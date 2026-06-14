pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.nexus.common

ColumnLayout {
    id: root

    required property string title
    required property string groupIcon
    required property var items

    spacing: Tokens.spacing.extraSmall / 2
    Layout.fillWidth: true

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Tokens.padding.small
        spacing: Tokens.spacing.small

        MaterialIcon {
            text: root.groupIcon
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.icon.small
            fill: 1
        }

        StyledText {
            Layout.fillWidth: true
            text: root.title + "  \u00B7  " + root.items.length
            color: Colours.palette.m3onSurfaceVariant
            font: Tokens.font.label.medium
            elide: Text.ElideRight
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.extraSmall

        Repeater {
            model: root.items.length

            KeybindItem {
                required property int index

                first: index === 0
                last: index === root.items.length - 1
                key: root.items[index].key
                description: root.items[index].description
                icon: root.items[index].icon
            }
        }
    }
}
