-------------------------------------------------------------------------------
-- Base Scene Action
-- Base class for scene actions that handle scene transitions
-------------------------------------------------------------------------------
local bt = require("behaivor.btree")

local BaseSceneAction = {}

-------------------------------------------------------------------------------
-- Creates a new scene action module
-- @param handlers table - { reload, next, gotoScene }
-- @return table - Action module with scene functionality
-------------------------------------------------------------------------------
function BaseSceneAction.new(handlers)
    local M = {}

    M.ACTION_NAME = "scene"

    local sceneHandlers = handlers or {}

    -- Parse scene name from action string
    -- Examples:
    --   "goto buttonScene" -> "buttonScene"
    --   "goto button" -> "buttonScene"
    --   "button" -> "buttonScene"
    local function parseSceneName(actionName)
        local sceneName = actionName

        -- Extract the scene name after "goto " if present
        local gotoName = actionName:match("^goto%s+(.+)$")
        if gotoName then
            sceneName = gotoName
        end

        if sceneName and sceneName ~= "" then
            -- Only add "Scene" suffix if not already present
            if not sceneName:match("Scene$") then
                sceneName = sceneName .. "Scene"
            end
            return sceneName
        end

        return nil
    end

    -- Main execute function
    function M.execute(actionTarget)
        if not actionTarget then
            print("[ACTION] scene - ERROR: No action target specified")
            return bt.FAILED
        end

        if actionTarget == "reload" and sceneHandlers.reload then
            return sceneHandlers.reload()
        end

        if actionTarget == "next" and sceneHandlers.next then
            return sceneHandlers.next()
        end

        local sceneName = parseSceneName(actionTarget)
        if sceneName and sceneHandlers.gotoScene then
            return sceneHandlers.gotoScene(sceneName, actionTarget)
        end

        print("[ACTION] scene - Unknown action: " .. tostring(actionTarget))
        return bt.FAILED
    end

    return M
end

return BaseSceneAction
