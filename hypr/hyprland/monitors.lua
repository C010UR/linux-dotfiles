hl.pmonitor({
  output = "eDP-1",
  mode = "2880x1800",
  position = "0x0",
  scale = 1.25,
  refresh = {
    performance = 120,
    balanced = 60,
    ["power-saver"] = 60,
  },
})
hl.monitor({
  output = "desc:LG Electronics LG ULTRAFINE 508NTABKV160",
  mode = "2560x1440@60",
  position = "-768x-2160",
  scale = 1,
})
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })
