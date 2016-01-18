conf.vm.define :demo do |node|
  machine_fullstack_vm node, host: 'demo'
  
  conf.vm.synced_folder BASE_DIR + '/etc/conf.d/demo.etc', REMOTE_BASE + '/etc', type: 'rsync'
  
  node.vm.provision :shell, run: 'always' do |conf|
    conf.name = 'rsync html'
    conf.inline = "
      rsync -a #{REMOTE_BASE}/etc/html/ /var/www/html/
      chown -R apache:apache /var/www/html/
    "
  end
  
  install_magento2 node, host: 'demo', database: 'magento2_ce', path: 'base'
  install_magento2 node, host: 'demo', database: 'magento2_ee', path: 'enterprise', enterprise: true
  
  install_magento1 node, host: 'demo', database: 'magento1_ce', path: 'base'
  install_magento1 node, host: 'demo', database: 'magento1_ee', path: 'enterprise', enterprise: true
end
