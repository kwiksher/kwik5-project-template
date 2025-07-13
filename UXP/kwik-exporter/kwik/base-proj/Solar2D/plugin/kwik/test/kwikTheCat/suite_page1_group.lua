local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable

local groupTable = require("editor.group.groupTable")
local buttons = require("editor.group.buttons")

local helper = require("test.helper")
local json   = require("json")


function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  --
  props.groupTable = groupTable
  props.buttons = buttons
  helper.init(props)

end

local book = "book"
local page = "portait"

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  selectors.componentSelector.iconHander()
end

function M.setup()
end

function M.teardown()
end

function M.xtest_new_group()
  selectors.componentSelector:onClick(true,  "groupTable")
  -- for k, v in pairs(groupTable.iconObjs[1]) do print(k, v) end
  helper.clickIconObj(groupTable, "groups-icon")
  --[[
      -- layersbox -> layersTable
      local layersbox = require("editor.group.layersbox")
      local names = {"cat", "cat_face1"}
      -- layersbox.controlDown = true -- multi
      layersbox.controlDown = true
      helper.selectEntries(layersbox, names)
      -- click add button
      helper.clickButton("add")
--]]

  -- local button = "save"
  -- local obj = require("editor.group.buttons").objs[button]
  -- obj:tap()

end

function M.xtest_click_group()
   selectors.componentSelector:onClick(true,  "groupTable")
    groupTable.altDown = true
    helper.selectGroup("group0")
    groupTable.altDown = false
end

function M.xtest_click_group_for_editing()
  -- UI.testCallback = function()
    UI.page = "page1"
    groupTable.altDown = true
    selectors.componentSelector:onClick(true,  "groupTable")
    helper.selectGroup("groupCat")
    groupTable.altDown = false

  -- end
end

function M.xtest_render()
  local tmplt='editor/template/components/pageX/group/group.lua'
  local dst ='App/book/components/page1/groups/group-2.lua'
  local model = json.decode('{"layersboxSelections":[],"name":"groupC","layersbox":[{"rect":[],"layer":"background","index":1,"name":"background"},{"rect":[],"layer":"name","index":2,"name":"name"},{"rect":[],"layer":"cat","index":3,"name":"cat"},{"rect":[],"layer":"cat_face1","index":4,"name":"cat_face1"},{"rect":[],"layer":"title_base","index":5,"name":"title_base"},{"rect":[],"layer":"title3","index":6,"name":"title3"},{"rect":[],"layer":"title2","index":7,"name":"title2"},{"rect":[],"layer":"title1","index":8,"name":"title1"},{"rect":[],"layer":"starfish","index":9,"name":"starfish"},{"rect":[],"layer":"fish","index":10,"name":"fish"}],"properties":[{"name":"name","value":"group-2"}],"layersTable":[{"index":1,"rect":[]},{"index":2,"rect":[]}],"layersTableSelections":[]}')
end

--
-- groupTable setCurrnetSelection will set a current type = "group"
--
function M.xtest_click_group_linear()
  -- UI.testCallback = function()
    -- UI.page = "page1"
    selectors.componentSelector:onClick(true,  "groupTable")
    helper.selectGroup("group0")
    helper.clickIcon("Animations", "Linear")
  -- end
end

function M.xtest_click_group_linear_for_editing()
  -- UI.testCallback = function()
    UI.page = "page1"
    groupTable.altDown = true
    selectors.componentSelector:onClick(true,  "groupTable")
    helper.selectGroup("groupC", "linear")
    groupTable.altDown = false

  -- end
end

return M
