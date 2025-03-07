local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  name ="{{name}}",
  class = "{{class}}", -- spritesheet
  properties = {
    {{#properties}}
    target = "{{target}}",
    isBackgroud  = {{isBackground}},
    type = "{{type}}",
    {{#color}}
    color    = { {{r}}, {{g}}, {{b}}, {{a}} },
    {{/color}}
    {{/properties}}
  },
  layerProps = layerProps
}--
--
return require("components.kwik.layer_vector").set(M)
