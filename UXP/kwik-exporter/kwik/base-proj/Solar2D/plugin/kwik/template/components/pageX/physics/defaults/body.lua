local M = {
  name = "",
  class="body",
  properties = {
    bounce = 0,
    density = 0,
    friction = 0,
    gravityScale = 1.0,
    isSensor = false,
    radius = NIL,
    shape   = "circle", -- rect,  path
    type = "static", -- dynamic, kinematic

  },
  dataPath = NIL, -- physicsEdtior(CodeAndWeb)
  dataShape ={}
}

-- M.properties.gravityScale = -1 * M.properties.gravityScale

return M