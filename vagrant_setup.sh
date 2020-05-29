# update mirrorlist because the list in the base box is old and broken
sudo reflector -l 200 -f 10 --sort rate -c 'United States' --save /etc/pacman.d/mirrorlist

# update and pull basic core development packages/utilities
sudo pacman -Syyuu --noconfirm
sudo pacman -S git python python-pip python2 python2-pip lib32-gcc-libs clang llvm \
pacman-contrib go base-devel vim tmux unzip zip unrar wget mlocate cmake python2-virtualenv \
netcat net-tools dnsutils man man-pages devtools --noconfirm

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
gpg --keyserver keyserver.ubuntu.com --recv-keys 79C43DFBF1CF2187
makepkg -si --noconfirm
cd ~

# gef and dependencies
yay -S python-capstone python-keystone python-unicorn python-ropper ropgadget gef-git --noconfirm
# Note if you want to use peda or pwndbg instead, you need to manually modify your ~/.gdbinit
echo "source /usr/share/gef/gef.py" > ~/.gdbinit

# pwndbg
sudo pacman -S pwndbg --noconfirm
echo "#source /usr/share/pwndbg/gdbinit.py" >> ~/.gdbinit

# peda
sudo pacman -S peda --noconfirm
echo "#source /usr/share/peda/peda.py" >> ~/.gdbinit

# pwntools
sudo pacman -S python-pwntools --noconfirm

# pwntools for python2
# The python2-pwntools package conflicts with the Python 3 version so install into a venv in ~/tools
cd ~/tools && virtualenv2 pwntools2 && source pwntools2/bin/activate
pip install pwntools
deactivate

# qemu
sudo pacman -S qemu-headless qemu-headless-arch-extra --noconfirm

# r2 and ghidra decompiler plugin
sudo pacman -S radare2 r2ghidra-dec --noconfirm

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

# fzf
sudo pacman -S fzf --noconfirm
echo "source /usr/share/fzf/key-bindings.bash" >> ~/.bashrc
echo "source /usr/share/fzf/completion.bash" >> ~/.bashrc

# powerline
sudo pacman -S powerline powerline-fonts powerline-vim python-pygit2 --noconfirm
tee -a ~/.bashrc << END 
powerline-daemon -q
POWERLINE_BASH_CONTINUATION=1
POWERLINE_BASH_SELECT=1
. /usr/share/powerline/bindings/bash/powerline.sh
END
echo "let g:powerline_pycmd=\"py3\"" >> ~/.vimrc
echo "set laststatus=2" >> ~/.vimrc
echo "let g:powerline_pycmd=\"py3\"" | sudo tee -a /root/.vimrc
echo "set laststatus=2" | sudo tee -a /root/.vimrc
echo "source /usr/lib/python3.8/site-packages/powerline/bindings/tmux/powerline.conf" >> ~/.tmux.conf

# minimal vim configuration
echo "syntax on" >> ~/.vimrc
echo "filetype plugin indent on" >> ~/.vimrc
echo "set tabstop=4" >> ~/.vimrc
echo "set shiftwidth=4" >> ~/.vimrc
echo "set expandtab" >> ~/.vimrc

# one_gadget
yay -S one_gadget --noconfirm

# enable ptrace
echo "kernel.yama.ptrace_scope = 0" | sudo tee /etc/sysctl.d/10-ptrace.conf

# Clean up
sudo paccache --remove --keep 0
rm -rf ~/aur
