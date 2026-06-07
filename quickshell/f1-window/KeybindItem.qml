pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

ColumnLayout {
    id: root

    required property string key
    required property string description
    required property string icon
    property bool isLast: false

    spacing: 0
    Layout.fillWidth: true

    function keyIcon(name) {
        const s = name.trim()
        const low = s.toLowerCase()
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
            "return": "\u23CE", "enter": "\u23CE",
            "up": "\u2191", "down": "\u2193", "left": "\u2190", "right": "\u2192",
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
        }
        if (map[s]) return map[s]
        if (map[low]) return map[low]
        if (s.startsWith("XF86")) return s.slice(4)
        return s
    }

    function formatKey(raw) {
        if (raw.toLowerCase() === 'super + super_l') {
            raw = 'super';
        }

        return raw.split("+").map(k => keyIcon(k)).join(" + ")
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Tokens.padding.small
        Layout.bottomMargin: Tokens.padding.small
        spacing: Tokens.spacing.normal

        StyledRect {
            id: keyBadge

            Layout.preferredWidth: 200
            color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
            radius: Tokens.rounding.small
            implicitWidth: keyText.implicitWidth + Tokens.padding.normal * 2
            implicitHeight: keyText.implicitHeight + Tokens.spacing.small

            StyledText {
                id: keyText

                anchors.centerIn: parent
                text: root.formatKey(root.key)
                font.pointSize: Tokens.font.size.smaller
                color: Colours.palette.m3primary
            }
        }

        MaterialIcon {
            text: root.icon
            color: Colours.palette.m3primary
            font.pointSize: Tokens.font.size.normal
        }

        StyledText {
            Layout.fillWidth: true
            text: root.description
            font.weight: 600
            color: Colours.palette.m3onSurfaceVariant
            elide: Text.ElideRight
        }
    }

    StyledRect {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Colours.palette.m3outlineVariant
        opacity: 0.5
        visible: !root.isLast
    }
}
