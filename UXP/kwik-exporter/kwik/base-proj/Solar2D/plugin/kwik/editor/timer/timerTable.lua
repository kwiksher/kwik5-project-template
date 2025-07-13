local name = ...
local parent,root = newModule(name)

local props = require(root.."model").pageTools.timer
props.anchorName = "selectTimer"
props.icons      = {"timers", "trash"}
props.type       = "timers"

local M = require(root.."parts.baseTable").new(props)
M.type = "timers"
M.id = "timer"
return M
