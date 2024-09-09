#!/bin/zsh

# Define the WRIGHT_DIR Path
WRIGHT_WORKBENCH_PATH="$HOME/.wright_workbench"
WRIGHT_TOOLBOX_PATH="$WRIGHT_WORKBENCH_PATH/.toolbox"
WRIGHT_BIN_PATH="$WRIGHT_WORKBENCH_PATH/bin"

# Check if the WRIGHT_BIN_PATH is already in .zshrc and if the directory exists
if grep -q "export PATH=.*$WRIGHT_BIN_PATH.*" ~/.zshrc && [ -d "$WRIGHT_BIN_PATH" ]; then
    echo "✅ Wright CLI is already configured with WRIGHT_BIN_PATH at $WRIGHT_BIN_PATH."
else
    echo "🔧 Configuring Wright CLI in .zshrc..."

    # Ensure WRIGHT_BIN_PATH directory exists
    echo "🔍 Checking if $WRIGHT_BIN_PATH exists..."

    if [ ! -d "$WRIGHT_BIN_PATH" ]; then
        echo "📁 $WRIGHT_BIN_PATH does not exist. Attempting to create it..."
        
        # Attempt to create the directory and capture success/failure
        if mkdir -p "$WRIGHT_BIN_PATH"; then
            echo "✅ Successfully created $WRIGHT_BIN_PATH."
        else
            echo "❌ Failed to create $WRIGHT_BIN_PATH. Check permissions or available space."
            exit 1
        fi
    else
        echo "✅ $WRIGHT_BIN_PATH already exists. Proceeding..."
    fi

    echo "🔧 Adding Wright CLI setup to your .zshrc file..."
    # Add the Wright bin path and alias to .zshrc with a comment explaining the purpose
    echo -e "\n# Wright CLI Setup\nexport PATH=\"$WRIGHT_BIN_PATH:\$PATH\"\nalias wright=\"$WRIGHT_TOOLBOX_PATH/wright.sh\"" >> ~/.zshrc
    echo "✅ Wright CLI setup successfully added to .zshrc!"

    # Reload .zshrc only if we are in a Zsh session
    if [ -n "$ZSH_VERSION" ]; then
        echo "🔄 Sourcing .zshrc in Zsh..."
        source ~/.zshrc

        # Confirm that $HOME/.wright_workbench/bin is in the PATH variable
        if [[ ":$PATH:" == *":$WRIGHT_BIN_PATH:"* ]]; then
            echo "✅ $WRIGHT_BIN_PATH is now in your PATH."
        else
            echo "❌ Failed to add $WRIGHT_BIN_PATH to your PATH. Please check your .zshrc or reload the shell manually."
        fi
    else
        echo "⚠️ You are not in a Zsh shell. Please run 'source ~/.zshrc' manually if using Zsh."

        # Confirm that $HOME/.wright_workbench/bin is in the PATH variable after user reloads manually
        if [[ ":$PATH:" == *":$WRIGHT_BIN_PATH:"* ]]; then
            echo "✅ $WRIGHT_BIN_PATH is now in your PATH."
        else
            echo "❌ Failed to add $WRIGHT_BIN_PATH to your PATH. Please check your .zshrc or reload the shell manually."
        fi
    fi

    echo "✅ Wright CLI has been configured and is now available as a command!"
fi
