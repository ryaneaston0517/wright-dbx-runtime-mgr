#!/bin/bash

# Define the available subcommands
case "$1" in
  shelve)
    shift # remove 'shelve' from the argument list
    ~/.workbench/.toolbox/shelver.sh "$@" # call shelver.sh with any additional arguments
    ;;
  install)
    echo "🔧 Installing software..."
    # Add your install logic here
    ;;
  update)
    echo "🔄 Updating software versions..."
    # Add your update logic here
    ;;
  list)
    echo "📂 Listing software versions..."
    # Add a command to list active versions here
    ;;
  *)
    echo "Wright Package Manager"
    echo "Usage: wright [command]"
    echo "Commands:"
    echo "  shelve     Organize and shelve your active software versions"
    echo "  install    Install a new software"
    echo "  update     Update installed software"
    echo "  list       List current software versions"
    ;;
esac
