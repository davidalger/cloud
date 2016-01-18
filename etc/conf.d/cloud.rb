conf.vm.define :cloud do |node|
  node.vm.hostname = 'cloud.' + CLOUD_DOMAIN
  node.vm.provider :digital_ocean do | provider, override |
    provider.size = '512mb'
  end
  
  # creates and stores a persistent key/pair locally
  node.trigger.before [ :up, :provision, :reload, :rebuild ] do
    unless File.exist? BASE_DIR + '/etc/conf.d/cloud.etc/ssh/id_rsa'
      run "mkdir -p '#{BASE_DIR}/etc/conf.d/cloud.etc/ssh'"
      run "ssh-keygen -N '' -t rsa -f '#{BASE_DIR}/etc/conf.d/cloud.etc/ssh/id_rsa' -C 'vagrant@#{node.vm.hostname}'"
    end
  end
  
  # moves the persistent key/pair into place on remote node
  node.vm.provision :shell, run: 'always' do |conf|
    conf.name = 'place ssh keys'
    conf.inline = "
      key_path=#{REMOTE_BASE}/etc/conf.d/cloud.etc/ssh/id_rsa
      
      if [[ -f $key_path ]]; then
        mkdir -p ~/.ssh
        
        mv $key_path ~/.ssh
        mv $key_path.pub ~/.ssh/
        
        chmod 700 ~/.ssh
        chmod 600 ~/.ssh/id_rsa ~/.ssh/id_rsa.pub
      fi
    "
  end
  
  node.vm.synced_folder BASE_DIR + '/etc/conf.d/cloud.etc', REMOTE_BASE + '/etc', type: 'rsync'
  node.vm.synced_folder BASE_DIR + '/etc/conf.d', REMOTE_BASE + '/etc/conf.d', type: 'rsync'
  
  bootstrap_sh node, ['node', 'manager']
end
