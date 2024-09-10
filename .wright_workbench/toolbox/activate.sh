#!/bin/zsh

# Paths to runtime_versions.yml, the active runtime file, and drawer/bin directories
RUNTIME_FILE="$HOME/.wright_workbench/runtime_versions.yml"
echo "📄 Runtime configuration file set to: $RUNTIME_FILE"
ACTIVE_RUNTIME_FILE="$HOME/.wright_workbench/active_runtime.txt"
echo "📄 Active runtime file set to: $ACTIVE_RUNTIME_FILE"
BIN_DIR="$HOME/.wright_workbench/bin"
echo "🔧 Bin directory set to: $BIN_DIR"
DRAWER_DIR="$HOME/.wright_workbench/drawer"
echo "🗄️  Drawer directory set to: $DRAWER_DIR"


# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "❌ Error: 'yq' is not installed. This script requires 'yq' to parse YAML files."
    echo "💡 Please install 'yq' before running this script."
    exit 1
fi

# Ensure the user passed an argument
if [ -z "$1" ]; then
    echo "⚠️  Please specify an environment to activate, e.g., 'wright activate databricks-15.4'."
    exit 1
fi

ENVIRONMENT=$1

# Check if there is an active runtime
if [ -f "$ACTIVE_RUNTIME_FILE" ]; then
    CURRENT_ACTIVE=$(cat "$ACTIVE_RUNTIME_FILE")
    if [ "$CURRENT_ACTIVE" == "$ENVIRONMENT" ]; then
        echo "✅ $ENVIRONMENT is already the active runtime."
        exit 0
    fi
fi

# Extract the specified environment's configurations using yq
echo "🔍 Extracting configuration for $ENVIRONMENT..."

# Handle environments with hyphens or special characters by quoting the environment name
declare -A VERSIONS
TOOLS=("java")
# TOOLS=("python" "scala" "spark" "java")

for TOOL in "${TOOLS[@]}"; do
    VERSIONS[$TOOL]=$(yq e '."'${ENVIRONMENT}'".'"${TOOL}"'' "$RUNTIME_FILE")
done

# Check if the environment was found
for TOOL in "${TOOLS[@]}"; do
    if [ -z "${VERSIONS[$TOOL]}" ]; then
        echo "❌ Error: Invalid environment or missing configuration for $ENVIRONMENT."
        exit 1
    fi
done

# Echo the extracted versions
echo "✅ Configuration found for $ENVIRONMENT:"
for TOOL in "${TOOLS[@]}"; do
    echo "   - $TOOL: ${VERSIONS[$TOOL]}"
done

# Function to download the tool if not found in bin or drawer
download_tool_to_drawer() {
    local TOOL_VERSION=$1
    local TOOL_NAME=$2
    echo "🌐 Downloading $TOOL_NAME-$TOOL_VERSION..."
    # Check if the tool is Java, and call download_java.sh if it is
    if [[ "$TOOL_NAME" == "java" ]]; then
        # Execute the download_java.sh script
        SCRIPT_DIR=$(dirname "$0")  # Get the directory of the current script
        "$SCRIPT_DIR/download_java.sh" "$TOOL_VERSION" "${DRAWER_DIR}/${TOOL_NAME}"
    else
        # Placeholder logic for other tools
        mkdir -p "$DRAWER_DIR/$TOOL_NAME-$TOOL_VERSION"
        echo "✅ $TOOL_NAME-$TOOL_VERSION downloaded to drawer."
    fi
    echo "✅ $TOOL_NAME-$TOOL_VERSION downloaded to drawer."
}

# Function to move the tool from drawer to bin if present
move_from_drawer_to_bin() {
    local TOOL_TARBALL_PATH=$1
    if [ -f $TOOL_TARBALL_PATH ]; then
        echo "🗂️ Found $TOOL_TARBALL_PATH in the drawer. Moving to bin..."
        # Check if the tool is Java, and call download_java.sh if it is
        if [[ "$TOOL_TARBALL_PATH" == *"java"* ]]; then;
            # Execute the download_java.sh script
            SCRIPT_DIR=$(dirname "$0")  # Get the directory of the current script
            echo "🔧 Activating Java... $TOOL_TARBALL_PATH"
            "$SCRIPT_DIR/activate_java.sh" $TOOL_TARBALL_PATH
        fi
        # mv "$DRAWER_DIR/$TOOL_NAME-$TOOL_VERSION" "$BIN_DIR/"
        echo "✅ $TOOL_TARBALL_PATH moved to bin."
    else
        echo "❌ $TOOL_TARBALL_PATH not found in the drawer. Exiting."
        exit 1
    fi
}

# Function to create symlinks for the installed tools
create_symlinks() {
    TOOL_BIN_DIR="$1"  # Path to the tool's bin directory
    SYMLINK_DIR="$HOME/.wright_workbench/bin"  # Where symlinks will live

    # Ensure the symlink directory exists
    mkdir -p "$SYMLINK_DIR"

    echo "🔗 Creating symlinks for $TOOL_BIN_DIR..."

    # Loop over all executables in the tool's bin directory and create symlinks
    for executable in "$TOOL_BIN_DIR/bin/"*; do
        executable_name=$(basename "$executable")
        symlink_path="$SYMLINK_DIR/$executable_name"

        # Check if a symlink already exists at the target location
        if [ -L "$symlink_path" ]; then
            # If the symlink exists, check where it points
            current_target=$(readlink "$symlink_path")
            if [[ "$current_target" == "$executable" ]]; then  # Use double brackets for comparison in zsh
            else
                echo "🔄 Updating symlink for $executable_name (currently points to $current_target)"
                ln -sf "$executable" "$symlink_path"
                echo "✅ Symlink updated for $executable_name -> $symlink_path"
            fi
        else
            # Create the symlink if it doesn't exist
            ln -sf "$executable" "$symlink_path"
            echo "✅ Symlink created for $executable_name -> $symlink_path"
        fi
    done
}

