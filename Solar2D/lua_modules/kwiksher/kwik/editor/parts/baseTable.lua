local name = ...
local parent,     root, M = newModule(name)
local propsTable = require(parent .. "propsTable")
local bt         = require(kwikGlobal.ROOT .. "editor.controller.BTree.btree")
local tree       = require(kwikGlobal.ROOT .. "editor.controller.BTree.selectorsTree")
local btNodeName = "select component"
local muiIcon    = require(kwikGlobal.ROOT.."components.mui.icon").new()

local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")
local contextButtons = require(kwikGlobal.ROOT.."editor.parts.buttons")
local util = require(kwikGlobal.ROOT.."lib.util")

local classProps = require(kwikGlobal.ROOT.."editor.parts.classProps")
local debugName = "_groupTable"

local archInfo = system.getInfo("architectureInfo")
local isWindows = archInfo == "x86" or archInfo == "x64" or
                 archInfo == "IA64" or archInfo == "ARM"

M.x       = 100
M.y       = 66 -- 44
M.marginX = 74
M.marginY = 20

local option, newText = util.newTextFactory{
  x = 0,
  y = nil,
  width = 100,
  height = 20
}

local posX = display.contentCenterX*0.75

function M.mouseHandler(event, class, selections)
  if event.isSecondaryButtonDown then -- event.target.isSelected
    contextButtons:showContextMenu(event.x + 100, event.y,  {target = event.target, class=class, selections=selections})
  else
    -- print("@@@@not selected")
  end
  return true
end

-- target.class will be audio.long or audio.short or audio.sync
-- a sync audio can be multiple

local function onKeyEvent(self, event)
  -- Print which key was pressed down/up
  local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
  -- print(M.name, message)
  -- for k, v in pairs(event) do print(k, v) end
  self.altDown = false
  self.controlDown = false
  if isWindows then
    -- Set altDown to true if both Ctrl and Shift are pressed
    if event.phase == "down" then
      -- printKeys(event)
      self.altDown = event.isCtrlDown and event.isShiftDown
    elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
      self.controlDown = true
    elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
      self.shiftDown = true
    end
    -- print("Alt key pressed: ".. self.name..":".. tostring(M.altDown), event.phase)
  else
    if (event.keyName == "leftAlt" or event.keyName == "rightAlt") and event.phase == "down" then
      -- print("baseTable", self.name, message)
      self.altDown = true
    elseif (event.keyName == "leftControl" or event.keyName == "rightControl") and event.phase == "down" then
      self.controlDown = true
    elseif (event.keyName == "leftShift" or event.keyName == "rightShift") and event.phase == "down" then
      self.shiftDown = true
    end
end
  -- print("controlDown", M.controlDown)
end
--
function M:isAltDown()
  -- print(self.name, "altDown", self.altDown)
    return self.altDown
end
--
function M:isControlDown()
  return self.controlDown
end
--
function M:isShiftDown()
  return self.shiftDown
end
---
function M:init(UI, marginX, marginY)
  self.selection = nil
  self.lastSelection = nil
  if type(marginX) == "table" then
    -- print("####", self.name)
    -- print(debug.traceback())
  end
  self.marginX = marginX or self.marginX
  self.marginY = marginY or self.marginY
end

function M:tick(e)
  -- print("listener")
  -- print("", e.isActive, e.wasActive, e.status  )
  if self.selection == nil then
    return
  end
  local rect = self.selection.rect
  if e.isActive then
    if e.status == bt.RUNNING then
      rect:setFillColor(0, 0, 1)
    elseif e.status == bt.SUCCESS then
      rect:setFillColor(0, 1, 0)
    else
      rect:setFillColor(1, 0.5, 0)
    end
  else
    -- print("not active")
    rect:setFillColor(0.8)
  end
end

function M:setIndent( x, y)
  self.marginX = x or 74
  self.marginY = y or 20
end

function M:setPosition()
  -- print(debug.traceback())
  -- print("setPosition is not implemented")
