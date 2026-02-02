-------------------------------------------------------------------------------
-- {{SCENE_TITLE}} Action Controller
-- Auto-generated scaffold
-------------------------------------------------------------------------------
local actionHelper = require("utils.action_helper")

-- Module paths
local modulePaths = {
{{MODULE_PATHS}}
}

-- Create controller using action_helper.new with custom routing
local M = actionHelper.new(
    modulePaths,
    {
        simpleRouting = {
{{SIMPLE_ROUTING}}
        }
    },
    "{{SCENE_TITLE}} Action Controller"
)

return M
