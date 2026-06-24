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

-- ── Sized + centered floating apps ───────────────────────────────────────────

hl.window_rule({
  name = "flatseal",
  float = true,
  size = "(monitor_w*0.7) (monitor_h*0.8)",
  center = true,
  match = { class = "com.github.tchx84.Flatseal" },
})
hl.window_rule({
  name = "prism-launcher",
  float = true,
  size = "(monitor_w*0.7) (monitor_h*0.8)",
  center = true,
  match = { class = "org.prismlauncher.PrismLauncher" },
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

hl.window_rule({ name = "sysmon", workspace = "special:sysmon", match = { class = "btop" } })
hl.window_rule({
  name = "music",
  workspace = "special:music",
  match = { class = "feishin|Spotify|Supersonic|Cider|spotify" },
})
hl.window_rule({ name = "spotify-wayland", workspace = "special:music", match = { initial_title = "Spotify( Free)?" } }) -- Spotify Wayland sets no WM class
-- Slack Huddle: more specific than the communication rule below — must come first.
-- Identified by initialTitle since the window title changes once a call connects.
hl.window_rule({
  name = "slack-huddle",
  workspace = "special:huddle",
  fullscreen = true,
  match = { class = "(?i)slack", initial_title = "Slack - Huddle Preview" },
})
hl.window_rule({
  name = "communication",
  workspace = "special:communication",
  match = { class = "discord|equibop|vesktop|whatsapp|org.telegram.desktop|(?i)slack" },
})
-- Notes: lives in special:notes, toggled by Win+R
hl.window_rule({
  name = "notes",
  float = true,
  size = "(monitor_w*0.85) (monitor_h*0.75)",
  center = true,
  workspace = "special:notes",
  match = { class = "com.mitchellh.ghostty", title = "^notes$" },
})
-- Dolphin: lives in special:dolphin, toggled by Win+E
hl.window_rule({
  name = "dolphin",
  float = true,
  size = "(monitor_w*0.7) (monitor_h*0.8)",
  center = true,
  workspace = "special:dolphin",
  match = { class = "org.kde.dolphin" },
})

-- Qalculate: lives in special:qalculate, toggled by Win+C
hl.window_rule({
  name = "qalculate",
  float = true,
  size = "(monitor_w*0.3) (monitor_h*0.65)",
  center = true,
  workspace = "special:qalculate",
  match = { class = "qalculate-gtk" },
})

-- ── Dialogs ───────────────────────────────────────────────────────────────────

hl.window_rule({
  name = "dialogs",
  float = true,
  center = true,
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

hl.window_rule({
  name = "hyprland-share-picker",
  float = true,
  center = true,
  match = { class = "hyprland-share-picker" },
})

-- ── Event handlers ────────────────────────────────────────────────────────────

-- When a floating special overlay is visible and a new window opens, move it to the
-- current regular workspace then hide the overlay.
local function window_matches(win, match)
  if match.class ~= nil and win.class ~= match.class then
    return false
  end
  if match.title ~= nil and (win.title == nil or not win.title:match(match.title)) then
    return false
  end
  return true
end

local function find_matching_windows(match)
  local found = {}
  for _, w in ipairs(hl.get_windows()) do
    if window_matches(w, match) then
      found[#found + 1] = w
    end
  end
  return found
end

local overlay_specials = {
  { name = "dolphin", match = { class = "org.kde.dolphin" } },
  { name = "qalculate", match = { class = "qalculate-gtk" } },
  { name = "notes", match = { class = "com.mitchellh.ghostty", title = "^notes$" } },
}

hl.on("window.open", function(win)
  for _, overlay in ipairs(overlay_specials) do
    if window_matches(win, overlay.match) then
      return
    end
  end

  local overlay_names = {}
  for _, overlay in ipairs(overlay_specials) do
    overlay_names["special:" .. overlay.name] = true
  end

  -- Leave windows on their assigned special workspaces (Slack, Telegram, etc.)
  if win.workspace ~= nil and win.workspace.name:match("^special:") and not overlay_names[win.workspace.name] then
    return
  end

  for _, overlay in ipairs(overlay_specials) do
    local wins = find_matching_windows(overlay.match)
    if #wins > 0 then
      local owner = wins[1]
      local special = "special:" .. overlay.name
      if owner.workspace ~= nil and owner.workspace.name == special and owner.workspace.visible then
        local ws = hl.get_active_workspace()
        if ws ~= nil then
          hl.dispatch(hl.dsp.window.move({
            window = win,
            workspace = ws,
            follow = false,
          }))
        end

        hl.dispatch(hl.dsp.workspace.toggle_special(overlay.name))
        return
      end
    end
  end
end)

-- ── Workspace rules ───────────────────────────────────────────────────────────

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = { top = 5, right = 5, bottom = 5, left = 7 } })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = { top = 5, right = 5, bottom = 5, left = 7 } })
hl.workspace_rule({ workspace = "special:dolphin", gaps_out = { top = 5, right = 5, bottom = 5, left = 7 } })
hl.workspace_rule({ workspace = "special:qalculate", gaps_out = { top = 5, right = 5, bottom = 5, left = 7 } })
hl.workspace_rule({ workspace = "special:notes", gaps_out = { top = 5, right = 5, bottom = 5, left = 7 } })

-- ── Layer rules ───────────────────────────────────────────────────────────────

hl.layer_rule({ name = "hyprpicker", animation = "fade", match = { namespace = "hyprpicker" } })
hl.layer_rule({ name = "wlogout", animation = "fade", match = { namespace = "logout_dialog" } })
hl.layer_rule({ name = "slurp", animation = "fade", match = { namespace = "selection" } })
hl.layer_rule({ name = "wayfreeze", animation = "fade", match = { namespace = "wayfreeze" } })
hl.layer_rule({ name = "launcher", animation = "popin 80%", blur = true, match = { namespace = "launcher" } })
hl.layer_rule({
  name = "caelestia-no-anim",
  no_anim = true,
  match = { namespace = "caelestia-(border-exclusion|area-picker)" },
})
hl.layer_rule({
  name = "caelestia-fade",
  animation = "fade",
  match = { namespace = "caelestia-(drawers|background)" },
})
hl.layer_rule({
  name = "caelestia-blur",
  blur = true,
  ignore_alpha = 0.57,
  match = { namespace = "caelestia-drawers" },
})
hl.layer_rule({
  name = "f1-window",
  blur = true,
  ignore_alpha = 0.57,
  match = { namespace = "f1-window" },
})
