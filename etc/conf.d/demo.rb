conf.vm.define :demo do |node|
  machine_fullstack_vm node, host: 'demo'
  conf.vm.synced_folder BASE_DIR + '/etc/data.d/demo/etc/composer', REMOTE_BASE + '/etc/composer', type: 'rsync'
  install_magento2 node, host: 'demo', database: 'magento2_ee', path: 'enterprise', enterprise: true
  install_magento2 node, host: 'demo', database: 'magento2_ce', path: 'base'
end
