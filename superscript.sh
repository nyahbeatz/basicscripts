#1/bin/bash

#Install file sharing and basic networking tools along with curl and webmin

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root. Please use 'sudo'." 1>&2
   exit 1
fi

echo "Updating system package lists..."
sudo apt update

echo "Installing essential network utilities..."

# The 'net-tools' package includes classic commands like ifconfig and netstat.
sudo apt install net-tools -y

curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sh webmin-setup-repo.sh

# Install Webmin
echo "Installing Webmin..."
sudo apt-get install webmin --install-recommends -y