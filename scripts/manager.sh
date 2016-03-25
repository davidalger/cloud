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

source ./scripts/lib/utils.sh

########################################
:: configuring rpms for manager role
########################################

rpm --import ./etc/keys/RPM-GPG-KEY-Vagrant.txt
pushd /var/cache/yum/rpms

wget --timestamp https://releases.hashicorp.com/vagrant/1.7.4/vagrant_1.7.4_x86_64.rpm 2>&1 || true
rpm --checksig vagrant_1.7.4_x86_64.rpm
yum install -y vagrant_1.7.4_x86_64.rpm

popd

########################################
:: installing vagrant / plugins
########################################

yum install -y vagrant
vagrant plugin install vagrant-digitalocean
vagrant plugin install vagrant-triggers
