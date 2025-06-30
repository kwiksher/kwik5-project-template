local name = ...
local parent, root = newModule(name)
local listbox = require(root.."listbox")
--
local instance =
  require("commands.kwik.baseCommand").new(
  function(params)
    local UI = params.UI
    local default, entry
    local index = params.index
    print(name, params.type, index)
    --
    -- params came from listbox.addEvent
    --    index = #self.objs,
    --    type = self.type
    --
    --for sync, append a entry of a line in defaults.sync
    if params.type =="line" then
      default = require(kwikGlobal.ROOT.."template.components.pageX.replacement.defaults.sync")
      entry = default.line[1]
    elseif (params.type == "sequenceData") then
      default = require(kwikGlobal.ROOT.."template.components.pageX.replacement.defaults.spritesheet")
      entry = default.sequenceData[1]
    end
    -- append is to re-create the list box
    print(#listbox.value)
    table.insert(listbox.value, entry)
    print(#listbox.value)
    listbox:destroy()
    listbox:setValue()
    -- select the last index
    listbox.singleClickEvent(listbox.objs[#listbox.objs])
  end
)
--
return instance
