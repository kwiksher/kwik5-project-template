local current = ...
local parent,  root, M = newModule(current)

M.name = current
M.width = 60
M.model = {"New", "Select"}

local isCancel = function(event)
  local ret = event.phase == "up" and event.keyName == 'escape'
  return ret or (system.getInfo("platform") == "android" and event.keyName == "back")
end

---
function M:init(UI, listener)
  self.listener = listener
end
--
function M:create(UI)
  -- if self.name == "editor.action.buttonContext" then
  --   print(debug.traceback())
  -- end
  local group = display.newGroup()
  self.UI = UI
  self.objs = {}
  self.group = group

  local function tapHandler(target, event)
    local props = {}
    -- print(self.name)
    transition.from(target, {time=500, xScale=2, yScale=2})
    self.listener(target.eventName, self.target, self.class)
    self:hide()
      --
    return true
  end

  local options = {
    parent = group,
    text = "",
    font = native.systemFont,
    fontSize = 12,
    align = "center"
  }

  local function createButton(params)
    local option = params.option
    options.text = params.text
    options.x = params.x
    options.y = params.y

    local obj = display.newText(options)
    -- obj.anchorY=0.5
    -- obj.anchorX = 0
    obj.eventName = params.eventName
    obj:translate(obj.width/2 + 10, 0)

    local rect = display.newRoundedRect(obj.x, obj.y, obj.width+10, obj.height + 2, 10)
    group:insert(rect)
    group:insert(obj)
    rect:setFillColor(0, 0, 0.8)
    obj.rect = rect
    --
    obj.rect.tap = params.tapHandler
    obj.rect.eventName = params.eventName

    obj.alignment = params.alignment
    -- rect.anchorX = 0
    if params.objs then
      params.objs[params.eventName] = obj
      -- if self.name == "editor.action.buttonContext" then
      --   print(params.eventName)
      -- end
    end
    return obj
  end

  for i, name in next, self.model do
    -- print(i, name:gsub("%s+",""))
    createButton {
      text = name,
      x = display.contentCenterX - 480/2,
      y = display.actualContentHeight-10,
      eventName = name:gsub("%s+",""),
      alignment = "left",
      objs = self.objs,
      tapHandler = tapHandler
    }
  end

  for k, obj in pairs(self.objs) do
    obj.rect:addEventListener("tap", obj.rect)
  end
  self:hide()
end
--
function M:didShow(UI)
  self.UI = UI

end
--
function M:didHide(UI)
end
--
function M:destroy()
  -- print("destroy")
  if self.objs then
    for k, obj in next, self.objs do
      obj.rect:removeEventListener("tap", obj)
      obj.rect:removeSelf()
      obj:removeSelf()
    end
  end
  self.objs = nil
end

function M.mouseOver(event)
  local obj = M.lastButtonRect
  if obj then
    obj.alpha = 0.5
  end
  --
  local target = event.target
  target.alpha = 1
  --
  M.lastButtonRect = target
end

function M:showContextMenu(x,y, target, class)
  self.class = class
  -- print("showContextMenu target", target.text, class)
  self.target = target
  local indexX, indexY = 0,0
  for k, key in next, self.model do
    for k, obj in next, self.objs do
      if key:gsub("%s+", "")  == obj.rect.eventName then
        obj.isVisible = true
        obj.rect.isVisible = obj.isVisible
        obj.x = x --+ obj.width
        obj.y = y + indexY * obj.rect.height + 10
        indexY = indexY + 1
        obj.rect.x = obj.x
        obj.rect.y = obj.y
        obj.rect.alpha = 0.5
        -- print("key", key,obj.x, obj.y)
        -- obj.rect:toFront()
        -- obj:toFront()
        obj.rect:addEventListener("mouse", self.mouseOver)
        break
      end
    end
  end
  self.group:toFront()
  self:show()
end

function M:hideContextMenu()
  -- print(" --- hideContextMenu ----")
  if self.objs then
    for k, obj in pairs(self.objs) do
        obj.isVisible = false
        obj.rect.isVisible = false
        obj.rect:removeEventListener("mouse", self.mouseOver)
    end
  end

end

function M:show()
  -- print("---show ---")
  self.onKeyEvent = function(event)
    if isCancel(event)  then
      self:hide()
      --Android, prevent it from backing out of the app
      return true
    end
    return false
  end
  self.group.isVisible = true
  Runtime:addEventListener("key", self.onKeyEvent)
end

function M:hide()
  if self.objs then
    -- print(" --- hide ----")
    for k, obj in pairs(self.objs) do
      -- print(obj.text)
      obj.isVisible = false
      obj.rect.isVisible = false
      -- obj.alpha = 0
      -- obj.rect.alpha = 0
    end
  end
  self.group.isVisible = false
  Runtime:removeEventListener("key", self.onKeyEvent)
end

M.new = function(instance)
  return setmetatable(instance, {__index=M})
end
--
return M
