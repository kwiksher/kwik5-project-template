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
--
local classProps = require("editor.parts.classProps")
--

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  --
  props.buttons = buttons
  helper.init(props)

end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  --
  -- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectApp",
  --   UI = UI
  -- }
  -- appFolder = system.pathForFile("App", system.ResourceDirectory) -- default
  -- useTinyfiledialogs = false -- default
  ---
  bookTable.commandHandler({book="book"}, nil,  true)
  pageTable.commandHandler({page="page1"},nil,  true)
  -- timer.performWithDelay( 1000, function()
  selectors.componentSelector.iconHander()
  -- end)

end

function M.setup()
end

function M.teardown()
end

function M.xtest_multi_edit_props()
  --
  layerTable.controlDown = true
  --
  local names = {"name", "cat", "fish"}
  for i, name in next, names do
    helper.selectLayer(name)
    --helper.selectLayer(name, nil, true) -- isRightClick true
  end
  layerTable.controlDown = false
  ---
  -- helper.clickButton("modify")

  local toolbar = require("editor.parts.toolbar")
  local obj = toolbar.layerToolMap["Layer"]
  obj.callBack{target=obj}
  for k, v in pairs(toolbar.toolMap) do print(k, v) end
  local tool = toolbar.toolMap[obj.id.."-Properties"]
  tool.callBack{target=tool}

  for i, obj in next, classProps.objs do
  --  print(obj.text)
    if obj.text == "alpha" then
      obj.field.text = 1
    end
  end

  -- for k, obj in pairs(buttons.objs) do
  --   print(k)
  -- end
  -- buttons.objs["save"].rect:tap()
  -- buttons.objs["cancel"]:tap()

end

function M.xtest_multi_delete()
  --
  layerTable.controlDown = true
  --
    local names = {"name", "cat", "fish"}
    for i, name in next, names do
      helper.selectLayer(name)
      --helper.selectLayer(name, nil, true) -- isRightClick true
    end
    layerTable.controlDown = false
  ---
end

function M.xtest_multi_class_delete()
  --
  layerTable.controlDown = true
  --
    local names = {"name", "cat", "fish"}
    local class = "properties"
    for i, name in next, names do
      helper.selectLayer(name, class)
      --helper.selectLayer(name, nil, true) -- isRightClick true
    end
    layerTable.controlDown = false

      -- helper.clickButton("modify")

  -- local toolbar = require("editor.parts.toolbar")
  -- local obj = toolbar.layerToolMap["Layer"]
  -- obj.callBack{target=obj}

  -- local tool = toolbar.toolMap[obj.id.."-Properties"]
  -- tool.callBack{target=tool}

end

function M.xtest_saveLua()
  local util = require("editor.util")

  local tmplt='editor/template/components/pageX/layer/layer_properties.lua'
  local dst ='App/book/components/page1/layers/name_nil.lua'
  local model = json.decode('{"yScale":"nil","type":"nil","randYStart":"nil","height":"nil","xScale":"nil","randXStart":"nil","width":"nil","y":"nil","x":"nil","blendMode":"nil","name":"nil","randXEnd":"nil","kind":"nil","randYEnd":"nil","rotation":"nil"}')

  util.saveLua(tmplt, dst, model)
end

function M.xtest_multi_new_animation()
end

function M.xtest_multi_new_button()
end

function M.xtest_multi_set_physics()
end

function M.xtest_select_for_edit()
  local name = "cat"
  -- layerTable.altDown = true
  helper.selectLayer(name)
  -- layerTable.altDown = false

end

function M.xtest_select_for_edit_class()
  local name = "cat"
  local class = "properties"
  -- layerTable.altDown = true
  helper.selectLayer(name, class, false) -- isRightClick true
  -- layerTable.altDown = false
end

function M.xtest_copy_layer()
  local name = "cat"
  -- layerTable.altDown = true
  helper.selectLayer(name)
  helper.selectLayer(name, nil, true) -- isRightClick true
  helper.clickButton("copy")

  -- layerTable.altDown = false

  -- selectors.componentSelector:onClick(true,  "actionTable")
  -- helper.selectAction("eventOne")
end

function M.xtest_save()
  --just save eventOne
end

function M.xtest_cancel()
  -- 1. cancel to close it
end

return M
