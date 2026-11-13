-- ── Window rules ─────────────────────────────────────────────────────────────

-- Force opaque for apps that use native transparency
hl.window_rule({
  name = "force-opaque",
  opaque = true,
  match = { class = "equibop|org.quickshell|imv|swappy" },
})

-- Center all natively-floating non-xwayland windows (XDG transients, protocol-level popups).
-- Note: this only catches windows already floating at rule-eval time; windows made
-- floating by later rules below are centered by their individual center = true.
hl.window_rule({
  name = "center-floats",
  center = true,
  match = { float = true, xwayland = false },
})

-- Fix XWayland drags: unnamed popups love to snap to the cursor while dragging.
hl.window_rule({
  name = "fix-xwayland-drags",
  no_focus = true,
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
})

-- ── Floating apps ─────────────────────────────────────────────────────────────

hl.window_rule({ name = "guifetch", float = true, match = { class = "guifetch" } })
hl.window_rule({ name = "yad", float = true, match = { class = "yad" } })
hl.window_rule({ name = "zenity", float = true, match = { class = "zenity" } })
hl.window_rule({ name = "wev", float = true, match = { class = "wev" } })
-- GNOME archive manager ships two WM classes depending on how it's launched
hl.window_rule({ name = "file-roller", float = true, match = { class = "org.gnome.FileRoller|file-roller" } })
hl.window_rule({ name = "blueman", float = true, match = { class = "blueman-manager" } })
hl.window_rule({ name = "gradience", float = true, match = { class = "com.github.GradienceTeam.Gradience" } })
hl.window_rule({ name = "feh", float = true, match = { class = "feh" } })
hl.window_rule({ name = "imv", float = true, match = { class = "imv" } })
hl.window_rule({ name = "printer", float = true, match = { class = "system-config-printer" } })
hl.window_rule({ name = "quickshell", float = true, match = { class = "org.quickshell" } })

-- Noctalia settings window
hl.window_rule({
  name = "noctalia-settings",
  float = true,
  center = true,
  size = { 1080, 920 },
  match = { class = "dev.noctalia.Noctalia" },
})

-- ── Sized + centered floating apps ───────────────────────────────────────────

hl.window_rule({
  name = "flatseal",
  float = true,
  size = "(monitor_w*0.7) (monitor_h*0.8)",
  center = true,
  match = { class = "com.github.tchx84.Flatseal" },
})
-- Prism Launcher: default float/center at native size (progress, message boxes, pickers).
hl.window_rule({
  name = "prism-launcher-popups",
  float = true,
  center = true,
  match = { class = "org.prismlauncher.PrismLauncher" },
})
-- Settings, instance editor, and similar dialogs — smaller than the main launcher.
hl.window_rule({
  name = "prism-launcher-dialogs",
  float = true,
  size = "(monitor_w*0.55) (monitor_h*0.65)",
  center = true,
  match = {
    class = "org.prismlauncher.PrismLauncher",
    title = "^(Settings|New Instance|Copy Instance|Export Instance|Create Instance Shortcut|Choose Version|View Launcher Logs|Console window for |Edit Instance \\()",
  },
})
-- Main launcher window only (e.g. "Prism Launcher 11.0.2").
hl.window_rule({
  name = "prism-launcher-main",
  float = true,
  size = "(monitor_w*0.7) (monitor_h*0.8)",
  center = true,
  match = {
    class = "org.prismlauncher.PrismLauncher",
    title = "^Prism Launcher",
  },
})
hl.window_rule({
  name = "gnome-settings",
  float = true,
  size = "(monitor_w*0.7) (monitor_h*0.8)",
  center = true,
  match = { class = "org.gnome.Settings" },
})
hl.window_rule({
  name = "teleport-connect",
  float = true,
  size = "(monitor_w*0.7) (monitor_h*0.8)",
  center = true,
  match = { class = "Teleport Connect" },
})
hl.window_rule({
  name = "pavucontrol",
  float = true,
  size = "(monitor_w*0.6) (monitor_h*0.7)",
  center = true,
  match = { class = "org.pulseaudio.pavucontrol|yad-icon-browser" },
})
hl.window_rule({
  name = "nwg-look",
  float = true,
  size = "(monitor_w*0.5) (monitor_h*0.6)",
  center = true,
  match = { class = "nwg-look" },
})
hl.window_rule({
  name = "nmtui",
  float = true,
  size = "(monitor_w*0.6) (monitor_h*0.7)",
  center = true,
  match = { class = "com.mitchellh.ghostty", title = "nmtui" },
})
hl.window_rule({
  name = "atlauncher-console",
  float = true,
  match = { class = "com-atlauncher-App", title = "ATLauncher Console" },
})

-- ── Special workspaces ────────────────────────────────────────────────────────

hl.window_rule({
  name = "communication",
  workspace = "special:communication",
  match = { class = "discord|equibop|vesktop|whatsapp|org.telegram.desktop|(?i)slack" },
})

