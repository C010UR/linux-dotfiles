#!/usr/bin/env lua
-- scripts/test-which-key.lua
-- Walk the which-key tree for the current buffer and print every registered
-- node so you can verify that keymaps, groups, and descriptions look right.
--
-- Usage inside Neovim:
--   :luafile scripts/test-which-key.lua
-- Or from the command line (requires nvim with -u NONE):
--   nvim -u NONE --headless -c "luafile scripts/test-which-key.lua" -c "qa!"

local function dump_tree(bufnr, mode, prefix)
  bufnr = bufnr or 0
  mode = mode or "n"
  prefix = prefix or ""

  local ok, Buf = pcall(require, "which-key.buf")
  if not ok then
    print("ERROR: which-key is not loaded. Make sure the plugin is installed.")
    return
  end

  local m = Buf.get({ buf = bufnr, mode = mode })
  if not m then
    print(string.format("No which-key data for buf=%d mode=%s", bufnr, mode))
    return
  end

  local node
  if prefix == "" then
    node = m.tree.root
  else
    local Util = require("which-key.util")
    local keys = Util.keys(prefix, { norm = true })
    node = m.tree:find(keys, { expand = true })
  end

  if not node then
    print(string.format("No node found for prefix '%s' (buf=%d mode=%s)", prefix, bufnr, mode))
    return
  end

  local sep = string.rep("─", 70)
  print(sep)
  print(string.format("  Buffer: %d  |  Mode: %s  |  Prefix: '%s'", bufnr, mode, prefix == "" and "(root)" or prefix))
  print(sep)

  local function walk(n, depth)
    local indent = string.rep("  ", depth)
    local key = n.key or "(root)"
    local desc = n.desc or ""
    local group = n.group and " [GROUP]" or ""
    local rhs = n.keymap and n.keymap.rhs or ""
    local icon = ""
    if n.mapping and n.mapping.icon then
      icon = " [icon]"
    end

    -- Truncate long rhs strings
    if type(rhs) == "string" and #rhs > 40 then
      rhs = rhs:sub(1, 37) .. "..."
    end

    local line
    if rhs ~= "" and rhs ~= nil then
      line = string.format("%s%-10s  →  %-30s  |  %s%s%s", indent, key, desc, rhs, group, icon)
    else
      line = string.format("%s%-10s  →  %-30s%s%s", indent, key, desc, group, icon)
    end

    print(line)

    -- Collect children and sort by key for stable output
    local children = {}
    for _, child in pairs(n._children or {}) do
      children[#children + 1] = child
    end
    table.sort(children, function(a, b)
      return (a.key or "") < (b.key or "")
    end)

    for _, child in ipairs(children) do
      walk(child, depth + 1)
    end
  end

  walk(node, 0)
  print(sep)
end

local function count_nodes(bufnr, mode)
  bufnr = bufnr or 0
  mode = mode or "n"

  local ok, Buf = pcall(require, "which-key.buf")
  if not ok then
    print("ERROR: which-key is not loaded.")
    return
  end

  local m = Buf.get({ buf = bufnr, mode = mode })
  if not m then
    print(string.format("No which-key data for buf=%d mode=%s", bufnr, mode))
    return
  end

  local total = 0
  local groups = 0
  local leafs = 0

  local function walk(n)
    total = total + 1
    if n.group then
      groups = groups + 1
    elseif n.keymap and n.keymap.rhs then
      leafs = leafs + 1
    end
    for _, child in pairs(n._children or {}) do
      walk(child)
    end
  end

  walk(m.tree.root)

  local sep = string.rep("─", 70)
  print(sep)
  print(string.format("  Stats for buf=%d mode=%s", bufnr, mode))
  print(sep)
  print(string.format("  Total nodes: %d", total))
  print(string.format("  Groups:      %d", groups))
  print(string.format("  Leaf maps:   %d", leafs))
  print(sep)
end

-- Default run: dump root of current buffer in normal mode
print("\n")
dump_tree(0, "n", "")
print("\n")

-- Also dump the <leader> subtree
print("\n")
dump_tree(0, "n", "<leader>")
print("\n")

-- Stats
count_nodes(0, "n")
