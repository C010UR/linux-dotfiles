-- Window-management actions.
--
-- The binds in hyprland/keybinds.lua are untouched: every chord here is
-- currently unused, and each is registered through hl.cbind so it appears in
-- the F1 cheatsheet.

local floating = require("hyprland.window.floating-workspace")
local tools = require("hyprland.window.window-tools")
local dolphin = require("hyprland.window.dolphin")

local scripts = os.getenv("HOME") .. "/.config/hypr/scripts/"

hl.cbind("SUPER + E", dolphin.toggle, {
  desc = "Toggle Dolphin Scratchpad",
  category = "app_launcher",
  icon = "folder",
  order = 15,
})

hl.cbind("SUPER + G", function()
  floating.toggle()
end, {
  desc = "Cycle workspace: master / floating",
  category = "window",
  icon = "picture_in_picture_alt",
  order = 200,
})

hl.cbind("SUPER + O", hl.dsp.exec_cmd(scripts .. "pop-window.sh"), {
  desc = "Pop window out (float, pin, centre)",
  category = "window",
  icon = "open_in_new",
  order = 210,
})

hl.cbind("SUPER + ALT + Home", hl.dsp.exec_cmd(scripts .. "window-width.sh save"), {
  desc = "Save window width",
  category = "window",
  icon = "width",
  order = 220,
})

hl.cbind("SUPER + Home", hl.dsp.exec_cmd(scripts .. "window-width.sh restore"), {
  desc = "Restore window width",
  category = "window",
  icon = "width",
  order = 230,
})

hl.cbind("SUPER + Backspace", function()
  tools.toggle_transparency()
end, {
  desc = "Toggle window transparency",
  category = "window",
  icon = "opacity",
  order = 240,
})

hl.cbind("SUPER + SHIFT + Backspace", function()
  tools.toggle_gaps()
end, {
  desc = "Toggle window gaps",
  category = "window",
  icon = "grid_off",
  order = 250,
})

hl.cbind("SUPER + CTRL + Backspace", function()
  tools.toggle_aspect()
end, {
  desc = "Toggle square single-window aspect",
  category = "window",
  icon = "crop_square",
  order = 260,
})
