local name = ...
local parent,                   root, M = newModule(name)
local actionTableListener      = require(parent.."actionTableListener")
local buttonContext            = require(parent.."buttonContext")
--    local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")
local util                     = require(kwikGlobal.ROOT.."lib.util")
local keyEventManager          = require(kwikGlobal.ROOT .. "editor.keyEventManager")
--
-- local actionbox = require(root.."parts.actionbox")
-- local buttons = require(parent.."buttons")
--
M.selections = {}
M.x = nil
M.y = nil
M.width = 80 -- 52
M.groupName = "rootGroup"

local option, newText = util.newTextFactory{anchorX=0}

--
--  Selector will show action Table
--
-- load widget library
local widget = require("widget")

function M:setPosition()
  -- self.x = self.rootGroup.selectAction.rect.contentBounds.xMax
  self.x = display.contentCenterX - 480*0.95
  self.y = 22 -- self.rootGroup.selectAction.y

  -- self.x = self.rootGroup.selectAction.contentBounds.xMax
  -- self.y = self.rootGroup.selectAction.y
end

function M:init(UI)
  buttonContext:init(UI)
end
--

function M.mouseHandler(event)
  -- print(event.isSecondaryButtonDown,event.target.isSelected )
  if event.isSecondaryButtonDown and event.target.isSelected then
    buttonContext:showContextMenu(event.x + 20, event.y,  event.target, "action")
    --self.target = event.target
  else
    -- print("@@@@not selected")
  end
  return true
end


function M:create(UI)
  -- if self.rootGroup then return end
  self.rootGroup = UI.editor[self.groupName]
  self.group = display.newGroup()
  self.UI = UI
  self:setPosition()
  buttonContext:create(UI)

  option.width = self.width -- nil makes newText automatically adjust the width

   local function render (models, xIndex, yIndex)
    -- print("actionStore", #models)
    self:destroy()
    self.group = display.newGroup()
    -- buttons:show()

    local objs = {}

    local newButton = newText{
      x = self.x,
      y = self.y + 4,
      text = "New"
    }
    newButton:setFillColor(0, 1, 0)

    newButton.rect = display.newRect(self.group, newButton.x, newButton.y, newButton.width, newButton.height)
    newButton.rect:setFillColor(0.8)
    newButton.rect.anchorX = 0
    newButton.alpha = 1
    newButton.rect.alpha = 0
    newButton.tap = function(event)
      self:newHandler(event)
      -- buttons:show()
    end
    newButton:addEventListener("tap", newButton)

    local editButton = newText{
      x = newButton.contentBounds.xMax +4,
      y = newButton.y,
      text = "Edit"
    }
    editButton:setFillColor(0, 1, 0)
    editButton.tap = function(event)
      self:editHandler(event)
      -- buttons:show()
    end
    editButton:addEventListener("tap", editButton)
    -- editButton.rect = display.newRect(self.group, editButton.x, editButton.y, editButton.width, editButton.height)
    -- editButton.rect:setFillColor(0.8)
    -- editButton.rect.anchorX = 0
    editButton.alpha = 1
    -- editButton.rect.alpha = 0

    -- local attachButton = newText{
    --   x = newButton.contentBounds.xMax +44,
    --   y = newButton.y,
    --   text = "Attach"
    -- }
    -- attachButton:setFillColor(0, 1, 0)
    -- attachButton.tap = function(event)
    --   self:attachHandler(event)
    -- end
    -- attachButton:addEventListener("tap", attachButton)
    -- attachButton.alpha = 1

    for i = 1, #models do
      option.text = models[i]
      option.x = newButton.x
      option.y = newButton.y+ option.height * i
      --option.width = 100
      local obj = newText(option)
      obj.touch = function(target, event)
        -- print(event)
        if event.phase =="ended" then
          self:selectHandler(target)
        end
        return true
      end
      obj.action = obj.text
      obj:addEventListener("touch", obj)
      obj:addEventListener("mouse",self.mouseHandler)

      local rect = display.newRect(obj.x, obj.y, obj.width+10,option.height)
      rect:setFillColor(0.8)
      rect.strokeWidth = 1
      rect.anchorX = 0
      self.group:insert(rect)
      self.group:insert(obj)
      obj.rect = rect
      objs[i] = obj
    end
    -- objs[#objs + 1] = newButton
    self.rootGroup.actionTable= self.group
    self.rootGroup:insert(self.group)
    if #objs > 1 then
      newButton.rect.width = objs[#objs-1].rect.width
      newButton.rect.height = objs[#objs-1].rect.height
    end

    return objs, newButton, editButton --, attachButton
  end

  UI.editor.actionStore:listen(
    function(foo, fooValue)
      self:destroy()
      if fooValue and fooValue.value then
        -- self.objs, self.newButton, self.editButton, self.attachButton = render(fooValue,0,0)
        self.objs, self.newButton, self.editButton = render(fooValue.value,0,0)
        self:show()
        -- if #fooValue == 0 then
        --   self:hide()
        -- end
        if fooValue.isActiveProp then
          self.group.x = display.contentCenterX+160
          self.group.y = display.contentCenterY-100

        end
      end
    end
  )

end

function M:didShow(UI)
  self.UI = UI
  if self.newButton then
    self.newButton.isVisible = true
  end
  keyEventManager.register("actionTable", function(event) return M:onKeyEvent(event) end, 1)
end
--
function M:didHide(UI)
  if self.newButton then
    self.newButton.isVisible = false
  end
  keyEventManager.unregister("actionTable")
end

function M:hide()
  if self.objs then
    self.group.isVisible = false
  end
  if self.newButton then
    self.newButton.isVisible = false
    self.editButton.isVisible = false
    -- self.attachButton.isVisible = false
  end
end

function M:show()
  if self.objs then
    self.group.isVisible = true
  end
  if self.newButton then
    self.newButton.isVisible = true
    self.editButton.isVisible = true
    -- self.attachButton.isVisible = true
  end
end

--
function M:destroy()
  if self.objs then
    for i = 1, #self.objs do
      if self.objs[i].rect then
        self.objs[i].rect:removeSelf()
      end
      self.objs[i]:removeSelf()
    end
  end
  self.objs = nil
  if self.newButton then
    self.newButton:removeSelf()
    self.editButton:removeSelf()
    -- self.attachButton:removeSelf()
    self.newButton = nil
  end
end

return setmetatable(M, {__index=actionTableListener})