-- ── Dialogs ───────────────────────────────────────────────────────────────────

-- File pickers often request full monitor height; float + cap size.
hl.window_rule({
  name = "dialogs",
  float = true,
  center = true,
  size = "(monitor_w*0.45) (monitor_h*0.75)",
  suppress_event = "maximize fullscreen",
  match = {
    title = "(Select|Open)( a)? (File|Folder)(s)?"
      .. "|File (Operation|Upload)( Progress)?"
      .. "|.* Properties"
      .. "|^Library$"
      .. "|^Save As$"
      .. "|^Rename "
      .. "|^Export ",
  },
})

hl.window_rule({
  name = "xdg-file-portal",
  float = true,
  center = true,
  size = "(monitor_w*0.45) (monitor_h*0.75)",
  suppress_event = "maximize fullscreen",
  match = { class = "xdg-desktop-portal-gtk|xdg-desktop-portal-kde|org.freedesktop.impl.portal.desktop.kde" },
})

-- ── Wine ──────────────────────────────────────────────────────────────────────

hl.window_rule({ name = "wine-winecfg", float = true, match = { class = "winecfg.exe" } })
hl.window_rule({
  name = "wine-file-dialogs",
  float = true,
  center = true,
  suppress_event = "maximize fullscreen",
  match = { class = ".*\\.exe", title = "^(Open|Save As|Select a theme file|Choose File)$" },
})
hl.window_rule({
  name = "wine-mp3tag-popups",
  float = true,
  center = true,
  match = { class = "[Mm]p3tag\\.exe", title = "^(Mp3tag [^v]|M[^p]|Mp[^3]|Mp3[^t]|Mp3t[^a]|Mp3ta[^g]|[^M]).*" },
})
hl.window_rule({
  name = "wine-desktop",
  fullscreen = true,
  match = { title = "Wine Desktop" },
})

-- ── Picture-in-picture ────────────────────────────────────────────────────────

hl.window_rule({
  name = "picture-in-picture",
  float = true,
  pin = true,
  keep_aspect_ratio = true,
  move = "((monitor_w*1)-window_w-(monitor_w*0.02)) ((monitor_h*1)-window_h-(monitor_h*0.03))",
  match = { title = "Picture(-| )in(-| )[Pp]icture" },
})

-- ── Steam ─────────────────────────────────────────────────────────────────────

hl.window_rule({ name = "steam-friends", float = true, match = { class = "steam", title = "Friends List" } })
hl.window_rule({
  name = "steam-games",
  immediate = true,
  idle_inhibit = "always",
  match = { class = "steam_app_[0-9]+" },
})

-- ── Misc ──────────────────────────────────────────────────────────────────────

-- Mullvad VPN popup: pin near bottom-left
hl.window_rule({
  name = "mullvad-vpn",
  pin = true,
  move = "63 ((monitor_h*1)-window_h-(monitor_h*0.03))",
  match = { class = "Mullvad VPN", float = true },
})

-- XWayland unnamed popups (tooltips, context menus named win<N>)
hl.window_rule({
  name = "xwayland-popups",
  no_dim = true,
  no_shadow = true,
  rounding = 10,
  match = { xwayland = true, title = "win[0-9]+" },
})

-- Google meet is sharing your screen
hl.window_rule({
  name = "google-meet-screen-share",
  pin = true,
  move = "63 ((monitor_h*1)-window_h-(monitor_h*0.005))",
  match = { title = "meet.google.com is sharing your screen." },
})

-- Share picker
hl.window_rule({
  name = "hyprland-share-picker",
  float = true,
  center = true,
  match = { class = "hyprland-share-picker" },
})

-- JetBrains
hl.window_rule({
  name = "jetbrains",
  no_follow_mouse = true,
  match = { class = "^(jetbrains-.*)$" },
})

-- Telegram
hl.window_rule({
  name = "telegram",
  match = { class = "org.telegram.desktop" },
  focus_on_activate = false,
})

-- ── Layer rules ───────────────────────────────────────────────────────────────

hl.layer_rule({ name = "hyprpicker", animation = "fade", match = { namespace = "hyprpicker" } })
hl.layer_rule({ name = "wlogout", animation = "fade", match = { namespace = "logout_dialog" } })
hl.layer_rule({ name = "slurp", animation = "fade", match = { namespace = "selection" } })
hl.layer_rule({ name = "wayfreeze", animation = "fade", match = { namespace = "wayfreeze" } })
hl.layer_rule({ name = "screenshot-region", no_anim = true, match = { namespace = "noctalia-screenshot-region" } })
hl.layer_rule({ name = "launcher", animation = "popin 80%", blur = true, match = { namespace = "launcher" } })
hl.layer_rule({
  name = "noctalia-no-anim",
  no_anim = true,
  match = {
    namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
  },
})
