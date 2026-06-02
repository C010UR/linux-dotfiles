-- Playwright headed tests: keep browser windows on the same workspace as the
-- rest of the test session, without stealing focus or workspace from the user.
-- Normal app launches are handled by misc.initial_workspace_tracking instead.

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

local function build_playwright_maps(exclude_win)
  local pid_to_ws = {}
  local ppid_to_ws = {}

  for _, w in ipairs(hl.get_windows()) do
    if w ~= exclude_win and w.pid ~= nil and w.workspace ~= nil and is_playwright_process(w.pid) then
      pid_to_ws[w.pid] = w.workspace

      local ppid = get_ppid(w.pid)
      if ppid ~= nil and ppid_to_ws[ppid] == nil then
        ppid_to_ws[ppid] = w.workspace
      end
    end
  end

  return pid_to_ws, ppid_to_ws
end

local function find_playwright_workspace(pid, pid_to_ws, ppid_to_ws)
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

-- For the first browser window in a run, walk up to the terminal (or other
-- parent app) that launched the Playwright process.
local function find_launcher_workspace(pid, exclude_win)
  local visited = {}
  local current = pid

  while current ~= nil and current > 1 do
    if visited[current] then
      break
    end
    visited[current] = true

    for _, w in ipairs(hl.get_windows()) do
      if w ~= exclude_win and w.pid == current and w.workspace ~= nil and not is_playwright_process(w.pid) then
        return w.workspace
      end
    end

    current = get_ppid(current)
  end

  return nil
end

local function resolve_playwright_workspace(win)
  local pid_to_ws, ppid_to_ws = build_playwright_maps(win)
  return find_playwright_workspace(win.pid, pid_to_ws, ppid_to_ws) or find_launcher_workspace(win.pid, win)
end

hl.on("window.open_early", function(win)
  if win.pid == nil or win.workspace == nil or not is_playwright_process(win.pid) then
    return
  end

  hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "1", window = win }))

  local target_ws = resolve_playwright_workspace(win)

  if target_ws ~= nil and target_ws.name ~= win.workspace.name then
    hl.dispatch(hl.dsp.window.move({
      window = win,
      workspace = target_ws,
      follow = false,
    }))
  end
end)

hl.on("window.open", function(win)
  if win.pid == nil or not is_playwright_process(win.pid) then
    return
  end

  hl.dispatch(hl.dsp.window.set_prop({ prop = "no_focus", value = "0", window = win }))
  hl.dispatch(hl.dsp.window.set_prop({ prop = "focus_on_activate", value = "0", window = win }))
end)
