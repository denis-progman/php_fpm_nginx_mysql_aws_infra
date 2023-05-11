#!/bin/bash 
sudo su 

sudo yum update -y
sudo yum install -y amazon-linux-extras
sudo amazon-linux-extras enable php8.2
sudo yum clean metadata
sudo yum install -y php \ 
php-fpm \
php-common \
php-cli \
php-pdo \
php-json \
php-mysqlnd \
php-session \
php-opcache \
php-mbstring \
php-xml \
php-xmlwriter \
php-simplexml \
php-dom \
php-gd \
libmcrypt

sudo chmod 777 /etc/php-fpm

sudo mkdir -p /var/www/html
echo "<h1 style="color: darkred">Hello world, from fpm!</h1>" > /var/www/html/index.html


sudo systemctl enable php-fpm
sudo systemctl start php-fpm
