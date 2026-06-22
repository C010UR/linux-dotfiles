#!/usr/bin/env bash
# Re-apply Hyprland touchpad and auto-brightness state after system resume.
set -euo pipefail

restore() {
  sleep 1
  hyprctl eval 'require("hyprland.vars").apply_persisted_state()' >/dev/null 2>&1 || true
}

dbus-monitor --system \
  "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" |
  while read -r line; do
    if [[ "$line" == *"member=PrepareForSleep"* ]]; then
      read -r value_line || continue
      if [[ "$value_line" == *"boolean false"* ]]; then
        restore
      fi
    fi
  done
