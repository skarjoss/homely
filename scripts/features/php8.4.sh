#!/usr/bin/env bash

#echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER # add current user as sudoer

WSL_USER_NAME=$SUDO_USER
WSL_USER_GROUP=$SUDO_USER

mkdir -p /home/$WSL_USER_NAME/.homely-features

export DEBIAN_FRONTEND=noninteractive

if [ -f /home/$WSL_USER_NAME/.homely-features/php84 ]
then
   echo "PHP 8.4 already installed."
   service php8.4-fpm restart
   exit 0
fi

touch /home/$WSL_USER_NAME/.homely-features/php84
chown -Rf $WSL_USER_NAME:$WSL_USER_GROUP /home/$WSL_USER_NAME/.homely-features

# PHP 8.4
sudo add-apt-repository ppa:ondrej/php -y
apt-get install -y --allow-change-held-packages \
php8.4 php8.4-bcmath php8.4-bz2 php8.4-cgi php8.4-cli php8.4-common php8.4-curl php8.4-dba php8.4-dev \
php8.4-enchant php8.4-fpm php8.4-gd php8.4-gmp php8.4-imap php8.4-interbase php8.4-intl php8.4-ldap \
php8.4-mbstring php8.4-mysql php8.4-odbc php8.4-opcache php8.4-pgsql php8.4-phpdbg php8.4-pspell php8.4-readline \
php8.4-snmp php8.4-soap php8.4-sqlite3 php8.4-sybase php8.4-tidy php8.4-xml php8.4-xsl \
php8.4-zip php8.4-imagick

# php8.4-xdebug php8.4-xmlrpc php8.4-memcached php8.4-redis

# Configure php.ini for CLI
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.4/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.4/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.4/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.4/cli/php.ini

# Configure Xdebug
# echo "xdebug.mode = debug" >> /etc/php/8.4/mods-available/xdebug.ini
# echo "xdebug.discover_client_host = true" >> /etc/php/8.4/mods-available/xdebug.ini
# echo "xdebug.client_port = 9003" >> /etc/php/8.4/mods-available/xdebug.ini
# echo "xdebug.max_nesting_level = 512" >> /etc/php/8.4/mods-available/xdebug.ini
# echo "opcache.revalidate_freq = 0" >> /etc/php/8.4/mods-available/opcache.ini

# Configure php.ini for FPM
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.4/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.4/fpm/php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.4/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.4/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.4/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/8.4/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.4/fpm/php.ini

printf "[openssl]\n" | tee -a /etc/php/8.4/fpm/php.ini
printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.4/fpm/php.ini
printf "[curl]\n" | tee -a /etc/php/8.4/fpm/php.ini
printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.4/fpm/php.ini

# Configure FPM
sed -i "s/user = www-data/user = $WSL_USER_NAME/" /etc/php/8.4/fpm/pool.d/www.conf
sed -i "s/group = www-data/group = $WSL_USER_NAME/" /etc/php/8.4/fpm/pool.d/www.conf
sed -i "s/listen\.owner.*/listen.owner = $WSL_USER_NAME/" /etc/php/8.4/fpm/pool.d/www.conf
sed -i "s/listen\.group.*/listen.group = $WSL_USER_NAME/" /etc/php/8.4/fpm/pool.d/www.conf
sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/8.4/fpm/pool.d/www.conf

systemctl enable php8.4-fpm
service php8.4-fpm restart
