local M = {
  name = "pulse",
  class="Pulse",
  from = {
    x = nil,
    y = nil,
    alpha = 0,
    xScale = 1,
    yScale = 1,
    rotation = 0
  },
  to = {
    x = nil,
    y = nil,
    alpha = 1,
    xScale = 1.5,
    yScale = 1.5,
    rotation = 180
  },
  properties = {
    target = NIL,
    type    = NIL, -- group, page, sprite
    autoPlay=true,
    delay=0,
    duration=500,
    loop=5,
    reverse=false,
    resetAtEnd=false,
    easing="outCirc",
    xSwipe=nil,
    ySwipe=nil
  },
  breadcrumbs = nil,
  layerOptions = {
    -- layerProps
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
  actions = {onComplete = nil}
}

return M