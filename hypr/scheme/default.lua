-- Color palette (Material You dark scheme)
-- Auto-generated from scheme/default.conf
local M = {}

-- Palette key colors
M.primary_paletteKeyColor   = "7171ac"
M.secondary_paletteKeyColor = "76758e"
M.tertiary_paletteKeyColor  = "9e648e"
M.neutral_paletteKeyColor   = "78767b"
M.neutral_variant_paletteKeyColor = "777680"

-- Surface / background roles
M.background              = "131317"
M.onBackground            = "e5e1e7"
M.surface                 = "131317"
M.surfaceDim              = "131317"
M.surfaceBright           = "39393d"
M.surfaceContainerLowest  = "0e0e12"
M.surfaceContainerLow     = "1c1b1f"
M.surfaceContainer        = "201f23"
M.surfaceContainerHigh    = "2a292e"
M.surfaceContainerHighest = "353438"
M.onSurface               = "e5e1e7"
M.surfaceVariant          = "47464f"
M.onSurfaceVariant        = "c8c5d1"
M.inverseSurface          = "e5e1e7"
M.inverseOnSurface        = "313034"
M.outline                 = "918f9a"
M.outlineVariant          = "47464f"
M.shadow                  = "000000"
M.scrim                   = "000000"
M.surfaceTint             = "c2c1ff"

-- Primary
M.primary                 = "c2c1ff"
M.onPrimary               = "2a2a60"
M.primaryContainer        = "7171ac"
M.onPrimaryContainer      = "ffffff"
M.inversePrimary          = "595992"
M.primaryFixed            = "e2dfff"
M.primaryFixedDim         = "c2c1ff"
M.onPrimaryFixed          = "14134a"
M.onPrimaryFixedVariant   = "414178"

-- Secondary
M.secondary               = "c6c4e0"
M.onSecondary             = "2e2e44"
M.secondaryContainer      = "45455c"
M.onSecondaryContainer    = "b4b2ce"
M.secondaryFixed          = "e2e0fd"
M.secondaryFixedDim       = "c6c4e0"
M.onSecondaryFixed        = "19192e"
M.onSecondaryFixedVariant = "45455c"

-- Tertiary
M.tertiary                = "f5b2e0"
M.onTertiary              = "4e1e44"
M.tertiaryContainer       = "bb7da9"
M.onTertiaryContainer     = "000000"
M.tertiaryFixed           = "ffd7f0"
M.tertiaryFixedDim        = "f5b2e0"
M.onTertiaryFixed         = "35082e"
M.onTertiaryFixedVariant  = "68355c"

-- Error
M.error                   = "ffb4ab"
M.onError                 = "690005"
M.errorContainer          = "93000a"
M.onErrorContainer        = "ffdad6"

-- Success (custom)
M.success                 = "B5CCBA"
M.onSuccess               = "213528"
M.successContainer        = "374B3E"
M.onSuccessContainer      = "D1E9D6"

-- Terminal palette (term0–term15)
M.term0  = "353434"
M.term1  = "ac73ff"
M.term2  = "44def5"
M.term3  = "ffdcf2"
M.term4  = "99aad8"
M.term5  = "b49fea"
M.term6  = "9dceff"
M.term7  = "e8d3de"
M.term8  = "ac9fa9"
M.term9  = "c093ff"
M.term10 = "89ecff"
M.term11 = "fff0f6"
M.term12 = "b5c1dd"
M.term13 = "c9b5f4"
M.term14 = "bae0ff"
M.term15 = "ffffff"

-- Catppuccin-mapped aliases (used throughout configs)
M.rosewater = "f7eff9"
M.flamingo  = "e9def3"
M.pink      = "e2d7ff"
M.mauve     = "bfb8ff"
M.red       = "c1a5fd"
M.maroon    = "c9b5ed"
M.peach     = "e0c2f9"
M.yellow    = "ffecf3"
M.green     = "c8e3ff"
M.teal      = "d3dfff"
M.sky       = "d0daff"
M.sapphire  = "b7c5ff"
M.blue      = "b0b8ff"
M.lavender  = "c7c8ff"
M.text      = "e5e1e7"
M.subtext1  = "c8c5d1"
M.subtext0  = "918f9a"
M.overlay2  = "7e7c86"
M.overlay1  = "6b6972"
M.overlay0  = "595860"
M.surface2  = "48474e"
M.surface1  = "37373d"
M.surface0  = "25252a"
M.base      = "131317"
M.mantle    = "131317"
M.crust     = "121216"

-- Helper: wrap a 6-hex-digit color + 2-digit alpha as rgba(xxxxxxyy)
function M.rgba(color, alpha)
  return "rgba(" .. color .. alpha .. ")"
end

-- Helper: wrap a 6-hex-digit color as rgb(xxxxxx)
function M.rgb(color)
  return "rgb(" .. color .. ")"
end

return M
