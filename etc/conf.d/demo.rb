conf.vm.define :demo do |node|
  machine_fullstack_vm node, host: 'demo'

  conf.vm.synced_folder BASE_DIR + '/etc/data.d/demo/etc/composer', REMOTE_BASE + '/etc/composer', type: 'rsync'

  # todo: get proper vcl configured on node to support the fpc here
  # todo: get ssl support running on vm to support secure URLs
  install_magento2 node, host: 'demo', database: 'magento2_ce', path: 'base'
  install_magento2 node, host: 'demo', database: 'magento2_ee', path: 'enterprise', enterprise: true

  install_magento1 node, host: 'demo', database: 'magento1_ce', path: 'base'
  install_magento1 node, host: 'demo', database: 'magento1_ee', path: 'enterprise', enterprise: true
end
