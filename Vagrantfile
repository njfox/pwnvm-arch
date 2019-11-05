# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.ssh.username = "vagrant"
  config.ssh.forward_agent = true
  config.vm.provision :shell, :path => "vagrant_setup.sh", :privileged => false

  name = "pwnvm-arch"
  memory = "2048"

  config.vm.define "pwnvm-arch", primary: true do |a64|
    a64.vm.box = "archlinux/archlinux"
    a64.vm.provider "virtualbox" do |vb, override|
      override.vm.network "private_network", ip: "10.10.10.10"
      # Sync a folder between the host and all guests.
      # Uncomment this line (and adjust as you like)
      # override.vm.synced_folder "~/ctf", "/ctf"

      vb.name = name
      vb.memory = memory
      vb.gui = false
    end
    a64.vm.provider "libvirt" do |lv, override|
      override.vm.network "private_network",
        :ip => "10.10.10.10"
      # Sync a folder between the host and all guests.
      # Uncomment this line (and adjust as you like)
      # NOTE: Requires installation of the nfs-server package on the host machine
      # override.vm.synced_folder "~/ctf", "/ctf", :nfs => true
      override.vm.hostname = name
      lv.memory = memory
    end
  end
end
