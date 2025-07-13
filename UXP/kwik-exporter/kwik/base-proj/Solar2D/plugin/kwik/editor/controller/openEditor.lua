local name = ...
local parent, root = newModule(name)
local toolbar = require(kwikGlobal.ROOT.."editor.parts.toolbar")
local commands = require(kwikGlobal.ROOT.."editor.scripts.commands")
local util     = require(kwikGlobal.ROOT.."editor.util")
local commonType= table:mySet{"group", "timer", "variables", "page"}

local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    local options = params.props.options
    -- print(name, UI.page)
    if options then
      if  options.type == "action" then
        for i, v in next, options.selections  do
          commands.openEditorForCommand(UI.book, UI.page, v.action )
        end
      elseif options.type =="audio" then
        -- for k, value in pairs(v) do print(k, value) end
        for i, v in next, options.selections  do
          commands.openEditor(UI.book, UI.page, "audios/"..v.subclass, v.audio )
        end
      elseif commonType[options.type] then
        for i, v in next, options.selections  do
          commands.openEditor(UI.book, UI.page, options.type, v[options.type] )
        end
      elseif options.type =="asset" then
        -- print(UI.book, options.folder )
        commands.openFinder(UI.book, options.folder )
      end
    elseif UI.editor.selections == nil  then
      -- print("selection == nil")
      commands.openEditorForLayer(UI.book, UI.page, "index")
    else
      -- print("type", UI.editor.currentType)
      for i, v in next, UI.editor.selections do
        -- printKeys(v)
        if v.class == "audio" then
          commands.openEditorForAudio(UI.book, UI.page, v.audio, v.subclass)
        elseif v.class == "timer" then
            commands.openEditor(UI.book, UI.page, "timers",v.timer)
        elseif v.class == "variable" then
                commands.openEditor(UI.book, UI.page, "variables",v.variable)
       elseif v.class == "joint" then
            commands.openEditor(UI.book, UI.page, "joints",v.joint)
        elseif v.parentObj then
          local layer = util.getLayerPath(v)
          commands.openEditorForLayer(UI.book, UI.page, layer, v.class)
        else
          commands.openEditorForLayer(UI.book, UI.page, v.layer, v.class, UI.editor.currentType)
        end
      end
    end
    --
  end
)
--
return instance
