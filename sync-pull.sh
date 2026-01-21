#!/bin/bash
set -e

# Config
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_rsa}"
TARGET_DIR="$HOME/.claude"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
ENCRYPTED_FILE="$REPO_DIR/projects.zip.enc"
TMP_ZIP="/tmp/claude-projects-$$.zip"

# Check SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH key not found at $SSH_KEY"
    echo "Set SSH_KEY env var to your private key path"
    exit 1
fi

echo "Pulling from git..."
cd "$REPO_DIR"
git pull origin main

# Check encrypted file exists
if [ ! -f "$ENCRYPTED_FILE" ]; then
    echo "Error: No encrypted file found: $ENCRYPTED_FILE"
    exit 1
fi

# Derive encryption key from SSH key (SHA-256 hash)
KEY=$(sha256sum "$SSH_KEY" | cut -d' ' -f1)

echo "Decrypting..."
openssl enc -aes-256-cbc -d -salt -pbkdf2 -in "$ENCRYPTED_FILE" -out "$TMP_ZIP" -pass "pass:$KEY"

echo "Extracting to $TARGET_DIR..."
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"
rm -rf projects
unzip -q "$TMP_ZIP"
rm "$TMP_ZIP"

echo "Done! Projects synced to $TARGET_DIR/projects"
