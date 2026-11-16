---@class ScaffoldTestRunner
local M = {}

local passed = 0
local failed = 0
local php_registered = false

---@param name string
---@param fn fun()
function M.test(name, fn)
  local ok, err = pcall(fn)
  if not ok and type(err) == "string" then
    local skip_msg = err:match("skip:([^\n]+)") or err:match("^skip:(.+)$")
    if skip_msg then
      print("  skip  " .. name .. " (" .. skip_msg .. ")")
      return
    end
  end
  if ok then
    passed = passed + 1
    print("  ok  " .. name)
  else
    failed = failed + 1
    print(" FAIL " .. name)
    print("       " .. tostring(err))
  end
end

---@param a any
---@param b any
---@param msg? string
function M.assert_eq(a, b, msg)
  if a ~= b then
    error((msg or "assert_eq") .. ": got " .. vim.inspect(a) .. ", want " .. vim.inspect(b))
  end
end

---@param cond boolean
---@param msg? string
function M.assert_true(cond, msg)
  if not cond then
    error(msg or "assert_true")
  end
end

---@param haystack string
---@param needle string
function M.assert_contains(haystack, needle)
  M.assert_true(haystack:find(needle, 1, true) ~= nil, ("expected %q in content"):format(needle))
end

---@param haystack string
---@param needle string
function M.assert_not_contains(haystack, needle)
  M.assert_true(haystack:find(needle, 1, true) == nil, ("did not expect %q in content"):format(needle))
end

---@return string
function M.temp_project()
  local dir = vim.fs.normalize(vim.fn.tempname() .. "/scaffold-php-test")
  vim.fn.mkdir(dir .. "/src/Old", "p")
  vim.fn.writefile({
    "{",
    '  "autoload": {',
    '    "psr-4": { "App\\\\": "src/" }',
    "  }",
    "}",
  }, dir .. "/composer.json")
  return dir
end

function M.setup_php()
    if not php_registered then
      local registry = require("config.scaffold.registry")
      if not registry.providers.php then
        require("config.scaffold.php").register()
      end
      php_registered = true
    end
  return require("config.scaffold")
end

