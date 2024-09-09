#!/bin/zsh

# Define the installation directory
INSTALL_DIR="$HOME/.wright_workbench/bin"
echo "🔧 Installation directory set to: $INSTALL_DIR"
# Ensure the installation directory exists
mkdir -p "$INSTALL_DIR"

# Determine platform and architecture
PLATFORM=$(uname -s)
ARCH=$(uname -m)

# Echo platform and architecture information
echo "🖥️  Detected platform: $PLATFORM"
echo "🔧 Detected architecture: $ARCH"

# Translate architecture for jq naming convention
if [[ "$ARCH" == "x86_64" ]]; then
    ARCH="64"
    echo "🔄 Translating architecture to: $ARCH"
elif [[ "$ARCH" == "arm64" ]]; then
    ARCH="arm"
    echo "🔄 Translating architecture to: $ARCH"
else
    echo "❌ Unsupported architecture: $ARCH. Exiting."
    exit 1
fi

# Fetch the latest jq release version from GitHub using curl and sed
echo "🌐 Fetching the latest jq release version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/jqlang/jq/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Verify if the version was fetched correctly
if [ -z "$LATEST_VERSION" ]; then
    echo "❌ Failed to fetch the latest version. Exiting."
    exit 1
fi

echo "🔄 Latest jq version: $LATEST_VERSION"

# Set the correct download URL for the jq source tarball
JQ_URL="https://github.com/jqlang/jq/releases/download/${LATEST_VERSION}/${LATEST_VERSION}.tar.gz"

# Download jq source from the latest release URL
echo "🌐 Downloading jq source for $PLATFORM $ARCH from $JQ_URL..."
curl -L "$JQ_URL" -o "$INSTALL_DIR/jq.tar.gz"

# Decompress and extract the tar.gz file
echo "📦 Decompressing and extracting jq source..."
tar -xzf "$INSTALL_DIR/jq.tar.gz" -C "$INSTALL_DIR"

# Navigate to the extracted directory
cd "$INSTALL_DIR/$LATEST_VERSION" || exit

# Check if the configure script exists
if [ ! -f configure ]; then
    echo "❌ The configure script was not found. You may need to run autoconf."
    exit 1
fi

# Run configure to prepare the build
echo "🔧 Running configure script..."
./configure

# Compile jq from source
echo "🔨 Compiling jq..."
make

# Move the compiled binary to the bin directory
echo "🚚 Moving jq binary to $INSTALL_DIR..."
mv ./jq "$INSTALL_DIR"

# Clean up the extracted source directory and tar.gz file
echo "🧹 Cleaning up..."
rm -rf "$INSTALL_DIR/$LATEST_VERSION" "$INSTALL_DIR/jq.tar.gz"

# Make the jq binary executable
chmod +x "$INSTALL_DIR/jq"

# Confirm installation
echo "✅ jq has been successfully compiled and installed in $INSTALL_DIR."
