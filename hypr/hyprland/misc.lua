local c = require("hyprland.scheme")

hl.config({
  misc = {
    -- VRR only while a fullscreen window is up.  Always-on VRR (1) holds
    -- a vblank reference and blocks PSR1 on the internal panel, and the
    -- external LG is not VRR-capable, so it only produced
    -- "No Adaptive sync support" errors.
    vrr = 2,

    disable_hyprland_logo = true,
    force_default_wallpaper = 0,

    allow_session_lock_restore = true,
    middle_click_paste = false,
    initial_workspace_tracking = 1,
    initial_workspace_token_timeout = 90,
    focus_on_activate = false,
    session_lock_xray = true,

    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,

    background_color = c.rgb(c.surfaceContainer),
  },

  debug = {
    error_position = 1,
  },

  render = {
    -- Keep the output in SDR sRGB.  cm_auto_hdr makes Hyprland switch the
    -- monitor to HDR when a window goes fullscreen, and the panel flashes
    -- while it re-syncs.  send_content_type can also make the monitor
    -- change picture mode on fullscreen.
    cm_auto_hdr = 0,
    send_content_type = false,
  },
})
