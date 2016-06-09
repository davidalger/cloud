##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

require_relative 'etc/config.rb'
require_relative 'etc/defaults.rb'

# setup environment constants
BASE_DIR = File.dirname(__FILE__)
VAGRANT_DIR = '/vagrant'
SHARED_DIR = BASE_DIR + '/.shared'

# configure load path to include devenv libs and our own libs
$LOAD_PATH.unshift(BASE_DIR + '/lib')

# import our libraries
require 'provision'
require 'utils'
require 'machine'
require 'magento'

# verify our plugin dependencies are installed
assert_plugin 'vagrant-triggers'

# begin the configuration sequence
Vagrant.require_version '>= 1.7.4'
Vagrant.configure(2) do |conf|

  provider_vb conf
  provider_do conf
  provider_aws conf
  provider_rack conf

  # disable default vagrant dir sync and push up specific dirs we need
  conf.vm.synced_folder '.', VAGRANT_DIR, disabled: true
  conf.vm.synced_folder './guest', "#{VAGRANT_DIR}/guest", type: 'rsync'
  conf.vm.synced_folder './scripts', "#{VAGRANT_DIR}/scripts", type: 'rsync'
  conf.vm.synced_folder './etc/keys', "#{VAGRANT_DIR}/etc/keys", type: 'rsync'
  conf.vm.synced_folder './etc/filters', "#{VAGRANT_DIR}/etc/filters", type: 'rsync'

  # load config declarations for each site in etc/conf.d
  Dir.foreach BASE_DIR + '/etc/conf.d' do | file |
    if not File.directory? BASE_DIR + '/etc/conf.d/' + file and file =~ /.*\.rb$/
      include_conf BASE_DIR + '/etc/conf.d/' + file, conf
    end
  end

  # always output guest machine information on load
  conf.vm.provision :shell, run: 'always' do |conf|
    conf.name = "vm-info"
    conf.inline = "
      # use info from eth1 if available, otherwise eth0
      interface=$(ifconfig eth1 | grep 'inet addr' > /dev/null 2>&1 && echo eth1 || echo eth0)
      ip_address=$(ifconfig $interface | grep 'inet addr' | awk -F: '{print $2}' | awk '{print $1}')
      printf 'ip address: %s\nhostname: %s\n' \"$ip_address\" \"$(hostname)\"
    "
  end

  # verify with user before allowing a halt to take place
  conf.trigger.before :halt do
    confirm = nil
    until ["Y", "y", "N", "n"].include?(confirm)
      confirm = ask "Are you sure you want to halt the VM? [y/N] "
    end
    exit unless confirm.upcase == "Y"
  end

  # verify with user before allowing a rebuild to take place
  conf.trigger.before :rebuild do
    confirm = nil
    until ["Y", "y", "N", "n"].include?(confirm)
      puts "The rebuild command is a potentially destructive operation. All data on the VM will be erased!"
      confirm = ask "Are you sure you want to rebuild the VM? [y/N] "
    end
    exit unless confirm.upcase == "Y"
  end

  # kill vagrant destroy command as a safegaurd
  unless File.exist? BASE_DIR + '/etc/assassin.flag' or ENV['VAGRANT_ASSASSIN'] == "true"
    conf.trigger.reject :destroy do
      puts "Sorry, that command is not allowed from the vagrant tool! Please login to console to destroy a VM"
    end
  end
end
