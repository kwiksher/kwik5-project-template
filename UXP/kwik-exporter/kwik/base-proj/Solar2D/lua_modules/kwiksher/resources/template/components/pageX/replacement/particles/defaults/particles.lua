local M = {
  name = "blink",
  class="Blink",
  from = {
    x = 100,
    y = 100,
    alpha = 0,
    xScale = 1,
    yScale = 1,
    rotation = 0
  },
  to = {
    x = 100,
    y = 100,
    alpha = 1,
    xScale = 1.5,
    yScale = 1.5,
    rotation = 90
  },
  properties = {
    type = NIL,
    autoPlay=true,
    delay=1000,
    duration=3000,
    loop=1,
    reverse=false,
    resetAtEnd=false,
    easing=nil,
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
    dispose = true,
    shape = "",
    color = {1, 0, 1},
    interval = 300,
    time = 2000,
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
  actions = {
    actionName = "",
  }
}

return M