
local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  name = "article",
  properties = {
    {{#properties}}
    text =  "{{text}}",
    inputType = "{{inputType}}",
    font =  {{font}}, -- "HiraMaruProN-W4",
    fontSize =  {{fontSize}},
    -- alignment =  "{{alignment}}",
    {{#color}}
    color    = { {{r}}, {{g}}, {{b}}, {{a}} },
    {{/color}}
    paddingX = {{paddingX}},
    paddingY = {{paddingY}},
    variable = "{{variable}}",
    dynamicText = "{{dynamicText}}"
    {{/properties}}
  },
  layerProps = layerProps
}
--
return require("components.kwik.layer_textinput").set(M)
