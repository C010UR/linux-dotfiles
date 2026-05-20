-- Curves
hl.curve("specialWorkSwitch", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1.0 } } })
hl.curve("emphasizedAccel", { type = "bezier", points = { { 0.3, 0.0 }, { 0.8, 0.15 } } })
hl.curve("emphasizedDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1.0 } } })
hl.curve("standard", { type = "bezier", points = { { 0.2, 0.0 }, { 0.0, 1.0 } } })

-- Layers
hl.animation({ leaf = "layersIn", speed = 5, bezier = "emphasizedDecel", style = "slide", enabled = true })
hl.animation({ leaf = "layersOut", speed = 4, bezier = "emphasizedAccel", style = "slide", enabled = true })
hl.animation({ leaf = "fadeLayers", speed = 5, bezier = "standard", enabled = true })

-- Windows
hl.animation({ leaf = "windowsIn", speed = 5, bezier = "emphasizedDecel", enabled = true })
hl.animation({ leaf = "windowsOut", speed = 3, bezier = "emphasizedAccel", enabled = true })
hl.animation({ leaf = "windowsMove", speed = 6, bezier = "standard", enabled = true })

-- Workspaces
hl.animation({ leaf = "workspaces", speed = 5, bezier = "standard", enabled = true })
hl.animation({
	leaf = "specialWorkspace",
	speed = 4,
	bezier = "specialWorkSwitch",
	style = "slidefadevert 15%",
	enabled = true,
})

-- Fades & border
hl.animation({ leaf = "fade", speed = 6, bezier = "standard", enabled = true })
hl.animation({ leaf = "fadeDim", speed = 6, bezier = "standard", enabled = true })
hl.animation({ leaf = "border", speed = 6, bezier = "standard", enabled = true })
