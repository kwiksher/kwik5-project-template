local M = {}

local selectors
local UI
local bookTable
local pageTable

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
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
  pageTable.commandHandler({page="pageVariable"},nil,  true)
end

function M.setup()
end

function M.teardown()
end

--[[
  function M.test_readAssets()
    local util = require("editor.util")
    util.readAssets("bookFree", "timer")
  end
--]]

--[[
function M.test_completeBox()
  timer.performWithDelay( 1000, function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "variableTable")
    local view = require("editor.timer.variableTable")

    UI.scene.app:dispatchEvent {
      name = "editor.selector.selectTimer",
      UI = UI,
      class = "timer",
      isNew = true, --(name ~= "Trash-icon"),
      isDelete =false -- (name == "Trash-icon")
    }

    -- list actions in completeBox
    -- select one of them
    -- save

  end)
end
--]]

---[[
function M.xtest_new_component()
  timer.performWithDelay( 1000, function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "variableTable")
    local view = require("editor.variable.variableTable")

    UI.scene.app:dispatchEvent {
      name = "editor.selector.selectVariable",
      UI = UI,
      class = "variable",
      isNew = true, --(name ~= "Trash-icon"),
      isDelete =false -- (name == "Trash-icon")
    }

    -- list actions in completeBox
    -- select one of them
    -- save
    local buttons = require("editor.variable.buttons")
    buttons.objs["save"].tap{eventName="save"}
  end)
end
--]]

--[[
function M.test_component()
  timer.performWithDelay( 1000, function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "variableTable")
    local view = require("editor.timer.variableTable")
    local obj = view.objs[1]
    obj:touch{phase="ended"}
    ---
    local buttons = require("editor.timer.buttons")
    buttons.objs["save"].tap{eventName="save"}
  end)
end
--]]

local actionIndex = require("editor.action.index")
local actionTable = require("editor.action.actionTable")
local commandbox = require("editor.action.commandbox")
local actionCommandTable = require("editor.action.actionCommandTable")

local actionCommandPropsTable = require("editor.action.actionCommandPropsTable")
local actionController = require("editor.action.controller.index")
local muiName = "editor.action.commandView-"

function M.xtest_action_variable()
  timer.performWithDelay( 1000, function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "actionTable")


    -- this call selectHandler
    actionTable.objs[2]:tap() -- varaibleAction
    -- then edit
    actionTable.editButton:tap()

    -- now action editor is displayed
    -- let's chose Controls > Variables
    actionController.commandGroupHandler{target={muiOptions={name=muiName.."Controls"}}}

    -- each actionCommand in AC group is stored in commandMap
    local cmd = "Variables" -- "Condition"
    -- for k, v in pairs(actionIndex.commandMap) do
    --   print(k, v)
    -- end

    actionIndex.commandMap[cmd]:tap{}
    -- }
  end)
end

function M.test_action_condition()
  timer.performWithDelay( 1000, function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "actionTable")

    -- this call selectHandler
    actionTable.objs[2]:tap() -- varaibleAction
    -- then edit
    actionTable.editButton:tap()

    -- For editor  an existing actionCommand
    --   for examle, select variable.editVars in variableAction
    --
    -- local obj = actionCommandTable.objs[2]
    -- actionCommandTable:listener(obj,{phase="ended"})

    -- now action editor is displayed
    -- let's chose Controls > Variables
    actionController.commandGroupHandler{target={muiOptions={name=muiName.."Controls"}}}

    -- each actionCommand in AC group is stored in commandMap
    local cmd =  "Condition"
    -- for k, v in pairs(actionIndex.commandMap) do
    --   print(k, v)
    -- end

    actionIndex.commandMap[cmd]:tap{}

    commandbox.objs[2]:tap{}

    actionCommandPropsTable.objs[1].field.text = "conditions.isFruit"


  end)
end

return M
