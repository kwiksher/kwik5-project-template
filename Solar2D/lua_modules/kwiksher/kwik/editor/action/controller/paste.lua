local AC   = require("commands.kwik.actionCommand")
local util = require(kwikGlobal.ROOT.."editor.util")
local controller = require(kwikGlobal.ROOT.."editor.action.controller.index")
local json = require("json")
local scripts = require(kwikGlobal.ROOT.."editor.scripts.commands")

--
local command = function (params)
  local root, commands
	local UI    = params.UI
  print("action.paste at", params.action, params.class)
  local book = UI.editor.currentBook
  local page = UI.page
  local data = UI.editor.clipboard:read()
  -- clipboard.actions = {}
  -- clipboard.actionCommands = {}
  -- --
  local files = {}
  local updatedModel = util.createIndexModel(UI.scene.model)
  local namesMap = {}
  for i, v in next, updatedModel.commands do
      namesMap[v] = i
  end
  ---
  if params.class == "action" then
    if params.selections then
    else
      if #data.actions > 0 then
        for i, contents in next, data.actions do
            local decoded = json.decode(contents)
            local index = namesMap[decoded.name]
            if index then
              decoded.name = decoded.name.."_copied"
            end
            table.insert(updatedModel.commands, decoded.name)
            -- save lua
            files[#files+1] = controller:render(book, page, decoded.name, decoded.actions)
            -- save json
            files[#files+1] = controller:save(book, page, decoded.name, decoded)
        end
      end
      -- save index lua
      files[#files+1] = util.renderIndex(book, page,updatedModel)
      -- save index json
      files[#files+1] = util.saveIndex(book, page, nil, nil, updatedModel)

      scripts.saveSelection(book, page, {{name = "action pasted"}})
      scripts.backupFiles(files)
      scripts.executeCopyFiles(files)

    end
  elseif params.class =="actoinCommand" then
    local name = UI.editor.currentAction.name
    local path = "App."..book..".commands."..page.."."..name
    local model = require(path).model
    local decoded = json.decode(model)

    for i, v in next, data.actionCommands do
      table.insert(decoded.actions, params.index+i, v)
    end
    -- save lua
    files[#files+1] = controller:render(book, page, name, decoded.actions)
    -- save json
    files[#files+1] = controller:save(book, page, name, decoded)

    scripts.saveSelection(book, page, {{name = "actionCommand pasted"}})
    scripts.backupFiles(files)
    scripts.executeCopyFiles(files)
  end
--
end
--
local instance = AC.new(command)
return instance
