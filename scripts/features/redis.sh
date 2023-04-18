#!/usr/bin/env bash

if [ -f /etc/init.d/redis* ];
then
    echo "Redis already installed"
    redis-server --version
    service redis-server restart
    exit 0
fi

# Install & Configure Redis Server
apt-get install -y redis-server
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
service redis-server restart
systemctl enable redis-server | pecl install -f redis