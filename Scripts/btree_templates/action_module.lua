-------------------------------------------------------------------------------
-- {{SCENE_TITLE}} Actions
-- Auto-generated scaffold
-------------------------------------------------------------------------------
local bt = require("utils.btree")
local actionHelper = require("utils.action_helper")

local M = actionHelper.createModule()

-- Debug flag - set to false to only show debug logs
M.DEBUG_ENABLED = true

-- Scene objects reference
local sceneObjects = {}

function M.initialize(objects)
    sceneObjects = objects
    M.sceneObjects = objects
end

M.ACTIONS = {
{{ACTIONS_TABLE}}
}

{{ACTIONS_FUNCTIONS}}

return M
