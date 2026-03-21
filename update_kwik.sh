#!/bin/bash

# Script to download and install plugin-kwik.tgz and extract lua_modules from the latest release Source code (tar.gz)

# Variables
REPO="kwiksher/kwik5-project-template"
SOLAR2D_DIR="./Solar2D"
LUA_MODULES_TARGET="$SOLAR2D_DIR/lua_modules"
PLUGIN_DIR="$SOLAR2D_DIR/lua_modules/kwiksher"
SKINS_DIR="$HOME/Library/Application Support/Corona/Simulator/Skins"
TEMP_PLUGIN_FILE="/tmp/plugin-kwik.tgz"
TEMP_SRC_FILE="/tmp/kwik5-project-template-src.tgz"
EXTRACT_DIR="/tmp/kwik5-project-template-src"

# Create the plugin directory if it doesn't exist
mkdir -p "$PLUGIN_DIR"

# Create the skins directory if it doesn't exist
mkdir -p "$SKINS_DIR"

# Fetch the latest release information
echo "Fetching information about the latest release..."
echo "https://api.github.com/repos/$REPO/releases/latest"
RELEASE_INFO=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
if [ $? -ne 0 ]; then
    echo "Failed to connect to GitHub API. Please check your internet connection."
    exit 1
fi

# Extract the download URL for plugin-kwik.tgz
PLUGIN_URL=$(echo "$RELEASE_INFO" | grep -o '"browser_download_url": ".*plugin-kwik.tgz"' | cut -d'"' -f4)

# Extract the download URL for Source code (tar.gz)
SRC_URL=$(echo "$RELEASE_INFO" | grep -o '"tarball_url": "[^"]*' | cut -d'"' -f4)

# Download the plugin-kwik.tgz file
echo "Downloading plugin from $PLUGIN_URL..."
if curl -L -o "$TEMP_PLUGIN_FILE" "$PLUGIN_URL"; then
    echo "Download complete."
else
    echo "Failed to download the plugin. Please check your internet connection."
    exit 1
fi

# Remove old plugin files before extraction
echo "Removing old plugin files..."
rm -f "$PLUGIN_DIR/kwik.lua"
rm -rf "$PLUGIN_DIR/kwik"
echo "Old files removed."

# Extract the plugin-kwik.tgz file
echo "Installing plugin to $PLUGIN_DIR..."
if tar -xzf "$TEMP_PLUGIN_FILE" -C "$PLUGIN_DIR"; then
    echo "Plugin installed successfully!"
else
    echo "Failed to extract the plugin. The file may be corrupted."
    exit 1
fi

# Download the Source code (tar.gz) file
echo "Downloading source code from $SRC_URL..."
if curl -L -o "$TEMP_SRC_FILE" "$SRC_URL"; then
    echo "Source code download complete."
else
    echo "Failed to download the source code. Please check your internet connection."
    exit 1
fi

# Remove old extracted files and target lua_modules
echo "Cleaning up old files for lua_modules..."
rm -rf "$EXTRACT_DIR"
# Only remove contents of lua_modules except for kwiksher
if [ -d "$LUA_MODULES_TARGET" ]; then
  find "$LUA_MODULES_TARGET" -mindepth 1 -maxdepth 1 ! -name 'kwiksher' -exec rm -rf {} +
fi

# Extract the tarball
echo "Extracting source code..."
mkdir -p "$EXTRACT_DIR"
tar -xzf "$TEMP_SRC_FILE" -C "$EXTRACT_DIR"

# Find the extracted folder (it will be named kwiksher-kwik5-project-template-*)
EXTRACTED_SUBDIR=$(find "$EXTRACT_DIR" -maxdepth 1 -type d -name 'kwiksher-kwik5-project-template-*' | head -n 1)

# --- START DEBUG BLOCK ---
echo "--- DEBUG INFO ---"
echo "EXTRACT_DIR is: $EXTRACT_DIR"
echo "EXTRACTED_SUBDIR is: $EXTRACTED_SUBDIR"
echo "Listing contents of EXTRACT_DIR:"
ls -l "$EXTRACT_DIR"
if [ -n "$EXTRACTED_SUBDIR" ]; then
    echo "Listing contents of EXTRACTED_SUBDIR:"
    ls -lR "$EXTRACTED_SUBDIR"
fi
echo "--- END DEBUG INFO ---"

if [ -z "$EXTRACTED_SUBDIR" ]; then
    echo "Failed to find extracted source directory."
    exit 1
fi

# Copy Simulator skin files from the extracted source tree instead of embedding
# their contents directly in this installer.
SOURCE_SKINS_DIR="$EXTRACTED_SUBDIR/Scripts"
if [ ! -d "$SOURCE_SKINS_DIR" ]; then
  echo "Scripts directory not found in extracted source tree. Aborting."
  exit 1
fi

install_skin_file() {
  local source_file="$1"
  local destination_file="$2"

  if [ ! -f "$SOURCE_SKINS_DIR/$source_file" ]; then
    echo "Missing skin template: $SOURCE_SKINS_DIR/$source_file"
    exit 1
  fi

  cp "$SOURCE_SKINS_DIR/$source_file" "$SKINS_DIR/$destination_file"
  echo "Installed $destination_file from $source_file"
}

# Copy lua_modules to the target location
echo "Copying lua_modules to $LUA_MODULES_TARGET..."
if [ -d "$EXTRACTED_SUBDIR/Solar2D/lua_modules" ]; then
  cp -R "$EXTRACTED_SUBDIR/Solar2D/lua_modules" "$SOLAR2D_DIR"
else
  echo "lua_modules not found in source tarball, copying from ../kwik5-project-template/Solar2D..."
  if [ -d "../kwik5-project-template/Solar2D/lua_modules" ]; then
    cp -R ../kwik5-project-template/Solar2D/lua_modules "$SOLAR2D_DIR"
    echo "Copied lua_modules from local ../kwik5-project-template/Solar2D."
  else
    echo "lua_modules not found in ../kwik5-project-template/Solar2D. Aborting."
    exit 1
  fi
fi

echo "Installing Simulator skin files from source templates..."
install_skin_file "kwikEditorLandscape_mac.lua" "kwikEditorLandscape.lua"
install_skin_file "kwikEditorLandscape2x_mac.lua" "kwikEditorLandscape2x.lua"
install_skin_file "kwikEditorPortrait_mac.lua" "kwikEditorPortrait.lua"
install_skin_file "kwikEditorPortrait2x_mac.lua" "kwikEditorPortrait2x.lua"
echo "Simulator skin files installed."

# Clean up
echo "Cleaning up temp files..."
rm -rf "$TEMP_PLUGIN_FILE" "$TEMP_SRC_FILE" "$EXTRACT_DIR"

# Final message
RELEASE_TAG=$(echo "$RELEASE_INFO" | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)
echo "Installation complete. Plugin version: $RELEASE_TAG"
echo "You can now use the plugin in the Solar2D Simulator."
echo "Kwik Editor Landscape, Landscape 2x, Portrait, and Portrait 2x skins are available in the Simulator."