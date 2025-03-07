local M = {
  name = "prpoerties",
  class="layer",
  -- actionName = "",
  properties = {
    blendMode = NIL,
    height    = NIL,
    width     = NIL ,
    kind      = nil,
    name      = nil,
    type      = nil,
    x         = NIL,
    y         = NIL,
    alpha     = NIL,
    --
    align       = NIL,
    randXStart  = NIL,
    randXEnd    = NIL,
    randYStart  = NIL,
    randYEnd    = NIL,
    --,
    xScale     = NIL,
    yScale     = NIL,
    rotation   = NIL,
    --,
    layerAsBg     = false,
    isSharedAsset = false,
    ---
    color = nil,
    text = nil,
    font = nil,
    fontSize = nil,
    ---
    infinity = {
      enabled = false,
      speed = 1,
      distance = 0,
      direction = "right",
    },
      ---
    imagePath   = nil,
    imageHeight = nil,
    imageWidth  = nil
  },
}

return M