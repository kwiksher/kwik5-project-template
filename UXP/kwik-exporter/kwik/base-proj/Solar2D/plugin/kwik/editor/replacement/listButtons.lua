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
M.commands = {"delete", "save", "cancel", "select", "add", "preview"}
M.objs = {}

local isCancel = function(event)
  local ret = event.phase == "up" and event.keyName == "escape"
  return ret or (system.getInfo("platform") == "android" and event.keyName == "back")
end

---
function M:init(UI)
  local app = App.get()
  for i = 1, #self.commands do
    local eventName = "editor.replacement.list." .. self.commands[i]
    if app.context.commands[eventName] == nil then
      app.context:mapCommand(
        eventName,
        "editor.replacement.controller." .. self.commands[i]
      )
    end
  end
end
--
function M:create(UI)
  -- print("create", self.name)
  local rootGroup = UI.editor.rootGroup

  self.x = display.contentCenterX + 280
  self.y = display.actualContentHeight - 10

  local function tap(event)
    -- print("tap")
    if event.eventName == "toggle" then
      if self.objs[event.eventName].text == "show" then
        self.objs[event.eventName].text = "hide"
      else
        self.objs[event.eventName].text = "show"
      end
    else
      UI.scene.app:dispatchEvent {
        name = "editor.replacement.list." .. event.eventName,
        UI = UI,
        index = self.index
      }
    end
    return true
  end

  local options = {
    parent = rootGroup,
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
    rootGroup:insert(rect)
    rootGroup:insert(obj)
    rect:setFillColor(0, 0, 0.8)
    obj.rect = rect
    -- rect.anchorX = 0

    self.objs[params.eventName] = obj
    return obj.rect
  end

  -- local obj = createButton {
  --   text = "New",
  --   x = display.contentCenterX - 210,
  --   y = display.actualContentHeight-10,
  --   eventName = "create"
  -- }

  -- obj = createButton {
  --   text = "Copy",
  --   x = display.contentCenterX - 170,
  --   y = display.actualContentHeight-10,
  --   eventName = "copy"
  -- }

  -- obj = createButton {
  --   text = "Paste",
  --   x = display.contentCenterX -130,
  --   y = obj.y,
  --   eventName = "paste"
  -- }

  local obj =
    createButton {
    text = "Delete",
    x = self.x,
    y = self.y,
    eventName = "delete"
  }

  -- obj = createButton {
  --   text = "hide",
  --   x = obj.x + obj.width+10,
  --   y = obj.y,
  --   eventName = "toggle"
  -- }

  obj =
    createButton {
    text = "Save",
    x = obj.x + obj.width + 10,
    y = display.actualContentHeight - 10,
    eventName = "save"
  }
  obj =
    createButton {
    text = "Cancel",
    x = obj.x + obj.width,
    y = obj.y,
    eventName = "cancel"
  }

  obj =
  createButton {
  text = "Preview",
  x = obj.x + obj.width + 10,
  y = obj.y,
  eventName = "preview"
}

  -- rootGroup.replacementlistButtons = self
  self:hide()

end
--
function M:didShow(UI)
  for k, obj in pairs(self.objs) do
    obj:addEventListener("tap", obj)
  end
  self.UI = UI
  self:hide()
end
--
function M:didHide(UI)
  for k, obj in pairs(self.objs) do
    obj:removeEventListener("tap", obj)
  end
end
--
function M:destroy()
end

function M:toggle()
  for k, obj in pairs(self.objs) do
    obj.isVisible = not obj.isVisible
    obj.rect.isVisible = obj.isVisible
  end
end

function M:show()
  for k, obj in pairs(self.objs) do
    obj.isVisible = true
    obj.rect.isVisible = obj.isVisible
  end
  self.isVisible = true

  self.onKeyEvent = function(event)
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    -- print(message)
    --for k, v in pairs(event) do print(k, v) end
    if isCancel(event) then
      self.UI.scene.app:dispatchEvent {
        name = "editor.replacement.list.cancel",
        UI = self.UI
      }
      --Android, prevent it from backing out of the app
      return true
    end
    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
  end

  keyEventManager.register("replacementListButtons", self.onKeyEvent, 1)
end

function M:hide()
  for k, obj in pairs(self.objs) do
    obj.isVisible = false
    obj.rect.isVisible = obj.isVisible
  end
  self.isVisible = false

  keyEventManager.unregister("replacementListButtons")
end

--
return M
