local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable
local actionTable = require("editor.action.actionTable")
local commandbox = require("editor.action.commandbox")
local actionCommandPropsTable = require("editor.action.actionCommandPropsTable")
local helper = require("test.helper")

local muiName = "editor.action.commandView-"
local actionTable = require("editor.action.actionTable")
local controller = require("editor.action.controller.index")
local buttons = require("editor.parts.buttons")

local audioTable = require("editor.audio.audioTable")
local variableTable = require("editor.variable.variableTable")
local assetTable = require("editor.asset.assetTable")

--

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  --
  props.actionTable   = actionTable
  props.buttons       = buttons
  props.audioTable    = audioTable
  props.variableTable = variableTable
  props.assetTable = assetTable
  helper.init(props)

end

function M.suite_setup()
  -- selectors.projectPageSelector:show()
   selectors.projectPageSelector:onClick(true)
  --
  -- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectApp",
  --   UI = UI
  -- }
end

function M.setup()
end

function M.teardown()
end

----
local commands = require("editor.scripts.commands")
---


function M.xtest_new_book()
  local book =  helper.selectBook("book", true)
  helper.clickButton("create")
  -- UI.testCallback = function()
  --   local obj = helper.selectBook("book")
  --   bookTable.commandHandler(obj, {phase="ended"},  true)
  --   local x, y = obj.x, obj.y
  --   obj:dispatchEvent{name="mouse", target=obj, isSecondaryButtonDown=true, x = x, y = y}
  -- end
end

function M.xtest_select_page()
  -- UI.testCallback = function()
    local book = helper.selectBook("book")
    book:touch()
    --bookTable.commandHandler(obj, {phase="ended"},  true)
    local page2 = helper.getPage("page2")
    local page1 = helper.getPage("page1")

    timer.performWithDelay(2000, function()
      page2:tap()
    end)
    timer.performWithDelay(5000, function()
      page1:tap()
    end)
  -- end
end

function M.xtest_new_page()
  local book = helper.selectBook("mybook")
  book:touch()
  if UI.book ~="mybook" then
    return
  end
  for i, v in next, pageTable.iconObjs  do print(v.name  ) end
  local obj = pageTable.iconObjs[2]
  obj.callBack({target={muiOptions={name="newPage-icon"}}})
  -- UI.testCallback = function()
  --   local obj = helper.selectBook("book")
  --   bookTable.commandHandler(obj, {phase="ended"},  true)
  --   --
  --   obj = helper.getPage("page4")
  --   pageTable.commandHandler(obj, {phase="ended"},  true)
  --   local x, y = obj:localToContent(0, 0)
  --   local dx, dy = pageTable.scrollView:localToContent(0, 0)
  --   --
  --   print(x, y, pageTable.scrollView.x, pageTable.scrollView.y)
  --   print(pageTable.rootGroup.x, pageTable.rootGroup.y)
  --   print(dx, dy)
  --     -- local x, y = pageTable.scrollView:localToContent(obj.x, obj.y)
  --     -- local x, y = pageTable.rootGroup:localToContent(obj.x, obj.y)
  --     -- local x, y = pageTable.group:localToContent(pageTable.group.x, pageTable.group.y)
  --     -- local x, y = pageTable.scrollView.x, pageTable.scrollView.y
  --     -- print(pageTable.group.x, pageTable.group.y)
  --     -- print(pageTable.group:localToContent(0,0))
  --     -- print(pageTable.scrollView:localToContent(0,0))
  --   --
  --   x=  obj.x + x - dx
  --   y = dy
  --   obj:dispatchEvent{name="mouse", target=obj, isSecondaryButtonDown=true, x = x , y = y}
  --   helper.clickButton("create")
  -- end
end

function M.test_rename_page()
  local book = helper.selectBook("mybook")
  book:touch()
  if UI.book ~="mybook" then return end
  helper.selectPage("page3", false)
  helper.selectPage("page3", true)
  helper.clickButton("rename")
end

function M.xtest_copy_paste_page()
end

function M.xtest_delete_page()
  local book = helper.selectBook("mybook")
  book:touch()
  if UI.book ~="mybook" then
    return
  end
  for i, v in next, pageTable.objs  do print(v.page  ) end
  local obj = pageTable.objs[#pageTable.objs]
  printKeys(obj)
  obj:tap{phase = "ended"}

  local icon = pageTable.iconObjs[3]
  icon.callBack({target={muiOptions={name="trash-icon"}}})

end

--
-- use tool generate index?
--
function M.xtest_layer_new_icon()
  UI.testCallback = function()
  end
end

--
-- shapes {rect, circle, triangle, polygon}
--
function M.xtest_layer_contextmenu_new()
  local obj = helper.selectBook("book")
   bookTable.commandHandler(obj, {phase="ended"},  true)
   UI.testCallback = function()
    -- obj = helper.getPage("page4")
    -- pageTable.commandHandler(obj, {phase="ended"},  true)

    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    local name = "title"
    -- -- layerTable.altDown = true
    helper.selectLayer(name)
    helper.selectLayer(name, nil, true) -- isRightClick true
    helper.clickButton("create")
  end
end

function M.xtest_layer_contextmenu_new_shape()
  local obj = helper.selectBook("book")
   bookTable.commandHandler(obj, {phase="ended"},  true)

   UI.testCallback = function()
    -- obj = helper.getPage("page4")
    -- pageTable.commandHandler(obj, {phase="ended"},  true)

    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    local name = "title"
    -- -- layerTable.altDown = true
    helper.selectLayer(name)
    helper.selectLayer(name, nil, true) -- isRightClick true
    helper.clickButtonInRow("create", "shape.new_rectangle")
  end
end

function M.xtest_layer_contextmenu_up_down()
  -- update weight from inde.lua
  --    use components/pageX/index.lua to change order of layers and set an ordered weight value to each .lua
  --    open vs code or .http to update a weight value
  --
  -- update index.lua from layer's .lua
  --   this operation works for appending new layers. For example, copiing  .lua files of other pages to components/pageX/layer folder
  --   or inserting a new one.
end

--
-- rename layer.lua and layer_class.lua and generate(update) index.lua
--
function M.xtest_rename_book()
end

function M.xtest_rename_group()
end

function M.xtest_rename_timer()
end

function M.xtest_rename_joints()
end

function M.xtest_rename_var()
end

function M.xtest_rename_audio()
end

------
return M
