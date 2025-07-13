local M = {}

local selectors
local UI
local bookTable
local pageTable

local helper = require("test.helper")

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
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
  -- appFolder = system.pathForFile("App", system.ResourceDirectory) -- default
  -- useTinyfiledialogs = false -- default
  ---
  bookTable.commandHandler({book="bookFree"}, nil,  true)
  --pageTable.commandHandler({page="page_portrait"},nil,  true)
  pageTable.commandHandler({page="page1"},nil,  true)
end

function M.setup()
end

function M.teardown()
end

local actionIndex = require("editor.action.index")

function M.xtest_componentSelector()
  UI.testCallback = function()
    selectors.componentSelector:onClick(true,  "layerTable")
    selectors.componentSelector.iconHander()
    -- local name = "Candice"
    -- helper.selectLayer(name)

    --helper.selectTool{class="linear", isNew=true}
    --helper.selectTool{class="canvas", isNew=true}
   actionIndex.iconHander()

    -- selectors.componentSelector:onClick(true,  "actionTable")

    --[[

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
    --]]
  end
end


local actionTable = require("editor.action.actionTable")
local commandbox = require("editor.action.commandbox")
local actionCommandTable = require("editor.action.actionCommandTable")

local actionCommandPropsTable = require("editor.action.actionCommandPropsTable")
local actionController = require("editor.action.controller.index")
local muiName = "editor.action.commandView-"

function M.test_actionSelector()
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    -- actionIndex.iconHander()

    selectors.componentSelector:onClick(true,  "actionTable")


      -- this call selectHandler
      actionTable.objs[1]:tap() -- varaibleAction
      -- then edit
      actionTable.editButton:tap()

      -- now action editor is displayed
      -- let's chose Controls > Variables
      actionController.commandGroupHandler{target={muiOptions={name=muiName.."Controls"}}}

      -- -- each actionCommand in AC group is stored in commandMap
      local cmd = "Condition"
      actionIndex.commandMap[cmd]:tap{}
  end
end

function M.xtest_action_variable()
  UI.testCallback = function()
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
  end
end

return M
