-- local simple = require("simpleTree")
-- simple.run()

local view = require("selectorsView")
local commands = require("selectorsCommands")
local tree = require("selectorsTree")

tree:init(commands)
view:create(tree)
tree:tick()