#!/bin/bash

# Set the path to the source project
SOURCE_PATH="/Users/aliharris/portainer/portainer-ee"

# Set the path to the destination project
DEST_PATH="/Users/aliharris/portainer/portainer"

# Prompt the user to enter the commit SHA1 hash
read -p "Enter the commit SHA1 hash: " COMMIT_SHA1

# Generate the patch file from the source project
PATCH_FILE=$(git -C $SOURCE_PATH format-patch $COMMIT_SHA1^..$COMMIT_SHA1)

# Apply the patch file to the destination project
git -C $DEST_PATH am -3 --reject --whitespace=fix $SOURCE_PATH/$PATCH_FILE

# Clean up the patch file
rm $SOURCE_PATH/$PATCH_FILE
