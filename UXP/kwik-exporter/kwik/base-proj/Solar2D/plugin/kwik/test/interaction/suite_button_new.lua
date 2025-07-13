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
  UI = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  --
  props.groupTable = groupTable
  props.buttons = buttons
  helper.init(props)
end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  selectors.componentSelector.iconHander()
  selectors.componentSelector:onClick(true, "layerTable")
end

function M.setup()
end

function M.teardown()
end

function M.xtest_select()
  local name = "rect_0"
  helper.selectLayer(name)
end

function M.xtest_select_for_editing()
  local name = "rect_0"
  layerTable.altDown = true
  helper.selectLayer(name)
  layerTable.altDown = false
end

function M.test_new_button()
  local name = "star"
  helper.selectLayer(name)
  helper.selectIcon("Interactions", "Button"):done(
    function()
    end
  )
end

function M.test_new_button_new_action()
  local name = "star"
  helper.selectLayer(name)
  helper.selectIcon("Interactions", "Button"):done(
    function()
    end
  )
end

function M.test_new_button_over()
  local name = "star"
  helper.selectLayer(name)
  helper.selectIcon("Interactions", "Button"):done(
    function()
    end
  )
end

function M.test_new_button_mask()
  local name = "star"
  helper.selectLayer(name)
  helper.selectIcon("Interactions", "Button"):done(
    function()
    end
  )
end

function M.xtest_action()
  UI.scene.app:dispatchEvent {
    name = "editor.action.selectLayer",
    action = "eventOne",
    UI = UI
  }
end

return M
