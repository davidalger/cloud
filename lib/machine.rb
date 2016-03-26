##
 # Copyright © 2015 by David Alger. All rights reserved
 # 
 # Licensed under the Open Software License 3.0 (OSL-3.0)
 # See included LICENSE file for full text of OSL-3.0
 # 
 # http://davidalger.com/contact/
 ##

require 'utils'

def machine_common conf
  conf.vm.box = 'bento/centos-6.7'  # overriden for some providers

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

  # configuration on default vagrant synced folder
  conf.vm.synced_folder '.', VAGRANT_DIR, type: 'rsync',
    rsync__args: ['--delete-excluded', '--archive', '-z'],
    rsync__exclude: ['/.git/', '/.gitignore', '/composer.*', '/*.md', '/etc/*.*'] # etc exclude allows dirs without a .

  # prepare node for performing actual provisioning on itself and/or other nodes
  build_sh conf
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
