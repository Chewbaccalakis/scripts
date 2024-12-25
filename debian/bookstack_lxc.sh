#!/bin/bash

# Check for sudo permissions
if [ "$EUID" -ne 0 ]; then
    echo "This script requires sudo permissions. Please run as root or with sudo."
    exit 1
fi

# Display information about the script
echo "This script is intended for a Debian LXC environment and does not include database setup."

# Prompt the user
read -p "Do you want to install BookStack? (yes/no): " choice

# Check the user's input
case "$choice" in
    yes|Yes|y|Y)
        apt-get update
        apt-get upgrade -y
        apt-get update
        apt-get install -y git curl wget unzip
        apt-get install -y php php-cli php--gd php-dom php-iconv php-mbstring php-mysql php-openssl php-pdo php-pdo-mysql php-tokenizer php-xml php-zip php-ldap
        apt-get install -y apache2
        curl https://raw.githubusercontent.com/Chewbaccalakis/scripts/refs/heads/main/debian/apache_bookstack.conf -o /etc/apache2/sites-available/bookstack.conf
        a2ensite bookstack.conf
        systemctl reload apache2
        curl -sS https://getcomposer.org/installer -o composer-setup.php
        php composer-setup.php --install-dir=/usr/local/bin --filename=composer
        mkdir -p /var/www/bookstack/
        git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch /var/www/bookstack/
        cd /app
        composer install --no-dev
        php artisan key:generate
        ;;
    no|No|n|N)
        echo "Installation aborted."
        exit 0
        ;;
    *)
        echo "Invalid choice. Please run the script again and respond with 'yes' or 'no'."
        exit 1
        ;;
esac
