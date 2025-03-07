local M = {
  name = "physics",
  class="page",
  -- actionName = "",
  properties = {
    orientation = "landscapeLeft",
    -- orientation= "portraitUpsideDown" "landscapeLeft"
    invert = false,
    scale = 1,
    gravityX = 0,
    gravityY = 0,
    drawMode = "hybrid", -- "hybrid" -- normal, debug
  }
}
M.walls = {
  }

return require("components.kwik.page_physics").set(M)
