local AC = require("commands.kwik.actionCommand")
-- local App = require(kwikGlobal.ROOT.."controller.Application")
local json = require("json")
--
local command = function (params)
	local UI    = params.UI
  print("action.copy", params.action, params.class)
  -- print(#params.selections)

  local clipboard = UI.editor.clipboard
  local data = {}
  data.actions = {}
  data.actionCommands = {}
  data.book = UI.book
  data.page = UI.page
  --
  if params.class == "action" then
    if params.selections then
      for i, v in next, UI.editor.selections do
        print(i, v.action)
        local model = require("App."..UI.book..".commands."..UI.page.."."..v.action).model
        decoded, pos, msg = json.decode( model )
        if not decoded then
          print( "Decode failed at "..tostring(pos)..": "..tostring(msg) )
          break
        end
        data.actions[#data.actions + 1] = decoded
      end
    else
      local model = require("App."..UI.book..".commands."..UI.page.."."..params.action).model
      print(model)
      data.actions[#data.actions + 1] = model
    end
  elseif params.class == "actionCommand" then
    local name = UI.editor.currentAction.name
    local model = require("App."..book..".commands."..page.."."..name).model
    local decoded = json.decode(model)
    if params.selections then
      for i, v in next, UI.editor.selections do
        table.insert(data.actionCommands, decoded.actions[v.index])
      end
    else
      data.actionCommands[1] = decoded.actions[params.index]
    end

  end
  UI.editor.clipboard:save(data)
--
end
--
local instance = AC.new(command)
return instance
