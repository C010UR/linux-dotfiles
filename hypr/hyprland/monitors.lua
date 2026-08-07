-- Laptop panel: profile-aware refresh; disabled while any external is connected.
hl.pmonitor({
  output = "eDP-1",
  mode = "2880x1800",
  position = "0x0",
  scale = 1.25,
  auto_disable = true,
  refresh = {
    performance = 120,
    balanced = 60,
    ["power-saver"] = 60,
  },
})

-- MSI MAG 274QF X24 (2K / 240Hz — needs DP/USB-C for 240; HDMI tops out at 144)
hl.monitor({
  output = "desc:Microstep MAG 274QF X24",
  mode = "2560x1440@144",
  position = "0x0",
  scale = 1,
})

-- LG UltraFine (when used)
hl.monitor({
  output = "desc:LG Electronics LG ULTRAFINE 508NTABKV160",
  mode = "2560x1440@60",
  position = "0x0",
  scale = 1,
})
