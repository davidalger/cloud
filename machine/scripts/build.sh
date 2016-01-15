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

# pull vendor assets into place, then cleanup
rsync -a --ignore-existing $REMOTE_BASE/vendor/davidalger/devenv/vagrant/{etc,scripts} $VAGRANT_DIR/
rsync -a --ignore-existing $REMOTE_BASE/vendor/davidalger/devenv/vagrant/lib/ $REMOTE_BASE/lib/
cp $REMOTE_BASE/vendor/davidalger/devenv/vagrant/scripts/bootstrap.sh $VAGRANT_DIR/
cp $REMOTE_BASE/vendor/davidalger/devenv/vagrant/bin/magento /usr/local/bin/
cp $REMOTE_BASE/vendor/davidalger/devenv/vagrant/bin/m2setup.sh /usr/local/bin/
rm -rf $REMOTE_BASE/vendor
