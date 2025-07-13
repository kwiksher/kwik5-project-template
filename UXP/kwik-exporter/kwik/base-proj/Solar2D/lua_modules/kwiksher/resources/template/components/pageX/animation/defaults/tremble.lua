local M = {
  name = "tremble0",
  class="Tremble",
  from = nil,
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
    loop=10,
    reverse=true,
    resetAtEnd=false,
    easing=NIL,
    xSwipe=false,
    ySwipe=false,
    useLang = false
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