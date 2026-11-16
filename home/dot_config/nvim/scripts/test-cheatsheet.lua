#!/usr/bin/env lua
-- scripts/test-cheatsheet.lua
-- Smoke test for the per-mode keymap cheatsheet. Opens every sheet, reports
-- the rendered line count, and exercises cycling and closing.
--
-- Usage inside Neovim (config loaded):
--   :luafile scripts/test-cheatsheet.lua
-- Or from the command line:
--   nvim --headless -u init.lua -c "luafile scripts/test-cheatsheet.lua" -c "qa!"

local ok, cheatsheet = pcall(require, "config.cheatsheet")
if not ok then
  print("ERROR: config.cheatsheet not found on runtimepath")
  print(tostring(cheatsheet))
  return
end

cheatsheet.setup()

local MODES = { "n", "i", "v", "o", "c", "t", "motions" }
local CONTEXTS = { "pickers", "explorer", "lsp", "trouble", "debug" }
local ids = {}
vim.list_extend(ids, MODES)
vim.list_extend(ids, CONTEXTS)
local failures = 0

local sep = string.rep("─", 58)
print(sep)
print("  Config cheatsheet smoke test")
print(sep)

for _, id in ipairs(ids) do
  local opened, err = pcall(cheatsheet.open, id)
  if not opened then
    failures = failures + 1
    print(string.format("  %-8s FAIL  %s", id, tostring(err)))
  else
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local non_empty = 0
    for _, line in ipairs(lines) do
      if line:match("%S") then
        non_empty = non_empty + 1
      end
    end
    local listed = vim.bo[buf].buflisted
    local modifiable = vim.bo[buf].modifiable
    local status = (non_empty > 0 and not listed and not modifiable) and "ok" or "BAD"
    if status == "BAD" then
      failures = failures + 1
    end
    print(
      string.format(
        "  %-8s %-4s lines=%-4d non-empty=%-4d listed=%-5s modifiable=%s",
        id,
        status,
        #lines,
        non_empty,
        tostring(listed),
        tostring(modifiable)
      )
    )
  end
end

-- Cycle each ring and make sure every id is visited exactly once.
local function test_ring(ring, list)
  local start = ring == "mode" and "n" or "pickers"
  cheatsheet.open(start)
  local seen = {}
  local ok = true
  for _ = 1, #list do
    local id = vim.b[vim.api.nvim_get_current_buf()].config_cheatsheet_id
    if not id or seen[id] then
      ok = false
    end
    seen[id or "?"] = true
    cheatsheet.cycle(ring, 1)
  end
  for _, id in ipairs(list) do
    if not seen[id] then
      ok = false
    end
  end
  return ok
end

local modes_ok = test_ring("mode", MODES)
local contexts_ok = test_ring("context", CONTEXTS)
if not (modes_ok and contexts_ok) then
  failures = failures + 1
end
print(string.format("  rings     modes=%s contexts=%s", modes_ok and "ok" or "BAD", contexts_ok and "ok" or "BAD"))

-- Close should wipe every sheet buffer and leave a non-cheatsheet buffer.
cheatsheet.close()
local current = vim.api.nvim_get_current_buf()
local cleaned = vim.b[current].config_cheatsheet_id == nil
if not cleaned then
  failures = failures + 1
end
print(string.format("  close    %s", cleaned and "ok" or "BAD"))

print(sep)
print(failures == 0 and "  all good" or string.format("  %d failure(s)", failures))
print(sep)
