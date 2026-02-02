-------------------------------------------------------------------------------
-- Scene Actions
-- Generic scene transition actions
-- Parses scene name from action and transitions using composer
-------------------------------------------------------------------------------
local bt = require("utils.btree")
local BaseSceneAction = require("actions.base_scene_action")
local composer = require("composer")

-- Scene objects reference
local sceneObjects = {}

-- Generic scene transition
local function gotoScene(sceneName)
    if not sceneName then
        print("[ACTION] goto - ERROR: Could not parse scene name")
        return bt.FAILED
    end

    -- Check if uiHandler has enableBehaviorTree for component-based paths
    local uiHandler = pcall(require, "App.uiHandler") and require("App.uiHandler")
    local useComponentPaths = uiHandler and uiHandler.enableBehaviorTree

    local baseName = sceneName:gsub("Scene$", "")
    baseName = baseName:sub(1,1):lower() .. baseName:sub(2)

    local targetScene
    if useComponentPaths then
        targetScene = "App.{{BOOK}}.components." .. baseName .. ".index"
    else
        targetScene = "views." .. baseName .. "." .. sceneName
    end

    print("[ACTION] goto " .. targetScene)
    composer.gotoScene(targetScene, {
        effect = "fade",
        time = 300
    })
    return bt.SUCCESS
end

-- Handle reload action
local function reloadScene()
    print("[ACTION] scene reload")
    local currentScene = composer.getSceneName("current")
    if currentScene then
        -- Use recycleOnSceneChange to force scene recreation without removing
        -- This avoids the kwik framework cleanup that expects appName
        composer.recycleOnSceneChange = true
        composer.gotoScene(currentScene, {
            effect = "fade",
            time = 300,
            params = { reload = true }
        })
        return bt.SUCCESS
    else
        print("[ACTION] scene reload - ERROR: No current scene")
        return bt.FAILED
    end
end

-- Handle next action (go to empty scene)
local function nextScene()
    print("[ACTION] scene next")

    -- Get current scene to copy props if available
    local currentSceneName = composer.getSceneName("current")
    local currentScene = composer.getScene(currentSceneName)
    local params = {}

    -- Store the current scene name (Kwik component scene is fine)
    params.returnToScene = currentSceneName
    print("[scene_actions] Setting returnToScene to: " .. tostring(currentSceneName))

    -- If current scene has UI props, pass them to the next scene
    if currentScene and currentScene.UI and currentScene.UI.props then
        params.sceneProps = {
            UI = currentScene.UI,
            model = currentScene.model,
            getCommands = currentScene.getCommands,
            app = currentScene.app,
            classType = currentScene.classType
        }
    end

    composer.gotoScene("App.{{BOOK}}.behaviorTree.views.emptyScene", {
        effect = "slideLeft",
        time = 300,
        params = params
    })

    return bt.SUCCESS
end

-- Create module using base class
local M = BaseSceneAction.new({
    reload = reloadScene,
    next = nextScene,
    gotoScene = gotoScene,
})

-- Debug flag - set to false to only show debug logs
M.DEBUG_ENABLED = true

-- Override initialize to store scene objects
function M.initialize(objects)
    sceneObjects = objects
    M.sceneObjects = objects
end

return M
