local M = {
  name = "pinch",
  class="pinch",
  properties = {
    target = NIL,
    type   = NIL,
    isActive = true,
    constrainAngle = NIL,
    xStart=NIL, xEnd=NIL, yStart=NIL, yEnd = NIL,
    scaleMax = 3.0,
    scaleMin = 0.2
  },
  actions ={
    onMoved = NIL,
    onEnded = NIL
  }
}

return M