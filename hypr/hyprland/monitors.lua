-- Laptop panel: 120Hz on AC, 60Hz on battery; disabled while an external is connected.
hl.pmonitor({
  output = "eDP-1",
  mode = "2880x1800",
  scale = 1.25,
  layout_order = 1,
  auto_disable = true,
  refresh = {
    performance = 120,
    balanced = function(ctx)
      return ctx.on_ac and 120 or 60
    end,
    ["power-saver"] = 60,
  },
})

-- LG UltraFine (when used)
hl.pmonitor({
  output = "desc:LG Electronics LG ULTRAFINE 508NTABKV160",
  mode = "3840x2160",
  scale = 1.25,
  layout_order = 2,
  refresh = {
    performance = 60,
    balanced = 60,
    ["power-saver"] = 60,
  },
})
