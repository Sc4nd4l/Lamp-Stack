#!/bin/bash

# Request user input
echo "Please enter your domain (example.com):"
read DOMAIN
echo "Please enter your desired MariaDB database name:"
read DATABASE
echo "Please enter your desired MariaDB username:"
read USER
echo "Please enter your desired MariaDB password:"
read PASSWORD

# Update system packages
sudo apt update
sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Install MariaDB
sudo apt install mariadb-server -y

# Install PHP and its modules
sudo apt install php-fpm php-mysql -y

# Create Nginx server block file
sudo bash -c 'cat > /etc/nginx/sites-available/${DOMAIN} <<EOF
server {
    listen 80;
    root /var/www/html;
    index index.php index.html index.htm index.nginx-debian.html;
    server_name ${DOMAIN};

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF'

# Enable the site
sudo ln -s /etc/nginx/sites-available/${DOMAIN} /etc/nginx/sites-enabled/

# Test Nginx config
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# Setup MariaDB database
sudo mysql -u root <<EOF
CREATE DATABASE ${DATABASE};
CREATE USER '${USER}'@'localhost' IDENTIFIED BY '${PASSWORD}';
GRANT ALL PRIVILEGES ON ${DATABASE}.* TO '${USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

# Install Certbot for Let's Encrypt
sudo apt install certbot python3-certbot-nginx -y

# Obtain and install SSL certificates
sudo certbot --nginx -d ${DOMAIN}
