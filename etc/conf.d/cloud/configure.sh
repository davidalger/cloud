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

source $VAGRANT_DIR/scripts/includes/configure_ssh
source $VAGRANT_DIR/scripts/includes/add_known_hosts

# checkout specified cloud configuration from private repository (assumes authorized deploy key is present)
if [[ ! -z $CLOUD_CONFIG ]]; then
    git clone -q $CLOUD_CONFIG $REMOTE_BASE/etc/sites.d
fi

echo "cd /vagrant" >> ~/.bash_profile
