local name = ...
local parent,root = newModule(name)

local shape = require(kwikGlobal.ROOT.."editor.shape.index")

local instance = require("commands.kwik.baseCommand").new(
  function (params)
    local UI    = params.UI
    local options = params.options
    print(name)
    -- local options = params.props.options
    -- if options then
    --   for i, v in next, options.selections  do
    --     print(v.name)
    --   end
    -- else
    --   for i, v in next, UI.editor.selections do
    --     print("", v.layer, v.text, v.class )
    --   end
    -- end
    --
    shape.drawRect(UI)
    --
  end
)
--
return instance