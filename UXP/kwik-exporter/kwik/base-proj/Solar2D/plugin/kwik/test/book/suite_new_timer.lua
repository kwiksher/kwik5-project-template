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
  pageTable.commandHandler({page="pageTimer"},nil,  true)
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
    selectors.componentSelector:onClick(true,  "timerTable")
    local view = require("editor.timer.timerTable")

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
function M.test_new_component()
  timer.performWithDelay( 1000, function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "timerTable")
    local view = require("editor.timer.timerTable")

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
    local buttons = require("editor.timer.buttons")
    buttons.objs["save"].tap{eventName="save"}
  end)
end
--]]

--[[
function M.test_component()
  timer.performWithDelay( 1000, function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "timerTable")
    local view = require("editor.timer.timerTable")
    local obj = view.objs[1]
    obj:touch{phase="ended"}
    ---
    local buttons = require("editor.timer.buttons")
    buttons.objs["save"].tap{eventName="save"}
  end)
end
--]]

--[[
function M.test_action()
  timer.performWithDelay( 1000, function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "actionTable")
    UI.scene.app:dispatchEvent {
      name = "editor.action.selectAction",
      action = "onComplete",
      UI = UI
    }
  end)
end
--]]
return M
