local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  name = "{{name}}",
  properties = {
    {{#properties}}
    target = "{{target}}",
    mask = "{{mask}}"
    {{/properties}}
  },
  layerProps = layerProps
}

-- function M:didShow(UI)
--   local obj = UI.sceneGroup[self.properties.target]
--   timer.performWithDelay(1000, function()
--     obj.group.maskScaleX = obj.group.maskScaleX * 1.5
--     obj.group.maskScaleY = obj.group.maskScaleY * 1.5
--   end, 5)
-- end

--
return require("components.kwik.layer_mask").set(M)
