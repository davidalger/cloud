conf.vm.define :demo do |node|
  machine_fullstack_vm node, host: 'demo'
  
  conf.vm.synced_folder BASE_DIR + '/etc/conf.d/demo.etc', REMOTE_BASE + '/etc', type: 'rsync'
  
  # todo: get proper vcl configured on node to support the fpc here
  # todo: get ssl support running on vm to support secure URLs
  # todo: get index page in place
  # todo: find out if nuc1 demos still are needed
  install_magento2 node, host: 'demo', database: 'magento2_ce', path: 'base'
  install_magento2 node, host: 'demo', database: 'magento2_ee', path: 'enterprise', enterprise: true
  
  install_magento1 node, host: 'demo', database: 'magento1_ce', path: 'base'
  install_magento1 node, host: 'demo', database: 'magento1_ee', path: 'enterprise', enterprise: true
end
