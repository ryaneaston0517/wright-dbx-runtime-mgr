#!/bin/bash

# Define directories
WORKBENCH_DIR="$HOME/.workbench"
DRAWER_DIR="$WORKBENCH_DIR/drawer"

# Ensure the drawer directory exists
mkdir -p "$DRAWER_DIR"

# Fun echo message to simulate going to the workbench
echo "🔧 Heading over to the workbench..."

# Loop through each folder in the .workbench directory
for SOFTWARE in "$WORKBENCH_DIR"/*/; do
    # Extract the folder name by removing the path
    SOFTWARE_NAME=$(basename "$SOFTWARE")

    # Skip the "drawer" folder itself
    if [ "$SOFTWARE_NAME" == "drawer" ]; then
        continue
    fi

    # Handle Java manually due to its different naming convention
    if [[ "$SOFTWARE_NAME" == zulu* ]]; then
        SOFTWARE_TYPE="java"
    else
        # Extract the software type by splitting the name at the first "-"
        SOFTWARE_TYPE=$(echo "$SOFTWARE_NAME" | cut -d'-' -f1)
    fi

    # Define the software-specific subfolder in the drawer
    SOFTWARE_DRAWER="$DRAWER_DIR/$SOFTWARE_TYPE"

    # Step 1: Check if the drawer for the software exists
    if [ ! -d "$SOFTWARE_DRAWER" ]; then
        echo "🗃️ Finding an empty drawer and provisioning it for $SOFTWARE_TYPE..."
        mkdir -p "$SOFTWARE_DRAWER"
    else
        echo "📂 Pulling open the $SOFTWARE_TYPE drawer..."
    fi

    # Step 2: Check if the software version is already in the drawer
    if [ -f "$SOFTWARE_DRAWER/${SOFTWARE_NAME}.tar.gz" ]; then
        echo "✅ $SOFTWARE_NAME is already stored in the $SOFTWARE_TYPE drawer."
    else
        # Step 3: If the version isn't stored, package it into its own container
        echo "📦 Getting a container ready for $SOFTWARE_NAME and placing it in the $SOFTWARE_TYPE drawer..."
        tar -czvf "$SOFTWARE_DRAWER/${SOFTWARE_NAME}.tar.gz" -C "$WORKBENCH_DIR" "$SOFTWARE_NAME"
        echo "🧳 $SOFTWARE_NAME has been safely placed in the $SOFTWARE_TYPE drawer as ${SOFTWARE_NAME}.tar.gz"
    fi
done

# Final echo statement to indicate organization is complete
echo "🧹 Workbench organized! The active tools are ready, and old versions are neatly stored in the drawers."
