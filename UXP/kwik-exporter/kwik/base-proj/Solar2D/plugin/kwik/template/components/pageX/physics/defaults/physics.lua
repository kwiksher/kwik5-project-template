local M = {
  name = "physics",
  class="page",
  -- actionName = "",
  properties = {
    orientation = "landscapeLeft",
    -- orientation= "portraitUpsideDown"
    invert = false,
    scale = 1,
    gravityX = 0,
    gravityY = 9.8,
    drawMode = "hybrid", -- normal, debug
    walls = {top=false, bottom=true, left=false, right=false}
},
}

return M