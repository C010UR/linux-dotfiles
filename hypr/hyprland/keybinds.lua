local v = require("hyprland.vars")

-- ── Shell / Caelestia keybinds ────────────────────────────────────────────────

hl.cbind("SUPER + Super_L", hl.dsp.global("caelestia:launcher"), {
  desc = "Toggle Launcher",
  category = "shell",
  icon = "apps",
  order = 10,
})

hl.cbind("CTRL + ALT + Delete", hl.dsp.global("caelestia:session"), {
  desc = "Session Menu",
  category = "shell",
  icon = "logout",
  order = 50,
})
hl.cbind("CTRL + ALT + C", hl.dsp.global("caelestia:clearNotifs"), {
  desc = "Clear Notifications",
  category = "shell",
  icon = "notifications_off",
  locked = true,
  order = 60,
})
hl.cbind("SUPER + K", hl.dsp.global("caelestia:dashboard"), {
  desc = "Toggle Dashboard",
  category = "shell",
  icon = "dashboard",
  order = 20,
})
hl.cbind("SUPER + L", hl.dsp.global("caelestia:lock"), {
  desc = "Lock Screen",
  category = "shell",
  icon = "lock",
  order = 40,
})
hl.cbind("SUPER + F1", hl.dsp.global("clste:toggleF1"), {
  desc = "Toggle Keybinds",
  category = "shell",
  icon = "help",
  order = 30,
})
hl.cbind("SUPER + F6", hl.dsp.global("clste:toggleAutoclickerWindow"), {
  desc = "Autoclicker config",
  category = "shell",
  icon = "touch_app",
  order = 31,
})
hl.cbind("F6", hl.dsp.global("clste:toggleAutoclicker"), {
  desc = "Toggle autoclicker",
  category = "shell",
  icon = "ads_click",
  order = 32,
})

-- Restore lock: restart shell then lock
hl.cbind("SUPER + ALT + L", hl.dsp.exec_cmd("caelestia shell -d"), {
  desc = "Restart Shell",
  category = "shell",
  icon = "restart_alt",
  locked = true,
  order = 80,
})
hl.cbind("SUPER + ALT + L", hl.dsp.global("caelestia:lock"), {
  desc = "Lock Screen",
  category = "shell",
  icon = "lock",
  locked = true,
  order = 85,
})

-- Brightness
hl.cbind("XF86MonBrightnessUp", v.brightness_up, {
  desc = "Brightness Up",
  category = "media",
  icon = "brightness_6",
  locked = true,
  order = 10,
})
hl.cbind("XF86MonBrightnessDown", v.brightness_down, {
  desc = "Brightness Down",
  category = "media",
  icon = "brightness_5",
  locked = true,
  order = 20,
})
hl.cbind("SUPER + SHIFT + B", v.toggle_autobrightness, {
  desc = "Toggle Auto Brightness",
  category = "media",
  icon = "brightness_auto",
  order = 30,
})

-- Media controls
hl.cbind("CTRL + SUPER + SPACE", hl.dsp.global("caelestia:mediaToggle"), {
  desc = "Play / Pause",
  category = "media",
  icon = "play_pause",
  locked = true,
  order = 30,
})
hl.cbind("XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"), {
  desc = "Play / Pause",
  category = "media",
  icon = "play_pause",
  locked = true,
  order = 31,
})
hl.cbind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), {
  desc = "Play / Pause",
  category = "media",
  icon = "play_pause",
  locked = true,
  order = 32,
})
hl.cbind("CTRL + SUPER + Equal", hl.dsp.global("caelestia:mediaNext"), {
  desc = "Next Track",
  category = "media",
  icon = "skip_next",
  locked = true,
  order = 40,
})
hl.cbind("XF86AudioNext", hl.dsp.global("caelestia:mediaNext"), {
  desc = "Next Track",
  category = "media",
  icon = "skip_next",
  locked = true,
  order = 41,
})
hl.cbind("CTRL + SUPER + Minus", hl.dsp.global("caelestia:mediaPrev"), {
  desc = "Previous Track",
  category = "media",
  icon = "skip_previous",
  locked = true,
  order = 50,
})
hl.cbind("XF86AudioPrev", hl.dsp.global("caelestia:mediaPrev"), {
  desc = "Previous Track",
  category = "media",
  icon = "skip_previous",
  locked = true,
  order = 51,
})
hl.cbind("XF86AudioStop", hl.dsp.global("caelestia:mediaStop"), {
  desc = "Stop",
  category = "media",
  icon = "stop",
  locked = true,
  order = 60,
})

