local name = ...
local parent,root = newModule(name)

local props = require(root.."model").pageTools.group
props.anchorName = "selectGroup"
props.icons      = {"groups", "trash"}
props.type       = "groups"

local M = setmetatable({name="groupTable"}, {__index=require(root.."parts.layerTable")})

local bt = require(root .. "controller.BTree.btree")
local tree = require(root .. "controller.BTree.selectorsTree")

local actionCommandPropsTable = require(kwikGlobal.ROOT.."editor.action.actionCommandPropsTable")
local buttons                 = require(kwikGlobal.ROOT.."editor.parts.buttons")
local classProps              = require(kwikGlobal.ROOT.."editor.parts.classProps")
local classPropsPhysics         = require(kwikGlobal.ROOT.."editor.physics.classProps")

M.anchorName = "selectGroup"
M.icons      = {"groups", "trash"}
M.type       = "groups"
M.id         = "group"

M.x = display.contentCenterX
M.y = 20

M.indentX = 0
M.indentY = 0

function M:init(UI, x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function M:setIndent( x, y)
  self.indentX = x
  self.indentY = y
end

-- function M:setPosition()
--   self.x = self.rectWidth/2 + 22
--   self.y = self.rootGroup.selectLayer.y + marginY
-- end

local layerTableCommands = require(kwikGlobal.ROOT.."editor.parts.layerTableCommands")

function M:commandHandler(eventObj, event)
  -- print("@@@@@@@@@@ commandHandler")
  if event.phase == "began" or event.phase == "moved" then
    return
  end
  local UI = self.UI

  local fromActive = { selections = {}, layer = UI.editor.currentLayer, class = UI.editor.currentClass, suffix = UI.editor.currentClassSuffix}
  print("fromActive", fromActive.layer, fromActive.class)
  if UI.editor.selections then
    for i, v in next, UI.editor.selections do
      print("#", v.layer)
      table.insert(fromActive.selections, v)
    end
  end

  layerTableCommands.clearSelections(self, "group")

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
      -- print("@@@@@TODO show group props", target.id, target.text)
      -- print(target[self.id])
      tree.backboard = {
        show = true,
        class = "group",
        group = target.text
      }
      -- for instance, obj.animation = "animA", obj.group = "grouA"
      --  see obj[self.id] = name in render
      --
      --tree.backboard[self.id] = target[self.id],
      tree:setConditionStatus("select component", bt.SUCCESS, true)
      tree:setActionStatus("load "..self.id, bt.RUNNING, true)
      tree:setConditionStatus("select "..self.id, bt.SUCCESS)
    end
  elseif self.controlDown then -- mutli selections
    layerTableCommands.multiSelections(self, target)
  else
    if layerTableCommands.singleSelection(self, target, true) then -- isNotLayer == true
      self.UI.editor.currentLayer = target.layer
      self.UI.editor:setCurrnetSelection(target.layer, target.name, "group") -- _type == group, page, sprite
      -- print("@@@@@@", target.layer, target.class)
      if classPropsPhysics:setActiveProp(target.layer, target.class) then
        self:hide()
        UI.editor.currentClass = fromActive.class
        UI.editor.currentLayer = fromActive.layer
        -- print(UI.editor.currentLayer)
        UI.editor.selections = fromActive.selections
        -- local json = require("json")
        -- print(json.prettify(UI.editor.selections))
        return true
      end
    end
  end
  -- print("@@@@", #self.selections)
  self.UI.editor.selections = self.selections

  return true

end



function M:commandHandlerClass(target, event)
  -- print("@@@@@@ commandHandlerClass", target.layer, target.text)
  local class = target.text
  local UI = self.UI
  if event.phase == "began" or event.phase == "moved" then
    return
  end
  --
  layerTableCommands.clearSelections(self, "class")
  --
  buttons:hide()
  --
  UI.editor:setCurrnetSelection(target.layer, class, "group") -- _type == group, page, sprite
  -- print("@@@@", UI.editor.currentType)

  if self:isAltDown() then
    -- print("", "isAltDown")
    --showClassProps(self, target, "group")
    if self.selection ~= target then
      self.selection = target
      for i = 1, #self.selections do
        self.selections[i].rect:setFillColor(0.8)
      end
      --
      self.selections = {target}
      target.isSelected = true
      target.rect:setFillColor(0,1,0)

      UI.scene.app:dispatchEvent {
        name = "editor.selector.selectTool",
        UI = UI,
        class = target.class,
        isNew = false,
        layer = layerName,
      }
    end

  elseif self:isControlDown() then -- mutli selections
    -- print("", "isControlDown")
    layerTableCommands.multiSelections(self, target)
  else
    if layerTableCommands.singleSelection(self, target, true) then -- isNotLayer
      -- print("", "singleSelection")
      actionCommandPropsTable:setActiveProp(target.layer, target.class, target.suffix)
      classProps:setActiveProp(target.layer, target.class, target.suffix)
      -- print("@@@@@@", target.layer, target.class)
      classPropsPhysics:setActiveProp(target.layer, target.class)
    end
  end
  UI.editor.selections = self.selections
  -- print("@@@@", UI.editor.currentType)
  return true
end

local posX = display.contentCenterX * 0.4
local isMultiSelection = false
local buttons = require(kwikGlobal.ROOT.."editor.parts.buttons")
-- See group = true makes rename for handleing group
function M.mouseHandler(event)
  if event.isSecondaryButtonDown and event.target.isSelected then
    -- printKeys(event.target)
    buttons:showContextMenu(posX, event.y, {layer = event.target.layer, group = true, class = event.target.class, isMultiSelection = isMultiSelection})
  else
    -- print("@@@@not selected")
  end
  return true
end


function M:create(UI)
  -- self.commandHandlerClass = layerTableCommands.commandHandlerClass
  -- self.showClassProps = showClassProps
  -- --self.commandHandler = commands.commandHandler

  -- if self.rootGroup then return end
  -- print(debug.traceback())
  self:initScene(UI)
  self.selections = {}

  self.UI = UI

  UI.editor.groupStore:listen(
    function(foo, fooValue)
      -- local json = require("json")
      -- print(json.prettify(fooValue))
      self:destroy()
      self.selection = nil
      self.selections = {}
      self.objs = {}
      self.iconObjs = {}
      if fooValue and fooValue.value then
        -- print("@@@@@", self.indentX, self.indentY)
        self.objs = self:render(fooValue.value, self.indentX, self.indentY)
        if #fooValue.value == 0 then
           self:createIcons(120, 5)
        else
           self:createIcons()
        end
      end
      --
      self.rootGroup:insert(self.group)
      self.rootGroup["groupTable"] = self.group

      -- print(self.id,  #self.objs)
      -- if #self.objs > 0 then
      --   printKeys(self.objs[1])
      -- end

      if fooValue and fooValue.value  then
        -- print(debug.traceback())
        self:show()
      else
        self:hide()
      end
      if fooValue and fooValue.isActiveProp then
        self.group.oriX = self.group.x
        self.group.oriY = self.group.y
        self.group.x = display.contentCenterX+100
        self.group.y = 50 --display.contentCenterY-120
      end

    end
  )
end
return M
