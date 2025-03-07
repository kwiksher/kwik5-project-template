local M = {
  name = "",
  class="body",
  properties = {
    bounce = 1,
    density = 1,
    friction = 1,
    gravityScale = 1.0,
    isFixedRotation = false,
    isSensor = false,
    radius = 0,  -- 0 means use object width/2 if cirlce is selected
    shape   = "rectangle", -- circle, rectangle,  path
    type = "dynamic", -- static, -- dynamic, kinematic

  },
  dataPath = NIL, -- physicsEdtior(CodeAndWeb)
  dataShape ={}
}

-- M.properties.gravityScale = -1 * M.properties.gravityScale

return M