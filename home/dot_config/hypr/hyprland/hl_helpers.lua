-- Helpers shared by the rest of the config.

local M = {}

local function shell_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

-- Route notifications through the freedesktop notification server.
function hl.notify(opts)
  opts = opts or {}
  local text = opts.text or opts.summary
  if not text then
    error("hl.notify: 'text' is required")
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

local _orig_bind = hl.bind

function hl.cbind(keys, dispatcher, opts)
  opts = opts or {}

  local bind_opts = {}
  for k, value in pairs(opts) do
    if k ~= "desc" and k ~= "category" and k ~= "icon" and k ~= "order" then
      bind_opts[k] = value
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

return M
