-- Shared variables — require this module from any sub-config that needs app
-- names, cursor settings, or the color scheme.

local M = {}

-- Apps
M.terminal = "ghostty"
M.browser = "google-chrome-stable"
M.editor = "nvim"

-- Cursor
M.cursorTheme = "polarnight-cursors"
M.cursorSize = 24

-- Pointer device names (from `hyprctl devices`)
M.touchpadDevice = "asuf1209:00-2808:0219-touchpad"
M.mouseDevices = {
  "compx-2.4g-wireless-receiver-1",
  "compx-2.4g-wireless-receiver-consumer-control-1",
}

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

-- ── Persisted device state (touchpad + auto brightness) ──────────────────────

local _STATE_DIR = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/hypr"
local _touchpad_state_file = _STATE_DIR .. "/touchpad_state"
local _wluma_state_file = _STATE_DIR .. "/wluma_autobrightness_state"

local function _ensure_state_dir()
  os.execute("mkdir -p " .. _STATE_DIR)
end

local function _read_state_file(path, default)
  local f = io.open(path, "r")
  if not f then
    return default
  end
  local s = f:read("*l")
  f:close()
  if not s or s == "" then
    return default
  end
  return s
end

local function _write_state_file(path, state)
  _ensure_state_dir()
  local f = io.open(path, "w")
  if f then
    f:write(state)
    f:close()
  end
end

local function _read_touchpad_state()
  return _read_state_file(_touchpad_state_file, "enabled")
end

local function _write_touchpad_state(state)
  _write_state_file(_touchpad_state_file, state)
end

local function _read_wluma_state()
  return _read_state_file(_wluma_state_file, "enabled")
end

local function _write_wluma_state(state)
  _write_state_file(_wluma_state_file, state)
end

local function _brightness_current()
  local handle = io.popen("brightnessctl g 2>/dev/null")
  if not handle then
    return 0, 100
  end
  local cur = tonumber(handle:read("*l")) or 0
  handle:close()

  handle = io.popen("brightnessctl m 2>/dev/null")
  if not handle then
    return cur, 100
  end
  local max = tonumber(handle:read("*l")) or 100
  handle:close()

  return cur, max
end

function M.apply_touchpad_state()
  local enabled = _read_touchpad_state() == "enabled"
  hl.device({ name = M.touchpadDevice, enabled = enabled })
end

function M.apply_autobrightness_state()
  if _read_wluma_state() == "enabled" then
    hl.exec_cmd("systemctl --user start wluma.service")
  else
    hl.exec_cmd("systemctl --user stop wluma.service")
  end
end

function M.apply_persisted_state()
  M.apply_touchpad_state()
  M.apply_autobrightness_state()
end

function M.disable_autobrightness(silent)
  if _read_wluma_state() ~= "enabled" then
    return
  end
  hl.exec_cmd("systemctl --user stop wluma.service")
  _write_wluma_state("disabled")
  if not silent then
    hl.caelestia_notification({
      text = "Auto brightness: Disabled",
      duration = 2000,
      icon = "info",
    })
  end
end

function M.toggle_touchpad()
  local enabled = _read_touchpad_state() == "enabled"
  local next_state = enabled and "disabled" or "enabled"
  hl.device({ name = M.touchpadDevice, enabled = not enabled })
  _write_touchpad_state(next_state)
  hl.caelestia_notification({
    text = "Touchpad: " .. (enabled and "Disabled" or "Enabled"),
    duration = 2000,
    icon = "info",
  })
end

function M.toggle_autobrightness()
  local enabled = _read_wluma_state() == "enabled"
  if enabled then
    M.disable_autobrightness(false)
  else
    hl.exec_cmd("systemctl --user start wluma.service")
    _write_wluma_state("enabled")
    hl.caelestia_notification({
      text = "Auto brightness: Enabled",
      duration = 2000,
      icon = "info",
    })
  end
end

function M.brightness_down()
  M.disable_autobrightness(true)
  hl.dispatch(hl.dsp.global("caelestia:brightnessDown"))
end

function M.brightness_up()
  local auto_on = _read_wluma_state() == "enabled"
  local cur, max = _brightness_current()
  local at_max = cur >= max

  if auto_on and at_max then
    M.disable_autobrightness(true)
    hl.exec_cmd("brightnessctl s 100%")
    return
  end

  if auto_on then
    M.disable_autobrightness(true)
  end
  hl.dispatch(hl.dsp.global("caelestia:brightnessUp"))
end

-- ── Toggle Dolphin: show/hide as a special workspace overlay (special:dolphin).
-- The window rule automatically places dolphin there on first launch.
function M.toggle_dolphin()
  local wins = hl.get_windows({ class = "org.kde.dolphin" })
  if #wins == 0 then
    hl.exec_cmd("dolphin") -- window rule sends it to special:dolphin
    return
  end
  hl.dispatch(hl.dsp.workspace.toggle_special("dolphin"))
end

function M.get_config_path()
  local config = os.getenv("XDG_CONFIG_HOME")
  if not config then
    config = os.getenv("HOME") .. "/.config"
  end

  return config .. "/hypr"
end

return M
