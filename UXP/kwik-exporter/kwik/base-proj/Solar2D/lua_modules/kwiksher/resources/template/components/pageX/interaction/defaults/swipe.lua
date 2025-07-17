local M = {
  name = "swipe0",
  class="swipe",
  properties = {
    target = NIL,
    type   = NIL,
    isActive = true,
    swipeLength = 120/4,
    limitAngle = 30,
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