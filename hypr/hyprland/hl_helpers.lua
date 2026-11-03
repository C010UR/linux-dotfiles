local M = {}

local function shell_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

-- Route notifications through Caelestia's freedesktop notification server.
function hl.caelestia_notification(opts)
  opts = opts or {}
  local text = opts.text or opts.summary
  if not text then
    error("hl.caelestia_notification: 'text' is required")
  end

  local timeout = opts.duration or opts.timeout or 2000
  local parts = {
    "notify-send",
    "-a",
    "hyprland",
    "-t",
    tostring(timeout),
  }

  if opts.icon then
    parts[#parts + 1] = "-i"
    parts[#parts + 1] = shell_quote(opts.icon)
  end

  if opts.urgency then
    parts[#parts + 1] = "-u"
    parts[#parts + 1] = shell_quote(opts.urgency)
  end

  parts[#parts + 1] = shell_quote(text)

  local body = opts.body
  if body and body ~= "" then
    parts[#parts + 1] = shell_quote(body)
  end

  hl.exec_cmd(table.concat(parts, " "))
end

local _keybinds = {}
local _orig_bind = hl.bind

local launcher_interrupt = hl.dsp.global("caelestia:launcherInterrupt")

function hl.cbind(keys, dispatcher, opts)
  opts = opts or {}

  local upper_keys = keys:upper()
  if upper_keys:find("SUPER", 1, true) and not upper_keys:find("SUPER_L", 1, true) then
    if opts.mouse then
      _orig_bind(keys, launcher_interrupt, { mouse = true })
    else
      _orig_bind(keys, launcher_interrupt)
    end
  end

  table.insert(_keybinds, {
    key = keys,
    desc = opts.desc or "",
    category = opts.category or "misc",
    icon = opts.icon or "help",
    locked = opts.locked or false,
    order = opts.order or 999,
  })

  local bind_opts = {}
  for k, v in pairs(opts) do
    if k ~= "desc" and k ~= "category" and k ~= "icon" and k ~= "order" then
      bind_opts[k] = v
    end
  end

  if opts.desc then
    bind_opts.description = opts.desc
  end

  if next(bind_opts) then
    _orig_bind(keys, dispatcher, bind_opts)
  else
    _orig_bind(keys, dispatcher)
  end
end

function M.export()
  local dir = os.getenv("HOME") .. "/.cache/quickshell/f1-window"
  os.execute("mkdir -p " .. dir)

  local function j(s)
    return '"' .. tostring(s):gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
  end

  local lines = { "[" }
  for i, kb in ipairs(_keybinds) do
    local c = i < #_keybinds and "," or ""
    lines[#lines + 1] = string.format(
      '  {"key":%s,"description":%s,"category":%s,"icon":%s,"locked":%s,"order":%d}%s',
      j(kb.key),
      j(kb.desc),
      j(kb.category),
      j(kb.icon),
      tostring(kb.locked),
      kb.order,
      c
    )
  end
  lines[#lines + 1] = "]"

  local f = io.open(dir .. "/hyprland_keybinds.json", "w")
  if f then
    f:write(table.concat(lines, "\n"))
    f:close()
  end
end

hl.on("hyprland.start", function()
  M.export()
end)

hl.on("config.reloaded", function()
  M.export()
end)

-- hl.pmonitor: profile-aware hl.monitor (refresh rate follows power-profiles-daemon)
local PPD_STATE = "/var/lib/power-profiles-daemon/state.ini"
local _pmonitors = {}
local _pmonitor_applied = {}

local function read_first_line(path)
  local f = io.open(path, "r")
  if f == nil then
    return nil
  end

  local line = f:read("*l")
  f:close()
  return line
end

local function read_ppd_profile()
  local f = io.open(PPD_STATE, "r")
  if f == nil then
    return "balanced"
  end

  for line in f:lines() do
    local profile = line:match("^Profile=(.+)$")
    if profile then
      f:close()
      return profile
    end
  end

  f:close()
  return "balanced"
end

local function on_ac()
  for _, name in ipairs({ "AC0", "AC", "ACAD", "ADP1" }) do
    local online = read_first_line("/sys/class/power_supply/" .. name .. "/online")
    if online ~= nil then
      return online == "1"
    end
  end

  local status = read_first_line("/sys/class/power_supply/BAT0/status")
  if status ~= nil then
    return status ~= "Discharging"
  end

  return true
end

local function pmonitor_base_mode(mode)
  return mode:match("^(.-)@") or mode
end

local function pmonitor_hz(spec, profile, ctx)
  local refresh = spec.refresh
  if type(refresh) == "function" then
    return refresh(profile, ctx)
  end

  local value = refresh[profile] or refresh.default or refresh.balanced or 60
  if type(value) == "function" then
    return value(ctx)
  end

  return value
end

local function split_mode(mode)
  local width, height = mode:match("^(%d+)x(%d+)")
  return tonumber(width), tonumber(height)
end

local function format_rate(rate)
  local rounded = math.floor(rate + 0.5)
  if math.abs(rate - rounded) < 0.01 then
    return string.format("%d", rounded)
  end
  return string.format("%g", rate)
end

local function pick_supported_mode(output, base, target_hz)
  local width, height = split_mode(base)
  if width == nil or height == nil then
    return string.format("%s@%s", base, format_rate(target_hz))
  end

  local mon = hl.get_monitor(output)
  if mon ~= nil and mon.available_modes ~= nil then
    local below, above
    for _, mode in ipairs(mon.available_modes) do
      if mode.width == width and mode.height == height then
        if mode.refresh_rate <= target_hz + 0.5 then
          if below == nil or mode.refresh_rate > below.refresh_rate then
            below = mode
          end
        elseif above == nil or mode.refresh_rate < above.refresh_rate then
          above = mode
        end
      end
    end

    local chosen = below or above
    if chosen ~= nil then
      return string.format("%dx%d@%s", chosen.width, chosen.height, format_rate(chosen.refresh_rate))
    end
  end

  return string.format("%dx%d@%s", width, height, format_rate(target_hz))
end

local function monitor_logical_width(mon)
  local scale = tonumber(mon.scale) or 1
  if scale <= 0 then
    scale = 1
  end
  return math.floor(mon.width / scale + 0.5)
end

local function compute_layout(active_specs)
  local ordered = {}
  for _, spec in ipairs(active_specs) do
    ordered[#ordered + 1] = spec
  end

  table.sort(ordered, function(a, b)
    return (a.layout_order or 999) < (b.layout_order or 999)
  end)

  local positions = {}
  local x = 0
  for _, spec in ipairs(ordered) do
    local mon = hl.get_monitor(spec.output)
    if mon ~= nil then
      positions[spec.output] = string.format("%dx0", x)
      x = x + monitor_logical_width(mon)
    end
  end

  return positions
end

local function pmonitor_build_spec(spec, mode, position)
  local out = {}
  for key, value in pairs(spec) do
    if key ~= "refresh" and key ~= "auto_disable" and key ~= "layout_order" then
      out[key] = value
    end
  end

  out.mode = mode
  out.position = position
  return out
end

function hl.pmonitor(spec)
  if not spec.output or not spec.mode or not spec.refresh then
    error("hl.pmonitor requires output, mode, and refresh")
  end
  _pmonitors[#_pmonitors + 1] = spec
end

local function other_monitors_present(except)
  for _, mon in ipairs(hl.get_monitors()) do
    local name = mon.name or ""
    if name ~= except and name ~= "FALLBACK" and not name:match("^HEADLESS") then
      return true
    end
  end
  return false
end

local function apply_pmonitors()
  local profile = read_ppd_profile()
  local ctx = { profile = profile, on_ac = on_ac() }

  local disabled = {}
  local active_specs = {}
  for _, spec in ipairs(_pmonitors) do
    if spec.auto_disable and other_monitors_present(spec.output) then
      disabled[spec.output] = true
    else
      active_specs[#active_specs + 1] = spec
    end
  end

  local positions = compute_layout(active_specs)

  for _, spec in ipairs(_pmonitors) do
    local key = spec.output
    if disabled[key] then
      if _pmonitor_applied[key] ~= "disabled" then
        _pmonitor_applied[key] = "disabled"
        hl.monitor({ output = spec.output, disabled = true })
      end
    else
      local hz = pmonitor_hz(spec, profile, ctx)
      local mode = pick_supported_mode(spec.output, pmonitor_base_mode(spec.mode), hz)
      local position = positions[key] or spec.position or "0x0"
      local tag = mode .. ":" .. position
      if _pmonitor_applied[key] ~= tag then
        _pmonitor_applied[key] = tag
        local mon_spec = pmonitor_build_spec(spec, mode, position)
        mon_spec.disabled = false
        hl.monitor(mon_spec)
      end
    end
  end
end

hl.apply_pmonitors = apply_pmonitors

local _apply_pending = false

local function schedule_apply()
  if _apply_pending then
    return
  end

  _apply_pending = true
  local timer = hl.timer(function()
    _apply_pending = false
    apply_pmonitors()
  end, { timeout = 250, type = "oneshot" })
  timer:set_enabled(true)
end

hl.on("hyprland.start", apply_pmonitors)
hl.on("monitor.added", schedule_apply)
hl.on("monitor.removed", schedule_apply)

local _pmonitor_poll = hl.timer(apply_pmonitors, { timeout = 2000, type = "repeat" })
_pmonitor_poll:set_enabled(true)

return M
