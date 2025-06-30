local M = {}

local selectors
local UI
local bookTable
local pageTable
local actionTable = require("editor.action.actionTable")
local commandbox = require("editor.action.commandbox")
local actionCommandPropsTable = require("editor.action.actionCommandPropsTable")
local actionController = require("editor.action.controller.index")
local muiName = "editor.action.commandView-"

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
  UI.scene.app:dispatchEvent {
    name = "editor.selector.selectApp",
    UI = UI
  }
  -- appFolder = system.pathForFile("App", system.ResourceDirectory) -- default
  -- useTinyfiledialogs = false -- default
  ---
  bookTable.commandHandler({book="bookFree"}, nil,  true)
  pageTable.commandHandler({page="page3"},nil,  true)
end

function M.setup()
end

function M.teardown()
end

--[[
  function M.test_readAssets()
    local util = require("editor.util")
    util.readAssets("bookFree", "audio")
  end
--]]

---[[
function M.xtest_radioGroup()
  timer.performWithDelay( 1000, function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "audioTable")
    local audioTable = require("editor.audio.audioTable")

    UI.scene.app:dispatchEvent {
      name = "editor.selector.selectAudio",
      UI = UI,
      class = "audio",
      isNew = true, --(name ~= "Trash-icon"),
      isDelete =false -- (name == "Trash-icon")
    }
    -- timer.performWithDelay( 1000,
    -- function()
      local assetbox = require("editor.parts.assetbox")
      assetbox.triangle:tap()
      assetbox.onSwitchPress{target = {isOn = true, id="audiolong"}}
      local obj = assetbox.objs[2]
      obj:tap({numTaps = 1})
      assetbox:scrollToPosition()
    -- end )

    -- local buttons = require("editor.audio.buttons")
    -- buttons.objs["save"].tap{eventName="save"}
  end)
end
--]]

function M.xtest_new_component()
  timer.performWithDelay( 1000, function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "audioTable")
    local audioTable = require("editor.audio.audioTable")

    UI.scene.app:dispatchEvent {
      name = "editor.selector.selectAudio",
      UI = UI,
      class = "audio",
      isNew = true, --(name ~= "Trash-icon"),
      isDelete =false -- (name == "Trash-icon")
    }
    local assetbox = require("editor.parts.assetbox")
    local obj = assetbox.objs[2]
    obj:tap({numTaps = 1})
    assetbox:scrollToPosition()

    -- TODO input new Name
    -- local obj = audioTable.objs[1]
    -- obj:touch{phase="ended"}
    -- ---
    -- local buttons = require("editor.audio.buttons")
    -- buttons.objs["save"].tap{eventName="save"}
  end)
end

function M.xtest_component()
  timer.performWithDelay( 1000, function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "audioTable")
    local audioTable = require("editor.audio.audioTable")
    local obj = audioTable.objs[1]
    obj:touch{phase="ended"}
    ---
    -- local buttons = require("editor.audio.buttons")
    -- buttons.objs["save"].tap{eventName="save"}
  end)
end

function M.test_newAction()

  timer.performWithDelay( 1000, function()


    -- UI.scene.app:dispatchEvent {
    --   name = "editor.action.selectAction",
    --   isNew = true, -- isNew?
    --   UI = UI
    -- }

    -- click UI.editor.actionIcon
    --  it dispatches
    local editor = require("editor.action.index")

    selectors.componentSelector:onClick(true,  "actionTable")
    actionTable.newButton:tap{target=editor.newButton}
    -- selectAction("eventOne")

    -- Audio is muiIcon. This shows audioTable too
    actionController.commandGroupHandler{target={muiOptions={name=muiName.."Audio"}}}

    --select play
    local commandEntry = commandbox.objs[3] -- should we change 'objs' to 'objs'?
    commandEntry:dispatchEvent{name="tap", target=commandEntry}
    -- select _target
    local objEntry = actionCommandPropsTable.objs[1]
     objEntry:dispatchEvent{name="tap", target=objEntry}

    -- select an audio from audio table
    local audioTable = require("editor.audio.audioTable")
    local obj = audioTable.objs[1]
    obj:touch{phase="ended"}

     -- TBI select _trigger
     --  objEntry = actionCommandPropsTable.objs[2]
     --  objEntry:dispatchEvent{name="tap", target=objEntry}



  end)
end

---[[
function M.xtest_action()
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
