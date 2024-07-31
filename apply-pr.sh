#!/bin/bash

# Define the project path
PROJECT_PATH="/Users/aliharris/portainer/portainer"

# Define the temporary directory path
TMP_DIR="/Users/aliharris/portainer/tmp"

# Prompt the user for the URL of the diff file
read -p "Enter the URL of the diff file: " DIFF_URL

# Extract the diff file name from the URL
DIFF_FILE_NAME=$(basename "$DIFF_URL")

# Create the temporary directory if it doesn't exist
mkdir -p "$TMP_DIR"

# Change to the temporary directory
cd "$TMP_DIR"

# Download the diff file
echo "Downloading diff file from $DIFF_URL..."
curl "$DIFF_URL" -o "$DIFF_FILE_NAME"

# Check if download is successful
if [ ! -f "$DIFF_FILE_NAME" ]; then
    echo "Error: Failed to download the diff file."
    exit 1
fi

# Apply the diff to the project
echo "Applying diff to the project..."
cd "$PROJECT_PATH"
git apply --reject --whitespace=fix "$TMP_DIR/$DIFF_FILE_NAME"

# Check if git apply was successful
if [ $? -eq 0 ]; then
    echo "Diff applied successfully."
else
    echo "Error: Failed to apply the diff."
    exit 1
fi
