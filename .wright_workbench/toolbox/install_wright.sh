#!/bin/bash

# Define the lines to add to .zshrc
ZSHRC_CONFIG="
# Wright CLI Setup
export WRIGHT_DIR=\"\$HOME/.workbench/.toolbox\"
[[ -s \"\$WRIGHT_DIR/wright.sh\" ]] && alias wright=\"\$WRIGHT_DIR/wright.sh\"
"

# Check if the .zshrc file already has the Wright CLI setup
if grep -Fxq "Wright CLI Setup" ~/.zshrc
then
    echo "Wright CLI is already configured in .zshrc"
else
    echo "Configuring Wright CLI in .zshrc..."
    echo "$ZSHRC_CONFIG" >> ~/.zshrc
    echo "Wright CLI has been added to your .zshrc"
fi

# Source the .zshrc to apply the changes immediately
source ~/.zshrc
echo "Wright CLI is now available as a command!"
