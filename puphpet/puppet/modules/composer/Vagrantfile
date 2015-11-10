# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.5.1"

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant-root", "1"]
  end

  config.vm.box = "puppetlabs/ubuntu-12.04-64-puppet"
  config.vm.synced_folder "./", "/etc/puppet/modules/composer"
  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "spec/fixtures/manifests"
    puppet.manifest_file  = "vagrant.pp"
    puppet.module_path = "spec/fixtures/modules"
    puppet.hiera_config_path = "spec/fixtures/puppet/hiera.yaml"
  end
end
