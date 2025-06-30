local M = {}
local util = require(kwikGlobal.ROOT.."lib.util")
--
function M.createRectangle(layerProps)
  -- local x, y = app.getCenter(layerProps.x, layerProps.y)
  local x, y = layerProps.x, layerProps.y
  local obj = display.newRect(
    x,
    y,
    layerProps.width, layerProps.height)
  obj.xScale = layerProps.xScale
  obj.yScale = layerProps.yScale
  obj.anchorX = layerProps.anchorX or 0.5
  obj.anchorY = layerProps.anchorY or 0.5
  obj.rotation = layerProps.rotation or 0
  obj.oriX = layerProps.x
  obj.oriY = layerProps.y
  obj.oriAlpha = layerProps.alpha or 1

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
    --
    local paint = {type= "image"}
    if display.imageSuffix == nil then
      paint.filename = fullpath
    else
      local is2x4x = util.isFile(filename[1]..display.imageSuffix.."."..filename[2])
      if is2x4x then
        paint.filename = filename[1]..display.imageSuffix.."."..filename[2]
      end
    end
    obj.fill =  paint
  end
  return obj
end

function M.createCircle(layerProps)
  -- self.imagePath = layerProps.name.."." .. (layerProps.type or ".png")
  -- -- local path = UI.props.imgDir..self.imagePath
  -- local path = system.pathForFile(UI.props.imgDir..self.imagePath, system.ResourceDirectory)
  -- local x, y = app.getCenter(layerProps.x, layerProps.y)
  local x, y = layerProps.x, layerProps.y
  local obj = display.newCircle(
    x,
    y,
    layerProps.radius)
  if obj == nil then
    obj = display.newText(layerProps)
  end
  obj.name = layerProps.name
  obj:setFillColor(unpack(layerProps.color))
  obj.shapedWith = layerProps.shapedWith
  obj.anchorX = layerProps.anchorX or 0.5
  obj.anchorY = layerProps.anchorY or 0.5
  obj.rotation = layerProps.rotation or 0
  obj.xScale = layerProps.xScale
  obj.yScale = layerProps.yScale
  obj.oriX = layerProps.x
  obj.oriY = layerProps.y
  obj.oriAlpha = layerProps.alpha or 1
  return obj
end

function M.createImage(layerProps)
end

return M