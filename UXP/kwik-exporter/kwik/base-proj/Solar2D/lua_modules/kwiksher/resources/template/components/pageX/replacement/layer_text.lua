local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  name = "{{name}}",
  properties = {
    {{#properties}}
    contents =  "{{contents}}",
    font =  {{font}}, -- "HiraMaruProN-W4",
    fontSize =  {{fontSize}},
    alignment =  "{{alignment}}",
    {{#color}}
    color    = { {{r}}, {{g}}, {{b}}, {{a}} },
    {{/color}}
    orientation = "{{orientation}}",
    scaleX = {{scaleX}},
    scaleY = {{scaleY}},
    paddingX = {{paddingX}},
    paddingY = {{paddingY}},
    alpha = {{alpha}}
    {{/properties}}
  },
  layerProps = layerProps
}
--
return require("components.kwik.layer_text").set(M)
