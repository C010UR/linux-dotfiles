hl.config({
	gestures = {
		workspace_swipe_distance = 700,
		workspace_swipe_cancel_ratio = 0.15,
		workspace_swipe_min_speed_to_force = 5,
	},
})

-- Multi-finger gestures
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "up", action = "special", arg = "special" })
hl.gesture({
	fingers = 3,
	direction = "down",
	action = function()
		hl.exec_cmd("caelestia toggle specialws")
	end,
})
hl.gesture({
	fingers = 4,
	direction = "down",
	action = function()
		hl.exec_cmd("systemctl suspend-then-hibernate")
	end,
})
