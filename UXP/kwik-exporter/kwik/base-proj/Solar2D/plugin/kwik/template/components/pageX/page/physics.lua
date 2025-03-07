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
    {{#walls}}
    walls = {
      top={{top}}, bottom={{bottom}}, left={{left}}, right={{right}}
    }
    {{/walls}}
   {{/properties}}
  }
}

-- M.walls = {
-- }

return require("components.kwik.page_physics").set(M)
