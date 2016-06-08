#!/usr/bin/env bash
##
 # Copyright © 2016 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

set -e

source ./scripts/lib/utils.sh

########################################
:: installing web services
########################################

yum install -y redis sendmail varnish nginx

# install php and cross-version dependencies
yum $extra_repos install -y php-fpm php-cli php-opcache \
    php-mysqlnd php-mhash php-curl php-gd php-intl php-mcrypt php-xsl php-mbstring php-soap php-bcmath php-zip

# phpredis does not yet have php7 support
[[ "$PHP_VERSION" < 70 ]] && yum $extra_repos install -y php-pecl-redis

########################################
:: configuring web services
########################################

adduser -rUm -G sshusers www-data

# start user in the web root when logging in
echo cd /var/www/html >> ~www-data/.bash_profile

# create a key-pair to be used as a deploy key as needed
[[ ! -f ~www-data/.ssh/id_rsa ]] && sudo -u www-data ssh-keygen -N '' -t rsa -f ~www-data/.ssh/id_rsa

# authorize public keys on www-data user as well, using either provided authorized_keys file or vagrant supplied key
if [[ -f /vagrant/etc/ssh/authorized_keys ]]; then
    cp /vagrant/etc/ssh/authorized_keys ~www-data/.ssh/authorized_keys
else
    cp ~/.ssh/authorized_keys ~www-data/.ssh/authorized_keys
fi

chown www-data:www-data ~www-data/.ssh/authorized_keys
chmod 600 ~www-data/.ssh/authorized_keys

# configure proper group membership and ownership (apache user comes in with the php-fpm rpm)
usermod -a -G www-data nginx
userdel apache

chown -R root /var/log/php-fpm      # ditch apache ownership
chgrp -R www-data /var/lib/php      # ditch apache group

mkdir -p /var/www/html/current/pub
echo '<?php phpinfo();' > /var/www/html/current/pub/index.php
chown -R www-data:www-data /var/www/html

# ensure each of the web services will start on boot
chkconfig redis on
service redis start

chkconfig varnish on
service varnish start

chkconfig nginx on
service nginx start

chkconfig php-fpm on
service php-fpm start

########################################
:: installing develop tools
########################################

npm install -g grunt-cli

# install composer
wget https://getcomposer.org/download/1.1.2/composer.phar -O /usr/local/bin/composer 2>&1
chmod +x /usr/local/bin/composer

# install n98-magerun
wget http://files.magerun.net/n98-magerun-latest.phar -O /usr/local/bin/n98-magerun 2>&1
wget http://files.magerun.net/n98-magerun2-latest.phar -O /usr/local/bin/n98-magerun2 2>&1

chmod +x /usr/local/bin/n98-magerun
chmod +x /usr/local/bin/n98-magerun2

ln -s /usr/local/bin/n98-magerun /usr/local/bin/mr
ln -s /usr/local/bin/n98-magerun2 /usr/local/bin/mr2
