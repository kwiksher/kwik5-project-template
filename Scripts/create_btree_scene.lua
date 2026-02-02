#!/usr/bin/env lua

local function usage(script)
    print("Usage: " .. script .. " [dst] [book] [scene|treeFile]")
    print("  dst: e.g. Solar2D")
    print("  book: e.g. BTree_test")
    print("  scene|treeFile: scene name (e.g. narration) or .tree file (e.g. narration_scene.tree)")
end

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function shell_escape(path)
    return '"' .. path:gsub('"', '\\"') .. '"'
end

local function mkdir_p(path)
    os.execute("mkdir -p " .. shell_escape(path))
end

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

local function write_file(path, content)
    local f = io.open(path, "w")
    if not f then
        error("Failed to write file: " .. path)
    end
    f:write(content)
    f:close()
end

local function dirname(path)
    local dir = path:match("^(.*)/[^/]*$")
    return dir or "."
end

local function basename(path)
    return path:match("([^/]+)$") or path
end

local function add_lustache_paths(base_dir)
    local paths = {
        base_dir .. "/btree_templates/?.lua",
        base_dir .. "/btree_templates/?/?.lua",
        base_dir .. "/../BookServer/compress_assets/?.lua",
        base_dir .. "/../BookServer/compress_assets/?/?.lua",
        base_dir .. "/../tools/generate_scene_index/?.lua",
    }
    for _, p in ipairs(paths) do
        if not package.path:match(p, 1, true) then
            package.path = package.path .. ";" .. p
        end
    end
end

local function unique_list(items)
    local seen = {}
    local result = {}
    for _, item in ipairs(items) do
        if item ~= "" and not seen[item] then
            seen[item] = true
            table.insert(result, item)
        end
    end
    return result
end

local script = arg[0] or "create_btree_scene.lua"
local dst = arg[1]
local book = arg[2]
local sceneOrTree = arg[3]

if not dst or not book then
    print("Error: Missing required arguments.")
    usage(script)
    os.exit(1)
end

if not sceneOrTree then
    print("Error: No scene or tree file provided.")
    usage(script)
    os.exit(1)
end

local script_dir = (script:match("^(.*)/[^/]*$") or ".")
local template_dir = script_dir .. "/btree_templates"

add_lustache_paths(script_dir)
local lustache = require("lustache")

local behaviorDir = dst .. "/App/" .. book .. "/behaviorTree"
local actionsDir = behaviorDir .. "/actions"
local conditionsDir = behaviorDir .. "/conditions"
local viewsDir = behaviorDir .. "/views"

mkdir_p(actionsDir)
mkdir_p(conditionsDir)
mkdir_p(viewsDir)

-- Determine tree file and scene name
local treeFile
if sceneOrTree:match("%.tree$") then
    if sceneOrTree:match("/") then
        treeFile = sceneOrTree
    else
        treeFile = behaviorDir .. "/" .. sceneOrTree
    end

    if not read_file(treeFile) then
        print("Warning: tree file not found, creating: " .. treeFile)
        mkdir_p(dirname(treeFile))
        local tmpl = read_file(template_dir .. "/tree_scene.tree")
        if not tmpl then
            error("Missing template: tree_scene.tree")
        end
        local content = lustache:render(tmpl, { SCENE = "temp" })
        write_file(treeFile, content)
    end
else
    local sceneName = sceneOrTree
    treeFile = behaviorDir .. "/" .. sceneName .. "_scene.tree"
    if not read_file(treeFile) then
        print("Creating empty tree: " .. treeFile)
        mkdir_p(dirname(treeFile))
        local tmpl = read_file(template_dir .. "/tree_scene.tree")
        if not tmpl then
            error("Missing template: tree_scene.tree")
        end
        local content = lustache:render(tmpl, { SCENE = sceneName })
        write_file(treeFile, content)
    end
end

-- Normalize scene name from tree file
local sceneBase = basename(treeFile):gsub("%.tree$", ""):gsub("_scene$", "")
if sceneBase == "" then
    error("Error: Could not determine scene name from tree file: " .. treeFile)
end

local sceneTitle = sceneBase
local treeFileName = basename(treeFile)

local treeContent = read_file(treeFile)
if not treeContent then
    error("Error: tree file not readable: " .. treeFile)
end

-- Parse actions and conditions from tree file
local actionsRaw = {}
for token in treeContent:gmatch("%b[]") do
    local action = trim(token:sub(2, -2))
    if action ~= "" then
        table.insert(actionsRaw, action)
    end
end

local conditionsRaw = {}
for token in treeContent:gmatch("%b()") do
    local condition = trim(token:sub(2, -2))
    if condition ~= "" then
        table.insert(conditionsRaw, condition)
    end
end

local actionsList = unique_list(actionsRaw)
local conditionsList = unique_list(conditionsRaw)

-- Build action routing and action table
local simpleRouting = ""
local actionsTable = ""
local actionsFunctions = ""

local actionFunctionTemplate = read_file(template_dir .. "/action_function.lua")
if not actionFunctionTemplate then
    error("Missing template: action_function.lua")
end

local simpleRoutingTemplate = read_file(template_dir .. "/simple_routing.lua")
if not simpleRoutingTemplate then
    error("Missing template: simple_routing.lua")
end

local actionTableTemplate = read_file(template_dir .. "/action_table.lua")
if not actionTableTemplate then
    error("Missing template: action_table.lua")
