local current = ...
local parent, root = newModule(current)
local M = require(kwikGlobal.ROOT.."editor.parts.baseProps").new()
---------------------------
local assetTable = require(kwikGlobal.ROOT.."editor.asset.assetTable")
local layerTable = require(kwikGlobal.ROOT.."editor.parts.layerTable")
local libUtil    = require(kwikGlobal.ROOT.."lib.util")

M.name = "textProps"
M.class = "sync"
M.type = "line" -- sequenceData
local obj, sentenceDir

function M:setActiveProp(value)
  print("setActiveProp", self.name)
  local UI = self.UI
  --
  assetTable:hide()
  layerTable:show()
  --
  local name =self.activeProp or ""
  for i,v in next, self.objs or {} do
    if v.text == name then -- should be _filename
      v.field.text = value
    elseif v.text == "sentenceDir" then
      sentenceDir = value:sub(1, value:len()-4)
      v.field.text = sentenceDir
    end
    print(v.text)
  end
  --print("Warning activeProp name is not found for", self.activeProp)

  --  update listbox by reading timecodes txt
  --    check word.mp3 in sentenceDir
  local listbox = require(parent.."listbox")
  local path = "App/" .. UI.book.."/assets/audios/"..value
  local sentenceDirPath = "App/"..UI.book.."/assets/audios/"..sentenceDir

  print("@@@@ path" , path)
  print("@@@@ sentenceDirPath" , sentenceDirPath)

  local entries = libUtil.readSyncText(path,sentenceDirPath )
  listbox:setValue(entries, self.type)
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

function M:showThumnail()
end

return M