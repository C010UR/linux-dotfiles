#!/usr/bin/env bash
# Extract Lua diagnostics via your full Neovim config (LuaLS, etc.).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec nvim --headless -u "$ROOT/init.lua" "+luafile $ROOT/scripts/extract_lua_diagnostics.lua"
