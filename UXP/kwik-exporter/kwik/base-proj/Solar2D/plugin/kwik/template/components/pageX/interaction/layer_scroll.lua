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
    {{/properties}}
  },
  --
  actions={},
  --
  layerProps = layerProps
}

if M.properties.area == "paragraph" then
  M.properties.width  = {{width}}/4
end

if M.properties.area == "object" then
  M.properties.width = {{width}}/4
end

if M.properties.area == "page" then
  M.properties.width, M.properties.height   = {{width}}/4, {{height}}/4
  M.properties.scrollWidth, M.properties.scrollHeight = {{scrollWidth}}/4, {{scrollHeight}}/4
end

if M.properties.area == "manual" then
  -- if M.properties.is1x then
  --   local top, left   = {{top}}, {{left}}
  --   local width, height   = {{width}}, {{height}}
  --   local scrollWidth, scrollHeight = {{scrollWidth}}, {{scrollHeight}}
  -- else
    M.properties.top, M.properties.left   = {{top}}, {{left}}
    M.properties.width, M.properties.height   = {{width}}/4, {{height}}/4
    M.properties.scrollWidth,M.properties.scrollHeight = {{scrollWidth}}/4, {{scrollHeight}}/4
  -- end
end

function M:create(UI)
  self:setScroll(UI)
end

function M:didShow(UI)
end

function M:didHide(UI)
end

return require("components.kwik.layer_scroll").set(M)