-- VM keyboard passthrough.
--
-- QEMU's GTK UI is built against GTK3, whose Wayland backend cannot ask the
-- compositor to inhibit shortcuts. So even with QEMU's keyboard grabbed,
-- Hyprland sees SUPER first and runs the host bind instead of sending it to the
-- guest. While a QEMU window is focused we therefore switch to a submap whose
-- only bind is a non-consuming catchall: Hyprland matches nothing, and every
-- key (SUPER chords included) is forwarded to the focused window.
--
-- Leave passthrough with CTRL+SHIFT+Escape, or just focus a non-VM window.
-- Toggle it manually any time with CTRL+ALT+SHIFT+V.

local VM_CLASSES = {
  qemu = true,
  QEMU = true,
}

local function is_vm(window)
  return window ~= nil and VM_CLASSES[window.class] == true
end

local function in_passthrough()
  return hl.get_current_submap() == "vm_passthrough"
end

hl.define_submap("vm_passthrough", function()
  -- Matches every key without consuming it, so the guest receives everything.
  hl.bind("catchall", hl.dsp.no_op(), { non_consuming = true })
  -- Consuming escape hatch: this one does NOT reach the guest.
  hl.bind("CTRL + SHIFT + Escape", hl.dsp.submap("reset"))
end)

hl.bind("CTRL + ALT + SHIFT + V", function()
  if in_passthrough() then
    hl.dispatch(hl.dsp.submap("reset"))
  else
    hl.dispatch(hl.dsp.submap("vm_passthrough"))
  end
end, { submap_universal = true, description = "VM keyboard passthrough" })

hl.on("window.active", function(window)
  if is_vm(window) then
    hl.dispatch(hl.dsp.submap("vm_passthrough"))
  elseif in_passthrough() then
    hl.dispatch(hl.dsp.submap("reset"))
  end
end)
