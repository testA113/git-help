#!/bin/bash

# Set the paths to both projects
PORTAINER_PATH="/Users/aliharris/portainer/portainer"
PORTAINER_EE_PATH="/Users/aliharris/portainer/portainer-ee"

# Function to prompt for source and destination
select_source_dest() {
    echo "Select the source project:"
    select SOURCE in "portainer" "portainer-ee"; do
        case $SOURCE in
            portainer) 
                SOURCE_PATH=$PORTAINER_PATH
                DEST_PATH=$PORTAINER_EE_PATH
                break;;
            portainer-ee) 
                SOURCE_PATH=$PORTAINER_EE_PATH
                DEST_PATH=$PORTAINER_PATH
                break;;
        esac
    done
    echo "Source: $SOURCE"
    echo "Destination: $([ "$SOURCE" == "portainer" ] && echo "portainer-ee" || echo "portainer")"
}

# Call the function to set SOURCE_PATH and DEST_PATH
select_source_dest

# Prompt the user to enter the commit SHA1 hash
read -p "Enter the commit SHA1 hash: " COMMIT_SHA1

# Generate the patch file from the source project
PATCH_FILE=$(git -C $SOURCE_PATH format-patch $COMMIT_SHA1^..$COMMIT_SHA1)

# Apply the patch file to the destination project
git -C $DEST_PATH am -3 --reject --whitespace=fix $SOURCE_PATH/$PATCH_FILE

# Clean up the patch file
rm $SOURCE_PATH/$PATCH_FILE