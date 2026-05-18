local M = {
  name = "audio0",
  class="audio",
  type = "short",
  properties = {
    autoPlay=false,
    channel = 1,
    delay=0,
    file = "",
    fadein = false,
    folder="",
    loops = 0,
    volume = 8
  }
}

M.actions = { onComplete = "" }

return M