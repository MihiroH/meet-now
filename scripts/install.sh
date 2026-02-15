#!/bin/bash

# Simple script to install MeetNow binary into /Applications as a proper App Bundle

if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/MeetNow"
    exit 1
fi

BINARY_PATH="$1"
APP_PATH="/Applications/MeetNow.app"

echo "🚀 Installing MeetNow to /Applications..."

# Create structure
mkdir -p "$APP_PATH/Contents/MacOS"

# Move binary
cp "$BINARY_PATH" "$APP_PATH/Contents/MacOS/MeetNow"
chmod +x "$APP_PATH/Contents/MacOS/MeetNow"

# Copy Info.plist
cp "$(dirname "$0")/../MeetNow/Info.plist" "$APP_PATH/Contents/Info.plist"

# Copy Icon
mkdir -p "$APP_PATH/Contents/Resources"
cp "$(dirname "$0")/../MeetNow/AppIcon.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"

echo "✅ Installed successfully! You can now run 'open -a MeetNow'."
echo "💡 Note: If macOS blocks the first run, right-click $APP_PATH and select 'Open'."
