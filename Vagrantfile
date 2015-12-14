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

BASE_DIR = File.dirname(__FILE__)
VAGRANT_DIR = '/vagrant'
DEVENV_PATH = 'vendor/davidalger/devenv/vagrant'
SHARED_DIR = BASE_DIR + '/.shared'

if not File.exist?(DEVENV_PATH + '/vagrant.rb')
  raise "Please run 'composer install' before running vagrant commands."
end

$LOAD_PATH.unshift(BASE_DIR + '/' + DEVENV_PATH)
require 'lib/provision'

# begin the configuration sequence
Vagrant.require_version '>= 1.7.4'
Vagrant.configure(2) do |conf|

  conf.vm.provider 'digitalocean'
  conf.vm.hostname = 'cloud.' + CLOUD_DOMAIN

  conf.vm.provider :digital_ocean do | provider, override |
    provider.token = CONF_DO_TOKEN
    provider.image = CONF_DO_IMAGE
    provider.region = CONF_DO_REGION
    provider.size = CONF_DO_SIZE

    override.ssh.private_key_path = CONF_DO_KEY_PATH
    override.vm.box = CONF_DO_BOX_NAME
    override.vm.box_url = CONF_DO_BOX_URL
  end

  # these vms are not considered secure for purposes of agent forwarding
  conf.ssh.forward_agent = false

  # copy in devenv stuff without overwriting any existing files
  conf.vm.provision :shell do |conf|
    conf.name = 'build'
    conf.inline = "rsync -a --ignore-existing #{VAGRANT_DIR}/#{DEVENV_PATH}/ #{VAGRANT_DIR}/"
  end

  bootstrap_sh(conf, ['node', 'web'], { php_version: 70 })
  service(conf, { start: ['redis', 'httpd', 'nginx'] })

end
