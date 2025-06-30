local AC = require("commands.kwik.actionCommand")
local json = require("json")
local actionCommandTable = require(kwikGlobal.ROOT.."editor.action.actionCommandTable")
local actionCommandPropsTable = require(kwikGlobal.ROOT.."editor.action.actionCommandPropsTable")
local actionButtons = require(kwikGlobal.ROOT.."editor.action.buttons")

local util = require(kwikGlobal.ROOT.."editor.util")
local controller = require(kwikGlobal.ROOT.."editor.action.controller.index")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
local picker             = require(kwikGlobal.ROOT.."editor.picker.name")

--
local command = function (params)
	local UI    = params.UI
  local page = params.page or UI.page
  -- print("actionCommand.save")
  UI.editor.actionEditor:hideCommandPropsTable(true)
  actionButtons:show()
  --
  local props, selected = actionCommandPropsTable:getValue()
  -- print("", selected, json.encode(props))
  ---
  local actions = actionCommandTable.actions

  local action = {command=props.type.."."..(selected or ""), params = {}}
  for i=1, #props.properties do
    local entry = props.properties[i]
    -- print(entry.name, entry.value)
    if entry.name == '_target' then
      action.params.target = entry.value
    elseif type(entry.value) == "number" then
      action.params[entry.name] = entry.value
    elseif entry.value:len() > 0 then
      action.params[entry.name] = entry.value:gsub('"',  "'")
    else
      action.params[entry.name] = 'nil'
    end
  end
  --
  --local updatedModel = util.createIndexModel(UI.scene.model, "", "")
  local updatedModel = util.createIndexModel(UI.scene.model)
  local nameText     = UI.editor.currentAction.name
  -- print(nameText)
  local currentIndex = UI.editor.currentActionCommandIndex
  local files = {}

  --
  if props.isNew or (UI.currentAction and UI.currentAction.isNew) then
    actions[#actions + 1] = action
    local newAction = {
      name= nameText,
      actions = actions,
      isNew = true
    }
    UI.editor.currentAction = newAction
    UI.editor.actionCommandStore:set(newAction)
    --[[
      print(json.encode(newAction))
      -- Update components/pageX/index.lua model/pageX/index.json
      updatedModel.commands[#updatedModel.commands + 1] = newAction.name
      --
      files[#files+1] = util.renderIndex(UI.editor.currentBook, page,updatedModel)
      files[#files+1] = util.saveIndex(UI.editor.currentBook, page, props.layer,props.class, updatedModel)
      --
      -- if name contains '.', should we create a folder? maybe later
      --
    --]]
  else
    -- print("",currentIndex)
    actions[currentIndex] = action
    UI.editor.actionCommandStore:set{actions=actions}
    --[[
      UI.editor.currentAction = {
        name= nameText,
        actions = actions
      }
      --
      local current = updatedModel.commands[currentIndex]
      -- Update components/pageX/index.lua model/pageX/index.json
      if current.name ~= nameText then
        --
        -- TODO
        -- delete .json, .lua
        --
        updatedModel.commands[currentIndex] = UI.editor.currentAction
        --
        files[#files+1] = util.renderIndex(UI.editor.currentBook, page, updatedModel)
        files[#files+1] = util.saveIndex(UI.editor.currentBook, page, props.layer,props.class, updatedModel)
      end
    --]]
  end
  --[[
    -- save lua
    files[#files+1] = controller:render(UI.editor.currentBook, page, nameText, actions)
    -- save json
    files[#files+1] = controller:save(UI.editor.currentBook, page, nameText, {name=nameText, actions = actions})
    -- publish
    scripts.backupFiles(files)
    scripts.executeCopyFiles(files)
  --]]

  --[[
    {
      "name": "eventOne",
      "actions" :[
        { "command":"animation.play", "params":{"target":"title-animation"}},
        {"command":"audio.play", "params":{
          "target" : "bgm",
          "type" : "",
          "channel" : "",
          "repeatable" : true,
          "delay" : "",
          "loop" : -1,
          "fade" : "",
          "volume" : "",
          "trigger" : "eventTwo"
        }}
        ]
      }
  ]]

  --
  -- should use selectAction or call UI.editor.actionCommandStore:set()?
  --
  -- UI.scene.app:dispatchEvent {
  --   name = "editor.action.selectAction",
  --   action = event.action,
  --   UI = UI
  -- }
--
end
--
local instance = AC.new(command)
return instance
