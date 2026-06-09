pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

ConnectedRect {
    id: root

    required property string key
    required property string description
    required property string icon

    Layout.fillWidth: true
    implicitHeight: rowLayout.implicitHeight + rowLayout.anchors.margins * 2

    function keyIcon(name) {
        const s = name.trim();
        const low = s.toLowerCase();
        const map = {
            "super": "\u2318",
            "ctrl": "Ctrl",
            "alt": "Alt",
            "shift": "Shift",
            "delete": "Delete",
            "tab": "Tab",
            "space": "Space",
            "escape": "Esc",
            "page_up": "PgUp",
            "page_down": "PgDn",
            "caps_lock": "Caps",
            "print": "Prt Scr",
            "backspace": "\u232B",
            "return": "\u23CE",
            "enter": "\u23CE",
            "up": "\u2191",
            "down": "\u2193",
            "left": "\u2190",
            "right": "\u2192",
            "minus": "\u2212",
            "equal": "=",
            "backslash": "\\",
            "comma": ",",
            "period": ".",
            "XF86AudioRaiseVolume": "\uF028",
            "XF86AudioLowerVolume": "\uF027",
            "XF86AudioMute": "\uF026",
            "XF86AudioMicMute": "\uF131",
            "XF86AudioPlay": "\uF04B",
            "XF86AudioPause": "\uF04C",
            "XF86AudioStop": "\uF04D",
            "XF86AudioNext": "\uF04E",
            "XF86AudioPrev": "\uF04A",
            "XF86MonBrightnessUp": "\uF052",
            "XF86MonBrightnessDown": "\uF053",
            "XF86TouchpadToggle": "\uF2DB",
            "XF86Launch1": "\uF120",
        };
        if (map[s])
            return map[s];
        if (map[low])
            return map[low];
        if (s.startsWith("XF86"))
            return s.slice(4);
        return s;
    }

    function formatKey(raw) {
        if (raw.toLowerCase() === "super + super_l")
            raw = "super";

        return raw.split("+").map(k => keyIcon(k)).join(" + ");
    }

    RowLayout {
        id: rowLayout

        anchors.fill: parent
        anchors.margins: Tokens.padding.medium
        anchors.leftMargin: Tokens.padding.largeIncreased
        anchors.rightMargin: Tokens.padding.largeIncreased
        spacing: Tokens.spacing.medium

        MaterialIcon {
            text: root.icon
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.icon.medium
        }

        StyledText {
            Layout.fillWidth: true
            text: root.description
            color: Colours.palette.m3onSurface
            font: Tokens.font.body.small
            elide: Text.ElideRight
        }

        StyledText {
            Layout.maximumWidth: parent.width * 0.45
            horizontalAlignment: Text.AlignRight
            text: root.formatKey(root.key)
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.body.small
            elide: Text.ElideLeft
        }
    }
}
