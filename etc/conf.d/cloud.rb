conf.vm.define :cloud do |node|
  node.vm.hostname = 'cloud.' + CLOUD_DOMAIN
  node.vm.provider :digital_ocean do | provider, override |
    provider.size = '512mb'
  end

  conf.vm.synced_folder BASE_DIR + '/etc/conf.d/cloud.etc', REMOTE_BASE + '/etc', type: 'rsync'
  conf.vm.synced_folder BASE_DIR + '/etc/conf.d', REMOTE_BASE + '/etc/conf.d', type: 'rsync'

  bootstrap_sh node, ['node', 'manager']
end
