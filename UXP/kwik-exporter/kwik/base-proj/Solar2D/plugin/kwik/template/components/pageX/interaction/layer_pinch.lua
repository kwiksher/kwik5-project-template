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
    constrainAngle = {{constrainAngle}},
    xStart={{xStart}},
    yStart={{yStart}},
    yStart={{yStart}},
    yEnd = {{yEnd}},
    scaleMin = {{scaleMin}},
    scaleMax = {{scaleMax}}
    {{/properties}}
  },
  --
  actions={
  {{#actions}}
    onEnded ="{{onEnded}}",
    onMoved="{{onMoved}}"
  {{/actions}}
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