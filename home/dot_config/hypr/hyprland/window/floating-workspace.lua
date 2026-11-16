-- Per-workspace "floating" mode.
--
-- The default stays master: a workspace switched to floating has its tiled
-- windows floated, cascaded and centred, opens new windows floating, and
-- focuses on click rather than on hover. Switching back tiles exactly the
-- windows the mode floated, leaving windows that float on their own alone.
--
-- State is stored per workspace number in ~/.local/state/hypr/workspace-modes.

local compat = require("hyprland.window.compat")

local FLOATED_TAG = "mode-floated"
local WORKSPACE_TAG = "floating-workspace"
local STATE_FILE = compat.state_dir .. "/workspace-modes"

local M = {}

local modes = {}
local watching = false
local floating_ready = false
local cascade = 0
local follow_mouse = nil
local input_is_floating = nil

local function floating_workspace(id)
  id = tonumber(id)
  if not id or id < 1 then
    return false
  end

  return modes[tostring(id)] == "floating"
end

local function has_tag(window, tag)
  for _, value in ipairs(window.tags or {}) do
    if value == tag then
      return true
    end
  end

  return false
end

local function set_tag(window, tag, on)
  hl.dispatch(hl.dsp.window.tag({
    tag = (on and "+" or "-") .. tag,
    window = compat.address(window),
  }))
end

local function set_floating(window, floating)
  hl.dispatch(hl.dsp.window.float({
    action = floating and "on" or "off",
    window = compat.address(window),
  }))
end

-- Floating workspaces need depth and full opacity: overlapping translucent
-- windows are hard to tell apart, so these windows opt out of transparency.
local function ensure_setup()
  if floating_ready then
    return
  end

  floating_ready = true

  hl.window_rule({
    name = "floating-workspace-opaque",
    opacity = "1.0 override 1.0 override",
    match = { tag = WORKSPACE_TAG },
  })
end

-- Comfortable size, centred, each window stepped from the last so a workspace
-- floated all at once does not leave every window stacked exactly on top of
-- the one beneath it.
local function place(window)
  local monitor = window.monitor
  if not monitor or not monitor.width or not monitor.height then
    return
  end

  local scale = monitor.scale or 1
  local width = math.floor(monitor.width / scale)
  local height = math.floor(monitor.height / scale)

  if (monitor.transform or 0) % 2 == 1 then
    width, height = height, width
  end

  -- 0.57 reports reserved as [left, top, right, bottom]; 0.56 used named keys.
  local reserved = monitor.reserved
  local left, top, right, bottom = 0, 0, 0, 0
  if type(reserved) == "table" then
    left = reserved.left or reserved[1] or 0
    top = reserved.top or reserved[2] or 0
    right = reserved.right or reserved[3] or 0
    bottom = reserved.bottom or reserved[4] or 0
  end

  width = width - left - right
  height = height - top - bottom

  local target = compat.address(window)

  hl.dispatch(hl.dsp.window.resize({
    x = math.min(1100, math.floor(width * 0.64)),
    y = math.min(760, math.floor(height * 0.68)),
    relative = false,
    window = target,
  }))
  hl.dispatch(hl.dsp.window.center({ window = target }))

  cascade = (cascade + 1) % 5
  hl.dispatch(hl.dsp.window.move({
    x = cascade * 24 - 48,
    y = cascade * 24 - 48,
    relative = true,
    window = target,
  }))
end

