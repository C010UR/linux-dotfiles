pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services

SectionContainer {
    id: root

    required property string title
    required property string groupIcon
    required property var items

    contentSpacing: 0

    readonly property int half: Math.ceil(root.items.length / 2)

    RowLayout {
        spacing: Tokens.spacing.small
        Layout.bottomMargin: Tokens.spacing.small

        MaterialIcon {
            text: root.groupIcon
            fill: 1
            color: Colours.palette.m3primary
            font.pointSize: Tokens.spacing.large
        }

        StyledText {
            text: root.title + " (" + root.items.length + ")"
            font.pointSize: Tokens.font.size.normal
            font.weight: 500
        }

        Item {
            Layout.fillWidth: true
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.large

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: root.half

                KeybindItem {
                    required property int index

                    key: root.items[index].key
                    description: root.items[index].description
                    icon: root.items[index].icon
                    isLast: index === root.half - 1
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            visible: root.items.length > root.half

            Repeater {
                model: root.items.length - root.half

                KeybindItem {
                    required property int index

                    key: root.items[root.half + index].key
                    description: root.items[root.half + index].description
                    icon: root.items[root.half + index].icon
                    isLast: index === root.items.length - root.half - 1
                }
            }
        }
    }
}
