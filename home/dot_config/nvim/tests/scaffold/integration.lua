---@class ScaffoldTestIntegration
local M = {}

---@param runner ScaffoldTestRunner
function M.run(runner)
  local fixture = require("tests.scaffold.fixture")
  local transfer = require("config.scaffold.transfer")
  local php = require("config.scaffold.php")

  print("scaffold sms integration")

  local root, err = fixture.setup_sms()
  if not root then
    print("  skip  sms integration: " .. (err or "fixture unavailable"))
    return
  end

  local command = fixture.command_dir(root)
  local fixdir = fixture.fixture_dir(root)
  local scaffold = runner.setup_php()

  -- Keep tests deterministic; LSP case opts in separately.
  vim.g.config_scaffold_lsp_file_rename = false

  runner.test("sms.fixture copies Command tree and composer.json", function()
    runner.assert_true(vim.uv.fs_stat(root .. "/composer.json") ~= nil)
    local n = fixture.count_php_under_command(root)
    runner.assert_true(n >= 30, ("expected many Command php files, got %d"):format(n))
    runner.assert_true(vim.uv.fs_stat(fixdir .. "/ScaffoldTargetCommand.php") ~= nil)
  end)

  runner.test("sms.scaffold creates correct empty php file", function()
    local path = fixdir .. "/ScaffoldNewCommand.php"
    vim.fn.writefile({}, path)
    local result = php.build({
      buf = 0,
      path = path,
      root = root,
      stem = "ScaffoldNewCommand",
      ext = "php",
    })
    vim.fn.writefile(result.lines, path)
    local content = fixture.read(path)
    runner.assert_contains(content, "namespace RichBrains\\Bundles\\SMSBundle\\Command\\_ScaffoldFixture;")
    runner.assert_contains(content, "final class ScaffoldNewCommand extends Command")
    runner.assert_contains(content, "declare(strict_types=1);")
    runner.assert_contains(content, "#[AsCommand(name: 'app:command', description: 'App command')]")
    vim.fn.delete(path)
  end)

  runner.test("sms.copy file updates namespace", function()
    local from = fixdir .. "/ScaffoldTargetCommand.php"
    local to = command .. "/Archive/ScaffoldTargetCommand.php"
    vim.fn.mkdir(command .. "/Archive", "p")
    runner.assert_true(scaffold.copy_path(from, to))
    local content = fixture.read(to)
    runner.assert_contains(content, "namespace RichBrains\\Bundles\\SMSBundle\\Command\\Archive;")
    runner.assert_not_contains(content, "namespace RichBrains\\Bundles\\SMSBundle\\Command\\_ScaffoldFixture;")
    vim.fn.delete(to)
    vim.fn.delete(command .. "/Archive", "d")
  end)

  runner.test("sms.copy folder updates namespaces", function()
    local from = fixdir
    local to = command .. "/_ScaffoldFixtureCopy"
    vim.fn.mkdir(vim.fs.dirname(to), "p")
    runner.assert_true(scaffold.copy_path(from, to))
    local consumer = to .. "/ScaffoldConsumerCommand.php"
    local content = fixture.read(consumer)
    runner.assert_contains(content, "namespace RichBrains\\Bundles\\SMSBundle\\Command\\_ScaffoldFixtureCopy;")
    local target = fixture.read(to .. "/ScaffoldTargetCommand.php")
    runner.assert_contains(target, "namespace RichBrains\\Bundles\\SMSBundle\\Command\\_ScaffoldFixtureCopy;")
    vim.fn.delete(to, "rf")
  end)

  runner.test("sms.move file updates namespace and class", function()
    local from = fixdir .. "/ScaffoldTargetCommand.php"
    local to = command .. "/ScaffoldTargetRenamedCommand.php"
    runner.assert_true(scaffold.rename_file({ from = from, to = to }))
    local content = fixture.read(to)
    runner.assert_contains(content, "namespace RichBrains\\Bundles\\SMSBundle\\Command;")
    runner.assert_contains(content, "class ScaffoldTargetRenamedCommand")
    runner.assert_true(vim.uv.fs_stat(from) == nil)
    -- restore for later tests
    scaffold.rename_file({ from = to, to = from })
  end)

  runner.test("sms.move folder updates namespaces in tree", function()
    local from = fixdir
    local to = command .. "/_ScaffoldFixtureMoved"
    runner.assert_true(scaffold.rename_tree({ from = from, to = to }))
    local content = fixture.read(to .. "/ScaffoldConsumerCommand.php")
    runner.assert_contains(content, "namespace RichBrains\\Bundles\\SMSBundle\\Command\\_ScaffoldFixtureMoved;")
    local target = fixture.read(to .. "/ScaffoldTargetCommand.php")
    runner.assert_contains(target, "namespace RichBrains\\Bundles\\SMSBundle\\Command\\_ScaffoldFixtureMoved;")
    runner.assert_true(vim.uv.fs_stat(from) == nil)
    scaffold.rename_tree({ from = to, to = from })
  end)

  runner.test("sms.rename file updates consumer when phpactor available", function()
    local lsp = require("config.scaffold.lsp")
    vim.g.config_scaffold_lsp_file_rename = true

    local minimal, min_err = fixture.setup_sms_minimal()
    if not minimal then
      error("skip:" .. (min_err or "minimal fixture unavailable"))
    end

    local min_fix = fixture.fixture_dir(minimal)
    local target = min_fix .. "/ScaffoldTargetCommand.php"
    local consumer = min_fix .. "/ScaffoldConsumerCommand.php"
    local renamed = min_fix .. "/ScaffoldTargetRenamedCommand.php"

    vim.fn.chdir(minimal)
    local buf = vim.fn.bufadd(consumer)
    vim.bo[buf].filetype = "php"
    vim.fn.bufload(buf)

    if not fixture.wait_phpactor(buf, 25000) then
      vim.g.config_scaffold_lsp_file_rename = false
      error("skip:phpactor not available in headless session")
    end
    vim.wait(3000)

    local pairs = { { from = target, to = renamed } }
    if not lsp.will_rename(pairs) then
      vim.g.config_scaffold_lsp_file_rename = false
      error("skip:phpactor willRename returned no workspace edit")
    end

    runner.assert_true(vim.fn.rename(target, renamed) == 0)
    lsp.did_rename(pairs)
    require("config.scaffold.php").sync_path(renamed, {
      namespace = "RichBrains\\Bundles\\SMSBundle\\Command\\_ScaffoldFixture",
      symbol = "ScaffoldTargetRenamedCommand",
      kind = "class",
    })

    local content = fixture.read(consumer)
    runner.assert_contains(content, "ScaffoldTargetRenamedCommand")
    runner.assert_not_contains(content, "use RichBrains\\Bundles\\SMSBundle\\Command\\_ScaffoldFixture\\ScaffoldTargetCommand;")

    vim.g.config_scaffold_lsp_file_rename = false
  end)
end

return M
