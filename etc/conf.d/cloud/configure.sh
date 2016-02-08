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

# checkout specified cloud configuration from private repository (assumed to have authorized deploy key)
if [[ ! -z $CLOUD_CONFIG ]]; then
    git clone -q --no-checkout $CLOUD_CONFIG $REMOTE_BASE/etc/cloud-config
    mv $REMOTE_BASE/etc/cloud-config/.git $REMOTE_BASE/etc/.git
    rmdir $REMOTE_BASE/etc/cloud-config
    git --work-tree $REMOTE_BASE/etc --git-dir $REMOTE_BASE/etc/.git checkout -q --force
fi
