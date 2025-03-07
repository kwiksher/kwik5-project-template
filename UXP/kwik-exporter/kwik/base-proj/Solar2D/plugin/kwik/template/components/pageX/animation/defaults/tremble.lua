local M = {
  name = "tremble",
  class="Tremble",
  from = {
    x = nil,
    y = nil,
    alpha = 1,
    duration = 1000,
    xScale = 1,
    yScale = 1,
    rotation = 0
  },
  to = {
    x = nil,
    y = nil,
    alpha = 1,
    duration = 2000,
    xScale = 1,
    yScale = 1,
    rotation = 15
  },
  properties = {
    target = NIL,
    type    = NIL, -- group, page, sprite
    autoPlay=true,
    delay=0,
    duration=100,
    loop=3,
    reverse=false,
    resetAtEnd=false,
    easing=NIL,
    xSwipe=nil,
    ySwipe=nil
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