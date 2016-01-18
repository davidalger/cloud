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

if [[ ! -d $REMOTE_BASE/vendor ]]; then
    exit
fi

# pull vendor assets into place, then cleanup
mkdir -p $VAGRANT_DIR/bin/
rsync -a --ignore-existing $REMOTE_BASE/vendor/davidalger/devenv/vagrant/{etc,scripts} $VAGRANT_DIR/ \
    --exclude 'etc/hosts'
rsync -a --ignore-existing $REMOTE_BASE/vendor/davidalger/devenv/vagrant/lib/ $REMOTE_BASE/lib/
cp $REMOTE_BASE/vendor/davidalger/devenv/vagrant/scripts/bootstrap.sh $VAGRANT_DIR/
cp $REMOTE_BASE/vendor/davidalger/devenv/vagrant/bin/magento $VAGRANT_DIR/bin/
cp $REMOTE_BASE/vendor/davidalger/devenv/vagrant/bin/m2setup.sh $VAGRANT_DIR/bin/
rm -rf $REMOTE_BASE/vendor

# append public key to authorized_keys file if present; this happens on provisioining in 15-ssh.sh, or here on reload
if [[ -f /vagrant/etc/ssh/authorized_keys ]] && [[ -f ~/.ssh/id_rsa.pub ]]; then
    cat ~/.ssh/id_rsa.pub >> /vagrant/etc/ssh/authorized_keys
fi
