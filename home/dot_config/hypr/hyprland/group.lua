local c = require("hyprland.scheme")

hl.config({
  group = {
    ["col.border_active"] = c.rgba(c.primary, "e6"),
    ["col.border_inactive"] = c.rgba(c.onSurfaceVariant, "11"),
    ["col.border_locked_active"] = c.rgba(c.primary, "e6"),
    ["col.border_locked_inactive"] = c.rgba(c.onSurfaceVariant, "11"),

    groupbar = {
      font_family = "JetBrains Mono NF",
      font_size = 15,
      gradient_rounding = 5,
      height = 25,
      indicator_height = 0,
      gaps_in = 3,
      gaps_out = 3,

      text_color = c.rgb(c.onPrimary),
      text_color_inactive = c.rgb(c.onSurfaceVariant),
      text_color_locked_active = c.rgb(c.onPrimary),
      text_color_locked_inactive = c.rgb(c.onSurfaceVariant),
      text_padding = 4,
      keep_upper_gap = true,
      rounding = 5,

      ["col.active"] = c.rgba(c.primary, "d4"),
      ["col.inactive"] = c.rgba(c.outline, "d4"),
      ["col.locked_active"] = c.rgba(c.primary, "d4"),
      ["col.locked_inactive"] = c.rgba(c.secondary, "d4"),
    },
  },
})
