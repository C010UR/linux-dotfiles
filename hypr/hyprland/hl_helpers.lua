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


return M
