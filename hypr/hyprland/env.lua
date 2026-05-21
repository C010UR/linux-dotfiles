local v = require("hyprland.vars")

-- ── Cursor ────────────────────────────────────────────────────────────────────
hl.env("XCURSOR_THEME", v.cursorTheme)
hl.env("XCURSOR_SIZE", tostring(v.cursorSize))

-- ── Qt ────────────────────────────────────────────────────────────────────────
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- ── Toolkit backends ──────────────────────────────────────────────────────────
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("SDL_VIDEODRIVER", "wayland,x11,windows")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
