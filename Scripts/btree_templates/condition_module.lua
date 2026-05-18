-------------------------------------------------------------------------------
-- {{SCENE_TITLE}} Conditions
-- Auto-generated scaffold
-------------------------------------------------------------------------------
local bt = require("behaivor.btree")
local actionHelper = require("behaivor.action_helper")

local M = actionHelper.createModule()

-- Scene objects reference
local sceneObjects = {}

function M.initialize(objects)
    sceneObjects = objects
    M.sceneObjects = objects
end

M.CONDITIONS = {
{{{CONDITIONS_TABLE}}}
}

{{{CONDITIONS_FUNCTIONS}}}

function M.evaluate(conditionName)
    local condition = M.CONDITIONS[conditionName]
    if condition then
        return condition()
    else
        print("Warning: Unknown condition: " .. tostring(conditionName))
        return bt.FAILED
    end
end

return M
