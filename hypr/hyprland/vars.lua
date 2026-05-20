-- Shared variables — require this module from any sub-config that needs app
-- names, cursor settings, or the color scheme.

local M = {}

-- Apps
M.terminal = "ghostty"
M.browser  = "google-chrome-stable"
M.editor   = "nvim"

-- Cursor
M.cursorTheme = "polarnight-cursors"
M.cursorSize  = 24

-- Touchpad device name (from `hyprctl devices`)
M.touchpadDevice = "asuf1209:00-2808:0219-touchpad"

-- ── Workspace helpers (replaces wsaction.fish) ───────────────────────────────
-- Workspaces are grouped in bands of 10 (ws 1–10, 11–20, …).
-- Normal mode: stay in the current group, jump to slot N within it.
-- Group mode:  stay in the current slot, jump to group N.

local function active_ws_id()
  return hl.get_active_workspace().id
end

function M.ws_goto(n)
  local id = math.floor((active_ws_id() - 1) / 10) * 10 + n
  hl.dispatch(hl.dsp.focus({ workspace = id }))
end

function M.ws_goto_group(n)
  local id = (n - 1) * 10 + (active_ws_id() % 10)
  hl.dispatch(hl.dsp.focus({ workspace = id }))
end

function M.ws_move(n)
  local id = math.floor((active_ws_id() - 1) / 10) * 10 + n
  hl.dispatch(hl.dsp.window.move({ workspace = id }))
end

function M.ws_move_group(n)
  local id = (n - 1) * 10 + (active_ws_id() % 10)
  hl.dispatch(hl.dsp.window.move({ workspace = id }))
end

-- ── Touchpad toggle (replaces toggle-touchpad.sh) ────────────────────────────

local _touchpad_state_file = "/tmp/touchpad_state"

local function _read_touchpad_state()
  local f = io.open(_touchpad_state_file, "r")
  if not f then return "enabled" end
  local s = f:read("*l"); f:close()
  return s
end

local function _write_touchpad_state(state)
  local f = io.open(_touchpad_state_file, "w")
  if f then f:write(state); f:close() end
end

function M.toggle_touchpad()
  local enabled = _read_touchpad_state() == "enabled"
  hl.device({ name = M.touchpadDevice, enabled = not enabled })
  _write_touchpad_state(enabled and "disabled" or "enabled")
  hl.notification.create({
    text     = "Touchpad: " .. (enabled and "Disabled" or "Enabled"),
    duration = 2000,
    icon     = "info",
  })
end

-- ── Toggle Dolphin: show/hide as a special workspace overlay (special:dolphin).
-- The window rule automatically places dolphin there on first launch.
function M.toggle_dolphin()
  local wins = hl.get_windows({ class = "org.kde.dolphin" })
  if #wins == 0 then
    hl.exec_cmd("dolphin")  -- window rule sends it to special:dolphin
    return
  end
  hl.dispatch(hl.dsp.workspace.toggle_special("dolphin"))
end

return M
