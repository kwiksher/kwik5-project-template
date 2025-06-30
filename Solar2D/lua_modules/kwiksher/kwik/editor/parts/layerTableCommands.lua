local name = ...
local parent, root = newModule(name)

local M = {} -- layerTable
local bt = require(kwikGlobal.ROOT .. "editor.controller.BTree.btree")
local tree = require(kwikGlobal.ROOT .. "editor.controller.BTree.selectorsTree")

local propsTable = require(kwikGlobal.ROOT.."editor.parts.propsTable")
local actionCommandPropsTable = require(kwikGlobal.ROOT.."editor.action.actionCommandPropsTable")
local classProps = require(kwikGlobal.ROOT.."editor.parts.classProps")
local buttons = require(kwikGlobal.ROOT.."editor.parts.buttons")
local util = require(kwikGlobal.ROOT.."editor.util")

local posX = display.contentCenterX * 0.4

local isLastSelection = "class"
local isMultiSelection = false

function M.mouseHandler(event)
  if event.isSecondaryButtonDown and event.target.isSelected then
    -- {class=event.target.text, selections={event.target},
    -- contextMenu = {"create", "rename", "delete"}, orientation = "horizontal"})
    -- buttons:showContextMenu(posX, posY)
    --for k,v in pairs(event) do print(k, v) end
    -- print("@", event.target.text, event.isSecondaryButtonDown)
    -- local posX, posY = event.target:localToContent(event.target.x, event.target.y)
    -- local posX, posY = event.target:contentToLocal(event.x, event.y)
    -- local posX, posY = event.target:localToContent(event.x, event.y)
    -- print(posX, posY)
    buttons:showContextMenu(posX, event.y, {layer = event.target.layer, class = event.target.class, isMultiSelection = isMultiSelection, shapedWith=event.target.shapedWith})
  else
    -- print("@@@@not selected")
  end
  return true
end

local function clearSelections(layerTable, current)
  if isLastSelection ~= current then
    if layerTable.selections then
      for i, v in next, layerTable.selections do
        v.isSelected = false
        if v.rect.setStrokeColor then
          v.rect:setStrokeColor(0.8)
          v.rect:setFillColor(0.8)
        end
      end
    end
  end
  isLastSelection = current
end

