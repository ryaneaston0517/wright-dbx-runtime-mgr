#!/bin/zsh

# Define the installation directory
INSTALL_DIR="$HOME/.wright_workbench/bin"
echo "🔧 Installation directory set to: $INSTALL_DIR"
# Ensure the installation directory exists
mkdir -p "$INSTALL_DIR"

# Define the base URL for Maven releases
BASE_URL="https://dlcdn.apache.org/maven/maven-3/"

echo "🌐 Fetching the latest Maven version from: $BASE_URL"

# Fetch the directory listing from the URL, filter out the version directories, and extract the latest one
LATEST_VERSION=$(curl -s $BASE_URL | grep 'href' | grep -o '>[0-9]\+\.[0-9]\+\.[0-9]\+/' | sed 's|[>/]||g' | sort -V | tail -n 1)

# Check if we have a valid version
if [ -z "$LATEST_VERSION" ]; then
    echo "❌ Error: Could not determine the latest Maven version."
    exit 1
fi

# Output the latest version
echo "✅ Latest Maven version: $LATEST_VERSION"

# Construct the URL for the latest version tarball
TARBALL_URL="${BASE_URL}${LATEST_VERSION}/binaries/apache-maven-${LATEST_VERSION}-bin.tar.gz"

# Output the tarball URL
echo "📦 Download URL for the latest Maven version: $TARBALL_URL"

# Download Maven source from the latest release URL
echo "🌐 Downloading Maven source from $TARBALL_URL..."
curl -L "$TARBALL_URL" -o "$INSTALL_DIR/maven.tar.gz"

# Check if the download was successful
if [ $? -eq 0 ]; then
    echo "✅ Maven $LATEST_VERSION downloaded successfully to $INSTALL_DIR/maven.tar.gz"
else
    echo "❌ Error: Failed to download Maven $LATEST_VERSION"
    exit 1
fi

# Decompress and extract the tar.gz file
echo "📦 Decompressing and extracting Maven binary..."
tar -xzf "$INSTALL_DIR/maven.tar.gz" -C "$INSTALL_DIR"

# Check if the extraction was successful
if [ $? -eq 0 ]; then
    echo "✅ Maven $LATEST_VERSION extracted successfully to $INSTALL_DIR"
else
    echo "❌ Error: Failed to extract Maven $LATEST_VERSION"
    exit 1
fi

# Cleanup the tarball after extraction
rm "$INSTALL_DIR/maven.tar.gz"
echo "🧹 Cleaned up Maven tarball"

# Define Maven installation path (where it was extracted)
MAVEN_DIR="$INSTALL_DIR/apache-maven-${LATEST_VERSION}"

# Create symlinks from Maven binaries to $INSTALL_DIR
for binary in "$MAVEN_DIR/bin/"*; do
    binary_name=$(basename "$binary")
    symlink_path="$INSTALL_DIR/$binary_name"
    
    if [ -L "$symlink_path" ] || [ -e "$symlink_path" ]; then
        echo "🔄 Symlink or file already exists for $binary_name, overwriting..."
        rm -f "$symlink_path"
    fi
    
    ln -s "$binary" "$symlink_path"
    echo "🔗 Created symlink: $symlink_path -> $binary"
done

echo "✅ Symlinks created for Maven binaries."
