local M = {
  name = "switch0",
  class="Switch",
  properties = {
    target = NIL,
    type    = NIL, -- group, page, sprite
    autoPlay=true,
    delay=0,
    duration=100,
    loop = 0,
    to = NIL,
    useLang = false
  },
  layerOptions = {
  },
  fillOptions = {
  },

  actions = {onComplete = nil}
}

return M