#!/bin/bash

# WordPress waldjugend-theme Update Script
# Ensure this script is run as root or with sudo.

# Developed by Leonard Wijshoff in 2025
# https://github.com/lwijshoff
# See LICENSE for more information

#!/bin/bash
# Exit on errors
set -e

# Source the config file
source "$(dirname "$0")/config.sh"  # Ensure it's sourced relative to the current script's location

# Derive theme folder name from the repo URL and build the path
THEME_DIR="$TARGET_DIR/wp-content/themes/$(basename $THEME_REPO .git)"

# Go to the theme directory
cd $THEME_DIR

# Fetch the latest tags and releases from GitHub
echo "Fetching tags from the remote repository..."
git fetch --tags

# Get the latest tag (release) from GitHub
LATEST_RELEASE=$(git tag -l | sort -V | tail -n 1)

# Get the current installed version (local tag)
CURRENT_VERSION=$(git describe --tags --abbrev=0)

echo "Current version: $CURRENT_VERSION"
echo "Latest release: $LATEST_RELEASE"

# Check if the local version is the same as the latest release
if [ "$CURRENT_VERSION" != "$LATEST_RELEASE" ]; then
    echo "A new release is available. Updating to version $LATEST_RELEASE..."
    # Pull the latest release (i.e., tag)
    git checkout $LATEST_RELEASE
    git pull origin $LATEST_RELEASE
else
    echo "You are already on the latest release ($LATEST_RELEASE). No update needed."
fi

# Set the proper ownership and permissions
echo "Setting ownership and permissions for the theme..."
sudo chown -R www-data:www-data $THEME_DIR
sudo chmod -R 775 $THEME_DIR

# Print a success message
clear
cat ./assets/ascii-waldjugend-art.txt
NEW_VERSION=$(git describe --tags --abbrev=0)
printf "\nUpdated to version: %s\n" "$VERSION"
printf "\nTheme update complete!\n"
