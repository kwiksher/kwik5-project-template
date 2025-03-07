local name = ...
local parent,root = newModule(name)
--
-- see pageX/layer/layer_text.lua
--
local M = {
  name = "{{layer}}", -- {{name}}
  class = "dynamictext",
  properties = {
    {{#properties}}
    variable = "{{variable}}",
    type     = "{{type}}",
    offsetX = {{offsetX}},
    offsetY = {{offsetY}},
    {{#color}}
    color    = { {{r}}, {{g}}, {{b}}, {{a}} },
    {{/color}}
    fontSize = {{fontSize}},
    font = {{font}},
    align = "{{align}}",
    {{/properties}}
  },
}
--
M.layerProps = require(parent.."{{layer}}")
--
M.x = M.layerProps.mX
M.y = M.layerProps.mY


return require("components.kwik.layer_dynamictext").new(M)
