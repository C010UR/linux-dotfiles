local v = require("hyprland.vars")

-- ── Shell keybinds (Noctalia) ─────────────────────────────────────────────────

hl.cbind("SUPER + SPACE", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), {
  desc = "Toggle Launcher",
  category = "shell",
  icon = "apps",
  order = 10,
})

hl.cbind("SUPER + L", hl.dsp.exec_cmd("noctalia msg session lock"), {
  desc = "Lock Screen",
  category = "shell",
  icon = "lock",
  order = 40,
})

hl.cbind("SUPER + V", hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"), {
  desc = "Clipboard History",
  category = "shell",
  icon = "clipboard",
  order = 20,
})

hl.cbind("SUPER + C", hl.dsp.exec_cmd("noctalia msg panel-toggle yuuto/calculator:panel"), {
  desc = "Calculator",
  category = "shell",
  icon = "calculator",
  order = 30,
})

hl.cbind("SUPER + SHIFT + P", hl.dsp.exec_cmd("noctalia msg power-cycle"), {
  desc = "Cycle Power Profile",
  category = "system",
  icon = "battery_charging",
  order = 10,
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
hl.cbind("XF86AudioPlay", hl.dsp.exec_cmd("noctalia msg media toggle"), {
  desc = "Play / Pause",
  category = "media",
  icon = "play_pause",
  locked = true,
  order = 31,
})
hl.cbind("XF86AudioPause", hl.dsp.exec_cmd("noctalia msg media toggle"), {
  desc = "Play / Pause",
  category = "media",
  icon = "play_pause",
  locked = true,
  order = 32,
})
hl.cbind("XF86AudioNext", hl.dsp.exec_cmd("noctalia msg media next"), {
  desc = "Next Track",
  category = "media",
  icon = "skip_next",
  locked = true,
  order = 41,
})
hl.cbind("XF86AudioPrev", hl.dsp.exec_cmd("noctalia msg media previous"), {
  desc = "Previous Track",
  category = "media",
  icon = "skip_previous",
  locked = true,
  order = 51,
})
hl.cbind("XF86AudioStop", hl.dsp.exec_cmd("noctalia msg media stop"), {
  desc = "Stop",
  category = "media",
  icon = "stop",
  locked = true,
  order = 60,
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

-- Toggle control center
hl.cbind("SUPER + S", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"), {
  desc = "Toggle Control Center",
  category = "shell",
  icon = "dashboard",
  order = 20,
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

-- ── Window groups ─────────────────────────────────────────────────────────────

hl.cbind("ALT + TAB", hl.dsp.exec_cmd("noctalia msg window-switcher hold"), {
  desc = "Window Switcher",
  category = "window_group",
  icon = "swap_horiz",
  order = 10,
})
hl.cbind("SHIFT + ALT + TAB", hl.dsp.exec_cmd("noctalia msg window-switcher hold reverse"), {
  desc = "Window Switcher (Reverse)",
  category = "window_group",
  icon = "swap_horiz",
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
hl.cbind("SUPER + SHIFT + COMMA", hl.dsp.group.lock(), {
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
hl.cbind("SUPER + mouse:272", hl.dsp.window.drag(), {
  desc = "Drag Window",
  category = "window",
  icon = "open_with",
  mouse = true,
  order = 115,
})
hl.cbind("SUPER + mouse:273", hl.dsp.window.resize(), {
  desc = "Resize Window",
  category = "window",
  icon = "aspect_ratio",
  mouse = true,
  order = 120,
})
hl.cbind("SUPER + ALT + P", hl.dsp.window.pin(), {
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

-- ── Special workspace ─────────────────────────────────────────────────────────

hl.cbind("SUPER + D", hl.dsp.workspace.toggle_special("communication"), {
  desc = "Toggle Communication",
  category = "special_workspace",
  icon = "forum",
  order = 60,
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

-- ── Screenshots ───────────────────────────────────────────────────────────────

hl.cbind("Print", hl.dsp.exec_cmd("noctalia msg screenshot-fullscreen"), {
  desc = "Screenshot (Full)",
  category = "screenshot_recording",
  icon = "screenshot_monitor",
  locked = true,
  order = 10,
})

hl.cbind("SUPER + SHIFT + S", hl.dsp.exec_cmd("noctalia msg screenshot-region"), {
  desc = "Screenshot (Region)",
  category = "screenshot_recording",
  icon = "screenshot_region",
  locked = true,
  order = 20,
})

-- ── Volume ────────────────────────────────────────────────────────────────────

hl.cbind("XF86AudioMicMute", hl.dsp.exec_cmd("noctalia msg mic-mute"), {
  desc = "Toggle Mic Mute",
  category = "media",
  icon = "mic",
  locked = true,
  order = 70,
})
hl.cbind("XF86AudioMute", hl.dsp.exec_cmd("noctalia msg volume-mute"), {
  desc = "Toggle Mute",
  category = "media",
  icon = "volume_off",
  locked = true,
  order = 80,
})
hl.cbind("SUPER + SHIFT + M", hl.dsp.exec_cmd("noctalia msg volume-mute"), {
  desc = "Toggle Mute",
  category = "media",
  icon = "volume_off",
  locked = true,
  order = 81,
})
hl.cbind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up"), {
  desc = "Volume Up",
  category = "media",
  icon = "volume_up",
  locked = true,
  repeating = true,
  order = 90,
})
hl.cbind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down"), {
  desc = "Volume Down",
  category = "media",
  icon = "volume_down",
  locked = true,
  repeating = true,
  order = 100,
})

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

-- ── Sleep ─────────────────────────────────────────────────────────────────────

hl.cbind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"), {
  desc = "Suspend",
  category = "utility",
  icon = "bedtime",
  order = 30,
})

-- ── Clipboard ─────────────────────────────────────────────────────────────────

hl.cbind(
  "CTRL + SHIFT + ALT + P",
  hl.dsp.exec_cmd([[sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"]]),
  {
    desc = "Paste (Alternate)",
    category = "utility",
    icon = "content_paste",
    locked = true,
    order = 70,
  }
)
