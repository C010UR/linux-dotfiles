-- Curves
hl.curve("specialWorkSwitch", { type = "bezier", points = { {0.05, 0.7}, {0.1,  1.0 } } })
hl.curve("emphasizedAccel",   { type = "bezier", points = { {0.3,  0.0}, {0.8,  0.15} } })
hl.curve("emphasizedDecel",   { type = "bezier", points = { {0.05, 0.7}, {0.1,  1.0 } } })
hl.curve("standard",          { type = "bezier", points = { {0.2,  0.0}, {0.0,  1.0 } } })

-- Layers
hl.animation({ leaf = "layersIn",   speed = 5, bezier = "emphasizedDecel", style = "slide" })
hl.animation({ leaf = "layersOut",  speed = 4, bezier = "emphasizedAccel", style = "slide" })
hl.animation({ leaf = "fadeLayers", speed = 5, bezier = "standard" })

-- Windows
hl.animation({ leaf = "windowsIn",   speed = 5, bezier = "emphasizedDecel" })
hl.animation({ leaf = "windowsOut",  speed = 3, bezier = "emphasizedAccel" })
hl.animation({ leaf = "windowsMove", speed = 6, bezier = "standard" })

-- Workspaces
hl.animation({ leaf = "workspaces",       speed = 5, bezier = "standard" })
hl.animation({ leaf = "specialWorkspace", speed = 4, bezier = "specialWorkSwitch", style = "slidefadevert 15%" })

-- Fades & border
hl.animation({ leaf = "fade",    speed = 6, bezier = "standard" })
hl.animation({ leaf = "fadeDim", speed = 6, bezier = "standard" })
hl.animation({ leaf = "border",  speed = 6, bezier = "standard" })
