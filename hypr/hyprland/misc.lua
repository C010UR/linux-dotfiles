local c = require("scheme/default")

hl.config({
  misc = {
    vrr = 1,

    disable_hyprland_logo   = true,
    force_default_wallpaper = 0,

    allow_session_lock_restore = true,
    middle_click_paste         = false,
    focus_on_activate          = true,
    session_lock_xray          = true,

    mouse_move_enables_dpms = true,
    key_press_enables_dpms  = true,

    background_color = c.rgb(c.surfaceContainer),
  },

  debug = {
    error_position = 1,
  },
})
