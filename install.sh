#!/bin/bash
set -e

# UPDATE THIS: Replace with your actual GitHub username and repo
DOWNLOAD_URL="https://github.com/jaideepsingh/starter-pack/releases/latest/download/spl-starter-pack.zip"
INSTALL_DIR="$HOME/Desktop"

echo ""
echo "SPL Starter Pack Installer (External)"
echo "======================================"
echo ""

# Get password
PASSWORD="${STARTER_PWD:-}"
if [ -z "$PASSWORD" ]; then
  if [ -t 0 ]; then
    # Running interactively
    read -sp "Enter access password: " PASSWORD
    echo ""
  elif [ -e /dev/tty ]; then
    # Piped but tty available
    read -sp "Enter access password: " PASSWORD < /dev/tty
    echo "" > /dev/tty
  else
    echo "Error: No password provided. Set STARTER_PWD environment variable:"
    echo "  STARTER_PWD=<password> curl -fsSL ... | bash"
    exit 1
  fi
fi

if [ -z "$PASSWORD" ]; then
  echo "Error: Password required"
  exit 1
fi

# Download
echo "Downloading..."
TEMP_ZIP=$(mktemp)
if ! curl -fsSL "$DOWNLOAD_URL" -o "$TEMP_ZIP"; then
  rm -f "$TEMP_ZIP"
  echo ""
  echo "Error: Download failed. Release may have expired or been removed."
  exit 1
fi

# Extract with password
echo "Extracting..."
if [ -d "$INSTALL_DIR/spl-starter-pack" ]; then
  echo "Removing existing installation..."
  rm -rf "$INSTALL_DIR/spl-starter-pack"
fi
if ! unzip -q -P "$PASSWORD" "$TEMP_ZIP" -d "$INSTALL_DIR"; then
  rm -f "$TEMP_ZIP"
  echo ""
  echo "Error: Invalid password or corrupted archive"
  exit 1
fi
rm -f "$TEMP_ZIP"

# Run setup
echo "Running setup..."
"$INSTALL_DIR/spl-starter-pack/setup"
