# update and pull basic core development packages/utilities
sudo pacman -Syyu --noconfirm
sudo pacman -S git python python-pip python2 python2-pip lib32-gcc-libs clang llvm \
pacman-contrib go base-devel vim tmux unzip zip unrar wget mlocate cmake python2-virtualenv \
netcat net-tools dnsutils man man-pages --noconfirm

echo "set -g mouse on" > ~/.tmux.conf
mkdir ~/tools

# yay for AUR packages
mkdir aur && cd aur
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si --noconfirm
cd ~

# The official glibc doesn't include symbols, but we can modify the package to include them ourselves
# https://github.com/bet4it/build-an-efficient-pwn-environment#glibc
cd ~/tools && yay -G glibc && cd glibc
sed -i 's/options=(!strip staticlibs)/options=(!strip debug staticlibs)/' PKGBUILD
gpg --recv-key 79C43DFBF1CF2187
makepkg -si --noconfirm
cd ~

# gef and dependencies
yay -S python-capstone python-keystone python-unicorn-git python-ropper ropgadget gef-git --noconfirm
# Note if you want to use peda or pwndbg instead, you need to manually modify your ~/.gdbinit
echo "source /usr/share/gef/gef.py" > ~/.gdbinit

# pwndbg
sudo pacman -S pwndbg --noconfirm
echo "#source /usr/share/pwndbg/gdbinit.py" >> ~/.gdbinit

# peda
sudo pacman -S peda --noconfirm
echo "#source /usr/share/peda/peda.py" >> ~/.gdbinit

# pwntools
yay -S python-pwntools-git --noconfirm

# pwntools for python2
# The python2-pwntools package conflicts with the Python 3 version so install into a venv in ~/tools
cd ~/tools && virtualenv2 pwntools2 && source pwntools2/bin/activate
pip install pwntools
deactivate

# qemu
sudo pacman -S qemu-headless qemu-headless-arch-extra --noconfirm

# r2
sudo pacman -S radare2 --noconfirm

# angr
# The python-angr-git AUR package requires gcc7 being built from source (which takes ages)
# and also tramples a bunch of other dependencies like z3, so we're just going to use a 
# venv to install it instead
cd ~/tools && python -m venv angr && source angr/bin/activate
pip install angr
deactivate

# binwalk
sudo pacman -S binwalk --noconfirm

# fixenv
sudo wget -O /usr/local/bin/fixenv https://raw.githubusercontent.com/hellman/fixenv/master/r.sh
sudo chmod +x /usr/local/bin/fixenv

# z3
sudo pacman -S python-z3 --noconfirm

# AFL
sudo pacman -S afl afl-utils --noconfirm

# Clean up
sudo paccache --remove --keep 0
rm -rf ~/aur
