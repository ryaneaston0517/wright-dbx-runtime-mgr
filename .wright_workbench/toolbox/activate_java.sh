TARBALL_PATH=$1

echo "📂 Starting Java activation..."

# Echo the tarball path
echo "🗂 Extracting JDK from: $TARBALL_PATH"

# Define the installation path
INSTALL_DIR="$HOME/.wright_workbench/bin"
echo "📁 Installation directory will be: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Extract the last element of the tarball path and remove .tar.gz
FOLDER_NAME=$(basename "$TARBALL_PATH" .tar.gz)
echo "📦 Extracted folder name will be: $FOLDER_NAME"

# Define the final installation directory using the extracted folder name
FINAL_INSTALL_DIR="$INSTALL_DIR/$FOLDER_NAME"
echo "📁 Final installation directory: $FINAL_INSTALL_DIR"
mkdir -p "$FINAL_INSTALL_DIR"

# Check if the tarball exists before extracting
if [ ! -f "$TARBALL_PATH" ]; then
    echo "❌ Error: Tarball not found at $TARBALL_PATH. Exiting."
    return 1
fi

# Extract the tarball into the new folder
echo "🛠 Extracting $TARBALL_PATH into $FINAL_INSTALL_DIR"
tar -xvzf "$TARBALL_PATH" -C "$FINAL_INSTALL_DIR" --strip-components=1

# Output the installation location
if [ $? -eq 0 ]; then
    echo "✅ JDK successfully installed to: $FINAL_INSTALL_DIR"
else
    echo "❌ Error: Failed to extract the JDK tarball."
fi

# # Function to create symlinks for all Java executables
# create_java_symlinks() {
#   JAVA_INSTALL_DIR="$1"   # The extracted JDK directory (e.g., zulu8.78.0.19)
#   SYMLINK_DIR="$HOME/.wright_workbench/bin"  # Where the symlinks will live

#   # Ensure the symlink directory exists
#   mkdir -p "$SYMLINK_DIR"

#   # Path to the Java bin directory
#   JAVA_BIN_DIR="$JAVA_INSTALL_DIR/bin"

#   echo "Creating symlinks for all Java executables in $JAVA_BIN_DIR..."

#   # Loop over all executables in the JDK's bin directory and create symlinks
#   for executable in "$JAVA_BIN_DIR"/*; do
#     # Get the base name of the executable (e.g., "java" or "javac")
#     executable_name=$(basename "$executable")
    
#     # Create a symlink in the SYMLINK_DIR for each executable
#     ln -sf "$JAVA_BIN_DIR/$executable_name" "$SYMLINK_DIR/$executable_name"
#     echo "Symlink created for $executable_name"
#   done

#   echo "All symlinks created for Java in $SYMLINK_DIR."
# }