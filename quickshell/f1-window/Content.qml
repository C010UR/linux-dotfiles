pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia.Config
import qs.components
import qs.components.filedialog

Item {
    id: root

    required property DrawerVisibilities visibilities
    required property DashboardState dashState
    required property FileDialog facePicker
    required property KeybindsService keybindsService

    readonly property real contentWidth: 1024
    readonly property real contentHeight: 600

    readonly property var dashboardTabs: [
        {
            iconName: "desktop_windows",
            text: qsTr("Hyprland"),
            enabled: true
        }
    ]

    readonly property real nonAnimWidth: root.contentWidth + viewWrapper.anchors.margins * 2
    readonly property real nonAnimHeight: tabs.implicitHeight + tabs.anchors.topMargin + root.contentHeight + viewWrapper.anchors.margins * 2

    implicitWidth: nonAnimWidth
    implicitHeight: nonAnimHeight

    Tabs {
        id: tabs

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: Tokens.padding.normal
        anchors.margins: Tokens.padding.large

        nonAnimWidth: root.nonAnimWidth - anchors.margins * 2
        dashState: root.dashState
        tabs: root.dashboardTabs
    }

    ClippingRectangle {
        id: viewWrapper

        anchors.top: tabs.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Tokens.padding.large

        radius: Tokens.rounding.normal
        color: "transparent"

        Flickable {
            id: view

            readonly property int currentIndex: root.dashState.currentTab
            readonly property Item currentItem: currentIndex === 0 ? hyprlandPane : neovimPane

            anchors.fill: parent

            flickableDirection: Flickable.HorizontalFlick

            implicitWidth: root.contentWidth
            implicitHeight: root.contentHeight

            contentX: currentItem?.x ?? 0
            contentWidth: row.implicitWidth
            contentHeight: row.implicitHeight

            onContentXChanged: {
                if (!moving || !currentItem)
                    return;

                const x = contentX - currentItem.x;
                if (x > currentItem.implicitWidth / 2)
                    root.dashState.currentTab = Math.min(root.dashState.currentTab + 1, tabs.count - 1);
                else if (x < -currentItem.implicitWidth / 2)
                    root.dashState.currentTab = Math.max(root.dashState.currentTab - 1, 0);
            }

            onDragEnded: {
                if (!currentItem)
                    return;

                const x = contentX - currentItem.x;
                if (x > currentItem.implicitWidth / 10)
                    root.dashState.currentTab = Math.min(root.dashState.currentTab + 1, tabs.count - 1);
                else if (x < -currentItem.implicitWidth / 10)
                    root.dashState.currentTab = Math.max(root.dashState.currentTab - 1, 0);
                else
                    contentX = Qt.binding(() => currentItem?.x ?? 0);
            }

            RowLayout {
                id: row

                HyprlandTab {
                    id: hyprlandPane
                    Layout.alignment: Qt.AlignTop
                    keybindsService: root.keybindsService
                }
            }

            Behavior on contentX {
                Anim {}
            }
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
