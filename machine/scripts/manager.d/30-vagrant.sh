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
# install vagrant for cli use

set -e

# so plugins are installed in the correct user location
export VAGRANT_HOME=/home/vagrant/.vagrant.d

yum install -y vagrant
vagrant plugin install vagrant-digitalocean
vagrant plugin install vagrant-triggers

chown -R vagrant:vagrant $VAGRANT_HOME
