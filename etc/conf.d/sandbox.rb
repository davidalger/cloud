if defined? SANDBOX_SITE and SANDBOX_SITE == true
  node_name = 'sandbox'

  conf.vm.define node_name do |node|
    machine_fullstack_vm node, host: node_name
  end

  conf.vm.define node_name + '2' do |node|
    machine_fullstack_vm node, host: node_name + '2'
  end
end
