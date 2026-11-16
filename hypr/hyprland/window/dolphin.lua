-- Dolphin scratchpad.
--
-- One Dolphin window lives on special:dolphin. SUPER + E reuses it instead of
-- starting another, and closing the window closes the special workspace
-- (misc.close_special_on_empty). Ark shares the workspace.

local compat = require("hyprland.window.compat")

local M = {}

local SPECIAL = "dolphin"
local SPECIAL_NAME = "special:" .. SPECIAL
local CLASS = "org.kde.dolphin"

local LAUNCH_CMD = "app2unit -t scope -- dolphin"
local LAUNCH_TIMEOUT = 8000

-- Rules full-match the title, so the pattern has to cover the whole string:
-- "Downloads — Dolphin", a bare "Dolphin", and paths used as titles.
local MAIN_TITLE = "^(.* (—|–|-) Dolphin|Dolphin|/.*)$"
local DIALOG_MAX_SIZE = "(monitor_w*0.75) (monitor_h*0.8)"

local launching = false

local function dialog_rule(name, title, size)
  hl.window_rule({
    name = "dolphin-" .. name,
    match = { class = CLASS, title = title },
    float = true,
    center = true,
    size = size,
    suppress_event = "maximize fullscreen",
  })
end

-- Everything Dolphin opens -- the file manager, dialogs, folders handed to it
-- from elsewhere -- belongs to the floating scratchpad.
hl.window_rule({
  name = "dolphin-scratchpad",
  workspace = SPECIAL_NAME,
  match = { class = CLASS },
  float = true,
  center = true,
  suppress_event = "maximize fullscreen",
})

hl.window_rule({
  name = "dolphin-scratchpad-main",
  match = { class = CLASS, title = MAIN_TITLE },
  float = true,
  center = true,
  size = "(monitor_w*0.65) (monitor_h*0.7)",
})

-- Unlisted dialogs keep their native size, capped so they still fit on screen.
hl.window_rule({
  name = "dolphin-dialogs",
  match = { class = CLASS, title = "negative:" .. MAIN_TITLE },
  float = true,
  center = true,
  max_size = DIALOG_MAX_SIZE,
  suppress_event = "maximize fullscreen",
})

-- Input and confirmation dialogs

dialog_rule("pattern-input", "^(Select|Unselect)$", "500 260")
dialog_rule("rename-tab", "^Rename Tab$", "500 240")
dialog_rule("hide-item", "^Hide this (File|Folder)\\?$", "560 300")
dialog_rule("change-file-type", "^Change File Type$", "620 360")

dialog_rule("rename-item", "^Rename Item$", "540 300")
dialog_rule("rename-items", "^Rename Items$", "720 500")

dialog_rule("confirmation", "^Confirmation$", "620 380")
dialog_rule("delete-confirmation", "^(Delete Permanently|Move to Trash)$", "720 480")
dialog_rule(
  "admin-warning",
  "^(How to Administrate|Risks of Acting as an Administrator)$",
  "680 480"
)

-- File conflicts

dialog_rule(
  "file-conflict",
  "^(File Already Exists|Folder Already Exists|Already Exists as Folder)$",
  "860 640"
)

-- Properties, Open With and new files

dialog_rule("properties", "^Properties for .*", "840 680")
dialog_rule("open-with", "^(Open With|Choose Application|Choose Application for .*)$", "800 600")
dialog_rule("new-file", "^(Create New .*|Create Symlink|Create link to URL)$", "660 480")
dialog_rule("new-file-error", "^Sorry$", "540 320")

-- Settings and view properties

dialog_rule("settings", "^Configure$", "1060 780")
dialog_rule("shortcuts", "^Configure Keyboard Shortcuts$", "900 700")
dialog_rule("view-display", "^View Display Style$", "740 600")
dialog_rule("view-progress", "^Applying View Properties$", "500 240")

-- Bookmarks, places and service downloads

dialog_rule("bookmarks", "^(Edit Bookmarks|Add Places Entry|Edit Places Entry)$", "760 580")
dialog_rule(
  "new-stuff",
  "^(Download New Services.*|Get Hot New Stuff.*|Download New .*)$",
  "900 700"
)

-- Authentication, certificates and permissions

dialog_rule(
  "auth",
  "^(Server Authentication|Authentication Dialog|Retry Authentication|SSL)$",
  "680 440"
)
dialog_rule("ssl-info", "^KDE SSL Information$", "800 640")
dialog_rule(
  "permissions",
  "^(Advanced Permissions|Edit ACL Entry|Advanced Options for .*)$",
  "740 560"
)

-- Progress

dialog_rule(
  "progress",
  "^(Progress Dialog|Copying.*|Moving.*|Deleting.*|Renaming.*|Creating directory.*"
    .. "|Examining.*|Transferring.*|Mounting.*|Unmounting.*)$",
  "740 360"
)
dialog_rule("system-config", "^Updating System Configuration$", "500 220")

-- File pickers

dialog_rule(
  "file-picker",
  "^(Open|Open File|Open Files|Open Folder|Open Folders|Select File|Select Files"
    .. "|Select Folder|Select Folders|Library)$",
  "900 700"
)

local function dolphin_windows()
  return hl.get_windows({ class = CLASS })
end

local function special_visible()
  local workspace = hl.get_active_special_workspace()
  return workspace ~= nil and workspace.name == SPECIAL_NAME
end

local function on_special(window)
  local workspace = window.workspace
  return workspace ~= nil and workspace.name == SPECIAL_NAME
end

local function reveal()
  if #dolphin_windows() == 0 then
    return
  end

  -- Focusing the special opens it when hidden and does nothing when visible.
  hl.dispatch(hl.dsp.focus({ workspace = SPECIAL_NAME }))
end

local function launch()
  if launching then
    return
  end

  launching = true
  hl.dispatch(hl.dsp.exec_cmd(LAUNCH_CMD))

  -- Don't leave the keybind stuck if Dolphin never maps.
  compat.after(LAUNCH_TIMEOUT, function()
    launching = false
  end)
end

function M.toggle()
  local windows = dolphin_windows()

  if #windows == 0 then
    launch()
    return
  end

  if special_visible() then
    hl.dispatch(hl.dsp.workspace.toggle_special(SPECIAL))
    return
  end

  -- A Dolphin window dragged to a normal workspace comes home the next time
  -- the scratchpad is opened.
  for _, window in ipairs(windows) do
    if not on_special(window) then
      hl.dispatch(hl.dsp.window.move({
        workspace = SPECIAL_NAME,
        window = compat.address(window),
      }))
    end
  end

  hl.dispatch(hl.dsp.focus({ workspace = SPECIAL_NAME }))
end

-- The rule moves Dolphin to the hidden special, so reveal it once it has
-- mapped. The second pass covers a slow first map.
hl.on("window.open", function(window)
  if not window or window.class ~= CLASS then
    return
  end

  launching = false

  compat.after(1, reveal)
  compat.after(250, reveal)
end)

M.special = SPECIAL_NAME

o = o or {}
o.dolphin = M

return M
