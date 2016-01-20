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

# install ssh key/pair and authorized_keys on node
if [[ -f $REMOTE_BASE/etc/ssh/id_rsa ]]; then
  mkdir -p ~/.ssh
  
  mv $REMOTE_BASE/etc/ssh/id_rsa ~/.ssh/
  mv $REMOTE_BASE/etc/ssh/id_rsa.pub ~/.ssh/
  
  # append public key to authorized_keys file so we'll be able to talk to guests
  if [[ -f $REMOTE_BASE/etc/ssh/authorized_keys ]]; then
    cat ~/.ssh/id_rsa.pub >> $REMOTE_BASE/etc/ssh/authorized_keys
  fi
  
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
fi

# add github.com public key to known hosts so we can talk without user confirmation
test ! -f ~/.ssh/known_hosts && touch ~/.ssh/known_hosts
if [[ -z "$(grep github ~/.ssh/known_hosts)" ]]; then
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
fi

# checkout specified cloud configuration from private repository (assumed to have authorized deploy key)
if [[ ! -z $CLOUD_CONFIG ]]; then
    git clone -q --no-checkout $CLOUD_CONFIG $REMOTE_BASE/etc/cloud-config
    mv $REMOTE_BASE/etc/cloud-config/.git $REMOTE_BASE/etc/.git
    rmdir $REMOTE_BASE/etc/cloud-config
    git --work-tree $REMOTE_BASE/etc --git-dir $REMOTE_BASE/etc/.git checkout -q --force
fi
