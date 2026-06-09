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

function hl.cbind(keys, dispatcher, opts)
  opts = opts or {}

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

local function read_ppd_profile()
  local f = io.open(PPD_STATE, "r")
  if not f then
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

local function pmonitor_base_mode(mode)
  return mode:match("^(.-)@%d") or mode
end

local function pmonitor_hz(spec, profile)
  local refresh = spec.refresh
  if type(refresh) == "function" then
    return refresh(profile)
  end
  return refresh[profile] or refresh.default or refresh.balanced or 60
end

local function pmonitor_build_spec(spec, profile)
  local out = {}
  for k, v in pairs(spec) do
    if k ~= "refresh" then
      out[k] = v
    end
  end
  out.mode = string.format("%s@%d", pmonitor_base_mode(spec.mode), pmonitor_hz(spec, profile))
  return out
end

function hl.pmonitor(spec)
  if not spec.output or not spec.mode or not spec.refresh then
    error("hl.pmonitor requires output, mode, and refresh")
  end
  _pmonitors[#_pmonitors + 1] = spec
end

local function apply_pmonitors()
  local profile = read_ppd_profile()
  for _, spec in ipairs(_pmonitors) do
    local key = spec.output
    local hz = pmonitor_hz(spec, profile)
    if _pmonitor_applied[key] ~= profile .. ":" .. hz then
      _pmonitor_applied[key] = profile .. ":" .. hz
      hl.monitor(pmonitor_build_spec(spec, profile))
    end
  end
end

hl.on("hyprland.start", apply_pmonitors)
hl.on("config.reloaded", apply_pmonitors)

local _pmonitor_poll = hl.timer(apply_pmonitors, { timeout = 10000, type = "repeat" })
_pmonitor_poll:set_enabled(true)

return M
