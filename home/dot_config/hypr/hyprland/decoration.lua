local c = require("hyprland.scheme")

hl.config({
  decoration = {
    rounding = 10,

    blur = {
      enabled = false,
      size = 6,
      passes = 2,
      new_optimizations = true,
      xray = true,
      popups = true,
      input_methods = true,
      variant = "acrylic",
      acrylic = {
        refraction = 16,
        bulb = 32,
        clarity = 0.85,
        aberration = 0.02,
        tint = c.rgba(c.primary, "14"),
      },
    },

    shadow = {
      range = 20,
      color = c.rgba(c.surface, "d4"),
    },
  },
})
