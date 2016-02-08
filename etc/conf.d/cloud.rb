conf.vm.define :cloud do |node|
  node.vm.hostname = 'cloud.' + CLOUD_DOMAIN
  node.vm.provider :digital_ocean do | provider, override |
    provider.size = '512mb'
  end
  
  # creates and stores a persistent key/pair on the host machine
  node.trigger.before [ :up, :provision, :reload, :rebuild ] do
    unless File.exist? BASE_DIR + '/etc/conf.d/cloud/ssh/id_rsa'
      run "mkdir -p '#{BASE_DIR}/etc/conf.d/cloud/ssh'"
      run "ssh-keygen -N '' -t rsa -f '#{BASE_DIR}/etc/conf.d/cloud/ssh/id_rsa' -C 'vagrant@#{node.vm.hostname}'"
    end
  end
  
  node.vm.synced_folder BASE_DIR + '/etc/conf.d/cloud', REMOTE_BASE + '/etc', type: 'rsync'
  node.vm.synced_folder BASE_DIR + '/etc/conf.d', REMOTE_BASE + '/etc/conf.d', type: 'rsync', rsync__exclude: [
    'cloud-config',
    'cloud',
    'cloud.rb'
  ]
  
  bootstrap_sh node, ['node', 'manager']
  configure_sh node, { cloud_config: CLOUD_CONFIG }
end
