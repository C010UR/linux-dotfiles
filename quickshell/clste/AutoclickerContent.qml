pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.modules.nexus.common

Item {
    id: root

    required property ShellScreen screen
    required property real maxWidth
    required property real maxHeight
    required property AutoclickerState settings
    required property AutoclickerService service

    readonly property real hPad: Tokens.padding.largeIncreased
    readonly property real vPad: Tokens.padding.largeIncreased
    readonly property real contentWidth: Math.min(screen.width * 0.5, maxWidth)
    readonly property real contentHeight: Math.min(screen.height * 0.55, maxHeight)

    property bool recordingAction: false

    readonly property list<MenuItem> durationUnitItems: [
        MenuItem { text: qsTr("Seconds") },
        MenuItem { text: qsTr("Minutes") }
    ]

    readonly property int durationUnitIndex: root.settings.durationUnit === "minutes" ? 1 : 0

    function setRateFromText(text) {
        const value = parseFloat(text);
        if (!isNaN(value) && value > 0)
            root.settings.rateValue = value;
    }

    function setDurationFromText(text) {
        const value = parseFloat(text);
        if (!isNaN(value) && value > 0)
            root.settings.durationValue = value;
    }

    function keyName(key, text) {
        if (key >= Qt.Key_A && key <= Qt.Key_Z)
            return String.fromCharCode("a".charCodeAt(0) + key - Qt.Key_A);
        if (key >= Qt.Key_0 && key <= Qt.Key_9)
            return String.fromCharCode("0".charCodeAt(0) + key - Qt.Key_0);
        if (key >= Qt.Key_F1 && key <= Qt.Key_F12)
            return "f" + (key - Qt.Key_F1 + 1);

        const map = {
            [Qt.Key_Space]: "space",
            [Qt.Key_Return]: "enter",
            [Qt.Key_Enter]: "enter",
            [Qt.Key_Tab]: "tab",
            [Qt.Key_Escape]: "esc",
            [Qt.Key_Backspace]: "backspace",
            [Qt.Key_Delete]: "delete",
            [Qt.Key_Insert]: "insert",
            [Qt.Key_Home]: "home",
            [Qt.Key_End]: "end",
            [Qt.Key_PageUp]: "pageup",
            [Qt.Key_PageDown]: "pagedown",
            [Qt.Key_Up]: "up",
            [Qt.Key_Down]: "down",
            [Qt.Key_Left]: "left",
            [Qt.Key_Right]: "right",
            [Qt.Key_Minus]: "minus",
            [Qt.Key_Equal]: "equal",
            [Qt.Key_Comma]: "comma",
            [Qt.Key_Period]: "period",
            [Qt.Key_Slash]: "slash",
            [Qt.Key_Semicolon]: "semicolon",
            [Qt.Key_Apostrophe]: "quote",
            [Qt.Key_Backslash]: "backslash",
            [Qt.Key_QuoteLeft]: "backtick",
            [Qt.Key_BracketLeft]: "leftbracket",
            [Qt.Key_BracketRight]: "rightbracket"
        };

        if (map[key])
            return map[key];
        if (text && text.trim().length === 1)
            return text.trim().toLowerCase();
        return "";
    }

    function recordKey(event) {
        const key = root.keyName(event.key, event.text);
        if (!key)
            return;

        const parts = [];
        if (event.modifiers & Qt.ControlModifier)
            parts.push("ctrl");
        if (event.modifiers & Qt.ShiftModifier)
            parts.push("shift");
        if (event.modifiers & Qt.AltModifier)
            parts.push("alt");
        if (event.modifiers & Qt.MetaModifier)
            parts.push("super");

        parts.push(key);
        root.settings.actionType = "key";
        root.settings.keyCombo = parts.join("+");
        root.recordingAction = false;
        event.accepted = true;
    }

    function recordMouse(button) {
        if (button === Qt.RightButton)
            root.settings.actionType = "right";
        else
            root.settings.actionType = "left";
        root.recordingAction = false;
    }

    implicitWidth: contentWidth + hPad * 2
    implicitHeight: Math.min(layout.implicitHeight + vPad * 2, contentHeight + vPad * 2)

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.leftMargin: root.hPad
        anchors.rightMargin: root.hPad
        anchors.topMargin: root.vPad
        anchors.bottomMargin: root.vPad
        spacing: Tokens.spacing.extraLargeIncreased

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.extraSmall

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Autoclicker")
                color: Colours.palette.m3onSurface
                font: Tokens.font.title.large
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                text: root.service.running ? qsTr("Running") : qsTr("Stopped")
                color: root.service.running ? Colours.palette.m3primary : Colours.palette.m3outline
                font: Tokens.font.body.small
                elide: Text.ElideRight
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.extraSmall / 2

            SectionHeader {
                first: true
                text: qsTr("Timing")
            }

            ConnectedRect {
                Layout.fillWidth: true
                first: true
                last: true
                implicitHeight: timingLayout.implicitHeight + timingLayout.anchors.margins * 2

                RowLayout {
                    id: timingLayout

                    anchors.fill: parent
                    anchors.margins: Tokens.padding.medium
                    anchors.leftMargin: Tokens.padding.largeIncreased
                    anchors.rightMargin: Tokens.padding.largeIncreased
                    spacing: Tokens.spacing.medium

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Timing")
                            font: Tokens.font.body.small
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Actions per selected unit")
                            color: Colours.palette.m3outline
                            font: Tokens.font.label.small
                            elide: Text.ElideRight
                        }
                    }

                    StyledTextField {
                        Layout.preferredWidth: 96
                        text: root.settings.rateValue.toString()
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: DoubleValidator {
                            bottom: 0.1
                            top: root.settings.rateUnit === "cpm" ? 6000 : 100
                            decimals: root.settings.rateUnit === "cpm" ? 0 : 1
                        }
                        onTextEdited: root.setRateFromText(text)
                        onAccepted: root.setRateFromText(text)
                        onEditingFinished: root.setRateFromText(text)

                        background: StyledRect {
                            implicitWidth: 96
                            radius: Tokens.rounding.medium
                            color: Colours.tPalette.m3surfaceContainerHigh
                        }
                    }

                    SegmentToggle {
                        leftText: qsTr("CPS")
                        rightText: qsTr("CPM")
                        leftActive: root.settings.rateUnit === "cps"
                        onLeftClicked: root.settings.rateUnit = "cps"
                        onRightClicked: root.settings.rateUnit = "cpm"
                    }
                }
            }

            SectionHeader {
                text: qsTr("Action")
            }

            ConnectedRect {
                id: actionCard

                Layout.fillWidth: true
                first: true
                last: true
                implicitHeight: actionLayout.implicitHeight + actionLayout.anchors.margins * 2
                focus: root.recordingAction

                Keys.onPressed: event => root.recordKey(event)

                RowLayout {
                    id: actionLayout

                    anchors.fill: parent
                    anchors.margins: Tokens.padding.medium
                    anchors.leftMargin: Tokens.padding.largeIncreased
                    anchors.rightMargin: Tokens.padding.largeIncreased
                    spacing: Tokens.spacing.medium

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            Layout.fillWidth: true
                            text: root.recordingAction ? qsTr("Press a key combo or mouse button") : qsTr("Recorded action")
                            font: Tokens.font.body.small
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: root.recordingAction ? qsTr("Listening for the next action") : root.service.actionLabel()
                            color: Colours.palette.m3outline
                            font: Tokens.font.label.small
                            elide: Text.ElideRight
                        }
                    }

                    IconTextButton {
                        icon: root.recordingAction ? "radio_button_checked" : "fiber_manual_record"
                        text: root.recordingAction ? qsTr("Recording") : qsTr("Record")
                        type: root.recordingAction ? TextButton.Filled : TextButton.Tonal
                        onClicked: {
                            root.recordingAction = true;
                            actionCard.forceActiveFocus();
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: 1
                    enabled: root.recordingAction
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.CrossCursor
                    onPressed: mouse => {
                        root.recordMouse(mouse.button);
                        mouse.accepted = true;
                    }
                }
            }

            SectionHeader {
                text: qsTr("Duration")
            }

            ConnectedRect {
                Layout.fillWidth: true
                first: true
                last: true
                implicitHeight: durationLayout.implicitHeight + durationLayout.anchors.margins * 2

                RowLayout {
                    id: durationLayout

                    anchors.fill: parent
                    anchors.margins: Tokens.padding.medium
                    anchors.leftMargin: Tokens.padding.largeIncreased
                    anchors.rightMargin: Tokens.padding.largeIncreased
                    spacing: Tokens.spacing.medium

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            Layout.fillWidth: true
                            text: qsTr("Run duration")
                            font: Tokens.font.body.small
                            elide: Text.ElideRight
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: root.settings.durationEnabled ? qsTr("Autoclicker stops after this time") : qsTr("Run until stopped")
                            color: Colours.palette.m3outline
                            font: Tokens.font.label.small
                            elide: Text.ElideRight
                        }
                    }

                    StyledSwitch {
                        checked: root.settings.durationEnabled
                        onToggled: root.settings.durationEnabled = checked
                    }

                    StyledTextField {
                        Layout.preferredWidth: 96
                        enabled: root.settings.durationEnabled
                        opacity: enabled ? 1 : 0.45
                        text: root.settings.durationValue.toString()
                        inputMethodHints: Qt.ImhFormattedNumbersOnly
                        validator: DoubleValidator {
                            bottom: 1
                            top: root.settings.durationUnit === "minutes" ? 1440 : 86400
                            decimals: 0
                        }
                        onTextEdited: root.setDurationFromText(text)
                        onAccepted: root.setDurationFromText(text)
                        onEditingFinished: root.setDurationFromText(text)

                        background: StyledRect {
                            implicitWidth: 96
                            radius: Tokens.rounding.medium
                            color: Colours.tPalette.m3surfaceContainerHigh
                        }
                    }

                    SegmentToggle {
                        enabled: root.settings.durationEnabled
                        opacity: enabled ? 1 : 0.45
                        leftText: qsTr("Sec")
                        rightText: qsTr("Min")
                        leftActive: root.settings.durationUnit === "seconds"
                        onLeftClicked: root.settings.durationUnit = "seconds"
                        onRightClicked: root.settings.durationUnit = "minutes"
                    }
                }
            }

            InfoRow {
                Layout.fillWidth: true
                visible: root.service.lastError
                first: true
                last: true
                label: qsTr("Error")
                value: root.service.lastError
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            IconTextButton {
                Layout.fillWidth: true
                type: TextButton.Filled
                icon: root.service.running ? "stop_circle" : "play_circle"
                text: root.service.running ? qsTr("Stop") : qsTr("Start")
                onClicked: root.service.running ? root.service.stop() : root.service.start()
            }

            IconTextButton {
                Layout.fillWidth: true
                type: TextButton.Tonal
                icon: root.service.running ? "motion_photos_pause" : "ads_click"
                text: qsTr("Toggle")
                onClicked: root.service.toggle()
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

    component SegmentToggle: StyledRect {
        id: toggle

        required property string leftText
        required property string rightText
        required property bool leftActive

        signal leftClicked
        signal rightClicked

        Layout.preferredWidth: segmentRow.implicitWidth + Tokens.padding.extraSmall * 2
        implicitHeight: Tokens.font.body.medium.pointSize + Tokens.padding.small * 2 + Tokens.padding.extraSmall
        radius: Tokens.rounding.full
        color: Colours.tPalette.m3surfaceContainerHigh

        StyledRect {
            id: indicator

            x: segmentRow.x + (toggle.leftActive ? leftSegment.x : rightSegment.x)
            y: segmentRow.y
            width: toggle.leftActive ? leftSegment.width : rightSegment.width
            height: toggle.leftActive ? leftSegment.height : rightSegment.height
            radius: Tokens.rounding.full
            color: Colours.palette.m3primary

            Behavior on x {
                Anim {
                    type: Anim.Emphasized
                }
            }

            Behavior on width {
                Anim {
                    type: Anim.Emphasized
                }
            }
        }

        RowLayout {
            id: segmentRow

            anchors.fill: parent
            anchors.margins: Tokens.padding.extraSmall
            spacing: Tokens.spacing.extraSmall
            z: 1

            SegmentButton {
                id: leftSegment

                text: toggle.leftText
                active: toggle.leftActive
                onClicked: toggle.leftClicked()
            }

            SegmentButton {
                id: rightSegment

                text: toggle.rightText
                active: !toggle.leftActive
                onClicked: toggle.rightClicked()
            }
        }
    }

    component SegmentButton: StyledRect {
        id: segment

        required property string text
        required property bool active

        signal clicked

        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitWidth: label.implicitWidth + Tokens.padding.medium * 2
        implicitHeight: label.implicitHeight + Tokens.padding.small
        radius: Tokens.rounding.full
        color: "transparent"

        StateLayer {
            color: segment.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
            radius: segment.radius
            onClicked: segment.clicked()
        }

        StyledText {
            id: label

            anchors.centerIn: parent
            text: segment.text
            color: segment.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurfaceVariant
            font: Tokens.font.label.small

            Behavior on color {
                CAnim {}
            }
        }
    }
}
