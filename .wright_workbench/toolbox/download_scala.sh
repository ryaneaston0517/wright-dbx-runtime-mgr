#!/bin/zsh

echo "📂 Starting Scala download..."
BASE_URL="https://downloads.lightbend.com/scala"

# Use the passed-in Python version or fall back to a default
VERSION="${1:-2.12.18}"

# Use the passed-in download location or fall back to a default location
DRAWER_DIR="$HOME/.wright_workbench/drawer/scala"
DOWNLOAD_LOCATION="${2:-$DRAWER_DIR}"

echo "🌐 Fetching Scala version $VERSION from lightbend.com..."
echo "🔧 Download location: $DOWNLOAD_LOCATION"

OUTPUT_FILE="$DOWNLOAD_LOCATION/scala-$VERSION.tar.gz"
echo "📦 Output location: $OUTPUT_FILE"

# Ensure the directory exists
mkdir -p "$DOWNLOAD_LOCATION"

FINAL_URL="$BASE_URL/$VERSION/scala-$VERSION.tgz"
echo "🔗 Download URL: $FINAL_URL"
echo "🔄 Downloading Python version: $VERSION"

curl -o "$OUTPUT_FILE" "$FINAL_URL"

# Verify if the download was successful
if [ $? -eq 0 ]; then
    echo "✅ Download complete: $OUTPUT_FILE"
else
    echo "❌ Download failed!"
fi
