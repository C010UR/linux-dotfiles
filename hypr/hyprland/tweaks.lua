-- Small Hyprland behaviour tweaks.
-- No look-and-feel changes: layout, gaps and borders stay as configured.

hl.config({
  general = {
    resize_on_border = true,
    extend_border_grab_area = 8,
    hover_icon_on_border = true,
  },

  misc = {
    -- Fewer "application not responding" popups from slow clients.
    anr_missed_pings = 3,
    -- A click on a window under a fullscreen one focuses it instead of doing
    -- nothing.
    on_focus_under_fullscreen = 1,
  },

  cursor = {
    hide_on_key_press = true,
  },
})

-- Slow-app-launch fix: let systemd and D-Bus activation see the session
-- environment before anything is launched from a keybind.
hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
end)
