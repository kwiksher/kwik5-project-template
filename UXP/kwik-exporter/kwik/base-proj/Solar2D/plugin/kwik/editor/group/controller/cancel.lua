local name = ...
local tool      = require(kwikGlobal.ROOT.."editor.group.index")

local instance = require("commands.kwik.baseCommand").new(
  function (params)
    local UI    = params.UI
    -- print(name)
    -- print(UI.editor.currentTool.model.id)
    tool.controller:hide()
    if UI.editor.focusGroup then
      UI.editor.focusGroup:removeSelf()
    end
    UI.editor.currentTool = nil

  end
)
--
return instance