#!/usr/bin/env bash

if [ -f /etc/init.d/docker* ];
then
    echo "Docker already installed"
    docker --version
    service docker restart
    exit 0
fi

# Install & Configure Redis Server
WSL_USER_NAME=$SUDO_USER
apt update
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt update
apt-cache policy docker-ce
apt install docker-ce -y
curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
usermod -aG docker $WSL_USER_NAME
service docker restart
systemctl enable docker