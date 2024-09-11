#!/bin/zsh

TARBALL_PATH=$1

echo "📂 Starting activation..."

# Echo the tarball path
echo "🗂 Extracting from: $TARBALL_PATH"

# Define the installation path
INSTALL_DIR="$HOME/.wright_workbench/bin"
echo "📁 Installation directory will be: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Extract the last element of the tarball path and remove .tar.gz or tgz dynamically
FOLDER_NAME=$(basename "$TARBALL_PATH" | sed -E 's/\.(tar\.gz|tgz)$//')
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
    echo "✅ successfully installed to: $FINAL_INSTALL_DIR"
else
    echo "❌ Error: Failed to extract the tarball."
fi

# Check if the extracted software needs to be compiled
echo "🔍 Checking if compilation is required..."

if [ -f "$FINAL_INSTALL_DIR/configure" ]; then
    echo "⚙️ 'configure' script found. Compilation is required."
    
    cd "$FINAL_INSTALL_DIR"
    echo "🔧 Running './configure'..."
    ./configure --prefix="$FINAL_INSTALL_DIR" --enable-optimizations

    if [ $? -eq 0 ]; then
        echo "🔧 Running 'make'..."
        make -j$(nproc)

        if [ $? -eq 0 ]; then
            echo "🔧 Running 'make install'..."
            make install
            echo "✅ Compilation and installation complete."
        else
            echo "❌ Error during 'make'."
            return 1
        fi
    else
        echo "❌ Error during './configure'."
        return 1
    fi
elif [ -f "$FINAL_INSTALL_DIR/Makefile" ]; then
    echo "⚙️ 'Makefile' found but no 'configure'. Running 'make' directly."

    cd "$FINAL_INSTALL_DIR"
    echo "🔧 Running 'make'..."
    make -j$(nproc)

    if [ $? -eq 0 ]; then
        echo "🔧 Running 'make install'..."
        make install
        echo "✅ Compilation and installation complete."
    else
        echo "❌ Error during 'make'."
        return 1
    fi
else
    echo "📦 No 'configure' or 'Makefile' found. This is likely a precompiled binary."
fi

echo "🎉 Done!"