#!/usr/bin/env bash
##
 # Copyright © 2016 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

set -e

# don't do anything if has already been run (i.e. vendor was removed)
[[ ! -d $VAGRANT_DIR/vendor ]] && exit

# pull vendor assets into place on guest
rsync -a --ignore-existing $VAGRANT_DIR/vendor/davidalger/devenv/vagrant/{etc,guest,scripts,lib} $VAGRANT_DIR/ \
    --exclude 'guest/etc/hosts'

# remove vendor dir from target to cleanup guest and prevent re-runs of this script
rm -rf $VAGRANT_DIR/vendor
