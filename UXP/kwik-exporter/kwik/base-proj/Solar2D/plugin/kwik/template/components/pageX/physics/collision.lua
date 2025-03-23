local name = ...
local parent, root = newModule(name)

local M = {
  name = "{{name}}",
  class="collision",
  properties = {
    {{#properties}}
    body          = "{{body}}",
    isRemoveOther = {{isRemoveOther}},
    isRemoveSelf = {{isRemoveSelf}},
    othersGroup  =  require(root.."groups.".."{{othersGroup}}")
    {{/properties}}
  },
  actions = { onCollision="{{onCollision}}" },
}

return require("components.kwik.layer_physicsCollision").set(M)
