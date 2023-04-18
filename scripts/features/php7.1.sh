#!/usr/bin/env bash

#echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER # add current user as sudoer
# sudo update-alternatives --config php

WSL_USER_NAME=$SUDO_USER
WSL_USER_GROUP=$SUDO_USER

mkdir -p /home/$WSL_USER_NAME/.homely-features

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/$WSL_USER_NAME/.homely-features/php71 ]
then
    echo "PHP 7.1 already installed."
    service php7.1-fpm restart
    exit 0
fi

touch /home/$WSL_USER_NAME/.homely-features/php71
chown -Rf $WSL_USER_NAME:$WSL_USER_GROUP /home/$WSL_USER_NAME/.homely-features

# PHP 7.1
apt-get install -y --allow-change-held-packages \
php7.1 php7.1-bcmath php7.1-bz2 php7.1-cgi php7.1-cli php7.1-common php7.1-curl php7.1-dba php7.1-dev php7.1-enchant \
php7.1-fpm php7.1-gd php7.1-gmp php7.1-imap php7.1-interbase php7.1-intl php7.1-json php7.1-ldap php7.1-mbstring \
php7.1-mysql php7.1-odbc php7.1-opcache php7.1-pgsql php7.1-phpdbg php7.1-pspell php7.1-readline php7.1-recode \
php7.1-snmp php7.1-soap php7.1-sqlite3 php7.1-sybase php7.1-tidy php7.1-xdebug php7.1-xml php7.1-xmlrpc php7.1-xsl \
php7.1-zip php7.1-memcached php7.1-redis php7.1-mcrypt

# Configure php.ini for CLI
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/cli/php.ini

# Configure Xdebug
echo "xdebug.mode = debug" >> /etc/php/7.1/mods-available/xdebug.ini
echo "xdebug.discover_client_host = true" >> /etc/php/7.1/mods-available/xdebug.ini
echo "xdebug.client_port = 9003" >> /etc/php/7.1/mods-available/xdebug.ini
echo "xdebug.max_nesting_level = 512" >> /etc/php/7.1/mods-available/xdebug.ini
echo "opcache.revalidate_freq = 0" >> /etc/php/7.1/mods-available/opcache.ini

# Configure php.ini for FPM
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.1/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.1/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/fpm/php.ini

printf "[openssl]\n" | tee -a /etc/php/7.1/fpm/php.ini
printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.1/fpm/php.ini
printf "[curl]\n" | tee -a /etc/php/7.1/fpm/php.ini
printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.1/fpm/php.ini

# Configure FPM
sed -i "s/user = www-data/user = $WSL_USER_NAME/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = $WSL_USER_NAME/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/listen\.owner.*/listen.owner = $WSL_USER_NAME/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = $WSL_USER_NAME/" /etc/php/7.1/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.1/fpm/pool.d/www.conf

systemctl enable php7.1-fpm
service php7.1-fpm restart
