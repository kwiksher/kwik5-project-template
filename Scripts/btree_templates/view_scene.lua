-------------------------------------------------------------------------------
-- {{SCENE_TITLE}} Scene View - BTree Scaffold
-------------------------------------------------------------------------------
local BaseScene = require("views.baseScene")
local common = require("utils.common_helpers")
local displayManager = require("views.display_manager")

local scene = BaseScene:new("{{SCENE}}")

local actionController = require("actions.{{SCENE}}.{{SCENE}}_controller")
local conditionController = require("conditions.{{SCENE}}.{{SCENE}}_condition_controller")

local conditionNames = {
{{CONDITION_LIST}}
}

function scene:create(event)
    local sceneGroup = self.view

    self.objs = self.objs or {}

    local layers = displayManager.createSceneLayers(sceneGroup)
    self.objs.background = layers.background
    self.objs.characterGroup = layers.characters
    self.objs.uiGroup = layers.ui

    -- TODO: add display objects

    actionController.initialize(self.objs)
    conditionController.initialize(self.objs)

    self.behaviorTree = common.loadBehaviorTree("App/{{BOOK}}/behaviorTree/{{TREE_FILE}}", actionController, nil)

    print("{{SCENE_TITLE}} Scene: Created successfully")
end

function scene:show(event)
    if event.phase == "will" then
        common.resetTreeController(self.treeController)
    elseif event.phase == "did" then
        if self.treeController and self.treeController.isComplete then
            return
        end

        if self.behaviorTree and not self.treeController then
            self.treeController = {
                tree = self.behaviorTree,
                isComplete = false,
                timerId = nil,
                tick = function(self)
                    if not self.isComplete then
                        for _, conditionName in ipairs(conditionNames) do
                            local status = conditionController.evaluate(conditionName)
                            if status ~= nil then
                                self.tree:setConditionStatus(conditionName, status)
                            end
                        end

                        local status = self.tree:tick()
                        common.handleTreeTickResult(self, status)
                    end
                end
            }

            self.treeController:tick()
        end
    end
end

function scene:hide(event)
    if event.phase == "will" then
        common.stopTreeController(self.treeController)
    end
end

function scene:destroy(event)
    print("{{SCENE_TITLE}} Scene: Destroy")
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
