-- Per-window utilities: transparency, gaps and square-aspect toggles, plus
-- re-centring of popped-out windows after a move.

local compat = require("hyprland.window.compat")

local M = {}
local gaps_saved = nil
local aspect_on = false

-- Tag-based so the opacity survives reloads and follows the window.
hl.window_rule({
  name = "hypr-transparent",
  opacity = "0.97 0.94",
  match = { tag = "hypr-transparent" },
})

local function active()
  return hl.get_active_window()
end

function M.toggle_transparency()
  local window = active()
  if not window then
    return
  end

  local on = false
  for _, tag in ipairs(window.tags or {}) do
    if tag == "hypr-transparent" then
      on = true
    end
  end

  hl.dispatch(hl.dsp.window.tag({
    tag = (on and "-" or "+") .. "hypr-transparent",
    window = compat.address(window),
  }))
end

local function read_gaps(option, fallback)
  local value = hl.get_config(option)

  if type(value) == "table" then
    return {
      top = value.top or fallback.top,
      right = value.right or fallback.right,
      bottom = value.bottom or fallback.bottom,
      left = value.left or fallback.left,
    }
  end

  if type(value) == "number" then
    return { top = value, right = value, bottom = value, left = value }
  end

  return fallback
end

local function read_int(option, fallback)
  local value = hl.get_config(option)
  return type(value) == "number" and value or fallback
end

function M.toggle_gaps()
  local gaps_in = read_gaps("general.gaps_in", { top = 2, right = 2, bottom = 2, left = 2 })
  local gaps_out = read_gaps("general.gaps_out", { top = 5, right = 5, bottom = 5, left = 7 })
  local border = read_int("general.border_size", 2)

  if gaps_in.top + gaps_out.top + border > 0 then
    gaps_saved = { gaps_in = gaps_in, gaps_out = gaps_out, border = border }
    hl.config({ general = { gaps_in = 0, gaps_out = 0, border_size = 0 } })
  else
    local saved = gaps_saved or {
      gaps_in = { top = 2, right = 2, bottom = 2, left = 2 },
      gaps_out = { top = 5, right = 5, bottom = 5, left = 7 },
      border = 2,
    }
    hl.config({
      general = {
        gaps_in = saved.gaps_in.top,
        gaps_out = saved.gaps_out,
        border_size = saved.border,
      },
    })
  end
end

function M.toggle_aspect()
  aspect_on = not aspect_on
  hl.config({
    layout = {
      single_window_aspect_ratio = aspect_on and { 1, 1 } or { 0, 0 },
    },
  })
end

-- Hyprland moves a floating window to another monitor at the same offset from
-- its origin, so a popped-out window would land off-centre or off a smaller
-- screen. The move is still being committed when the event fires, so wait a
-- loop before centring.
hl.on("window.move_to_workspace", function(window)
  if not window then
    return
  end

  local popped = false
  for _, tag in ipairs(window.tags or {}) do
    if tag == "pop" then
      popped = true
    end
  end

  if not popped then
    return
  end

  compat.after(1, function()
    hl.dispatch(hl.dsp.window.center({ window = compat.address(window) }))
  end)
end)

o = o or {}
o.window_tools = M

return M
