local c = require("scheme/default")

hl.config({
  general = {
    layout        = "dwindle",
    allow_tearing = false,  -- Allows `immediate` window rule to work

    gaps_workspaces = 3,
    gaps_in         = 2,
    gaps_out        = { top = 5, right = 5, bottom = 5, left = 7},
    border_size     = 2,

    ["col.active_border"]   = c.rgba(c.primary, "e6"),
    ["col.inactive_border"] = c.rgba(c.onSurfaceVariant, "11"),
  },

  dwindle = {
    preserve_split = true,
  },

  xwayland = {
    force_zero_scaling = true,
  },
})
