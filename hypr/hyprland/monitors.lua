-- Monitor layout only.
--
-- asus-ptpd owns the internal panel's refresh rate and follows the
-- power-profiles-daemon profile.  Keeping the mode out of Hyprland's
-- polling loop is what removes the old ~10 s switch delay.
--
-- Hyprland's Lua API only lists *enabled* monitors, so a disabled
-- external is invisible to hl.get_monitor().  Always ask for the
-- external first and only park the laptop once it is actually up.
--
-- hl.monitor() merges into the existing rule for an output, so every
-- field we care about must be set explicitly.  Without disabled = false
-- a later hl.monitor(laptop) inherits disabled = true and the panel
-- never comes back.

local LAPTOP = "eDP-1"

local laptop = {
  output = LAPTOP,
  mode = "2880x1800@60",
  position = "0x0",
  scale = 1.25,
  disabled = false,
}

local external = {
  output = "desc:LG Electronics LG ULTRAFINE 508NTABKV160",
  mode = "3840x2160@60",
  position = "0x0",
  scale = 1.25,
  disabled = false,
}

-- hl.get_monitors() returns enabled outputs only.  A non-eDP entry is
-- therefore a live second screen, not just a plugged-in connector.
local function external_enabled()
  for _, mon in ipairs(hl.get_monitors()) do
    local name = mon.name or ""
    if name ~= LAPTOP and name ~= "FALLBACK" and not name:match("^HEADLESS") then
      return true
    end
  end
  return false
end

local applied = nil

local function apply(force)
  local want = external_enabled() and "external" or "laptop"
  if not force and applied == want then
    return
  end
  applied = want

  if want == "external" then
    -- Bring the external up first, then park the laptop panel.
    hl.monitor(external)
    hl.monitor({ output = LAPTOP, disabled = true })
  else
    -- No second screen: the laptop panel must stay usable.  Enabling an
    -- absent output is a no-op, so this also repairs the external rule.
    hl.monitor(laptop)
    hl.monitor(external)
  end
end

-- Debounce: give the external's modeset time to settle before parking
-- the laptop panel.  One pending timer, never a repeating one.
local pending = false
local function apply_soon(force)
  if pending then
    return
  end
  pending = true
  local timer = hl.timer(function()
    pending = false
    apply(force)
  end, { timeout = 1200, type = "oneshot" })
  timer:set_enabled(true)
end

hl.on("hyprland.start", function()
  applied = nil
  apply_soon(true)
end)

hl.on("config.reloaded", function()
  -- A reload clears the monitor rules, so re-apply even if the desired
  -- state looks unchanged.
  applied = nil
  apply_soon(true)
end)

hl.on("monitor.added", function(mon)
  -- Only a new *external* changes the layout.  eDP appearing is the
  -- result of this file re-enabling it, not a reason to disable it.
  if mon == nil or mon.name ~= LAPTOP then
    apply_soon(false)
  end
end)

hl.on("monitor.removed", function(mon)
  -- Only the external leaving changes the layout.  eDP disappearing is
  -- the result of this file disabling it; re-enabling it here would
  -- start an infinite disable/enable loop.
  if mon == nil or mon.name ~= LAPTOP then
    apply_soon(false)
  end
end)
