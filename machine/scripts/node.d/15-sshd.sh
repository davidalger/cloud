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
# configure sshd service

set -e

if [[ -f ./etc/ssh/sshd_config ]]; then
    cp ./etc/ssh/sshd_config /etc/ssh/sshd_config
fi

service sshd reload
