pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.services

Item {
    id: root

    required property ShellScreen screen
    required property real maxWidth
    required property real maxHeight
    required property KeybindsService keybindsService

    readonly property real hPad: Tokens.padding.largeIncreased
    readonly property real vPad: Tokens.padding.largeIncreased
    readonly property real contentWidth: Math.min(screen.width * 0.75, maxWidth)
    readonly property real contentHeight: Math.min(screen.height * 0.65, maxHeight)

    implicitWidth: contentWidth + hPad * 2
    implicitHeight: Math.min(layout.implicitHeight + vPad * 2, contentHeight + vPad * 2)

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.leftMargin: root.hPad
        anchors.rightMargin: root.hPad
        anchors.topMargin: root.vPad
        anchors.bottomMargin: root.vPad
        spacing: Tokens.spacing.extraLargeIncreased

        ColumnLayout {
            id: header

            Layout.fillWidth: true
            spacing: Tokens.spacing.extraSmall

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Hyprland Keybinds")
                color: Colours.palette.m3onSurface
                font: Tokens.font.title.large
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("%1 shortcuts").arg(root.keybindsService.hyprlandKeybinds.length)
                color: Colours.palette.m3outline
                font: Tokens.font.body.small
                elide: Text.ElideRight
            }
        }

        HyprlandKeybinds {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: root.contentHeight - header.implicitHeight - layout.spacing - root.vPad * 2
            keybindsService: root.keybindsService
        }
    }

    Behavior on implicitWidth {
        Anim {
            type: Anim.EmphasizedLarge
        }
    }

    Behavior on implicitHeight {
        Anim {
            type: Anim.EmphasizedLarge
        }
    }
}
