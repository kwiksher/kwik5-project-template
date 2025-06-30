#!/bin/bash

# Makeself script to download and install a Solar2D plugin from latest GitHub release

# Variables
REPO="kwiksher/kwik5-project-template"
PLUGIN_DIR="./Solar2D/lua_modules/kwiksher"
SKINS_DIR="$HOME/Library/Application Support/Corona/Simulator/Skins"
TEMP_FILE="/tmp/plugin-kwik.tgz"

# Create the plugin directory if it doesn't exist
mkdir -p "$PLUGIN_DIR"

# Create the skins directory if it doesn't exist
mkdir -p "$SKINS_DIR"

# Fetch the latest release information
echo "Fetching information about the latest release..."
RELEASE_INFO=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
if [ $? -ne 0 ]; then
    echo "Failed to connect to GitHub API. Please check your internet connection."
    exit 1
fi

# Extract the download URL for plugin-kwik.tgz
DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep -o '"browser_download_url": ".*plugin-kwik.tgz"' | cut -d'"' -f4)

# Check if we found a download URL
if [ -z "$DOWNLOAD_URL" ]; then
    echo "Could not find plugin-kwik.tgz in the latest release."
    echo "Please check if the file exists in the latest release of $REPO."
    exit 1
fi

# Download the plugin-kwik.tgz file
echo "Downloading plugin from $DOWNLOAD_URL..."
if curl -L -o "$TEMP_FILE" "$DOWNLOAD_URL"; then
    echo "Download complete."
else
    echo "Failed to download the plugin. Please check your internet connection."
    exit 1
fi

# Remove old files before extraction
echo "Removing old plugin files..."
rm -f "$PLUGIN_DIR/kwik.lua"
rm -rf "$PLUGIN_DIR/kwik"
echo "Old files removed."

# Extract the plugin-kwik.tgz file
echo "Installing plugin to $PLUGIN_DIR..."
if tar -xzf "$TEMP_FILE" -C "$PLUGIN_DIR"; then
    echo "Plugin installed successfully!"
else
    echo "Failed to extract the plugin. The file may be corrupted."
    exit 1
fi

# Create the kwikEditorLandscape.lua skin file
echo "Creating Kwik Editor Landscape skin file..."
cat > "$SKINS_DIR/kwikEditorLandscape.lua" << 'EOF'
simulator =
{
  device = "desktop-1920x1080",
  screenOriginX = 0,
  screenOriginY = 0,
  screenWidth = 590,
  screenHeight = 960,
	iosPointWidth = 590,
	iosPointHeight = 960,
  deviceImage = nil,
  displayManufacturer = "Kwiksher",
  displayName = "Kwik Landscape",
  windowTitleBarName = "Kwik Editor Landscape"
}
EOF
echo "Kwik Editor Landscape skin file created."

# Clean up
rm "$TEMP_FILE"

# Final message
RELEASE_TAG=$(echo "$RELEASE_INFO" | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)
echo "Installation complete. Plugin version: $RELEASE_TAG"
echo "You can now use the plugin in the Solar2D Simulator."
echo "Kwik Editor Landscape skin is available in the Simulator."