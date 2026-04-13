#!/bin/bash

TARGET_DIR="Solar2D/fonts"
mkdir -p "$TARGET_DIR"

# Roboto source
ROBOTO_BASE="https://github.com/google/fonts/raw/main/apache/roboto"

# Noto Sans JP source
NOTO_BASE="https://github.com/google/fonts/raw/main/ofl/notosansjp"

ROBOTO_FILES=(
  "Roboto-Regular.ttf"
  "Roboto-Bold.ttf"
  "Roboto-Italic.ttf"
  "Roboto-Medium.ttf"
)

NOTO_FILES=(
  "NotoSansJP-Regular.ttf"
  "NotoSansJP-Bold.ttf"
  "NotoSansJP-Medium.ttf"
)

echo "Downloading Roboto fonts..."
for FILE in "${ROBOTO_FILES[@]}"; do
  echo "Fetching $FILE..."
  curl -L "$ROBOTO_BASE/$FILE" -o "$TARGET_DIR/$FILE"
done

echo "Downloading Noto Sans JP fonts..."
for FILE in "${NOTO_FILES[@]}"; do
  echo "Fetching $FILE..."
  curl -L "$NOTO_BASE/$FILE" -o "$TARGET_DIR/$FILE"
done

echo "Done! All fonts saved to $TARGET_DIR/"
