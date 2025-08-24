#!/bin/bash

# A general-purpose bash script to install and set up common file server
# and networking tools like NFS and Samba on a Linux system.
# Installation of Webmin is Debian-based systems only. For now still working on it
# The script will detect the package manager (apt, yum, dnf) and install
# the necessary server and client components. partial for now

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Starting the file server installation script..."

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root. Please use 'sudo'." 1>&2
   exit 1
fi

# --- Step 1: Detect the Linux distribution and package manager ---
# This section makes the script more portable across different systems.
echo "Detecting package manager..."
PACKAGE_MANAGER=""
if command -v apt-get &> /dev/null; then
    PACKAGE_MANAGER="apt-get"
    echo "Detected Debian/Ubuntu-based system. Using 'apt-get'."
elif command -v yum &> /dev/null; then
    PACKAGE_MANAGER="yum"
    echo "Detected CentOS/RHEL-based system. Using 'yum'."
elif command -v dnf &> /dev/null; then
    PACKAGE_MANAGER="dnf"
    echo "Detected Fedora-based system. Using 'dnf'."
else
    echo "Error: Supported package manager (apt, yum, or dnf) not found."
    exit 1
fi

echo "Updating system package list..."
sudo $PACKAGE_MANAGER update -y

# --- Step 2: Install NFS (Network File System) packages ---
# NFS is ideal for sharing files between Linux and Unix-like systems.
echo "Installing NFS server and client packages..."
if [ "$PACKAGE_MANAGER" == "apt-get" ]; then
    # On Debian/Ubuntu, the server is called 'nfs-kernel-server' and the client is 'nfs-common'.
    sudo $PACKAGE_MANAGER install -y nfs-kernel-server nfs-common
elif [ "$PACKAGE_MANAGER" == "yum" ] || [ "$PACKAGE_MANAGER" == "dnf" ]; then
    # On CentOS/RHEL/Fedora, the package is 'nfs-utils' for both server and client components.
    sudo $PACKAGE_MANAGER install -y nfs-utils
fi

# Enable and start the NFS service.
echo "Enabling and starting the NFS service..."
sudo systemctl enable nfs-server
sudo systemctl start nfs-server
echo "NFS installation and service setup complete."

# --- Step 3: Install Samba packages ---
# Samba is essential for sharing files with Windows systems.
echo "Installing Samba packages..."
if [ "$PACKAGE_MANAGER" == "apt-get" ]; then
    # On Debian/Ubuntu, the main package is 'samba'.
    sudo $PACKAGE_MANAGER install -y samba
elif [ "$PACKAGE_MANAGER" == "yum" ] || [ "$PACKAGE_MANAGER" == "dnf" ]; then
    # On CentOS/RHEL/Fedora, the main package is also 'samba'.
    sudo $PACKAGE_MANAGER install -y samba samba-common-tools
fi

# Enable and start the Samba services.
# The services are named 'smb' and 'nmb' on some systems, or 'samba' on others.
echo "Enabling and starting the Samba services..."
if command -v systemctl &> /dev/null; then
    sudo systemctl enable smb nmb || sudo systemctl enable samba || echo "Could not enable Samba service with standard names."
    sudo systemctl start smb nmb || sudo systemctl start samba || echo "Could not start Samba service with standard names."
fi
echo "Samba installation and service setup complete."

echo "All specified file server tools have been installed successfully."
echo "You can now proceed with configuring your shares in /etc/exports (for NFS) and /etc/samba/smb.conf (for Samba)."

# --- Step 3: Install Webmin repo ---
curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sh webmin-setup-repo.sh

# Install Webmin
echo "Installing Webmin..."
sudo apt-get install webmin --install-recommends -y

# --- Step 4: Cleaning up packages ---
echo "Cleaning up package cache..."
sudo apt autoremove -y
sudo apt clean




# Install core penetration testing tools from the standard repositories
# echo "Installing Nmap, Wireshark, and other common tools..."
# sudo apt install -y nmap wireshark hashcat metasploit-framework
