# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANT_CONFIG_VERSION = "2"
VAGRANT_BOX_NAME = 'lorem'.gsub('-', '_')

Vagrant.configure(VAGRANT_CONFIG_VERSION) do |config|
  config.vm.define VAGRANT_BOX_NAME do |box|
    box.vm.box = "ubuntu/xenial64"
    box.vm.hostname = "#{VAGRANT_BOX_NAME}.vagrant"
    box.vm.network "private_network", type: "dhcp"
    box.vm.provider "virtualbox" do |vb|
      vb.memory = "512"
      vb.cpus = 1
    end

    box.vm.provision "shell", privileged: true, name: "Install python", inline: <<-SHELL
      which python || {
        apt-get update
        apt-get install -y python-minimal
      }
    SHELL

    box.vm.provision "ansible" do |ansible|
      ansible.playbook = "tests/main.yml"
      ansible.sudo = true
      ansible.limit = 'all'
      ansible.groups = {
        'all:vars' => {
          'vagrant' => true,
        }
      }
    end

  end
end
