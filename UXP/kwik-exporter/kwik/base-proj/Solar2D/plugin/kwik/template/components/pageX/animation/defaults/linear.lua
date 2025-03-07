local M = {
  name = "linear",
  class="Linear",
  from = {
    x = 0,
    y = 0,
    alpha = 0,
    xScale = 1,
    yScale = 1,
    rotation = 0
  },
  to = {
    x = 200,
    y = 0,
    alpha = 1,
    xScale = 1.5,
    yScale = 1.5,
    rotation = 90
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
    easing="inCircular",
    xSwipe=nil,
    ySwipe=nil
  },
  audio = {
    name = "",
    volume = 5,
    channel = 1,
    loop = 1,
    fadeIn = false,
    repeatable = false
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