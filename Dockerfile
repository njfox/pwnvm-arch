FROM archlinux

# Create normal user so makepkg is happy
RUN useradd -m user && passwd -d user \
  && printf 'user ALL=(ALL) ALL\n' | tee -a /etc/sudoers

# Allow installation of manpages with packages
RUN sed -i '/NoExtract  = usr\/share\/man\//d' /etc/pacman.conf

# Bump cpu cores for compiling packages
RUN sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j4"/' /etc/makepkg.conf

# update and pull basic core development packages/utilities
RUN pacman -Syu --noconfirm \
  && pacman -S git python python-pip python2 python2-pip lib32-gcc-libs clang llvm \
  pacman-contrib go base-devel vim tmux unzip zip unrar wget mlocate cmake python2-virtualenv \
  netcat net-tools dnsutils sudo man man-pages --noconfirm

# Switch to normal user for the rest of the build
USER user:user

RUN echo "set -g mouse on" > ~/.tmux.conf

RUN mkdir ~/tools

# yay for AUR packages
RUN mkdir /tmp/aur && cd /tmp/aur \
  && git clone https://aur.archlinux.org/yay.git \
  && cd yay && makepkg -si --noconfirm \
  && cd ~

# The official glibc doesn't include symbols, but we can modify the package to include them ourselves
# https://github.com/bet4it/build-an-efficient-pwn-environment#glibc
RUN cd ~/tools && yay -G glibc && cd glibc \
  && sed -i 's/options=(!strip staticlibs)/options=(!strip debug staticlibs)/' PKGBUILD \
  && makepkg -si --noconfirm \
  && cd ~

# gef and dependencies
RUN yay -S python-capstone python-keystone python-unicorn-git python-ropper ropgadget gef-git --noconfirm \
  # Note if you want to use peda or pwndbg instead, you need to manually modify your ~/.gdbinit
  && echo "source /usr/share/gef/gef.py" > ~/.gdbinit

# pwndbg
RUN sudo pacman -S pwndbg --noconfirm && echo "#source /usr/share/pwndbg/gdbinit.py" >> ~/.gdbinit

# peda
RUN sudo pacman -S peda --noconfirm && echo "#source /usr/share/peda/peda.py" >> ~/.gdbinit

# pwntools
RUN yay -S python-pwntools-git --noconfirm

# pwntools for python2
# The python2-pwntools package conflicts with the Python 3 version so install into a venv in ~/tools
RUN cd ~/tools && virtualenv2 pwntools2 && source pwntools2/bin/activate \
  && pip install pwntools && deactivate

# qemu
RUN sudo pacman -S qemu-headless qemu-headless-arch-extra --noconfirm

# r2
RUN sudo pacman -S radare2 --noconfirm

# angr
# The python-angr-git AUR package requires gcc7 being built from source (which takes ages)
# and also tramples a bunch of other dependencies like z3, so we're just going to use a 
# venv to install it instead
RUN cd ~/tools && python -m venv angr && source angr/bin/activate \
  && pip install angr && deactivate

# binwalk
RUN sudo pacman -S binwalk --noconfirm

# fixenv
RUN sudo wget -O /usr/local/bin/fixenv https://raw.githubusercontent.com/hellman/fixenv/master/r.sh \
  && sudo chmod +x /usr/local/bin/fixenv

# z3
RUN sudo pacman -S python-z3 --noconfirm

# Clean up
RUN rm -rf /tmp/aur && rm -rf ~/.cache/yay

WORKDIR /home/user