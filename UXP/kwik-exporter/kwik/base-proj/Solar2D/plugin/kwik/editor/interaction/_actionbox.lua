local M = require(kwikGlobal.ROOT.."editor.parts.linkbox").new()

---------------------------
M.name = "onComplete"
M.selectedTextLabel = ""
--
-- load(UI, type, x, y, selectedValue)
--    type = {"action", "animation", "group", "audio"}
--    type.animation loads pageX/index.json to list layers
--    type.action loads the list of files in pageX/commands folder
--  see editor/util.lua read
--        setFiles(ret.audios, "/audios/short")
--        setFiles(ret.audios, "/audios/long")
--        setFiles(ret.groups, "/groups")
--        setFiles(ret.groups, "/commands")

function M:init(UI, x, y, w, h)
   self:_init(UI, x or display.contentCenterX, y or (display.contentCenterY + 200), w, h, "action")
  --self:_init(UI, x , y , "action")
end

return M