-- Kill / restart shell
hl.cbind("SUPER + SHIFT + R", hl.dsp.exec_cmd("qs -c caelestia kill"), {
  desc = "Kill Shell",
  category = "shell",
  icon = "close",
  release = true,
  order = 90,
})
hl.cbind("SUPER + ALT + R", hl.dsp.exec_cmd("qs -c caelestia kill; caelestia shell -d"), {
  desc = "Restart Shell",
  category = "shell",
  icon = "restart_alt",
  release = true,
  order = 95,
})

-- ── Workspace navigation ──────────────────────────────────────────────────────

-- Go to workspace 1–10
for i = 1, 9 do
  hl.cbind("SUPER + " .. i, function()
    v.ws_goto(i)
  end, {
    desc = "Go to Workspace " .. i,
    category = "workspace",
    icon = "grid_view",
    order = 10,
  })
  hl.cbind("CTRL + SUPER + " .. i, function()
    v.ws_goto_group(i)
  end, {
    desc = "Go to Workspace Group " .. i,
    category = "workspace",
    icon = "filter_1",
    order = 20,
  })
end
hl.cbind("SUPER + 0", function()
  v.ws_goto(10)
end, {
  desc = "Go to Workspace 10",
  category = "workspace",
  icon = "grid_view",
  order = 15,
})
hl.cbind("CTRL + SUPER + 0", function()
  v.ws_goto_group(10)
end, {
  desc = "Go to Workspace Group 10",
  category = "workspace",
  icon = "filter_1",
  order = 25,
})

-- Go to workspace ±1
hl.cbind("CTRL + SUPER + RIGHT", hl.dsp.focus({ workspace = "e-1" }), {
  desc = "Next Workspace",
  category = "workspace",
  icon = "chevron_right",
  repeating = true,
  order = 30,
})
hl.cbind("CTRL + SUPER + LEFT", hl.dsp.focus({ workspace = "e+1" }), {
  desc = "Prev Workspace",
  category = "workspace",
  icon = "chevron_left",
  repeating = true,
  order = 35,
})
hl.cbind("SUPER + Page_Up", hl.dsp.focus({ workspace = "e-1" }), {
  desc = "Next Workspace",
  category = "workspace",
  icon = "chevron_right",
  repeating = true,
  order = 36,
})
hl.cbind("SUPER + Page_Down", hl.dsp.focus({ workspace = "e+1" }), {
  desc = "Prev Workspace",
  category = "workspace",
  icon = "chevron_left",
  repeating = true,
  order = 37,
})

-- Toggle special workspace
hl.cbind("SUPER + S", hl.dsp.exec_cmd("caelestia toggle specialws"), {
  desc = "Toggle Special Workspace",
  category = "special_workspace",
  icon = "star",
  order = 10,
})

-- ── Move window to workspace ──────────────────────────────────────────────────

-- Move window to workspace 1–10
for i = 1, 9 do
  hl.cbind("SUPER + ALT + " .. i, function()
    v.ws_move(i)
  end, {
    desc = "Move to Workspace " .. i,
    category = "workspace",
    icon = "grid_view",
    order = 50,
  })
  hl.cbind("CTRL + SUPER + ALT + " .. i, function()
    v.ws_move_group(i)
  end, {
    desc = "Move to Workspace Group " .. i,
    category = "workspace",
    icon = "filter_1",
    order = 60,
  })
end
hl.cbind("SUPER + ALT + 0", function()
  v.ws_move(10)
end, {
  desc = "Move to Workspace 10",
  category = "workspace",
  icon = "grid_view",
  order = 55,
})
hl.cbind("CTRL + SUPER + ALT + 0", function()
  v.ws_move_group(10)
end, {
  desc = "Move to Workspace Group 10",
  category = "workspace",
  icon = "filter_1",
  order = 65,
})

-- Move window to workspace ±1
hl.cbind("SUPER + ALT + Page_Up", hl.dsp.window.move({ workspace = "e-1" }), {
  desc = "Move to Next Workspace",
  category = "workspace",
  icon = "chevron_right",
  repeating = true,
  order = 70,
})
hl.cbind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "e+1" }), {
  desc = "Move to Prev Workspace",
  category = "workspace",
  icon = "chevron_left",
  repeating = true,
  order = 75,
})
hl.cbind("SUPER + ALT + RIGHT", hl.dsp.window.move({ workspace = "e+1" }), {
  desc = "Move to Next Workspace",
  category = "workspace",
  icon = "chevron_right",
  repeating = true,
  order = 76,
})
hl.cbind("SUPER + ALT + LEFT", hl.dsp.window.move({ workspace = "e-1" }), {
  desc = "Move to Prev Workspace",
  category = "workspace",
  icon = "chevron_left",
  repeating = true,
  order = 77,
})

