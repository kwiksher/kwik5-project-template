local M = {}
local group = require("com.gieson.PopUp") -- this is display.newGroup()

local editorWidth, editorHeight = (960 - 480)/2, (590 - 320)/2

local transitionTime = 500
--local transitionKillerOff = nil
-- Added mouse over support
local lastButtonRect = nil
local function mouseOver(event)
  if lastButtonRect then
    lastButtonRect.alpha = 0.5
  end
  event.target.alpha = 1
  lastButtonRect = event.target
  return false
end

local options = {
  text = "",
  font = native.systemFont,
  fontSize = 10,
  align = "left"
}

function M:tap(event, target)
  -- print("tap")
  -- printKeys(target)
  -- print(target.eventName)
  if target.eventName == "popup.save" then
    if self.pointA.activeEntryX then
      local function getValue(num)
        local t = "+"
        if num < 0  then
          t = "-"
        end
        return t ..num
      end
      if self.bodyName then
        self.pointA.activeEntryX.field.text = self.bodyName..".x" .. getValue(self.pointA.newX)
        self.pointA.activeEntryY.field.text = self.bodyName ..".y" ..getValue(self.pointA.newY)
      else
        -- print( self.pointA.oriX,  self.pointA.oriX, self.pointA.newX, self.pointA.newY)
        if self.pointA.newX == nil then
          self.pointA.activeEntryX.text = self.pointA.oriX - editorWidth
        else
          self.pointA.activeEntryX.text = self.pointA.newX - editorWidth
        end
        if self.pointA.newY == nil then
          self.pointA.activeEntryY.text = self.pointA.oriY - editorHeight
        else
          self.pointA.activeEntryY.text = self.pointA.newY - editorHeight
        end
      end
    end
  else -- cancel
    self.pointA:setValueXY(self.pointA.oriX, self.pointA.oriY)
  end
  transition.to( group, { time=transitionTime, alpha=0.0, onComplete= function()
    -- print("tapEnded")
    self:tapEnded()
  end })

  return true
end

function M:tapEnded()
  for i, obj in next, self.objs do
    obj:removeEventListener("tap", obj.tap )
    obj.rect:removeEventListener("mouse", mouseOver)
  end
end

local function createButton(params)
  options.parent = params.group
  options.text = params.text
  options.x = params.x
  options.y = params.y

  local obj = display.newText(options)
  --obj.anchorY=0.5
  obj.eventName = params.eventName
  -- obj.anchorX =0

  local rect = display.newRoundedRect(obj.x, obj.y, 40, obj.height + 2, 10)
  params.group:insert(rect)
  params.group:insert(obj)
  rect:setFillColor(0, 0, 0.8)
  obj.rect = rect
  -- Attach mouseOver effect
  -- rect.anchorX = 0
  return obj
end

function M:pos(theX, theY) -- pos from dragger:onDown, pass it to Popup
  group:pos(theX,theY)
end

function M:on(theX, theY, useMulti) -- on from dragger:onDown, pass it to Popup
  group:on(theX, theY, useMulti)
end

function M:text(theText) -- text from  dragger:onDown, pass it to Popup
  group:text(theText)
end

function M:off(dragger)
  -- print("Dragger OFF")
  -- print("self.pointA", self.pointA)

  for i, obj in next, self.objs do
    obj.tap = function(event)
      -- print(self.pointA)
      -- print(obj.eventName)
      self:tap(event, obj)
      return true
    end
    obj:addEventListener("tap", obj.tap )
    obj.rect:addEventListener("mouse", mouseOver)
  end
end

function M:onMove( x, y)
  self.pointA.newX = x
  self.pointA.newY = y
end

M.new = function(pointA)
  local instance = {}

  local saveButton = createButton {
    group = group,
    text = "Save",
    x = 45,
    y = 30,
    eventName = "popup.save"
  }

  local cancelButton = createButton {
    group = group,
    text = "Cacnel",
    x = 85,
    y = 30,
    eventName = "popup.cancel"
  }

  instance.objs = {saveButton, cancelButton}
  instance.pointA = pointA -- Initialize this explicitly for tap event
  -- print( pointA.oriX,  pointA.oriX, pointA.newX, pointA.newY)

  return setmetatable(instance, {__index = M})
end

return M