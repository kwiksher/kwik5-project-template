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
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
  --
  UI.scene.app:dispatchEvent {
    name = "editor.selector.selectApp",
    UI = UI
  }
end

function M.setup()
  local obj = helper.selectBook("bookFree")
   bookTable.commandHandler(obj, {phase="ended"},  true)
end

function M.teardown()
end

-- new folder in context menu for layer' selection?
-- open vs code to make a group folder and put layers in it?

function M.xtest_new_rectangle()
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    --

    -- new layer A
    -- new layer B
    -- select A and B
    -- new group in context menu with selecting layers
    --    mkdir folderName
    --    mv layer A & B .lua
    --    update App/bookX/components/pageX/index.lua

    -- shortcut t to select and group layers
    Runtime:dispatchEvent{name="key", keyName="", phase="down"}

   end
end

------
return M
