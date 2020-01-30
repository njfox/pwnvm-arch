# pwnvm - Arch Linux Edition
A modified version of [OpenToAll's pwnvm](https://github.com/OpenToAllCTF/pwnvm) based on Arch Linux. pwnvm is a ready-to-go VM you can use to work on most pwn/reversing challenges in CTFs with little-to-no additional setup.

**Note:** Docker is now supported! Skip to [Docker Instructions](#running-in-docker) to get started. If you're using vagrant and a traditional hypervisor like VirtualBox, continue reading the original instructions below.

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

## Running in Docker
Docker is also supported as a lighter-weight alternative to a full virtual machine under a traditional hypervisor. Some caveats:

* Docker containers are designed to be immutable, meaning that by default your changes and files created inside the container will not be saved when you exit.
* If running on a Linux host, some system settings may need to be modified on the host for things to work correctly (e.g., core dump locations, ASLR). For this reason, I recommend vagrant if your host box is Linux.

### Installation
1. Install docker on your host operating system.
2. Run `docker pull njfox/pwnvm-arch`

To build the container locally instead, clone this repository and run the following command from the docker sub-directory:

```
$ git clone https://github.com/njfox/pwnvm-arch && cd pwnvm-arch/docker && docker build -t pwnvm-arch .
```

### Usage
```
$ docker run --rm -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined njfox/pwnvm-arch /bin/bash
```
Note the `--cap-add` and `--security-opt` flags are required for proper debugging within Docker.

If you've cloned this repository, you can use the convenient launcher script instead at `docker/run.sh`:
```
$ docker/run.sh
```

Tools, virtualenvs etc. are installed in `~/tools`.

#### Mounting Folders
To mount a folder from the host to persist changes (recommended), add the -v argument when launching the run script. The following example mounts `/home/nick/ctf` on the host to `/ctf` within the container:

```
$ docker/run.sh -v /home/nick/ctf:/ctf
```

#### Forwarding Ports
Add the `-p <host port>:<docker port>` switch to forward ports from the host. The following command launches the container with port 4444 on the host being forwarded to port 80 on the container:

```
$ docker/run.sh -p 4444:80
```

### Extending the Container
If you want to customize the pwnvm container, you can create your own Dockerfile with `FROM njfox/pwnvm-arch` at the top. Then any customizations you add will be layered on top of the base container.