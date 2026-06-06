local M = {}

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

return M
