CREATE DATABASE IF NOT EXISTS `pma_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant access to root
GRANT ALL PRIVILEGES ON `pma_db`.* TO 'root'@'%';
FLUSH PRIVILEGES;

-- Create the necessary tables for phpMyAdmin
USE `pma_db`;
SOURCE /usr/share/phpmyadmin/sql/create_tables.sql;