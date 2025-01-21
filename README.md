# WordPress and MariaDB Installation Guide

## Introduction

This guide will walk you through the installation of a WordPress website for your own Waldjugend Horst, Landesverband or other purposes.

> [!IMPORTANT]
> The contents of this repository are tested for the installation of a WordPress website on [Ubuntu 24.10](https://ubuntu.com/download/server) with [MariaDB](https://mariadb.org/download) as a database, [php 8.3](https://www.php.net/downloads.php), [Apache2](https://httpd.apache.org/download.cgi) as an http(s) server and a [Raspberry Pi 5](https://www.raspberrypi.com/products/raspberry-pi-5/) as server on a local network. 
> This repository contains an `install.sh` script that will guide you through the installation and may be simpler to use instead of following the guide below.

Table of Contents

- [WordPress and MariaDB Installation Guide](#wordpress-and-mariadb-installation-guide)
  - [Introduction](#introduction)
  - [Using install script](#using-install-script)
  - [Manual installation](#manual-installation)
    - [Setting up MariaDB and Apache2](#setting-up-mariadb-and-apache2)
    - [Installing WordPress](#installing-wordpress)
    - [Setting up WordPress](#setting-up-wordpress)

## Using install script

Clone the repository to your local machine;
```bash
git clone "https://github.com/lwijshoff/waldjugend-installation.git"
```

Cd into the repository folder;
```bash
cd waldjugend-installation
```

Make the install script executable;
```bash
chmod +x install.sh
```

Run the install script;
```bash
sudo ./install.sh
```

## Manual installation

### Setting up MariaDB and Apache2

Some of the steps below are documented without the `sudo` command beforehand, it could be however that it still requires a `sudo`.

Start with updating all of your packages and installing Apache2;
```bash
sudo apt update
sudo apt upgrade
sudo apt install apache2
```

Check if the Apache2 service is running;
```bash
systemctl status apache2
```

Make Apache2 run on system boot;
```bash
systemctl is-enabled apache2
```

Check if Apache2 is running by opening the systems IP in your browser
```bash
ip addr | grep inet
```

Install MariaDB-server and MariaDB-client;
```bash
sudo apt install mariadb-server mariadb-client
```

Check the status of the MariaDB service;
```bash
sudo systemctl status mariadb.service
```

Make MariaDB run on system boot;
```bash
sudo systemctl is-enabled mariadb.service
```

Secure MariaDB;
```bash
sudo mariadb-secure-installation
```

> For older versions of Ubuntu this command may be;
```bash
sudo mysql_secure_installation
```

Go trough the setup, I setup the installation with the following answer order;
```
N, N, Y, Y, Y, Y
```

> [!IMPORTANT]
> When prompted to give a password for the database, generate a [strong password](https://edu.gcfglobal.org/en/internetsafety/creating-strong-passwords/1/) only the database manager knows!
> The password that you generate here is used to access the database via [CLI](https://www.google.com/search?q=CLI&client=firefox-b-d&sca_esv=741dc4f98c90c9c4&ei=jDqOZ5elHJGpxc8P9q6SkAE&ved=0ahUKEwiXm4fnn4SLAxWRVPEDHXaXBBIQ4dUDCBA&uact=5&oq=CLI&gs_lp=Egxnd3Mtd2l6LXNlcnAiA0NMSTIKEAAYgAQYQxiKBTIKEAAYgAQYQxiKBTILEC4YgAQYsQMYgwEyBRAuGIAEMhAQABiABBixAxhDGIMBGIoFMgsQABiABBixAxiDATILEC4YgAQY0QMYxwEyCBAAGIAEGLEDMgoQABiABBhDGIoFMgsQLhiABBjHARivAUifCVDKA1jDBnABeAGQAQCYAWKgAY8CqgEBM7gBA8gBAPgBAZgCBKACqgLCAgoQABiwAxjWBBhHwgINEAAYgAQYsAMYQxiKBcICDhAAGLADGOQCGNYE2AEBwgIZEC4YgAQYsAMY0QMYQxjHARjIAxiKBdgBAcICExAuGIAEGLADGEMYyAMYigXYAQHCAhEQLhiABBixAxjRAxiDARjHAcICDhAAGIAEGLEDGIMBGIoFwgIREC4YgAQYsQMYgwEYxwEYrwHCAggQLhiABBixA5gDAIgGAZAGEboGBggBEAEYCZIHAzIuMqAHjCs&sclient=gws-wiz-serp), more about that in the next step.

Check if you an now finally connect to the database;
```bash
sudo mysql -u root
```

Type the following to exit;
```bash
exit
```

Install php;
```bash
sudo apt install php libapache2-mod-php php-mysql
```

Restart the Apache2 service;
```bash
sudo systemctl restart apache2
```

Create `info.php` file;

> [!TIP]
> You can use multiple text editors for this, such as `vim` or `nano`, I'll be using vim throughout the documentation.

```bash
sudo apt-get install vim
sudo vim /var/www/html/info.php
```

Add the following content to the `info.php` file;
```php
<?php
 phpinfo();
?> 
```

Exit the text editor by pressing `CTRL + C` and typing `:wq`
Now go to `systemipaddress/info.php` in your browser and it should load the php info page;

Install phpmyadmin;
```bash
sudo apt install phpmyadmin
```

When prompted; select Apache2 and select yes;
Now generate a [strong password](https://edu.gcfglobal.org/en/internetsafety/creating-strong-passwords/1/) only the database manager knows, for phpmyadmin;

> [!TIP]
> You can later log into `systemipaddress/phpmyadmin` using the user: `phpmyadmin` and then your new securely generated password.

Confirm your password;
Restart Apache2 service;
```bash
sudo systemctl reload apache2.service
```

Open phpmyadmin (`systemipaddress/phpmyadmin`) in your browser;

> [!NOTE]
> If you got an error 404 in your browser, then you need to use `nano` to configure `apache2.conf` to work with phpmyadmin.

Install nano if not already installed;
```bash
sudo apt install nano
```

Configure `apache2.conf`;
```bash
sudo nano /etc/apache2/apache2.conf
```

Include the following line at the bottom of the file, then save and exit;
```bash
Include /etc/phpmyadmin/apache.conf
```

Restart Apache2 service;
```bash
sudo systemctl reload apache2.service
```

Open phpmyadmin (`systemipaddress/phpmyadmin`) in your browser;
Make sure it does not return a 404, and log in using the user: `phpmyadmin` and the password you previously created;

Configure firewall and allow http and https;
```bash
sudo ufw status
sudo ufw enable
```

Allow OpenSSH in firewall;
```bash
sudo ufw allow ssh
```

Allow http and https;
```bash
sudo ufw allow 'Apache Full'
```

### Installing WordPress

Download WordPress
```bash
sudo wget -c http://wordpress.org/latest.tar.gz
```

Extract the gzip file;
```bash
sudo tar -xzvf latest.tar.gz
```

Copy WordPress to the new waldjugend directory in your html directory;
```bash
sudo cp -R wordpress /var/www/html/waldjugend
```

Edit the permissions of the directory;
```bash
sudo chown -R www-data:www-data /var/www/html/waldjugend
sudo chmod -R 775 /var/www/html/waldjugend
```

Create a database for the website;
```bash
sudo mysql -u root -p
```

Log in and execute the following command;
```mysql
CREATE DATABASE waldjugend;
```

Create an (admin) user with a  [strong password](https://edu.gcfglobal.org/en/internetsafety/creating-strong-passwords/1/) for the database;
```mysql
CREATE USER 'admin'@'%' IDENTIFIED BY 'password';
```

Grant the (admin) user privileges on all databases;
```mysql
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;
```

Log into phpmyadmin (`systemipaddress/phpmyadmin`) on your browser with the new (admin) user;

Flush privileges;
```mysql
FLUSH PRIVILEGES;
exit;
```

Create wp-config file;
```bash
cd wordpress
sudo mv wp-config-sample.php wp-config.php
sudo vim wp-config.php
```

Go through the config and adjust as needed, the following options are a necessity;
```php
DB_NAME = waldjugend
DB_USER = admin
DB_PASSWORD = password
```

Exit the text editor by pressing `CTRL + C` and typing `:wq`
Confirm your changes;
```bash
cat wp-config.php
```

Edit `waldjugend.conf`;
```bash
sudo vim /etc/apache2/sites-available/waldjugend.conf
```

Paste in the following;
```conf
<VirtualHost *:80>
 ServerName waldjugend
 ServerAdmin admin@localhost
 DocumentRoot /var/www/html/waldjugend
 ErrorLog ${APACHE_LOG_DIR}/error.log
 CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost> 
```

Exit the text editor by pressing `CTRL + C` and typing `:wq`
Confirm your changes;
```bash
cat /etc/apache2/sites-available/waldjugend.conf
```

Check your Apache configuration;
```bash
apachectl -t
```

> [!NOTE]
> If you get an error saying that Apache2 could not reliably determine the servers's fully qualified domain name, then do the following;

```bash
sudo vim /etc/apache2/apache2.conf
```

Add the following; to the bottom of the document;
```conf
# Add ServerName
ServerName localhost
```

Exit the text editor by pressing `CTRL + C` and typing `:wq`
Check your Apache configuration again;
```bash
apachectl -t
```

It should now just say `Syntax OK`
Enable the site;
```bash
sudo a2ensite waldjugend.conf
```

Reload Apache2;
```bash
sudo systemctl reload apache2
```

Disable the default site;
```bash
sudo a2dissite 000-default.conf
```

Restart Apache2;
```bash
sudo service apache2 restart
```

Edit `php.ini`;
Depending on your php installation this path can be different!
```bash
sudo vim /etc/php/8.3/apache2/php.ini
```

Scroll down and adjust the following options;
The following are just recommendations but can be larger values depending on how much you wish to allow the user to be able to upload to your site.
```ini
upload_max_filesize = 128M
post_max_size = 128M
max_execution_time = 300
```

Exit the text editor by pressing `CTRL + C` and typing `:wq`

### Setting up WordPress

Open your browser enter the systems IP in your browser and follow the WordPress instructions in your browser;

> [!TIP]
> If the apache2 page still appears but not WordPress, it could be due to possible errors made in `/etc/apache2/sites-available/waldjugend.conf` 
> You can confirm this error by running the `apachectl configtest` command in your [CLI](https://www.google.com/search?q=CLI&client=firefox-b-d&sca_esv=741dc4f98c90c9c4&ei=jDqOZ5elHJGpxc8P9q6SkAE&ved=0ahUKEwiXm4fnn4SLAxWRVPEDHXaXBBIQ4dUDCBA&uact=5&oq=CLI&gs_lp=Egxnd3Mtd2l6LXNlcnAiA0NMSTIKEAAYgAQYQxiKBTIKEAAYgAQYQxiKBTILEC4YgAQYsQMYgwEyBRAuGIAEMhAQABiABBixAxhDGIMBGIoFMgsQABiABBixAxiDATILEC4YgAQY0QMYxwEyCBAAGIAEGLEDMgoQABiABBhDGIoFMgsQLhiABBjHARivAUifCVDKA1jDBnABeAGQAQCYAWKgAY8CqgEBM7gBA8gBAPgBAZgCBKACqgLCAgoQABiwAxjWBBhHwgINEAAYgAQYsAMYQxiKBcICDhAAGLADGOQCGNYE2AEBwgIZEC4YgAQYsAMY0QMYQxjHARjIAxiKBdgBAcICExAuGIAEGLADGEMYyAMYigXYAQHCAhEQLhiABBixAxjRAxiDARjHAcICDhAAGIAEGLEDGIMBGIoFwgIREC4YgAQYsQMYgwEYxwEYrwHCAggQLhiABBixA5gDAIgGAZAGEboGBggBEAEYCZIHAzIuMqAHjCs&sclient=gws-wiz-serp).

If you did everything correctly, you can now continue with the [design configuration](https://waldjugend-kleve.de/design-konfiguration/).