local function multiSelections(layerTable, target)
  if not target.isSelected then
    layerTable.selections[#layerTable.selections + 1] = target
    target.isSelected = true
    target.rect:setFillColor(0, 1, 0)
    target.rect:setStrokeColor(0, 1, 0)
  else
    target.isSelected = false
    target.rect:setFillColor(0.8)
    target.rect:setStrokeColor(0.8)
    for i, v in next, layerTable.selections do
       if v == target then
        table.remove(layerTable.selections, i)
        break
       end
    end
    layerTable.selection = nil
  end
end

local function singleSelection(layerTable, target, isNotLayer)
  local UI = layerTable.UI
  if layerTable.selection == target and target.isSelected then
    -- print("let's toogle")
    target.isSelected = false
    target.rect:setFillColor(0.8)
    for i, v in next, layerTable.selections do
       if v == target then
        table.remove(layerTable.selections, i)
        break
       end
    end
    layerTable.selection = nil
  else
    if layerTable.selections then
      -- print("@@",#layerTable.selections)
      for i = 1, #layerTable.selections do
        local obj = layerTable.selections[i]
        -- print("", obj.text)
        if obj.rect and obj.setFillColor then
          obj.rect:setFillColor(0.8)
          obj.rect:setStrokeColor(0.8)
        end
      end
    end
    layerTable.selection = target
    --
    layerTable.selections = {target}
    target.isSelected = true
    target.rect:setFillColor(0,1,0)
    --target.rect:setStrokeColor(0, 1, 0)
    ---
    if not isNotLayer then
      UI.editor:setCurrnetSelection()
      -- printKeys(target)
      if target.layer and target.layer:len() then
        local name = util.getLayerPath(target)
        UI.editor.currentLayer = name
      elseif target.class == "audio" then
        local name = util.getLayerPath(target)
        UI.editor.currentLayer = name
        UI.editor.currentClass = "audio"
        print(name)
      else
        print("Warning target.layer is not found")
        --print(debug.traceback())
      end
      -- target.isSelected = true
      if target.name and target.variable == nil then
        -- print("### currentClass ##")
        UI.editor.currentClass = target.name
        UI.editor.currentClassSuffix = target.suffix
      end
    end
    return true
    --
  end
end

local function showLayerProps(layerTable, target)
  local UI = layerTable.UI
  local path = util.getParent(target)

  if layerTable.selection == target then
    -- let's toogle
    -- target.isSelected = false
    if propsTable.isVisible then
      -- print("", "hide")
      target:setFillColor(0)
      propsTable:hide()
    else
      target.rect:setFillColor(0, 1, 0)
      propsTable:show()
      return true
    end
  else
    layerTable.selection = target
    if layerTable.selections then
      for i = 1, #layerTable.selections do
        layerTable.selections[i].rect:setFillColor(0.8)
      end
    end
    layerTable.selections = {target}
    target.isSelected = true
    target.rect:setFillColor(0, 1, 0)
    return true
  end
end

local function showFocus(layerTable)
  local UI = layerTable.UI
  if UI.editor.focusGroup then
    UI.editor.focusGroup:removeSelf()
  end
  local group = display.newGroup()
  UI.sceneGroup:insert(group)
  UI.editor.focusGroup = group
  --
  for i, v in next, layerTable.selections do
    local name = v.layer
    -- print(i, v.layer)
    if v.parentObj then
      name = util.getLayerPath(v)
      -- print("", name)
    end
    local obj = UI.sceneGroup[name]
    if obj then
      -- print("@", v.text, obj.x, obj.y)
      local posX, posY = obj.x, obj.y
      local rect = display.newRect(UI.editor.focusGroup, posX, posY, obj.width, obj.height)
      rect:setFillColor(1, 0, 0, 0)
      rect:setStrokeColor(0, 1, 0)
      rect.strokeWidth = 1
      rect.xScale = obj.xScale
      rect.yScale = obj.yScale
      rect.anchorX = obj.anchorX
      rect.anchorY = obj.anchorY
      rect.rotation = obj.rotation
      transition.from(rect, {time=100, xScale=3, yScale=3})
    end
  end
end

function M.commandHandler(layerTable, target, event)
  if event.phase == "began" or event.phase == "moved" then
    return true
  end
  local  UI = layerTable.UI
  local path = util.getParent(target)
  --

  local fromActive = { selections = {}, layer = UI.editor.currentLayer, class = UI.editor.currentClass, suffix = UI.editor.currentClassSuffix}
  -- print("fromActive", fromActive.layer, fromActive.class)

  if UI.editor.selections then
    for i, v in next, UI.editor.selections do
      -- print("#", v.layer)
      table.insert(fromActive.selections, v)
    end
  end

  clearSelections(layerTable, "layer")
  --
  --
  buttons:hideContextMenu()
  ---
  -- print("@@@@@@", layerTable.altDown, layerTable:isAltDown())
  -- print(debug.traceback())

  if layerTable:isAltDown() then
    if showLayerProps(layerTable, target) then
      --
      tree.backboard = {
        layer = target.layer,
        path = path,
        isIndex = target.isIndex,
        -- class = target.class
      }
      -- print("###", target.layer)
      tree:setConditionStatus("select layer", bt.SUCCESS, true)
      tree:setActionStatus("load layer", bt.RUNNING, true)
      tree:setConditionStatus("select props", bt.SUCCESS)

      UI.editor:setCurrnetSelection(target.layer)
      -- UI:dispatchEvent {
      --   name = "editor.selector.selectLayer",
      --   UI = UI,
      --   layer = target.layer,
      --   class = target.class
      -- }
      --
    end
  elseif layerTable:isControlDown() then -- mutli selections
    -- print("multi selection")
    multiSelections(layerTable, target)
    isMultiSelection = true
  else
    isMultiSelection = false
    if singleSelection(layerTable, target) then
      -- should we enable one of them?
      -- print("", "singleSelection")
      local layer = target.layer
      if target.parentObj then
        layer = util.getLayerPath(target)
      end


      if actionCommandPropsTable:setActiveProp(layer, target.class, target.suffix) then
        -- print("@@@ fromActive.class")
        layerTable:hide()
        UI.editor.currentClass = fromActive.class
        UI.editor.currentLayer = fromActive.layer
        UI.editor.currentLayerSuffix = fromActive.suffix
        UI.editor.selections = fromActive.selections
        layerTable.group.x = layerTable.group.oriX
        layerTable.group.y = layerTable.group.oriY
        return -- notice!
      end
      --
      -- setClassProps is used in physics to set the value to physics.classProps
      --
      local classProps = layerTable.classProps or classProps
      if classProps:setActiveProp(layer) then
        layerTable.classProps = nil -- physycis has own classProps
        layerTable:hide()
        -- print("@@@ fromActive.class", fromActive.class)
        UI.editor.currentClass = fromActive.class
        UI.editor.currentLayer = fromActive.layer
        UI.editor.currentLayerSuffix = fromActive.suffix
        UI.editor.selections = fromActive.selections
        layerTable.group.x = layerTable.group.oriX
        layerTable.group.y = layerTable.group.oriY
        return -- notice!
      end
    end
    -- print("UI.editor.currentLayer", UI.editor.currentLayer, UI.editor.currentClass)
    -- if UI.editor.selections then
    --   for i, v in next, UI.editor.selections do
    --     -- print("@", v.layer)
    --   end
    -- end

  end
  --
  -- focus
  --
  showFocus(layerTable)
  --

  if  UI.editor.selections_backup == nil then
    UI.editor.selections = layerTable.selections
    -- print("@@@@@", "UI.editor.selections_backup == nil", target.layer)
    UI.editor.currentClass = ""
    UI.editor.currentLayer = target.layer
  else
    UI.editor.selections = {}
    for i, v in next, UI.editor.selections_backup do
      -- print("recover", i, v.text)
      -- layerTable.selections[i] = v
      UI.editor.selections[i] = v
    end
  end

  -- print("$$$$$$$", UI.editor.currentLayer)

  return true
end

local function showClassProps(layerTable, target)
  local UI = layerTable.UI
  local type = "layer"
  local path = util.getParent(target)
  -- print("@@@@ path", path)

  local layerName = target.layer
  UI.editor:setCurrnetSelection()

  if layerTable.selection == target then
    -- print("dispatch selectTool", layerName, target.class)
    -- target.isSelected = false

    target.rect:setFillColor(0.8)
    UI.scene.app:dispatchEvent {
      name = "editor.selector.selectTool",
      UI = UI,
      class = target.class,
      suffix = target.suffix,
      isNew = false,
      layer = layerName,
      toogle = true -- <========
    }
  else
    layerTable.selection = target
    for i = 1, #layerTable.selections do
      layerTable.selections[i].rect:setFillColor(0.8)
    end
    --
    layerTable.selections = {target}
    target.isSelected = true
    target.rect:setFillColor(0,1,0)

    --
    -- target.isSelected = true
    if target.layer and target.layer:len() then
      local name = util.getLayerPath(target)
      -- print("####", name)
      UI.editor.currentLayer = name
    else
      print("Warning target.layer is not found")
      --print(debug.traceback())
    end
    if target.name and target.variable == nil then
      -- print("### currentClass ##")
      UI.editor.currentClass = target.name
    end

    UI.scene.app:dispatchEvent {
      name = "editor.selector.selectTool",
      UI = UI,
      class = target.class,
      suffix = target.suffix,
      isNew = false,
      layer = layerName,
    }

    --[[
    -- for load layer
    tree.backboard = {
      layer = layerName,
      class = target.class,
      path = path
    }
      tree:setConditionStatus("select "..type, bt.SUCCESS, true)
      tree:setActionStatus("load "..type, bt.RUNNING) -- need tick to process load layer with tree.backboard
      tree:setConditionStatus("select props", bt.FAILED, true)

      -- For editor compoent. this fires selectTool event with backboard params
      tree.backboard.isNew = false

      tree:setConditionStatus("modify component", bt.SUCCESS)
      tree:setActionStatus("editor component", bt.RUNNING, true)
    --]]
  end
end

function M.commandHandlerClass(layerTable, target, event)
  -- print("commandHandlerClass", target.layer, target.text)
  local UI = layerTable.UI
  if event.phase == "began" or event.phase == "moved" then
    return
  end

  local fromActive = { selections = {}, layer = UI.editor.currentLayer, class = UI.editor.currentClass, suffix = UI.editor.currentClassSuffix}

  --
  clearSelections(layerTable, "class")
  --
  buttons:hideContextMenu()
  --
  target.rect:toFront()
  target:toFront()
  if layerTable:isAltDown() then
    -- print("", "isAltDown")
    showClassProps(layerTable, target)
  elseif layerTable:isControlDown() then -- mutli selections
    -- print("", "isControlDown")
    multiSelections(layerTable, target)
    isMultiSelection = true
  else
    isMultiSelection = false
    if singleSelection(layerTable, target) then
      -- print("", "singleSelection")

      local layer = target.layer
      if target.parentObj then
        layer = util.getLayerPath(target)
      end

      if actionCommandPropsTable:setActiveProp(layer, target.class, target.suffix) then
        layerTable:hide()
        UI.editor.currentClass = fromActive.class
        UI.editor.currentClassSuffix = fromActive.suffix
        UI.editor.currentLayer = fromActive.layer
        UI.editor.selections = fromActive.selections
        layerTable.group.x = layerTable.group.oriX
        layerTable.group.y = layerTable.group.oriY
        return -- notice!
      end

      if classProps:setActiveProp(layer, target.class, target.suffix) then
        layerTable:hide()
        print("@@@ fromActive.class", fromActive.class)
        UI.editor.currentClass = fromActive.class
        UI.editor.currentClassSuffix = fromActive.suffix
        UI.editor.currentLayer = fromActive.layer
        UI.editor.selections = fromActive.selections
        layerTable.group.x = layerTable.group.oriX
        layerTable.group.y = layerTable.group.oriY
        return -- notice!
      end

      -- recover selections
      if UI.editor.selections_backup and #UI.editor.selections_backup > 0 then
        UI.editor.selections = {}
        for i, v in next, UI.editor.selections_backup do
          -- print("recover", i, v.text)
          -- layerTable.selections[i] = v
          UI.editor.selections[i] = v
        end
      end
    end
  end

  UI.editor.selections = layerTable.selections

  return true
end
--
-- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectTool",
  --   UI = UI,
  --   class = target.class,
  --   isNew = false,
  --   layer = target.layer
  -- }

  --[[

     print("==== cond")
     tree.tree.conditions:forEach(function(____, c)
       for i=1, #c do
         if c[i].nodeStatus == 1 then
           print("", c[i].name)
         end
       end
     end)

     print("==== action")
     tree.tree.actions:forEach(function(____, a)
       for i=1, #a do
         if a[i].nodeStatus > 0 then
           -- for k, v in pairs(a[i]) do
           --   print("",k, v)
           -- end
           print("", a[i].name, a[i].nodeStatus, a[i]._active)
         end
       end
     end)
     --]]
--
M.singleSelection = singleSelection
M.clearSelections = clearSelections
M.multiSelections = multiSelections
M.showLayerProps = showLayerProps
M.showClassProps = showClassProps
M.showFocus      = showFocus
return M
