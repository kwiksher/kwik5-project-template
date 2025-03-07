local M = {
  name = "swipe",
  class="swipe",
  properties = {
    target = NIL,
    type   = NIL,
    isActive = true,
    swipeLength = 120,
    limitAngle = NIL,
    useStrictBounds = false
  },
  actions={
    onUp = NIL,
    onDown = NIL,
    onRight = NIL,
    onLeft  = NIL,
  },
}

return M