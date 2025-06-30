local current = ...
local parent,  root, M = newModule(current)

M.name = current
M.weight = 1
M.width = 60

local App = require("Application")
local keyEventManager = require("editor.keyEventManager")

local screen = require("spyric.screen")

local selectbox = require(parent.."selectbox")
--
-- local button = require("com.gieson.Button")
-- local tools = require("com.gieson.Tools")
---
local _contextMenus = {"create", "rename", "modify","openEditor", "copy", "paste", "delete"}
M.contextButtons = _contextMenus
-- M.contextButtons = table:mySet{"edit", "copy", "paste", "delete"}


M.commands = {"create", "shape.new_rectangle", "shape.new_ellipse", "shape.new_text",
  "rename",
  "modify", "shape.move", "shape.scale", "shape.rotate",
  "openEditor",
  "copy", "paste", "delete",
  "toggle",
  "save", "cancel"}

M.objs = nil

local isCancel = function(event)
  local ret = event.phase == "up" and event.keyName == 'escape'
  return ret or (system.getInfo("platform") == "android" and event.keyName == "back")
end

---
function M:init(UI, toggleHandler)
  -- singleton?? ---
  -- if self.objs then return end
  --
  -- if self.id ~="physics" then
  --   print (debug.traceback())
  -- end

  self.objs = {}
  ---
    local app = App.get()
    for i = 1, #self.commands do
      local eventName =  "editor.classEditor." .. self.commands[i]
      if app.context.commands[eventName] == nil then
        app.context:mapCommand(
          eventName,
          "editor.controller." .. self.commands[i]
        )
      end
    end
  self.togglePanel = toggleHandler
