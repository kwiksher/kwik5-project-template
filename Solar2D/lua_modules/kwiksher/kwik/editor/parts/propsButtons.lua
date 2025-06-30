local M = {}
local current = ...
local parent,  root = newModule(current)

M.name = current
M.weight = 1
--
-- local button = require("com.gieson.Button")
-- local tools = require("com.gieson.Tools")
---
local Props =  {
  name = "group",
  commandClass = "properties",
  anchorName = "selectLayer",
  model = {
  -- {name="copy",   label="Copy"},
  -- {name= "paste", label="Paste"},
  -- {name="preview",label="Preview"},
  -- {name="create", label="New"},
  -- {name="delete", label="Delete"},
  {name="save",   label="Save"},
  {name="cancel", label="Cancel"}}
}


local M = require(parent.."baseButtons").new(Props)

--
return M
