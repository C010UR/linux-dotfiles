local c = require("scheme/default")

hl.config({
  group = {
    ["col.border_active"]          = c.rgba(c.primary, "e6"),
    ["col.border_inactive"]        = c.rgba(c.onSurfaceVariant, "11"),
    ["col.border_locked_active"]   = c.rgba(c.primary, "e6"),
    ["col.border_locked_inactive"] = c.rgba(c.onSurfaceVariant, "11"),

    groupbar = {
      font_family              = "JetBrains Mono NF",
      font_size                = 15,
      gradients                = true,
      gradient_round_only_edges = false,
      gradient_rounding        = 5,
      height                   = 25,
      indicator_height         = 0,
      gaps_in                  = 3,
      gaps_out                 = 3,

      text_color             = c.rgb(c.onPrimary),
      ["col.active"]         = c.rgba(c.primary, "d4"),
      ["col.inactive"]       = c.rgba(c.outline, "d4"),
      ["col.locked_active"]  = c.rgba(c.primary, "d4"),
      ["col.locked_inactive"] = c.rgba(c.secondary, "d4"),
    },
  },
})
