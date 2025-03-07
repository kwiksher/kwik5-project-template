local name = ...
local parent, root = newModule(name)

local M = {
  name = "{{name}}",
  class="collision",
  properties = {
    {{#properties}}
    body          = "{{layer}}",
    isRemoveOther = {{isRemoveOther}},
    isRemoveSelf = {{isRemoveSelf}},
    others  =  "{{others}}"
    {{/properties}}
  },
  actions = {
    {{#actions}}
      onCollision="{{onCollision}}"
    {{/actions}}
  },
}

return require("components.kwik.layer_physicsCollision").set(M)
