-- $weight={{weight}}
--
local parent,root, M = newModule(...)
local util = require("lib.util")

local _layerProps = {
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
--
function M:init(UI)
  --local sceneGroup = UI.sceneGroup
end
--
function M:create(UI)
  local layerProps = self.layerProps or _layerProps
  self.layerProps = layerProps

  local obj = display.newRect(
      layerProps.x,
      layerProps.y,
      layerProps.width, layerProps.height)

  obj.xScale = layerProps.xScale
  obj.yScale = layerProps.yScale
  obj.anchorX = layerProps.anchorX or 0.5
  obj.anchorY = layerProps.anchorY or 0.5
  obj.rotation = layerProps.rotation or 0

  obj.name = layerProps.name
  if layerProps.color then
    obj:setFillColor(unpack(layerProps.color))
  end

  obj.shapedWith = layerProps.shapedWith

  if layerProps.imageFile:len() > 0  then
    local fullpath = layerProps.imageFolder..layerProps.imageFile
    local splited = util.split(fullpath, '/')
    local filename = splited[#splited]
    local folder = fullpath:gsub(filename, "")
    obj.imageName = filename
    obj.imageFolder= folder
    filename = util.split(filename, ".")
    local is2x4x = util.isFile(filename[1]..display.imageSuffix.."."..filename[2])
    local paint = {type= "image"}
    if is2x4x then
      paint.filename = filename[1]..display.imageSuffix.."."..filename[2]
    else
      paint.filename = fullpath
    end
    obj.fill =  paint
  end

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
  return self:newInstance(props, _layerProps)
end
--
return M