end
--
function M:initScene(UI)
  self.rootGroup = UI.editor.rootGroup
  self.group = display.newGroup()
  --
  if self.tick then
    self.group.tick = function(e)
      self:tick(e)
    end
    self.group:addEventListener("tick", self.group)
  end
  --
  local btNodes = tree.tree.conditions.items[btNodeName]
  btNodes[1].viewObj = self.group
  --
  option.y = self.y
  self.option = option
end

--
M.newText = newText
--
function M:commandHandler(eventObj, event)
  local UI = self.UI
  if event.phase == "began" or event.phase == "moved" then
    return
  end
  local fromActive = { selections = {}, layer = UI.editor.currentLayer, class = UI.editor.currentClass, suffix = UI.edtior.currentClassSuffix}
  -- print("fromActive", fromActive.layer, fromActive.class)

  if UI.editor.selections then
    for i, v in next, UI.editor.selections do
      -- print("#", v.layer)
      table.insert(fromActive.selections, v)
    end
  end

  layerTableCommands.clearSelections(self, "audio")

  local target = eventObj -- or event.target
  --UI.editor.currentLayer = target.layer
  --UI.editor.currentClass = target.class
  --
  if target and target.setFillColor then
    target:setFillColor(0, 0, 1)
  end
  if self.selection and self.selection.rect then
    self.selection.rect:setFillColor(0.8)
  end
  --
  if self.altDown then
    if layerTableCommands.showLayerProps(self, target) then
      -- print("TODO show  props", self.id, target.class)
      -- print(target[self.id])
      tree.backboard = {
        show = true,
        class = target.class
      }
      -- for instance, obj.animation = "animA", obj.group = "grouA"
      --  see obj[self.id] = name in render
      --
      tree.backboard[self.id] = target[self.id],
      tree:setConditionStatus("select component", bt.SUCCESS, true)
      tree:setActionStatus("load "..self.id, bt.RUNNING, true)
      tree:setConditionStatus("select "..self.id, bt.SUCCESS)
    end
  elseif self.controlDown then -- mutli selections
    layerTableCommands.multiSelections(self, target)
  else
    if UI.editor.selections then
      for i, v in next, UI.editor.selections do
        -- print("#", v.layer)
        table.insert(fromActive.selections, v)
      end
    end
    --
    if layerTableCommands.singleSelection(self, target) then
      if target.layer then
        UI.editor:setCurrnetSelection(target.layer)
      end
      -- target.isSelected = true
      if target.variable then
        -- print(target.variable)

        if fromActive.class == "button" then -- this means button > onTap > acton > editVar or if, elseif
          local actionCommandPropsTable = require(kwikGlobal.ROOT.."editor.action.actionCommandPropsTable")
           if actionCommandPropsTable:setActiveProp(target.variable) then  -- setActiveProps(layer, class) class is set nil here
            self:hide()
            UI.editor.currentClass = fromActive.class
            UI.editor.currentLayer = fromActive.layer
            UI.editor.currentLayerSuffix = fromActive.suffix
            UI.editor.selections = fromActive.selections
            -- print("@@@@", UI.editor.currentLayer, UI.editor.currentClass)
          end
        else
          -- fromActive == dynamictext
          if classProps:setActiveProp(target.variable, "variable") then
            self:hide()
            UI.editor.currentClass = fromActive.class
            UI.editor.currentLayer = fromActive.layer
            UI.editor.currentLayerSuffix = fromActive.suffix
            UI.editor.selections = fromActive.selections
            -- print("@@@@", UI.editor.currentLayer, UI.editor.currentClass)
          end
        end
      else
        if target.name then
          -- print("### currentClass ##")
          UI.editor.currentClass = target.name
          UI.editor.currentClassSuffix = target.suffix
        end
      end
      -- printKeys(target)
    end
  end
  UI.editor.selections = self.selections
  return true

