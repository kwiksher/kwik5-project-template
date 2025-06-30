local current = ...
local parent,root, M = newModule(current)

local pointA = require(parent.."pointA")

M.ptAcolor = {0/255, 178/255, 255/255, 0.5}
M.ptAtext = "B"

return setmetatable(M, {__index=pointA})
