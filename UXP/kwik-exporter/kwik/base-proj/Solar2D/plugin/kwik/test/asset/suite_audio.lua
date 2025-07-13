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
local helper = require("test.helper")

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
end

function M.suite_setup()
  selectors.projectPageSelector:show()
  selectors.projectPageSelector:onClick(true)
end

function M.setup()
end

function M.teardown()
end

function M.xtest_readAssets()
  selectors.componentSelector.iconHander()
  selectors.assetsSelector:iconHander()
  selectors.assetsSelector:onClick(true, "audios")
end


function M.xtest_select_audio()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "audioTable")
    local audioTable = require("editor.audio.audioTable")
    local obj = audioTable.objs[1]
    obj:touch{phase="ended"}
end

function M.xtest_new_component()
  selectors.componentSelector.iconHander()
  selectors.componentSelector:onClick(true,  "audioTable")
  local audioTable = require("editor.audio.audioTable")
  local obj = audioTable.objs[1]
  obj:touch{phase="ended"}
  ---
  -- local buttons = require("editor.audio.buttons")
  -- buttons.objs["save"].tap{eventName="save"}

    -- local assetbox = require("editor.parts.assetbox")
    -- local obj = assetbox.objs[2]
    -- obj:tap({numTaps = 1})
    -- assetbox:scrollToPosition()

    -- TODO input new Name
    -- local obj = audioTable.objs[1]
    -- obj:touch{phase="ended"}
    -- ---
    -- local buttons = require("editor.audio.buttons")
    -- buttons.objs["save"].tap{eventName="save"}
end

function M.xtest_new_component_from_asset()
  selectors.componentSelector.iconHander()

  selectors.assetsSelector:show()
  selectors.assetsSelector:onClick(true, "audios")

  timer.performWithDelay( 1000, function()
    local assetTable = require("editor.asset.assetTable")
    local obj = assetTable.objs[1]
    obj:touch{phase="ended"}

    -- local buttons = require("editor.asset.buttons")
    -- buttons.objs["save"].tap{eventName="save"}
  end)

end

function M.xtest_new_action()
  UI.editor.actionEditor.iconHander()
  actionTable.newButton:tap{target=UI.editor.newButton}
end

function M.xtest_select_action()
  local actionName = "eventAudio"
  local actionCategory = "Audio"
  --
  local editor = require("editor.action.index")
  selectors.componentSelector:onClick(true,  "actionTable")
  helper.actionTable = actionTable
  actionTable.altDown = true
  helper.clickAction(actionName)
  actionTable.altDown = false

  local muiName = "action.commandView-"
-- local actionTable = require("editor.action.actionTable")
  local controller = require("editor.action.controller.index")
  -- Action is muiIcon
  controller.commandGroupHandler{target={muiOptions={name=muiName..actionCategory}}}
end

return M