end

local actionTypesSet = {}
local actionRoutes = {}
local actionEntries = {}

for _, action in ipairs(actionsList) do
    local actionType, actionWhat
    if action:find(" ") then
        actionType = action:match("^(%S+)")
        actionWhat = trim(action:sub(#actionType + 1))
    else
        actionType = action
        actionWhat = action
    end

    if actionType and actionType ~= "" then
        if not actionTypesSet[actionType] then
            actionTypesSet[actionType] = true
            if actionType == "goto" or actionType == "scene" then
                table.insert(actionRoutes, { type = actionType, module = "scene" })
            else
                table.insert(actionRoutes, { type = actionType, module = sceneBase })
            end
        end

        if actionType ~= "goto" then
            local actionKey = actionWhat
            local funcName = "action_" .. actionKey:gsub("[^%w]+", "_")
            table.insert(actionEntries, { name = actionKey, func = funcName })
            actionsFunctions = actionsFunctions .. lustache:render(actionFunctionTemplate, {
                ACTION_FUNC = funcName,
                ACTION_NAME = actionKey,
            })
        end
    end
end

simpleRouting = lustache:render(simpleRoutingTemplate, { routes = actionRoutes })
actionsTable = lustache:render(actionTableTemplate, { actions = actionEntries })

-- Build condition table and functions
local conditionsTable = ""
local conditionsFunctions = ""
local conditionList = ""

local conditionFunctionTemplate = read_file(template_dir .. "/condition_function.lua")
if not conditionFunctionTemplate then
    error("Missing template: condition_function.lua")
end

local conditionTableTemplate = read_file(template_dir .. "/condition_table.lua")
if not conditionTableTemplate then
    error("Missing template: condition_table.lua")
end

local conditionEntries = {}

for _, condition in ipairs(conditionsList) do
    local funcName = "condition_" .. condition:gsub("[^%w]+", "_")
    table.insert(conditionEntries, { name = condition, func = funcName })
    conditionsFunctions = conditionsFunctions .. lustache:render(conditionFunctionTemplate, {
        CONDITION_FUNC = funcName,
        CONDITION_NAME = condition,
    })
    conditionList = conditionList .. "    \"" .. condition .. "\",\n"
end

conditionsTable = lustache:render(conditionTableTemplate, { conditions = conditionEntries })

if conditionList == "" then
    conditionList = "    -- no conditions\n"
end

-- Create scene-specific directories
mkdir_p(actionsDir .. "/" .. sceneBase)
mkdir_p(conditionsDir .. "/" .. sceneBase)
mkdir_p(viewsDir .. "/" .. sceneBase)

-- Ensure generic scene actions exist
if not read_file(actionsDir .. "/scene_actions.lua") then
    local tmpl = read_file(template_dir .. "/scene_actions.lua")
    if not tmpl then
        error("Missing template: scene_actions.lua")
    end
    local content = lustache:render(tmpl, { SCENE = sceneBase, BOOK = book })
    write_file(actionsDir .. "/scene_actions.lua", content)
    print("Created: " .. actionsDir .. "/scene_actions.lua")
end

-- Ensure base scene action exists
if not read_file(actionsDir .. "/base_scene_action.lua") then
    local tmpl = read_file(template_dir .. "/base_scene_action.lua")
    if not tmpl then
        error("Missing template: base_scene_action.lua")
    end
    write_file(actionsDir .. "/base_scene_action.lua", tmpl)
    print("Created: " .. actionsDir .. "/base_scene_action.lua")
end

-- Render templates
local replacements = {
    SCENE = sceneBase,
    SCENE_TITLE = sceneTitle,
    BOOK = book,
    TREE_FILE = treeFileName,
    ACTIONS_TABLE = actionsTable,
    ACTIONS_FUNCTIONS = actionsFunctions,
    CONDITIONS_TABLE = conditionsTable,
    CONDITIONS_FUNCTIONS = conditionsFunctions,
    CONDITION_LIST = conditionList,
    MODULE_PATHS = "    scene = \"actions.scene_actions\",\n    " .. sceneBase .. " = \"actions." .. sceneBase .. "." .. sceneBase .. "_actions\",\n",
    SIMPLE_ROUTING = simpleRouting,
    COND_MODULE_PATHS = "    " .. sceneBase .. " = \"conditions." .. sceneBase .. "." .. sceneBase .. "_conditions\",\n",
}

local function render_template(src, dst)
    local tmpl = read_file(src)
    if not tmpl then
        error("Missing template: " .. src)
    end
    local content = lustache:render(tmpl, replacements)
    write_file(dst, content)
end

render_template(template_dir .. "/action_module.lua", actionsDir .. "/" .. sceneBase .. "/" .. sceneBase .. "_actions.lua")
render_template(template_dir .. "/action_controller.lua", actionsDir .. "/" .. sceneBase .. "/" .. sceneBase .. "_controller.lua")
render_template(template_dir .. "/condition_module.lua", conditionsDir .. "/" .. sceneBase .. "/" .. sceneBase .. "_conditions.lua")
render_template(template_dir .. "/condition_controller.lua", conditionsDir .. "/" .. sceneBase .. "/" .. sceneBase .. "_condition_controller.lua")
render_template(template_dir .. "/view_scene.lua", viewsDir .. "/" .. sceneBase .. "/" .. sceneBase .. "Scene.lua")

print("Scaffold complete: " .. behaviorDir)
