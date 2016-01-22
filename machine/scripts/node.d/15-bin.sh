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
# setup custom bin tools

set -e

if [[ -d ./bin ]]; then
    rsync -a --ignore-existing ./bin/ /usr/local/bin/
fi
