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
read -p "Enter the PR number: " PR_NUMBER

# Define the diff file name based on PR number
DIFF_FILE_NAME="pr-${PR_NUMBER}.diff"

# Create the temporary directory if it doesn't exist
mkdir -p "$TMP_DIR"

# Set the diff file path
DIFF_FILE_PATH="$TMP_DIR/$DIFF_FILE_NAME"

# Navigate to the source project directory to run GitHub CLI commands
cd "$PROJECT_PATH/$SOURCE_PATH"

# Download the diff file using GitHub CLI
echo "Fetching diff for PR #${PR_NUMBER}..."
gh pr diff ${PR_NUMBER} > "$DIFF_FILE_PATH"

# Check if download is successful
if [ ! -f "$DIFF_FILE_PATH" ] || [ ! -s "$DIFF_FILE_PATH" ]; then
    echo "Error: Failed to fetch the diff for PR #${PR_NUMBER}."
    exit 1
fi

# Return to the project root directory
cd "$PROJECT_PATH"

# Apply the diff to the project
echo "Applying diff to the project..."
git apply --reject -p3 --whitespace=fix --directory=$TARGET_PATH "$TMP_DIR/$DIFF_FILE_NAME"

# Check if git apply was successful
if [ $? -eq 0 ]; then
    echo "Diff applied successfully."
else
    echo "Error: Failed to apply the diff."
    exit 1
fi
