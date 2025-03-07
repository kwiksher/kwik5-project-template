-- $weight={{weight}}
--
local parent,root, M = newModule(...)
local util = require("lib.util")
local app = require "controller.Application"
local shape = require("components.kwik.layer_shape")
--
local layerProps = {
  name     = "{{name}}",
  x        = {{x}},
  y        = {{y}},
  width    =  {{width}},
  height    =  {{height}},
  xScale = {{xScale}},
  yScale = {{yScale}},
  anchorX = {{anchorX}},
  anchorY = {{anchorY}},
  rotation = {{rotation}},
  {{#fill }}
  color    = { {{r}}, {{g}}, {{b}}, {{a}} },
  {{/fill }}
  shapedWith = "new_rectangle",
  imageFile = "{{imageFile}}",
  imageFolder = "{{imageFolder}}"
}

M.layerProps = layerProps
--
function M:init(UI)
  --local sceneGroup = UI.sceneGroup
end
--
function M:create(UI)
  local layerProps = self.layerProps
  -- local x, y = app.getCenter(layerProps.x, layerProps.y)
  local x, y = layerProps.x, layerProps.y
  --
  local obj = shape.createRectangle(layerProps)
  --
  obj.layerIndex = #UI.layers+1
  UI.layers[obj.layerIndex] = obj
  UI.sceneGroup:insert(obj)
  UI.sceneGroup[obj.name] = obj

end
--
function M:didShow(UI)
end
--
function M:didHide(UI)
end
--
function  M:destroy(UI)
end
--
function M:new(props)
  return self:newInstance(props, layerProps)
end
--
return M