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
  bookTable.commandHandler({book="bookFree"}, nil,  true)
end

function M.setup()
end

function M.teardown()
end

----
local commands = require("editor.scripts.commands")
---
function M.xtest_vscode_layer_index()
  local page = "page4"
  pageTable.commandHandler({page=page},nil,  true)
  UI.testCallback = function()
    -- UI.page = "page4"
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    --
    -- commands.openEditorForLayer("bookFree", "page1", "index")
    --
    for i, obj in next, selectors.componentSelector.objs do
      if obj.text == "Layer" then
        obj:dispatchEvent{name= "mouse", target=obj, isSecondaryButtonDown=true, x = obj.x, y = obj.y}
        break
      end
    end

    helper.clickButton("openEditor")

    -- selectorBase.lua createSelection to have mouse hover handler
    --
  end
end

function M.xtest_vscode_layer()
  local page = "page1"
  pageTable.commandHandler({page=page},nil,  true)
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    --
    -- commands.openEditorForLayer("bookFree", "page1", "title")
    --
    -- parts/layerTableCommands.lua
    --
    local name = "title"
    -- layerTable.altDown = true
    helper.selectLayer(name)
    helper.selectLayer(name, nil, true) -- isRightClick true
    helper.clickButton("openEditor")
  end
end

function M.xtest_vscode_class()
  local page = "page1"
  pageTable.commandHandler({page=page},nil,  true)
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    --
    -- commands.openEditorForLayer("bookFree", "page1", "title", "linear")
    --
    -- parts/layerTableCommands.lua
    --
    local name = "title"
    local class = "linear"
    -- layerTable.altDown = true
    helper.selectLayer(name, class, false) -- isRightClick false
    helper.selectLayer(name, class, true) -- isRightClick true
    helper.clickButton("openEditor")
    -- layerTable.altDown = false
  end
end

function M.xtest_multi_edit()
  local page = "page1"
  pageTable.commandHandler({page=page},nil,  true)
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "layerTable")
    ---
    layerTable.controlDown = true
    ---
    local names = {"title", "gotoBtn", "bg"}
    for i, name in next, names do
      helper.selectLayer(name)
      helper.selectLayer(name, nil, true) -- isRightClick true
    end
    layerTable.controlDown = false
    ---
    helper.clickButton("openEditor")
  end
end


function M.xtest_vscode_command()
  local page = "page1"
  pageTable.commandHandler({page=page},nil,  true)
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "actionTable")
    ---
    -- commands.openEditorForCommand("bookFree", "page1", "eventOne")
    --
    -- action/actionTable.lua
    --
    helper.selectAction("eventOne")
    helper.selectAction("eventOne", true) -- isRightClick
    helper.clickButton("openEditor")
  end
end

function M.xtest_vscode_command_multi()
  local page = "page1"
  pageTable.commandHandler({page=page},nil,  true)
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "actionTable")
    ---
    -- commands.openEditorForCommand("bookFree", "page1", "eventOne")
    --
    -- action/actionTable.lua
    --
    actionTable.controlDown = true
    helper.selectAction("eventOne")
    helper.selectAction("eventTwo")
    helper.selectAction("eventOne", true) -- isRightClick
    actionTable.controlDown = false
    helper.clickButton("openEditor")
  end
end

function M.xtest_vscode_audio()
  local page = "page3"
  pageTable.commandHandler({page=page},nil,  true)
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "audioTable")
    --
    -- commands.openEditor("bookFree", "page3", "audios/long", "GentleRain")
    --
    -- audio/audioTable.lua newAudio()
    --
    audioTable.controlDown = true
    helper.selectAudio("GentleRain")
    helper.selectAudio("Tranquility")
    helper.selectAudio("Tranquility", true) -- isRightClick
    audioTable.controlDown = false
    helper.clickButton("openEditor")
  end
end

--
-- To be specified
--
-- group/timer/variable uses baseTable.lua
--   baseTable is used for assetTable and pageTable too,
--     vscode to open asset folder, and App/components?
-- multi sections?
--

function M.xtest_vscode_group()
  local page = "page4"
  pageTable.commandHandler({page=page},nil,  true)
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "groupTable")
    -- commands.openEditor("bookFree", "page4", "groups", "myGroup")
  end
end

function M.xtest_vscode_timer()
  local page = "pageTimer"
  pageTable.commandHandler({page=page},nil,  true)
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "timerTable")
    -- commands.openEditor("bookFree", "pageTimer", "timers", "timerOne")
  end
end

function M.xtest_vscode_variable()
  local page = "pageVariable"
  pageTable.commandHandler({page=page},nil,  true)
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.componentSelector:onClick(true,  "variableTable")
    -- commands.openEditor("bookFree", "pageVariable", "variables", "varOne")
    variableTable.controlDown = true
    helper.selectVariable("varOne")
    helper.selectVariable("varTwo")
    helper.selectVariable("varTwo", true) -- isRightClick
    variableTable.controlDown = false
    helper.clickButton("openEditor")
  end
end
--
-- assets folder is opened in Finder
--- multi select and new from assetTable, edit/delete/vscode are not supported so it opens asset folder in Finder instead
--
function M.xtest_finder_asset()
  local page = "page1"
  pageTable.commandHandler({page=page},nil,  true)
  UI.testCallback = function()
    selectors.componentSelector.iconHander()
    selectors.assetsSelector:show()

    -- local video_index = 5
    -- local target = selectors.assetsSelector.objs[video_index]
    -- target:dispatchEvent({name="tap", target=target})

    local audio_index = 1
    local target = selectors.assetsSelector.objs[audio_index]
    target:dispatchEvent({name="tap", target=target})

    assetTable.controlDown = true
    helper.selectAsset("alphabet/a.mp3")
    helper.selectAsset("alphabet/b.mp3")
    helper.selectAsset("alphabet/b.mp3", true) -- isRightClick
    assetTable.controlDown = false
    helper.clickButton("openEditor")

  end

end

function M.xtest_vscode_pageTable()
end

function M.xtest_vscode_bookTable()
end
------
return M
