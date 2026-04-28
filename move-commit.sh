#!/bin/bash

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

PORTAINER_PATH="$(select_worktree_root)" || exit 1
PORTAINER_CE_PATH="package/server-ce"
PORTAINER_EE_PATH="package/server-ee"

# Function to prompt for source and destination
select_source_dest() {
    echo "Select the source project:"
    select SOURCE in "portainer" "portainer-ee"; do
        case $SOURCE in
            portainer) 
                DEST_PATH=$PORTAINER_EE_PATH
                break;;
            portainer-ee) 
                DEST_PATH=$PORTAINER_CE_PATH
                break;;
        esac
    done
    echo "Source: $SOURCE"
    echo "Destination: $([ "$SOURCE" == "portainer" ] && echo "portainer-ee" || echo "portainer")"
}

# Call the function to set DEST_PATH
select_source_dest

# Prompt the user to enter the commit SHA1 hash
read -p "Enter the commit SHA1 hash: " COMMIT_SHA1

# Generate the patch file from the selected worktree.
PATCH_FILE=$(git -C $PORTAINER_PATH format-patch $COMMIT_SHA1^..$COMMIT_SHA1)

# Apply the patch file to the destination package in the selected worktree.
cd $PORTAINER_PATH
git -C $DEST_PATH am -p3 --directory=$DEST_PATH --reject --whitespace=fix $PORTAINER_PATH/$PATCH_FILE

# Clean up the patch file
rm $PORTAINER_PATH/$PATCH_FILE