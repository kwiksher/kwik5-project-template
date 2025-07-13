local parent,root, M = newModule(...)

local selectorBase = require(parent .. "selectorBase")
local selectLayerFilter = require(parent .. "selectLayerFilter")
local propsTable = require(parent .. "propsTable")
local propsButtons = require(parent .. "propsButtons")

-- local bookTable = require(parent.."bookTable")
-- local pageTable = require(parent.."pageTable")
-- local layerTable = require(parent.."layerTable")
-- local audioTable = require(parent.."audioTable")

local jointTable   = require(kwikGlobal.ROOT.."editor.physics.jointTable")
-- ---
local muiIcon = require(kwikGlobal.ROOT.."components.mui.icon").new()
local util = require(kwikGlobal.ROOT.."lib.util")
local mui = require("materialui.mui")
local muiData = require("materialui.mui-data")


local buttons           = require(kwikGlobal.ROOT.."editor.parts.buttons")
local selectorsListener = require(parent.."selectorsListener")

local widget = require("widget")
local util = require(kwikGlobal.ROOT.."lib.util")

---
local option, newText = util.newTextFactory()

local function showLabels(fooValue, rootGroup)
  -- print (fooValue.currentBook, fooValue.currentPage, fooValue.currentLayer, fooValue.currentClass)
  -- print(debug.traceback())
  local labelBook = newText {
    parent = rootGroup,
    text = fooValue.currentBook or "",
    x = display.contentWidth * 0.75,
    y = 16,
    -- y = (display.actualContentHeight - 1280 / 4) / 2,
    width = nil,
    height = 18,
    font = native.systemFont,
    fontSize = 10,
    align = "center"
  }
  labelBook.anchorY = 1
  labelBook:setFillColor(1)
  --
  local labelPage = newText {
    parent = rootGroup,
    text = "> " .. (fooValue.currentPage or ""),
    x = 10,
    y = 16,
    -- y = (display.actualContentHeight - 1280 / 4) / 2,
    width = nil,
    height = 18,
    font = native.systemFont,
    fontSize = 10,
    align = "center"
  }
  labelPage.anchorY = 1
  labelPage.x = labelPage.width / 2 + labelBook.contentBounds.xMax + 2
  labelPage:setFillColor(1)
  ---
  local labelLayer = newText {
    parent = rootGroup,
    text = "> " .. (fooValue.currentLayer or ""),
    x = 10,
    y = 16,
    -- y = (display.actualContentHeight - 1280 / 4) / 2,
    width = nil,
    height = 18,
    font = native.systemFont,
    fontSize = 10,
    align = "center"
  }
  labelLayer.anchorY = 1
  labelLayer.x = labelPage.contentBounds.xMax + labelLayer.width / 2 + 2
  labelLayer:setFillColor(1)

  local labelClass
  if fooValue.currentClass then
    -- print("++++++++", fooValue.currentClass)
    labelClass = newText {
      parent = rootGroup,
      text = "> " .. (fooValue.currentClass or ""),
      x = 10,
      y = 16,
      -- y = (display.actualContentHeight - 1280 / 4) / 2,
      width = nil,
      height = 18,
      font = native.systemFont,
      fontSize = 10,
      align = "center"
    }
    labelClass.anchorY = 1
    labelClass.x = labelLayer.contentBounds.xMax + labelClass.width / 2 + 2
    labelClass:setFillColor(1)
    end
  -- local rect = display.newRect(labelPage.x, labelPage.y, labelPage.width, labelPage.height)
  -- rect:setFillColor(0.5,0,0,0.5)

  -- local rect = display.newRect(labelLayer.x, labelLayer.y, labelLayer.width, labelPage.height)
  -- rect:setFillColor(0,0.5,0,0.5)

  --
  -- print("", labelBook.text, labelPage.text, labelLayer.text)
  return {labelBook, labelPage, labelLayer, labelClass}
end


function M:init(UI)
  -- print("init", UI.page)
end

