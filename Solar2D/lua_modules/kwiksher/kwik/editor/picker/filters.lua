local M = {}

local util = require(kwikGlobal.ROOT.."lib.util")
local option, newText = util.newTextFactory {
  text = "",
  x    = 0,
  y    = 100,
  width    = 80,
  height   = 30,
  fontSize = 12,
}

M.model = require(kwikGlobal.ROOT.."template.components.pageX.animation.defaults.filters_ref")

M.x = display.contentCenterX
M.y = display.contentCenterY-200
M.width = 80
M.height = 40
M.buttons = {"filter", "composite", "generator", "CANCEL"}
--
function M:create(UI)
  -- buttons
  self.buttonObjs = {}

  for i, v in next, self.buttons do
    local _option = {}
    _option.y = self.y -32
    _option.text = v
    local obj = display.newText(_option)
    obj:setFillColor(1,1,1)
    if i > 1 then
      obj.x = self.buttonObjs[i-1].contentBounds.xMax + obj.width/2 + 10
    else
      obj.x = self.x
    end
    obj:addEventListener("tap", function(event)
      if event.target.text == "CANCEL" then
        self:destroy()
      else
        self:createTable(event.target.text)
        self:show()
      end
    end)
    self.buttonObjs[#self.buttonObjs + 1 ] = obj

  end
  --- thumbnails
  self:createTable("filter")
end

function M:createTable(name)
  if self.objs then
    for i, obj in next, self.objs do
      -- print(obj.text)
      obj:removeEventListener("tap", self.tapHandler)
      if obj.image1 then
        obj.image1.alpha = 0
        obj.image1:removeSelf()
      end
      if obj.image2 then
        obj.image2.alpha = 0
        obj.image2:removeSelf()
      end
      obj:removeSelf()
    end
  end
  --
  self.objs = {}
  local rowNum = 0
  local colNum = 0
  for i, v in next, self.model do
    local k = v.name
    local sPos, ePos = k:find(name)
    if sPos  then
      colNum = colNum % 4
      -- print(colNum)
      option.x = self.x + self.width*colNum + 10
      option.y = self.y + self.height*rowNum
      option.text = k:sub(ePos+2)
      local path = "assets/images/filters/"
      local obj = newText(option)
      if name =="composite" then
        obj:setFillColor(1,0,0)
      else
        obj:setFillColor(0.5,1,0.5)
      end
      obj.anchorY = 0.6
      obj.filter_name = k
      -- print(path..v.image1)
      if v.image2 then
        obj.image2 =display.newImage(path..v.image2, option.x, option.y)
        obj.image2.width = self.width
        obj.image2.height = self.height
      else
        obj.image1 = display.newImage(path..v.image1, option.x, option.y)
        obj.image1.width = self.width
        obj.image1.height = self.height
      end
      obj:toFront()
      self.objs[#self.objs +1] = obj
      colNum = colNum + 1
      if colNum % 4 == 0 then
        rowNum = rowNum + 1
      end
    end
  end
end

function M.tapHandler(event)
  local target = event.target
  M.listener(target.filter_name)
end

function M:show(UI)
  for i, obj in next, self.objs do
    obj:addEventListener("tap",self.tapHandler)
  end
end

function M:destroy(UI)
  for i, obj in next, self.objs do
    obj:removeEventListener("tap", self.tapHandler)
    if obj.image1 then
      obj.image1:removeSelf()
    end
    if obj.image2 then
      obj.image2:removeSelf()
    end
    obj:removeSelf()
  end
  for i, obj in next, self.buttonObjs do
    obj:removeSelf()
  end
  self.objs = nil
end

return M