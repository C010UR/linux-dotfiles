-- ── Monitors ──────────────────────────────────────────────────────────────────

hl.monitor({ output = "eDP-1", mode = "2880x1800@120", position = "0x0", scale = 1.333334 })
-- hl.monitor({ output = "eDP-1", mode = "2880x1800@120", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })

-- ── Sub-configs  ──────────────────────────────────────────────────────────────

require("hyprland/env")
require("hyprland/general")
require("hyprland/input")
require("hyprland/misc")
require("hyprland/animations")
require("hyprland/decoration")
require("hyprland/group")
require("hyprland/execs")
require("hyprland/rules")
require("hyprland/gestures")
require("hyprland/keybinds")
