---@class ScaffoldTestFixture
local M = {}

M.SMS_COMMAND_REL = "src/RichBrains/Bundles/SMSBundle/Command"

---@return string|nil
function M.sms_source_root()
  local env = os.getenv("SCAFFOLD_SMS_ROOT")
  if env and env ~= "" and vim.uv.fs_stat(env .. "/composer.json") then
    return vim.fs.normalize(env)
  end
  local home = vim.fs.normalize("~/job/sms")
  if vim.uv.fs_stat(home .. "/composer.json") then
    return home
  end
  return nil
end

---@param cmd string[]
---@return boolean ok
---@return string|nil err
local function run_cmd(cmd)
  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    return false, (result.stderr or "") .. (result.stdout or "")
  end
  return true
end

---@param src string
---@param dst string
local function copy_path(src, dst)
  if vim.uv.fs_stat(src) == nil then
    error("missing fixture source: " .. src)
  end
  local stat = vim.uv.fs_stat(src)
  if stat.type == "directory" then
    vim.fn.mkdir(dst, "p")
    local ok, err = run_cmd({ "cp", "-a", src .. "/.", dst })
    if not ok then
      error(err or "cp failed")
    end
    return
  end
  vim.fn.mkdir(vim.fs.dirname(dst), "p")
  local ok, err = run_cmd({ "cp", "-a", src, dst })
  if not ok then
    error(err or "cp failed")
  end
end

---@param root string
function M.write_scaffold_fixture_files(root)
  local fixture_dir = root .. "/" .. M.SMS_COMMAND_REL .. "/_ScaffoldFixture"
  vim.fn.mkdir(fixture_dir, "p")

  vim.fn.writefile({
    "<?php",
    "",
    "declare(strict_types=1);",
    "",
    "namespace RichBrains\\Bundles\\SMSBundle\\Command\\_ScaffoldFixture;",
    "",
    "final class ScaffoldTargetCommand",
    "{",
    "}",
  }, fixture_dir .. "/ScaffoldTargetCommand.php")

  vim.fn.writefile({
    "<?php",
    "",
    "declare(strict_types=1);",
    "",
    "namespace RichBrains\\Bundles\\SMSBundle\\Command\\_ScaffoldFixture;",
    "",
    "use RichBrains\\Bundles\\SMSBundle\\Command\\_ScaffoldFixture\\ScaffoldTargetCommand;",
    "",
    "final class ScaffoldConsumerCommand",
    "{",
    "    public function run(ScaffoldTargetCommand $target): void",
    "    {",
    "    }",
    "}",
  }, fixture_dir .. "/ScaffoldConsumerCommand.php")
end

--- Copy SMS `composer.json` and `Command/` tree into a fresh temp directory.
---@return string|nil root
---@return string|nil err
function M.setup_sms()
  local sms = M.sms_source_root()
  if not sms then
    return nil, "SCAFFOLD_SMS_ROOT or ~/job/sms with composer.json not found"
  end

  local root = vim.fs.normalize(vim.fn.tempname() .. "/scaffold-sms-fixture")
  vim.fn.mkdir(root, "p")

  copy_path(sms .. "/composer.json", root .. "/composer.json")
  copy_path(sms .. "/" .. M.SMS_COMMAND_REL, root .. "/" .. M.SMS_COMMAND_REL)

  M.write_scaffold_fixture_files(root)
  return root
end

--- Minimal project (composer + _ScaffoldFixture only) for faster LSP tests.
---@return string|nil root
---@return string|nil err
function M.setup_sms_minimal()
  local sms = M.sms_source_root()
  if not sms then
    return nil, "SCAFFOLD_SMS_ROOT or ~/job/sms with composer.json not found"
  end

  local root = vim.fs.normalize(vim.fn.tempname() .. "/scaffold-sms-minimal")
  vim.fn.mkdir(root .. "/" .. M.SMS_COMMAND_REL, "p")
  copy_path(sms .. "/composer.json", root .. "/composer.json")
  M.write_scaffold_fixture_files(root)
  return root
end

---@param root string
---@return string
function M.command_dir(root)
  return root .. "/" .. M.SMS_COMMAND_REL
end

---@param root string
---@return string
function M.fixture_dir(root)
  return M.command_dir(root) .. "/_ScaffoldFixture"
end

---@param path string
---@return string
function M.read(path)
  return table.concat(vim.fn.readfile(path), "\n")
end

---@param root string
---@return integer
function M.count_php_under_command(root)
  local n = 0
  for _, path in ipairs(require("config.scaffold.transfer").collect_files(M.command_dir(root))) do
    if path:match("%.php$") then
      n = n + 1
    end
  end
  return n
end

---@param buf integer
---@param ms? integer
---@return boolean
---@param client vim.lsp.Client
---@param method string
---@return boolean
local function client_supports(client, method)
  if client.supports_method then
    return client:supports_method(method)
  end
  return client.methods ~= nil and client.methods[method] ~= nil
end

---@param buf integer
---@param ms? integer
---@return boolean
function M.wait_phpactor(buf, ms)
  ms = ms or 20000
  local deadline = vim.uv.now() + ms
  while vim.uv.now() < deadline do
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
      if client.name == "phpactor" and client_supports(client, "workspace/willRenameFiles") then
        return true
      end
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.fn.bufload(buf)
    end
    vim.wait(200)
  end
  return false
end

return M
