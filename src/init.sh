#!/bin/bash

set -e

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

TMP_SECRET_DIR="$(mktemp -d)"
ASCII_ART_FILE="$ROOT_DIR/res/ascii-waldjugend-art.txt"
COMPOSE_FILE="$ROOT_DIR/docker-compose.yml"

clear
echo "Welcome to the Waldjugend Docker Setup"
echo

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

# Generate root password
echo "[+] Generating secure MySQL root password..."
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)

# Write secrets to temporary files
echo "$MYSQL_ROOT_PASSWORD" > "$TMP_SECRET_DIR/mysql_root_password"
echo "$MYSQL_USER" > "$TMP_SECRET_DIR/mysql_user"
echo "$MYSQL_PASSWORD" >> "$TMP_SECRET_DIR/mysql_password"

# Create Docker volume if needed
echo "[+] Creating Docker volume 'wj_secret_data'..."
docker volume create wj_secret_data > /dev/null

# Copy secrets into volume
echo "[+] Copying secrets into Docker-managed volume..."
docker run --rm \
  -v wj_secret_data:/run/secrets \
  -v "$TMP_SECRET_DIR":/tmp_secrets:ro \
  alpine \
  sh -c "cp /tmp_secrets/* /run/secrets/ && chmod 0444 /run/secrets/*"

# Remove temp secrets
rm -rf "$TMP_SECRET_DIR"

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

# Show ASCII art
echo
if [ -f "$ASCII_ART_FILE" ]; then
  cat "$ASCII_ART_FILE"
else
  echo "ASCII art file not found: $ASCII_ART_FILE"
fi
echo