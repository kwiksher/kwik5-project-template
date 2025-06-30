local M = require(kwikGlobal.ROOT.."editor.parts.baseProps").new()
---------------------------
M.name = "audioProps"
M.class ="sync"

local assetTable = require(kwikGlobal.ROOT.."editor.asset.assetTable")
local layerTable = require(kwikGlobal.ROOT.."editor.parts.layerTable")

function M:showThumnail()
end

function M:setActiveProp(value)

  assetTable:hide()
  layerTable:show()
  print("setActiveProp", self.name)

  local name =self.activeProp or ""
  for i,v in next, self.objs or {} do
    if v.text == name then
      v.field.text = value
      print("###", self.activeProp, value, #self.objs, self)
      return
    end
  end
  print("Warning activeProp name is not found for", self.activeProp)
end

function M:getValue()
  local ret = {}
  for i, v in next, self.objs do
    local key, value = v.text,  v.field.text
    if key == "_filename" then
      key = "filename"
    end
    ret[key] = value
    print("", key, value)
  end
  return ret
end

return M