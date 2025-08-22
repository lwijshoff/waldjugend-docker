# WordPress Waldjugend Docker Installation

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

## Installation

1. **Clone this repository**
  ```bash
  git clone https://github.com/lwijshoff/waldjugend-docker.git
  cd waldjugend-docker
  ```

2. **Configure environment variables**  
  Rename the example `.env` file and adjust it to your needs:
  ```bash
  mv .env.example .env
  ```
  Edit `.env` with your preferred editor (database name, user, password, ports, etc.).

  > [!CAUTION]  
  > Pick strong, long and random passwords, as they may otherwise grant unauthorized people access to your database. 

3. **Configure WordPress settings**  
  There is a `config.ini` file in the `/rsc` directory. Adjust it as needed for your environment.

4. **Start the containers**  
  ```bash
  docker compose up -d
  ```
  This will start WordPress, the database, and other required services in the background.

> [!TIP]  
> It might take some time for the database to get up and running. 

---

## Usage

- **Access WordPress**:  
  Once everything is running, open your browser and go to:  
  ```
  http://localhost
  ```
  (or replace `localhost` with your server’s IP/hostname).

- **Stop containers**:  
  ```bash
  docker compose down
  ```
  These volumes are persistent, so your data is retained. Unless you delete the `wordpress_data` and `db_data` volumes.

- **View logs**:  
  ```bash
  docker compose logs -f
  ```

---

## Notes

- Use `.env` to customize **database credentials**.  
- `config.ini` in `/rsc` [contains php.ini directives](https://www.php.net/manual/en/ini.list.php).  
- This setup is mainly intended for **local development** and **testing**.  
  For production use, consider adding HTTPS, backups, and security hardening.

---

## License

This project is released under the MIT License. See [LICENSE](./LICENSE) for details.
