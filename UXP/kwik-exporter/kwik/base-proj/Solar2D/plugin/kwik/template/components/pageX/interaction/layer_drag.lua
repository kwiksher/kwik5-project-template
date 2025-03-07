local parent,root, M = newModule(...)
local layerProps = require(M.layerMod).layerProps or {}

local MultiTouch = require("extlib.dmc_multitouch")

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
    {{#boundaries}}
    boundaries = {xMin={{xMin}}, xMax={{xMax}}, yMin={{yMin}}, yMax={{yMax}}},
    {{/boundaries}}
    isActive = {{isActive}},
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
}

M.layerProps = layerProps
M.actions={
  {{#actions}}
  onDropped = "{{onDropped}}",
  onReleased ="{{onReleased}}",
  onMoved="{{onMoved}}"
  {{/actions}}
}

function M:create(UI)
  self.UI = UI
end

function M:didShow(UI)
  self.UI = UI
  -- self:addEventListener(self.obj)
  local sceneGroup = UI.sceneGroup
  local layerName  = self.properties.target
  self.obj        = sceneGroup[layerName]
  if self.isPage then
    self.obj = sceneGroup
  end
  --
  self.obj.dropArea = sceneGroup[self.properties.dropArea]
  -- printKeys(self.obj)
  self.obj.oriX, self.obj.oriY = self.obj.x, self.obj.y
  self:activate(self.obj)
end
function M:didHide(UI)
  -- self:removeEventListener(self.obj)
  self:deactivate(self.obj)
end

return require("components.kwik.layer_drag").set(M)