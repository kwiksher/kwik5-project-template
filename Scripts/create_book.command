#!/bin/bash

SCRIPT_DIR="$(cd $(dirname $0); pwd)"

# Check if the required arguments are provided
if [ -z "$1" ]; then
    echo "Error: No destination provided."
    echo "Usage: $0 [dst] [book] [pages]"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Error: No book name provided."
    echo "Usage: $0 [dst] [book] [pages]"
    exit 1
fi

# Set variables from arguments
dst=$1
book=$2
pages=$3

# Set default pages if none are provided
if [ -z "$pages" ]; then
    pages="page1"
fi

tmp=""

mkdir -p $dst/App/$book
cd $dst/App/$book

# Process each page
for page in $pages; do
    tmp+="'${page}', "
    echo $page
    mkdir -p assets/images/$page
    mkdir -p commands/$page
    mkdir -p components/$page
    mkdir -p components/$page/audios
    mkdir -p components/$page/audios/long
    mkdir -p components/$page/audios/short
    mkdir -p components/$page/audios/sync
    mkdir -p components/$page/groups
    mkdir -p components/$page/layers
    mkdir -p components/$page/page
    mkdir -p components/$page/timers
    mkdir -p components/$page/variables
    mkdir -p components/$page/joints
    mkdir -p models/$page

    cp $SCRIPT_DIR/background.lua components/$page/layers/background.lua

    cat << EOF > $page.lua
local sceneName = ...
--
local scene = require('controller.scene').new(sceneName, {
    components = {
      layers = { { background={} } },
      audios = { },
      groups = { },
      timers = { },
      variables = { },
      page = { }
    },
    commands = { },
    onInit = function(scene) print("onInit") end
})
--
return scene
EOF
done

echo $tmp

pwd

cat << EOF > index.lua
local scenes = {
$tmp
}
return scenes
EOF

cd assets
cat << EOF > model.lua
local M = {
  audios = {}, sprites = {}, videos = {}
}
return M
EOF

# Exit successfully
exit 0