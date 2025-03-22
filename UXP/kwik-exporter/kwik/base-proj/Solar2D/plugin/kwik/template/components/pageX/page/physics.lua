local M = {
  name = "physics",
  class="page",
  -- actionName = "",
  properties = {
    {{#properties}}
    orientation = "{{orientation}}",
    -- orientation= "portraitUpsideDown" "landscapeLeft"
    invert = {{invert}},
    scale = {{scale}},
    gravityX = {{gravityX}},
    gravityY = {{gravityY}},
    drawMode = "{{drawMode}}", -- "hybrid" -- normal, debug
   {{/properties}}
  }
}

M.walls = {
  {{#walls}}
  top={{top}}, bottom={{bottom}}, left={{left}}, right={{right}} }
  {{/walls}}
}

return M