-- Move window to/from special workspace
hl.cbind("CTRL + SUPER + SHIFT + UP", hl.dsp.window.move({ workspace = "special:special" }), {
  desc = "Move to Special Workspace",
  category = "special_workspace",
  icon = "star",
  order = 20,
})
hl.cbind("CTRL + SUPER + SHIFT + DOWN", hl.dsp.window.move({ workspace = "e+0" }), {
  desc = "Move from Special Workspace",
  category = "special_workspace",
  icon = "star",
  order = 30,
})
hl.cbind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special" }), {
  desc = "Move to Special Workspace",
  category = "special_workspace",
  icon = "star",
  order = 35,
})

-- ── Window groups ─────────────────────────────────────────────────────────────

hl.cbind("ALT + TAB", hl.dsp.window.cycle_next(), {
  desc = "Cycle Windows",
  category = "window_group",
  icon = "swap_horiz",
  repeating = true,
  order = 10,
})
hl.cbind("SHIFT + ALT + TAB", hl.dsp.window.cycle_next({ prev = true }), {
  desc = "Cycle Windows (Prev)",
  category = "window_group",
  icon = "swap_horiz",
  repeating = true,
  order = 20,
})
hl.cbind("CTRL + ALT + TAB", hl.dsp.group.next(), {
  desc = "Next Group",
  category = "window_group",
  icon = "view_carousel",
  repeating = true,
  order = 30,
})
hl.cbind("CTRL + SHIFT + ALT + TAB", hl.dsp.group.prev(), {
  desc = "Prev Group",
  category = "window_group",
  icon = "view_carousel",
  repeating = true,
  order = 40,
})
hl.cbind("SUPER + COMMA", hl.dsp.group.toggle(), {
  desc = "Toggle Group",
  category = "window_group",
  icon = "group_work",
  order = 50,
})
hl.cbind("SUPER + U", hl.dsp.window.move({ out_of_group = true }), {
  desc = "Ungroup Window",
  category = "window_group",
  icon = "ungroup",
  order = 60,
})
hl.cbind("SUPER + SHIFT + COMMA", hl.dsp.group.lock_active(), {
  desc = "Lock Group",
  category = "window_group",
  icon = "lock",
  order = 70,
})

-- Move active workspace to next/previous monitor
hl.cbind("SUPER + ALT + COMMA", hl.dsp.workspace.move({ monitor = "-1" }), {
  desc = "Move Workspace Left",
  category = "window_group",
  icon = "swap_horiz",
  order = 80,
})
hl.cbind("SUPER + ALT + PERIOD", hl.dsp.workspace.move({ monitor = "+1" }), {
  desc = "Move Workspace Right",
  category = "window_group",
  icon = "swap_horiz",
  order = 90,
})

-- ── Window focus & movement ───────────────────────────────────────────────────

hl.cbind("SUPER + LEFT", hl.dsp.focus({ direction = "left" }), {
  desc = "Focus Left",
  category = "window",
  icon = "arrow_back",
  order = 10,
})
hl.cbind("SUPER + RIGHT", hl.dsp.focus({ direction = "right" }), {
  desc = "Focus Right",
  category = "window",
  icon = "arrow_forward",
  order = 20,
})
hl.cbind("SUPER + UP", hl.dsp.focus({ direction = "up" }), {
  desc = "Focus Up",
  category = "window",
  icon = "arrow_upward",
  order = 30,
})
hl.cbind("SUPER + DOWN", hl.dsp.focus({ direction = "down" }), {
  desc = "Focus Down",
  category = "window",
  icon = "arrow_downward",
  order = 40,
})
hl.cbind("SUPER + SHIFT + LEFT", hl.dsp.window.move({ direction = "left" }), {
  desc = "Move Window Left",
  category = "window",
  icon = "arrow_back",
  order = 50,
})
hl.cbind("SUPER + SHIFT + RIGHT", hl.dsp.window.move({ direction = "right" }), {
  desc = "Move Window Right",
  category = "window",
  icon = "arrow_forward",
  order = 60,
})
hl.cbind("SUPER + SHIFT + UP", hl.dsp.window.move({ direction = "up" }), {
  desc = "Move Window Up",
  category = "window",
  icon = "arrow_upward",
  order = 70,
})
hl.cbind("SUPER + SHIFT + DOWN", hl.dsp.window.move({ direction = "down" }), {
  desc = "Move Window Down",
  category = "window",
  icon = "arrow_downward",
  order = 80,
})

