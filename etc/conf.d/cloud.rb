conf.vm.define :cloud do |node|
  node.vm.hostname = 'cloud.' + CLOUD_DOMAIN
  node.vm.provider :digital_ocean do | provider, override |
    provider.size = '512mb'
  end
  conf.vm.synced_folder BASE_DIR + '/etc', REMOTE_BASE + '/etc', type: 'rsync', rsync__exclude: [
    'assassin.flag',
    # 'config.rb'
  ]
  bootstrap_sh node, ['node', 'manager']
end
