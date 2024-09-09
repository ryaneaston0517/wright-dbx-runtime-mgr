#!/bin/zsh

# Path to where scripts are stored
WRIGHT_WORKBENCH="$HOME/.wright_workbench"

# Parse subcommands and arguments
COMMAND=$1
ARGUMENT=$2

case "$COMMAND" in
    activate)
        if [ -n "$ARGUMENT" ]; then
            echo "Activating environment for $ARGUMENT..."
            source "$WRIGHT_WORKBENCH/.toolbox/activate.sh" "$ARGUMENT"
        else
            echo "Please specify an environment to activate, e.g., 'wright activate databricks-15.4'."
        fi
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Available commands: activate"
        ;;
esac
