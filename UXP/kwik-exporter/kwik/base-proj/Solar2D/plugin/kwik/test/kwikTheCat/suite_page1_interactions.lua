local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable
local actionTable = require("editor.action.actionTable")
local actionCommandTable = require("editor.action.actionCommandTable")
local actionCommandPropsTable = require("editor.action.actionCommandPropsTable")
local actionEditor = require("editor.action.index")
local colorPicker = require("colorPicker")
local classProps = require("editor.parts.classProps")
local actionbox = require("editor.parts.actionbox")
----
local buttons = require("editor.action.buttons")
local actionCommandButtons = require("editor.action.actionCommandButtons")
----
local helper = require("test.helper")
local picker = require("editor.picker.name")
local actionButtonContext = require("editor.action.buttonContext")

local groupTable = require("editor.group.groupTable")

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  props.actionTable = actionTable
  props.buttons = buttons
  props.groupTable = groupTable
  helper.init(props)
end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  selectors.componentSelector.iconHander()
end

function M.setup()
end

function M.teardown()
end

function M.xtest_new_drag()
  local name = "groupCat"
  selectors.componentSelector:onClick(true,  "groupTable")
  helper.selectGroup(name)
  helper.clickIcon("Interactions", "Drag")
end

function M.xtest_new_parallax()
  local name = "groupCat"
  selectors.componentSelector:onClick(true,  "groupTable")
  helper.selectGroup(name)
  helper.clickIcon("Interactions", "Parallax")
end

function M.xtest_new_scroll()
  local name = "groupCat"
  selectors.componentSelector:onClick(true,  "groupTable")
  helper.selectGroup(name)
  helper.clickIcon("Interactions", "Scroll")
end

function M.xtest_new_shake()
  local name = "groupCat"
  selectors.componentSelector:onClick(true,  "groupTable")
  helper.selectGroup(name)
  helper.clickIcon("Interactions", "Shake")
end

function M.xtest_new_spin()
  local name = "groupCat"
  selectors.componentSelector:onClick(true,  "groupTable")
  helper.selectGroup(name)
  helper.clickIcon("Interactions", "Spin")
end

function M.test_new_swipe()
  local name = "groupCat"
  selectors.componentSelector:onClick(true,  "groupTable")
  helper.selectGroup(name)
  helper.clickIcon("Interactions", "Swipe")
end

return M
