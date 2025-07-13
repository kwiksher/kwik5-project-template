local M = {}
M.name = ...
M.weight = 6
local parent,  root = newModule(M.name)
local App     = require(kwikGlobal.ROOT.."controller.Application")
local dragger = require("com.gieson.dragger")
local popupMod = require(parent.."popup")

M.x = 0
M.y = 0
M.oriX = display.contentCenterX
M.oriY = display.contentCenterY
-- M.ptAcolor = {255/255, 7/255, 17/255, 25/255}
M.ptAcolor = {0/255, 178/255, 200/255, 0.5}

M.ptAtext = "A"

local Props = {
  ptTextFont = "Helvetica-Bold",
  ptTextSize = 18,
  ptTextColor = {255, 255, 255, 255},
}

function M:setBodyName (name)
  self.popup.bodyName = name
end

function M:setActiveEntryObjs(objX, objY)
  -- print(self.name, "setActiveEntryObjs", objX, objY)
  self.activeEntryX = objX
  self.activeEntryY = objY
  -- self.popup.activeEntryX = objX
  -- self.popup.activeEntryY = objY
end

function M:setValueXY(x, y)
  self.group.alpha = 0.8
  self.group.x = x
  self.group.y = y
  -- self.oriX = x
  -- self.oriX = y
end
---
local editorWidth, editorHeight = (960 - 480)/2, (590 - 320)/2
---
function M:setValue(fromOrTo, layerProps)
  if fromOrTo == nil then
    self.group.alpha = 0
  else
    -- The problem is here - we need to transform coordinates correctly
    local x, y = fromOrTo.x, fromOrTo.y
    -- print(self.name, x, y)
    -- print(debug.traceback())
    -- self.x = x - editorWidth
    -- self.y = y - editorHeight
    -- Get the actual transformed coordinates from the object
    -- This is how layer_image.lua calculates positions

    if self.group then
      self.group.alpha = 1

      self.group.x = x
      self.group.y = y

      -- -- Use the same transformation as in layer_image.lua
      -- if layerProps and layerProps.x and layerProps.y then
      --   -- Apply the same transformation to match object coordinates
      --   self.group.x = x
      --   self.group.y = y
      -- else
      --   self.group.x = x
      --   self.group.y = y
      -- end
    end

    -- print(self.name, "Position set:", self.group.x, self.group.y)
  end

  if layerProps and layerProps.x and layerProps.y then
    -- Store original position properly
    self.oriX = layerProps.x
    self.oriY = layerProps.y
  end
  -- print(self.name, "Original:", self.oriX, self.oriY)
end
--
function M:init(UI, x, y, width, height)
  self.x = (x or self.x)
  self.y = (y or self.y)
  self.oriX = self.x
  self.oriY = self.y
  self.width = width or self.width
  self.height = height or self.height
  -- print("@@@@@",self, self.name, self.oriX, self.oriY, self.x, self.y)

end
--
function M:create(UI)
    -- print("create", self.name)
    if self.x == nil then return end
    --
    -- print("####", self, self.name, self.oriX,  self.oriX, self.x, self.y)
    self.popup = popupMod.new(self)
    -- self.popup.pointA = self

    self.objs = {}
    self.group = display.newGroup()
    UI.sceneGroup:insert(self.group)
    UI.editor.pointGroup = self.group

    local ptAdot = display.newCircle(0, 0, 15)
    ptAdot:setFillColor(unpack(self.ptAcolor))
    local ptAlabel = display.newText(self.ptAtext, 0, 0, Props.ptTextFont,
                                     Props.ptTextSize)
    ptAlabel:setTextColor(unpack(Props.ptTextColor))

    ptAlabel.x = 1.5
    ptAlabel.y = 0
    table.insert(self.objs, ptAdot)
    table.insert(self.objs, ptAlabel)

    local ptA = dragger:newDragger{
        img = self.group,
        callback = function(x, y)
          -- if self.activeEntryX then -- for animation
          --   print(self.name, "newDragger, callback")
          --   self.popup.activeEntryX = self.activeEntryX
          --   self.popup.activeEntryY = self.activeEntryY
          -- end
          --self.popup.pointA = self
          self.popup:onMove(x, y)
        end,
        popup = self.popup,
        editorHeight = editorHeight,
        editorWidth = editorWidth
    }
    self.group:insert(ptAdot)
    self.group:insert(ptAlabel
  )
    --self.group:translate(display.contentCenterX-100, display.contentCenterY)
    self.group.ptA = ptA

    -- Calculate position more precisely for editor view
    -- Use the scale factor from App.getPosition in reverse if needed
    local centerX = (self.oriX or display.contentCenterX)
    local centerY = (self.oriY or display.contentCenterY)

    -- Position the point properly, ensuring it's centered on the target
    self.group.x = centerX + self.x
    self.group.y = centerY + self.y
    -- print(self.name, "self.x y", self.x, self.y, self.oriX, self.oriY)
    -- print(self.name, "self.group.x y", self.group.x, self.group.y)
    --
    if self.group.x == 0 and self.group.y ==0 then
      print("Waning: layerProps maybe missing in .lua")
    end

end
--
function M:didShow(UI) end
--
function M:didHide(UI) end
--
function M:destroy()
  if self.objs then
    for i, obj in next, self.objs do
      if obj.removeSelf then
        obj:removeSelf()
      end
    end
  end
  self.objs = nil
end

--
function M:toggle()
  -- print("@ toggle")
  for i, obj in next, self.objs do
   obj.isVisible = not obj.isVisible
  end
end

function M:show()
  -- print("@ show", self.group.x, self.group.y)
  for i, obj in next, self.objs or {} do
    obj.isVisible = true
  end
end

function M:hide()
  -- print("@ hide")
  for i, obj in next, self.objs or {} do
    obj.isVisible = false
  end
end


return M
