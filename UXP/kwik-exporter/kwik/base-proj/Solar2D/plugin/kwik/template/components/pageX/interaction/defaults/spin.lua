local M = {
  name = "spin0",
  class="spin",
  properties = {
    target = NIL,
    type   = NIL,
    minAngle  = 0,
    maxAngle  = 0,
    isActive = true
  },
  actions={
    onClokwise = NIL,
    onCounterClockwise = NIL,
    onEnded = NIL,
  }
}

return M