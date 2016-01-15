##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

def machine_common (conf)
  conf.vm.box = 'bento/centos-6.7'  # overriden for some providers

  # conf.vm.provider 'digitalocean'
  conf.vm.provider :digital_ocean do | provider, override |
    provider.token = CONF_DO_TOKEN
    provider.image = CONF_DO_IMAGE
    provider.region = CONF_DO_REGION
    provider.size = CONF_DO_SIZE
    provider.ssh_key_name = CONF_DO_KEY_NAME
    provider.backups_enabled = true

    override.ssh.private_key_path = CONF_DO_KEY_PATH
    override.vm.box = CONF_DO_BOX_NAME
    override.vm.box_url = CONF_DO_BOX_URL
  end

  # these vms are not considered secure for purposes of agent forwarding
  conf.ssh.forward_agent = false

  # copy in devenv stuff without overwriting any existing files
  conf.vm.provision :shell, run: 'always' do |conf|
    conf.name = 'build'
    conf.inline = "rsync -a --ignore-existing #{REMOTE_BASE}/#{DEVENV_PATH}/{etc,scripts} #{VAGRANT_DIR}/"
  end
  
  # authorize list of default public keys on new node
  conf.vm.provision :shell do |conf|
    conf.name = 'authorized_keys'
    conf.inline = "
      if [[ -f /vagrant/etc/ssh/authorized_keys ]]; then
          if [[ ! -d ~/.ssh ]]; then
              mkdir ~/.ssh
              chmod 700 ~/.ssh
          fi
          cp /vagrant/etc/ssh/authorized_keys ~/.ssh/authorized_keys
          chmod 600 ~/.ssh/authorized_keys
      fi
    "
  end
end

def machine_fullstack_vm (node, host: nil, ip: nil, php_version: nil, mysql_version: nil)
  node.vm.hostname = host + '.' + CLOUD_DOMAIN

  bootstrap_sh node, ['node', 'db', 'web'], { php_version: php_version, mysql_version: mysql_version }
  service(node, { start: ['redis', 'mysqld', 'httpd', 'varnish', 'nginx'] })
end
