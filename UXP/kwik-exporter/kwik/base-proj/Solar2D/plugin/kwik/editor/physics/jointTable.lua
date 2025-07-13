local name = ...
local parent,root = newModule(name)

    -- joint = {
    --   name = "Joint",
    --   id = "joint"
    -- },

-- local props = require(root.."model").pageTools.joint
local props = {
  name = "Joint",
  id = "joint",
  anchorName = "selectJoint",
  icons      = {"phyJoint", "trash"},
  type       = "joints",
}

local M = require(root.."parts.baseTable").new(props)
return M
