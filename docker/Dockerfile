FROM archlinux

# Create normal user so makepkg is happy
RUN useradd -m user && passwd -d user \
  && printf 'user ALL=(ALL) ALL\n' | tee -a /etc/sudoers

# Allow installation of manpages with packages
RUN sed -i '/NoExtract  = usr\/share\/man\//d' /etc/pacman.conf

# Bump cpu cores for compiling packages
RUN sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j4"/' /etc/makepkg.conf

# update mirrorlist
RUN pacman -Syy reflector pacman-contrib --noconfirm \
  && reflector -l 200 -f 10 --sort rate -c 'United States' --save /etc/pacman.d/mirrorlist \
  && paccache --remove --keep 0

# update and pull basic core development packages/utilities
RUN pacman -Syyuu --noconfirm \
  && pacman -S git python python-pip python2 python2-pip lib32-gcc-libs clang llvm \
  go base-devel vim tmux unzip zip unrar wget mlocate cmake python2-virtualenv \
  netcat net-tools dnsutils sudo man man-pages --noconfirm \
  && paccache --remove --keep 0

# Switch to normal user for the rest of the build
USER user:user

RUN echo "set -g mouse on" > ~/.tmux.conf

RUN mkdir ~/tools

# yay for AUR packages
RUN mkdir /tmp/aur && cd /tmp/aur \
  && git clone https://aur.archlinux.org/yay.git \
  && cd yay && makepkg -si --noconfirm \
  && cd ~ && rm -rf /tmp/aur/yay \
  && sudo paccache --remove --keep 0

# The official glibc doesn't include symbols, but we can modify the package to include them ourselves
# https://github.com/bet4it/build-an-efficient-pwn-environment#glibc
RUN cd /tmp/aur && yay -G glibc && cd glibc \
  && sed -i 's/options=(!strip staticlibs)/options=(!strip debug staticlibs)/' PKGBUILD \
  && gpg --keyserver keyserver.ubuntu.com --recv-keys 79C43DFBF1CF2187 16792B4EA25340F8 7273542B39962DF7 BC7C7372637EC10C \
  && makepkg -si --noconfirm \
  && cd ~ && rm -rf /tmp/aur/glibc

# gef and dependencies
RUN yay -S python-capstone python-keystone python-unicorn python-ropper ropgadget gef-git --noconfirm \
  # Note if you want to use peda or pwndbg instead, you need to manually modify your ~/.gdbinit
  && echo "source /usr/share/gef/gef.py" > ~/.gdbinit \
  && rm -rf ~/.cache/yay \
  && sudo paccache --remove --keep 0

# pwndbg
RUN sudo pacman -S pwndbg --noconfirm && echo "#source /usr/share/pwndbg/gdbinit.py" >> ~/.gdbinit \
  && sudo paccache --remove --keep 0

# peda
RUN sudo pacman -S peda --noconfirm && echo "#source /usr/share/peda/peda.py" >> ~/.gdbinit \
  && sudo paccache --remove --keep 0

# pwntools
RUN sudo pacman -S python-pwntools --noconfirm \
  && sudo paccache --remove --keep 0

# pwntools for python2
# The python2-pwntools package conflicts with the Python 3 version so install into a venv in ~/tools
RUN cd ~/tools && virtualenv2 pwntools2 && source pwntools2/bin/activate \
  && pip install pwntools && deactivate

# qemu
RUN sudo pacman -S qemu-headless qemu-headless-arch-extra --noconfirm \
  && sudo paccache --remove --keep 0

# r2 and ghidra decompiler plugin
RUN sudo pacman -S radare2 r2ghidra-dec --noconfirm \
  && sudo paccache --remove --keep 0

# angr
# The python-angr-git AUR package requires gcc7 being built from source (which takes ages)
# and also tramples a bunch of other dependencies like z3, so we're just going to use a 
# venv to install it instead
RUN cd ~/tools && python -m venv angr && source angr/bin/activate \
  && pip install angr && deactivate

# binwalk
RUN sudo pacman -S binwalk --noconfirm \
  && sudo paccache --remove --keep 0

# fixenv
RUN sudo wget -O /usr/local/bin/fixenv https://raw.githubusercontent.com/hellman/fixenv/master/r.sh \
  && sudo chmod +x /usr/local/bin/fixenv

# z3
RUN sudo pacman -S python-z3 --noconfirm \
  && sudo paccache --remove --keep 0

# AFL
RUN sudo pacman -S afl afl-utils --noconfirm \
  && sudo paccache --remove --keep 0

# fzf
RUN sudo pacman -S fzf --noconfirm \
  && echo "source /usr/share/fzf/key-bindings.bash" >> ~/.bashrc \
  && echo "source /usr/share/fzf/completion.bash" >> ~/.bashrc \
  && sudo paccache --remove --keep 0

# powerline
RUN sudo pacman -S powerline powerline-fonts powerline-vim python-pygit2 --noconfirm \
  && echo "powerline-daemon -q" >> ~/.bashrc \
  && echo "POWERLINE_BASH_CONTINUATION=1" >> ~/.bashrc \
  && echo "POWERLINE_BASH_SELECT=1" >> ~/.bashrc \
  && echo ". /usr/share/powerline/bindings/bash/powerline.sh" >> ~/.bashrc \
  && echo "let g:powerline_pycmd=\"py3\"" >> ~/.vimrc \
  && echo "set laststatus=2" >> ~/.vimrc \
  && echo "let g:powerline_pycmd=\"py3\"" | sudo tee -a /root/.vimrc \
  && echo "set laststatus=2" | sudo tee -a /root/.vimrc \
  && echo "source /usr/lib/python3.8/site-packages/powerline/bindings/tmux/powerline.conf" >> ~/.tmux.conf \
  && sudo paccache --remove --keep 0

# minimal vim configuration
RUN echo "syntax on" >> ~/.vimrc \
  && echo "filetype plugin indent on" >> ~/.vimrc \
  && echo "set tabstop=4" >> ~/.vimrc \
  && echo "set shiftwidth=4" >> ~/.vimrc \
  && echo "set expandtab" >> ~/.vimrc

# one_gadget
RUN yay -S one_gadget --noconfirm \
  && rm -rf ~/.cache/yay \
  && sudo paccache --remove --keep 0

# patchelf
RUN sudo pacman -S patchelf --noconfirm \
  && sudo paccache --remove --keep 0

# Clean up
RUN rm -rf /tmp/aur

WORKDIR /home/user
