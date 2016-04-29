##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

require 'utils'

# Virtual Box Configuration
def provider_vb conf
  if defined? CONF_VB_ENABLE and CONF_VB_ENABLE == true
    conf.vm.provider :virtualbox do |provider, conf|
      provider.memory = 4096
      provider.cpus = 2

      conf.vm.network :private_network, type: 'dhcp'
      conf.vm.box = 'bento/centos-6.7'
    end
  end
end

# Digital Ocean Configuration
def provider_do conf
  if defined? CONF_DO_TOKEN
    assert_plugin 'vagrant-digitalocean'
    
    conf.vm.provider :digital_ocean do |provider, conf|
      provider.token           = CONF_DO_TOKEN
      provider.image           = CONF_DO_IMAGE
      provider.region          = CONF_DO_REGION
      provider.size            = CONF_DO_SIZE
      provider.ssh_key_name    = CONF_DO_PK_NAME
      provider.backups_enabled = true

      conf.ssh.private_key_path = CONF_DO_PK_PATH
      conf.vm.box = 'https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box'
    end
  end
end

# AWS Configuration
def provider_aws conf
  if defined? CONF_AWS_KEY_ID and defined? CONF_AWS_KEY_SECRET
    assert_plugin 'vagrant-aws'
    conf.vm.provider :aws do |provider, conf|
      provider.ami               = CONF_AWS_AMI
      provider.access_key_id     = CONF_AWS_KEY_ID
      provider.secret_access_key = CONF_AWS_KEY_SECRET
      provider.keypair_name      = CONF_AWS_PK_NAME

      if defined? CONF_AWS_SESSION_TOKEN
        provider.session_token = CONF_AWS_SESSION_TOKEN
      end

      conf.ssh.username          = 'cloud'
      conf.ssh.private_key_path  = CONF_AWS_PK_PATH
      conf.vm.box = 'https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box'
    end
  end
end

# Rackspace Cloud Configuration
def provider_rack conf
  if defined? CONF_RAX_USERNAME and defined? CONF_RAX_API_KEY
    assert_plugin 'vagrant-rackspace'
    conf.vm.provider :rackspace do |provider, conf|
      provider.username         = CONF_RAX_USERNAME
      provider.api_key          = CONF_RAX_API_KEY
      provider.rackspace_region = CONF_RAX_REGION
      provider.flavor           = CONF_RAX_FLAVOR
      provider.image            = CONF_RAX_IMAGE
    end
  end
end

def machine_fullstack_vm node, host: nil, ip: nil, php_version: nil, mysql_version: nil
  # if no period in supplied host, tack on the configured CLOUD_DOMAIN
  unless host =~ /.*\..*/
    host = host + '.' + CLOUD_DOMAIN
  end
  node.vm.hostname = host
  
  bootstrap_sh node, ['node', 'config', 'db', 'web'], {
    ssl_dir: '/etc/ssl',
    php_version: php_version,
    mysql_version: mysql_version
  }
  service node, { start: ['redis', 'mysqld', 'httpd', 'varnish', 'nginx'], reload: ['sshd'] }
end

def machine_synced_etc node, path
  node.vm.synced_folder path, VAGRANT_DIR + '/etc', type: 'rsync', rsync__args: [ '--archive', '-z', '--copy-links' ]
end

def build_sh conf, env = {}
  conf.vm.provision :shell, run: 'always' do |conf|
    env = {
      vagrant_dir: VAGRANT_DIR
    }.merge(env)
    exports = generate_exports env

    conf.name = 'build.sh'
    conf.inline = %-#{exports} #{VAGRANT_DIR}/scripts/build.sh-
  end
end

def configure_sh conf, env = {}
  conf.vm.provision :shell, run: 'always' do |conf|
    env = {
      vagrant_dir: VAGRANT_DIR
    }.merge(env)
    exports = generate_exports env

    conf.name = 'configure.sh'
    conf.inline = %-#{exports} #{VAGRANT_DIR}/etc/configure.sh-
  end
end
