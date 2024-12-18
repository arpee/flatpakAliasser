#!/bin/bash

# Define paths
BASHRC="$HOME/.bashrc"
BASHRC_D="$HOME/.bashrc.d"
FLATPAK_ALIASES_FILE="$BASHRC_D/flatpakaliases"

# Create .bashrc.d directory if it doesn't exist
if [ ! -d "$BASHRC_D" ]; then
    echo "Creating $BASHRC_D directory..."
    mkdir -p "$BASHRC_D"
fi

# Check if .bashrc sources .bashrc.d and add the code if missing
SOURCE_CODE="if [ -d \"\$HOME/.bashrc.d\" ]; then for file in \"\$HOME/.bashrc.d/\"*; do [ -r \"\$file\" ] && source \"\$file\"; done; fi"

if ! grep -Fxq "$SOURCE_CODE" "$BASHRC"; then
    echo "Adding sourcing code for .bashrc.d to $BASHRC..."
    echo "" >> "$BASHRC"
    echo "# Source all files in ~/.bashrc.d" >> "$BASHRC"
    echo "$SOURCE_CODE" >> "$BASHRC"
fi

# Clear the flatpakaliases file or create it if it doesn't exist
if [ -f "$FLATPAK_ALIASES_FILE" ]; then
    echo "Clearing existing flatpakaliases file..."
    > "$FLATPAK_ALIASES_FILE"
else
    echo "Creating flatpakaliases file..."
    touch "$FLATPAK_ALIASES_FILE"
fi

# Generate aliases for all Flatpak applications
echo "Generating Flatpak aliases..."
flatpak-spawn --host flatpak list --columns=name,application | tail -n +2 | while IFS=$'\t' read -r app_name app_id; do
    # Convert app name to a sanitized alias
    alias_name=$(echo "$app_name" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:][:punct:]')

    # Generate the alias command
    alias_command="alias $alias_name='flatpak run $app_id'"

    # Add the alias to the flatpakaliases file
    echo "$alias_command" >> "$FLATPAK_ALIASES_FILE"
done

# Source/reload .bashrc to make the aliases current
echo "Reloading .bashrc to apply changes..."
source "$BASHRC"

echo "Flatpak aliases have been generated and applied. Enjoy!"
