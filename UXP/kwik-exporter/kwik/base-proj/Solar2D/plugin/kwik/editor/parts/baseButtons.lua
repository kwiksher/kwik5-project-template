local M = {}
local current = ...
local parent = current:match("(.-)[^%.]+$")

M.name = current
M.weight = 1

local App = require("Application")
local keyEventManager = require(kwikGlobal.ROOT.."editor.keyEventManager")
-- local rootButtons = require(parent.."buttons")

--
-- local button = require("com.gieson.Button")
-- local tools = require("com.gieson.Tools")
---
M.model = {
  -- {name="copy",   label="Copy"},
  -- {name= "paste", label="Paste"},
  -- {name="preview",label="Preview"},
  -- {name="create", label="New"},
  -- {name="delete", label="Delete"},
  {name="save",   label="Save"},
  {name="cancel", label="Cancel"}}

M.commandClass = "properties"


local isCancel = function(event)
  local ret = event.phase == "up" and event.keyName == 'escape'
  return ret or (system.getInfo("platform") == "android" and event.keyName == "back")
end

---
function M:init(UI)
  self.objs = {}
  local app = App.get()
  for i = 1, #self.model do
    local entry = self.model[i]
    app.context:mapCommand(
      "editor."..self.commandClass.."." .. entry.name,
      "editor.controller."..self.commandClass.."." .. entry.name
    )
  end
end
--
function M:_create(UI)
  self.UI = UI

  -- print("create", self.name)
  local group = display.newGroup()

  local function tapHandler(event)
    -- print("tap", self.UI)
    UI.scene.app:dispatchEvent {
      name = "editor."..self.commandClass.."." .. event.eventName,
      UI = self.UI
    }
  end

  local options = {
    parent = group,
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
    obj.tap = tapHandler
    obj.eventName = params.eventName
    -- obj.anchorX =0

    local rect = display.newRoundedRect(obj.x, obj.y, 40, obj.height + 2, 10)
    group:insert(rect)
    group:insert(obj)
    rect:setFillColor(0, 0, 0.8)
    obj.rect = rect
    -- rect.anchorX = 0

    self.objs[params.eventName] = obj
    return obj
  end

  for i=1, #self.model do
    local entry = self.model[i]
    if i ==1 then
      entry.obj = createButton {
        text = entry.label,
        x = display.contentCenterX,
        y = display.actualContentHeight-10,
        eventName = entry.name
      }
    else
      entry.obj = createButton {
        text = entry.label,
        x = 10 + self.model[i-1].obj.x + self.model[i-1].obj.width,
        y = display.actualContentHeight-10,
        eventName = entry.name
      }
    end
    -- print(entry.name, entry.obj.x, entry.obj.y)
  end

  -- if not self.isInstance then
  --   UI.editor.rootGroup.propsButtons = group
  --   UI.editor.rootGroup:insert(group)
  --   UI.editor.propsButtons = self
  -- end
  group.isVisible = false
  self.group = group

end

function M:create(UI)
  self:_create(UI)
end
--
function M:didShow(UI)
  -- print(debug.traceback())
  for k, obj in pairs(self.objs) do
    -- print("didShow", obj.text)
    obj:addEventListener("tap", obj)
  end
  self.UI = UI
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
  -- print(self.name, "@@ toggle")
  for k, obj in pairs(self.objs) do
    obj.isVisible = not obj.isVisible
    obj.rect.isVisible = obj.isVisible
  end
end

function M:show()
  -- print(self.name, "@@ show")
  -- print(debug.traceback())

  -- rootButtons:hide()
  -- print(debug.traceback())
  if self.objs == nil then return end
  --
  for k, obj in pairs(self.objs) do
    obj.isVisible = true
    obj.rect.isVisible = obj.isVisible
  end
  if self.group then
    self.group.isVisible = true
    --
    local cancel =  "editor."..self.commandClass..".cancel"
    self.onKeyEvent = function(event)
      if isCancel(event)  then
        self.UI.scene.app:dispatchEvent {
          name = cancel,
          UI = self.UI,
        }
        --Android, prevent it from backing out of the app
        return true
      end
      -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
      -- This lets the operating system execute its default handling of the key
      return false
    end
    --
    -- Register with centralized key event manager
    local handlerId = "baseButtons_" .. self.commandClass
    keyEventManager.register(handlerId, self.onKeyEvent, 1) -- priority 1 for UI elements
  end
end

function M:hide()
  -- print(self.name, "@@ hide")
  -- print(debug.traceback())
  if self.objs == nil then return end
  for k, obj in pairs(self.objs) do
    obj.isVisible = false
    obj.rect.isVisible = obj.isVisible
  end
  if self.group then
    self.group.isVisible = false
    -- Unregister from centralized key event manager
    local handlerId = "baseButtons_" .. self.commandClass
    keyEventManager.unregister(handlerId)
  end
end

M.new = function(instance)
  instance.isInstance = true
	return setmetatable(instance, {__index=M}), bt, tree
end

--
return M
