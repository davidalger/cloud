conf.vm.define :demo do |node|
  machine_fullstack_vm node, host: 'demo'
  conf.vm.synced_folder BASE_DIR + '/etc/data.d/demo/etc/composer', REMOTE_BASE + '/etc/composer', type: 'rsync'
  mage2_install node, host: 'demo', db_name: 'mage2_demo'
end
