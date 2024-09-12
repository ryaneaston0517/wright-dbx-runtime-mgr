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
    exit 1
fi

# Extract the tarball into the new folder
echo "🛠 Extracting $TARBALL_PATH into $FINAL_INSTALL_DIR"
tar -xzf "$TARBALL_PATH" -C "$FINAL_INSTALL_DIR" --strip-components=1 --no-same-owner --no-same-permissions

# Output the installation location
if [ $? -eq 0 ]; then
    echo "✅ Successfully installed to: $FINAL_INSTALL_DIR"
else
    echo "❌ Error: Failed to extract the tarball."
    exit 1
fi

# Check if the extracted software needs to be compiled
echo "🔍 Checking if compilation is required..."

# Check if 'configure' script exists
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
            
            # Overwrite the original tarball with the built version
            echo "📦 Compressing the built version to overwrite the original tarball..."
            tar -czf "$TARBALL_PATH" -C "$FINAL_INSTALL_DIR" .
            
            if [ $? -eq 0 ]; then
                echo "✅ Built version compressed and saved to: $TARBALL_PATH"
            else
                echo "❌ Error: Failed to compress the tarball."
                exit 1
            fi
        else
            echo "❌ Error during 'make'."
            exit 1
        fi
    else
        echo "❌ Error during './configure'."
        exit 1
    fi

# Check if 'Makefile' exists and no 'configure'
elif [ -f "$FINAL_INSTALL_DIR/Makefile" ]; then
    echo "⚙️ 'Makefile' found but no 'configure'. Running 'make' directly."

    cd "$FINAL_INSTALL_DIR"
    echo "🔧 Running 'make'..."
    make -j$(nproc)

    if [ $? -eq 0 ]; then
        echo "🔧 Running 'make install'..."
        make install
        echo "✅ Compilation and installation complete."
        
        # Overwrite the original tarball with the built version
        echo "📦 Compressing the built version to overwrite the original tarball..."
        tar -czf "$TARBALL_PATH" -C "$FINAL_INSTALL_DIR" .
        
        if [ $? -eq 0 ]; then
            echo "✅ Built version compressed and saved to: $TARBALL_PATH"
        else
            echo "❌ Error: Failed to compress the tarball."
            exit 1
        fi
    else
        echo "❌ Error during 'make'."
        exit 1
    fi

# Check if it's Spark (by looking for "/spark-" in the path)
elif [[ "$FINAL_INSTALL_DIR" == *"/spark-"* ]]; then
    echo "🔍 Detected Spark source directory. Building Spark with Maven..."

    # Check if Maven is installed
    if ! command -v mvn &> /dev/null; then
        echo "❌ Error: Maven is not installed or not in PATH."
        exit 1
    fi

    cd "$FINAL_INSTALL_DIR"

    # Build Spark using Maven
    mvn -DskipTests clean package

    # Check if the build was successful
    if [ $? -eq 0 ]; then
        echo "✅ Spark built successfully!"

        # Overwrite the original tarball with the built version
        echo "📦 Compressing built Spark version to overwrite the original tarball..."
        tar -czf "$TARBALL_PATH" -C "$FINAL_INSTALL_DIR" .

        if [ $? -eq 0 ]; then
            echo "✅ Built Spark version compressed and stored in: $TARBALL_PATH"
        else
            echo "❌ Error: Failed to compress the tarball."
            exit 1
        fi
    else
        echo "❌ Error: Spark build failed."
        exit 1
    fi
else
    echo "📦 No 'configure', 'Makefile', or Spark source found. This is likely a precompiled binary."
fi

echo "🎉 Done!"
