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

if [[ -f /vagrant/etc/ssh/id_rsa ]]; then
  mkdir -p ~/.ssh
  
  mv /vagrant/etc/ssh/id_rsa ~/.ssh/
  mv /vagrant/etc/ssh/id_rsa.pub ~/.ssh/
  
  # append public key to authorized_keys file so we'll be able to talk to guests
  if [[ -f /vagrant/etc/ssh/authorized_keys ]]; then
    cat ~/.ssh/id_rsa.pub >> /vagrant/etc/ssh/authorized_keys
  fi
  
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
fi
