local v = require("hyprland.vars")

-- Palette roles used by the rest of the Hyprland config.
--
-- Noctalia's "hypr-scheme" template rewrites scheme/noctalia.conf whenever the
-- palette changes. The defaults below are only used before the first render.
local M = {
  primary = "afcbd5",
  onPrimary = "00363f",
  secondary = "bec8cc",
  onSurfaceVariant = "bfc9ca",
  surface = "121414",
  surfaceContainer = "1e2021",
  outline = "899295",
}

function M.rgba(color, alpha)
  return "rgba(" .. color .. alpha .. ")"
end

function M.rgb(color)
  return "rgb(" .. color .. ")"
end

local path = v.get_config_path() .. "/scheme/noctalia.conf"
local file = io.open(path, "r")

if file ~= nil then
  for line in file:lines() do
    local name, hex =
      line:match("^%s*([%w_]+)%s*=%s*([a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9][a-fA-F0-9])%s*$")

    if name and hex and M[name] ~= nil then
      M[name] = hex
    end
  end

  file:close()
end

return M
