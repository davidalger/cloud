conf.vm.define :demo do |node|
  machine_fullstack_vm node, host: 'demo'
  
  conf.vm.synced_folder BASE_DIR + '/etc/conf.d/demo.etc', REMOTE_BASE + '/etc', type: 'rsync'
  
  node.vm.provision :shell, run: 'always' do |conf|
    conf.name = 'rsync html'
    conf.inline = "
      rsync -a #{REMOTE_BASE}/etc/www/ /var/www/
      chown -R apache:apache /var/www/
    "
  end
  
  install_magento2 node, host: 'demo', database: 'magento2_ce', path: 'v2/base'
  install_magento2 node, host: 'demo', database: 'magento2_ee', path: 'v2/enterprise', enterprise: true
  
  install_magento1 node, host: 'demo', database: 'magento1_ce', path: 'v1/base'
  install_magento1 node, host: 'demo', database: 'magento1_ee', path: 'v1/enterprise', enterprise: true
end
