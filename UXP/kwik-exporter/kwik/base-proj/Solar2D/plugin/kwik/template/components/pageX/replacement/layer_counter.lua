local parent, root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  name = "{{layer}}",
  properties = {
    {{#properties}}
    target = "{{target}}",
    countValue = {{countValue}},
    font = "{{font}}", -- "HiraMaruProN-W4",
    fontSize = {{fontSize}},
    alignment = "{{alignment}}",
    {{#color}}
    color    = { {{r}}, {{g}}, {{b}}, {{a}} },
    {{/color}}
    orientation = "{{orientation}}",
    scaleX = {{scaleX}},
    scaleY = {{scaleY}},
    paddingX = {{paddingX}},
    paddingY = {{paddingY}},
    alpha = {{alpha}},
    autoPlay = {{autoPlay}}
    {{/properties}}
  },
  actions = {
    onComplete = "{{onComplete}}"
  },
  layerProps = layerProps
}
--
return require("components.kwik.layer_counter").set(M)
