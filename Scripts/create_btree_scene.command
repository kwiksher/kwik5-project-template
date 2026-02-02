#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/btree_templates"

usage() {
    echo "Usage: $0 [dst] [book] [scene|treeFile]"
    echo "  dst: e.g. Solar2D"
    echo "  book: e.g. BTree_test"
    echo "  scene|treeFile: scene name (e.g. narration) or .tree file (e.g. narration_scene.tree)"
}

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Missing required arguments."
    usage
    exit 1
fi

if [ -z "$3" ]; then
    echo "Error: No scene or tree file provided."
    usage
    exit 1
fi

dst="$1"
book="$2"
sceneOrTree="$3"

behaviorDir="$dst/App/$book/behaviorTree"
actionsDir="$behaviorDir/actions"
conditionsDir="$behaviorDir/conditions"
viewsDir="$behaviorDir/views"

mkdir -p "$actionsDir" "$conditionsDir" "$viewsDir"

# Determine tree file and scene name
if [[ "$sceneOrTree" == *.tree ]]; then
    if [[ "$sceneOrTree" == */* ]]; then
        treeFile="$sceneOrTree"
    else
        treeFile="$behaviorDir/$sceneOrTree"
    fi

    if [ ! -f "$treeFile" ]; then
        echo "Warning: tree file not found, creating: $treeFile"
        mkdir -p "$(dirname "$treeFile")"
        export BTREE_SCENE="temp"
        python3 - "$TEMPLATE_DIR/tree_scene.tree" "$treeFile" <<'PY'
import os, sys
src, dst = sys.argv[1], sys.argv[2]
with open(src, 'r') as f:
    content = f.read()
content = content.replace("{{SCENE}}", os.environ.get("BTREE_SCENE", "scene"))
with open(dst, 'w') as f:
    f.write(content)
PY
    fi
else
    sceneName="$sceneOrTree"
    treeFile="$behaviorDir/${sceneName}_scene.tree"
    if [ ! -f "$treeFile" ]; then
        echo "Creating empty tree: $treeFile"
        mkdir -p "$(dirname "$treeFile")"
        export BTREE_SCENE="$sceneName"
        python3 - "$TEMPLATE_DIR/tree_scene.tree" "$treeFile" <<'PY'
import os, sys
src, dst = sys.argv[1], sys.argv[2]
with open(src, 'r') as f:
    content = f.read()
content = content.replace("{{SCENE}}", os.environ.get("BTREE_SCENE", "scene"))
with open(dst, 'w') as f:
    f.write(content)
PY
    fi
fi

# Normalize scene name from tree file
sceneBase="$(basename "$treeFile" .tree)"
sceneBase="${sceneBase%_scene}"

if [ -z "$sceneBase" ]; then
    echo "Error: Could not determine scene name from tree file: $treeFile"
    exit 1
fi

sceneTitle="$sceneBase"

treeFileName="$(basename "$treeFile")"

# Parse actions and conditions from tree file
actionsRaw=$(grep -oE '\[[^]]+\]' "$treeFile" | sed -E 's/^\[//; s/\]$//' | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')
conditionsRaw=$(grep -oE '\([^)]*\)' "$treeFile" | sed -E 's/^\(//; s/\)$//' | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')

actionsList=$(printf "%s\n" "$actionsRaw" | awk 'NF && !seen[$0]++')
conditionsList=$(printf "%s\n" "$conditionsRaw" | awk 'NF && !seen[$0]++')

# Build action routing and action table
simpleRouting=""
actionsTable=""
actionsFunctions=""

simpleRoutingTemplate="$TEMPLATE_DIR/simple_routing.lua"
actionTableTemplate="$TEMPLATE_DIR/action_table.lua"
conditionTableTemplate="$TEMPLATE_DIR/condition_table.lua"
simpleRoutingRoutes=""
actionEntries=""

# Track action types to avoid duplicates
actionTypesSet="|"

while IFS= read -r action; do
    if [[ "$action" == *" "* ]]; then
        actionType="${action%% *}"
        actionWhat="${action#* }"
    else
        actionType="$action"
        actionWhat="$action"
    fi

    if [ -z "$actionType" ]; then
        continue
    fi

    if [[ "$actionTypesSet" != *"|$actionType|"* ]]; then
        actionTypesSet+="$actionType|"

        if [ "$actionType" = "goto" ] || [ "$actionType" = "scene" ]; then
            simpleRoutingRoutes+="$actionType=scene"$'\n'
        else
            simpleRoutingRoutes+="$actionType=$sceneBase"$'\n'
        fi
    fi

    if [ "$actionType" != "goto" ]; then
        actionKey="$actionWhat"
        funcName="action_$(echo "$actionKey" | sed -E 's/[^a-zA-Z0-9]+/_/g')"
        actionEntries+="$actionKey|$funcName"$'\n'
        actionsFunctions+="function M.$funcName()"$'\n'
        actionsFunctions+="    print(\"[ACTION] $actionKey\")"$'\n'
        actionsFunctions+="    return bt.SUCCESS"$'\n'
        actionsFunctions+="end"$'\n\n'
    fi

done <<< "$actionsList"

simpleRouting=$(lua - <<'LUA'
local templatePath = os.getenv("BTREE_SIMPLE_ROUTING_TEMPLATE")
local routesRaw = os.getenv("BTREE_SIMPLE_ROUTING_ROUTES") or ""
local scriptDir = os.getenv("BTREE_SCRIPT_DIR")

package.path = package.path .. ";" .. scriptDir .. "/btree_templates/?.lua;" .. scriptDir .. "/btree_templates/?/?.lua"
local lustache = require("lustache")

local f = assert(io.open(templatePath, "r"))
local template = f:read("*a")
f:close()

local routes = {}
for line in routesRaw:gmatch("[^\n]+") do
    local t, m = line:match("^(.-)=(.+)$")
    if t and m then
        table.insert(routes, { type = t, module = m })
    end
end

local output = lustache:render(template, { routes = routes })
print(output)
LUA
)

# Build condition table and functions
conditionsTable=""
conditionsFunctions=""
conditionList=""
conditionEntries=""

while IFS= read -r condition; do
    if [ -z "$condition" ]; then
        continue
    fi

    funcName="condition_$(echo "$condition" | sed -E 's/[^a-zA-Z0-9]+/_/g')"
    conditionEntries+="$condition|$funcName"$'\n'
    conditionsFunctions+="function M.$funcName()"$'\n'
    conditionsFunctions+="    local result = false"$'\n'
    conditionsFunctions+="    print(\"[CONDITION] $condition: \" .. tostring(result))"$'\n'
    actionsTable=$(lua - <<'LUA'
    local templatePath = os.getenv("BTREE_ACTION_TABLE_TEMPLATE")
    local entriesRaw = os.getenv("BTREE_ACTION_ENTRIES") or ""
    local scriptDir = os.getenv("BTREE_SCRIPT_DIR")

    package.path = package.path .. ";" .. scriptDir .. "/btree_templates/?.lua;" .. scriptDir .. "/btree_templates/?/?.lua"
    local lustache = require("lustache")

    local f = assert(io.open(templatePath, "r"))
    local template = f:read("*a")
    f:close()

    local entries = {}
    for line in entriesRaw:gmatch("[^\n]+") do
        local name, func = line:match("^(.-)%|(.-)$")
        if name and func then
            table.insert(entries, { name = name, func = func })
        end
    end

    local output = lustache:render(template, { actions = entries })
    print(output)
    LUA
    )

    conditionsTable=$(lua - <<'LUA'
    local templatePath = os.getenv("BTREE_CONDITION_TABLE_TEMPLATE")
    local entriesRaw = os.getenv("BTREE_CONDITION_ENTRIES") or ""
    local scriptDir = os.getenv("BTREE_SCRIPT_DIR")

    package.path = package.path .. ";" .. scriptDir .. "/btree_templates/?.lua;" .. scriptDir .. "/btree_templates/?/?.lua"
    local lustache = require("lustache")

    local f = assert(io.open(templatePath, "r"))
    local template = f:read("*a")
    f:close()

    local entries = {}
    for line in entriesRaw:gmatch("[^\n]+") do
        local name, func = line:match("^(.-)%|(.-)$")
        if name and func then
            table.insert(entries, { name = name, func = func })
        end
    end

    local output = lustache:render(template, { conditions = entries })
    print(output)
    LUA
    )
    conditionsFunctions+="    return result and bt.SUCCESS or bt.FAILED"$'\n'
    conditionsFunctions+="end"$'\n\n'
    conditionList+="    \"$condition\","$'\n'

done <<< "$conditionsList"

if [ -z "$conditionList" ]; then
    conditionList="    -- no conditions"$'\n'
fi

# Create scene-specific directories
mkdir -p "$actionsDir/$sceneBase" "$conditionsDir/$sceneBase" "$viewsDir/$sceneBase"

# Ensure generic scene actions exist
if [ ! -f "$actionsDir/scene_actions.lua" ]; then
    export BTREE_SCENE="$sceneBase"
    export BTREE_BOOK="$book"
    python3 - "$TEMPLATE_DIR/scene_actions.lua" "$actionsDir/scene_actions.lua" <<'PY'
import os, sys
src, dst = sys.argv[1], sys.argv[2]
with open(src, 'r') as f:
    content = f.read()
content = content.replace("{{SCENE}}", os.environ.get("BTREE_SCENE", "scene"))
content = content.replace("{{BOOK}}", os.environ.get("BTREE_BOOK", "Book"))
with open(dst, 'w') as f:
    f.write(content)
PY
    echo "Created: $actionsDir/scene_actions.lua"
fi

# Ensure base scene action exists
if [ ! -f "$actionsDir/base_scene_action.lua" ]; then
    python3 - "$TEMPLATE_DIR/base_scene_action.lua" "$actionsDir/base_scene_action.lua" <<'PY'
import sys
src, dst = sys.argv[1], sys.argv[2]
with open(src, 'r') as f:
    content = f.read()
with open(dst, 'w') as f:
    f.write(content)
PY
    echo "Created: $actionsDir/base_scene_action.lua"
fi

# Render templates
export BTREE_SCENE="$sceneBase"
export BTREE_SCENE_TITLE="$sceneTitle"
export BTREE_BOOK="$book"
export BTREE_TREE_FILE="$treeFileName"
export BTREE_ACTIONS_TABLE="$actionsTable"
export BTREE_ACTIONS_FUNCTIONS="$actionsFunctions"
export BTREE_CONDITIONS_TABLE="$conditionsTable"
export BTREE_CONDITIONS_FUNCTIONS="$conditionsFunctions"
export BTREE_CONDITION_LIST="$conditionList"

modulePaths=""
modulePaths+="    scene = \"actions.scene_actions\","$'\n'
modulePaths+="    $sceneBase = \"actions.$sceneBase.${sceneBase}_actions\","$'\n'
condModulePaths=""
condModulePaths+="    $sceneBase = \"conditions.$sceneBase.${sceneBase}_conditions\","$'\n'

export BTREE_MODULE_PATHS="$modulePaths"
export BTREE_COND_MODULE_PATHS="$condModulePaths"
export BTREE_SCRIPT_DIR="$SCRIPT_DIR"
export BTREE_SIMPLE_ROUTING_TEMPLATE="$simpleRoutingTemplate"
export BTREE_SIMPLE_ROUTING_ROUTES="$simpleRoutingRoutes"
export BTREE_ACTION_TABLE_TEMPLATE="$actionTableTemplate"
export BTREE_CONDITION_TABLE_TEMPLATE="$conditionTableTemplate"
export BTREE_ACTION_ENTRIES="$actionEntries"
export BTREE_CONDITION_ENTRIES="$conditionEntries"
export BTREE_SIMPLE_ROUTING="$simpleRouting"

render_template() {
    local src="$1"
    local dst="$2"

    python3 - "$src" "$dst" <<'PY'
import os, sys
src, dst = sys.argv[1], sys.argv[2]
with open(src, 'r') as f:
    content = f.read()
replacements = {
    "SCENE": os.environ.get("BTREE_SCENE", "scene"),
    "SCENE_TITLE": os.environ.get("BTREE_SCENE_TITLE", "Scene"),
    "BOOK": os.environ.get("BTREE_BOOK", "Book"),
    "TREE_FILE": os.environ.get("BTREE_TREE_FILE", "scene.tree"),
    "ACTIONS_TABLE": os.environ.get("BTREE_ACTIONS_TABLE", ""),
    "ACTIONS_FUNCTIONS": os.environ.get("BTREE_ACTIONS_FUNCTIONS", ""),
    "CONDITIONS_TABLE": os.environ.get("BTREE_CONDITIONS_TABLE", ""),
    "CONDITIONS_FUNCTIONS": os.environ.get("BTREE_CONDITIONS_FUNCTIONS", ""),
    "CONDITION_LIST": os.environ.get("BTREE_CONDITION_LIST", ""),
    "MODULE_PATHS": os.environ.get("BTREE_MODULE_PATHS", ""),
    "SIMPLE_ROUTING": os.environ.get("BTREE_SIMPLE_ROUTING", ""),
    "COND_MODULE_PATHS": os.environ.get("BTREE_COND_MODULE_PATHS", ""),
}
for key, value in replacements.items():
    content = content.replace("{{" + key + "}}", value)
with open(dst, 'w') as f:
    f.write(content)
PY
}

render_template "$TEMPLATE_DIR/action_module.lua" "$actionsDir/$sceneBase/${sceneBase}_actions.lua"
render_template "$TEMPLATE_DIR/action_controller.lua" "$actionsDir/$sceneBase/${sceneBase}_controller.lua"
render_template "$TEMPLATE_DIR/condition_module.lua" "$conditionsDir/$sceneBase/${sceneBase}_conditions.lua"
render_template "$TEMPLATE_DIR/condition_controller.lua" "$conditionsDir/$sceneBase/${sceneBase}_condition_controller.lua"
render_template "$TEMPLATE_DIR/view_scene.lua" "$viewsDir/$sceneBase/${sceneBase}Scene.lua"

echo "Scaffold complete: $behaviorDir"
