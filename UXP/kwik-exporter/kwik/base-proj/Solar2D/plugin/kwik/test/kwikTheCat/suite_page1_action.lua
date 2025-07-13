local M = {}

local selectors
local UI
local bookTable
local pageTable
local actionTable = require("editor.action.actionTable")
local commandbox = require("editor.action.commandbox")
local actionCommandPropsTable = require("editor.action.actionCommandPropsTable")

local helper = require("test.helper")

function selectTool(args)
  UI.scene.app:dispatchEvent(
    {
      name = "editor.selector.selectTool",
      UI = UI,
      class = args.class, -- obj.class,
      -- toolbar = self,
      isNew = args.isNew
    }
  )
end

local muiName = "action.commandView-"
-- local actionTable = require("editor.action.actionTable")
local controller = require("editor.action.controller.index")

--
function selectAction(name)
  for i, v in next, actionTable.objs do
    print("###", v.text)
    if v.text == name then
      -- v:dispatchEvent{name="touch", pahse="ended", target=v}
      v:tap{target=v}
      return
    end
  end
end


function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
end

function M.suite_setup()
  -- selectors.projectPageSelector:show()
  -- selectors.projectPageSelector:onClick(true)
  --
  -- UI.scene.app:dispatchEvent {
  --   name = "editor.selector.selectApp",
  --   UI = UI
  -- }
  -- appFolder = system.pathForFile("App", system.ResourceDirectory) -- default
  -- useTinyfiledialogs = false -- default
  ---
  -- bookTable.commandHandler({book="book"}, nil,  true)
  -- pageTable.commandHandler({page="page1"},nil,  true)
  -- timer.performWithDelay( 1000, function()
  -- end)

  --selectors.componentSelector:onClick(true,  "layerTable")

end

function M.setup()
end

function M.teardown()
end

-- function M.test_component()
--     selectors.projectPageSelector:show()
-- end

function M.xtest_new_action()
  UI.editor.actionEditor.iconHander()
  actionTable.newButton:tap{target=editor.newButton}
end

function M.xtest_select_action()
  UI.testCallback = function()
    --
    UI.editor.actionEditor.iconHander()

    selectAction("eventOne")

   --- select a command
   local commandsTable = require("editor.action.actionCommandTable")
   local obj = commandsTable.objs[1]
   commandsTable:singleClickEvent(obj)

    -- select a layer
    -- local propsTable = require("editor.action.actionCommandPropsTable")
    -- local linkbox = propsTable.linkbox
    -- local obj = linkbox.objs[1]
    -- obj:tap({numTaps = 1})

   -- save command props
      -- UI.scene.app:dispatchEvent {
      --   name = "editor.actionCommand.save",
      --   UI = UI,
      -- }

  -- -- editor.editButton:tap{target=editor.editButton}
  -- controller.commandGroupHandler{target={muiOptions={name=muiName.."Page"}}}
  end
end

function M.xtest_select_multi_actions()
  -- UI.testCallback = function()
  --
  UI.editor.actionEditor.iconHander()
  actionTable.controlDown = true
  selectAction("eventOne")
  selectAction("eventTwo")
  actionTable.controlDown = false
  -- end

  local buttons = require("editor.action.buttons")
  buttons.objs.cancel.tap{eventName="delete"}
end

function M.xtest_select_multi_actionCommands()
  -- UI.testCallback = function()
  --
  UI.editor.actionEditor.iconHander()
  selectAction("eventOne")
  -- end

  local buttons = require("editor.action.actionCommandButtons")
  buttons.objs.cancel.tap{eventName="delete"}


end

--[[
function M.test_drag()
  assert(true, "drag and drop to change the order of commands")
end
--]]

--[[
function M.test_selectAction()
  assert(truee, "show selected action name and set a focus (text color) in selector")
end
--]]

--[[
function M.test_save()
  --just save eventOne
end
--]]

--[[
function M.test_cancel()
  -- 1. cancel to close it
end
-- ]]

--[[
function M.test_commandEditorShow()
  -- show
  -- 1.0 click an command entry in commands Table
  -- 1.1 open commandEditor with the command
  -- 1.2 cancel to close it
  local editor = require("editor.action.actionCommandTable")
  timer.performWithDelay(1000, function()
    for k, v in pairs(editor) do print(k, v) end
    local obj = actionTable.objs[1]
    editor.singleClickEvent(obj)
    --
    alocal buttons = require("editor.action.buttons")
    buttons.objs["cancel"].tap{eventName="cancel"}
  end)
  --
end
--]]

--[[
function M.test_modifyActionCommnad()
  -- click UI.editor.actionIcon
  --  it dispatches
    UI.scene.app:dispatchEvent {
      name = "editor.action.selectAction",
      action = "act01",
      UI = UI
    }
   --- select a command
   local commandsTable = require("editor.action.actionCommandTable")
   local obj = commandsTable.objs[1]
    commandsTable.singleClickEvent(obj)

    -- select a layer
    -- local propsTable = require("editor.action.actionCommandPropsTable")
    -- local linkbox = propsTable.linkbox
    -- local obj = linkbox.objs[1]
    -- obj:tap({numTaps = 1})

   -- save command props
      -- UI.scene.app:dispatchEvent {
      --   name = "editor.actionCommand.save",
      --   UI = UI,
      -- }

  end
--]]


