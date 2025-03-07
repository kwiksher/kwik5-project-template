local M = {
  name = "{{layer}}",
  class="body",
  dataPath = NIL, -- physicsEdtior(CodeAndWeb)
  dataShape ={}
}

{{#invert}}
M.properties.gravityScale = -1 * M.properties.gravityScale
{{/invert}}

function M:create(UI)
  local {{layer}} = UI.sceneGroup["{{layer}}"]
  self.properties = {
  {{#properties}}
      bounce = {{bounce}},
      density = {{density}},
      friction = {{friction}},
      gravityScale = {{gravityScale}},
      isSensor = {{isSensor}},
      radius = {{radius}}, -- NIL means use object width/2
      shape   =" {{shape}}", -- "circle", -- rect,  path
      type = "{{type}}",
   {{/properties}}
  }

end

return require("components.kwik.layer_physicsBody").set(M)
