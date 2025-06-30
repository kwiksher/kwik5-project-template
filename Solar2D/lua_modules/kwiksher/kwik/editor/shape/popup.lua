local M = require("com.gieson.PopUp")
M.rectTool = nil

local options = {
  text = "",
  font = native.systemFont,
  fontSize = 10,
  align = "left"
}

local function tap(event)
  print("tap")
  if event.eventName == "popup.save" then
    M.rectTool:save()
  elseif event.eventName == "popup.move" then
    M.rectTool:move()
  elseif event.eventName == "popup.scale" then
    M.rectTool:scale()
  else -- cancel
    M.rectTool:cancel()
  end
  return true
end

local function createButton(params)
  options.parent = M.group
  options.text = params.text
  options.x = params.x
  options.y = params.y

  local obj = display.newText(options)
  --obj.anchorY=0.5
  obj.tap = tap
  obj.eventName = params.eventName
  obj:addEventListener("tap", obj )
  -- obj.anchorX =0

  local rect = display.newRoundedRect(obj.x, obj.y, 40, obj.height + 2, 10)
  M.group:insert(rect)
  M.group:insert(obj)
  rect:setFillColor(0, 0, 0.8)
  obj.rect = rect
  -- rect.anchorX = 0
end

function M:pos(x, y)
  self.group.x = x
  self.group.y = y
end

function M:create(rectTool)
  self.rectTool = rectTool
  self.group = display.newGroup()
  createButton {
    text = "Save",
    x = 45,
    y = 30,
    eventName = "popup.save"
  }

  createButton {
    text = "Move",
    x = 85,
    y = 30,
    eventName = "popup.move"
  }

  createButton {
    text = "Sale",
    x = 125,
    y = 30,
    eventName = "popup.scale"
  }

  createButton {
    text = "Cancel",
    x = 165,
    y = 30,
    eventName = "popup.cancel"
  }
end

function M:destroy()
  self.group:removeSelf()
end

return M
