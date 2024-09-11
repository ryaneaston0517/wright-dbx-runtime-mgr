#!/bin/zsh

echo "📂 Starting Python download..."
BASE_URL="https://www.python.org/ftp/python"

# Use the passed-in Python version or fall back to a default
VERSION="${1:-3.11.0}"

# Use the passed-in download location or fall back to a default location
DRAWER_DIR="$HOME/.wright_workbench/drawer/python"
DOWNLOAD_LOCATION="${2:-$DRAWER_DIR}"

echo "🌐 Fetching Python version $VERSION from Python.org..."
echo "🔧 Download location: $DOWNLOAD_LOCATION"

OUTPUT_FILE="$DOWNLOAD_LOCATION/python-$VERSION.tar.gz"
echo "📦 Output location: $OUTPUT_FILE"

# Ensure the directory exists
mkdir -p "$DOWNLOAD_LOCATION"

FINAL_URL="$BASE_URL/$VERSION/Python-$VERSION.tgz"
echo "🔗 Download URL: $FINAL_URL"
echo "🔄 Downloading Python version: $VERSION"

curl -o "$OUTPUT_FILE" "$FINAL_URL"

# Verify if the download was successful
if [ $? -eq 0 ]; then
    echo "✅ Download complete: $OUTPUT_FILE"
else
    echo "❌ Download failed!"
fi
