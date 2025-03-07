-- $weight={{weight}}
--
local parent,root, M = newModule(...)

local _layerProps = {
  name     = M.name,
  shape    = "{{shape}}",
  x        = display.contentCenterX ,
  y        = display.contentCenterY,
  {{#color}}
  color    = { {{r}}, {{g}}, {{b}}, {{a}} },
  {{/color}}
  text     = "{{text}}",
  width    = nil, -- {{width}},
  font     = {{font}},
  fontSize = {{fontSize}},
  align    = "{{align}}"  -- Alignment parameter
}
--
function M:init(UI)
  --local sceneGroup = UI.sceneGroup
end
--
function M:create(UI)
  local layerProps = self.layerProps or _layerProps
  local obj

  self.imagePath = layerProps.name.."." .. (layerProps.type or ".png")
  local path = UI.props.imgDir..self.imagePath
  -- local path = system.pathForFile(UI.props.imgDir..self.imagePath, system.ResourceDirectory)
  local obj = display.newImage(
      path,
      layerProps.x,
      layerProps.y)

  if obj == nil then
    obj = display.newText(layerProps)
  end

  obj.name = layerProps.name
  obj:setFillColor(unpack(layerProps.color))
  obj.layerIndex = #UI.layers+1
  UI.layers[obj.layerIndex] = obj
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
  return self:newInstance(props, _layerProps)
end
--
return M