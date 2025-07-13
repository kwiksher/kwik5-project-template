local M = {}
local current = ...
local parent = current:match("(.-)[^%.]+$")

M.name = current
M.weight = 1

local App = require("Application")
local keyEventManager = require("editor.keyEventManager")

--
-- local button = require("com.gieson.Button")
-- local tools = require("com.gieson.Tools")
---
M.commands = {"create", "delete", "save", "cancel", "copy", "paste"}
M.objs = nil

local isCancel = function(event)
  local ret = event.phase == "up" and event.keyName == 'escape'
  return ret or (system.getInfo("platform") == "android" and event.keyName == "back")
end

---
function M:init(UI, toggleHandler)
    local app = App.get()
    for i = 1, #self.commands do
      local eventName = "editor.action." .. self.commands[i]
      if app.context.commands[eventName] == nil then
        app.context:mapCommand(
          eventName,
          "editor.action.controller." .. self.commands[i]
        )
      end
    end
    self.togglePanel = toggleHandler
end
--
function M:create(UI)

  -- print("create", self.name)
  -- single ton
  -- if self.objs == nil then return end
  self.objs = {}
  self.group = display.newGroup()

  local posX = display.contentCenterX - 210
  local posY = display.actualContentHeight-10

  local function tap(event)
    -- print("tap")
    if event.eventName == "toggle" then
      self.togglePanel(true)
      if self.objs[event.eventName].text == "show" then
        self.objs[event.eventName].text = "hide"
      else
        self.objs[event.eventName].text = "show"
      end
    else
      UI.scene.app:dispatchEvent {
        name = "editor.action." .. event.eventName,
        UI = UI
      }
    end
    return true
  end

  local options = {
    parent = self.group,
    text = "",
    font = native.systemFont,
    fontSize = 10,
    align = "left"
  }

  local function createButton(params)
    options.text = params.text
    options.x = params.x
    options.y = params.y

    local obj = display.newText(options)
    --obj.anchorY=0.5
    obj.tap = tap
    obj.eventName = params.eventName
    -- obj.anchorX =0

    local rect = display.newRoundedRect(obj.x, obj.y, 40, obj.height + 2, 10)
    self.group:insert(rect)
    self.group:insert(obj)
    rect:setFillColor(0, 0, 0.8)
    obj.rect = rect
    -- rect.anchorX = 0

    self.objs[params.eventName] = obj
    return obj.rect
  end

  local obj = createButton {
    text = "New",
    x = posX,
    y = posY,
    eventName = "create"
  }

  obj = createButton {
    text = "Copy",
    x = display.contentCenterX - 170,
    y = display.actualContentHeight-10,
    eventName = "copy"
  }

  obj = createButton {
    text = "Paste",
    x = display.contentCenterX -130,
    y = obj.y,
    eventName = "paste"
  }

  obj = createButton {
    text = "Delete",
    x = obj.x + obj.width,
    y = obj.y,
    eventName = "delete"
  }

  -- obj = createButton {
  --   text = "hide",
  --   x = obj.x + obj.width+10,
  --   y = obj.y,
  --   eventName = "toggle"
  -- }

  obj = createButton {
    text = "Save",
    x = display.contentCenterX + 45,
    y = display.actualContentHeight-10,
    eventName = "save"
  }
  obj = createButton {
    text = "Cancel",
    x = obj.x + obj.width,
    y = obj.y,
    eventName = "cancel"
  }
  --print(debug.traceback())
  UI.editor.viewStore.actionButtons = self
  self:hide()

end
--
function M:didShow(UI)
  if self.objs == nil then return end
  for k, obj in pairs(self.objs) do
    obj:addEventListener("tap", obj)
  end
  self.UI = UI
  --self:toggle()
end
--
function M:didHide(UI)
  if self.objs == nil then return end
  for k, obj in pairs(self.objs) do
    obj:removeEventListener("tap", obj)
  end
end
--
function M:destroy()
  if self.objs == nil then return end
  for k, obj in pairs(self.objs) do
    obj.rect:removeSelf()
    obj:removeSelf()
  end
  self.objs = nil
end

function M:toggle()
  -- print(debug.traceback())
  if self.objs == nil then return end
  for k, obj in pairs(self.objs) do
    obj.isVisible = not obj.isVisible
    obj.rect.isVisible = obj.isVisible
    end
end

function M:show()
  -- print(debug.traceback())
  if self.objs == nil then return end
  for k, obj in pairs(self.objs) do
    obj.isVisible = true
    -- obj.alpha = 1
    -- obj.rect.alpha = 1
    obj.rect.isVisible = obj.isVisible
  end
  self.onKeyEvent = function(event)
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    -- print(message)
    --for k, v in pairs(event) do print(k, v) end
    if isCancel(event)  then
      self.UI.scene.app:dispatchEvent {
        name = "editor.action.cancel",
        UI = self.UI,
      }
      --Android, prevent it from backing out of the app
      return true
    end
    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
  end

  --keyEventManager.register("actionButtons", self.onKeyEvent, 1)

end

function M:hide()
  -- print("why not hiding????")
  if self.objs == nil then return end
  for k, obj in pairs(self.objs) do
    -- print(obj.text)
    -- obj.alpha = 0
    -- obj.rect.alpha = 0
    obj.isVisible = false
    obj.rect.isVisible = obj.isVisible
  end

  --keyEventManager.unregister("actionButtons")

end

--
return M
