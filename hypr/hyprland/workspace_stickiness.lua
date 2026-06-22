-- Workspace stickiness via PID-tree provenance.
--
-- Manual top-level launches stay on the workspace Hyprland initially assigns
-- (usually the active one). Windows stick to another workspace only when the
-- PID tree shows they belong to an existing anchored tree:
--   • shell-mediated launch (app → shell → terminal on ws N)
--   • same-process popup (same pid, floating dialog)
--   • child of a process already anchored to ws N

local SHELLS = {
  bash = true,
  dash = true,
  fish = true,
  nu = true,
  sh = true,
  zsh = true,
}

-- pid -> workspace name for manually rooted / inherited trees
local _anchors = {}
-- windows relocated to a background workspace during open_early
local _relocated = {}

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

local function get_comm(pid)
  local f = io.open("/proc/" .. pid .. "/comm")
  if f == nil then
    return nil
  end
  local comm = f:read("*l")
  f:close()
  return comm
end

local function is_shell(pid)
  local comm = get_comm(pid)
  return comm ~= nil and SHELLS[comm] or false
end

local function build_pid_chain(pid)
  local chain = {}
  local visited = {}
  local current = pid

  while current ~= nil and current > 1 do
    if visited[current] then
      break
    end
    visited[current] = true
    chain[#chain + 1] = current
    current = get_ppid(current)
  end

  return chain
end

local function find_window_for_pid(pid, exclude_win)
  for _, w in ipairs(hl.get_windows()) do
    if w ~= exclude_win and w.pid == pid and w.workspace ~= nil then
      return w
    end
  end
  return nil
end

local function workspace_by_name(name)
  local active = hl.get_active_workspace()
  if active ~= nil and active.name == name then
    return active
  end

  for _, w in ipairs(hl.get_windows()) do
    if w.workspace ~= nil and w.workspace.name == name then
      return w.workspace
    end
  end

  return nil
end

local function register_anchor(pid, ws_name)
  if pid ~= nil and ws_name ~= nil then
    _anchors[pid] = ws_name
  end
end

local function win_key(win)
  return tostring(win.pid) .. ":" .. tostring(win.class) .. ":" .. tostring(win.title)
end

-- Return a workspace to stick to, or nil to keep the window on its initial workspace.
local function resolve_stick_target(win)
  if win.pid == nil then
    return nil
  end

  local chain = build_pid_chain(win.pid)

  -- Same-pid popup/dialog from an existing window on another workspace.
  local same_pid_opener = find_window_for_pid(win.pid, win)
  if same_pid_opener ~= nil and same_pid_opener.workspace.name ~= win.workspace.name then
    if win.float then
      return same_pid_opener.workspace
    end
  end

  -- Shell-mediated: app → shell → … → window-owning ancestor.
  for i, pid in ipairs(chain) do
    if is_shell(pid) then
      for j = i + 1, #chain do
        local opener = find_window_for_pid(chain[j], win)
        if opener ~= nil then
          return opener.workspace
        end
      end
    end
  end

  -- Inherited anchor from an ancestor process in this tree.
  for i = 2, #chain do
    local ws_name = _anchors[chain[i]]
    if ws_name ~= nil then
      return workspace_by_name(ws_name)
    end
  end

  return nil
end

hl.on("window.open_early", function(win)
  if win.pid == nil or win.workspace == nil then
    return
  end

  if win.workspace.name:match("^special:") then
    return
  end

  local initial_ws = win.workspace.name
  local target = resolve_stick_target(win)

  if target ~= nil and target.name ~= initial_ws then
    hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "1", window = win }))
    hl.dispatch(hl.dsp.window.move({
      window = win,
      workspace = target,
      follow = false,
    }))
    register_anchor(win.pid, target.name)
    _relocated[win_key(win)] = true
    return
  end

  register_anchor(win.pid, initial_ws)
end)

hl.on("window.open", function(win)
  if win.pid == nil or win.workspace == nil then
    return
  end

  if not _relocated[win_key(win)] then
    return
  end
  _relocated[win_key(win)] = nil

  local active = hl.get_active_workspace()
  if active == nil or win.workspace.name == active.name then
    return
  end

  hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "0", window = win }))
  hl.dispatch(hl.dsp.window.set_prop({ prop = "focus_on_activate", value = "0", window = win }))
end)
