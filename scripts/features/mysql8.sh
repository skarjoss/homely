#!/usr/bin/env bash

# Replace!
# [!sudo_password!] (random password for sudo)
# $DB_PASSWORD (random password for database user)

#
# REQUIRES:
# - sudo_password (random password for sudo)
# - db_password (random password for database user)
#

if [ -f /etc/init.d/mysql* ];
then
    echo "Mysql already installed"
    mysql --version
    service mysql restart
    exit 0
fi

# sudo rm -rf /var/lib/mysql/
# sudo mysqld --initialize

WSL_USER_NAME=$SUDO_USER
DB_PASSWORD=secret

# Install MySQL
apt-get install -y mysql-server

# Configure Password Expiration
echo "default_password_lifetime = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

# Set Character Set
echo "[mysqld]" >> /etc/mysql/my.cnf
echo "default_authentication_plugin=mysql_native_password" >> /etc/mysql/my.cnf

# Configure Max Connections
RAM=$(awk '/^MemTotal:/{printf "%3.0f", $2 / (1024 * 1024)}' /proc/meminfo)
MAX_CONNECTIONS=$(( 70 * $RAM ))
REAL_MAX_CONNECTIONS=$(( MAX_CONNECTIONS>70 ? MAX_CONNECTIONS : 100 ))
sed -i "s/^max_connections.*=.*/max_connections=${REAL_MAX_CONNECTIONS}/" /etc/mysql/my.cnf

# Configure Access Permissions For Root & homely Users
sed -i '/^bind-address/s/bind-address.*=.*/bind-address = */' /etc/mysql/mysql.conf.d/mysqld.cnf
mysql --user="root" --password="$DB_PASSWORD" -e "CREATE USER 'root'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';"
mysql --user="root" --password="$DB_PASSWORD" -e "CREATE USER 'root'@'%' IDENTIFIED BY '$DB_PASSWORD';"
mysql --user="root" --password="$DB_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO root@'127.0.0.1' WITH GRANT OPTION;"
mysql --user="root" --password="$DB_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO root@'%' WITH GRANT OPTION;"

mysql --user="root" --password="$DB_PASSWORD" -e "CREATE USER 'homely'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';"
mysql --user="root" --password="$DB_PASSWORD" -e "CREATE USER 'homely'@'%' IDENTIFIED BY '$DB_PASSWORD';"
mysql --user="root" --password="$DB_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO 'homely'@'127.0.0.1' WITH GRANT OPTION;"
mysql --user="root" --password="$DB_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO 'homely'@'%' WITH GRANT OPTION;"
mysql --user="root" --password="$DB_PASSWORD" -e "FLUSH PRIVILEGES;"

# Create The Initial Database If Specified
mysql --user="root" --password="$DB_PASSWORD" -e "CREATE DATABASE homely CHARACTER SET utf8 COLLATE utf8_unicode_ci;"

# MySQL start
#service mysql restart
service mysql stop
systemctl enable mysql
sudo update-rc.d mysql defaults
usermod -d /var/lib/mysql/ mysql
service mysql start

