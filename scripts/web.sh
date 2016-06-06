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

yum install -y redis sendmail varnish httpd nginx

# install php and cross-version dependencies
yum $extra_repos install -y php php-cli php-curl php-gd php-intl php-mcrypt php-xsl php-mbstring php-soap php-bcmath \
    php-mysqlnd php-mhash php-opcache php-ldap

# phpredis does not yet have php7 support
[[ "$PHP_VERSION" < 70 ]] && yum $extra_repos install -y php-pecl-redis

########################################
:: configuring web services
########################################

perl -pi -e 's/Listen 80//' /etc/httpd/conf/httpd.conf
perl -0777 -pi -e 's#(<Directory "/var/www/html">.*?)AllowOverride None(.*?</Directory>)#$1AllowOverride All$2#s' \
        /etc/httpd/conf/httpd.conf

# disable error index file if installed
[ -f "/var/www/error/noindex.html" ] && mv /var/www/error/noindex.html /var/www/error/noindex.html.disabled

chkconfig redis on
service redis start

chkconfig httpd on
service httpd start

chkconfig varnish on
service varnish start

chkconfig nginx on
service nginx start

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
