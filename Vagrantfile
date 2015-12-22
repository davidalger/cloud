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
REMOTE_BASE = '/vagrant'
VAGRANT_DIR = '/vagrant/machine'  # machine dir on remote, named for compatibility with devenv
DEVENV_PATH = 'vendor/davidalger/devenv/vagrant'
SHARED_DIR = BASE_DIR + '/.shared'

# verify composer dependencies have been installed
if not File.exist?(DEVENV_PATH + '/vagrant.rb')
  raise "Please run 'composer install' before running vagrant commands."
end

# load vendor libs
$LOAD_PATH.unshift(BASE_DIR + '/' + DEVENV_PATH)
require 'lib/provision'

# load built-in libs
require_relative 'lib/utils.rb'
require_relative 'lib/machine.rb'
require_relative 'lib/magento.rb'

# begin the configuration sequence
Vagrant.require_version '>= 1.7.4'
Vagrant.configure(2) do |conf|
  machine_common conf

  # declare management node
  conf.vm.define :cloud do |node|
    machine_manager_vm node, host: 'cloud', php_version: 70
  end

  # load config declarations for each site in etc/conf.d
  Dir.foreach BASE_DIR + '/etc/conf.d' do |file|
    if !File.directory? file
      include_conf BASE_DIR + '/etc/conf.d/' + file, conf
    end
  end
end
