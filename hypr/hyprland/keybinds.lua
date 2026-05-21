local v = require("hyprland.vars")

-- ── Shell / Caelestia keybinds ────────────────────────────────────────────────

-- Launcher
hl.bind("SUPER + Super_L", hl.dsp.global("caelestia:launcher"))

-- Misc shell actions
hl.bind("CTRL + ALT + Delete", hl.dsp.global("caelestia:session"))
hl.bind("CTRL + ALT + C", hl.dsp.global("caelestia:clearNotifs"), { locked = true })
hl.bind("SUPER + K", hl.dsp.global("caelestia:dashboard"))
hl.bind("SUPER + L", hl.dsp.global("caelestia:lock"))

-- Restore lock: restart shell then lock
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("caelestia shell -d"), { locked = true })
hl.bind("SUPER + ALT + L", hl.dsp.global("caelestia:lock"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { locked = true })

-- Media controls
hl.bind("CTRL + SUPER + Space", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("CTRL + SUPER + Equal", hl.dsp.global("caelestia:mediaNext"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.global("caelestia:mediaNext"), { locked = true })
hl.bind("CTRL + SUPER + Minus", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.global("caelestia:mediaStop"), { locked = true })

-- Kill / restart shell
hl.bind("CTRL + SUPER + SHIFT + R", hl.dsp.exec_cmd("qs -c caelestia kill"), { release = true })
hl.bind("CTRL + SUPER + ALT + R", hl.dsp.exec_cmd("qs -c caelestia kill; caelestia shell -d"), { release = true })

-- ── Workspace navigation ──────────────────────────────────────────────────────

-- Go to workspace 1–10
for i = 1, 9 do
  hl.bind("SUPER + " .. i, function()
    v.ws_goto(i)
  end)
  hl.bind("CTRL + SUPER + " .. i, function()
    v.ws_goto_group(i)
  end)
end
hl.bind("SUPER + 0", function()
  v.ws_goto(10)
end)
hl.bind("CTRL + SUPER + 0", function()
  v.ws_goto_group(10)
end)

-- Go to workspace ±1
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("CTRL + SUPER + right", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })
hl.bind("CTRL + SUPER + left", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "e-1" }), { repeating = true })
hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "e+1" }), { repeating = true })

-- Go to workspace group ±10
hl.bind("CTRL + SUPER + mouse_down", hl.dsp.focus({ workspace = "e-10" }))
hl.bind("CTRL + SUPER + mouse_up", hl.dsp.focus({ workspace = "e+10" }))

-- Toggle special workspace
hl.bind("SUPER + S", hl.dsp.exec_cmd("caelestia toggle specialws"))

-- ── Move window to workspace ──────────────────────────────────────────────────

-- Move window to workspace 1–10
for i = 1, 9 do
  hl.bind("SUPER + ALT + " .. i, function()
    v.ws_move(i)
  end)
  hl.bind("CTRL + SUPER + ALT + " .. i, function()
    v.ws_move_group(i)
  end)
end
hl.bind("SUPER + ALT + 0", function()
  v.ws_move(10)
end)
hl.bind("CTRL + SUPER + ALT + 0", function()
  v.ws_move_group(10)
end)

-- Move window to workspace ±1
hl.bind("SUPER + ALT + Page_Up", hl.dsp.window.move({ workspace = "e-1" }), { repeating = true })
hl.bind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "e+1" }), { repeating = true })
hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.move({ workspace = "e-1" }))
hl.bind("SUPER + ALT + mouse_up", hl.dsp.window.move({ workspace = "e+1" }))
hl.bind("SUPER + ALT + right", hl.dsp.window.move({ workspace = "e+1" }), { repeating = true })
hl.bind("SUPER + ALT + left", hl.dsp.window.move({ workspace = "e-1" }), { repeating = true })

-- Move window to/from special workspace
hl.bind("CTRL + SUPER + SHIFT + up", hl.dsp.window.move({ workspace = "special:special" }))
hl.bind("CTRL + SUPER + SHIFT + down", hl.dsp.window.move({ workspace = "e+0" }))
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special" }))

