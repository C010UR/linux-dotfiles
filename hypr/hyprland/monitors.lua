-- Monitor layout.
--
-- Two owners, one job each:
--   * this file decides which outputs are lit;
--   * asus-ptpd decides the internal panel's refresh rate and follows the
--     power-profiles-daemon profile.
--
-- The laptop rule deliberately has no fixed `mode`.  hl.monitor() merges
-- into the existing rule for an output, so the rate asus-ptpd last
-- selected stays in the rule and survives a dock/undock.  At config load
-- the rule is rebuilt from scratch, so it is seeded with the panel's
-- actual current rate instead of a hardcoded one; the daemon still owns
-- every later change.
--
-- Everything below is a reconcile from observed state.  Hyprland lists
-- enabled outputs by default and all outputs with { all = true }, so we
-- never need a cached "last applied" value that can go stale.

local LAPTOP = "eDP-1"

local laptop_on = {
  output = LAPTOP,
  position = "0x0",
  scale = 1.25,
  disabled = false,
}

local laptop_off = {
  output = LAPTOP,
  disabled = true,
}

local external = {
  output = "desc:LG Electronics LG ULTRAFINE 508NTABKV160",
  mode = "3840x2160@60",
  position = "0x0",
  scale = 1.25,
  disabled = false,
}

-- Enabled outputs only.  A plugged-in but disabled screen is not a second
-- screen, so it must not park the laptop panel.
local function external_enabled()
  for _, mon in ipairs(hl.get_monitors()) do
    local name = mon.name or ""
    if name ~= LAPTOP and name ~= "FALLBACK" and not name:match("^HEADLESS") then
      return true
    end
  end
  return false
end

-- Includes disabled outputs, so we can tell whether the panel is parked.
local function laptop_enabled()
  for _, mon in ipairs(hl.get_monitors({ all = true })) do
    if mon.name == LAPTOP then
      return mon.enabled
    end
  end
  return false
end

-- The panel's current rate, used only to seed the rule at config load so
-- a reload does not reset the panel to its EDID preferred mode.  Returns
-- nil when the output has not reported a mode yet, in which case the
-- rule simply has no mode and Hyprland uses preferred.
local function laptop_current_mode()
  for _, mon in ipairs(hl.get_monitors({ all = true })) do
    if mon.name == LAPTOP then
      local width, height, hz = mon.width, mon.height, mon.refresh_rate
      if width and height and hz and width > 0 and height > 0 and hz > 0 then
        return string.format("%dx%d@%d", width, height, math.floor(hz + 0.5))
      end
    end
  end
  return nil
end

local function reconcile()
  if external_enabled() then
    -- Park the panel only when a live second output can take over.
    if laptop_enabled() then
      hl.monitor(laptop_off)
    end
  elseif not laptop_enabled() then
    hl.monitor(laptop_on)
  end
end

-- Register both rules once per config load.  Rules are matched by output,
-- so a monitor that appears later is configured by its rule instead of by
-- a follow-up modeset.  The laptop rule is seeded with the panel's current
-- rate and, while docked, with disabled = true, so reloading the config
-- neither resets the rate nor briefly wakes the panel.  Runtime changes
-- use the mode-less specs above so the daemon's choice is never
-- overwritten.
hl.monitor({
  output = LAPTOP,
  position = "0x0",
  scale = 1.25,
  disabled = external_enabled(),
  mode = laptop_current_mode(),
})
hl.monitor(external)

-- Debounce hotplug bursts: the compositor is still applying its own layout
-- when the first event lands.  One pending timer, never a repeating one.
local pending = false
local function reconcile_soon()
  if pending then
    return
  end
  pending = true
  local timer = hl.timer(function()
    pending = false
    reconcile()
  end, { timeout = 1200, type = "oneshot" })
  timer:set_enabled(true)
end

-- monitor.removed can hand us an expired object, so the handlers ignore
-- their argument and reconcile from hl.get_monitors() instead.  A
-- reconcile that finds nothing to do writes nothing, which is what makes
-- disabling the panel safe: the resulting monitor.removed event cannot
-- start a disable/enable loop.
hl.on("hyprland.start", reconcile_soon)
hl.on("config.reloaded", reconcile_soon)
hl.on("monitor.added", reconcile_soon)
hl.on("monitor.removed", reconcile_soon)
hl.on("monitor.layout_changed", reconcile_soon)

return { reconcile = reconcile }
