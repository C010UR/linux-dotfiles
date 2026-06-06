import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "utils/scripts/fzf.js" as Fzf

Item {
    id: root

    property var hyprlandKeybinds: []
    property bool hyprLoaded: false
    property var fzfFinder: null

    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/quickshell/f1-window"

    onHyprlandKeybindsChanged: {
        if (hyprlandKeybinds.length > 0)
            fzfFinder = new Fzf.Finder(hyprlandKeybinds, {
                selector: item => `${item.key} ${item.description} ${item.category}`
            });
        else
            fzfFinder = null;
    }

    function filter(keybinds, search) {
        if (!search || !fzfFinder)
            return keybinds;
        return fzfFinder.find(search).sort((a, b) => {
            if (a.score === b.score)
                return a.item.description.length - b.item.description.length;
            return b.score - a.score;
        }).map(r => r.item);
    }

    function groupByCategory(keybinds) {
        const groups = {}
        for (const kb of keybinds) {
            const cat = kb.category || "misc"
            if (!groups[cat])
                groups[cat] = {
                    key: cat,
                    items: []
                }
            groups[cat].items.push(kb)
        }
        for (const g of Object.values(groups))
            g.items.sort((a, b) => (a.order ?? 999) - (b.order ?? 999))
        return Object.values(groups)
    }

    FileView {
        id: hyprView
        path: root.cacheDir + "/hyprland_keybinds.json"
        onLoaded: {
            root.hyprlandKeybinds = JSON.parse(text());
            root.hyprLoaded = true;
        }
    }

    Connections {
        function onConfigReloaded(): void {
            hyprView.reload();
        }

        target: typeof Hypr !== "undefined" ? Hypr : null
    }
}
