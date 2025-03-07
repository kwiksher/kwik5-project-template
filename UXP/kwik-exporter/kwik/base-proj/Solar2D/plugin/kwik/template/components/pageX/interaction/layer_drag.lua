local name = ...
local parent,root = newModule(name)

local layerProps = require(parent.."{{layer}}").properties
local MultiTouch = require("extlib.dmc_multitouch")

function M:dbounds()
  local dbounds = {}
  if {{gconstrain) and {{gboundsX) and {{gboundsY)  then
      dbounds = { constrainAngle = {{gangle}} }
  else if {{gconstrain) and {{gboundsX}}  and {{gboundsY}} then
      dbounds = { constrainAngle = {{gangle}}, xBounds = { {{gboundsXS}}, {{gboundsXE}}} }
  else if {{gconstrain)  and{{gboundsX) and {{gboundsY}} then
      dbounds = { constrainAngle = {{gangle}}, yBounds = { {{gboundsYS}}, {{gboundsYE}}} }
  else if {{gconstrain}}  and {{gboundsX}} and {{gboundsY}} then
      dbounds = { constrainAngle = {{gangle}}, xBounds = { {{gboundsXS}}, {{gboundsXE}}}, yBounds = { {{gboundsYS}}, {{gboundsYE}}} }
  else if {{gconstrain}} and {{gboundsX}} and {{gboundsY}} then
      dbounds = { xBounds = { {{gboundsXS}}, {{gboundsXE}}} }
  else if {{gconstrain}}  and {{gboundsX) and {{gboundsY) then
      dbounds = { yBounds = { {{gboundsYS}}, {{gboundsYE}}} }
  else if {{gconstrain}}  and {{gboundsX}}  and {{gboundsY}} then
      dbounds = { xBounds = { {{gboundsXS}}, {{gboundsXE}}}, yBounds = { {{gboundsYS}}, {{gboundsYE}}} }
  end
  return dbounds
end


local M = {
  name ="{{layer}}",
  -- commonAsset = "{{common}}",
  -- class = "{{class}}", -- button, drag, canvas ...
  --
  -- dragProps
  properties = {
    {{#properties}}
    target = "{{layer}}",
    type  = "{{type}}",
    constrainAngle = {{constrainAngle}},
    bounds = {xMin={{xMin}}, xMax={{xMax}}, yMin={{yMin}}, yMax={{yMax}}},
    isActive = "{{isActive}}",
    isFocus = true,
    isPage = false,
    --
    isFlip = true,
    flipInitialDirection  = "right", -- "left", "bottom", "top"
    -- flipAxis = "x", -- "y",
    -- flipValue      = 0,
    -- flipScale = 1, -- -1
    -- --
    isDrop = true,
    dropArea = "{{dropArea}}",
    dropMargin = 10,
    --
    -- dropBound = {xMin=0, xMax=0, yMin = 0, yMax=0},
    --
    rock = 1, -- 0,
    backToOrigin = true,
   {{/properties}}
  }
  --
}

M.layerProps = layerProps
M.actions={
  {{#actions}}
  onDropped = "{{onDropped}}",
  onReleased ="{{onReleased}}",
  onMoved="{{onMoved}}" },
  {{/actions}}


function M:create(UI)
  self.UI = UI
  local sceneGroup = UI.sceneGroup
  local layerName  = self.properties.target
  self.obj        = sceneGroup[layerName]
  if self.isPage then
    self.obj = sceneGroup
  end
  --
  self.obj.dropArea = sceneGroup[self.dropArea]
  self:activate(self.obj)
end

function M:didShow(UI)
  self.UI = UI
  self:addEventListener(self.obj)
end

function M:didHide(UI)
  self:removeEventListener(self.obj)
end

return require("components.kwik.layer_drag").set(M)