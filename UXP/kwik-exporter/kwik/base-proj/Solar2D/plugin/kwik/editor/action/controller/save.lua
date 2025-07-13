local AC                 = require("commands.kwik.actionCommand")
local util               = require(kwikGlobal.ROOT.."editor.util")
local controller         = require(kwikGlobal.ROOT.."editor.action.controller.index")
local actionCommandTable = require(kwikGlobal.ROOT.."editor.action.actionCommandTable")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")
local picker             = require(kwikGlobal.ROOT.."editor.picker.name")
local actionTable        = require(kwikGlobal.ROOT.."editor.action.actionTable")
--
local command = function (params)
	local UI    = params.UI
  local page = params.page or UI.page
  --local updatedModel = util.createIndexModel(UI.scene.model, "", "")
  local updatedModel = util.createIndexModel(UI.scene.model)
  local nameText     = UI.editor.currentAction.name -- picker.obj.field.text

  -- print("action.save", nameText)

  -- if UI.editor.actionEditor.selectbox.selectedObj then
  --   nameText = UI.editor.actionEditor.selectbox.selectedObj.text
  -- end
  -- printTable(UI.editor,currentAction)
  if UI.editor.currentAction.isNew then
    -- for i, v in next, updatedModel.commands do
    --   if v == nameText then
    --     nameText = nameText..math.random()
    --     break
    --   end
    -- end
    table.insert(updatedModel.commands, nameText)
  elseif nameText ~= UI.editor.currentAction.name_updated then
    nameText = UI.editor.currentAction.name_updated
    local updated = {}
    for i, v in next, updatedModel.commands do
      if UI.editor.currentAction.name ~= v then
        updated [#updated+1] = v
      else
        updated [#updated+1] = nameText
      end
    end
    updatedModel.commands = updated
  end

  local currentIndex = UI.editor.currentActionCommandIndex
  local files = {}
  --
  local actions = actionCommandTable.actions
  local readonly = actionCommandTable.readonly

  for i=1, #actions do
    print(actions[i].command)
  end

  -- print(nameText)

  local newAction = {
    name= nameText,
    actions = actions
  }
  UI.editor.currentAction = newAction

  if actionTable.actionbox then
    --
    newAction.controller = controller
    UI.editor.currentActionForSave = function() return newAction.name, newAction.actions, newAction.controller end
    local partsButtons       = require(kwikGlobal.ROOT.."editor.parts.buttons")
    local audioButtons       = require(kwikGlobal.ROOT.."editor.audio.buttons")
    local classProps         = require(kwikGlobal.ROOT.."editor.parts.classProps")
    local classPropsPhysics  = require(kwikGlobal.ROOT.."editor.physics.classProps")
    local actionEditor  = require(kwikGlobal.ROOT.."editor.action.index")
    actionTable.actionbox:setActiveProp(newAction.name)
    --
    actionEditor:hide()
    --
    if classProps.origVisible then
      classProps:show()
    end
    if classPropsPhysics.origVisible then
      classPropsPhysics:show()
    end
    if classProps.type == "editor.timer.index" then
      for i, v in next, actionEditor.otherButtons do
        v:show()
      end
    elseif UI.editor.currentClass == "audio" then
      audioButtons:show()
    else
      partsButtons:show()
    end

  elseif not readonly then
    -- save index lua
    files[#files+1] = util.renderIndex(UI.editor.currentBook, page,updatedModel)
    -- save index json
    files[#files+1] = util.saveIndex(UI.editor.currentBook, page, nil, nil, updatedModel)
    -- save lua
    files[#files+1] = controller:render(UI.editor.currentBook, page, nameText, actions)
    -- save json
    files[#files+1] = controller:save(UI.editor.currentBook, page, nameText, {name=nameText, actions = actions})
    scripts.backupFiles(files)
    scripts.executeCopyFiles(files)
  end
--
end
--
local instance = AC.new(command)
return instance
