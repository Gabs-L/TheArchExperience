To format later, but here is my learning doc on how to install arch+hyprland:
refer to arch install to get base system first.
Installing stuffs once logged in:
additional step before rebooting is install graphics drivers (not generally necessary):
```
lspci -k | grep -A 2 -E "(VGA|3D)"
pacman -S
mesa
alacritty
hyprland
wofi
thunar
lightdm
lightdm-gtk-greeter
xdg-desktop-portal
xdg-desktop-portal-gtk
xdg-desktop-portal-hyprland
xorg-xwayland
pipewire
wireplumber
pipewire-pulse
brightnessctl
htop
nvim
firefox
```
Enable/Configure before reboot:
```
sudo systemctl enable lightdm
systemctl --user enable pipewire.service pipewire.socket
systemctl --user enable pipewire-pulse.service pipewire-pulse.socket
systemctl --user enable wireplumber.service
```
In /etc/lightdm/lightdm.conf, set:
```
greeter-session=lightdm-gtk-greeter
```
Make an account (root login is disabled by default I think)
```
useradd -m -G wheel -s /bin/bash <username>
passwd <username>
```
Configure the hyprland config file in ~/.config/hypr/hyprland.conf
```
ls ~/.config
mkdir -p ~/.config/hypr
cp /usr/share/hypr/hyprland.conf ~/.config/hypr/hyprland.conf   # if not already made
nvim ~/.config/hypr/hyprland.conf
```
edit the following:


