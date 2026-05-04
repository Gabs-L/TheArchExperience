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
wpctl
brightnessctl
yambar
htop
```
after rebooting from live install media:
```
pacman -Syu  
