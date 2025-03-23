local M = {
  name = "rotation",
  class="Rotation",
  from = {
    x = nil,
    y = nil,
    alpha = 1,
    xScale = 1,
    yScale = 1,
    rotation = 0
  },
  to = {
    x = nil,
    y = nil,
    alpha = 1,
    xScale = 1,
    yScale = 1,
    rotation = 360
  },
  properties = {
    target = NIL,
    type    = NIL, -- group, page, sprite
    autoPlay=true,
    delay=0,
    duration=1000,
    loop=1,
    reverse=false,
    resetAtEnd=false,
    easing="outCirc",
    xSwipe=nil,
    ySwipe=nil,
    anchorPoint = "Center",
  },
  breadcrumbs = nil,
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
  actions = {onComplete = nil}
}

return M