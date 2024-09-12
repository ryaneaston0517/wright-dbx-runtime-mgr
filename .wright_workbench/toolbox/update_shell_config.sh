#!/bin/zsh

# Function to check and add/update variables within the Wright CLI block in the shell profile
update_shell_config_block() {
    local KEY=$1
    local VALUE=$2
    local PROFILE_FILE="$HOME/.zshrc"
    local START_COMMENT="## Wright CLI Setup ##"
    local END_COMMENT="## End Wright CLI Setup ##"

    # Check if the Wright CLI block exists
    if grep -q "$START_COMMENT" "$PROFILE_FILE"; then
        # Check if the key exists within the block
        if sed -n "/$START_COMMENT/,/$END_COMMENT/p" "$PROFILE_FILE" | grep -q "$KEY="; then
            # If the key exists but the value doesn't match, update it
            if ! sed -n "/$START_COMMENT/,/$END_COMMENT/p" "$PROFILE_FILE" | grep -q "$KEY=\"$VALUE\""; then
                echo "🔄 Replacing existing $KEY within the Wright CLI block with $VALUE"
                sed -i '' "/$START_COMMENT/,/$END_COMMENT/s|$KEY=.*|$KEY=\"$VALUE\"|" "$PROFILE_FILE"
                echo "✅ $KEY updated to $VALUE in $PROFILE_FILE"
            else
                echo "✅ $KEY is already set correctly in the Wright CLI block in $PROFILE_FILE"
            fi
        else
            # Add the key-value pair if it's not present
            sed -i '' "/$START_COMMENT/a\\
export $KEY=\"$VALUE\"\\
" "$PROFILE_FILE"
            echo "✅ $KEY added to the Wright CLI block in $PROFILE_FILE"
        fi
    else
        # Create the Wright CLI block and add the key-value pair if the block doesn't exist
        echo "🔄 Wright CLI Setup block not found. Adding the block and $KEY."
        printf "\n$START_COMMENT\nexport $KEY=\"$VALUE\"\n$END_COMMENT\n" >> "$PROFILE_FILE"
        echo "✅ Wright CLI Setup block and $KEY added to $PROFILE_FILE"
    fi
}

# Function to add/update aliases in the Wright CLI block
update_shell_config_alias() {
    local ALIAS_NAME=$1
    local ALIAS_VALUE=$2
    local PROFILE_FILE="$HOME/.zshrc"
    local START_COMMENT="## Wright CLI Setup ##"
    local END_COMMENT="## End Wright CLI Setup ##"

    # Check if the Wright CLI Setup block exists
    if grep -q "$START_COMMENT" "$PROFILE_FILE"; then
        # Check if the alias exists within the block
        if sed -n "/$START_COMMENT/,/$END_COMMENT/p" "$PROFILE_FILE" | grep -q "alias $ALIAS_NAME="; then
            echo "✅ Alias $ALIAS_NAME already exists in the Wright CLI block"
        else
            # Add the alias if not present
            sed -i '' "/$START_COMMENT/a\\
alias $ALIAS_NAME='$ALIAS_VALUE'\\
" "$PROFILE_FILE"
            echo "✅ Alias $ALIAS_NAME added to the Wright CLI block"
        fi
    else
        # If the block doesn't exist, create it and add the alias within it
        echo "🔄 Wright CLI Setup block not found. Adding the block and alias $ALIAS_NAME."
        printf "\n$START_COMMENT\nalias $ALIAS_NAME='$ALIAS_VALUE'\n$END_COMMENT\n" >> "$PROFILE_FILE"
        echo "✅ Wright CLI Setup block and alias $ALIAS_NAME added to $PROFILE_FILE"
    fi
}

# Function to update JAVA_HOME
update_shell_config_java() {
    local HOME_PATH="$1"
    echo "🔍 Checking if JAVA_HOME is set correctly..."
    update_shell_config_block "JAVA_HOME" "$HOME_PATH"
}

# Function to update Python aliases
update_shell_config_python() {
    echo "🔍 Checking if Python and pip aliases are set correctly..."
    update_shell_config_alias "python" "python3"
    update_shell_config_alias "pip" "pip3"
}

update_shell_config_scala() {
    local HOME_PATH="$1"
    echo "🔍 Checking if SCALA_HOME is set correctly..."
    update_shell_config_block "SCALA_HOME" "$HOME_PATH"
}

update_shell_config_spark() {
    local HOME_PATH="$1"
    echo "🔍 Checking if SPARK_HOME is set correctly..."
    update_shell_config_block "SPARK_HOME" "$HOME_PATH"
}