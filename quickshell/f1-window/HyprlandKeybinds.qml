pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.controls
import qs.services

Item {
    id: root

    required property var keybindsService

    implicitWidth: 1024
    implicitHeight: 600

    readonly property var categories: ({
            shell: { label: "Shell", icon: "widgets" },
            workspace: { label: "Workspaces", icon: "grid_view" },
            window: { label: "Windows", icon: "window" },
            window_group: { label: "Window Groups", icon: "view_carousel" },
            app_launcher: { label: "App Launchers", icon: "launch" },
            media: { label: "Media & Sound", icon: "music_note" },
            screenshot_recording: { label: "Screenshots", icon: "screenshot_monitor" },
            special_workspace: { label: "Special Workspaces", icon: "star" },
            utility: { label: "Utilities", icon: "build" }
        })

    readonly property var filteredGroups: {
        const filtered = root.keybindsService.filter(root.keybindsService.hyprlandKeybinds, search.text)
        return root.keybindsService.groupByCategory(filtered)
    }

    readonly property var categoryOrder: ["shell", "workspace", "window", "window_group", "app_launcher", "media", "screenshot_recording", "special_workspace", "utility"]

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.normal

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ClippingRectangle {
                anchors.fill: parent
                radius: Tokens.rounding.normal
                color: "transparent"

                StyledFlickable {
                    id: flick

                    anchors.fill: parent
                    contentWidth: width
                    contentHeight: contentCol.implicitHeight
                    flickableDirection: Flickable.VerticalFlick

                    WheelHandler {
                        rotationScale: 1
                        target: flick
                        property: "contentY"
                    }

                    ColumnLayout {
                        id: contentCol

                        width: flick.width
                        spacing: Tokens.spacing.normal

                        Repeater {
                            model: root.filteredGroups.sort((a, b) => {
                                const ai = root.categoryOrder.indexOf(a.key);
                                const bi = root.categoryOrder.indexOf(b.key);
                                return (ai === -1 ? 99 : ai) - (bi === -1 ? 99 : bi);
                            })

                            KeybindGroup {
                                required property var modelData

                                Layout.fillWidth: true
                                title: root.categories[modelData.key]?.label ?? modelData.key
                                groupIcon: root.categories[modelData.key]?.icon ?? "help"
                                items: modelData.items
                            }
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: Tokens.padding.large
                            visible: root.filteredGroups.length === 0
                            text: search.text ? "No matching keybinds" : "No keybinds loaded"
                            color: Colours.palette.m3onSurfaceVariant
                            font.pointSize: Tokens.font.size.normal
                        }
                    }

                    StyledScrollBar.vertical: StyledScrollBar {
                        flickable: flick
                    }
                }
            }
        }

        StyledRect {
            color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
            radius: Tokens.rounding.full

            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(searchIcon.implicitHeight, search.implicitHeight, clearIcon.implicitHeight)

            MaterialIcon {
                id: searchIcon

                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Tokens.padding.normal
                text: "search"
                color: Colours.palette.m3onSurfaceVariant
            }

            StyledTextField {
                id: search

                anchors.left: searchIcon.right
                anchors.right: clearIcon.left
                anchors.leftMargin: Tokens.spacing.small
                anchors.rightMargin: Tokens.spacing.small
                topPadding: Tokens.padding.larger
                bottomPadding: Tokens.padding.larger
                placeholderText: qsTr("Search keybinds...")

                Component.onCompleted: forceActiveFocus()
                Keys.onEscapePressed: search.text = ""
            }

            MaterialIcon {
                id: clearIcon

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Tokens.padding.normal
                width: search.text ? implicitWidth : implicitWidth / 2
                opacity: search.text ? (clearMouse.pressed ? 0.7 : clearMouse.containsMouse ? 0.8 : 1) : 0
                text: "close"
                color: Colours.palette.m3onSurfaceVariant

                MouseArea {
                    id: clearMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: search.text ? Qt.PointingHandCursor : undefined
                    onClicked: search.text = ""
                }

                Behavior on width {
                    Anim {
                        type: Anim.StandardSmall
                    }
                }

                Behavior on opacity {
                    Anim {
                        type: Anim.StandardSmall
                    }
                }
            }
        }
    }
}
