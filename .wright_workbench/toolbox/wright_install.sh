#!/bin/bash

WORKBENCH_DIR="$HOME/.workbench"
RUNTIME_VERSIONS_FILE="$WORKBENCH_DIR/runtime_versions.yml"

# Function to download and install specific Python, Scala, Spark, and Java versions
install_runtime() {
    local runtime=$1
    echo "Installing environment for Databricks runtime $runtime..."
    
    # Parse YAML to get version mappings
    python_version=$(grep -A1 "$runtime" "$RUNTIME_VERSIONS_FILE" | grep "python" | awk '{print $2}')
    scala_version=$(grep -A1 "$runtime" "$RUNTIME_VERSIONS_FILE" | grep "scala" | awk '{print $2}')
    spark_version=$(grep -A1 "$runtime" "$RUNTIME_VERSIONS_FILE" | grep "spark" | awk '{print $2}')
    java_version=$(grep -A1 "$runtime" "$RUNTIME_VERSIONS_FILE" | grep "java" | awk '{print $2}')

    # Python installation
    if [ ! -d "$WORKBENCH_DIR/python-$python_version" ]; then
        echo "Downloading Python $python_version..."
        curl -O https://www.python.org/ftp/python/$python_version/Python-$python_version.tgz
        tar -xzf Python-$python_version.tgz -C "$WORKBENCH_DIR"
        rm Python-$python_version.tgz
        echo "Python $python_version installed."
    fi

    # Scala installation
    if [ ! -d "$WORKBENCH_DIR/scala-$scala_version" ]; then
        echo "Downloading Scala $scala_version..."
        curl -O https://downloads.lightbend.com/scala/$scala_version/scala-$scala_version.tgz
        tar -xzf scala-$scala_version.tgz -C "$WORKBENCH_DIR"
        rm scala-$scala_version.tgz
        echo "Scala $scala_version installed."
    fi

    # Spark installation
    if [ ! -d "$WORKBENCH_DIR/spark-$spark_version-bin-hadoop3" ]; then
        echo "Downloading Spark $spark_version..."
        curl -O https://archive.apache.org/dist/spark/spark-$spark_version/spark-$spark_version-bin-hadoop3.tgz
        tar -xzf spark-$spark_version-bin-hadoop3.tgz -C "$WORKBENCH_DIR"
        rm spark-$spark_version-bin-hadoop3.tgz
        echo "Spark $spark_version installed."
    fi

    # Java installation
    if [ ! -d "$WORKBENCH_DIR/zulu-$java_version" ]; then
        echo "Downloading Zulu Java $java_version..."
        curl -O https://cdn.azul.com/zulu/bin/zulu$java_version-ca-jdk8.0.312-macosx_x64.tar.gz
        tar -xzf zulu$java_version-ca-jdk8.0.312-macosx_x64.tar.gz -C "$WORKBENCH_DIR"
        rm zulu$java_version-ca-jdk8.0.312-macosx_x64.tar.gz
        echo "Zulu Java $java_version installed."
    fi
}
