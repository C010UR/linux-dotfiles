pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.services
import Caelestia.Config

Item {
    id: root

    required property KeybindsService keybindsService

    implicitWidth: 1024
    implicitHeight: 600

    HyprlandKeybinds {
        anchors.fill: parent
        keybindsService: root.keybindsService
    }
}
