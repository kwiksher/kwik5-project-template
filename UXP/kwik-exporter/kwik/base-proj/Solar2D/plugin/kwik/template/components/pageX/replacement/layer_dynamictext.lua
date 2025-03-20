local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}
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
    paddingX = {{paddingX}},
    paddingY = {{paddingY}},
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
M.layerProps = layerProps
--
return require("components.kwik.layer_dynamictext").new(M)
