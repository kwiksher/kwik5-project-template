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
    {{/properties}}
  },
  --
  actions={
  {{#actions}}
    onComplete = "{{onComplete}}",
  {{/actions}}
  },
  --
  layerProps = layerProps
}

function M:create(UI)
  self:setShake(UI)
end

function M:didShow(UI)
  self:activate(UI)
end

function M:didHide(UI)
  self:deactivate(UI)
end

return require("components.kwik.layer_shake").set(M)