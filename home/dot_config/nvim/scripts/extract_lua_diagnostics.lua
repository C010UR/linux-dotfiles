--- Print LuaLS (or other) diagnostics for config Lua files.
--- Usage: nvim --headless -u ~/.config/nvim/init.lua "+luafile .../extract_lua_diagnostics.lua" +qa
--- Optional: NVIM_DIAG_PATHS=path1:path2

local M = {}

local DEFAULT_PATHS = {
  "lua/config/scaffold.lua",
  "lua/config/scaffold/init.lua",
  "lua/config/scaffold/lsp.lua",
  "lua/config/scaffold/php/init.lua",
  "lua/config/scaffold/php/psr4.lua",
  "lua/config/scaffold/php/sync.lua",
  "lua/config/scaffold/php/rename.lua",
  "lua/config/scaffold/php/symfony.lua",
  "lua/config/scaffold/php/symfony_types.lua",
  "lua/config/scaffold/transfer.lua",
  "lua/config/scaffold/explorer.lua",
  "lua/config/scaffold/types.lua",
  "lua/config/root.lua",
}

function M.paths()
  local env = vim.env.NVIM_DIAG_PATHS
  if env and env ~= "" then
    return vim.split(env, ":", { plain = true })
  end
  local config = vim.fn.stdpath("config")
  local paths = {}
  for _, rel in ipairs(DEFAULT_PATHS) do
    paths[#paths + 1] = config .. "/" .. rel
  end
  return paths
end

function M.run()
  for _, file in ipairs(M.paths()) do
    if vim.uv.fs_stat(file) then
      vim.cmd("edit " .. vim.fn.fnameescape(file))
    end
  end

  vim.defer_fn(function()
    local count = 0
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
        local name = vim.api.nvim_buf_get_name(buf)
        if name ~= "" then
          for _, d in ipairs(vim.diagnostic.get(buf)) do
            count = count + 1
            print(string.format(
              "%s:%d:%d\t%s\t%s",
              name,
              d.lnum + 1,
              d.col + 1,
              d.source or "diagnostic",
              d.message:gsub("\n", " ")
            ))
          end
        end
      end
    end
    if count == 0 then
      print("No diagnostics (LuaLS may still be starting — try :sleep 5m first).")
    else
      print(string.format("\n%d diagnostic(s)", count))
    end
    vim.cmd("qa!")
  end, 8000)
end

M.run()
