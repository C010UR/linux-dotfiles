-- Window-rule fixes: keep apps and layout behaved, without touching theming.

-- Keep windows from un-maximising themselves behind the layout's back. An app
-- that "maximises" on restore no longer knocks the tiling out of shape.
hl.window_rule({
  name = "suppress-maximize",
  suppress_event = "maximize",
  match = { class = ".*" },
})

-- Browsers: ignore their own size and maximise hints so they always tile.
hl.window_rule({
  name = "chromium-browser-tag",
  tag = "+chromium-browser",
  match = { class = "((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)" },
})
hl.window_rule({
  name = "chromium-browser-tile",
  tile = true,
  match = { tag = "chromium-browser" },
})
hl.window_rule({
  name = "firefox-browser-tag",
  tag = "+firefox-browser",
  match = { class = "([fF]irefox|zen|librewolf)" },
})
hl.window_rule({
  name = "firefox-browser-tile",
  tile = true,
  match = { tag = "firefox-browser" },
})

-- Video, meeting popouts and PiP keep their own floating behaviour.
hl.window_rule({
  name = "browser-video-detag",
  tag = "-chromium-browser",
  match = { class = "^.+-youtube\\.com__.*$|^.+-app\\.zoom\\.us__wc_home.*$|^.+-meet\\.google\\.com__.*$" },
})
hl.window_rule({
  name = "browser-pip-detag",
  tag = "-chromium-browser",
  match = { title = "Picture(-| )in(-| )[Pp]icture" },
})
hl.window_rule({
  name = "browser-share-detag",
  tag = "-chromium-browser",
  match = { title = ".*is sharing your screen.*" },
})

-- Opt-in idle inhibit: tag a window `noidle` and the screen stays awake while
-- it is open.
hl.window_rule({
  name = "noidle-tag",
  idle_inhibit = "always",
  match = { tag = "noidle" },
})

-- Ghostty's own scrollback is slow
hl.window_rule({
  name = "ghostty-scroll",
  scroll_touchpad = 0.2,
  match = { class = "com.mitchellh.ghostty" },
})
