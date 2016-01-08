conf.vm.define :cloud do |node|
  node.vm.hostname = 'cloud.' + CLOUD_DOMAIN
  node.vm.provider :digital_ocean do | provider, override |
    provider.size = '512mb'
  end
  bootstrap_sh node, ['node', 'manager']
end
