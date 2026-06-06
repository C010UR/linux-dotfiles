pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Caelestia.Blobs
import Caelestia.Config
import qs.components
import qs.services

ShellRoot {
    GlobalShortcut {
        appid: "f1-window"
        name: "toggle"
        onPressed: visibilities.dashboard = !visibilities.dashboard
    }

    PanelWindow {
        id: popup
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusiveZone: 0
        WlrLayershell.namespace: "f1-window"
        WlrLayershell.keyboardFocus: visibilities.dashboard ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        contentItem.Config.screen: screen.name
        contentItem.Tokens.screen: screen.name

        HyprlandFocusGrab {
            active: visibilities.dashboard
            windows: [popup]
            onCleared: visibilities.dashboard = false
        }

        DrawerVisibilities {
            id: visibilities
        }

        KeybindsService {
            id: keybindsService
        }

        Item {
            anchors.fill: parent
            opacity: Colours.transparency.enabled ? Colours.transparency.base : 1
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                blurMax: 15
                shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.7)
            }

            BlobGroup {
                id: blobGroup
                color: Colours.palette.m3surface
                smoothing: Config.border.smoothing

                Behavior on color {
                    CAnim {}
                }
            }

            BlobInvertedRect {
                anchors.fill: parent
                anchors.margins: -50
                group: blobGroup
                radius: Config.border.rounding
                borderLeft: -anchors.margins
                borderRight: Config.border.thickness - anchors.margins
                borderTop: Config.border.thickness - anchors.margins
                borderBottom: Config.border.thickness - anchors.margins
            }

            BlobRect {
                id: blobBg
                group: blobGroup
                x: dashboardWrapper.x
                y: dashboardWrapper.y + Config.border.thickness
                implicitWidth: dashboardWrapper.width
                implicitHeight: dashboardWrapper.height
                radius: Tokens.rounding.large
                deformScale: (0.1 * Config.appearance.deformScale) / 10000
            }
        }

        Wrapper {
            id: dashboardWrapper
            visibilities: visibilities
            keybindsService: keybindsService
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            transform: Matrix4x4 {
                matrix: blobBg.deformMatrix
            }
        }

        mask: Region {
            x: dashboardWrapper.x
            y: dashboardWrapper.y
            width: dashboardWrapper.width
            height: dashboardWrapper.height
        }
    }
}