--
function M:create(UI)
  -- print("create", self.name, UI.page)
  -- if self.rootGroup then return end
  self.rootGroup = UI.editor.rootGroup
  ---
  -- See editor.index.lua registers each select command  to the context
  ---
  self.projectPageSelector =
    selectorBase.new(
    UI,
    11, --self.x
    -2, --self.y
    {
      {label = "", command = "selectBook", store = "bookTable", btree = "select book"},
      {label = "", command = "selectPage", store = "pageTable", btree = "select page"},
      {label = "      ", command = "empty"},
      {label = "Properties", command = "selectPageIcons"},
      -- {label = "Browse", command = "selectApp"},
    },
    "openProject", --iconName
    nil,
    nil,
    nil,
    self.mouseHandler
  )

  self.projectPageSelector.optionWidth = 40
  self.projectPageSelector.marginY = 11
  self.projectPageSelector.marginX = 55

  self.componentSelector =
    selectorBase.new(
    UI,
    33, --self.x
    -2, --self.y
    {
      {label = "Layer", command = "selectLayer", store = "layerTable", filter = true, btree = "select layer"},
      {label = "Audio", command = "selectAudio", store = "audioTable", btree = "select component"},
      {label = "Group", command = "selectGroup", store = "groupTable", btree = "select component"},
      {label = "Timer", command = "selectTimer", store = "timerTable", btree = "select component"},
      {label = "Var", command = "selectVariable", store = "variableTable", btree = "select component"},
      {label = "Joint", command = "selectJoint", store = "jointTable", btree = "select component"},
      -- {label = "Action", command = "selectAction", store = "actionTable"}
    },
    "toolLayer",
    selectLayerFilter,
    propsTable,
    propsButtons,
    self.mouseHandler
  )
  self.componentSelector.marginY = 11
  self.componentSelector.marginX = 88

  self.assetsSelector =
  selectorBase.new(
    UI,
    76, -- display.contentCenterX + 480/2-24, -- self.x
    -2,        -- self.y
    {
      {label = "Audio", command = "selectAudioAsset", store = "audios", btree = "select asset"},
      {label = "Particles", command = "selectPaticlesAsset", store = "particles", btree = "select asset"},
      {label = "Sprite", command = "selectSpriteAsset", store = "sprites", btree = "select asset"},
      {label = "SyncText", command = "selectSyncTextAsset", store = "syncs", btree = "select asset"},
      {label = "Video", command = "selectVideoAsset", store = "videos", btree = "select asset"},
    },
    "toolAssets",
    nil
  )
  self.assetsSelector.marginX = 88 -- display.contentCenterX -60
  self.assetsSelector.marginY =  11 -- -12 -- self.componentSelector.height+30
  self.assetsSelector.optionWidth = 48
  self.assetsSelector.width =  60

  --
  self.projectPageSelector:create(UI)
  self.componentSelector:create(UI)
  self.assetsSelector:create(UI)
  --------------
  function self.assetsSelector.iconObj:move(width)
    -- self.x = self.x + width
  end

  function self.assetsSelector.iconObj:reset(width)
    -- self.x = self.x - width
  end
  -------------

  jointTable:create(UI)

  -- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectLayer",
  --   UI = UI,
  --   show = false
  -- }


  -- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectAction",
  --   UI = UI
  -- }

  -- timer.performWithDelay( 100, function()
    self.projectPageSelector:hide()
    self.componentSelector:hide()
    self.assetsSelector:hide()
    selectLayerFilter:hide()
    jointTable:hide()

  -- end)


  self:addListener(UI, buttons, propsTable)
  ------
  -- header/footer
  --
  UI.editor.rootGroup:addEventListener("labelStore", function(event)
    self:didHide()
    if self.objs then
      for i, obj in next, self.objs do
        obj:removeSelf()
      end
    end
    self.objs = showLabels(event, self.rootGroup)

    -- timer.performWithDelay( 10,
    -- function()
    --   if self.objs == nil then
    --     self.objs = showLabels(event, self.rootGroup)
    --   end
    -- end )
  end)
  -- UI.editor.labelStore:listen(
  --   function(foo, fooValue)
  --     print("UI.labelStore")
  --     for k, v in pairs(fooValue.value) do
  --       print("", k, v)
  --     end
  --     timer.performWithDelay( 1000,
  --     function()
  --       self:destroy()
  --       self.objs = showLabels(fooValue.value, rootGroup)
  --     end )
  --   end
  -- )


end
--
function M:didShow(UI)
  -- print("didShow", UI.page)
  self.projectPageSelector:didShow(UI)
  self.componentSelector:didShow(UI)
  self.assetsSelector:didShow(UI)
  jointTable:didShow(UI)
end
--
function M:didHide(UI)
  -- print("didHide", UI.page)
  self.projectPageSelector:didHide(UI)
  self.componentSelector:didHide(UI)
  self.assetsSelector:didHide(UI)
  jointTable:didHide(UI)
end
--
function M:destroy(UI)
  -- print("destroy")

  self.projectPageSelector:destroy(UI)
  self.componentSelector:destroy(UI)
  self.assetsSelector:destroy(UI)

  if self.objs then
    for i=1, #self.objs do
      self.objs[i]:removeSelf()
    end
    self.objs = nil
  end
end
--
return setmetatable( M, {__index=selectorsListener})
