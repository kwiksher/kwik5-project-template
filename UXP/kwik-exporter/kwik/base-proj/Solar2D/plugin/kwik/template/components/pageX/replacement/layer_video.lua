local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  properties = {
    {{#properties}}
    target = "{{target}}",
    loop     = "{{loop}}",
    rewind   = "{{rewind}}",
    isLocal  = "{{isLocal}}",
    url      = "{{url}}",
    autoPlay = "{{autoPlay}}",
    {{/properties}}
  },
  actions = {
    {{#actions}}
    onCompelete = "{{onComplete}}"
    {{/actions}}
  },
  layerProps = layerProps
}
--
M.singleNames = {"PagePrevM", "PageNextM"}
--
M.x = layerProps.x
M.y = layerProps.y
--
return require("components.kwik.layer_video").set(M)
