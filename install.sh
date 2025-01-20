#!/bin/bash

# WordPress and MariaDB Installation Script
# Ensure this script is run as root or with sudo.

# Developed by Leonard Wijshoff in 2025
# https://github.com/lwijshoff
# See LICENSE for more information

# Exit on errors
set -e

# Update and upgrade packages
echo "Updating packages..."
sudo apt update && sudo apt upgrade -y

# Install Apache2
echo "Installing Apache2..."
sudo apt install -y apache2

# Enable Apache2 on startup
sudo systemctl enable apache2
sudo systemctl start apache2

# Install MariaDB
echo "Installing MariaDB..."
sudo apt install -y mariadb-server mariadb-client

# Enable and secure MariaDB
sudo systemctl enable mariadb
sudo systemctl start mariadb
echo "Securing MariaDB..."
sudo mariadb-secure-installation

# Install PHP and required modules
echo "Installing PHP and modules..."
sudo apt install -y php libapache2-mod-php php-mysql

# Restart Apache2 service
echo "Restarting Apache2..."
sudo systemctl restart apache2

# Create PHP info page
echo "Creating PHP info page..."
echo "<?php
 phpinfo();
?>" | sudo tee /var/www/html/info.php

# Install phpMyAdmin
echo "Installing phpMyAdmin..."
sudo apt install -y phpmyadmin

# Configure Apache for phpMyAdmin
echo "Including phpMyAdmin configuration in Apache..."
echo "Include /etc/phpmyadmin/apache.conf" | sudo tee -a /etc/apache2/apache2.conf
sudo systemctl reload apache2

# Configure firewall
echo "Configuring firewall..."
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 'Apache Full'

# Download and set up WordPress
echo "Downloading WordPress..."
wget -c http://wordpress.org/latest.tar.gz

echo "Extracting WordPress..."
tar -xzvf latest.tar.gz

TARGET_DIR="/var/www/html/waldjugend"
echo "Setting up WordPress in $TARGET_DIR..."
sudo mv wordpress $TARGET_DIR
sudo chown -R www-data:www-data $TARGET_DIR
sudo chmod -R 775 $TARGET_DIR

# Prompt user for database credentials
echo "Setting up MariaDB for WordPress..."
default_db="waldjugend"
read -p "Enter the WordPress database name [default: $default_db]: " DB_NAME
DB_NAME=${DB_NAME:-waldjugend}
default_user="admin"
read -p "Enter the WordPress database user [default: $default_user]: " DB_USER
DB_USER=${DB_USER:-$default_user}
read -sp "Enter the WordPress database password: " DB_PASS
echo

# Create WordPress database and user
sudo mysql -e "CREATE DATABASE ${DB_NAME};"
sudo mysql -e "CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'%' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"

# Configure WordPress
echo "Configuring WordPress..."
sudo mv $TARGET_DIR/wp-config-sample.php $TARGET_DIR/wp-config.php
sudo sed -i "s/database_name_here/${DB_NAME}/" $TARGET_DIR/wp-config.php
sudo sed -i "s/username_here/${DB_USER}/" $TARGET_DIR/wp-config.php
sudo sed -i "s/password_here/${DB_PASS}/" $TARGET_DIR/wp-config.php

# Set up Apache virtual host using variables
echo "Setting up Apache virtual host..."
VHOST_CONF="/etc/apache2/sites-available/waldjugend.conf"
echo "<VirtualHost *:80>
    ServerName $DB_NAME
    ServerAdmin $DB_USER@localhost
    DocumentRoot $TARGET_DIR
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee $VHOST_CONF

sudo apachectl -t
sudo a2ensite waldjugend.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2

# Add ServerName to Apache configuration
echo "Adding ServerName localhost to Apache configuration..."
echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
sudo systemctl reload apache2

# Adjust PHP configuration
PHP_INI="/etc/php/$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')/apache2/php.ini"
echo "Updating PHP configuration in $PHP_INI..."
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" $PHP_INI
sudo sed -i "s/post_max_size = .*/post_max_size = 128M/" $PHP_INI
sudo sed -i "s/max_execution_time = .*/max_execution_time = 300/" $PHP_INI
sudo systemctl restart apache2

# Finished Installation message
clear
cat ascii-text-art.txt
printf "\nInstallation complete!\n"
printf "Open your browser and go to http://$(hostname -I | cut -d' ' -f1) to complete the WordPress setup.\n"