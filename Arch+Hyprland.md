# Arch + Hyprland From Scratch 👺
_(I didn't know about archinstall or how to copy github dotfiles)_

## _Arch+Hyprland on T450s:_
## === initial setup ===
```
setfont ter-124b
timedatectl set-ntp true
```

check if time is synced, and internet connection is good:
```
timedatectl status
ip link
ping archlinux.org
```

## === partitioning ===
```
lsblk
fdisk /dev/[disk_name]
```
in fdisk:
```
g        # create new GPT partition table
n        # new partition
1        # partition number 1 (sdx1, for boot)
enter    # first sector (press Enter)
+512M    # size of EFI partition
t        # change type
1        # choose EFI System
n        # new partition
2        # partition number 2 (sdx2, for linux)
enter    # first sector (press Enter)
enter    # last sector (press Enter, use rest of disk)
w        # write changes (BE SURE BEFORE WRITTING CHANGES)
```

## === format partitions ===
```
lsblk
mkfs.fat -F32 /dev/[efi_partition(sdx1)]
mkfs.ext4 /dev/[linux_partition(sdx2)]
```
**--- wiping a drive ---**  
*Note this may take a very long time
```dd if=/dev/zero of=/dev/sdx bs=16M status=progress```  
```wipefs -a /dev/sdx```

## === mounting partitions ===
```
mount /dev/[linux_partition(sdx2)] /mnt
mkdir -p /mnt/boot
mount /dev/[efi_partition(sdx1)] /mnt/boot
```
```
ls /mnt
ls /mnt/boot
```

## === install base system ===
```
pacstrap -K /mnt base linux linux-firmware intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

## === setting time and base config ===
```
ln -sf /usr/share/zoneinfo/America/Vancouver /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.conf
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "[desiredhostname]" > /etc/hostname
```

## === install network manager ===
```
pacman -Syu networkmanager sudo nvim
systemctl enable NetworkManager
```

## === add a user ===
```
useradd -m -G wheel,video,audio,render,input -s /bin/bash [username]
passwd [username]
EDITOR=nvim visudo
  // uncomment "%wheel ALL=(ALL:ALL) ALL"
```

## === clean boot manager ===
```
pacman -S grub efibootmgr
efibootmgr -v
efibootmgr -b [boot_option_to_remove] -B
```
use the hex id number, eg. 0007, or 000A

## === configure and install bootloader === 
```
lsblk -f
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```

## === unmount and reboot ===
```
exit
umount -R /mnt
reboot
```

## _Post Reboot_
**Some useful bits/bobs**
## === reenter chroot from install media ===
first shutdown pc, and boot back into install media
```
mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
arch-chroot /mnt
```

## _PACKAGES_
## === Setting terminal font ===
*Not the terminal emulator font
```
sudo pacman -Syu fastfetch
sudo pacman -S terminus-font ttf-font-awesome
nvim /etc/vconsole.conf
	FONT=ter-124b
```
default:     lat0-16  
large:       ter-932n  
uber large:  solar24x32  

## === The packages ===
*Since I know I don't have a dGPU and will be using the iGPU on the thinkpad i5-5300U (Thinkpad T450s), I know I need to install intel display managers and drivers
but this might not be the case for you. Check which display device you have with ```lspci -k | grep -A 2 -E "(VGA|3D)"```
```
sudo pacman -Syu
mesa
vulkan-intel
intel-media-driver
alacritty
hyprland
waybar
wofi
thunar
tumbler
```

=== greeter ===
```
lightdm
lightdm-gtk-greeter
```

=== basic desktop portals ===
```
sudo pacman -Syu
xdg-desktop-portal
xdg-desktop-portal-gtk
xdg-desktop-portal-hyprland
xorg-xwayland
```

=== audio ===
```
pipewire
pipewire-pulse
// pipewire-alsa
// pipewire-jack
wireplumber
sof-firmware
// alsa-firmware
// alsa-ucm-conf
alsa-utils
```

=== monitor/screen ===
```
brightnessctl
grim
slurp
```

=== other ===
```
base-devel
wl-clipboard
```

=== apps ===
```
firefox
```

## Config Files 
*I recommend rebooting here before making and setting all the config files
=== hyprland ===
```
mkdir -p ~/.config/hypr
cp /usr/share/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
nvim ~/.config/hypr/hyprland.conf
```
[configuration](<https://wiki.hypr.land/Configuring/>)

env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland
env = LIBVA_DRIVER_NAME,iHD

$terminal = alacritty
$fileManager = thunar
$menu = wofi --show drun
$browser = firefox

exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = waybar

shadow -> enabled = false
blur -> enabled = false
animations -> enabled = false
touchpad -> natural_scroll = true

bind = , Print, exec grim -g "$(slurp)" - | wl-copy

=== lightdm ==  
Under [Seat:*] 
```
sudo nvim /etc/lightdm/lightdm.conf
	greeter-session=lightdm-gtk-greeter
	user-session=hyprland
sudo systemctl enable lightdm
```

== audio ===
```
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service
alsamixer
```
run ``` aplay -l ``` to list audio devices

## Cleanup
```
sudo pacman -Rs $(pacman -Qdtq)
```

## In Compositor Setup
##=== Firefox ===
media.ffmpeg.vaapi.enabled -> true
media.ffvpx.enabled -> false
media.rdd-ffmpeg.enabled -> true
gfx.webrender.all -> true
layout.css.font-visibility.standard -> true
layers.acceleration.force-enabled -> true
browser.tabs.unloadOnLowMemory -> true
dom.ipc.processCount -> 4
browser.low_commit_space_threshold_mb -> 200
image.mem.decode_on_draw -> true
extensions.pocket.enabled -> false

--- junk removal: ---
browser.newtabpage.activity-stream.feeds.telemetry -> false
browser.newtabpage.activity-stream.telemetry -> false
datareporting.healthreport.uploadEnabled -> false
browser.newtabpage.activity-stream.feeds.section.topstories -> false


todo:
-screenshots
-waybar
-OBS
-fastfetch config
-hyprlock
-github -> dotfiles
-hyprpaper

## Hyprland Shortcuts (me-edition)
general {
	gaps_in = 5
	gap_out = 5
	border_size = 1
	resize_on_border = true
}

bind = $mainMod, RETURN, exec,  $terminal
bind = $mainMod, Q, killactive,
bind = $mainMod, E, $fileManager
bindl = $mainMod, mainMod_L, exec, pkill [menu] || $menu
