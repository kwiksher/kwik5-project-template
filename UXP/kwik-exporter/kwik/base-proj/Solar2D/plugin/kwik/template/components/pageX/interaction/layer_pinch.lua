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
    constrainAngle = {{constrainAngle}},
    xStart={{xStart}}, yStart={{eEnd}}, yStart={{yStart}}, yEnd = {{yEnd}},
    min = {{min}},
    max = {{max}}
    {{/properties}}
  },
  --
  actions={
    onEnded ="{{onEnded}}",
    onMoved="{{onMoved}}"
  },
  --
  layerProps = layerProps
}

function M:create(UI)
  self:setPinch(UI)
end

function M:didShow(UI)
  self:activate(UI)
end

function M:didHide(UI)
  self:deactivate(UI)
end

return require("components.kwik.layer_pinch").set(M)