import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool enabled: true
    property real maxWidth: 960
    property real maxHeight: 640

    readonly property string configPath: `${Quickshell.env("HOME")}/.config/caelestia/f1-window.json`

    FileView {
        path: root.configPath
        onLoaded: {
            try {
                const cfg = JSON.parse(text());
                if (cfg.enabled !== undefined)
                    root.enabled = cfg.enabled;
                if (cfg.maxWidth !== undefined)
                    root.maxWidth = cfg.maxWidth;
                if (cfg.maxHeight !== undefined)
                    root.maxHeight = cfg.maxHeight;
            } catch (e) {
            }
        }
    }
}
