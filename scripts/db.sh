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
:: installing mysqld service
########################################

[ -f ./guest/etc/my.cnf ] && cp ./guest/etc/my.cnf /etc/my.cnf
yum install -y mysql-server

########################################
:: configuring mysqld access
########################################

# start servcie to initialize data directory and setup default access
service mysqld start >> $BOOTSTRAP_LOG 2>&1
mysql -uroot -e "
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
"
service mysqld stop >> $BOOTSTRAP_LOG 2>&1 # leave mysqld in stopped state
