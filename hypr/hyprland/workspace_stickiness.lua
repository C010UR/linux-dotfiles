-- Generic workspace stickiness.
--
-- Goal: a window opened by another window lands on that opener's *current*
-- workspace, without dragging the user there. This covers app popups/dialogs
-- (same pid as the main window) and apps launched from another window such as a
-- terminal (resolved by walking the process tree). Brand-new top-level launches
-- have no opener window, so they fall through to Hyprland's native
-- initial_workspace_tracking (single-shot) instead.

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

-- Map every existing window's pid to its workspace. When several windows share
-- a pid (e.g. an app with multiple windows), prefer the one on the currently
-- active workspace -- it is the most likely opener of a new popup.
local function build_pid_workspace_map(exclude_win)
  local active = hl.get_active_workspace()
  local active_name = active and active.name or nil

  local pid_to_ws = {}
  for _, w in ipairs(hl.get_windows()) do
    if w ~= exclude_win and w.pid ~= nil and w.workspace ~= nil then
      local existing = pid_to_ws[w.pid]
      if existing == nil or (active_name ~= nil and w.workspace.name == active_name) then
        pid_to_ws[w.pid] = w.workspace
      end
    end
  end

  return pid_to_ws
end

-- Walk the new window's process ancestry (itself first, then parents) and return
-- the workspace of the nearest ancestor that already owns a window.
local function resolve_opener_workspace(win)
  if win.pid == nil then
    return nil
  end

  local pid_to_ws = build_pid_workspace_map(win)

  local visited = {}
  local current = win.pid
  while current ~= nil and current > 1 do
    if visited[current] then
      break
    end
    visited[current] = true

    if pid_to_ws[current] ~= nil then
      return pid_to_ws[current]
    end

    current = get_ppid(current)
  end

  return nil
end

hl.on("window.open_early", function(win)
  if win.pid == nil or win.workspace == nil then
    return
  end

  -- A window rule (or its parent) already placed it on a special workspace;
  -- leave it alone.
  if win.workspace.name:match("^special:") then
    return
  end

  local target = resolve_opener_workspace(win)
  if target == nil or target.name == win.workspace.name then
    return
  end

  -- Block focus while we relocate to a background workspace so the window can't
  -- steal it from the user. Restored in window.open below.
  hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "1", window = win }))
  hl.dispatch(hl.dsp.window.move({
    window = win,
    workspace = target,
    follow = false,
  }))
end)

hl.on("window.open", function(win)
  if win.pid == nil or win.workspace == nil then
    return
  end

  local active = hl.get_active_workspace()
  local target = resolve_opener_workspace(win)

  -- Only touch windows we relocated to a non-active (background) workspace.
  if target == nil or active == nil or target.name == active.name then
    return
  end

  -- Make it normally focusable again (so the user can focus it once they switch
  -- to that workspace), but keep it from yanking focus on later activation.
  hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "0", window = win }))
  hl.dispatch(hl.dsp.window.set_prop({ prop = "focus_on_activate", value = "0", window = win }))
end)
