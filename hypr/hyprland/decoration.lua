local c = require("hyprland.scheme")

hl.config({
  decoration = {
    rounding = 10,

    blur = {
      passes = 2,
      popups = true,
      input_methods = true,
    },

    shadow = {
      range = 20,
      color = c.rgba(c.surface, "d4"),
    },
  },
})
