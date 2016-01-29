#!/usr/bin/env bash
##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

########################################
# install and configure mysqld service

set -e

if [[ -f ./etc/my.cnf ]]; then
    cp ./etc/my.cnf /etc/my.cnf
fi

mkdir /etc/my.cnf.d/    # won't exist prior to install, and 5.1 doesn't automatically create it
if [[ -d ./etc/my.cnf.d ]] && [[ ! -z "$(ls -1 ./etc/my.cnf.d/)" ]]; then
    cp ./etc/my.cnf.d/*.cnf /etc/my.cnf.d/
fi

yum install -y mysql-server

# start servcie to initialize data directory and setup default access
service mysqld start >> $BOOTSTRAP_LOG 2>&1
mysql -uroot -e "
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
"
service mysqld stop >> $BOOTSTRAP_LOG 2>&1 # leave mysqld in stopped state
