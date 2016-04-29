conf.vm.define :sandbox do |node|
  machine_fullstack_vm node, host: 'sandbox'
end
