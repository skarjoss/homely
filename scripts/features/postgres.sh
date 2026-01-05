#!/usr/bin/env bash

if [ -f /etc/init.d/postgresql* ];
then
    echo "Postgresql already installed"
    psql --version
    service postgresql restart
    exit 0
fi

WSL_USER_NAME=$SUDO_USER
DB_PASSWORD=secret
