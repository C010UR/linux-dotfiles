#!/bin/bash
# Save or restore the focused window's width, keyed by window class and
# workspace so the same app can have a different width per workspace.
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr/window-widths"
action=${1:-}

usage() {
  echo "Usage: window-width.sh save|restore" >&2
  exit 1
}

[[ $action == "save" || $action == "restore" ]] || usage

active=$(hyprctl activewindow -j) || exit 1
address=$(jq -r '.address // empty' <<<"$active")
[[ -n $address ]] || exit 1

key=$(jq -r '[.class, .initialClass, .title] | map(select(. != null and . != "")) | first // empty' <<<"$active")
[[ -n $key ]] || exit 1

workspace=$(jq -r '.workspace.id // .workspace.name // empty' <<<"$active")
[[ -n $workspace ]] || exit 1

window="address:$address"
name="workspace-${workspace}-${key}.width"
name=${name//\//_}
name=${name//$'\n'/_}
file="$STATE_DIR/$name"

notify() {
  notify-send -a hyprland "$1" 2>/dev/null || true
}

window_width() {
  hyprctl clients -j | jq -er --arg address "$address" '.[] | select(.address == $address) | .size[0]'
}

resize_width_by() {
  local delta=$1
  hyprctl dispatch "hl.dsp.window.resize({ window = \"$window\", x = $delta, y = 0, relative = true })" >/dev/null 2>&1 ||
    hyprctl dispatch resizeactive "$delta" 0 "$window" >/dev/null
}

save_width() {
  local width tmp
  width=$(jq -er '.size[0]' <<<"$active")

  mkdir -p "$STATE_DIR"
  tmp=$(mktemp "$STATE_DIR/.width.XXXXXX")
  printf '%s\n' "$width" >"$tmp"
  mv "$tmp" "$file"

  notify "Saved width ${width} for ${key}"
}

restore_width() {
  if [[ ! -f $file ]]; then
    notify "No saved width for ${key}"
    exit 1
  fi

  local width current next direction delta probe probe_delta i
  width=$(<"$file")
  [[ $width =~ ^[0-9]+$ ]] || exit 1

  current=$(window_width)
  (( current == width )) && return

  # Probe a resize to learn which sign this layout grows in.
  direction=""
  for probe in 10 -10; do
    resize_width_by "$probe"
    next=$(window_width)

    if (( next != current )); then
      if (((next - current) * probe > 0)); then
        direction=1
      else
        direction=-1
      fi

      current=$next
      break
    fi
  done

  [[ -n $direction ]] || exit 1

  for i in {1..6}; do
    delta=$((width - current))
    (( delta == 0 )) && break

    probe_delta=$((delta * direction))
    resize_width_by "$probe_delta"

    next=$(window_width)
    (( next == current )) && break
    current=$next
  done
}

case "$action" in
save) save_width ;;
restore) restore_width ;;
esac