end
--
function M:create(UI)
  self.UI = UI
  -- print("create", self.name)
  --
  -- singleton ---
  if self.objs and next(self.objs) then return end
  self.objs = {}

  -- print(debug.traceback())
  ---
  local group = display.newGroup()
  self.group = group

  local function tapHandler(event)
    print("tap", event.target.eventName)
    return true
  end

  local function touchHandler(event)
    -- print("touch", event.eventName)
    if event.phase == "began" or event.phase == "moved" then return true end
    if event.eventName == "toggle" then
      self.togglePanel(true)
      local obj = self.objs[event.eventName]
      if obj.text == "show" then
        obj.text = "hide"
      else
        obj.text = "show"
      end
    else
      local props = {}
      transition.from(obj, {time=500, xScale=2, yScale=2})

      -- if event.eventName == "copy" then
      -- elseif event.eventName == "save" then
      --   props = UI.useClassEditorProps()
      --   print("saving props") -- if nil, command from dispathEvent will skip the process by checking props null
      --    for k, v in pairs(props) do print("",k, v) end
      --    if props.properties then
      --       for k, v in pairs(props.properties) do print("",k, v) end
      --     end
      -- end

      -- if props then
        -- props.layer=self.UI.editor.currentLayer
        -- props.class= self.UI.editor.currentClass
        -- props.selections = self.UI.editor.selections
      -- end
      -- close context menu
      -- for i, key in next, self.contextButtons do
      --   if key == event.eventName then
      --     self:hide()
      --     break
      --   end
      -- end
      --
      self:hide()
      --
      if self.contextMenuOptions then
        props.layer = self.contextMenuOptions.layer
        props.class = self.contextMenuOptions.class -- type timerTable like "timers" "joints" "variables"
        props.book  = self.contextMenuOptions.book
        props.page  = self.contextMenuOptions.page
        props.audio = self.contextMenuOptions.audio
        props.group  = self.contextMenuOptions.group
        props.type = self.contextMenuOptions.type -- for audio only
        props.selections = self.contextMenuOptions.selections -- for audio, group, timer etc
        props.target     = self.contextMenuOptions.target

        --print(self.contextMenuOptions.class)
        --
        -- {class=event.target.text, selections={event.target},
        -- contextMenu = {"create", "rename", "delete"}, orientation = "horizontal"})

      end

      -- print("buttons", "editor.classEditor." .. event.eventName, props.layer, props.class)

      self.UI.scene.app:dispatchEvent {
        name = "editor.classEditor." .. event.eventName,
        UI = self.UI,
        decoded = selectbox.decoded,
        props = props
      }
    end
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
    options.text = params.text
    options.x = params.x
    options.y = params.y

    local obj = display.newText(options)
    -- obj.anchorY=0.5
    -- obj.anchorX = 0
    obj.eventName = params.eventName
    obj:translate(obj.width/2 + 10, 0)
    obj.contextButton = params.contextButton

    local rect = display.newRoundedRect(obj.x, obj.y, obj.width+10, obj.height + 2, 10)
    group:insert(rect)
    group:insert(obj)
    rect:setFillColor(0, 0, 0.8)
    obj.rect = rect
    --
    obj.rect.touch = touchHandler
    obj.rect.eventName = params.eventName

    obj.alignment = params.alignment
    -- rect.anchorX = 0
    if params.objs then
      params.objs[params.eventName] = obj
    end
    obj.originalX = obj.x
    obj.originalY = obj.y
    return obj
  end

  local function createButtonsInRow(obj, params)
    local objs = {}
    for i, v in next, params do
      v.x = obj.x  + obj.width/2 + obj.width*(i-1)
      v.y = obj.y
      local _obj = createButton(v)
      v.x = _obj.x + _obj.rect.width
      objs[#objs+1] =_obj
      _obj.alpha= 0
      _obj.rect.alpha = 0
    end
    return objs
  end

  local obj = createButton {
    text = "New",
    x = display.contentCenterX - 480/2,
    y = display.actualContentHeight-10,
    eventName = "create",
    alignment = "left",
    objs = self.objs,
    contextButton = true
  }

  obj.rect.buttonsInRow = createButtonsInRow(
    obj.rect, {
    {text = "rectangle", eventName="shape.new_rectangle"},
    {text = "ellipse", eventName="shape.new_ellipse"},
    {text = "text", eventName="shape.new_text"},
  })

  -- print("@@@", #obj.rect.buttonsInRow)

  obj = createButton {
    text = "Edit",
    x = obj.rect.contentBounds.xMax,-- display.contentCenterX - 210,
    y = display.actualContentHeight-10,
    eventName = "modify",
    alignment = "left",
    objs = self.objs,
    contextButton = true
  }

  obj.rect.buttonsInRow = createButtonsInRow(
    obj.rect, {
    {text = "move", eventName="shape.move"},
    {text = "scale", eventName="shape.scale"},
    {text = "rotate", eventName="shape.rotate"},
  })

  obj = createButton {
    text = "Copy",
    x = obj.rect.contentBounds.xMax,-- x = display.contentCenterX - 170,
    y = display.actualContentHeight-10,
    eventName = "copy",
    alignment = "left",
    objs = self.objs
  }

  obj = createButton {
    text = "Paste",
    x = obj.rect.contentBounds.xMax, --x = display.contentCenterX -130,
    y = obj.y,
    eventName = "paste",
    alignment = "left",
    objs = self.objs
  }

  obj = createButton {
    text = "Delete",
    x = obj.rect.contentBounds.xMax,
    y = obj.y,
    eventName = "delete",
    alignment = "left",
    objs = self.objs,
    contextButton = true
  }

  obj = createButton {
    text = "hide",
    x = obj.rect.contentBounds.xMax,
    y = obj.y,
    eventName = "toggle",
    alignment = "left",
    objs = self.objs,
    contextButton = true
  }

  obj = createButton {
    text = "Save",
    x = obj.rect.contentBounds.xMax, --x = display.contentCenterX + 45,
    y = display.actualContentHeight-10,
    eventName = "save",
    alignment = "right",
    objs = self.objs
  }
  obj = createButton {
    text = "Cancel",
    x = obj.rect.contentBounds.xMax,
    y = obj.y,
    eventName = "cancel",
    alignment = "right",
    objs = self.objs
  }

  obj = createButton {
    text = "In vscode",
    x = obj.rect.contentBounds.xMax,
    y = obj.y,
    eventName = "openEditor",
    alignment = "right",
    objs = self.objs,
    contextButton = true
  }

  obj = createButton {
    text = "Rename",
    x = obj.rect.contentBounds.xMax,
    y = obj.y,
    eventName = "rename",
    alignment = "right",
    objs = self.objs,
    contextButton = true
  }

  self.openEditorObj = obj
  self.openEditorObj.originalText = obj.text

  for k, obj in pairs(self.objs) do
    -- print(obj.eventName)
    obj.rect:addEventListener("touch", obj.rect)
    obj.rect:addEventListener("tap", tapHandler)

    if obj.rect.buttonsInRow then
      for kk, button in pairs(obj.rect.buttonsInRow) do
        button.rect:addEventListener("touch", button.rect)
        button.rect:addEventListener("tap", tapHandler)
      end
    end
  end

  self.UI.editor.rootGroup:insert(group)
  self.UI.editor.rootGroup.buttons = group

  group.split = function()
    local leftPosX, rightPosX = screen.safe.minX + 30 , screen.centerX + 480*0.5
    -- print(leftPosX, rightPosX)
    for i, eventName in next, self.commands do
      if self.objs then
        local obj = self.objs[eventName]
        if obj == nil then
          -- print(eventName)
        elseif obj.alignment == "left" then
        obj.x = leftPosX
        obj.rect.x = leftPosX
        leftPosX = leftPosX + obj.rect.width
        elseif obj.alignment == "right" then
          obj.x = rightPosX
          obj.rect.x = rightPosX
          rightPosX = rightPosX + obj.rect.width
        end
      end
    end

  end
  --
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
  -- print(debug.traceback())
  self:hide()
  -- print("buttons:destroy()")
  -- if self.objs then
  --   for k, obj in next, self.objs do
  --     obj.rect:removeEventListener("tap", obj)
  --     obj.rect:removeSelf()
  --     obj:removeSelf()
  --     if obj.rect.buttonsInRow then
  --       for k, o in next, obj.rect.buttonsInRow do
  --         o.rect:removeEventListener("mouse", self.mouseOverInRow)
  --         o.rect:removeSelf()
  --       end
  --     end
  --   end
  -- end
  -- self.objs = nil
end

function M:toggle()
  for k, obj in pairs(self.objs) do
    obj.isVisible = not obj.isVisible
    obj.rect.isVisible = obj.isVisible
  end
end

function M.mouseOver(event)
  local obj = M.lastButtonRect
  if obj then
    obj.alpha = 0.5
    if obj.buttonsInRow then
      for k, o in next, obj.buttonsInRow do
        o.isVisible = false
        o.rect.isVisible = false
      end
    end
  end
  --
  local target = event.target
  target.alpha = 1
  --
  obj = M.lastButtonRectInRow
  if obj then
    obj.alpha = 0.5
  end
  --
  if target.buttonsInRow and M.contextMenuOptions.class == "" and M.contextMenuOptions.isMultiSelection==false then
    for k, o in next, target.buttonsInRow do
      o.isVisible = true
      o.alpha = 1
      o.rect.isVisible = true
    end
  end
  M.lastButtonRect = target
end

function M.mouseOverInRow(event)
  local obj = M.lastButtonRectInRow
  if obj then
    obj.alpha = 0.5
  end
  local target = event.target
  target.alpha = 1
  M.lastButtonRectInRow = target
end

function M:showContextMenu(x,y, options)
  if self.isLoaded then
    self:hide()
    self.isLoaded = false
    return
  end
  self.isLoaded = true
  self.contextMenuOptions = options
  if options then
    self.contextButtons = options.contextButtons or _contextMenus
  end

  local function filterVisible(key)
    if key == "rename" then
      if self.contextMenuOptions.isMultiSelection then
        return false
      end
      if self.contextMenuOptions.class and self.contextMenuOptions.class:len() > 0 then
        return false
      end
    end

    if key == "create" then
      if self.contextMenuOptions.shapedWith then
        return true
      else
        return false
      end
    end
    return true
  end

  local index = 0
  local pos ={x=x, y=y}
  -- print("showContextMenu", x, y)

  for i, key in next, self.contextButtons do
    for k, obj in next, self.objs do
      if key  == obj.rect.eventName and filterVisible(key) then
        obj.isVisible = true
        obj.rect.isVisible = obj.isVisible

        if options and options.orientation =="horizontal" then
          pos.x = pos.x + obj.rect.width
        else
          pos.y = pos.y + obj.rect.height
        end
        obj.x = pos.x
        obj.y = pos.y

        index = index + 1
        obj.rect.x = obj.x
        obj.rect.y = obj.y
        obj.rect.alpha = 0.5
        -- obj.rect:toFront()
        -- obj:toFront()
        obj.rect:addEventListener("mouse", self.mouseOver)
        --
        -- for buttons in row
        --
        -- print(key, obj.rect.eventName, (options or {}).isPageContent )
        -- print(self.contextMenuOptions.shapedWith, obj.rect.buttonsInRow  )
        if self.contextMenuOptions.shapedWith and obj.rect.buttonsInRow and not (options or {}).isPageContent then
          local index = 1
          local pos_x=0
          print(key)
          for i, o in next, obj.rect.buttonsInRow do
            print("",i, o.text)
            o.isVisible = false
            o.rect.isVisible = o.isVisible
            -- if options and options.orientation =="horizontal" then
              o.x = obj.x + obj.rect.width + 10 + pos_x
              o.y = obj.y
              pos_x = pos_x + o.rect.width
              index = index + 1
            -- else
            --   o.x = x --+ o.width
            --   o.y = y + indexY * o.rect.height
            --   indexY = indexY + 1
            -- end
            o.rect.x = o.x
            o.rect.y = o.y
            o.rect.alpha = 0.5
            -- o.rect:toFront()
            -- o:toFront()
            o.rect:addEventListener("mouse", self.mouseOverInRow)
          end
        end
        break
      end
    end
  end
  self.group:toFront()
end

function M:hideContextMenu()
  self.contextMenuOptions = nil -- "actionTable"
  self.contextButtons = _contextMenus
  self.openEditorObj.text = self.openEditorObj.originalText

  if self.objs then
    for k, obj in pairs(self.objs) do
      if obj.contextButton or obj.text == "Copy" or obj.text == "Paste" then
        obj.isVisible = false
        obj.rect.isVisible = false
        if obj.rect.buttonsInRow then
          for i, o in next, obj.rect.buttonsInRow do
            o.isVisible = false
            o.rect.isVisible = false
          end
        end
      end
    end
  end

end

function M:show()
  -- print("@ show", self.id)
  -- print(debug.traceback())

  for k, obj in pairs(self.objs) do
    -- print(obj.text, obj.x, obj.y)
    obj.x = obj.originalX
    obj.y = obj.originalY
    obj.rect.x = obj.x
    obj.rect.y = obj.y
    obj.rect.alpha = 1

    if not obj.contextButton then
      obj.isVisible = true
      obj.rect.isVisible = true
      obj.rect:removeEventListener("mouse", self.mouseOver)
      if obj.rect.buttonsInRow then
        for i, o in next, obj.rect.buttonsInRow do -- mouse over to show them
          o.isVisible = false
          o.rect.isVisible = false
          -- o.alpha = 0
          -- o.rect.alpha = 0
          o:removeEventListener("mouse", self.mouseOverInRow)
        end
      end
    end
  end

  self.onKeyEvent = function(event)
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    -- print(message)
    --for k, v in pairs(event) do print(k, v) end
    if isCancel(event)  then
      self.UI.scene.app:dispatchEvent {
        name = "editor.classEditor.cancel",
        UI = self.UI,
      }
      --Android, prevent it from backing out of the app
      return true
    end
    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
  end

  keyEventManager.register("partsButtons_" .. (self.id or "default"), self.onKeyEvent, 1)

end

function M:hide()
  -- print("@ hide", self.id)
  if self.objs then
    for k, obj in pairs(self.objs) do
      obj.isVisible = false
      obj.rect.isVisible = false
      if obj.rect.buttonsInRow then
        for i, o in next, obj.rect.buttonsInRow do
          o.isVisible = false
          o.rect.isVisible = false
        end
      end

    end
  end
  keyEventManager.unregister("partsButtons_" .. (self.id or "default"))
  self.openEditorObj.text = self.openEditorObj.originalText

end

M.new = function(id)
  local instance = {id=id}
  return setmetatable(instance, {__index=M})
end
--
return M
