local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  properties = {
  {{#properties}}
    target    = "{{target}}",
    startIndex = "{{startIndex}}",
    url =  "{{elURL}}",
    prefix = "{{prefix}}",
    suffix = "{{suffix}}"
    numOfImages= {{numOfImages}}
  {{/properties}}
  },
  action = {
    {{#actions}}
    onCompelete = "{{onComplete}}"
    {{/actions}}
  },
  layerProps = layerProps
}
--
return require("components.kwik.layer_video").set(M)
