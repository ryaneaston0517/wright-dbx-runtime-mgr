#!/bin/zsh

# Source the shell config update script to use its functions
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/update_shell_config.sh"

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

DB_RUNTIME="$1"

# Check if there is an active runtime
if [ -f "$ACTIVE_RUNTIME_FILE" ]; then
    CURRENT_ACTIVE=$(cat "$ACTIVE_RUNTIME_FILE")
    if [ "$CURRENT_ACTIVE" == "$DB_RUNTIME" ]; then
        echo "✅ $DB_RUNTIME is already the active runtime."
        exit 0
    fi
fi

# Extract the specified environment's configurations using yq
echo "🔍 Extracting configuration for $DB_RUNTIME..."

# Function to download the tool if not found in bin or drawer
download_tool_to_drawer() {
    local TOOL_VERSION="$1"
    local TOOL_NAME="$2"

    if [[ "$TOOL_NAME" == *"spark"* ]]; then
        local TOOL_SCRIPT="spark"
    else
        local TOOL_SCRIPT="$TOOL_NAME"
    fi

    echo "🌐 Downloading $TOOL_NAME-$TOOL_VERSION..."

    "$SCRIPT_DIR/download_${TOOL_SCRIPT}.sh" "$TOOL_VERSION" "${DRAWER_DIR}/${TOOL_NAME}"
    echo "✅ Spark $TOOL_NAME-$TOOL_VERSION downloaded to drawer."
}

# Function to move the tool from drawer to bin if present
move_from_drawer_to_bin() {
    local TOOL_TARBALL_PATH="$1"
    echo "🗂️ Found $TOOL_TARBALL_PATH in the drawer. Moving to bin..."
    echo "🔧 Activating $TOOL_TARBALL_PATH..."
    "$SCRIPT_DIR/activate_tool.sh" "$TOOL_TARBALL_PATH"
    echo "✅ $TOOL_TARBALL_PATH moved to bin."
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

# Handle environments with hyphens or special characters by quoting the environment name
declare -A VERSIONS
TOOLS=("spark" "scala" "python" "java") 

for TOOL in "${TOOLS[@]}"; do
    # Extract version using yq and check if valid
    if [[ "$TOOL" == *"spark"* ]]; then
        # If TOOL contains "spark" but isn't exactly "spark", use the version of "spark"
        TOOL_VERSION=$(yq e '."'${DB_RUNTIME}'".spark' "$RUNTIME_FILE")
    else
        # Otherwise, extract the version normally for the tool
        TOOL_VERSION=$(yq e '."'${DB_RUNTIME}'".'"${TOOL}"'' "$RUNTIME_FILE")
    fi
    if [ -z "$TOOL_VERSION" ]; then
        echo "❌ Error: Invalid Databricks runtime or missing configuration for $TOOL in $DB_RUNTIME."
        exit 1
    fi

    # Store the extracted version in the associative array
    VERSIONS[$TOOL]="$TOOL_VERSION"

    # Echo the extracted version for the tool
    echo "✅ Configuration found for $TOOL in $DB_RUNTIME: $TOOL_VERSION"

    # Normalize the version string
    TOOL_VERSION=$(echo "$TOOL_VERSION" | tr '[:upper:]' '[:lower:]' | tr -d ' ')

    # Define paths
    TOOL_FOLDER_NAME="${TOOL}-${TOOL_VERSION}"
    TOOL_TARBALL_PATH="$DRAWER_DIR/$TOOL/$TOOL_FOLDER_NAME.tar.gz"

    # Check if the tool is installed in the bin directory
    echo "🔍 Checking if $TOOL_FOLDER_NAME is installed..."
    if [ ! -d "$BIN_DIR/$TOOL_FOLDER_NAME" ]; then
        # If not found in bin, check if it's in the drawer
        if [ ! -f "$TOOL_TARBALL_PATH" ]; then
            echo "❌ $TOOL_TARBALL_PATH is not installed. Attempting to download it to the drawer..."
            download_tool_to_drawer "$TOOL_VERSION" "$TOOL"
        else
            echo "✅ $TOOL_TARBALL_PATH is already in the drawer."
        fi

        # Move from drawer to bin
        echo "📦 $TOOL_FOLDER_NAME is not in the bin. Attempting to move from the drawer..."
        # move_from_drawer_to_bin "$TOOL_TARBALL_PATH"
    else
        echo "✅ $TOOL_FOLDER_NAME is already installed in the bin."
    fi

    # Create symlinks for the tool
    echo "🔗 Creating symlinks for $TOOL_FOLDER_NAME..."
    # create_symlinks "$BIN_DIR/$TOOL_FOLDER_NAME"

    # Update the environment variable in the shell profile
    echo "🔧 Updating shell configuration for $TOOL..."

    if typeset -f "update_shell_config_${TOOL}" > /dev/null; then
        # update_shell_config_${TOOL} "$BIN_DIR/$TOOL_FOLDER_NAME"
    else
        echo "⚠️ No update function for $TOOL. Skipping shell config update."
    fi
done

echo "🔄 Sourcing ${HOME}/.zshrc to apply changes..."
source $HOME/.zshrc
echo "✅ ${HOME}/.zshrc sourced. Changes applied."
