local c = require("hyprland.scheme")

hl.config({
  general = {
    layout = "master",
    gaps_workspaces = 3,
    gaps_in = 2,
    gaps_out = { top = 5, right = 5, bottom = 5, left = 7 },
    border_size = 2,
    allow_tearing = true,

    snap = {
      enabled = true,
      window_gap = 10,
      monitor_gap = 10,
      respect_gaps = true,
    },

    ["col.active_border"] = c.rgba(c.primary, "e6"),
    ["col.inactive_border"] = c.rgba(c.onSurfaceVariant, "11"),
  },

  master = {
    mfact = 0.5,
  },

  xwayland = {
    force_zero_scaling = true,
  },
})
