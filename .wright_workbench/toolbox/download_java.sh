#!/bin/zsh

# Function to detect OS
detect_os() {
  case "$(uname -s)" in
    Darwin)
      OS="macos"
      ;;
    Linux)
      OS="linux"
      ;;
    *)
      echo "Unsupported OS. Exiting."
      exit 1
      ;;
  esac
}

# Function to detect architecture
detect_arch() {
  case "$(uname -m)" in
    x86_64)
      ARCH="x86"
      ;;
    arm64|aarch64)
      ARCH="aarch64"
      ;;
    *)
      echo "Unsupported architecture. Exiting."
      exit 1
      ;;
  esac
}

# Function to download the appropriate Zulu JDK .tar.gz file
download_java() {
  ZULU_BASE_URL="https://cdn.azul.com/zulu/bin"

  # Use the passed-in Java version or fall back to a default
  JDK_VERSION="${1:-Zulu 8.78.0.19}"

  # Use the passed-in download location or fall back to a default location
  DRAWER_DIR="$HOME/.wright_workbench/drawer/java"
  DOWNLOAD_LOCATION="${2:-$DRAWER_DIR}"

  echo "Downloading JDK version: $JDK_VERSION"
  echo "Download location: $DOWNLOAD_LOCATION"

  # Ensure the directory exists
  mkdir -p "$DOWNLOAD_LOCATION"

  # Step 1: Convert to lowercase
  echo "Original JDK version: $JDK_VERSION"
  JDK_VERSION_LOWER=$(echo "$JDK_VERSION" | tr '[:upper:]' '[:lower:]')
  echo "Lowercase version: $JDK_VERSION_LOWER"

  # Step 2: Remove spaces
  JDK_VERSION_NO_SPACES=$(echo "$JDK_VERSION_LOWER" | tr -d ' ')
  echo "Version with no spaces: $JDK_VERSION_NO_SPACES"

  # Step 1: Split the string by the delimiter '-' and isolate the last part (architecture)
  LAST_PART=$(echo "$JDK_VERSION_NO_SPACES" | awk -F'-' '{print $NF}')

  # Step 2: Remove the last part (architecture) and get the base version string
  BASE_VERSION=$(echo "$JDK_VERSION_NO_SPACES" | sed "s/-$LAST_PART//")

  # Determine architecture
  if [[ "$OS" == "macos" && "$ARCH" == "x86_64" ]]; then
    # macOS on x86_64
    NEW_ARCH="macosx_x64"
  elif [[ "$OS" == "macos" && "$ARCH" == "arm64" ]]; then
    # macOS on ARM64 (Apple Silicon)
    NEW_ARCH="macosx_aarch64"
  elif [[ "$OS" == "macos" && "$ARCH" == "aarch64" ]]; then
    # macOS on ARM64 (Apple Silicon)
    NEW_ARCH="macosx_aarch64"
  elif [[ "$OS" == "linux" && "$ARCH" == "x86_64" ]]; then
    # Linux on x86_64
    NEW_ARCH="linux_x64"
  elif [[ "$OS" == "linux" && "$ARCH" == "arm64" ]]; then
    # Linux on ARM64
    NEW_ARCH="linux_aarch64"
  else
    echo "Unsupported OS or architecture: $OS, $ARCH"
    exit 1
  fi

  # Step 5: Concatenate the base version with the wildcard and new architecture
  FINAL_VERSION="${BASE_VERSION}-.*-${NEW_ARCH}"
  echo "Final version regex: $FINAL_VERSION"

  # Count the number of items in FINAL_VERSION delimited by "-"
  FINAL_VERSION_PARTS=$(echo "$FINAL_VERSION" | awk -F'-' '{print NF}')
  echo "Number of parts in FINAL_VERSION: $FINAL_VERSION_PARTS"

  # Step 1: Use curl to get the directory listing
  echo "Fetching directory listing from $ZULU_BASE_URL"
  LISTING=$(curl -s $ZULU_BASE_URL)

  # Step 3: Extract all matching lines for JDK-related .tar.gz files
  MATCHED_FILES=$(echo "$LISTING" | grep -E "${BASE_VERSION}-.*-jdk.*-${NEW_ARCH}\.tar\.gz")

  # Step 4: Filter by JDK (excluding jre), and match number of parts with FINAL_VERSION
  if [[ -n "$MATCHED_FILES" ]]; then
    # Extract only jdk versions, excluding any jre versions
    FILTERED_FILES=$(echo "$MATCHED_FILES" | sed -n 's/.*href="\/zulu\/bin\/\([^"]*\)".*/\1/p' | grep -v 'jre' | grep -v '\-fx\-')
    echo "Filtered JDK files:"
    echo "$FILTERED_FILES"

    NO_FILE_MATCH="No matching JDK files found for pattern: $FINAL_VERSION"
    MATCH_FOUND=false

    # Convert FILTERED_FILES into an array
    IFS=$'\n' FILES_ARRAY=("${(@f)FILTERED_FILES}")

    # Step 5: Keep only the files that have the same number of segments as FINAL_VERSION
    echo "Filtered JDK files:"
    for FILE in "${FILES_ARRAY[@]}"; do
        FINAL_URL="${ZULU_BASE_URL}/${FILE}"
        echo "Checking: $FINAL_URL"
        # Extract the first part of FILE, delimited by '-'
        TARBALL_BASENAME=$(echo "$FILE" | awk -F'-' '{print $1}')
        OUTPUT_FILE="${DOWNLOAD_LOCATION}/${TARBALL_BASENAME}.tar.gz"
        echo "Saving to: $OUTPUT_FILE"
        curl -o "$OUTPUT_FILE" "$FINAL_URL"
        MATCH_FOUND=true

        # # Call the function to install Java after download
        # install_zulu_jdk "$OUTPUT_FILE"

        # break # stop the loop after the first match
    done

    # If no match was found after checking all files, print the no match message
    if ! $MATCH_FOUND; then
      echo "$NO_FILE_MATCH"
    fi
  else
    echo "$NO_FILE_MATCH"
  fi
}

# Detect OS and architecture
echo "Detecting OS and architecture..."
detect_os
echo "Detected OS: $OS"
detect_arch
echo "Detected architecture: $ARCH"

# Download and install the JDK
# Accept parameters from command line
JAVA_VERSION="$1"
DOWNLOAD_LOCATION="$2"

# Download and install the JDK
download_java "$JAVA_VERSION" "$DOWNLOAD_LOCATION"
# download_zulu_jdk
# result=$(download_zulu_jdk)
# echo $result
# install_zulu_jdk

# # Optional: Set JAVA_HOME and add to PATH
# echo "Setting up environment variables..."
# if [[ "$OS" == "macos" ]]; then
#   echo 'export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu*/Contents/Home' >> ~/.bash_profile
# else
#   echo 'export JAVA_HOME=/usr/lib/jvm/zulu*/bin' >> ~/.bashrc
# fi
# echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bash_profile

# echo "Installation complete. Please restart your terminal or source your profile file to use the new Java version."
