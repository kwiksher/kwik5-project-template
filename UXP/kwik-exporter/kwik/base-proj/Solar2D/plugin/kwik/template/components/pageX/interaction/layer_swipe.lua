local name = ...
local parent,root = newModule(name)

local layerProps = require(parent.."{{layer}}").properties

local M = {
  name="{{name}}",
  --
  properties = {
    {{#properties}}
    target = "{{layer}}",
    type  = "{{type}}",
    isActive = "{{isActive}}",
    swipeLength = {{swipeLength}},
    limitAngle = {{limitAngle}},
    useStrictBounds = {{useStrictBounds}}}
    {{/properties}}
  },
  --
  actions={
    onUp = "{{onUp}}",
    onDown ="{{onDown}}",
    onRight ="{{onRight}}",
    onLeft  = "{{onLeft}}"
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