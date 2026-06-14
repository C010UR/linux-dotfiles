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

    readonly property var categoryOrder: ["shell", "workspace", "window", "window_group", "app_launcher", "media", "screenshot_recording", "special_workspace", "utility"]

    property string searchQuery: ""
    property var displayGroups: keybindsService.sortGroups(keybindsService.allGroups, categoryOrder)

    function refreshDisplay() {
        displayGroups = keybindsService.sortGroups(
            keybindsService.filterAndGroup(searchQuery),
            categoryOrder
        );
    }

    Timer {
        id: searchDebounce
        interval: 80
        onTriggered: root.refreshDisplay()
    }

    Connections {
        function onAllGroupsChanged(): void {
            root.refreshDisplay();
        }

        target: root.keybindsService
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Tokens.spacing.extraLargeIncreased

        StyledRect {
            id: searchBar

            Layout.fillWidth: true
            implicitHeight: searchLayout.implicitHeight + Tokens.padding.medium * 2

            radius: Tokens.rounding.full
            color: Colours.tPalette.m3surfaceContainerLowest
            border.color: searchField.activeFocus ? Colours.palette.m3primary : Colours.palette.m3outlineVariant

            Behavior on border.color {
                CAnim {}
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                onClicked: searchField.focus = true
            }

            RowLayout {
                id: searchLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Tokens.padding.large

                spacing: Tokens.spacing.small

                MaterialIcon {
                    text: "search"
                    color: Colours.palette.m3onSurfaceVariant
                    font: Tokens.font.icon.medium
                }

                StyledTextField {
                    id: searchField

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    placeholderText: qsTr("Search keybinds...")
                    placeholderTextColor: Colours.palette.m3onSurfaceVariant
                    color: Colours.palette.m3onSurface
                    font: Tokens.font.body.large

                    onTextChanged: {
                        root.searchQuery = text;
                        if (!text) {
                            searchDebounce.stop();
                            root.refreshDisplay();
                            return;
                        }
                        searchDebounce.restart();
                    }

                    Component.onCompleted: forceActiveFocus()
                    Keys.onEscapePressed: searchField.text = ""
                }

                IconButton {
                    icon: "close"
                    font: Tokens.font.icon.medium
                    type: IconButton.Text
                    padding: Tokens.padding.extraSmall
                    isRound: true
                    onClicked: {
                        searchField.clear();
                        root.searchQuery = "";
                        searchDebounce.stop();
                        root.refreshDisplay();
                    }

                    opacity: searchField.text.length > 0 ? 1 : 0

                    Behavior on opacity {
                        Anim {
                            type: Anim.DefaultEffects
                        }
                    }
                }
            }
        }

        ClippingRectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Tokens.rounding.extraLarge
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
                    spacing: Tokens.spacing.extraLargeIncreased

                    Repeater {
                        model: root.displayGroups

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
                        visible: root.displayGroups.length === 0
                        text: root.searchQuery ? qsTr("No matching keybinds") : qsTr("No keybinds loaded")
                        color: Colours.palette.m3outline
                        font: Tokens.font.body.large
                    }
                }

                StyledScrollBar.vertical: StyledScrollBar {
                    flickable: flick
                }
            }
        }
    }
}
