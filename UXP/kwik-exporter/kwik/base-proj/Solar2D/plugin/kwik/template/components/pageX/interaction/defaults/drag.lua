local M = {
  name = "drag",
  class="drag",
  actions = {
    onDropped = "",
    onReleased ="",
    onMoved= "" },
  properties = {
    target = NIL,
    type  = NIL,
    constrainAngle = NIL,
    isActive = true,
    isFocus = true,
    --
    isFlip = true,
    flipInitialDirection = "right",  -- flipSet.right
    isDrop = true,
    dropArea = "",
    dropAreaMargin = 10,
    --
    boundaries = {xMin=0, xMax=1920, yMin=0, yMax=1080},
    --
    rockingEnable = 1 ,-- 0,
    backToOrigin = true,

  }
}

return M