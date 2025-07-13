local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable

local helper = require("test.helper")
local json = require("json")

local groupTable = require("editor.group.groupTable")
local buttons = require("editor.group.buttons")


function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  --
  props.groupTable = groupTable
  props.buttons    = buttons
  helper.init(props)

end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  selectors.componentSelector.iconHander()
  selectors.componentSelector:onClick(true,  "layerTable")
end

function M.setup()
end

function M.teardown()
end

function M.xtest_select()
  local name = "star"
  helper.selectLayer(name)
  -- selectTool{class="linear", isNew=true}
  --selectComponent("Action")
end

function M.xtest_select_for_editing()
  local name = "star"
  layerTable.altDown = true
  print("------------------")
  helper.selectLayer(name)
  layerTable.altDown = false

  -- selectTool{class="linear", isNew=true}
  --selectComponent("Action")
end


function M.test_new_path_animation()
  local name = "star"
  helper.selectLayer(name)
  helper.selectIcon("Animations", "Path"):done(
    function()
      local pathProps = require("editor.animation.pathProps")
      printKeys(pathProps)
      print(pathProps.name, #pathProps.objs)
      helper.setProp(pathProps.objs, "_filename", "PathStar_open.json")
    end
  )

  -- local classProps = require("editor.parts.classProps")
  -- helper.setProp(classProps.objs, "_filename", "PathStar_open.json")
  -- timer.performWithDelay(1000, function()

end

function M.xtest_new_animation()
  local name = "cat"
  helper.selectLayer(name)
  helper.clickIcon("Animations", "Linear")

  local buttons = require("editor.parts.buttons")
  local obj = buttons.objs["save"]
  -- obj.rect:tap()

end

function M.xtest_new_group_animation()
  local name = "groupCat"
  selectors.componentSelector:onClick(true,  "groupTable")

  helper.selectGroup(name)
  helper.clickIcon("Animations", "Linear")

  -- local obj = buttons.objs["save"]
  -- obj.rect:tap()

end

function M.xtest_new_animation_template()
  local name = "cat"
  helper.selectLayer(name)
  helper.clickIcon("Animations", "Linear")

  local buttons = require("editor.parts.buttons")
  local obj = buttons.objs["save"]
  -- obj.rect:tap()

  local props = buttons:useClassEditorProps()
  -- for k, v in pairs(props) do print(k, v) end
  print(json.encode(props))

  local _model = [[{"xSwipe":"nil","ySwipe":"nil","to":{"y":400,"xScale":1.5,"rotation":90,"yScale":1.5,"alpha":1,"x":100},"resetAtEnd":"nil","properties":{"type":"","autoPlay":"true","resetAtEnd":"false","reverse":"false","duration":1000,"delay":0,"loop":1},"easing":"Linear","from":{"y":0,"xScale":1,"rotation":0,"yScale":1,"alpha":0,"x":0},"reverse":"nil","layerOptions":{"isSceneGroup":"false","referencePoint":"Center","deltaX":0,"deltaY":0}}]]

  local util = require("editor.util")

  local tmplt='editor/template/components/pageX/animation/layer_animation.lua'
  local dst ='tmp.lua'
  local model = json.decode(_model)
  util.saveLua(tmplt, dst, model)

end

function M.xtest_new_multi_animation()
  local name = "cat"
  --
  layerTable.controlDown = true
  --
  local names = {"name", "cat", "fish"}
  local class = nil
  for i, name in next, names do
    helper.selectLayer(name, class)
    --helper.selectLayer(name, nil, true) -- isRightClick true
  end
  layerTable.controlDown = false
  helper.clickIcon("Animations", "Linear")

  local button = "save"
  local obj = require("editor.parts.buttons").objs[button]
  obj.rect:tap()

end


function M.xtest_action()
  UI.scene.app:dispatchEvent {
    name = "editor.action.selectLayer",
    action = "eventOne",
    UI = UI
  }
end

return M
