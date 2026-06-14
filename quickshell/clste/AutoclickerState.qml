import Quickshell

PersistentProperties {
    reloadableId: "autoclickerState"

    property bool visible: false
    property real rateValue: 10
    property string rateUnit: "cps"
    property string actionType: "left"
    property string keyCombo: "ctrl+c"
    property bool durationEnabled: false
    property real durationValue: 60
    property string durationUnit: "seconds"
}
