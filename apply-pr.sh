#!/bin/bash

# Define the project path
PROJECT_PATH="/Users/aliharris/portainer/portainer-suite"

# Define the temporary directory path
TMP_DIR="/Users/aliharris/portainer/tmp"

# Define the portainer CE and EE paths
PORTAINER_CE_PATH="package/server-ce"
PORTAINER_EE_PATH="package/server-ee"

# Function to prompt for source project
select_source_project() {
    echo "Select the source project:"
    select SOURCE in "portainer" "portainer-ee"; do
        case $SOURCE in
            portainer) 
                SOURCE_PATH=$PORTAINER_CE_PATH
                TARGET_PATH=$PORTAINER_EE_PATH
                break;;
            portainer-ee) 
                SOURCE_PATH=$PORTAINER_EE_PATH
                TARGET_PATH=$PORTAINER_CE_PATH
                break;;
        esac
    done
    echo "Source project: $SOURCE"
    echo "Target project: $([ "$SOURCE" == "portainer" ] && echo "portainer-ee" || echo "portainer")"
}

# Call the function to set SOURCE_PATH and TARGET_PATH
select_source_project

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
git apply --reject -p3 --whitespace=fix --directory=$TARGET_PATH "$TMP_DIR/$DIFF_FILE_NAME"

# Check if git apply was successful
if [ $? -eq 0 ]; then
    echo "Diff applied successfully."
else
    echo "Error: Failed to apply the diff."
    exit 1
fi
