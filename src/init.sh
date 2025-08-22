#!/bin/bash

set -e

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

ENV_FILE="$ROOT_DIR/.env"
SECRETS_DIR="$ROOT_DIR/secrets"
ROOT_SECRET_FILE="$SECRETS_DIR/mysql_root_password"
ASCII_ART_FILE="$ROOT_DIR/res/ascii-waldjugend-art.txt"
COMPOSE_FILE="$ROOT_DIR/docker-compose.yml"

clear
echo "Welcome to the Waldjugend Docker Setup"
echo

if [ ! -f "$ENV_FILE" ]; then
  echo "[+] Generating .env file..."

  # Prompt for admin username
  read -p "Enter MySQL admin username [default: admin]: " MYSQL_USER
  MYSQL_USER=${MYSQL_USER:-admin}

  # Prompt for admin password (with confirmation)
  while true; do
    read -s -p "Enter a secure password for MySQL admin user '$MYSQL_USER': " MYSQL_PASSWORD
    echo
    read -s -p "Confirm password: " MYSQL_PASSWORD_CONFIRM
    echo
    if [ "$MYSQL_PASSWORD" = "$MYSQL_PASSWORD_CONFIRM" ]; then
      break
    else
      echo "Passwords do not match. Try again."
    fi
  done

  # Write .env file with comments
  echo "[+] Writing credentials to $ENV_FILE..."
  cat <<EOF > "$ENV_FILE"
# -------------------------
# DATABASE CREDENTIALS
# -------------------------

# Admin user credentials for MySQL
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD
EOF

else
  echo "[*] .env file already exists at $ENV_FILE"
fi

# Create secrets directory if missing
mkdir -p "$SECRETS_DIR"

# Generate root password if not already created
if [ ! -f "$ROOT_SECRET_FILE" ]; then
  echo "[+] Generating secure MySQL root password..."
  openssl rand -base64 32 > "$ROOT_SECRET_FILE"
  chmod 600 "$ROOT_SECRET_FILE"
else
  echo "[*] Root password secret already exists at $ROOT_SECRET_FILE"
fi

# Show ASCII art
echo
if [ -f "$ASCII_ART_FILE" ]; then
  cat "$ASCII_ART_FILE"
else
  echo "ASCII art file not found: $ASCII_ART_FILE"
fi
echo

# Launch docker-compose (v2 or v1)
echo "[*] Starting Docker containers..."

if command -v docker compose &> /dev/null; then
  docker compose -f "$COMPOSE_FILE" up -d
elif command -v docker-compose &> /dev/null; then
  docker-compose -f "$COMPOSE_FILE" up -d
else
  echo "Neither 'docker compose' nor 'docker-compose' is available on your system."
  echo "Please install Docker Compose to proceed:"
  echo "https://docs.docker.com/compose/install/"
  exit 1
fi