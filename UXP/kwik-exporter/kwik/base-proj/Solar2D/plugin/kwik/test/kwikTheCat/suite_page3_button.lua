local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable
local actionTable
local helper = require("test.helper")

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  bookTable.commandHandler({book="book"}, nil,  true)
  pageTable.commandHandler({page="page3"},nil,  true)
  selectors.componentSelector.iconHander()
end

function M.setup()
end

function M.teardown()
end

function M.test_select_button()
  helper.selectLayer("ball")
  helper.selectIcon("Interactions", "Button")

  local actionbox = require("editor.parts.actionbox")
  helper.actionTable = require("editor.action.actionTable")

  local classProps = require("editor.parts.classProps")
  helper.setProp(classProps.objs, "btaps", "2")

  -- helper.clickProp(classProps.objs, "mask")
  -- helper.selectLayer("baloon")

  helper.clickProp(classProps.objs, "over")
  helper.selectLayer("ball_over")

  -- select an action
  helper.clickProp(actionbox.objs, "onTap")
  helper.clickAction("eventOne")

  --
end

return M
