local v = require("hyprland.vars")

hl.on("hyprland.start", function()
  -- Keyring and auth
  hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

  -- Desktop shell
  hl.exec_cmd("noctalia --daemon")

  -- Automount storage devices
  hl.exec_cmd("udiskie")

  -- Clipboard history
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- Auto delete trash 30 days old
  hl.exec_cmd("trash-empty 30")

  -- Apply cursor theme
  hl.exec_cmd("hyprctl setcursor " .. v.cursorTheme .. " " .. tostring(v.cursorSize))
  hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme '" .. v.cursorTheme .. "'")
  hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. tostring(v.cursorSize))

  -- Location provider and night light
  -- hl.exec_cmd("/usr/lib/geoclue-2.0/demos/agent")
  -- hl.exec_cmd("sleep 1 && gammastep")

  -- Forward bluetooth media commands to MPRIS
  hl.exec_cmd("mpris-proxy")

  v.apply_persisted_state()
  hl.exec_cmd(v.get_config_path() .. "/scripts/watch-resume.sh")
end)

hl.on("config.reloaded", function()
  v.apply_persisted_state()
end)
