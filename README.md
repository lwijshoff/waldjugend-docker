# WordPress Waldjugend Docker Setup

## Introduction

This repository contains everything you need to set up a **WordPress** environment on your host.
It uses Docker and Docker Compose for an easy and reproducible setup.
Please note it was modified to fit the use case of the Deutsche Waldjugend.

If you are just looking to install the theme or the plugin without Docker, check out my other repositories:  
- [waldjugend-theme](https://github.com/lwijshoff/waldjugend-theme)  
- [waldjugend-plugin](https://github.com/lwijshoff/waldjugend-plugin)  

> [!IMPORTANT]  
> The setup in this repository has been tested on:  
> - **OS:** [Ubuntu 25.04 aarch64](https://ubuntu.com/download/server)  
> - **Database:** [MariaDB](https://mariadb.org/download)  
> - **PHP:** [PHP 8.3](https://www.php.net/downloads.php)  
> - **Webserver:** [Apache2](https://httpd.apache.org/download.cgi)  
> - **Hardware:** [Raspberry Pi 5](https://www.raspberrypi.com/products/raspberry-pi-5/) running on a local network.  

---

## Requirements

Before you begin, make sure you have installed:

- [Docker](https://docs.docker.com/get-docker/)  
- [Docker Compose](https://docs.docker.com/compose/install/)  
- [Git](https://git-scm.com/downloads)  

---

## Setup

1. **Clone this repository**
  ```bash
  git clone https://github.com/lwijshoff/waldjugend-docker.git
  cd waldjugend-docker
  ```

2. **Configure WordPress settings**  
  There is a `config.ini` file in the `/rsc` directory. Adjust it as needed for your environment. \
  This file is mounted into the container as PHP configuration (`php.ini` directives, see [php documentation](https://www.php.net/manual/en/ini.list.php))

3. **Run the initialization script**  
  Make the script executable (first time only), then run it:
  ```bash
  chmod +x ./src/init.sh
  ./src/ínit.sh
  ```
  This will:
  - Ask you to set an MySQL admin username and password.
  - Generate a random root password for backend access.
  - Create the required Docker volume `wj_secret_data` and inject the credentials.
  - Run the `docker compose up -d` command.

  > [!CAUTION]  
  > Pick strong, long and random passwords. Weak passwords may allow unauthorized access.

---

## Usage

- ### Access WordPress:  
  Once everything is up and running, wordpress will be available on port `80` (standard http port):  
  ```
  http://localhost
  ```
  Here you can begin with setting up WordPress.

- ### Access phpMyAdmin:
  PhpMyAdmin will be available on port `8080`:  
  ```
  http://localhost:8080
  ```
  Here you can access phpMyAdmin with the credentials you entered before.

  (Or alternatively replace `localhost` with your server’s IP/hostname).

  > [!TIP]  
  > WorPress and phpMyAdmin may not be immediately available while the database is initializing. \
  > You can check the logs with:
  > ```bash
  > docker compose logs -f
  > ```

- ### Stopping containers:
  ```bash
  docker compose down
  ```
  These volumes `wj_wp_data`, `wj_db_data` are persistent, so your data is retained.
  
  If you want to delete these volumes consider running:
  ```bash
  docker compose down -v
  ```
  Running this command will remove the `wj_wp_data` and `wj_db_data` volumes. \
  The `wj_secret_data` volume is not removed, as it contains sensitive credentials such as:

  - `mysql_root_password` - Randomly generated root password used internally by WordPress to connect to MariaDB.
  - `mysql_user` - Admin username for accessing MariaDB through phpMyAdmin.
  - `mysql_password` - Corresponding admin password for phpMyAdmin/MariaDB access.

---

## Notes

- The `wj_secret_data` volume is not removed when running `docker compose down -v`. 
  - This lets you reset containers but keep credentials, so you can restart with `docker compose up -d` without rerunning `./src/init.sh`.
- `config.ini` in `/rsc` is customizable and supports all [php.ini directives](https://www.php.net/manual/en/ini.list.php).  
- This setup is mainly intended for **local development** and **testing**.  
  For production use, consider adding HTTPS, backups, and security hardening.

---

## License

This project is released under the MIT License. See [LICENSE](./LICENSE) for details.
