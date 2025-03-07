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
    dpx = {{dpx}},
    dpy = {{dpy}},
    {{/properties}}
  },
  --
  actions={
    onBack = "{{onBack}}",
    onForward ="{{onForward}}",
  },
  --
  layerProps = layerProps
}

function M:create(UI)
  self:setParallax(UI)
end

function M:didShow(UI)
  self:activate(UI)
end

function M:didHide(UI)
  self:deactivate(UI)
end

return require("components.kwik.layer_parallax").set(M)