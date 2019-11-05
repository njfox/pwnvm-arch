# pwnvm - Arch Linux Edition
A modified version of [OpenToAll's pwnvm](https://github.com/OpenToAllCTF/pwnvm) based on Arch Linux. pwnvm is a ready-to-go VM you can use to work on most pwn/reversing challenges in CTFs with little-to-no additional setup.

## Installation
1. Install a hypervisor. The following hypervisors are supported:
   * VirtualBox (default, recommended)
   * libvirt (requires vagrant-libvirt provider, which can be found [here](https://github.com/vagrant-libvirt/vagrant-libvirt))
2. Install Vagrant:
   * OSX: `brew cask install vagrant`
   * Linux: `sudo apt-get install vagrant`
3. Clone this project and `cd` to clone dir.
4. Build VM and provision:
   * If using VirtualBox: `vagrant up`
   * If using libvirt: `vagrant up --provider=libvirt`

## Usage
`vagrant ssh`

### File sharing
By default the directory that contains the _Vagrantfile_ is shared with the vm and is mounted at _/vagrant_, so you can move files between the host and guest by simply moving files to/from there.

If using libvirt, you will first need to install an NFS server on the host and start the service (`sudo pacman -S nfs-utils && systemctl start nfs-server`).

### Services
The VM exposes its IP on a private network on ip 10.10.10.10. You can run whatever services you like on the VM and they will be accessible from the host through that IP.

### Managing VMs
You should never have to open your hypervisor to manage the VMs. Everything can be done through `vagrant`, but must be done from the directory where the _Vagrantfile_ lives.

* See VMs: `vagrant global-status`
* Reprovision: `vagrant provision [<vm>]`
* SSH: `vagrant ssh [<vm>]`
* Adopt changes to _Vagrantfile_: `vagrant reload [<vm>]`
* Bring down VM: `vagrant halt [<vm>]`
* Bring up VM: `vagrant up [<vm>]`
* Scrap VM: `vagrant destroy [<vm>]`
