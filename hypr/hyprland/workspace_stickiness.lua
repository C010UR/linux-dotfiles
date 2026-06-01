-- Keep child windows on the same workspace as related existing windows.
-- Uses process parent/ancestor relationships so Playwright popups, Steam
-- windows, and other forked children follow the original window.

local focus_anchor = nil
local focus_workspace = nil

local function get_ppid(pid)
  local f = io.open("/proc/" .. pid .. "/status")
  if f == nil then
    return nil
  end

  local ppid
  for line in f:lines() do
    ppid = line:match("^PPid:%s+(%d+)$")
    if ppid ~= nil then
      break
    end
  end
  f:close()

  return ppid and tonumber(ppid) or nil
end

local function build_process_maps(exclude_win)
  local pid_to_ws = {}
  local ppid_to_ws = {}

  for _, w in ipairs(hl.get_windows()) do
    if w ~= exclude_win and w.pid ~= nil and w.workspace ~= nil then
      pid_to_ws[w.pid] = w.workspace

      local ppid = get_ppid(w.pid)
      if ppid ~= nil and ppid_to_ws[ppid] == nil then
        ppid_to_ws[ppid] = w.workspace
      end
    end
  end

  return pid_to_ws, ppid_to_ws
end

local function find_related_workspace(pid, pid_to_ws, ppid_to_ws)
  local visited = {}
  local current = pid

  while current ~= nil and current > 1 do
    if visited[current] then
      break
    end
    visited[current] = true

    if pid_to_ws[current] ~= nil then
      return pid_to_ws[current]
    end

    local ppid = get_ppid(current)
    if ppid == nil then
      break
    end

    if pid_to_ws[ppid] ~= nil then
      return pid_to_ws[ppid]
    end

    if ppid_to_ws[ppid] ~= nil then
      return ppid_to_ws[ppid]
    end

    current = ppid
  end

  return nil
end

local function get_cmdline(pid)
  local f = io.open("/proc/" .. pid .. "/cmdline", "rb")
  if f == nil then
    return ""
  end

  local data = f:read("*a")
  f:close()
  return data:gsub("\0", " ")
end

local function is_playwright_process(pid)
  local visited = {}
  local current = pid

  while current ~= nil and current > 1 do
    if visited[current] then
      break
    end
    visited[current] = true

    local cmdline = get_cmdline(current):lower()
    if cmdline:find("playwright", 1, true) ~= nil or cmdline:find("ms%-playwright", 1, true) ~= nil then
      return true
    end

    current = get_ppid(current)
  end

  return false
end

local function should_suppress_focus(win)
  if win.pid == nil then
    return false
  end

  if is_playwright_process(win.pid) then
    return true
  end

  local pid_to_ws, ppid_to_ws = build_process_maps(win)
  return find_related_workspace(win.pid, pid_to_ws, ppid_to_ws) ~= nil
end

local function remember_focus()
  local ws = hl.get_active_workspace()
  if ws ~= nil then
    focus_workspace = ws
  end

  local active = hl.get_active_window()
  if active ~= nil and not should_suppress_focus(active) then
    focus_anchor = active
  end
end

local function restore_focus()
  if focus_workspace ~= nil then
    local current = hl.get_active_workspace()
    if current == nil or current.name ~= focus_workspace.name then
      hl.dispatch(hl.dsp.focus({ workspace = focus_workspace }))
    end
  end

  if focus_anchor ~= nil and focus_anchor.mapped then
    hl.dispatch(hl.dsp.focus({ window = focus_anchor }))
  end
end

hl.on("window.open_early", function(win)
  if win.pid == nil or win.workspace == nil then
    return
  end

  if should_suppress_focus(win) then
    remember_focus()
  end

  local pid_to_ws, ppid_to_ws = build_process_maps(win)
  local target_ws = find_related_workspace(win.pid, pid_to_ws, ppid_to_ws)

  if target_ws ~= nil and target_ws.name ~= win.workspace.name then
    hl.dispatch(hl.dsp.window.move({
      window = win,
      workspace = target_ws,
      follow = false,
    }))
  end
end)

hl.on("window.open", function(win)
  if not should_suppress_focus(win) then
    return
  end

  hl.dispatch(hl.dsp.window.set_prop({ prop = "focus_on_activate", value = "0", window = win }))

  -- Defer refocus so we don't fight Hyprland during window creation.
  hl.timer(function()
    restore_focus()
  end, { timeout = 50, type = "oneshot" })
end)

hl.on("window.active", function(win, active)
  if active == 0 or should_suppress_focus(win) then
    return
  end

  focus_anchor = win
  focus_workspace = win.workspace
end)
