#!/bin/bash

# Default values
dst="."
book="MyBook"
pages_input="page1"
src="./template/components/pageX/layer/bg.lua"
class="button"
layer=$(basename "$src" .lua)

# Parse command-line arguments using a while loop.
while [ "$#" -gt 0 ]; do
  case $1 in
    --dst=*)
      dst="${1#*=}"
      ;;
    --book=*)
      book="${1#*=}"
      ;;
    --pages=*)
      pages_input="${1#*=}"
      ;;
    --src=*)
      src="${1#*=}"
      layer=$(basename "$src" .lua)
      ;;
    --class=*)
      class="${1#*=}"
      ;;
    *)
      ;;
  esac
  shift
done

echo "pages_input is: $pages_input"

if [ -n "$BASH_VERSION" ]; then
  echo "Running in Bash version $BASH_VERSION"
  IFS=',' read -r -a pages <<< "$pages_input"
fi
if [ -n "$ZSH_VERSION" ]; then
  echo "Running in Zsh version $ZSH_VERSION"
  pages=(${(s/,/)pages_input})
fi
# Convert pages_input (a comma-separated list) into an array.

echo "Parsed pages:"
for page in "${pages[@]}"; do
  echo "$page"
done

mkdir -p "$dst/App/$book"
#cd "$dst/App/$book" || exit
book_path=$dst/App/$book

for page in "${pages[@]}"
do
  tmp+="'${page}', "
  # echo "$page"
  mkdir -p "$book_path/assets/images/$page"
  mkdir -p "$book_path/commands/$page"
  mkdir -p "$book_path/components/$page"
  mkdir -p "$book_path/components/$page/audios"
  mkdir -p "$book_path/components/$page/audios/long"
  mkdir -p "$book_path/components/$page/audios/short"
  mkdir -p "$book_path/components/$page/audios/sync"
  mkdir -p "$book_path/components/$page/groups"
  mkdir -p "$book_path/components/$page/layers"
  mkdir -p "$book_path/components/$page/page"
  mkdir -p "$book_path/components/$page/timers"
  mkdir -p "$book_path/components/$page/variables"
  mkdir -p "$book_path/components/$page/joints"
  mkdir -p "$book_path/models/$page"

  cp "$src" "$book_path/components/$page/layers/$layer.lua"
  src_class=${src/"$layer"/"${layer}_${class}"}
  cp "$src_class" "$book_path/components/$page/layers/${layer}_${class}.lua"
  sed -i '' "s/emitter_gemini\.lua/${page}.json/g" "$book_path/components/$page/layers/${layer}_${class}.lua"

  #cd "components/$page" || exit
  cat << EOF > $book_path/components/$page/index.lua
local sceneName = ...
--
local scene = require('controller.scene').new(sceneName, {
    components = {
      layers = { { $layer = { class= { "$class" }} } },
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
##
  # cd ../..
done

echo "$tmp"

# cd "$dst/App/$book" || exit
cat << EOF > $book_path/index.lua
local scenes = {
$tmp
}
return scenes
EOF

# cd "$dst/App/$book/assets" || exit
cat << EOF > $book_path/assets/model.lua
local M = {
  audios = {}, sprites = {}, videos = {}
}
return M
EOF