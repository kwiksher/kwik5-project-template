local M = {
  name     = "{{name}}",
  type     = "{{type}}", -- "global", "recorded"
  properties = {
    {{#properties}}
    autoPlay = {{autoPlay}},
    channel  = {{channel}},
    delay    = {{delay}},
    fadein   = {{fadein}},
    filename = "{{filename}}",
    folder   = "{{folder}}",
    loops    = {{loops}}, -- 1 + 3 = 4 times
    volume   = {{volume}}
    {{/properties}}
  }
}

  -- name        = {{aname}},
  -- type        = {{atype}},
  -- language    = nil  -- or {"en", "jp"},
  -- filename    = "{{fileName}}",
  -- folder      = nil
  -- autoPlay    = {{aplay}},
  -- deplay      = {{adelay}},
  -- volume      = {{avol}},
  -- channel     = {{achannel}}
  -- loops       = {{aloop}},
  -- fadein      = {{tofade}},
  -- retain      = {{akeep}}

M.actions = { onComplete = "{{actionName}}" }

-- you can play it with UI.audios[self.name]:play()

return require("components.kwik.page_audio").set(M)