end
-- icons
function M:createIcons (_marginX, _marginY)
  -- print("@@@@@@@@@ createIcons", self.anchorName, self.marginX, _marginY)
  local marginX = _marginX or self.marginX
  local marginY = _marginY or 0
  self:setPosition()
  --
  for i=1, #self.icons do
    local name = self.icons[i]

    local posX = self.x + marginX
    local posY = self.y -33 + marginY
    -- print(name, posX, posY)

    local obj = muiIcon:create {
      icon = {name.."_over", name.."Color_over", name},
      text = "",
      name = name.."-icon",
      x = posX + i*22,
      y = posY,
      width = 22,
      height = 22,
      fontSize =16,
      fillColor = {1.0},
      listener = function(event)
        -- should we use BT with "add component"?
        -- for k, v in pairs(event.target.muiOptions) do print(k, v) end
        local name = event.target.muiOptions.name

        local class = self.id
        -- print(class)
        -- if name == "trash-icon" then
        --   -- for a class is selected, we need a class value
        --   class = self.UI.editor.currentClass or self.id
        -- end

        local subclass = ""
        if self.selections and self.selections[1] then
          subclass = self.selections[1].subclass
        end

        if self.anchorName then
          if name == "trash-icon" then
            -- print("@@@@", class)
            self.UI.scene.app:dispatchEvent {
              name = "editor.classEditor.delete",
              UI = self.UI,
              class = class,
              subclass = subclass,
              icon = name,
              isNew = (name ~= "trash-icon" and name ~="Properties-icon"),
              isDelete = (name == "trash-icon")
            }
          else
            self.UI.scene.app:dispatchEvent {
              name = "editor.selector."..self.anchorName,
              UI = self.UI,
              class = class,
              subclass = subclass,
              icon = name,
              isNew = (name ~= "trash-icon" and name ~="Properties-icon"),
              isDelete = (name == "trash-icon")
            }
          end
        else -- use icon.eventMap
          print("use icon.eventMap",name)
          local eventName = self.eventMap[name:gsub("-icon", "")] or self.anchorName
          self.UI.scene.app:dispatchEvent {
            name = "editor.selector."..eventName,
            UI = self.UI,
            class = class,
            subclass = subclass,
            icon = name,
            isNew = (name ~= "trash-icon" and name ~="Properties-icon"),
            isDelete = (name == "trash-icon")
          }
        end
        --
        if  self.selections and #self.selections > 0 then
          for i = 1, #self.selections do
            if self.selections[i].rect then
              self.selections[i].rect:setFillColor(0.8)
            end
          end
       end
       self.selections = {}
       self.selection = nil
        --
      end,
    }
    self.iconObjs[#self.iconObjs + 1] = obj
    self.group:insert(obj)
  end
end
--
function M:create(UI)
  -- if self.rootGroup then
  --   return
  -- end
  if self.name == debugName then
    print("create", self.id)
  end
  self.selections = {}
  self:initScene(UI)
  --
  local function render(models, xIndex, yIndex)
    local count = 0
    local option = self.option
    ---[[
    self:setPosition()
    for i = 1, #models do
      local name = models[i]
      option.text = name
      option.x = self.x + self.marginX + xIndex * 5
      option.y = self.y + self.marginY + option.height * (count-1)
      -- print(name, option.x, option.y)
      option.width = 100
      local obj = newText(option)
      obj[self.id] = name
      obj[self.type] = name
      obj.index = i
      obj.class = self.id
      -- obj.touch = commandHandler
      -- obj:addEventListener("touch", obj)
      --
      obj.touch = function(eventObj, event)
        self:commandHandler(eventObj, event)
        self.selections = UI.editor.selections
        if self.selection then
          -- self.selection.rect:setFillColor(0,1,0)
          self.selection.rect:setStrokeColor(0,1,0)
          self.selection.rect.strokeWidth = 1
        end
      end
      obj:addEventListener("touch", obj)
      obj:addEventListener("mouse", function(event)
        -- print("self.type", self.type)
        self.mouseHandler(event, self.id, self.selections)
      end)
      --
      local rect = display.newRect(obj.x, obj.y, obj.width + 10, option.height)
      rect:setFillColor(0.8)
      rect.strokeWidth = 1
      self.group:insert(rect)
      self.group:insert(obj)
      --
      count = count + 1
      obj.rect = rect
      self.objs[#self.objs + 1] = obj
    end

    --]]
    if self.name == debugName then
      print(#self.objs)
    end
  -- self.group.isVisible = true
  end

  -- print("@@@@", UI.editor.currentClass)

  UI.editor[self.id.."Store"]:listen(
    function(foo, fooValue)
      -- print("@@@@", self.id)
      self:destroy()
      self.selection = nil
      self.selections = {}
      self.objs = {}
      self.iconObjs = {}
      if fooValue.value then
        render(fooValue.value, 0, 0)
        if #fooValue.value == 0 then
           self:createIcons(120, 5)
        else
           self:createIcons()
        end
      end
      --
      self.rootGroup:insert(self.group)
      self.rootGroup[self.id.."Table"] = self.group

      -- print(self.id,  #self.objs)
      if fooValue.value  then
        -- print(debug.traceback())
        self:show()
      else
        self:hide()
      end
    end
  )
end
--
function M:didShow(UI)
  self.UI = UI
  -- print(self.name, "didShow")
  self.keyListener = function(event) onKeyEvent(self, event)end
  Runtime:addEventListener("key", self.keyListener)
end

--
function M:didHide(UI)
  -- print(self.name, "didHide")
  Runtime:removeEventListener("key", self.keyListener)
end

function M:show()
  if self.name == debugName then
    print(self.name, "show", #self.objs)
  end
  if self.group then
    self.group.isVisible = true
    self.group:toFront()
  end
  if self.objs then
    for i=1, #self.objs do
      self.objs[i].isVisible = true
      self.objs[i].rect.isVisible = true
      self.objs[i].rect:toFront()
      self.objs[i]:toFront()
      if self.objs[i].toggleButton then
        self.objs[i].toggleButton.isVisible = true
      end
    end
  end
  if self.iconObjs then
    for i, v in next, self.iconObjs do
      v.isVisible = true
    end
  end
end

function M:hide()
  if self.name == debugName then
    print(self.name, "hide")
  end
  if self.group then
    self.group.isVisible = false
  end
  if self.objs then
    for i=1, #self.objs do
      -- print(self.objs[i].text)
      self.objs[i].isVisible = false
      self.objs[i].rect.isVisible = false
      if self.objs[i].toggleButton then
        self.objs[i].toggleButton.isVisible = false
      end
    end
  end

  if self.iconObjs then
    for i, v in next, self.iconObjs do
      v.isVisible = false
    end
  end

  -- for i=1, #self.objs do
  --   self.objs[i].isVisible = false
  -- end
end
--
function M:destroy()
  -- print(self.name)
   if self.name == debugName then
    print("`@@@", self.name, "destroy")
    -- print(debug.traceback())
  end
  if self.objs then
    for i = 1, #self.objs do
      if self.objs[i].toggleButton then
        self.objs[i].toggleButton:removeSelf()
      end
      if self.objs[i].rect  and self.objs[i].rect.removeSelf then
        self.objs[i].rect:removeSelf()
      end
      if self.objs[i] and self.objs[i].removeSelf then
        self.objs[i]:removeSelf()
      end
    end
  end
  if self.iconObjs then
    for i, v in next, self.iconObjs do
      if v.removeSelf then
        v:removeSelf()
      end
    end
  end
  self.iconObjs = nil
  self.objs = nil
  self.selection = nil
  --
  if self.rootGroup then
    self.rootGroup[self.id.."Table"] = nil
  end
end

function M:clean()
  -- if self.name == debugName then
    -- print("clean", self.name)
  -- end
  if self.objs then
    for i, obj in next, self.objs do
      if obj.rect and obj.removeSelf then
        obj.rect:removeSelf()
      end
      if obj.removeSelf then
        obj:removeSelf()
      end
    end
    self.objs = nil
  end
  if self.iconObjs then
    for i, v in next, self.iconObjs do
      if v.removeSelf then
        v:removeSelf()
      end
    end
  end
  self.iconObjs = nil
  self.selection = nil
  -- print(debug.traceback())
end

M.new = function(instance)
  if instance.name == debugName then
    print("new")
  end
  if instance.objs  then
    for i = 1, #instance.objs do
      instance.objs[i].rect:removeSelf()
      instance.objs[i]:removeSelf()
    end
  end
  if instance.iconObjs then
    for i, v in next, instance.iconObjs do
      v:removeSelf()
    end
  end
  instance.objs = {}
  instance.iconObjs = {}

  return setmetatable(instance, {__index=M}), bt, tree
end
--
return M
