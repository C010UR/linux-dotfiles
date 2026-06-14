import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root

    property var hyprlandKeybinds: []
    property bool hyprLoaded: false
    property var allGroups: []

    readonly property string cacheDir: Quickshell.env("HOME") + "/.cache/quickshell/f1-window"

    onHyprlandKeybindsChanged: rebuildAllGroups()

    function rebuildAllGroups() {
        root.allGroups = groupByCategory(root.hyprlandKeybinds);
    }

    function matchesSearch(kb, search) {
        const q = search.toLowerCase();
        return kb.key.toLowerCase().includes(q)
            || kb.description.toLowerCase().includes(q)
            || (kb.category || "").toLowerCase().includes(q);
    }

    function filterAndGroup(search) {
        if (!search)
            return root.allGroups;

        const filtered = [];
        for (const kb of root.hyprlandKeybinds) {
            if (matchesSearch(kb, search))
                filtered.push(kb);
        }
        return groupByCategory(filtered);
    }

    function groupByCategory(keybinds) {
        const seen = new Set();
        const groups = {};
        for (const kb of keybinds) {
            const dedupKey = `${kb.key}|${kb.description}`;
            if (seen.has(dedupKey))
                continue;
            seen.add(dedupKey);

            const cat = kb.category || "misc";
            if (!groups[cat])
                groups[cat] = {
                    key: cat,
                    items: []
                };
            groups[cat].items.push(kb);
        }

        const result = Object.values(groups);
        for (const g of result)
            g.items.sort((a, b) => (a.order ?? 999) - (b.order ?? 999));
        return result;
    }

    function sortGroups(groups, order) {
        return groups.slice().sort((a, b) => {
            const ai = order.indexOf(a.key);
            const bi = order.indexOf(b.key);
            return (ai === -1 ? 99 : ai) - (bi === -1 ? 99 : bi);
        });
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
