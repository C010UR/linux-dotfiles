# Scaffold tests

## Run

```bash
./scripts/run_scaffold_tests.sh
```

Requires `~/job/sms` (or set `SCAFFOLD_SMS_ROOT`) with `composer.json` and `src/RichBrains/Bundles/SMSBundle/Command/`.

## What is covered

| Area | Fixture | LSP |
|------|---------|-----|
| Copy SMS `Command/` + `composer.json` | temp dir per run | — |
| Scaffold empty PHP | `_ScaffoldFixture/` | — |
| Copy / move file & folder | `_ScaffoldFixture/` | local namespace/class sync |
| Cross-file `use` updates | minimal 2-file project | phpactor `willRename` (skipped if no edit) |

Local sync updates `namespace` and `class` in moved/copied files only. Other files are updated when phpactor returns a `workspace/willRenameFiles` workspace edit (`vim.g.config_scaffold_lsp_file_rename`, default on in `options.lua`).

## Layout (`lua/config/scaffold/`)

| Module | Role |
|--------|------|
| `init.lua` | Public API, `setup()`, autocmds |
| `registry.lua` | Provider registration and lookup |
| `relocate.lua` | Copy, move, rename, LSP + provider sync |
| `buffer.lua` | Empty-file scaffold on open |
| `transfer.lua` | Paths, explorer targets, tree pairs |
| `lsp.lua` | `willRenameFiles` / `didRenameFiles` |
| `php/init.lua` | PHP provider registration and `build` |
| `php/psr4.lua`, `php/sync.lua`, `php/rename.lua` | PHP-specific logic |

PHP project roots (`composer.json`, phpactor markers) live only in `lua/plugins/lang-php.lua`.

Add a language by implementing `build`, optional `rename` / `file_move`, and calling `registry.register()` from a `lang-*.lua` plugin.

## Environment

- `SCAFFOLD_SMS_ROOT` — path to sms repo (default `~/job/sms`)
- `SCAFFOLD_REQUIRE_LSP=1` — (optional, not implemented) fail instead of skip when LSP unavailable
