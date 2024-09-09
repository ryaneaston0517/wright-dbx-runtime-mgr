#!/bin/zsh

# Define the installation directory (you can customize this)
INSTALL_DIR="$HOME/.wright_workbench/bin"
TEMP_DIR="$INSTALL_DIR/temp_yq"

# Echo the installation directory for clarity
echo "🔧 Installation directory set to: $INSTALL_DIR"

# Ensure the directory exists
echo "📁 Checking if installation directory exists..."
mkdir -p "$INSTALL_DIR"
# Ensure the temporary directory exists
mkdir -p "$TEMP_DIR"

if [ $? -eq 0 ]; then
    echo "✅ Installation directory is ready."
else
    echo "❌ Failed to create installation directory. Exiting."
    exit 1
fi

# Determine the platform and architecture
PLATFORM=$(uname -s)
ARCH=$(uname -m)

# Echo the detected platform and architecture for verification
echo "🖥️  Detected platform: $PLATFORM"
echo "🔧 Detected architecture: $ARCH"

# Translate architecture for yq naming convention
if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="amd64"
    echo "🔄 Translating architecture to: $ARCH"
elif [[ "$ARCH" == "arm64" ]]; then
    ARCH="arm64"
    echo "🔄 Translating architecture to: $ARCH"
else
    echo "❌ Unsupported architecture: $ARCH. Exiting."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ 'jq is not installed. This script requires 'jq' to parse JSON files."
else
    echo "✅ 'jq' is already installed."
fi

# Set the download URL for the latest version of yq from GitHub releases
echo "🌐 Fetching the latest version of yq from GitHub..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.tag_name')

# Verify if the version was fetched correctly
if [ -z "$LATEST_VERSION" ]; then
    echo "❌ Failed to fetch the latest version. Exiting."
    exit 1
fi

echo "🔄 Latest yq version: $LATEST_VERSION"

# Set the correct yq binary tarball based on platform
if [[ "$PLATFORM" == "Darwin" ]]; then
    YQ_TARBALL="yq_darwin_${ARCH}.tar.gz"
    echo "🖥️  Platform is Darwin. Setting YQ_TARBALL to $YQ_TARBALL"
elif [[ "$PLATFORM" == "Linux" ]]; then
    YQ_TARBALL="yq_linux_${ARCH}.tar.gz"
    echo "🖥️  Platform is Linux. Setting YQ_TARBALL to $YQ_TARBALL"
else
    echo "❌ Unsupported platform: $PLATFORM. Exiting."
    exit 1
fi

# Correct download URL for yq tarball from the latest release
YQ_URL="https://github.com/mikefarah/yq/releases/download/${LATEST_VERSION}/${YQ_TARBALL}"

# Download yq tarball from the latest release URL
echo "🌐 Downloading yq for $PLATFORM $ARCH from $YQ_URL..."
curl -L "$YQ_URL" -o "$TEMP_DIR/yq.tar.gz"

# Decompress and extract the tar.gz file
echo "📦 Decompressing and extracting yq..."
tar -xzf "$TEMP_DIR/yq.tar.gz" -C "$TEMP_DIR"

# Find the actual executable based on its executable permission
echo "🔍 Searching for the executable in the temp directory..."
EXECUTABLE=$(find "$TEMP_DIR" -type f -not -name "*.*" -exec file {} + | grep 'executable' | cut -d: -f1)

# Echo the executable path
echo "🔍 Found executable: $EXECUTABLE"

# Move the executable to the final installation directory
echo "🚚 Moving the yq binary to the installation directory..."
mv "$EXECUTABLE" "$INSTALL_DIR/yq"

# Clean up the temporary files
echo "🧹 Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

# Make the yq binary executable if necessary
chmod +x "$INSTALL_DIR/yq"