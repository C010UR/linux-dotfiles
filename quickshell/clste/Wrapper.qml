pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components

Item {
    id: root

    required property F1WindowState state
    required property F1WindowConfig config
    required property ShellScreen screen
    required property KeybindsService keybindsService

    readonly property bool shouldBeActive: state.visible && config.enabled
    property real offsetScale: shouldBeActive ? 0 : 1

    visible: offsetScale < 1
    anchors.topMargin: (-implicitHeight - 5) * offsetScale
    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth || Math.min(screen.width * 0.75, config.maxWidth)
    opacity: 1 - offsetScale

    Behavior on offsetScale {
        Anim {}
    }

    Loader {
        id: content

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        active: root.shouldBeActive || root.visible

        sourceComponent: Content {
            screen: root.screen
            maxWidth: root.config.maxWidth
            maxHeight: root.config.maxHeight
            keybindsService: root.keybindsService
        }
    }
}
