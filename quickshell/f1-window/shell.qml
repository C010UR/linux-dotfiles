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
        onPressed: state.visible = !state.visible
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
        WlrLayershell.keyboardFocus: state.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        contentItem.Config.screen: screen.name
        contentItem.Tokens.screen: screen.name

        HyprlandFocusGrab {
            active: state.visible
            windows: [popup]
            onCleared: state.visible = false
        }

        F1WindowState {
            id: state
        }

        F1WindowConfig {
            id: config
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
                color: Colours.tPalette.m3surface
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
                x: panelWrapper.x
                y: panelWrapper.y + Config.border.thickness
                implicitWidth: panelWrapper.width
                implicitHeight: panelWrapper.height
                radius: Tokens.rounding.large
                deformScale: (0.1 * Config.appearance.deformScale) / 10000
            }
        }

        Wrapper {
            id: panelWrapper
            state: state
            config: config
            screen: popup.screen
            keybindsService: keybindsService
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            transform: Matrix4x4 {
                matrix: blobBg.deformMatrix
            }
        }

        mask: Region {
            x: panelWrapper.x
            y: panelWrapper.y
            width: panelWrapper.width
            height: panelWrapper.height
        }
    }
}
