conf.vm.define :stack do |node|
  machine_fullstack_vm node, host: 'stack'
end
