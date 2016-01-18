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
# configure local ssh

set -e

if [[ ! -f ~/.ssh/id_rsa ]]; then
    ssh-keygen -N '' -t rsa -f ~/.ssh/id_rsa
    cat ~/.ssh/id_rsa.pub >> /vagrant/etc/ssh/authorized_keys   ## will be appened in build.sh on reload
fi

if [[ -f /vagrant/etc/ssh/authorized_keys ]]; then
    cp /vagrant/etc/ssh/authorized_keys ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi
