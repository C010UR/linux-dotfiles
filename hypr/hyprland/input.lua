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
      tap_to_click = true,
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
  sensitivity = 0,
})

for _, name in ipairs(v.mouseDevices) do
  hl.device({
    name = name,
    accel_profile = "flat",
    sensitivity = -0.4,
  })
end

hl.device({
  name = v.ydotoolDevice,
  accel_profile = "flat",
})
