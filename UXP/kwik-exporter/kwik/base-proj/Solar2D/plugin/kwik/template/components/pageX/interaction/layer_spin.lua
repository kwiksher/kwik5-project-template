local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

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
  {{#actions}}
    onClokwise = "{{onClokwise}}",
    onCounterClockwise ="{{onCounterClockwise}}",
    onEnded ="{{onEnded}}",
  {{/actions}}
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

return require("components.kwik.layer_spin").set(M)