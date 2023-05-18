#!/bin/bash 
sudo su 

sudo amazon-linux-extras install -y epel
sudo yum update -y 
sudo yum install -y nginx 
sudo chmod 777 -R /etc/nginx

sudo systemctl enable nginx
sudo systemctl start nginx
