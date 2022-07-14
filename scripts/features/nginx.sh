#!/usr/bin/env bash

if [ -f /etc/init.d/nginx* ];
then
    echo "Nginx already installed"
    nginx -v
    service nginx restart
    exit 0
fi

# Install & Configure Redis Server
apt-get remove --purge -y nginx nginx-full nginx-common
apt-get install -y --force-yes nginx
service nginx restart
systemctl enable nginx.service