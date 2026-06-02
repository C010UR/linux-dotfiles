local v = require("hyprland.vars")

hl.config({
  input = {
    kb_layout = "us,ru",
    kb_options = "grp:caps_toggle",
    repeat_delay = 250,
    repeat_rate = 50,

    focus_on_close = 1,

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

hl.device({
  name = v.touchpadDevice,
  accel_profile = "adaptive",
  sensitivity = 0.2,
})

for _, name in ipairs(v.mouseDevices) do
  hl.device({
    name = name,
    accel_profile = "adaptive",
    sensitivity = -0.6,
  })
end
