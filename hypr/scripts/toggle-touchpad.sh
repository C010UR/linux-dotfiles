#!/bin/bash

TOUCHPAD="asuf1209:00-2808:0219-touchpad"
STATE_FILE="/tmp/touchpad_state"

if [ ! -f "$STATE_FILE" ]; then
    echo "enabled" > "$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")

if [ "$STATE" == "enabled" ]; then
    hyprctl keyword "device[$TOUCHPAD]:enabled" false
    echo "disabled" > "$STATE_FILE"
    notify-send "Touchpad" "Disabled" -t 2000
else
    hyprctl keyword "device[$TOUCHPAD]:enabled" true
    echo "enabled" > "$STATE_FILE"
    notify-send "Touchpad" "Enabled" -t 2000
fi
