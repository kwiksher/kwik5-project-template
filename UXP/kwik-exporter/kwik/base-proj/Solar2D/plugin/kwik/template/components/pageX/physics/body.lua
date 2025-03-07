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
      target = "{[layer]}",
      bounce = {{bounce}},
      density = {{density}},
      friction = {{friction}},
      gravityScale = {{gravityScale}},
      isFixedRotation = {{isFixedRotation}},
      isSensor = {{isSensor}},
      radius = {{radius}}, -- 0 means use object width/2 if cirlce is selected
      shape   ="{{shape}}", -- "circle", -- rectangle,  path
      type = "{{type}}", -- kinematic, static, dynamic
   {{/properties}}
  }
  self:_create(UI)
end

return require("components.kwik.layer_physicsBody").set(M)
