#!/bin/bash

# Set the paths to both directories
PORTAINER_PATH="/Users/aliharris/portainer/portainer-suite"
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

# Generate the patch file from the source project
PATCH_FILE=$(git -C $PORTAINER_PATH format-patch $COMMIT_SHA1^..$COMMIT_SHA1)

# Apply the patch file to the destination project
cd $PORTAINER_PATH
git -C $DEST_PATH am -p3 --directory=$DEST_PATH --reject --whitespace=fix $PORTAINER_PATH/$PATCH_FILE

# Clean up the patch file
rm $PORTAINER_PATH/$PATCH_FILE