function M.run()
  print("scaffold tests")

  M.setup_php()

  local transfer = require("config.scaffold.transfer")
  local php = require("config.scaffold.php")

  M.test("transfer.collect_files finds nested php", function()
    local dir = M.temp_project()
    vim.fn.mkdir(dir .. "/src/Old/Sub", "p")
    vim.fn.writefile({ "<?php" }, dir .. "/src/Old/Foo.php")
    vim.fn.writefile({ "<?php" }, dir .. "/src/Old/Sub/Bar.php")

    local files = transfer.collect_files(dir .. "/src/Old")
    M.assert_eq(#files, 2)
    M.assert_true(vim.tbl_contains(files, dir .. "/src/Old/Foo.php"))
    M.assert_true(vim.tbl_contains(files, dir .. "/src/Old/Sub/Bar.php"))
  end)

  M.test("transfer.resolve_target_dir uses explorer cwd parent", function()
    local dir = M.temp_project()
    local command = dir .. "/src/Command"
    local hotfix = command .. "/Hotfix"
    vim.fn.mkdir(hotfix, "p")
    local file = hotfix .. "/Foo.php"
    vim.fn.writefile({ "<?php" }, file)
    M.assert_eq(transfer.resolve_target_dir(hotfix, command), command)
    M.assert_eq(transfer.resolve_target_dir(command, command), command)
  end)

  M.test("transfer.default_relocate_destination copy avoids duplicate basename", function()
    local dir = M.temp_project()
    local hotfix2 = dir .. "/src/Command/Hotfix2"
    vim.fn.mkdir(hotfix2, "p")
    local default = transfer.default_relocate_destination(hotfix2, hotfix2, "copy")
    M.assert_eq(vim.fn.fnamemodify(default, ":t"), "Hotfix2-copy")
    M.assert_true(not default:find("/Hotfix2/Hotfix2$"))
  end)

  M.test("transfer.default_relocate_destination move keeps path for rename", function()
    local dir = M.temp_project()
    local command = dir .. "/src/Command"
    local hotfix = command .. "/Hotfix"
    vim.fn.mkdir(hotfix, "p")
    local default = transfer.default_relocate_destination(hotfix, command, "move")
    M.assert_eq(default, hotfix)
    local to, err = transfer.resolve_relocate_destination(hotfix, command .. "/Hotfix2", "move")
    M.assert_eq(err, nil)
    M.assert_eq(to, command .. "/Hotfix2")
  end)

  M.test("transfer.resolve_relocate_destination blocks copy into source tree", function()
    local dir = M.temp_project()
    local hotfix2 = dir .. "/src/Command/Hotfix2"
    vim.fn.mkdir(hotfix2, "p")
    local to, err = transfer.resolve_relocate_destination(hotfix2, hotfix2 .. "/Hotfix2", "copy")
    M.assert_eq(to, nil)
    M.assert_true(err ~= nil)
  end)

  M.test("transfer.partition_paths allows same folder when destination name differs", function()
    local dir = M.temp_project()
    local hotfix = dir .. "/src/Old"
    vim.fn.mkdir(hotfix, "p")
    local file = hotfix .. "/Foo.php"
    vim.fn.writefile({ "<?php" }, file)
    local to = hotfix .. "/Bar.php"
    M.assert_true(not transfer.is_noop_relocate(file, to))
  end)

  M.test("transfer.partition_paths skips identical paths", function()
    local dir = M.temp_project()
    local hotfix = dir .. "/src/Old"
    local file = hotfix .. "/Foo.php"
    vim.fn.writefile({ "<?php" }, file)
    local relocate, skipped = transfer.partition_paths({ file }, hotfix)
    M.assert_eq(#relocate, 0)
    M.assert_eq(#skipped, 1)
    local relocate2 = transfer.partition_paths({ file }, dir .. "/src/New")[1]
    M.assert_eq(relocate2, file)
  end)

  M.test("transfer.file_pairs_for_tree", function()
    local dir = M.temp_project()
    vim.fn.mkdir(dir .. "/src/Old/Sub", "p")
    vim.fn.writefile({ "<?php" }, dir .. "/src/Old/Foo.php")
    vim.fn.writefile({ "<?php" }, dir .. "/src/Old/Sub/Bar.php")

    local pairs = transfer.file_pairs_for_tree(dir .. "/src/Old", dir .. "/src/New")
    M.assert_eq(#pairs, 2)
    M.assert_eq(pairs[1].to, dir .. "/src/New/Foo.php")
    M.assert_eq(pairs[2].to, dir .. "/src/New/Sub/Bar.php")
  end)

  M.test("php.namespace_for empty psr4 prefix (Symfony-style)", function()
    local dir = vim.fn.tempname() .. "/sms-style"
    vim.fn.mkdir(dir .. "/src/RichBrains/Foo", "p")
    vim.fn.writefile({
      "{",
      '  "autoload": { "psr-4": { "": "src/" } }',
      "}",
    }, dir .. "/composer.json")
    local path = dir .. "/src/RichBrains/Foo/Bar.php"
    M.assert_eq(php.namespace_for(path, dir), "RichBrains\\Foo")
  end)

  M.test("php.project_root finds composer.json", function()
    local dir = M.temp_project()
    M.assert_eq(php.project_root(dir .. "/src/Old/Foo.php"), dir)
  end)

  M.test("php.apply_expected_to_lines keeps single opening brace", function()
    local lines = { "class Foo {" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "class Bar {")
  end)

  M.test("php.apply_expected_to_lines updates namespace and class", function()
    local lines = { "<?php", "namespace App\\Old;", "class Foo", "{", "}" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "App\\New", symbol = "Foo", kind = "class" }))
    M.assert_eq(lines[2], "namespace App\\New;")
    M.assert_eq(lines[3], "class Foo")
  end)

  M.test("php.apply_expected_to_lines handles brace attached to name", function()
    local lines = { "class Foo{" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "class Bar{")
  end)

  M.test("php.apply_expected_to_lines handles enum backing type", function()
    local lines = { "enum Suit: string" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Rank", kind = "enum" }))
    M.assert_eq(lines[1], "enum Rank: string")
  end)

  M.test("php.apply_expected_to_lines handles extends and implements", function()
    local lines = { "class A extends B implements C, D" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "X", kind = "class" }))
    M.assert_eq(lines[1], "class X extends B implements C, D")
  end)

  M.test("php.apply_expected_to_lines handles trait with type", function()
    local lines = { "trait TraitA: string" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "TraitB", kind = "trait" }))
    M.assert_eq(lines[1], "trait TraitB: string")
  end)

  M.test("php.apply_expected_to_lines preserves modifiers when kind differs", function()
    local lines = { "abstract class Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "abstract class Bar")
  end)

  M.test("php.apply_expected_to_lines preserves final when kind differs", function()
    local lines = { "final class Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "final class Bar")
  end)

  M.test("php.apply_expected_to_lines preserves readonly when kind differs", function()
    local lines = { "readonly class Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "readonly class Bar")
  end)

  M.test("php.apply_expected_to_lines preserves all modifiers when kind differs", function()
    local lines = { "abstract final class Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "abstract final class Bar")
  end)

  M.test("php.apply_expected_to_lines handles interface", function()
    local lines = { "interface Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "interface" }))
    M.assert_eq(lines[1], "interface Bar")
  end)

  M.test("php.apply_expected_to_lines skips when already correct", function()
    local lines = { "class Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Foo", kind = "class" }))
    M.assert_eq(lines[1], "class Foo")
  end)

  M.test("php.apply_expected_to_lines ignores non-declaration lines", function()
    local lines = { "use App\\Foo;", "$x = 1;", "// class Foo", "/* class Foo */", "# class Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "use App\\Foo;")
    M.assert_eq(lines[2], "$x = 1;")
    M.assert_eq(lines[3], "// class Foo")
    M.assert_eq(lines[4], "/* class Foo */")
    M.assert_eq(lines[5], "# class Foo")
  end)

  M.test("php.apply_expected_to_lines ignores kind change and preserves keyword", function()
    local lines = { "class Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Foo", kind = "interface" }))
    M.assert_eq(lines[1], "class Foo")
  end)

  M.test("php.kind_from_stem detects abstract class prefix", function()
    local kind, name = php.kind_from_stem("AbstractExampleClass")
    M.assert_eq(kind, "abstract_class")
    M.assert_eq(name, "AbstractExampleClass")
  end)

  M.test("php.kind_from_stem does not treat Abstract as suffix", function()
    local kind, name = php.kind_from_stem("FooAbstract")
    M.assert_eq(kind, "class")
    M.assert_eq(name, "FooAbstract")
  end)

  M.test("php.apply_expected_to_lines preserves class keyword when name changes", function()
    local lines = { "class Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "AbstractBar", kind = "abstract_class" }))
    M.assert_eq(lines[1], "class AbstractBar")
  end)

  M.test("php.apply_expected_to_lines preserves abstract when name changes", function()
    local lines = { "abstract class AbstractFoo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Foo", kind = "class" }))
    M.assert_eq(lines[1], "abstract class Foo")
  end)

  M.test("php.apply_expected_to_lines preserves abstract when name changes twice", function()
    local lines = { "abstract class AbstractFoo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "AbstractBar", kind = "abstract_class" }))
    M.assert_eq(lines[1], "abstract class AbstractBar")
  end)

  M.test("php.build scaffolds abstract class", function()
    local dir = M.temp_project()
    local path = dir .. "/src/AbstractExample.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "AbstractExample",
      ext = "php",
    })
    M.assert_contains(table.concat(result.lines, "\n"), "abstract class AbstractExample")
  end)

  M.test("php.sync_path writes disk when buffer absent", function()
    local dir = M.temp_project()
    local path = dir .. "/src/Old/Foo.php"
    vim.fn.writefile({ "<?php", "namespace App\\Old;", "class Foo", "{", "}" }, path)

    M.assert_true(php.sync_path(path, { namespace = "App\\New", symbol = "Foo", kind = "class" }))
    local content = table.concat(vim.fn.readfile(path), "\n")
    M.assert_contains(content, "namespace App\\New;")
    M.assert_not_contains(content, "namespace App\\Old;")
  end)

  M.test("scaffold.copy_path updates namespace on copy", function()
    local dir = M.temp_project()
    vim.fn.mkdir(dir .. "/src/New", "p")
    local from = dir .. "/src/Old/Foo.php"
    vim.fn.writefile({ "<?php", "namespace App\\Old;", "class Foo", "{", "}" }, from)

    local scaffold = M.setup_php()
    local to = dir .. "/src/New/Foo.php"
    M.assert_true(scaffold.copy_path(from, to))

    local content = table.concat(vim.fn.readfile(to), "\n")
    M.assert_contains(content, "namespace App\\New;")
    M.assert_not_contains(content, "namespace App\\Old;")
  end)

  M.test("scaffold.move_paths updates namespace and class stem", function()
    local dir = M.temp_project()
    vim.fn.mkdir(dir .. "/src/Controller2", "p")
    local from = dir .. "/src/Controller/ControllerExample.php"
    vim.fn.mkdir(dir .. "/src/Controller", "p")
    vim.fn.writefile({
      "<?php",
      "namespace App\\Controller;",
      "class ControllerExample",
      "{",
      "}",
    }, from)

    M.setup_php().move_paths({ from }, dir .. "/src/Controller2", {})
    local to = dir .. "/src/Controller2/ControllerExample.php"
    local content = table.concat(vim.fn.readfile(to), "\n")
    M.assert_contains(content, "namespace App\\Controller2;")
    M.assert_contains(content, "class ControllerExample")
  end)

  M.test("scaffold.move_paths batch updates moved files", function()
    local dir = M.temp_project()
    vim.fn.mkdir(dir .. "/src/New", "p")
    local foo, bar = dir .. "/src/Old/Foo.php", dir .. "/src/Old/Bar.php"
    for _, p in ipairs({ foo, bar }) do
      vim.fn.writefile({
        "<?php",
        "namespace App\\Old;",
        "class " .. vim.fn.fnamemodify(p, ":t:r"),
        "{",
        "}",
      }, p)
    end

    M.setup_php().move_paths({ foo, bar }, dir .. "/src/New", {})
    local content = table.concat(vim.fn.readfile(dir .. "/src/New/Foo.php"), "\n")
    M.assert_contains(content, "namespace App\\New;")
    M.assert_not_contains(content, "namespace App\\Old;")
  end)

  M.test("scaffold.rename_tree moves directory and updates php", function()
    local dir = M.temp_project()
    vim.fn.writefile({ "<?php", "namespace App\\Old;", "class Foo", "{", "}" }, dir .. "/src/Old/Foo.php")

    M.setup_php().rename_tree({ from = dir .. "/src/Old", to = dir .. "/src/New" })
    local content = table.concat(vim.fn.readfile(dir .. "/src/New/Foo.php"), "\n")
    M.assert_contains(content, "namespace App\\New;")
    M.assert_not_contains(content, "namespace App\\Old;")
  end)

  local symfony = require("config.scaffold.php.symfony")

  M.test("symfony.is_project detects symfony.lock", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    M.assert_true(symfony.is_project(dir))
  end)

  M.test("symfony.is_project detects composer.json with symfony/framework-bundle", function()
    local dir = M.temp_project()
    vim.fn.writefile({ '{ "require": { "symfony/framework-bundle": "^6.4" } }' }, dir .. "/composer.json")
    M.assert_true(symfony.is_project(dir))
  end)

  M.test("symfony.is_project returns false for plain project", function()
    local dir = M.temp_project()
    M.assert_true(not symfony.is_project(dir))
  end)

  M.test("symfony.scaffold_type matches Command suffix", function()
    M.assert_eq(symfony.scaffold_type("SendEmailCommand"), "command")
  end)

  M.test("symfony.scaffold_type matches Controller suffix", function()
    M.assert_eq(symfony.scaffold_type("UserController"), "controller")
  end)

  M.test("symfony.scaffold_type matches Type suffix", function()
    M.assert_eq(symfony.scaffold_type("RegistrationType"), "form_type")
  end)

  M.test("symfony.scaffold_type matches Handler suffix", function()
    M.assert_eq(symfony.scaffold_type("SendEmailHandler"), "message_handler")
  end)

  M.test("symfony.scaffold_type matches Listener suffix", function()
    M.assert_eq(symfony.scaffold_type("RequestListener"), "event_listener")
  end)

  M.test("symfony.scaffold_type matches Voter suffix", function()
    M.assert_eq(symfony.scaffold_type("PostVoter"), "voter")
  end)

  M.test("symfony.scaffold_type matches Extension suffix", function()
    M.assert_eq(symfony.scaffold_type("AppExtension"), "twig_extension")
  end)

  M.test("symfony.scaffold_type matches Transformer suffix", function()
    M.assert_eq(symfony.scaffold_type("DateTransformer"), "data_transformer")
  end)

  M.test("symfony.scaffold_type matches Normalizer suffix", function()
    M.assert_eq(symfony.scaffold_type("UserNormalizer"), "normalizer")
  end)

  M.test("symfony.scaffold_type matches Validator suffix", function()
    M.assert_eq(symfony.scaffold_type("UniqueEmailValidator"), "constraint_validator")
  end)

  M.test("symfony.scaffold_type matches Constraint suffix", function()
    M.assert_eq(symfony.scaffold_type("NotBlankConstraint"), "constraint")
  end)

  M.test("symfony.scaffold_type matches Message suffix", function()
    M.assert_eq(symfony.scaffold_type("SendEmailMessage"), "message")
  end)

  M.test("symfony.scaffold_type ignores Abstract prefix", function()
    M.assert_eq(symfony.scaffold_type("AbstractCommand"), nil)
  end)

  M.test("symfony.scaffold_type returns nil for unknown suffix", function()
    M.assert_eq(symfony.scaffold_type("FooBar"), nil)
  end)

  M.test("php.build scaffolds symfony command", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Command/SendEmailCommand.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "SendEmailCommand",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "use Symfony\\Component\\Console\\Attribute\\AsCommand;")
    M.assert_contains(content, "#[AsCommand(name: 'app:command', description: 'App command')]")
    M.assert_contains(content, "final class SendEmailCommand extends Command")
    M.assert_contains(content, "return Command::SUCCESS;")
  end)

  M.test("php.build namespace comes before use statements", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Command/SendEmailCommand.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "SendEmailCommand",
      ext = "php",
    })
    -- Find positions of namespace and first use
    local namespace_idx = nil
    local use_idx = nil
    for i, line in ipairs(result.lines) do
      if line:match("^namespace ") then
        namespace_idx = i
      end
      if line:match("^use ") and not use_idx then
        use_idx = i
      end
    end
    M.assert_true(namespace_idx ~= nil, "namespace line not found")
    M.assert_true(use_idx ~= nil, "use line not found")
    M.assert_true(namespace_idx < use_idx, "namespace must come before use")
  end)

  M.test("php.build scaffolds symfony controller", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Controller/UserController.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "UserController",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "use Symfony\\Component\\HttpFoundation\\JsonResponse;")
    M.assert_contains(content, "use Symfony\\Component\\HttpFoundation\\Request;")
    M.assert_contains(content, "use Symfony\\Component\\Routing\\Attribute\\Route;")
    M.assert_contains(content, "#[Route('/')]")
    M.assert_contains(content, "final class UserController extends AbstractController")
  end)

  M.test("php.build scaffolds symfony form type", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Form/RegistrationType.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "RegistrationType",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "use Symfony\\Component\\Validator\\Constraints as Assert;")
    M.assert_contains(content, "use Symfony\\Bridge\\Doctrine\\Form\\Type\\EntityType;")
    M.assert_contains(content, "final class RegistrationType extends AbstractType")
  end)

  M.test("php.build scaffolds symfony message", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Message/SendEmailMessage.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "SendEmailMessage",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "final class SendEmailMessage")
    M.assert_contains(content, "public function __construct()")
  end)

  M.test("php.build scaffolds symfony message handler", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/MessageHandler/SendEmailHandler.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "SendEmailHandler",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "use Symfony\\Component\\Messenger\\Attribute\\AsMessageHandler;")
    M.assert_contains(content, "final class SendEmailHandler")
  end)

  M.test("php.build scaffolds symfony event listener", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/EventListener/RequestListener.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "RequestListener",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "use Symfony\\Component\\EventDispatcher\\Attribute\\AsEventListener;")
    M.assert_contains(content, "final class RequestListener")
  end)

  M.test("php.build scaffolds symfony voter", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Security/Voter/PostVoter.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "PostVoter",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "final class PostVoter extends Voter")
    M.assert_contains(content, "protected function supports(string $attribute, mixed $subject): bool")
  end)

  M.test("php.build scaffolds symfony twig extension", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Twig/AppExtension.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "AppExtension",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "use Twig\\Extension\\AbstractExtension;")
    M.assert_contains(content, "final class AppExtension extends AbstractExtension")
  end)

  M.test("php.build scaffolds symfony data transformer", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Form/DataTransformer/DateTransformer.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "DateTransformer",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "use Symfony\\Component\\Form\\DataTransformerInterface;")
    M.assert_contains(content, "final class DateTransformer implements DataTransformerInterface")
  end)

  M.test("php.build scaffolds symfony normalizer", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Serializer/UserNormalizer.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "UserNormalizer",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "use Symfony\\Component\\Serializer\\Normalizer\\DenormalizerInterface;")
    M.assert_contains(content, "final class UserNormalizer implements NormalizerInterface, DenormalizerInterface")
  end)

  M.test("php.build scaffolds symfony constraint", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Validator/NotBlankConstraint.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "NotBlankConstraint",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "#[\\Attribute]")
    M.assert_contains(content, "final class NotBlankConstraint extends Constraint")
  end)

  M.test("php.build scaffolds symfony constraint validator", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Validator/UniqueEmailValidator.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "UniqueEmailValidator",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "final class UniqueEmailValidator extends ConstraintValidator")
  end)

  M.test("php.build falls back to generic php for abstract class in symfony project", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Command/AbstractCommand.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "AbstractCommand",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "abstract class AbstractCommand")
  end)

  M.test("symfony.is_project detects vendor/symfony directory", function()
    local dir = M.temp_project()
    vim.fn.mkdir(dir .. "/vendor/symfony", "p")
    M.assert_true(symfony.is_project(dir))
  end)

  M.test("symfony.is_project detects symfony/symfony in composer.json", function()
    local dir = M.temp_project()
    vim.fn.writefile({ '{ "require": { "symfony/symfony": "^6.4" } }' }, dir .. "/composer.json")
    M.assert_true(symfony.is_project(dir))
  end)

  M.test("symfony build resolves namespace for command", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Command/SendEmailCommand.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "SendEmailCommand",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "namespace App\\Command;")
  end)

  M.test("symfony build resolves namespace for controller", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Controller/UserController.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "UserController",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "namespace App\\Controller;")
  end)

  M.test("symfony build command cursor position", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Command/SendEmailCommand.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "SendEmailCommand",
      ext = "php",
    })
    M.assert_eq(result.cursor.line, #result.lines - 2)
  end)

  M.test("symfony build controller cursor position", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Controller/UserController.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "UserController",
      ext = "php",
    })
    M.assert_eq(result.cursor.line, #result.lines - 1)
  end)

  M.test("symfony build form type cursor position", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Form/RegistrationType.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "RegistrationType",
      ext = "php",
    })
    M.assert_eq(result.cursor.line, #result.lines - 2)
  end)

  M.test("symfony build falls back to generic php for plain class", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Service/Foo.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "Foo",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "class Foo")
    M.assert_not_contains(content, "final class Foo")
  end)

  M.test("symfony file_move preserves final when moving command", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    vim.fn.mkdir(dir .. "/src/Command", "p")
    local path = dir .. "/src/Command/SendEmailCommand.php"
    vim.fn.writefile({
      "<?php",
      "",
      "declare(strict_types=1);",
      "",
      "namespace App\\Command;",
      "",
      "use Symfony\\Component\\Console\\Attribute\\AsCommand;",
      "use Symfony\\Component\\Console\\Command\\Command;",
      "",
      "#[AsCommand(name: 'app:send-email', description: 'Send email')]",
      "final class SendEmailCommand extends Command",
      "{",
      "}",
    }, path)

    local lines = vim.fn.readfile(path)
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "App\\Command", symbol = "ReceiveEmailCommand", kind = "class" }))
    local content = table.concat(lines, "\n")
    M.assert_contains(content, "final class ReceiveEmailCommand extends Command")
    M.assert_not_contains(content, "class SendEmailCommand")
  end)

  M.test("symfony file_move preserves final when downgrading to plain class", function()
    local lines = { "final class FooCommand" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "final class Bar")
  end)

  M.test("symfony should_scaffold rejects vendor paths", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    vim.fn.mkdir(dir .. "/vendor/symfony/console", "p")
    local path = dir .. "/vendor/symfony/console/Command.php"
    vim.fn.writefile({}, path)
    local buf = vim.fn.bufadd(path)
    vim.bo[buf].filetype = "php"
    M.assert_true(not php.should_scaffold(buf))
  end)

  M.test("symfony build handles empty namespace", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    -- Override composer.json with no psr-4 mapping
    vim.fn.writefile({
      "{",
      '  "autoload": { "psr-4": {} }',
      "}",
    }, dir .. "/composer.json")
    local path = dir .. "/SendEmailCommand.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "SendEmailCommand",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_not_contains(content, "namespace")
    M.assert_contains(content, "final class SendEmailCommand extends Command")
  end)

  M.test("symfony build form type includes all common imports", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Form/RegistrationType.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "RegistrationType",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "use Symfony\\Component\\Form\\Extension\\Core\\Type\\TextType;")
    M.assert_contains(content, "use Symfony\\Component\\Form\\Extension\\Core\\Type\\EmailType;")
    M.assert_contains(content, "use Symfony\\Component\\Form\\Extension\\Core\\Type\\ChoiceType;")
    M.assert_contains(content, "use Symfony\\Component\\Form\\Extension\\Core\\Type\\CheckboxType;")
    M.assert_contains(content, "use Symfony\\Component\\Form\\Extension\\Core\\Type\\CollectionType;")
    M.assert_contains(content, "use Symfony\\Component\\Form\\Extension\\Core\\Type\\DateTimeType;")
    M.assert_contains(content, "use Symfony\\Component\\Form\\Extension\\Core\\Type\\IntegerType;")
    M.assert_contains(content, "use Symfony\\Component\\Form\\Extension\\Core\\Type\\TextareaType;")
    M.assert_contains(content, "use Symfony\\Component\\Form\\Extension\\Core\\Type\\HiddenType;")
    M.assert_contains(content, "use Symfony\\Bridge\\Doctrine\\Form\\Type\\EntityType;")
    M.assert_contains(content, "use Symfony\\Component\\Validator\\Constraints as Assert;")
  end)

  M.test("symfony build message handler has empty body", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/MessageHandler/SendEmailHandler.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "SendEmailHandler",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "final class SendEmailHandler")
    M.assert_not_contains(content, "public function")
    M.assert_not_contains(content, "function __invoke")
  end)

  M.test("symfony build event listener has empty body", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/EventListener/RequestListener.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "RequestListener",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "final class RequestListener")
    M.assert_not_contains(content, "public function")
    M.assert_not_contains(content, "function __invoke")
  end)

  M.test("symfony build constraint has attribute and message property", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Validator/NotBlankConstraint.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "NotBlankConstraint",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "#[\\Attribute]")
    M.assert_contains(content, "public string $message = 'The value is not valid.';")
  end)

  M.test("symfony build constraint validator has validate method", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Validator/UniqueEmailValidator.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "UniqueEmailValidator",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "public function validate(mixed $value, Constraint $constraint): void")
  end)

  M.test("symfony build normalizer implements both interfaces", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Serializer/UserNormalizer.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "UserNormalizer",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "implements NormalizerInterface, DenormalizerInterface")
    M.assert_contains(content, "public function normalize(")
    M.assert_contains(content, "public function denormalize(")
    M.assert_contains(content, "public function supportsNormalization(")
    M.assert_contains(content, "public function supportsDenormalization(")
  end)

  M.test("symfony build data transformer has both methods", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Form/DataTransformer/DateTransformer.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "DateTransformer",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "public function transform(mixed $value): mixed")
    M.assert_contains(content, "public function reverseTransform(mixed $value): mixed")
  end)

  M.test("symfony build voter has supports and voteOnAttribute", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    local path = dir .. "/src/Security/Voter/PostVoter.php"
    local result = php.build({
      buf = 0,
      path = path,
      root = dir,
      stem = "PostVoter",
      ext = "php",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "protected function supports(string $attribute, mixed $subject): bool")
    M.assert_contains(content, "protected function voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool")
  end)

  M.test("php.should_scaffold rejects empty path", function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].filetype = "php"
    M.assert_true(not php.should_scaffold(buf))
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  M.test("php.should_scaffold rejects non-php file", function()
    local dir = M.temp_project()
    local path = dir .. "/README.md"
    vim.fn.writefile({ "# README" }, path)
    local buf = vim.fn.bufadd(path)
    vim.bo[buf].filetype = "markdown"
    M.assert_true(not php.should_scaffold(buf))
  end)

  M.test("php.apply_expected_to_lines preserves tab indentation", function()
    local lines = { "\tclass Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "\tclass Bar")
  end)

  M.test("php.apply_expected_to_lines handles attribute line before class", function()
    local lines = { "#[Route('/')]", "class Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "#[Route('/')]")
    M.assert_eq(lines[2], "class Bar")
  end)

  M.test("symfony scaffold_type prioritizes longer suffix for ambiguous stems", function()
    -- "CommandController" has both "Command" and "Controller" suffixes.
    -- Controller is checked after Command, but the longest match is Controller.
    -- Current behavior returns "controller" because Controller$ is checked after Command$.
    M.assert_eq(symfony.scaffold_type("MyCommandController"), "controller")
  end)

  M.test("symfony file_move keeps namespace and class for copied command", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    vim.fn.mkdir(dir .. "/src/Command", "p")
    vim.fn.mkdir(dir .. "/src/Command/Archive", "p")
    local from = dir .. "/src/Command/SendEmailCommand.php"
    vim.fn.writefile({
      "<?php",
      "",
      "declare(strict_types=1);",
      "",
      "namespace App\\Command;",
      "",
      "use Symfony\\Component\\Console\\Attribute\\AsCommand;",
      "use Symfony\\Component\\Console\\Command\\Command;",
      "",
      "#[AsCommand(name: 'app:send-email', description: 'Send email')]",
      "final class SendEmailCommand extends Command",
      "{",
      "    protected function execute(InputInterface $input, OutputInterface $output): int",
      "    {",
      "        return Command::SUCCESS;",
      "    }",
      "}",
    }, from)

    local scaffold = M.setup_php()
    local to = dir .. "/src/Command/Archive/SendEmailCommand.php"
    M.assert_true(scaffold.copy_path(from, to))

    local content = table.concat(vim.fn.readfile(to), "\n")
    M.assert_contains(content, "namespace App\\Command\\Archive;")
    M.assert_contains(content, "final class SendEmailCommand extends Command")
    M.assert_contains(content, "#[AsCommand(name: 'app:send-email', description: 'Send email')]")
  end)

  M.test("symfony file_move updates class name when stem changes", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    vim.fn.mkdir(dir .. "/src/Command", "p")
    local from = dir .. "/src/Command/SendEmailCommand.php"
    vim.fn.writefile({
      "<?php",
      "",
      "declare(strict_types=1);",
      "",
      "namespace App\\Command;",
      "",
      "use Symfony\\Component\\Console\\Attribute\\AsCommand;",
      "use Symfony\\Component\\Console\\Command\\Command;",
      "",
      "#[AsCommand(name: 'app:send-email', description: 'Send email')]",
      "final class SendEmailCommand extends Command",
      "{",
      "}",
    }, from)

    local scaffold = M.setup_php()
    local to = dir .. "/src/Command/ReceiveEmailCommand.php"
    scaffold.rename_file({ from = from, to = to })

    local content = table.concat(vim.fn.readfile(to), "\n")
    M.assert_contains(content, "final class ReceiveEmailCommand extends Command")
    M.assert_not_contains(content, "class SendEmailCommand")
  end)

  M.test("symfony file_move does not touch extends or imports", function()
    local dir = M.temp_project()
    vim.fn.writefile({}, dir .. "/symfony.lock")
    vim.fn.mkdir(dir .. "/src/Command", "p")
    local from = dir .. "/src/Command/SendEmailCommand.php"
    vim.fn.writefile({
      "<?php",
      "",
      "declare(strict_types=1);",
      "",
      "namespace App\\Command;",
      "",
      "use Symfony\\Component\\Console\\Attribute\\AsCommand;",
      "use Symfony\\Component\\Console\\Command\\Command;",
      "",
      "#[AsCommand(name: 'app:send-email', description: 'Send email')]",
      "final class SendEmailCommand extends Command",
      "{",
      "}",
    }, from)

    local lines = vim.fn.readfile(from)
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "App\\Command", symbol = "ReceiveEmailCommand", kind = "class" }))
    local content = table.concat(lines, "\n")
    -- Only namespace and class name changed, extends and imports untouched
    M.assert_contains(content, "class ReceiveEmailCommand extends Command")
    M.assert_contains(content, "use Symfony\\Component\\Console\\Attribute\\AsCommand;")
    M.assert_contains(content, "#[AsCommand(name: 'app:send-email', description: 'Send email')]")
  end)

  M.test("php.psr4 handles multiple psr4 prefixes", function()
    local dir = vim.fn.tempname() .. "/multi-psr4"
    vim.fn.mkdir(dir .. "/src", "p")
    vim.fn.mkdir(dir .. "/tests", "p")
    vim.fn.writefile({
      "{",
      '  "autoload": { "psr-4": { "App\\\\": "src/", "App\\\\Tests\\\\": "tests/" } }',
      "}",
    }, dir .. "/composer.json")

    local src_path = dir .. "/src/Command/FooCommand.php"
    local test_path = dir .. "/tests/Command/FooCommandTest.php"
    M.assert_eq(php.namespace_for(src_path, dir), "App\\Command")
    M.assert_eq(php.namespace_for(test_path, dir), "App\\Tests\\Command")
  end)

  M.test("symfony.is_project returns false for composer.json without symfony", function()
    local dir = M.temp_project()
    vim.fn.writefile({
      "{",
      '  "require": { "doctrine/orm": "^2.0" }',
      "}",
    }, dir .. "/composer.json")
    M.assert_true(not symfony.is_project(dir))
  end)

  M.test("php.apply_expected_to_lines handles class name with numbers", function()
    local lines = { "class Foo2" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar2", kind = "class" }))
    M.assert_eq(lines[1], "class Bar2")
  end)

  M.test("php.apply_expected_to_lines handles interface extends", function()
    local lines = { "interface Foo extends Bar, Baz" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Qux", kind = "interface" }))
    M.assert_eq(lines[1], "interface Qux extends Bar, Baz")
  end)

  M.test("php.apply_expected_to_lines handles multiple spaces between tokens", function()
    local lines = { "class   Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "class Bar")
  end)

  M.test("php.apply_expected_to_lines skips anonymous class", function()
    local lines = { "$x = new class {" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "$x = new class {")
  end)

  M.test("php.apply_expected_to_lines handles implements without extends", function()
    local lines = { "class Foo implements JsonSerializable" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "class Bar implements JsonSerializable")
  end)

  M.test("php.apply_expected_to_lines handles readonly final abstract", function()
    local lines = { "abstract readonly final class Foo" }
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(lines[1], "abstract readonly final class Bar")
  end)

  M.test("php.psr4 namespace for file at src root", function()
    local dir = M.temp_project()
    local path = dir .. "/src/Foo.php"
    M.assert_eq(php.namespace_for(path, dir), "App\\Foo")
  end)

  M.test("php.psr4 falls back to directory when no prefix matches", function()
    local dir = vim.fn.tempname() .. "/no-psr4"
    vim.fn.mkdir(dir .. "/lib/Models", "p")
    vim.fn.writefile({
      "{",
      '  "autoload": { "psr-4": { "App\\\\": "src/" } }',
      "}",
    }, dir .. "/composer.json")
    local path = dir .. "/lib/Models/User.php"
    M.assert_eq(php.namespace_for(path, dir), "lib\\Models")
  end)

  M.test("php.psr4 handles deeply nested path", function()
    local dir = M.temp_project()
    local path = dir .. "/src/Domain/User/ValueObject/Email.php"
    M.assert_eq(php.namespace_for(path, dir), "App\\Domain\\User\\ValueObject")
  end)

  M.test("php.sync_path returns false for non-existent file", function()
    M.assert_true(not php.sync_path("/nonexistent/path/Foo.php", { namespace = "", symbol = "Bar", kind = "class" }))
  end)

  M.test("php.sync_path returns false when no changes needed", function()
    local dir = M.temp_project()
    local path = dir .. "/src/Old/Foo.php"
    vim.fn.writefile({ "<?php", "namespace App\\Old;", "class Foo", "{", "}" }, path)
    M.assert_true(not php.sync_path(path, { namespace = "App\\Old", symbol = "Foo", kind = "class" }))
  end)

  M.test("php.project_root falls back to cwd without composer.json", function()
    local cwd = vim.fs.normalize(vim.uv.cwd() or "")
    M.assert_eq(php.project_root("/tmp/no-composer-here/Foo.php"), cwd)
  end)

  M.test("php.apply_expected_to_lines handles empty lines", function()
    local lines = {}
    lines = select(1, php.apply_expected_to_lines(lines, { namespace = "", symbol = "Bar", kind = "class" }))
    M.assert_eq(#lines, 0)
  end)

  M.test("php.copy_path updates namespace for same-directory rename", function()
    local dir = M.temp_project()
    local from = dir .. "/src/Old/Foo.php"
    vim.fn.writefile({ "<?php", "namespace App\\Old;", "class Foo", "{", "}" }, from)
    local to = dir .. "/src/Old/Bar.php"
    local scaffold = M.setup_php()
    M.assert_true(scaffold.copy_path(from, to))
    local content = table.concat(vim.fn.readfile(to), "\n")
    -- Same directory: namespace unchanged, class name changes
    M.assert_contains(content, "namespace App\\Old;")
    M.assert_contains(content, "class Bar")
  end)

  M.test("scaffold.rename_file handles file without namespace", function()
    local dir = M.temp_project()
    vim.fn.writefile({ '{ "autoload": { "psr-4": {} } }' }, dir .. "/composer.json")
    local from = dir .. "/Foo.php"
    vim.fn.writefile({ "<?php", "class Foo", "{", "}" }, from)
    local to = dir .. "/Bar.php"
    M.setup_php().rename_file({ from = from, to = to })
    local content = table.concat(vim.fn.readfile(to), "\n")
    M.assert_not_contains(content, "namespace")
    M.assert_contains(content, "class Bar")
    M.assert_true(vim.uv.fs_stat(from) == nil)
  end)

  local html = require("config.scaffold.html")

  M.test("html.build scaffolds basic html file", function()
    local result = html.build({
      buf = 0,
      path = "/tmp/index.html",
      root = "/tmp",
      stem = "index",
      ext = "html",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "<!DOCTYPE html>")
    M.assert_contains(content, '<html lang="en">')
    M.assert_contains(content, '<meta charset="UTF-8">')
    M.assert_contains(content, '<meta name="viewport" content="width=device-width, initial-scale=1.0">')
    M.assert_contains(content, '<meta name="description" content="">')
    M.assert_contains(content, "<title>Index</title>")
    M.assert_contains(content, '<script defer src="script.js"></script>')
    M.assert_contains(content, "<body>")
    M.assert_contains(content, "</html>")
  end)

  M.test("html.build title is always Index", function()
    local result = html.build({
      buf = 0,
      path = "/tmp/contact.html",
      root = "/tmp",
      stem = "contact",
      ext = "html",
    })
    local content = table.concat(result.lines, "\n")
    M.assert_contains(content, "<title>Index</title>")
    M.assert_not_contains(content, "<title>Contact</title>")
  end)

  M.test("html.should_scaffold accepts html files", function()
    local dir = M.temp_project()
    local path = dir .. "/index.html"
    vim.fn.writefile({}, path)
    local buf = vim.fn.bufadd(path)
    M.assert_true(html.should_scaffold(buf))
  end)

  M.test("html.should_scaffold accepts htm files", function()
    local dir = M.temp_project()
    local path = dir .. "/index.htm"
    vim.fn.writefile({}, path)
    local buf = vim.fn.bufadd(path)
    M.assert_true(html.should_scaffold(buf))
  end)

  M.test("html.should_scaffold rejects php files", function()
    local dir = M.temp_project()
    local path = dir .. "/index.php"
    vim.fn.writefile({}, path)
    local buf = vim.fn.bufadd(path)
    M.assert_true(not html.should_scaffold(buf))
  end)

  M.test("html.build cursor inside body", function()
    local result = html.build({
      buf = 0,
      path = "/tmp/index.html",
      root = "/tmp",
      stem = "index",
      ext = "html",
    })
    M.assert_eq(result.cursor.line, 11)
    M.assert_eq(result.cursor.col, 4)
  end)

  M.test("html.register adds provider to registry", function()
    html.register()
    local registry = require("config.scaffold.registry")
    local provider = registry.resolve_by_path("/tmp/test.html")
    M.assert_true(provider ~= nil)
    M.assert_true(provider.build ~= nil)
    M.assert_true(provider.should_scaffold ~= nil)
  end)

  require("tests.scaffold.integration").run(M)

  print(string.format("\n%d passed, %d failed", passed, failed))
  if failed > 0 then
    vim.v.errmsg = "scaffold tests failed"
    vim.api.nvim_command("cquit")
  end
end

return M
