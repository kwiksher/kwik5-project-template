local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local App = require(kwikGlobal.ROOT.."controller.Application")
local picker = require(kwikGlobal.ROOT.."editor.picker.name")
local buttons = require(kwikGlobal.ROOT.."editor.action.buttons")

--
local command = function (params)
	local UI         = params.UI
  local decoded, pas, msg

  local function showEditor (decoded)
    UI.editor.currentAction  = decoded
    --
    -- if UI.editor.actionEditor.isVisible then
    --   UI.editor.actionEditor:hide()
    -- else
      UI.editor.actionEditor:show(true)
      --UI.editor.editPropsLabel = UI.editor.currentAction.name
      UI.editor.actionCommandStore:set(decoded)
      buttons:show()

    -- end
  end
  ---
  if params.isNew then -- comes form newHandler
    decoded = {isNew = true, name="", actions={}}

    local listener = function(name)
      if name and name:len() > 0 then
        decoded.name = name
        -- print(name)
        showEditor(decoded)
      else
        print("TODO popup error message")
        picker:destroy()
      end
    end
    picker:create(listener)
  else
    -- local path =system.pathForFile( "App/"..App.get().name.."/models/"..UI.page.."/commands/"..params.action..".json", system.ResourceDirectory)
    -- decoded, pos, msg = json.decodeFile( path )
    local model = require("App."..App.get().name..".commands."..UI.page.."."..params.action).model
    decoded, pos, msg = json.decode( model )
    if not decoded then
      print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
      return
    end

    local textListener = function(event)
      if ( event.phase == "began" ) then
        -- User begins editor "defaultField"
      elseif ( event.phase == "ended" or event.phase == "submitted" ) then
          -- Output resulting text from "defaultField"
          print( event.target.text )
          UI.editor.currentAction.name_updated = event.target.text
      elseif ( event.phase == "editor" ) then
          -- print( event.newCharacters )
          -- print( event.oldText )
          -- print( event.startPosition )
          -- print( event.text )
      end
    end

    --UI.editor.actionEditor.selectbox:updateValue(decoded.name)
    showEditor(decoded)
    picker:create()
    picker.obj.field.text = decoded.name or params.action
    picker.obj.field:addEventListener( "userInput", textListener )
    UI.editor.currentAction.name_updated = decoded.name or params.action
  end
  --
end
--
local instance = AC.new(command)
return instance
