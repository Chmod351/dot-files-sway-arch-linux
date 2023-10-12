# My-config

my config to my system, i will use [arch](https://aur.archlinux.org/), [sway](https://swaywm.org/) and neovim

first run:

    sudo pacman -S sway networkmanager intel-ucode lightdm lightdm-gtk-greeter firefox
    
next:

```
systemctl enable lightdm.service
```

next:

```
sudo pacman -S picom neovim  lutris wine giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo  libxcomposite lib32-libxcomposite libxinerama lib32-libxinerama ncurses lib32-ncurses ocl-icd lib32-ocl-icd libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader xf86-video-intel libva lib32-libva vulkan-icd-loader lib32-vulkan-icd-loader nerd-fonts-complete alacritty ranger tmux git nodejs npm flatpak
```
next:

```
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
``` 

alias:

`nvim  ~/.bashrc`

```
alias update="sudo pacman -Syu"
alias install="sudo pacman -Sy && sudo pacman -S"
alias finstall="flatpak install"

alias alias='nvim ~/.bashrc'
alias gch="git checkout -b"
alias gst="git status"
alias save="!git add -A && git commit -m 'SAVEPOINT'"
alias gcm="git commit -am" 
```


