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

# Helper: fetch latest release info
fetch_release_info() {
  echo "https://api.github.com/repos/$REPO/releases/latest"
  RELEASE_INFO=$(curl -s "https://api.github.com/repos/$REPO/releases/latest")
  if [ $? -ne 0 ] || [ -z "$RELEASE_INFO" ]; then
    echo "Failed to connect to GitHub API. Please check your internet connection."
    return 1
  fi
  return 0
}

# If called with --version, print local and latest remote versions and exit
if [ "$1" = "--version" ]; then
  # local version
  LOCAL_VERSION="not-installed"
  if [ -f "$PLUGIN_DIR/version.txt" ]; then
    LOCAL_VERSION=$(cat "$PLUGIN_DIR/version.txt" 2>/dev/null || echo "unknown")
  fi

  if fetch_release_info; then
    REMOTE_TAG=$(echo "$RELEASE_INFO" | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)
    # try to prefer an explicit version.txt asset
    REMOTE_VERSION="${REMOTE_TAG:-unknown}"
    ASSET_URL=$(echo "$RELEASE_INFO" | grep -o '"browser_download_url": "[^"]*version.txt' | cut -d'"' -f4)
    if [ -n "$ASSET_URL" ]; then
      TMPV=$(mktemp)
      if curl -sSfL -o "$TMPV" "$ASSET_URL"; then
        REMOTE_VERSION=$(cat "$TMPV" 2>/dev/null || echo "$REMOTE_VERSION")
      fi
      rm -f "$TMPV"
    fi
  else
    REMOTE_VERSION="unknown"
  fi

  echo "Local version:  $LOCAL_VERSION"
  echo "Remote version: $REMOTE_VERSION"
  exit 0
fi

# Ensure we have release info available
if ! fetch_release_info; then
  echo "Unable to retrieve release information. Aborting."
  exit 1
fi

# Extract the download URL for plugin-kwik.tgz
PLUGIN_URL=$(echo "$RELEASE_INFO" | grep -o '"browser_download_url": "[^"]*"' | cut -d'"' -f4 | grep -m1 'plugin-kwik.tgz' || true)
if [ -z "$PLUGIN_URL" ]; then
  echo "Could not find plugin-kwik.tgz in release assets. RELEASE_INFO summary:"
  echo "$RELEASE_INFO" | sed -n '1,200p'
  exit 1
fi

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

# --- New: fetch version.txt asset and compare with local version ---
TEMP_VERSION_FILE="/tmp/kwik_version.txt"
VERSION_ASSET_URL=$(echo "$RELEASE_INFO" | grep -o '"browser_download_url": "[^"]*version.txt' | cut -d'"' -f4)
if [ -n "$VERSION_ASSET_URL" ]; then
  echo "Downloading version.txt from release asset..."
  if curl -sSfL -o "$TEMP_VERSION_FILE" "$VERSION_ASSET_URL"; then
    NEW_VERSION=$(cat "$TEMP_VERSION_FILE" 2>/dev/null || echo "")
    if [ -f "$PLUGIN_DIR/version.txt" ]; then
      OLD_VERSION=$(cat "$PLUGIN_DIR/version.txt" 2>/dev/null || echo "")
    else
      OLD_VERSION="not-installed"
    fi
    echo "Old version: ${OLD_VERSION:-unknown}"
    echo "New version: ${NEW_VERSION:-unknown}"

    # copy version.txt into plugin dir
    cp "$TEMP_VERSION_FILE" "$PLUGIN_DIR/version.txt" || echo "Failed to copy version.txt to $PLUGIN_DIR"
    rm -f "$TEMP_VERSION_FILE"
  else
    echo "Failed to download version.txt from release assets. Skipping version update."
  fi
else
  echo "No version.txt asset found in release. Skipping version sync."
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


# Create the kwikEditorPortrait.lua skin file
echo "Creating Kwik Editor Portrait skin file..."
cat > "$SKINS_DIR/kwikEditorPortrait.lua" << 'EOF'
simulator =
{
	device = "desktop-1920x1080",
	screenOriginX = 0,
	screenOriginY = 0,
	screenWidth = 960,
	screenHeight = 590,
	deviceImage = nil,
	displayManufacturer = "",
	displayName = "Kwik Portrait",
	supportsScreenRotation = false,
	windowTitleBarName = "Kwik Portrait Editor"
}
EOF
echo "Kwik Editor Portrait skin file created."

# Clean up
echo "Cleaning up temp files..."
rm -rf "$TEMP_PLUGIN_FILE" "$TEMP_SRC_FILE" "$EXTRACT_DIR"

# Final message
RELEASE_TAG=$(echo "$RELEASE_INFO" | grep -o '"tag_name": "[^"]*' | cut -d'"' -f4)
echo "Installation complete. Plugin version: $RELEASE_TAG"
echo "You can now use the plugin in the Solar2D Simulator."
echo "Kwik Editor Landscape skin is available in the Simulator."