local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local M = {
  name="{{name}}",
  --
  properties = {
    {{#properties}}
    target = "{{layer}}",
    type  = "{{type}}",
    isActive = {{isActive}},
    swipeLength = {{swipeLength}},
    limitAngle = {{limitAngle}},
    useStrictBounds = {{useStrictBounds}}
    {{/properties}}
  },
  --
  actions={
  {{#actions}}
    onUp = "{{onUp}}",
    onDown ="{{onDown}}",
    onRight ="{{onRight}}",
    onLeft  = "{{onLeft}}"
  {{/actions}}
  },
  --
  layerProps = layerProps
}

function M:create(UI)
  self:setSwipe(UI)
end

function M:didShow(UI)
  self:activate(UI)
end

function M:didHide(UI)
  self:deactivate(UI)
end

return require("components.kwik.layer_swipe").set(M)