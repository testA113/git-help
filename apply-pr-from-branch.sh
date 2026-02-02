#!/bin/bash

# Port a diff from an existing PR to a new branch.
# This is useful when we need patch releases and we need to apply PRs to both the develop branch and a release branch.
# 
# Assumes that you have created a new branch from another base branch.
# E.g. 
# - I've created a develop PR that doesn't need any more changes, and know the PR number
# - I've made a new branch based on the latest release branch

# Define the project path
PROJECT_PATH="/Users/aliharris/portainer/portainer-suite"

# Define the temporary directory path
TMP_DIR="/Users/aliharris/portainer/tmp"

# Prompt the user for the PR number
read -p "Enter the PR number: " PR_NUMBER

# Define the diff file name based on PR number
DIFF_FILE_NAME="pr-${PR_NUMBER}.diff"

# Create the temporary directory if it doesn't exist
mkdir -p "$TMP_DIR"

# Set the diff file path
DIFF_FILE_PATH="$TMP_DIR/$DIFF_FILE_NAME"

# Navigate to the project root directory to run GitHub CLI commands
cd "$PROJECT_PATH"

# Download the diff file using GitHub CLI
echo "Fetching diff for PR #${PR_NUMBER}..."
gh pr diff ${PR_NUMBER} > "$DIFF_FILE_PATH"

# Check if download is successful
if [ ! -f "$DIFF_FILE_PATH" ] || [ ! -s "$DIFF_FILE_PATH" ]; then
    echo "Error: Failed to fetch the diff for PR #${PR_NUMBER}."
    exit 1
fi

# Ensure we are in the project root directory
cd "$PROJECT_PATH"

# Apply the diff to the entire project (CE and EE)
echo "Applying diff to the project (CE and EE)..."
git apply --reject -p1 --whitespace=fix "$TMP_DIR/$DIFF_FILE_NAME"

# Check if git apply was successful
if [ $? -eq 0 ]; then
    echo "Diff applied successfully."
else
    echo "Error: Failed to apply the diff."
    exit 1
fi
