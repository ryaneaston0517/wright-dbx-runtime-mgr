#!/bin/zsh

echo "📂 Starting Spark download..."
BASE_URL="https://archive.apache.org/dist/spark"
VERSION="${1:-3.5.0}"  # Default Spark version is 3.5.0 if not provided
DRAWER_DIR="$HOME/.wright_workbench/drawer/spark"
DOWNLOAD_LOCATION="${2:-$DRAWER_DIR}"

# Extract the last part of the path
TOOL=$(basename "$DOWNLOAD_LOCATION")

echo "🔧 Download location: $DOWNLOAD_LOCATION"
mkdir -p "$DOWNLOAD_LOCATION"  # Ensure the directory exists

echo "🌐 Fetching $TOOL version $VERSION from apache.org..."
echo "🔧 Download location: $DOWNLOAD_LOCATION"

OUTPUT_FILE="$DOWNLOAD_LOCATION/$TOOL-$VERSION.tgz"
CHECKSUM_FILE="$DOWNLOAD_LOCATION/$TOOL-$VERSION.tgz.sha512"
SIGNATURE_FILE="$DOWNLOAD_LOCATION/$TOOL-$VERSION.tgz.asc"

# Assuming TOOL contains one of the following: "pyspark", "sparkr", "spark-bin-hadoop3", or "spark"
case $TOOL in
    pyspark)
        PACKAGE_URL="$BASE_URL/spark-$VERSION/$TOOL-$VERSION.tgz"
        ;;
    sparkr)
        PACKAGE_URL="$BASE_URL/spark-$VERSION/SparkR_$VERSION.tgz"  # Capital "R"
        ;;
    spark-bin-hadoop3)
        PACKAGE_URL="$BASE_URL/spark-$VERSION/spark-$VERSION-bin-hadoop3.tgz"
        ;;
    spark)
        PACKAGE_URL="$BASE_URL/spark-$VERSION/spark-$VERSION.tgz"
        ;;
    *)
        echo "❌ Error: Unknown tool type $TOOL."
        exit 1
        ;;
esac
echo "🔗 Download URL: $PACKAGE_URL"

# Download the tarball, checksum, and signature
echo "🔄 Downloading $TOOL version $VERSION..."
curl -o "$OUTPUT_FILE" "$PACKAGE_URL"
curl -o "$CHECKSUM_FILE" "$PACKAGE_URL.sha512"
curl -o "$SIGNATURE_FILE" "$PACKAGE_URL.asc"

# Verify if the download was successful
if [ $? -eq 0 ]; then
    echo "✅ Download complete: $OUTPUT_FILE"
else
    echo "❌ Download failed!"
    exit 1
fi

# Extract the expected checksum from the .sha512 file
EXPECTED_CHECKSUM=$(cat "$CHECKSUM_FILE" | awk '{print $1}')
echo "🔍 Expected checksum: $EXPECTED_CHECKSUM"

# Compute the actual checksum of the downloaded tarball
ACTUAL_CHECKSUM=$(shasum -a 512 "$OUTPUT_FILE" | awk '{print $1}')
echo "🔍 Actual checksum: $ACTUAL_CHECKSUM"

# Compare the checksums
echo "🔍 Verifying checksum..."
if [ "$EXPECTED_CHECKSUM" = "$ACTUAL_CHECKSUM" ]; then
    echo "✅ Checksum verified successfully."
else
    echo "❌ Error: Checksum verification failed."
    exit 1
fi

# TODO:  add in gpg verification. Requires gpg and dependencies to be installed
# # Import the Apache Spark public keys (you may want to skip this step if the keys are already imported)
# if ! gpg --list-keys "Spark Project Release Signing" > /dev/null 2>&1; then
#     echo "🌐 Importing Apache Spark GPG keys..."
#     curl https://downloads.apache.org/spark/KEYS | gpg --import
# fi

# # Verify the signature
# echo "🔍 Verifying GPG signature..."
# gpg --verify "$SIGNATURE_FILE" "$OUTPUT_FILE"

# if [ $? -eq 0 ]; then
#     echo "✅ GPG signature verified successfully."
# else
#     echo "❌ Error: GPG signature verification failed."
#     exit 1
# fi

echo "🎉 Spark download and verification complete!"
