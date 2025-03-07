local M = {
  name = "switch",
  class="Switch",
  properties = {
    target = NIL,
    type    = NIL, -- group, page, sprite
    autoPlay=true,
    delay=0,
    duration=100,
    to = NIL,
  },
  layerOptions = {
  },
  fillOptions = {
  },

  actions = {onComplete = nil}
}

return M