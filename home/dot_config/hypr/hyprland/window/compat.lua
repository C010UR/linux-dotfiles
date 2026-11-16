-- Helpers shared by the window-management modules.
-- Kept deliberately small: state paths, quoting, notifications, and a one-shot
-- timer helper (Hyprland's Lua timers do not start on their own).

local M = {}

M.home = os.getenv("HOME")
M.state_home = os.getenv("XDG_STATE_HOME") or (M.home .. "/.local/state")
M.state_dir = M.state_home .. "/hypr"

function M.shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

function M.ensure_dir(path)
  os.execute("mkdir -p " .. M.shell_quote(path))
end

function M.after(ms, fn)
  local timer = hl.timer(fn, { type = "oneshot", timeout = ms or 1 })
  if timer and timer.set_enabled then
    timer:set_enabled(true)
  end
end

function M.notify(text)
  if hl.notify then
    hl.notify({ text = text, duration = 2000, icon = "info" })
  else
    hl.exec_cmd("notify-send -a hyprland " .. M.shell_quote(text))
  end
end

function M.address(window)
  return "address:" .. window.address
end

return M
