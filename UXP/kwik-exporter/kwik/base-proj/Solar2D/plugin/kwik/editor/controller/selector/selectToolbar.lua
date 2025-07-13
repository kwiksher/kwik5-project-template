local AC = require("commands.kwik.actionCommand")
local json = require("json")
local util = require(kwikGlobal.ROOT.."lib.util")
local models = require(kwikGlobal.ROOT.."editor.model").layerTools
--
local command = function (params)
	local UI    = params.UI
  local icon   = params.class
  local tool = params.tool
  -- local toolbar = params.toolbar
  local layer = params.layer

	print("selectToolbar", icon)
  if parms.class then
      -- for Animations, Interactions, Replacements ...
      for i=1, #models do
        local model = models[i]
        if "editor.parts.toolbar-"..model.icon == icon then
          UI.editor.currentToolbar = icon
          --toolbar:toogleToolMap()
          break
        end
      end
      print("", "currentToolbar", UI.editor.currentToolbar)
  end

  if params.tool then
    UI.editor.currentTool = params.tool
  end
  --
  print("", UI.editor.currentToolbar, UI.editor.currentTool)
  UI.editor:setCurrnetSelection(params.layer)
  -- should we use name of UI.editor.editor.currentClass?
  tool.controller.read(UI.editor.currentBook, UI.page, UI.editor.currentLayer, isNew, UI.editor.currentTool)

end
--
local instance = AC.new(command)
return instance
