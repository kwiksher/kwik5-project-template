-------------------------------------------------------------------------------
-- {{SCENE_TITLE}} Condition Controller
-- Auto-generated scaffold
-------------------------------------------------------------------------------
local bt = require("utils.btree")

-- Module paths
local modulePaths = {
{{COND_MODULE_PATHS}}
}

local M = {}
local conditions = {}

function M.initialize(objects)
    -- Load all condition modules
    for name, path in pairs(modulePaths) do
        local success, module = pcall(require, path)
        if success then
            -- Check if module has generateConditions (e.g. dynamic conditions)
            if module.generateConditions then
                local generatedConditions = module.generateConditions()
                for conditionName, conditionWrapper in pairs(generatedConditions) do
                    conditions[conditionName] = conditionWrapper
                    print("{{SCENE_TITLE}} Condition Controller: Registered generated condition '" .. conditionName .. "'")
                end
            else
                if module.initialize then
                    module.initialize(objects)
                end
                conditions[name] = module
                print("{{SCENE_TITLE}} Condition Controller: Loaded module '" .. name .. "' from " .. path)
            end

            -- Initialize all conditions with objects
            if module.initialize then
                module.initialize(objects)
            end
        else
            print("Warning: Failed to load condition module '" .. name .. "': " .. tostring(module))
        end
    end

    print("{{SCENE_TITLE}} Condition Controller: Initialized successfully")
end

-- Evaluate function
function M.evaluate(conditionName)
    -- Check if we have a specific condition registered
    if conditions[conditionName] and conditions[conditionName].evaluate then
        return conditions[conditionName].evaluate()
    end

    -- Fallback: try calling evaluate on each module
    for moduleName, module in pairs(conditions) do
        if module.evaluate then
            local result = module.evaluate(conditionName)
            if result ~= nil then
                return result
            end
        end
    end

    print("Warning: No module found to evaluate condition: " .. tostring(conditionName))
    return false
end

return M
