hl.config({
  input = {
    kb_layout = "us,ru",
    kb_options = "grp:caps_toggle",
    repeat_delay = 250,
    repeat_rate = 50,

    focus_on_close = 1,

    accel_profile = "flat",
    sensitivity = 0.4,

    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.3,
      tap_to_click = false,
    },
  },

  binds = {
    scroll_event_delay = 0,
  },

  cursor = {
    hotspot_padding = 1,
  },
})
