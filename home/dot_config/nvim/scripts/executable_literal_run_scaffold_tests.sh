#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec nvim --headless -u "$ROOT/init.lua" "+lua require('tests.scaffold.run').run()" +qa