local function arrange_for(workspace)
  workspace = tonumber(workspace)
  if not workspace then
    return
  end

  local windows = hl.get_workspace_windows(tostring(workspace))

  -- Back to master: give back only the floating the mode handed out. A window
  -- that was already floating (a dialog, something popped out) is left alone.
  if not floating_workspace(workspace) then
    for _, window in ipairs(windows) do
      set_tag(window, WORKSPACE_TAG, false)

      if has_tag(window, FLOATED_TAG) then
        set_tag(window, FLOATED_TAG, false)

        if not window.pinned then
          set_floating(window, false)
        end
      end
    end

    return
  end

  ensure_setup()

  -- Claim every tiled window before floating any of them: floating one member
  -- of a group floats the rest, and a single pass would then find those
  -- already floating and strand them when the mode ends.
  local claiming = {}

  for _, window in ipairs(windows) do
    set_tag(window, WORKSPACE_TAG, true)

    if not window.floating and (window.fullscreen or 0) == 0 then
      set_tag(window, FLOATED_TAG, true)
      claiming[#claiming + 1] = window
    end
  end

  for _, window in ipairs(claiming) do
    set_floating(window, true)
    place(window)
  end
end

local function save()
  compat.ensure_dir(compat.state_dir)

  local ids = {}
  for id in pairs(modes) do
    ids[#ids + 1] = id
  end
  table.sort(ids, function(left, right)
    return tonumber(left) < tonumber(right)
  end)

  local file = io.open(STATE_FILE, "w")
  if not file then
    return
  end

  for _, id in ipairs(ids) do
    file:write(id .. "\t" .. modes[id] .. "\n")
  end

  file:close()
end

local function load()
  local file = io.open(STATE_FILE, "r")
  if not file then
    return
  end

  for line in file:lines() do
    local id, mode = line:match("^(%d+)\t(%a+)$")
    if id and (mode == "floating" or mode == "master") then
      modes[id] = mode
    end
  end

  file:close()
end

local function active_floating()
  local workspace = hl.get_active_workspace()
  return workspace ~= nil and floating_workspace(workspace.id)
end

local function update_input()
  local active = active_floating()

  if active == input_is_floating then
    return
  end

  input_is_floating = active

  if follow_mouse == nil then
    follow_mouse = hl.get_config("input.follow_mouse") or 1
  end

  hl.config({ input = { follow_mouse = active and 0 or follow_mouse } })
end

-- Workspace of a window, searched only across floating workspaces. Used for
-- events whose window object may not carry its workspace.
local function workspace_of(window)
  for id, mode in pairs(modes) do
    if mode == "floating" then
      for _, candidate in ipairs(hl.get_workspace_windows(id)) do
        if candidate.address == window.address then
          return tonumber(id)
        end
      end
    end
  end

  return nil
end

-- A window opening on a floating workspace floats from the event, at the size
-- the mode gives it. Windows that float on their own account (dialogs, apps
-- with a float rule, something popped out) keep their own geometry.
local function id_for_open(window)
  local workspace = window.workspace
  if workspace and workspace.id then
    return tonumber(workspace.id)
  end

  local active = hl.get_active_workspace()
  return active and tonumber(active.id) or nil
end

local function watch()
  if watching then
    return
  end

  watching = true
  follow_mouse = hl.get_config("input.follow_mouse") or 1
  input_is_floating = false

  hl.on("window.open", function(window)
    if not window then
      return
    end

    local id = id_for_open(window)
    if not id or not floating_workspace(id) then
      return
    end

    set_tag(window, WORKSPACE_TAG, true)

    if window.floating or (window.fullscreen or 0) > 0 then
      return
    end

    set_tag(window, FLOATED_TAG, true)
    compat.after(1, function()
      set_floating(window, true)
      place(window)
    end)
  end)

  -- A window carried onto a floating workspace floats; one carried out gives
  -- the floating back rather than staying floating over a tiling workspace.
  hl.on("window.move_to_workspace", function(_, workspace)
    compat.after(1, function()
      if workspace and workspace.id then
        arrange_for(workspace.id)
      end

      update_input()
    end)
  end)

  -- A fullscreen window is left as it is, so arrange it once it comes back
  -- out: a tiled one leaving fullscreen on a floating workspace floats then.
  hl.on("window.fullscreen", function(window)
    compat.after(1, function()
      local id = workspace_of(window)
      if id then
        arrange_for(id)
      end
    end)
  end)

  hl.on("workspace.active", update_input)
  hl.on("monitor.focused", update_input)
end

function M.set(workspace, mode)
  workspace = tonumber(workspace)
  if not workspace or workspace < 1 then
    return
  end

  if mode ~= "floating" and mode ~= "master" then
    return
  end

  local key = tostring(workspace)

  -- Floating keeps whatever tiled layout the workspace had, so nothing has to
  -- be chosen for it on the way back out.
  if mode ~= "floating" then
    hl.workspace_rule({ workspace = key, layout = mode })
  end

  modes[key] = mode
  save()

  if mode == "floating" then
    ensure_setup()
  end

  arrange_for(workspace)
  update_input()
end

function M.toggle(workspace)
  local target = tonumber(workspace)

  if not target then
    local active = hl.get_active_workspace()
    if not active then
      return
    end
    target = tonumber(active.id)
  end

  if not target or target < 1 then
    return
  end

  local mode = floating_workspace(target) and "master" or "floating"
  M.set(target, mode)
  compat.notify("Workspace " .. target .. ": " .. mode)
end

function M.is_floating(workspace)
  return floating_workspace(workspace)
end

local function apply_all()
  for id, mode in pairs(modes) do
    if mode == "floating" then
      ensure_setup()
      arrange_for(tonumber(id))
    end
  end

  update_input()
end

load()

hl.on("hyprland.start", function()
  watch()
  apply_all()
end)

hl.on("config.reloaded", function()
  watch()
  apply_all()
end)

-- `hyprctl dispatch 'function() o.floating.toggle(9) end'` runs the same thing
-- as the key, which keeps the action usable from scripts and menu entries.
o = o or {}
o.floating = M

return M
