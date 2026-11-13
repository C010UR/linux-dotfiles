#!/bin/bash
# Toggle pop-out for the focused window: float, size, centre, pin and raise.
# The `pop` tag lets the Lua config re-centre it after a move between monitors.
set -euo pipefail

width=${1:-1300}
height=${2:-900}
x=${3:-}
y=${4:-}

active=$(hyprctl activewindow -j) || exit 1
address=$(jq -r '.address // empty' <<<"$active")
[[ -n $address ]] || exit 0

pinned=$(jq -r '.pinned // false' <<<"$active")
window="address:$address"

dispatch() {
  hyprctl dispatch "$1" >/dev/null 2>&1 || true
}

if [[ $pinned == "true" ]]; then
  dispatch "hl.dsp.window.pin({ window = \"$window\" })"
  dispatch "hl.dsp.window.float({ window = \"$window\", action = \"toggle\" })"
  dispatch "hl.dsp.window.tag({ window = \"$window\", tag = \"-pop\" })"
else
  dispatch "hl.dsp.window.float({ window = \"$window\", action = \"toggle\" })"
  dispatch "hl.dsp.window.resize({ window = \"$window\", x = $width, y = $height })"

  if [[ -n $x && -n $y ]]; then
    dispatch "hl.dsp.window.move({ window = \"$window\", x = $x, y = $y })"
  else
    dispatch "hl.dsp.window.center({ window = \"$window\" })"
  fi

  dispatch "hl.dsp.window.pin({ window = \"$window\" })"
  dispatch "hl.dsp.window.alter_zorder({ window = \"$window\", mode = \"top\" })"
  dispatch "hl.dsp.window.tag({ window = \"$window\", tag = \"+pop\" })"
fi