# Function to ensure JAVA_HOME is set correctly in the shell profile within the Wright CLI block
update_home_env_var() {
    local HOME_PATH="$1"
    local PROFILE_FILE="$HOME/.zshrc"
    local START_COMMENT="# Wright CLI Setup"
    local END_COMMENT="# End Wright CLI Setup"

    echo "🔍 Checking if JAVA_HOME is set correctly in the $START_COMMENT block in $PROFILE_FILE..."

    # Check if the Wright CLI Setup block exists
    if grep -q "$START_COMMENT" "$PROFILE_FILE"; then
        # If the block exists, check if JAVA_HOME is within this block
        if sed -n "/$START_COMMENT/,/$END_COMMENT/p" "$PROFILE_FILE" | grep -q "export JAVA_HOME="; then
            # If JAVA_HOME exists but doesn't match, replace it
            if ! sed -n "/$START_COMMENT/,/$END_COMMENT/p" "$PROFILE_FILE" | grep -q "export JAVA_HOME=\"$HOME_PATH\""; then
                echo "🔄 Replacing existing JAVA_HOME within the Wright CLI block with $HOME_PATH"
                # Replace JAVA_HOME within the block, ensuring newlines are handled
                sed -i '' "/$START_COMMENT/,/$END_COMMENT/s|export JAVA_HOME=.*|export JAVA_HOME=\"$HOME_PATH\"|" "$PROFILE_FILE"
                echo "✅ JAVA_HOME updated to $HOME_PATH in $PROFILE_FILE"
            else
                echo "✅ JAVA_HOME is already set correctly in the Wright CLI block in $PROFILE_FILE"
            fi
        else
            # Add JAVA_HOME inside the block if it's not present
            sed -i '' "/$START_COMMENT/a\\
export JAVA_HOME=\"$HOME_PATH\"\\
" "$PROFILE_FILE"
            echo "✅ JAVA_HOME added to the Wright CLI block in $PROFILE_FILE"
        fi
    else
        # If the block doesn't exist, create it and add JAVA_HOME within it, ensuring newlines are handled properly
        echo "🔄 Wright CLI Setup block not found. Adding the block and JAVA_HOME."
        printf "\n$START_COMMENT\nexport JAVA_HOME=\"$HOME_PATH\"\nexport PATH=\"$HOME/.wright_workbench/bin:\$PATH\"\nalias wright=\"$HOME/.wright_workbench/.toolbox/wright.sh\"\n$END_COMMENT\n" >> "$PROFILE_FILE"
        echo "✅ Wright CLI Setup block and JAVA_HOME added to $PROFILE_FILE"
    fi

    # Source the .zshrc file to apply changes immediately
    echo "🔄 Sourcing $PROFILE_FILE to apply changes..."
    source "$PROFILE_FILE"
    echo "✅ $PROFILE_FILE sourced. Changes applied."
}

# Check if the necessary binaries are installed
for TOOL in "${TOOLS[@]}"; do
    TOOL_VERSION="${VERSIONS[$TOOL]}"
    TOOL_VERSION=$(echo "$TOOL_VERSION" | tr '[:upper:]' '[:lower:]' | tr -d ' ')

    TOOL_FOLDER_NAME="${TOOL}-${TOOL_VERSION}"
    TOOL_TARBALL_PATH="$DRAWER_DIR/$TOOL/${TOOL_VERSION}.tar.gz"
    echo "🔍 Checking if $TOOL_FOLDER_NAME is installed..."
    
    # First, check if the tool is in the bin directory
    if [ ! -d "$BIN_DIR/$TOOL_VERSION" ]; then
        # If not in bin, check if it's in the drawer and move it
        if [ ! -f $TOOL_TARBALL_PATH ]; then
            echo "❌ $TOOL_TARBALL_PATH is not installed. Attempting to download it to the drawer..."
            download_tool_to_drawer "$TOOL_VERSION" "$TOOL"
        else
            echo "✅ $TOOL_TARBALL_PATH is already in the drawer."
        fi

        echo "📦 $TOOL_FOLDER_NAME is not in the bin. Attempting to move from the drawer..."
        move_from_drawer_to_bin $TOOL_TARBALL_PATH $TOOL
    else
        echo "✅ $TOOL_FOLDER_NAME is already installed in the bin."
    fi

    echo "🔗 Creating symlinks for $TOOL_FOLDER_NAME..."
    create_symlinks "$BIN_DIR/$TOOL_VERSION"

    # Update the JAVA_HOME environment variable in the shell profile
    echo "🔧 Updating $TOOL HOME environment variable..."
    update_home_env_var $BIN_DIR/$TOOL_VERSION

done
