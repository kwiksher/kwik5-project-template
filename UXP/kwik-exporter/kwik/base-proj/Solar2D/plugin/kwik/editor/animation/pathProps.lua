local M = require(kwikGlobal.ROOT.."editor.parts.baseProps").new({width=50})
local classProps              = require(kwikGlobal.ROOT.."editor.parts.classProps")
M.class = "path"
M.showThumnail = classProps.showThumnail
return M