hl.cbind("SUPER + Minus", hl.dsp.layout("mfact -0.1"), {
  desc = "Shrink Master",
  category = "window",
  icon = "remove",
  repeating = true,
  order = 90,
})
hl.cbind("SUPER + Equal", hl.dsp.layout("mfact 0.1"), {
  desc = "Grow Master",
  category = "window",
  icon = "add",
  repeating = true,
  order = 100,
})

hl.cbind("SUPER + J", hl.dsp.layout("swapwithmaster master"), {
  desc = "Swap with Master",
  category = "window",
  icon = "swap_vert",
  order = 110,
})
hl.cbind("SUPER + X", hl.dsp.window.resize(), {
  desc = "Resize Window",
  category = "window",
  icon = "aspect_ratio",
  order = 120,
})
hl.cbind("SUPER + ALT + BACKSLASH", hl.dsp.exec_cmd("caelestia resizer pip"), {
  desc = "PiP Mode",
  category = "window",
  icon = "picture_in_picture_alt",
  order = 130,
})

hl.cbind("SUPER + P", hl.dsp.window.pin(), {
  desc = "Pin Window",
  category = "window",
  icon = "push_pin",
  order = 140,
})
hl.cbind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), {
  desc = "Fullscreen",
  category = "window",
  icon = "fullscreen",
  order = 150,
})
hl.cbind("SUPER + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), {
  desc = "Maximize",
  category = "window",
  icon = "fullscreen",
  order = 160,
})
hl.cbind("SUPER + ALT + SPACE", hl.dsp.window.float({ action = "toggle" }), {
  desc = "Toggle Float",
  category = "window",
  icon = "aspect_ratio",
  order = 170,
})
hl.cbind("SUPER + Q", hl.dsp.window.close(), {
  desc = "Close Window",
  category = "window",
  icon = "close",
  order = 180,
})

-- ── Special workspace toggles ─────────────────────────────────────────────────

hl.cbind("CTRL + SHIFT + ESCAPE", hl.dsp.exec_cmd("caelestia toggle sysmon"), {
  desc = "Toggle System Monitor",
  category = "special_workspace",
  icon = "monitor_heart",
  order = 40,
})
hl.cbind("SUPER + M", hl.dsp.exec_cmd("caelestia toggle music"), {
  desc = "Toggle Music",
  category = "special_workspace",
  icon = "music_cast",
  order = 50,
})
hl.cbind("SUPER + D", hl.dsp.workspace.toggle_special("communication"), {
  desc = "Toggle Communication",
  category = "special_workspace",
  icon = "forum",
  order = 60,
})
hl.cbind("SUPER + H", hl.dsp.workspace.toggle_special("huddle"), {
  desc = "Toggle Huddle",
  category = "special_workspace",
  icon = "groups",
  order = 70,
})
hl.cbind("SUPER + R", v.toggle_notes, {
  desc = "Toggle Notes",
  category = "special_workspace",
  icon = "edit_note",
  order = 80,
})

-- ── App launchers ─────────────────────────────────────────────────────────────

hl.cbind("SUPER + T", hl.dsp.exec_cmd("app2unit -t scope -- " .. v.terminal), {
  desc = "Open Terminal",
  category = "app_launcher",
  icon = "terminal",
  order = 10,
})
hl.cbind("SUPER + W", hl.dsp.exec_cmd("app2unit -t scope -- " .. v.browser), {
  desc = "Open Browser",
  category = "app_launcher",
  icon = "web",
  order = 20,
})
hl.cbind("SUPER + C", v.toggle_qalculate, {
  desc = "Calculator",
  category = "app_launcher",
  icon = "calculate",
  order = 30,
})
hl.cbind("SUPER + E", v.toggle_dolphin, {
  desc = "File Manager",
  category = "app_launcher",
  icon = "folder",
  order = 40,
})
hl.cbind("SUPER + ALT + E", hl.dsp.exec_cmd("app2unit -t scope -- nemo"), {
  desc = "File Manager (Nemo)",
  category = "app_launcher",
  icon = "folder",
  order = 50,
})
hl.cbind("CTRL + ALT + ESCAPE", hl.dsp.exec_cmd("app2unit -t scope -- qps"), {
  desc = "Process Manager",
  category = "app_launcher",
  icon = "monitor_heart",
  order = 60,
})
hl.cbind("CTRL + ALT + V", hl.dsp.exec_cmd("app2unit -t scope -- pavucontrol"), {
  desc = "Audio Settings",
  category = "app_launcher",
  icon = "settings",
  order = 70,
})

