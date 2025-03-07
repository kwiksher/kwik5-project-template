local M = {}
--
local app = require "controller.Application"
--
M.properties = {
  blendMode = "normal",
  height    =  1280/4 ,
  width     = 1920/4 ,
  name      = "bg",
  x         =  0, -- display.contentCenterX,
  y         =  0, display.contentCenterY,
  alpha     = 1,
  color     = {1,1,1,1},
  textColor = {0,0,0,1}
}

function M:init(UI)
end
--
function M:create(UI)
  local sceneGroup = UI.sceneGroup
  local properties = self.properties

  local scale = app.getImageSuffix()

  local x, y = app.getCenter(properties.x, properties.y)
  print(x, y)
  local obj = display.newRect(x, y, properties.width*scale, properties.height*scale)
  obj:setFillColor(unpack(properties.color))
  sceneGroup:insert(obj)
  sceneGroup[properties.name] = obj

  local options = {
      parent = sceneGroup,
      text = UI.page,
      font = native.systemFont,
      fontSize = 10,
      align = "center",
      x = x,
      y = properties.y,
  }
  local pageText = display.newText(options)
  pageText:setFillColor(unpack(properties.textColor))

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
return M
