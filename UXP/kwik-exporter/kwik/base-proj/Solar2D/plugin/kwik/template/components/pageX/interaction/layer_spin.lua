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
    minAngle  = {{minAgnle}},
    maxAngle  = {{maxAngle}}
    {{/properties}}
  },
  --
  actions={
    onClokwise = "{{onClokwise}}",
    onCounterClockwise ="{{onCounterClockwise}}",
    onEnded ="{{onEnded}}",
  },
  --
  layerProps = layerProps
}

function M:create(UI)
  self:setSpin(UI)
end

function M:didShow(UI)
  self:activate(UI)
end

function M:didHide(UI)
  self:deactivate(UI)
end

return require("components.kwik.layer_pinch").set(M)