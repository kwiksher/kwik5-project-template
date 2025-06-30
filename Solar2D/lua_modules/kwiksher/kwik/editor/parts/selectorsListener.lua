local name = ...
local parent,root, M = newModule(name)

local bt = require(kwikGlobal.ROOT .. "editor.controller.BTree.btree")
local tree = require(kwikGlobal.ROOT .. "editor.controller.BTree.selectorsTree")
local buttons  = require(kwikGlobal.ROOT.."editor.parts.buttons")
local selectLayerFilter = require(kwikGlobal.ROOT.."editor.parts.selectLayerFilter")
local json = require("json")

---
local keyboardNavigation = require(kwikGlobal.ROOT.."components.common.keyboardNavigation")
---
local bookTable = require(kwikGlobal.ROOT.."editor.parts.bookTable")

local function componentHandler(UI, storeTable, isActiveProp)
  -- each table will be reset
  --
  if isActiveProp == nil then
    UI.editor.layerStore:set{isActiveProp = isActiveProp, value={}}
  end
  UI.editor.audioStore:set{isActiveProp = isActiveProp, value=nil}
  UI.editor.actionStore:set{isActiveProp = isActiveProp, value=nil}
  UI.editor.groupStore:set{isActiveProp = isActiveProp, value=nil}
  UI.editor.timerStore:set{isActiveProp = isActiveProp, value=nil}
  UI.editor.variableStore:set{isActiveProp = isActiveProp, value=nil}
  UI.editor.jointStore:set{isActiveProp = isActiveProp, value=nil}

  bookTable:hide()


  tree:setConditionStatus("select audio", bt.FAILED)
  tree:setConditionStatus("select group", bt.FAILED)
  tree:setConditionStatus("select timer", bt.FAILED)
  tree:setConditionStatus("select variable", bt.FAILED)
  tree:setConditionStatus("select joint", bt.FAILED)

  --
  --
  if storeTable then
    selectLayerFilter:hide()
    -- should we show the last secection?
    if storeTable == "layerTable" then
      selectLayerFilter:show()
      UI.editor.layerStore:set{isActiveProp = isActiveProp, value=UI.scene.model.components.layers}
    elseif storeTable == "audioTable" then
      UI.editor.audioStore:set{isActiveProp = isActiveProp, value=UI.scene.model.components.audios}
    elseif storeTable == "groupTable" then
      print("storeTable == groupTable")
      UI.editor.groupStore:set{isActiveProp = isActiveProp, value=UI.scene.model.components.groups or {}}
    elseif storeTable == "timerTable" then
      -- print(storeTable, #UI.scene.model.components.timers)
      UI.editor.timerStore:set{isActiveProp = isActiveProp, value=UI.scene.model.components.timers}
    elseif storeTable == "variableTable" then
      UI.editor.variableStore:set{isActiveProp = isActiveProp, value=UI.scene.model.components.variables}
    elseif storeTable == "jointTable" then
      -- print("jointTable", #UI.scene.model.components.joints)
      UI.editor.jointStore:set{isActiveProp = isActiveProp, value=UI.scene.model.components.joints}
    elseif storeTable == "actionTable" then
      UI.editor.actionStore:set{isActiveProp = isActiveProp, value=UI.scene.model.commands}
    end
    -- UI.editor.groupStore:set{isActiveProp = isActiveProp, value=UI.scene.model.components.groups}
    -- UI.editor.timerStore:set{isActiveProp = isActiveProp, value=UI.scene.model.components.timers}
    -- UI.editor.variableStore:set{isActiveProp = isActiveProp, value=UI.scene.model.components.variables}
  else
    UI.editor.layerStore:set{isActiveProp = isActiveProp, value=UI.scene.model.components.layers}
  end
  --
end
--
-- these OnClick functions are called back from the icons
--
function M:addListener(UI, buttons, propsTable)
  local projectPageSelector = self.projectPageSelector
  local componentSelector   = self.componentSelector
  local assetsSelector      = self.assetsSelector
  --
  -- The icon click callback
  function self.componentSelector:onClick(isVisible, storeTable, isAcvtiveProp)
    -- print("componentSelector", isVisible)
    -- for i=1, #UI.scene.model.components.layers do
      -- for k, v in pairs(UI.scene.model.components.layers[i]) do print(k, v) end
    -- end
    --
    bookTable:hide()

    if isAcvtiveProp  == nil then
      buttons:hide()
    end

    if isVisible then
      --
      tree:setConditionStatus("select page", bt.SUCCESS)

      projectPageSelector:hide()
      keyboardNavigation:removeEventListener(UI)
      --
      assetsSelector:hide()
      assetsSelector.iconObj.isVisible = true
      propsTable:hide()
      -- for k, tool in pairs(UI.editor.editorTools) do
      --   -- print("hiding", k)
      --   tool:hide()
      -- end
      if storeTable == "groupTable" then
        local groupTable = require(kwikGlobal.ROOT.."editor.group.groupTable")
        if isAcvtiveProp then
          -- groupTable:setIndent(100, 0)
        else
          groupTable:setIndent(0,0)
        end
      elseif storeTable == "variableTable" then
        -- print("storeTable = variableTable", isActiveProp)
        local variableTable = require(kwikGlobal.ROOT.."editor.variable.variableTable")
        if isAcvtiveProp then
          variableTable:setIndent(200, nil)
        else
          variableTable:setIndent(nil,nil)
        end
      end

      componentHandler(UI, storeTable, isAcvtiveProp)
      if not UI.editor.toolbar.isVisible  then
          UI.editor.toolbar:show()
        UI.editor.actionIcon.isVisible = true
        -- local width = UI.editor.toolbar:getWidth()
        -- self.assetsSelector.iconObj:move(width)
      end

    end
    --
  end

  -- The icon click callback
  function self.projectPageSelector:onClick(isVisible, storeTable)
    -- print("projectPageSelector", isVisible)
    buttons:hide()
    if isVisible then
      keyboardNavigation:addEventListener(UI)
      componentSelector:hide()
      assetsSelector:hide()
      assetsSelector.iconObj.isVisible = true
      for k, tool in pairs(UI.editor.editorTools) do
        --print(k, tool.id)
        tool:hide()
      end
      if UI.editor.toolbar.isVisible then
        UI.editor.toolbar:hide()
        -- UI.editor.actionIcon.isVisible = false
        -- local width = UI.editor.toolbar:getWidth()
        -- self.assetsSelector.iconObj:reset(width)
      end
      UI.scene.app:dispatchEvent {
            name = "editor.selector.selectApp",
            UI = UI,
            appFolder = system.pathForFile("App", system.ResourceDirectory), -- default
            useTinyfiledialogs = false -- default
          }
    end
    if storeTable == "bookTable" then
      -- new book
    elseif storetable =="pageTable" then
      -- new page
    end
    bookTable:show()
  end

  function self.assetsSelector:onClick(isVisible, assetName)
    -- print("onClick", UI.editor.currentBook, assetName)
    -- UI.editor.assetStore:set{{}}

    if isVisible then
      componentSelector:hide()
      UI.editor.assets = require(kwikGlobal.ROOT.."editor.asset.index").controller:read(UI.editor.currentBook)
      --
      tree:setConditionStatus("select asset props", bt.FAILED)
      tree:setConditionStatus("add asset", bt.FAILED)
      tree:setConditionStatus("modify asset", bt.FAILED)
      tree:setConditionStatus("delete asset", bt.FAILED)
      --
      if assetName then
        -- print(assetName, print(json.encode(UI.editor.assets[assetName])))
        UI.editor.assetStore:set{value={class = assetName, decoded = UI.editor.assets[assetName]}}
      else
        componentSelector:onClick(true)
        UI.editor.assetStore:set{value={decoded = UI.editor.assets}}
      end
    else
      UI.editor.assetStore:set{value={}}
    end
    projectPageSelector:hide()
    keyboardNavigation:removeEventListener(UI)
  end
end

function M:selectComponentIcon(name) -- this is from action
  for i, v in next, self.componentSelector.objs do
    if v.text == name then
      v:dispatchEvent{name="tap", target=v, isActiveProp = true}
      return
    end
  end
end

-- local posX = display.contentCenterX*0.75
local menuSet = table:mySet{"selectBook", "selectPage", "selectLayer", "selectAudio", "selectGroup", "selectTimer", "selectVariable", "selectAction"}
function M.mouseHandler(event)
  if event.isSecondaryButtonDown then
    -- print(event.target.command)
    if menuSet[event.target.command] then
       buttons:showContextMenu(event.x+20, event.y-10,
        {type=event.target.text, selections=selections or {},
        contextMenu = {"create"}})
    end
  else
    -- print("@@@@not selected")
  end
  return true
end

--[[
  local function mouseHandlerComponent(event)
    if event.isSecondaryButtonDown then
      local editor = require(kwikGlobal.ROOT.."editor.index")
      -- print("@@@@ selected")
      editor.selections = {"index"}
      editor.selection = "index"
      buttons:showContextMenu(posX, event.y)
    else
      -- print("@@@@not selected")
    end
    return true
  end
--]]


return M