function M.test_newActionButton()
  -- click UI.editor.actionIcon
  --  it dispatches
  local editor = require("editor.action.index")

  selectors.componentSelector:onClick(true,  "actionTable")
  actionTable.newButton:tap{target=editor.newButton}
  -- selectAction("eventOne")

  -- Animation is muiIcon
  controller.commandGroupHandler{target={muiOptions={name=muiName.."Animation"}}}
  selectors.componentSelector:onClick(true,  "layerTable")

  --select play
  local commandEntry = commandbox.objs[2] -- should we change 'objs' to 'objs'?
  commandEntry:dispatchEvent{name="tap", target=commandEntry}
  -- select _target
  local objEntry = actionCommandPropsTable.objs[1]
  objEntry:dispatchEvent{name="tap", target=objEntry}

  helper.selectLayer("cat", "linear")

-- select a layer's animation (one of animation class)

  -- button is newText, please see model.lua for commandClass
  --controller.commandHandler{model={commandClass = "button"}}

  -- action name
    -- local editor = require("editor.action.index")
    -- editor.selectbox.selectedObj = editor.selectbox.objs[1]
    -- editor.selectbox.selectedObj.field.text = "act01"
    -- editor.selectbox:textListener(nil, {phase = "ended"})

   --- select button command
    -- UI.scene.app:dispatchEvent {
    --   name = "editor.action.selectActionCommand",
    --   UI = UI,
    --   value = "button", -- obj.model.commandClass
    --   isNew = true
    -- }
    --

   --- select a layer
    -- local propsTable = require("editor.action.actionCommandPropsTable")
    -- local linkbox = propsTable.linkbox
    -- local obj = linkbox.objs[2]
    --   obj:tap({numTaps = 1})
   --

   --- save command props
      -- UI.scene.app:dispatchEvent {
      --   name = "editor.actionCommand.save",
      --   UI = UI,
      -- }
    --
end

--[[
function M.test_newActionAnimation()
  -- click UI.editor.actionIcon
  --  it dispatches
    UI.scene.app:dispatchEvent {
      name = "editor.action.selectAction",
      isNew = true, -- isNew?
      UI = UI
    }
    -- action name
    local editor = require("editor.action.index")
    editor.selectbox.selectedObj = editor.selectbox.objs[1]
    editor.selectbox.selectedObj.field.text = "act01"
    editor.selectbox:textListener(nil, {phase = "ended"})
    -- select animation
    UI.scene.app:dispatchEvent {
      name = "editor.action.selectActionCommand",
      UI = UI,
      value = "animation", -- obj.model.commandClass
      isNew = true
    }
    --
    --
    -- should we add it to actionCommandTable?
    --
    -- select animation > play
    local commandbox = require("editor.action.commandbox")
    local obj = commandbox.objs[2]
    obj:tap({numTaps = 1})

      -- save command props
      UI.scene.app:dispatchEvent {
        name = "editor.actionCommand.save",
        UI = UI,
        page = "page1"
      }
    --
    --
    -- TODO actionCommand.save
    --   close the command props
    --   add the command to the table
    --   the buttons of action editor are displayed
    --
    -- save action
    -- UI.scene.app:dispatchEvent {
    --   name = "editor.save",
    --   UI = UI
    -- }

    -- local actionCommandTable = require("editor.action.actionCommandTable")
      --print("###", #actionCommandTable.objs)
      -- local obj = actionCommandTable.objs
      -- actionCommandTable.singleClickEvent(obj)

  -- TODO) inputText for action name
  --  create a command
    -- 2.0 click a new command
      -- 2.0.1 open it in command editor
    -- 2.1 save button in commandEditor
      -- 2.1.1 save it in memory
      -- 2.1.2 add it to commands table
    -- 2.2 save button of actionEditor
       -- 2.2.1 render/save lua & json
end
--]]

--[[
function M.test_commandEditor()
  --  create a command
    -- 2.0 click a new command
      -- 2.0.1 open it in command editor
    -- 2.1 save button in commandEditor
      -- 2.1.1 save it in memory
      -- 2.1.2 add it to commands table
    -- 2.2 save button of actionEditor
       -- 2.2.1 render/save lua & json
  -- delete a command
    -- 3.0 click delete button
    -- 3.1 show OK? dialog
      -- 3.1.1 remove it in memory
      -- 3.1.2 remove it commands table
      -- 3.1.3 close commandEditor
    -- 3.2 save button
  -- update a command
    -- commands editor
      -- modify values of props
      --  save button
        --  update commands Table
      --  close
    --  save button
end
--]]

return M
