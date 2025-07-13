local M = {}

local util = require(kwikGlobal.ROOT.."lib.util")
local option, newText = util.newTextFactory {
  text = "",
  x    = 0,
  y    = 100,
  width    = 200,
  height   = 30,
  fontSize = 12,
}

M.model = {message = "Please confirm", value=""}

M.x = display.contentCenterX
M.y = 22
M.width = 80
M.height = 40
M.buttons = {"Continue",  "CANCEL"}
--
function M:create(callback, message, props)
  self.callback = callback
  -- buttons
  self.buttonObjs = {}
  if callback then
    for i, v in next, self.buttons do
      local _option = {}
      _option.y = self.y + 50
      _option.text = v
      local obj = display.newText(_option)
      obj:setFillColor(1,1,1)
      if i > 1 then
        obj.x = self.buttonObjs[i-1].contentBounds.xMax + obj.width/2 + 10
      else
        obj.x = self.x
      end
      obj:addEventListener("tap", function(event)
        local message = event.target.text
          if callback then
            callback(message, props)
          end
        end)
      self.buttonObjs[#self.buttonObjs + 1 ] = obj
    end
  end
  --
  self.obj = {}
  --
  option.x = self.x
  option.y = self.y
  option.text =  message or ""
  -- for k,v in pairs(option) do print(k ,v ) end
  local obj = newText(option)
  obj:setFillColor(1)
  self.obj = obj
end

function M:continue(value)
  self.obj.field.text = value
  self.callback(value)
  self:destroy()
end

function M:hide()
  if self.obj then
    self.obj.isVisible = false
    self.obj.field.isVisible = false
  end
  if self.buttonObjs then
    for i, obj in next, self.buttonObjs do
      obj.isVisible = false
    end
  end
end

function M:show()
  if self.obj then
    self.obj.isVisible = true
  end
  if self.buttonObjs then
    for i, obj in next, self.buttonObjs do
      obj.isVisible = true
    end
  end
end

function M:destroy()
  self.obj:removeSelf()
  for i, obj in next, self.buttonObjs do
    obj:removeSelf()
  end
end

return M