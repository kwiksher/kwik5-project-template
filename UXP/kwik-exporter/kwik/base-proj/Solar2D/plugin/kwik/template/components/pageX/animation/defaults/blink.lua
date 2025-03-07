local M = {
  name = "blink0",
  class="Blink",
  from = {
    x = nil,
    y = nil,
    alpha = nil,
    xScale = nil,
    yScale = nil,
    rotation = nil
  },
  to = {
    x = nil,
    y = nil,
    alpha = 1,
    xScale = 1,
    yScale = 0.1,
    rotation = 0
  },
  properties = {
    target = NIL,
    type    = NIL, -- group, page, sprite
    autoPlay=true,
    delay = 1000,
    duration=500,
    loop=3,
    reverse=false,
    resetAtEnd=false,
    xSwipe=false,
    ySwipe=false,
    easing   = "inOutBack",
  -- 'Linear'
  -- 'inOutExpo'
  -- 'inExpo'
  -- 'outExpo'
  -- 'inOutQuad'
  -- 'outQuad'
  -- 'inQuad'
  -- 'inBounce'
  -- 'outBounce'
  -- 'inOutBounce'
  -- 'inElastic'
  -- 'outElastic'
  -- 'inOutElastic'
  -- 'inBack'
  -- 'outBack'
  -- 'inOutBack'
  ------------
    useLang = false
  },
  breadcrumbs = nil,
  layerOptions = {
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
  actions = {onComplete = NIL}
}

return M