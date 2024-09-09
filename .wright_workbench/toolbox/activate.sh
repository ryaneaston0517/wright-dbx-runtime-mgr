#!/bin/zsh

# Path to the runtime_versions.yml file
RUNTIME_FILE="$HOME/.wright_workbench/runtime_versions.yml"

# Check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "Error: 'yq' is not installed. This script requires 'yq' to parse YAML files."
    echo "Please install yq before running this script."
    echo "Installation instructions: https://github.com/mikefarah/yq#install"
    exit 1
fi

# Ensure the user passed an argument
if [ -z "$1" ]; then
    echo "Please specify an environment to activate, e.g., 'wright activate databricks-15.4'."
    exit 1
fi

# Extract the specified environment's configurations using yq
ENVIRONMENT=$1
PYTHON_VERSION=$(yq e ".${ENVIRONMENT}.python" "$RUNTIME_FILE")
SCALA_VERSION=$(yq e ".${ENVIRONMENT}.scala" "$RUNTIME_FILE")
SPARK_VERSION=$(yq e ".${ENVIRONMENT}.spark" "$RUNTIME_FILE")
JAVA_VERSION=$(yq e ".${ENVIRONMENT}.java" "$RUNTIME_FILE")

# Check if the environment was found
if [ -z "$PYTHON_VERSION" ] || [ -z "$SCALA_VERSION" ] || [ -z "$SPARK_VERSION" ] || [ -z "$JAVA_VERSION" ]; then
    echo "Error: Invalid environment or missing configuration for $ENVIRONMENT."
    exit 1
fi

# Activate the correct versions by updating the PATH and JAVA_HOME
echo "Activating environment for $ENVIRONMENT..."
echo "Setting up Python $PYTHON_VERSION, Scala $SCALA_VERSION, Spark $SPARK_VERSION, and Java $JAVA_VERSION."

# Update PATH for Python, Scala, and Spark
export PATH="$HOME/.wright_workbench/python-$PYTHON_VERSION/bin:$PATH"
export PATH="$HOME/.wright_workbench/scala-$SCALA_VERSION/bin:$PATH"
export PATH="$HOME/.wright_workbench/spark-$SPARK_VERSION-bin-hadoop3/bin:$PATH"

# Update JAVA_HOME for the correct Java version
export JAVA_HOME="$HOME/.wright_workbench/zulu-$JAVA_VERSION"
export PATH="$JAVA_HOME/bin:$PATH"

echo "$ENVIRONMENT environment activated with the following versions:"
echo "  Python: $PYTHON_VERSION"
echo "  Scala: $SCALA_VERSION"
echo "  Spark: $SPARK_VERSION"
echo "  Java: $JAVA_VERSION"
