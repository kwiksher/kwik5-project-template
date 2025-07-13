local M = {
  name = "bounce0",
  class="Bounce",
  from = nil,
  to = {
    x = nil,
    y = -100,
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
    duration=500,
    loop=2,
    reverse=true,
    resetAtEnd=false,
    easing="outCirc",
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