-- ── Screenshots & Recording ───────────────────────────────────────────────────

hl.cbind("Print", hl.dsp.exec_cmd("caelestia screenshot"), {
  desc = "Screenshot (Full)",
  category = "screenshot_recording",
  icon = "screenshot_monitor",
  locked = true,
  order = 10,
})
hl.cbind("SUPER + SHIFT + S", hl.dsp.global("caelestia:screenshotFreeze"), {
  desc = "Screenshot (Freeze)",
  category = "screenshot_recording",
  icon = "screenshot_monitor",
  order = 20,
})
hl.cbind("SUPER + SHIFT + ALT + S", hl.dsp.global("caelestia:screenshot"), {
  desc = "Screenshot (Region)",
  category = "screenshot_recording",
  icon = "screenshot_monitor",
  order = 30,
})
hl.cbind("SUPER + ALT + R", hl.dsp.exec_cmd("caelestia record -s"), {
  desc = "Record with Sound",
  category = "screenshot_recording",
  icon = "screen_record",
  order = 40,
})
hl.cbind("CTRL + ALT + R", hl.dsp.exec_cmd("caelestia record"), {
  desc = "Record Screen",
  category = "screenshot_recording",
  icon = "screen_record",
  order = 50,
})
hl.cbind("SUPER + SHIFT + ALT + R", hl.dsp.exec_cmd("caelestia record -r"), {
  desc = "Record Region",
  category = "screenshot_recording",
  icon = "screen_record",
  order = 60,
})

-- ── Volume ────────────────────────────────────────────────────────────────────

hl.cbind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), {
  desc = "Toggle Mic Mute",
  category = "media",
  icon = "mic",
  locked = true,
  order = 70,
})
hl.cbind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
  desc = "Toggle Mute",
  category = "media",
  icon = "volume_off",
  locked = true,
  order = 80,
})
hl.cbind("SUPER + SHIFT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), {
  desc = "Toggle Mute",
  category = "media",
  icon = "volume_off",
  locked = true,
  order = 81,
})
hl.cbind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+"),
  {
    desc = "Volume Up",
    category = "media",
    icon = "volume_up",
    locked = true,
    repeating = true,
    order = 90,
  }
)
hl.cbind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"),
  {
    desc = "Volume Down",
    category = "media",
    icon = "volume_down",
    locked = true,
    repeating = true,
    order = 100,
  }
)

-- ── Utility ───────────────────────────────────────────────────────────────────

hl.cbind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"), {
  desc = "Colour Picker",
  category = "utility",
  icon = "palette",
  order = 10,
})
hl.cbind("XF86TouchpadToggle", v.toggle_touchpad, {
  desc = "Toggle Touchpad",
  category = "utility",
  icon = "laptop_mac",
  locked = true,
  order = 20,
})
-- For some fucking reason the touchpad toggle on Asus Zenbook S16 is actually a screen mirroring toggle. fn + f7 calls super + p
hl.cbind("SUPER + P", v.toggle_touchpad, {
  desc = "Toggle Touchpad",
  category = "utility",
  icon = "laptop_mac",
  order = 25,
})
hl.cbind("XF86Launch1", hl.dsp.global("caelestia:showall"), {
  desc = "Show All Drawers",
  category = "shell",
  icon = "select_all",
  locked = true,
  repeating = true,
  order = 70,
})

-- ── Sleep ─────────────────────────────────────────────────────────────────────

hl.cbind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"), {
  desc = "Suspend",
  category = "utility",
  icon = "bedtime",
  order = 30,
})

-- ── Clipboard / emoji ─────────────────────────────────────────────────────────

hl.cbind("SUPER + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"), {
  desc = "Clipboard History",
  category = "utility",
  icon = "content_paste",
  order = 40,
})
hl.cbind("SUPER + ALT + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"), {
  desc = "Clipboard (Delete)",
  category = "utility",
  icon = "delete",
  order = 50,
})
hl.cbind("SUPER + PERIOD", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"), {
  desc = "Emoji Picker",
  category = "utility",
  icon = "emoji_symbols",
  order = 60,
})
hl.cbind(
  "CTRL + SHIFT + ALT + V",
  hl.dsp.exec_cmd([[sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"]]),
  {
    desc = "Paste (Alternate)",
    category = "utility",
    icon = "content_paste",
    locked = true,
    order = 70,
  }
)
