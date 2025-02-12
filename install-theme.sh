#!/bin/bash

# WordPress waldjugend-theme Installation Script
# Ensure this script is run as root or with sudo.

# Developed by Leonard Wijshoff in 2025
# https://github.com/lwijshoff
# See LICENSE for more information

# Exit on errors
set -e

# Save the directory where the script was executed from
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source the config file
source "$SCRIPT_DIR/config.sh"  # Ensure it's sourced relative to the current script's location

# Derive theme folder name from the repo URL and build the path
THEME_DIR="$TARGET_DIR/wp-content/themes/$(basename $THEME_REPO .git)"

# Clone the "master" branch of the theme repository into the themes directory
echo "Cloning the 'master' branch into $THEME_DIR..."
sudo git clone --branch master --single-branch $THEME_REPO $THEME_DIR

# Set the proper ownership and permissions
echo "Setting ownership and permissions for the theme..."
sudo chown -R www-data:www-data $THEME_DIR
sudo chmod -R 775 $THEME_DIR

# Print success message
clear
cat "$SCRIPT_DIR/assets/ascii-waldjugend-art.txt"
printf "Theme installation complete!\n"