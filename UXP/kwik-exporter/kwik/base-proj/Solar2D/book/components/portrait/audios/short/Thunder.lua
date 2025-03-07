local props = {
  name     = "",
  type     = "",
  properties = {
    autoPlay = false,
    channel  = 0,
    delay    = 0,
    filename = "",
    folder   = "short",
    loops    = 0, -- 1 + 3 = 4 times
  }
}
local M = {
  -- name        = ,
  -- type        = ,
  -- language    = nil  -- or {"en", "jp"},
  -- filename    = "",
  -- folder      = nil
  -- allowRepeat = false,
  -- autoPlay    = ,
  -- deplay      = ,
  -- volume      = ,
  -- channel     =
  -- loops       = ,
  -- fadein      = ,
  -- retain      =
  }
-- you can play it with UI.audios[self.name]:play()
return require("components.kwik.page_audio").set(props)
