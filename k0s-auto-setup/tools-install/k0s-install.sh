#!/bin/bash

# k0sctl Installation Script
# This script installs k0sctl, a tool for managing k0s clusters.

set -e

# --- Get Download URL ---
API_URL="https://api.github.com/repos/k0sproject/k0sctl/releases/latest"
LATEST_RELEASE_INFO=$(curl -s "$API_URL")

DOWNLOAD_URL=$(echo "$LATEST_RELEASE_INFO" | jq -r '.assets[] | select(.name | test("linux-amd64$")) | .browser_download_url')

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Error: Could not determine k0sctl download URL from GitHub API." >&2
  exit 1
fi

# --- Download and Install ---
echo "Installing k0sctl to /usr/local/bin... (sudo password may be required)"
curl -sSL "$DOWNLOAD_URL" | sudo tee /usr/local/bin/k0sctl >/dev/null
sudo chmod +x /usr/local/bin/k0sctl

# --- Verify ---
echo -e "\n✅ k0sctl installed successfully."
k0sctl version