-- ── Window groups ─────────────────────────────────────────────────────────────

hl.bind("ALT + Tab", hl.dsp.window.cycle_next(), { repeating = true })
hl.bind("SHIFT + ALT + Tab", hl.dsp.window.cycle_next({ prev = true }), { repeating = true })
hl.bind("CTRL + ALT + Tab", hl.dsp.group.next(), { repeating = true })
hl.bind("CTRL + SHIFT + ALT + Tab", hl.dsp.group.prev(), { repeating = true })
hl.bind("SUPER + Comma", hl.dsp.group.toggle())
hl.bind("SUPER + U", hl.dsp.window.move({ out_of_group = true }))
hl.bind("SUPER + SHIFT + Comma", hl.dsp.group.lock_active())

-- ── Window focus & movement ───────────────────────────────────────────────────

hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

hl.bind("SUPER + Minus", hl.dsp.layout("splitratio -0.1"), { repeating = true })
hl.bind("SUPER + Equal", hl.dsp.layout("splitratio 0.1"), { repeating = true })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + X", hl.dsp.window.resize(), { mouse = true })

hl.bind("SUPER + ALT + backslash", hl.dsp.exec_cmd("caelestia resizer pip"))

hl.bind("SUPER + P", hl.dsp.window.pin())
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" })) -- fullscreen with borders
hl.bind("SUPER + ALT + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + Q", hl.dsp.window.close())

-- ── Special workspace toggles ─────────────────────────────────────────────────

hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd("caelestia toggle sysmon"))
hl.bind("SUPER + M", hl.dsp.exec_cmd("caelestia toggle music"))
hl.bind("SUPER + D", hl.dsp.workspace.toggle_special("communication"))
hl.bind("SUPER + H", hl.dsp.workspace.toggle_special("huddle"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("caelestia toggle todo"))

-- ── App launchers ─────────────────────────────────────────────────────────────

hl.bind("SUPER + T", hl.dsp.exec_cmd("app2unit -- " .. v.terminal))
hl.bind("SUPER + W", hl.dsp.exec_cmd("app2unit -- " .. v.browser))
hl.bind("SUPER + C", hl.dsp.exec_cmd("app2unit -- " .. v.editor))
hl.bind("SUPER + E", v.toggle_dolphin)
hl.bind("SUPER + ALT + E", hl.dsp.exec_cmd("app2unit -- nemo"))
hl.bind("CTRL + ALT + Escape", hl.dsp.exec_cmd("app2unit -- qps"))
hl.bind("CTRL + ALT + V", hl.dsp.exec_cmd("app2unit -- pavucontrol"))

-- ── Utilities ─────────────────────────────────────────────────────────────────

hl.bind("Print", hl.dsp.exec_cmd("caelestia screenshot"), { locked = true }) -- full screen → clipboard
hl.bind("SUPER + SHIFT + S", hl.dsp.global("caelestia:screenshotFreeze")) -- region (freeze)
hl.bind("SUPER + SHIFT + ALT + S", hl.dsp.global("caelestia:screenshot")) -- region
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("caelestia record -s")) -- record with sound
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd("caelestia record")) -- record screen
hl.bind("SUPER + SHIFT + ALT + R", hl.dsp.exec_cmd("caelestia record -r")) -- record region
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a")) -- colour picker

-- ── Volume ────────────────────────────────────────────────────────────────────

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"),
  { locked = true, repeating = true }
)
hl.bind("XF86TouchpadToggle", v.toggle_touchpad, { locked = true })
hl.bind("SUPER + F7", v.toggle_touchpad) -- fallback touchpad toggle
hl.bind("XF86Launch1", hl.dsp.global("caelestia:showall"), { locked = true, repeating = true })

-- ── Sleep ─────────────────────────────────────────────────────────────────────

hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"))

-- ── Clipboard / emoji ─────────────────────────────────────────────────────────

hl.bind("SUPER + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"))
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"))
hl.bind("SUPER + Period", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))
hl.bind(
  "CTRL + SHIFT + ALT + V",
  hl.dsp.exec_cmd([[sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"]]),
  { locked = true }
) -- alternate paste
