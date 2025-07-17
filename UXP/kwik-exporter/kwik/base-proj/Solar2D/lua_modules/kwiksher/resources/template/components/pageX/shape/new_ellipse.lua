-- $weight={{weight}}
--
local parent,root, M = newModule(...)
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
  {{#path}}
   radius   = {{radius}},
  {{/path}}
  {{#fill }}
  color    = { {{r}}, {{g}}, {{b}}, {{a}} },
  {{/fill }}
  shapedWith = "new_ellipse"
}

M.layerProps = layerProps
--
function M:init(UI)
  --local sceneGroup = UI.sceneGroup
end
--
function M:create(UI)
  local layerProps = self.layerProps
  local obj

  self.imagePath = layerProps.name.."." .. (layerProps.type or ".png")
  local path = UI.props.imgDir..self.imagePath
  -- local path = system.pathForFile(UI.props.imgDir..self.imagePath, system.ResourceDirectory)
  -- local x, y = app.getCenter(layerProps.x, layerProps.y)
  local x, y = layerProps.x, layerProps.y
  --
  local obj = shape.createCircle(layerProps)
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