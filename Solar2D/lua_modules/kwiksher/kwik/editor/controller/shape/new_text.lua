local name = ...
local parent,root = newModule(name)
local shape = require(kwikGlobal.ROOT.."editor.shape.index")
---
local instance = require("commands.kwik.baseCommand").new(
  function (params)
    local UI    = params.UI
    local options = params.options
    print(name)
    --
    shape.drawText(UI)
    --
  end
)
--
return instance