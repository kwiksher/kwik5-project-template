local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  name="{{name}}",
  --
  properties = {
    {{#properties}}
    target = "{{layer}}",
    contents  = "{{contents}}",
    type  = "{{type}}",
    isActive = "{{isActive}}",
    area = "{{area}}",
    hideBackGround = {{hideBackGround}},
    horizontalScrollDisabled = {{horizontalScrollDisabled}},
    verticalScrollDisabled = {{verticalScrollDisabled}},
    positionX = {{positionX}},
    positionY = {{positionY}},
    width = {{width}}/4,
    height   = {{height}}/4,
    {{/properties}}
  },
  --
  actions={},
  --
  layerProps = layerProps
}

function M:create(UI)
end

function M:didShow(UI)
  self:setScroll(UI)
end

function M:didHide(UI)
end

return require("components.kwik.layer_scroll").set(M)