pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

Item {
    id: root

    required property AutoclickerState settings

    readonly property string scriptPath: `${Quickshell.env("HOME")}/.config/hypr/scripts/clicker.py`

    property bool running: false
    property var activeState: null
    property string lastError: ""
    property string controlError: ""
    property string pendingAction: ""

    function intervalSeconds() {
        if (root.settings.rateUnit === "cpm")
            return 60.0 / root.settings.rateValue;
        return 1.0 / root.settings.rateValue;
    }

    function durationSeconds() {
        if (!root.settings.durationEnabled)
            return null;
        if (root.settings.durationUnit === "minutes")
            return root.settings.durationValue * 60.0;
        return root.settings.durationValue;
    }

    function actionLabel() {
        if (root.settings.actionType === "left")
            return qsTr("Left click");
        if (root.settings.actionType === "right")
            return qsTr("Right click");
        return root.settings.keyCombo;
    }

    function rateLabel() {
        const unit = root.settings.rateUnit === "cpm" ? qsTr("per minute") : qsTr("per second");
        return `${root.settings.rateValue} ${unit}`;
    }

    function durationLabel() {
        if (!root.settings.durationEnabled)
            return qsTr("Until stopped");
        const unit = root.settings.durationUnit === "minutes" ? qsTr("minutes") : qsTr("seconds");
        return `${root.settings.durationValue} ${unit}`;
    }

    function statusSummary() {
        return `${root.actionLabel()} · ${root.rateLabel()} · ${root.durationLabel()}`;
    }

    function validate() {
        if (root.settings.rateValue <= 0)
            return qsTr("Rate must be greater than 0");
        if (root.settings.durationEnabled && root.settings.durationValue <= 0)
            return qsTr("Duration must be greater than 0");
        if (root.settings.actionType === "key" && !root.settings.keyCombo.trim())
            return qsTr("Enter a key combination");
        return "";
    }

    function buildCommand(toggle) {
        const cmd = ["python3", root.scriptPath];
        if (toggle)
            cmd.push("--toggle");
        if (root.settings.rateUnit === "cpm")
            cmd.push("--cpm", String(root.settings.rateValue));
        else
            cmd.push("--cps", String(root.settings.rateValue));

        if (root.settings.actionType === "key") {
            cmd.push("--action", "key", "--keys", root.settings.keyCombo.trim());
        } else {
            cmd.push("--action", "mouse", "--button", root.settings.actionType);
        }

        const duration = root.durationSeconds();
        if (duration !== null)
            cmd.push("--duration", String(duration));

        return cmd;
    }

    function refreshStatus() {
        statusProc.running = true;
    }

    function notify(action) {
        let title = "";
        let message = "";
        let icon = "";

        if (action === "enabled") {
            title = qsTr("Autoclicker enabled");
            message = root.statusSummary();
            icon = "media-playback-start";
        } else if (action === "disabled") {
            title = qsTr("Autoclicker disabled");
            message = qsTr("Autoclicker stopped");
            icon = "media-playback-stop";
        }

        if (title) {
            notifyProc.command = ["notify-send", "-a", "clste", "-i", icon, title, message];
            notifyProc.running = true;
        }
    }

    function start() {
        const error = root.validate();
        if (error) {
            root.lastError = error;
            return;
        }
        root.lastError = "";
        root.controlError = "";
        root.pendingAction = "enabled";
        controlProc.command = root.buildCommand(true);
        controlProc.running = true;
    }

    function stop() {
        root.lastError = "";
        root.controlError = "";
        root.pendingAction = "disabled";
        stopProc.running = true;
    }

    function toggle() {
        if (root.running)
            root.stop();
        else
            root.start();
    }

    Timer {
        id: pollTimer
        interval: 500
        repeat: true
        running: true
        onTriggered: root.refreshStatus()
    }

    Process {
        id: statusProc

        command: ["python3", root.scriptPath, "--status"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const payload = JSON.parse(text);
                    root.running = payload.running === true;
                    root.activeState = payload.state ?? null;
                } catch (e) {
                }
            }
        }
    }

    Process {
        id: controlProc

        onExited: code => {
            root.refreshStatus();
            if (code !== 0) {
                root.lastError = root.controlError || qsTr("Failed to control autoclicker");
                root.pendingAction = "";
                return;
            }
            root.notify(root.pendingAction);
            root.pendingAction = "";
        }
        stderr: StdioCollector {
            onStreamFinished: root.controlError = text.trim()
        }
    }

    Process {
        id: stopProc

        command: ["python3", root.scriptPath, "--stop"]
        onExited: code => {
            root.refreshStatus();
            if (code === 0)
                root.notify(root.pendingAction);
            root.pendingAction = "";
        }
    }

    Process {
        id: notifyProc
    }

    Component.onCompleted: root.refreshStatus()
}
