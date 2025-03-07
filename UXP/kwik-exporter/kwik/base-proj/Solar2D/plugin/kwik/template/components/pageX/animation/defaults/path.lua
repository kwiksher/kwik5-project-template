local M = {
  name = "path",
  class="Path",
  from = {
    alpha = 1,
    xScale = 1,
    yScale = 1,
    rotation = 0
  },
  to = {
    alpha = 1,
    xScale = 1.5,
    yScale = 1.5,
    rotation = 90
  },
  path = {
    filename = NIL,
    autoTurn = true,
    closed = true,
    pause = true,
    newAngle = NIL, -- newAngle:adjustment angle for objects coming from right to left
  },
  properties = {
    target = NIL,
    type    = NIL, -- group, page, sprite
    autoPlay=true,
    delay=0,
    duration=2000,
    loop=1,
    reverse=false,
    resetAtEnd=false,
    easing="inQuad",
    xSwipe=nil,
    ySwipe=nil
  },
  breadcrumbs = {
    enable  = false,
    dispose = true,
    shape = "circle",
    color = {1, 0, 0, 0.2},
    interval = 50,
    time = 1000,
    width = 30,
    height = 30
  },
  layerOptions = {
    -- layerProps
    --
    referencePoint = "Center",
      -- "Center"
      -- "TopLeft"
      -- "TopCenter"
      -- "TopRight"
      -- "CenterLeft"
      -- "CenterRight"
      -- "BottomLeft"
      -- "BottomLeft"
      -- "BottomRight"

    -- for text
    deltaX         = 0,
    deltaY         = 0
  },
  actions = {onComplete = ""}
}

return M