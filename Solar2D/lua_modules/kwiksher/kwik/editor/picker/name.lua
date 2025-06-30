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

M.model = {message = "Please input name for an action", value=""}

M.x = display.contentCenterX
M.y = 22
M.width = 80
M.height = 40
M.buttons = {"Continue",  "CANCEL"}
--
function M:create(callback, message)
  -- print(debug.traceback())
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
        -- print("@", self.obj.field.text)
        if event.target.text == "CANCEL" then
          if callback then
            callback("cancel")
          end
          self:destroy()
        else
          if callback then
            if self.obj.field.text == nil or self.obj.field.text:len() == 0 then
              self.obj.field.text = "name"..math.random(100)
            end
            callback(self.obj.field.text)
            -- self:destroy()
            for i, _obj in next, self.buttonObjs do
              _obj.isVisible = false
            end

          end
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
  option.text = "Input Name"
  -- for k,v in pairs(option) do print(k ,v ) end
  local obj = newText(option)
  obj:setFillColor(1)

  option.y = option.y + 20
  option.text = nil
  local field = util.newTextField(option)
  field.align = "center"
  field.placeholder = message or  self.model.message
  obj.field =field
  self.obj = obj
  self.isOn = true
 end

function M:getValue()
  if self.obj and self.obj.field then
    self.lastValue = self.obj.field.text
  end
  return self.lastValue
end

function M:continue(value)
  self.obj.field.text = value
  self.lastValue = value
  self.callback(value)
  self:destroy()
  self.isOn = false
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
  self.isOn = false
end

function M:show()
  -- print(debug.traceback())
  if self.obj then
    self.obj.field.isVisible = true
    self.obj.isVisible = true
  end
  if self.buttonObjs then
    for i, obj in next, self.buttonObjs do
      obj.isVisible = true
    end
  end
  self.isOn = true
end

function M:didShow()
  -- print("#didShow")
  -- self:show()
end

function M:didHide()
  self:hide()
end

function M:destroy()
  -- print(debug.traceback())
  if self.obj then
    self.obj.field:removeSelf()
    self.obj:removeSelf()
    for i, obj in next, self.buttonObjs do
      obj:removeSelf()
    end
    self.obj = nil
  end
  self.isOn = false
end

return M