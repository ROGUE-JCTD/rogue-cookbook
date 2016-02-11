# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.omnibus.chef_version = '12.6'
  config.vm.hostname = 'opengeonode'

  config.vm.box = 'ubuntu-14.04-opscode'
  config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-14.04_chef-provisionerless.box'

  config.vm.provider 'virtualbox' do |v|
    v.memory = 3072
    v.cpus = 2
  end

  config.vm.network :private_network, ip: "192.168.99.101"
  config.berkshelf.berksfile_path = 'Berksfile'
  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = 'cookbooks'
    chef.nodes_path = 'nodes'
    chef.run_list = [
      'recipe[rogue::postgresql]',
      'recipe[rogue]'
    ]
  end
end
