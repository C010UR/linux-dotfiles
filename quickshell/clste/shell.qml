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
        appid: "clste"
        name: "toggleF1"
        onPressed: state.visible = !state.visible
    }

    GlobalShortcut {
        appid: "clste"
        name: "toggleAutoclickerWindow"
        onPressed: autoclickerState.visible = !autoclickerState.visible
    }

    GlobalShortcut {
        appid: "clste"
        name: "toggleAutoclicker"
        onPressed: autoclickerService.toggle()
    }

    AutoclickerState {
        id: autoclickerState
    }

    AutoclickerService {
        id: autoclickerService
        settings: autoclickerState
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

    PanelWindow {
        id: autoclickerPopup
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
        WlrLayershell.keyboardFocus: autoclickerState.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        contentItem.Config.screen: screen.name
        contentItem.Tokens.screen: screen.name

        HyprlandFocusGrab {
            active: autoclickerState.visible
            windows: [autoclickerPopup]
            onCleared: autoclickerState.visible = false
        }

        AutoclickerConfig {
            id: autoclickerConfig
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
                id: autoclickerBlobGroup
                color: Colours.tPalette.m3surface
                smoothing: Config.border.smoothing

                Behavior on color {
                    CAnim {}
                }
            }

            BlobInvertedRect {
                anchors.fill: parent
                anchors.margins: -50
                group: autoclickerBlobGroup
                radius: Config.border.rounding
                borderLeft: -anchors.margins
                borderRight: Config.border.thickness - anchors.margins
                borderTop: Config.border.thickness - anchors.margins
                borderBottom: Config.border.thickness - anchors.margins
            }

            BlobRect {
                id: autoclickerBlobBg
                group: autoclickerBlobGroup
                x: autoclickerWrapper.x
                y: autoclickerWrapper.y + Config.border.thickness
                implicitWidth: autoclickerWrapper.width
                implicitHeight: autoclickerWrapper.height
                radius: Tokens.rounding.large
                deformScale: (0.1 * Config.appearance.deformScale) / 10000
            }
        }

        AutoclickerWrapper {
            id: autoclickerWrapper
            state: autoclickerState
            config: autoclickerConfig
            screen: autoclickerPopup.screen
            service: autoclickerService
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            transform: Matrix4x4 {
                matrix: autoclickerBlobBg.deformMatrix
            }
        }

        mask: Region {
            x: autoclickerWrapper.x
            y: autoclickerWrapper.y
            width: autoclickerWrapper.width
            height: autoclickerWrapper.height
        }
    }
}
