##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

def configure_common (conf)
  conf.vm.box = 'bento/centos-6.7'  # overriden for some providers

  # conf.vm.provider 'digitalocean'
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
    conf.inline = "rsync -a --ignore-existing #{VENDOR_BASE}/#{DEVENV_PATH}/{etc,scripts} #{VAGRANT_DIR}/"
  end
end

def configure_manager_vm (node, host: nil, ip: nil, php_version: nil)
  node.vm.hostname = host + '.' + CLOUD_DOMAIN

  node.vm.provider :digital_ocean do | provider, override |
    provider.size = '512mb'
  end

  bootstrap_sh(node, ['node', 'web'], { php_version: php_version })
  service(node, { start: ['redis', 'httpd', 'nginx'] })
end

def configure_fullstack_vm (node, host: nil, ip: nil, php_version: nil, mysql_version: nil)
  node.vm.hostname = host + '.' + CLOUD_DOMAIN

  bootstrap_sh(node, ['node', 'db', 'web'], { php_version: php_version, mysql_version: mysql_version })
  service(node, { start: ['redis', 'mysqld', 'httpd', 'nginx'] })
end
