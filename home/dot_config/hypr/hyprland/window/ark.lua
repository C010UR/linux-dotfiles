-- Ark scratchpad.
--
-- Ark shares Dolphin's special:dolphin. Any number of archive windows is
-- allowed, so each floats and is offset from the previous one. Window rules
-- cannot see other windows, so that offset happens on window.open.

local compat = require("hyprland.window.compat")
local dolphin = require("hyprland.window.dolphin")

local M = {}

local SPECIAL_NAME = dolphin.special
local CLASS = "org.kde.ark"
local MAIN_TITLE = "^(.* (—|–|-) Ark|Ark)$"
local DIALOG_MAX_SIZE = "(monitor_w*0.75) (monitor_h*0.8)"
local CASCADE_STEP = 36

local function dialog_rule(name, title, size)
  hl.window_rule({
    name = "ark-" .. name,
    match = { class = CLASS, title = title },
    float = true,
    center = true,
    size = size,
    suppress_event = "maximize fullscreen",
  })
end

-- Archive windows, dialogs and the preview viewer all belong to the scratchpad.
hl.window_rule({
  name = "ark-scratchpad",
  workspace = SPECIAL_NAME,
  match = { class = CLASS },
  float = true,
  center = true,
  suppress_event = "maximize fullscreen",
})

hl.window_rule({
  name = "ark-scratchpad-main",
  match = { class = CLASS, title = MAIN_TITLE },
  float = true,
  center = true,
  size = "(monitor_w*0.7) (monitor_h*0.75)",
})

-- Unlisted dialogs and the preview viewer keep their native size, capped so
-- they still fit on screen.
hl.window_rule({
  name = "ark-dialogs",
  match = { class = CLASS, title = "negative:" .. MAIN_TITLE },
  float = true,
  center = true,
  max_size = DIALOG_MAX_SIZE,
  suppress_event = "maximize fullscreen",
})

-- Archive dialogs

dialog_rule("extract", "^Extract$", "1040 760")
dialog_rule("add-files", "^Add Files( to .*)?$", "1040 760")
dialog_rule("open-archive", "^Open Archive$", "1040 760")
dialog_rule("save-copy", "^Save Copy As$", "1040 760")

dialog_rule("create", "^(Create New Archive|Compress to Archive)$", "720 560")
dialog_rule("advanced-options", "^Advanced Options$", "640 480")
dialog_rule("properties", "^Properties for .*", "760 600")

-- Conflicts and confirmations

dialog_rule("file-exists", "^(File Exists|File Already Exists|File Modified)$", "860 640")
dialog_rule("delete", "^Delete Files?$", "560 340")
dialog_rule("folder-into-itself", "^Moving a folder into itself$", "520 300")

-- Information and errors

dialog_rule("password", "^Password$", "480 260")
dialog_rule("corrupt", "^Corrupt archive$", "560 360")
dialog_rule("test-results", "^Test Results$", "560 360")
dialog_rule("cannot-preview", "^Cannot Preview File$", "520 300")
dialog_rule("closing-preview", "^Closing preview$", "460 220")
dialog_rule("messages", "^(Error|Warning|Information|Question|Sorry)$", "560 340")

-- Job progress, titled by Kerfuffle's job descriptions

dialog_rule(
  "progress",
  "^(Loading archive|Extracting.*|Compressing.*|Adding files|Adding comment"
    .. "|Deleting.*|Moving.*|Copying.*|Testing archive)$",
  "640 320"
)

local function is_main(window)
  return window.title == "Ark" or (window.title or ""):match(" Ark$") ~= nil
end

local function main_window_count()
  local count = 0

  for _, window in ipairs(hl.get_windows({ class = CLASS })) do
    if is_main(window) then
      count = count + 1
    end
  end

  return count
end

-- A second archive window would land exactly on the first, so step it down and
-- to the right. Dialogs keep the centred position the rules give them.
hl.on("window.open", function(window)
  if not window or window.class ~= CLASS or not is_main(window) then
    return
  end

  -- Let the size and centre rules land before offsetting.
  compat.after(120, function()
    local count = main_window_count()
    if count < 2 then
      return
    end

    local step = math.min(count - 1, 6) * CASCADE_STEP

    hl.dispatch(hl.dsp.window.move({
      x = step,
      y = step,
      relative = true,
      window = compat.address(window),
    }))
  end)
end)

o = o or {}
o.ark = M

return M
