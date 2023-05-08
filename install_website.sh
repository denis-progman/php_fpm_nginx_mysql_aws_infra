#!/bin/bash 
sudo su 
sudo amazon-linux-extras install -y epel
yum update -y 
yum install -y nginx 
systemctl enable nginx
systemctl start nginx
cat > /etc/nginx/conf.d/site.conf<<EOM
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /var/www/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
EOM

mkdir -p /var/www/html
echo "<h1>Hello world!</h1>" > /var/www/html/index.html
nginx -s reload