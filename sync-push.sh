#!/bin/bash
set -e

# Config
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_rsa}"
SOURCE_DIR="$HOME/.claude/projects"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
ENCRYPTED_FILE="$REPO_DIR/projects.zip.enc"
TMP_ZIP="/tmp/claude-projects-$$.zip"

# Check SSH key exists
if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH key not found at $SSH_KEY"
    echo "Set SSH_KEY env var to your private key path"
    exit 1
fi

# Check source exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory not found: $SOURCE_DIR"
    exit 1
fi

# Derive encryption key from SSH key (SHA-256 hash)
KEY=$(sha256sum "$SSH_KEY" | cut -d' ' -f1)

echo "Zipping $SOURCE_DIR..."
cd "$HOME/.claude"
zip -rq "$TMP_ZIP" projects

echo "Encrypting..."
openssl enc -aes-256-cbc -salt -pbkdf2 -in "$TMP_ZIP" -out "$ENCRYPTED_FILE" -pass "pass:$KEY"
rm "$TMP_ZIP"

echo "Pushing to git..."
cd "$REPO_DIR"
git add projects.zip.enc
git commit -m "sync: $(date '+%Y-%m-%d %H:%M:%S')" || echo "Nothing to commit"
git push origin main

echo "Done! Encrypted sync pushed."
