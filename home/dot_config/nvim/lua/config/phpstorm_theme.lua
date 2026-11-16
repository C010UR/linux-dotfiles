-- Colours pinned to the local PhpStorm 2026.1 install.
--
-- jb.nvim already carries the JetBrains *editor* palette, and it matches this
-- machine's scheme almost exactly (verified key by key), so only the pieces it
-- cannot know about are overridden here:
--
--   * the editor background of the scheme actually selected (Dark, #1e1f22)
--     rather than jb's Islands base (#191a1c)
--   * Islands Dark chrome surfaces (floats, status bar, tab line, separators)
--   * the integrated terminal ANSI palette
--
-- Sources, all read from the binaries and settings on this machine:
--   ~/Apps/phpstorm/lib/intellij.platform.ide.impl.jar
--     themes/islands/ManyIslandsDark.theme.json   (UI theme "Islands Dark")
--     themes/expUI/expUI_darkScheme.xml           (editor scheme "Dark")
--     DefaultColorSchemesManager.xml              (scheme "Darcula", ANSI palette)
--   ~/.config/JetBrains/PhpStorm2026.1/options/laf.xml, colors.scheme.xml
--
-- Regenerate by re-reading those files; nothing here is hand-invented.

local M = {}

-- Editor scheme "Dark" (expUI_darkScheme.xml)
local editor = {
  bg = "#1e1f22", -- TEXT / CONSOLE_BACKGROUND_KEY
  fg = "#bcbec4", -- TEXT foreground
  caret = "#ced0d6", -- CARET_COLOR
  caret_row = "#26282e", -- CARET_ROW_COLOR
  line_nr = "#4b5059", -- LINE_NUMBERS_COLOR
  line_nr_active = "#a1a3ab", -- LINE_NUMBER_ON_CARET_ROW
  selection = "#214283", -- SELECTION_BACKGROUND
  search = "#2d543f", -- SEARCH_RESULT_ATTRIBUTES
  inc_search = "#114957", -- TEXT_SEARCH_RESULT_ATTRIBUTES
  matched_brace = "#43454a", -- MATCHED_BRACE_ATTRIBUTES
  folded_fg = "#868991", -- FOLDED_TEXT_ATTRIBUTES
  folded_bg = "#393b40",
  todo = "#8bb33d", -- TODO_DEFAULT_ATTRIBUTES
  link = "#548af7", -- HYPERLINK_ATTRIBUTES
  error = "#fa6675", -- ERRORS_ATTRIBUTES EFFECT_COLOR
  warning = "#f2c55c", -- WARNING_ATTRIBUTES EFFECT_COLOR
  gutter_dim = "#43454a", -- Custom|General|Text|Whitespaces
}

-- Islands Dark UI theme (ManyIslandsDark.theme.json), semantic tokens resolved
local ui = {
  surface = "#191a1c", -- container-editor-bg = layer-0-bg = gray-10
  surface_alt = "#212326", -- layer-1-bg = gray-20
  border = "#33353b", -- gray-40
  text = "#d1d3d9", -- text-default = gray-130
  text_dim = "#73767c", -- text-secondary = gray-80
  accent = "#2e4d89", -- blue-60
  tab_active = "#233558", -- tab-selected-bg-active = blue-40
}

-- Terminal ANSI palette: BLOCK_TERMINAL_* from scheme "Darcula" -- the
-- Reworked terminal engine's colours (the 2026.1 default). These are tuned to
-- sit next to the editor syntax colours; the legacy engine's CONSOLE_* values
-- are duller and look like a different theme next to the code.
local ansi = {
  "#000000", -- black
  "#f27481", -- red
  "#6bcc62", -- green
  "#e0ce70", -- yellow
  "#5594fa", -- blue
  "#c092fa", -- magenta
  "#47ccbd", -- cyan
  "#ced0d6", -- white
  "#4e5157", -- bright black
  "#ff6b7a", -- bright red
  "#67ff59", -- bright green
  "#ffec1a", -- bright yellow
  "#3399ff", -- bright blue
  "#d970ff", -- bright magenta
  "#40ffe9", -- bright cyan
  "#ffffff", -- bright white
}

function M.apply()
  local hl = vim.api.nvim_set_hl

  -- Editor surface
  hl(0, "Normal", { fg = editor.fg, bg = editor.bg })
  hl(0, "NormalNC", { fg = editor.fg, bg = ui.surface })
  hl(0, "NormalFloat", { bg = ui.surface_alt, fg = editor.fg })
  hl(0, "Cursor", { fg = editor.bg, bg = editor.caret })
  hl(0, "CursorIM", { fg = editor.bg, bg = editor.caret })
  hl(0, "CursorLine", { bg = editor.caret_row })
  hl(0, "CursorColumn", { bg = editor.caret_row })
  hl(0, "LineNr", { fg = editor.line_nr })
  hl(0, "LineNrAbove", { fg = editor.line_nr })
  hl(0, "LineNrBelow", { fg = editor.line_nr })
  hl(0, "CursorLineNr", { fg = editor.line_nr_active, bold = true })
  hl(0, "SignColumn", { bg = editor.bg })
  hl(0, "ColorColumn", { bg = editor.caret_row })
  hl(0, "NonText", { fg = editor.gutter_dim })
  hl(0, "Whitespace", { fg = editor.gutter_dim })
  hl(0, "EndOfBuffer", { fg = editor.bg })

  -- Search and matching
  hl(0, "Visual", { bg = editor.selection })
  hl(0, "Search", { bg = editor.search })
  hl(0, "IncSearch", { bg = editor.inc_search })
  hl(0, "CurSearch", { bg = editor.inc_search })
  hl(0, "Substitute", { bg = editor.search })
  hl(0, "MatchParen", { bg = editor.matched_brace, bold = true })
  hl(0, "Folded", { fg = editor.folded_fg, bg = editor.folded_bg })

  -- Chrome
  hl(0, "Pmenu", { fg = editor.fg, bg = ui.surface_alt })
  hl(0, "PmenuSel", { fg = ui.text, bg = ui.tab_active, bold = true })
  hl(0, "PmenuSbar", { bg = ui.surface })
  hl(0, "PmenuThumb", { bg = ui.border })
  hl(0, "StatusLine", { fg = ui.text, bg = ui.surface })
  hl(0, "StatusLineNC", { fg = ui.text_dim, bg = ui.surface })
  hl(0, "TabLine", { fg = ui.text_dim, bg = ui.surface })
  hl(0, "TabLineSel", { fg = ui.text, bg = ui.tab_active, bold = true })
  hl(0, "TabLineFill", { bg = ui.surface })
  hl(0, "WinSeparator", { fg = ui.border })
  hl(0, "VertSplit", { fg = ui.border })
  hl(0, "FloatTitle", { fg = ui.text_dim, bg = ui.surface_alt })
  hl(0, "Title", { fg = editor.link, bold = true })
  hl(0, "Directory", { fg = editor.link })
  hl(0, "Underlined", { fg = editor.link, underline = true })
  hl(0, "Todo", { fg = editor.todo, bold = true })
  hl(0, "ErrorMsg", { fg = editor.error })
  hl(0, "WarningMsg", { fg = editor.warning })
  hl(0, "MoreMsg", { fg = editor.link })
  hl(0, "Question", { fg = editor.link })

  -- Diagnostics use the scheme's own effect colours
  hl(0, "DiagnosticError", { fg = editor.error })
  hl(0, "DiagnosticWarn", { fg = editor.warning })
  hl(0, "DiagnosticInfo", { fg = editor.link })
  hl(0, "DiagnosticHint", { fg = ui.text_dim })
  hl(0, "DiagnosticUnderlineError", { sp = editor.error, undercurl = true })
  hl(0, "DiagnosticUnderlineWarn", { sp = editor.warning, undercurl = true })
  hl(0, "DiagnosticUnderlineInfo", { sp = editor.link, undercurl = true })
  hl(0, "DiagnosticUnderlineHint", { sp = ui.text_dim, undercurl = true })

  -- Integrated terminal, identical to the IDE terminal and to kitty
  for i, colour in ipairs(ansi) do
    vim.g["terminal_color_" .. (i - 1)] = colour
  end
end

return M
