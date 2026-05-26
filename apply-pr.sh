#!/bin/bash

# apply the EE changes from a PR to CE. For any code that fails to apply, .rej files will be created.

# Use the current Portainer worktree when run from one, otherwise prompt for
# the target worktree root.
WORKTREE_BASE="${WORKTREE_BASE:-/Users/aliharris/portainer}"
WORKTREE_NAMES=("portainer-suite" "side-content" "review")

select_worktree_root() {
    local current_root name root

    command -v git >/dev/null 2>&1 || { echo "git is required" >&2; return 1; }

    if current_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
        for name in "${WORKTREE_NAMES[@]}"; do
            if [[ "$current_root" == "$WORKTREE_BASE/$name" ]]; then
                echo "$current_root"
                return 0
            fi
        done
    fi

    echo "Select worktree:" >&2
    select name in "${WORKTREE_NAMES[@]}"; do
        root="$WORKTREE_BASE/$name"

        if git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo "$root"
            return 0
        fi

        echo "Not a valid git worktree: $root" >&2
    done
}

PROJECT_PATH="$(select_worktree_root)" || exit 1

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

# Prompt the user for the PR number to fetch.
read -p "Enter the PR number: " PR_NUMBER

# Define the diff file name based on PR number
DIFF_FILE_NAME="pr-${PR_NUMBER}.diff"

# Create the temporary directory if it doesn't exist
mkdir -p "$TMP_DIR"

# Set the diff file path
DIFF_FILE_PATH="$TMP_DIR/$DIFF_FILE_NAME"

# Run GitHub CLI from the selected source package in the target worktree.
cd "$PROJECT_PATH/$SOURCE_PATH"

# Download the diff file using GitHub CLI
echo "Fetching diff for PR #${PR_NUMBER}..."
gh pr diff ${PR_NUMBER} > "$DIFF_FILE_PATH"

# Check if download is successful
if [ ! -f "$DIFF_FILE_PATH" ] || [ ! -s "$DIFF_FILE_PATH" ]; then
    echo "Error: Failed to fetch the diff for PR #${PR_NUMBER}."
    exit 1
fi

# Apply the diff from the selected worktree root.
cd "$PROJECT_PATH"

echo "Applying diff to the project..."
git apply --reject -p3 --whitespace=fix --directory=$TARGET_PATH "$TMP_DIR/$DIFF_FILE_NAME"

# Check if git apply was successful
if [ $? -eq 0 ]; then
    echo "Diff applied successfully."
else
    echo "Error: Failed to apply the diff."
    exit 1
fi
