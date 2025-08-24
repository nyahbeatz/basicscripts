#!/bin/bash
# --- Script to install a Cloudflare Tunnel (mobilelab) ---
# This script is for Debian/Ubuntu-based Linux distributions, x86 and arm64.
# Run this script with administrative privileges (e.g., sudo ./script.sh).

# ...existing code...

set -e  # Exit on error

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root. Please use 'sudo'." 1>&2
   exit 1
fi

# Check for required commands
for cmd in curl tee; do
    if ! command -v $cmd &>/dev/null; then
        echo "Error: $cmd is not installed." >&2
        exit 1
    fi
done

# Update package lists
echo "Updating system package lists..."
apt update

# Add cloudflare gpg key
echo "Adding Cloudflare GPG key..."
mkdir -p --mode=0755 /usr/share/keyrings
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

# Add this repo to your apt repositories
echo "Adding Cloudflare repository..."
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main' | tee /etc/apt/sources.list.d/cloudflared.list

# Install cloudflared
echo "Installing cloudflared..."
apt update && apt install cloudflared -y

# Check if cloudflared installed successfully
if ! command -v cloudflared &>/dev/null; then
    echo "cloudflared installation failed." >&2
    exit 1
fi

# Create a new tunnel
echo "Creating a new Cloudflare Tunnel..."

# Automatically run your tunnel whenever your machine starts
# Prompt for tunnel token
read -p "Enter your Cloudflare Tunnel token: " TUNNEL_TOKEN
cloudflared service install "$TUNNEL_TOKEN"
echo "Cloudflare Tunnel installation complete."