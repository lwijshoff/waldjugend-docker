#!/bin/bash

# WordPress waldjugend-theme Installation Script
# Ensure this script is run as root or with sudo.

# Developed by Leonard Wijshoff in 2025
# https://github.com/lwijshoff
# See LICENSE for more information

# Exit on errors
set -e

# Source the config file
source "$(dirname "$0")/config.sh"  # Ensure it's sourced relative to the current script's location

# Derive theme folder name from the repo URL and build the path
THEME_DIR="$TARGET_DIR/wp-content/themes/$(basename $THEME_REPO .git)"

# Extract the owner and repo name from the GitHub URL
REPO_OWNER=$(echo $THEME_REPO | sed -E 's/https:\/\/github.com\/([^\/]+)\/([^\/]+)\.git/\1/')
REPO_NAME=$(echo $THEME_REPO | sed -E 's/https:\/\/github.com\/([^\/]+)\/([^\/]+)\.git/\2/')

# Get the latest release tag using GitHub API
LATEST_RELEASE=$(curl --silent "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest" | jq -r .tag_name)

# Clone the latest release into the theme directory
echo "Cloning the latest release ($LATEST_RELEASE) into $THEME_DIR..."
sudo git clone --branch "$LATEST_RELEASE" --single-branch $THEME_REPO $THEME_DIR

# Set the proper ownership and permissions
echo "Setting ownership and permissions for the theme..."
sudo chown -R www-data:www-data $THEME_DIR
sudo chmod -R 775 $THEME_DIR

# Print a success message
printf "Theme installation complete!\n"