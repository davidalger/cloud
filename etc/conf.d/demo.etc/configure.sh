#!/usr/bin/env bash
##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

set -e

rsync -a $REMOTE_BASE/etc/www/ /var/www/
chown -R apache:apache /var/www/

test -f $REMOTE_BASE/etc/n98-magerun.yaml && cp $REMOTE_BASE/etc/n98-magerun.yaml ~/.n98-magerun.yaml
