# TheArchExperience
<sub>_The beginning of a potentially regrettable era_</sub>
### [THE INSTALLATION GUIDE](https://wiki.archlinux.org/title/Installation_guide)
### [THE MIRROR I USED](https://mirror.csclub.uwaterloo.ca/archlinux/iso/2026.03.01/)

## Chap. 1 - Installation media
Not much to see here.  
I took an old USB drive I had laying around and formatted it using diskpart as follows:  
```
list disk
select disk [x]
clean
format fs=fat32
assign letter=a
exit
```
this left me with a useable empty usb thumbdrive. Note this was an old and potentially buggy thumbdrive so I opted to do a full format as opposed to the ``` format fs=fat32 quick ```, which takes significantly longer...  
<ins>**Downloading the .iso**</ins>  
After going to the [mirror](https://mirror.csclub.uwaterloo.ca/archlinux/iso/2026.03.01/) website (which can be reached from the installation guide), I downloaded the full .iso which was called "archlinux-x86_64.iso". There's another download which has a timestamp and version id but apparently they're the exact same file with the same checksum so it doesn't matter which one you get.  

<ins>**Flashing to the drive**</ins>  
Since I'm on windows (10 IoT LTSC Enterprise on my Asus G14 GA401IV) I could conveniently use [Rufus](https://rufus.ie/en/) to flash the .iso I downloaded from the linked mirror onto the thumbdrive. There's a way to do this in linux but that's a later thing. Since I intend to use this boot drive purely as an installer, I have no need for a persistent partition (but if you intend to _boot_ from the drive you would want one). 
I set my persistent partition size to 0, partition scheme to GPT (for UEFI, though for legacy MBR is recommended for BIOS compatibility) and wrote the .iso file onto the thumbdrive.  

<ins>**Booting into the live environment**</ins>  
Now that I had a bootable drive ready, I could prepare my pc, in this case a thinkpad t450s[^1] (I know stereotypical) with an i5-5300U and a whopping 20GB of PC3L RAM.
* insert thumbdrive into the laptop, power on and hold f12 to enter boot menu.
* select the thumbdrive and choose installation medium. Let the installation happen.
* once the installation is complete you will want to configure keyboard, console (font), and time.

[^1]: it hurts me to use this lovely beast of a laptop as this was a laptop of many firsts (the thinkpad itself, as well as the mythical 16GB PC3L RAM stick and charger I found in the ewaste). My first thinkpad, first laptop I've ever use Linux on (Debian 12 "Bookworm"), and first linux device I had installed minecraft on and played as a client (server was hosted by a scrappy optiplex 3040 with an i3-6100 I had set up the earlier). I hope this laptop gets the love it deserves with this new OS...  

## Chap. 2 - The Arch Live Install Environment
<ins>**Configuring Keyboard and Console for Current Session**</ins>  
**0.0** Before anything else, here are some [handy keyboard shortcuts](https://wiki.archlinux.org/title/Linux_console#Keyboard_shortcuts) that work in the terminal.
```
poweroff
```
shuts down the system  
**1.0** to view available [keyboard layouts](https://wiki.archlinux.org/title/Linux_console/Keyboard_configuration), use
```
localectl list-keymaps
```  
to navigate, press "h" for help,  and "q" to exit.  
select the desired keymap using  
```loadkeys [layout_name]``` in my case, I will use the "us" layout: 
```
loadkeys us
```
Note that this keyboard layout assignment is only for the current session and is not saved, we will do that later.  
**2.0** now we can set the console [font and size](https://wiki.archlinux.org/title/Linux_console#Fonts).  
```setfont [font_name]``` sets the console font for the current session.  
```showconsolefont``` shows the glyph set for the current font.  
```ls /usr/share/kbd/consolefonts/``` lists available fonts to set, I used 
```
setfont ter-124b
```
to make things bigger and easier to read but for uber high density you can try "iso08.16", if you want uber massive font, you can try "ter-v32b".
Other terminus fonts I like are: lat0-16, ter-932n and solar24x32

<ins>**Verifying boot mode if unsure and** [**connecting to the interwebs**](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet)</ins>  
**0.0** 
```
cat /sys/firmware/efi/fw_platform_size
```
to check the UEFI bitness. If the command returns 64, then you are 64-bit x64, if it returns 32, then you are 32-bit IA32. If "No such file or directory" then you are probably using BIOS. My system was 64 so x64.  
**1.0** ```ip link``` to list network interfaces. In my case, I wanted to connect to my ethernet so this is when I plug in my ethernet cable. See the above link if you you want to connect to wireless.
  Since I am connecting to le web via ethernet, no additional setup was needed. Check that the indeface state is "UP" by retyping the command.

<ins>**Updating the System Clock**</ins>  
**0.0** ```timedatectl``` very simple :)

<ins>**TIME TO PARTITION!**</ins>  
**0.0** first, use ```lsblk``` or ```fdisk -l``` if you want more detal to identify storage devices, for the following steps, I use [fdisk](https://wiki.archlinux.org/title/Fdisk), but you can also use sfdisk, gdisk, or cfdisk.
  Since this is my first time installing arch, I will be doing a [single root partition scheme](https://wiki.archlinux.org/title/Partitioning#Single_root_partition) where we will need 3 partitions, one for EFI (boot), one for root (system), and one for swap (ram overflow). Since my laptop has 20GB of ram, I don't think I need a big swap, so I will leave it as a smaller partition. Here is the scheme I used:
  EFI: 1GB
  Root: 32GB
  Swap: 8GB
## Chap. 3 - Partitioning
From Here on out I am on Macbook pro 5 (A1278 2009 so things may not be applicable, reformat later)
```
fdisk /dev/<disk_name>
fdisk /dev/sda
```
once in fdisk, can use the following to partition/format disk
press "m" to open help menu
```
g        # create a new GPT partition table
n        # new partition
1        # partition number 1
         # first sector (press Enter)
+512M    # size of EFI partition
t        # change type
1        # choose EFI System
n        # new partition
2        # partition number 2
         # first sector (press Enter)
         # last sector (press Enter, use rest of disk)
w        # write changes (BE SURE BEFORE WRITTING CHANGES)
```
if things went bad and you need to wipe the disk u were partitioning, use ```wipefs -a /dev/sdX```
use ```lsblk``` to view partitions and their names or ```sudo fdisk -l``` if you want more detail

```
mkfs.fat -F32 /dev/sda1    # make sure the name matches! Set the first (EFI partition) to FAT32
mkfs.ext4 /dev/sda2    # set the storage (Linux root partition) to EXT4
```
After formatting, mount the partitions
```
mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/swap_partition  # if you made a swap partition
```

I accidentally misnamed my "/mnt/boot" directory "/mnt/bot"
delete directories with the following
```
mount | grep /mnt/bot    # check if empty
sudo rmdir /mnt/bot    # if directry is empty
sudo rm -r /mnt/bot    # if directory not empty and you wanna delete anyway
```

use the followign to check that directories are made as intended:
```
pwd
ls /mnt
ls /mnt/boot
```

PARTITTIONING DONE!
ON TO ISNTALL BASE SYSTEM

```
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```
Must be done in order

Once in chroot:
set time zone 
``` 
ln -sf /usr/share/zoneinfo/America/Vancouver /etc/localtime
hwclock --systohc
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "<desiredhostname>" > /etc/hostname
```

*** I FORGOT TO CONFIGURE NETWORKING!!!***
FIX HERE

also if you accidentally exit chroot, just remount boot directory and continue
```
mount /dev/sda2 /mnt
mount /dev/sda1 /mnt/boot
arch-chroot /mnt
```
set the password for root using 
```
passwd
```

configure [bootloader](https://wiki.archlinux.org/title/Arch_boot_process#Boot_loader):
```
ls /sys/firmware/efi  # if there are directories, then that means you booted in UEFI. You will need to install an UEFI bootloader ike GRUB
findmnt /mnt/boot /mnt/boot/efi /mnt/efi    # find your efi mount point in case u forgot (like I did)
lsblk -f    # alt method of identifying efi mount point. if just on sda1 (FAT32 (EFI) partition) then just use the /boot directory 
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=<boot mount directory> --bootloader-id=GRUB --recheck
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```

U ARE READY FOR REBOOT NOW!?
```
exit
umount -R /mnt
reboot
```

after reboot. login with "root" and the password you set

***SINCE I FORGOT TO CONFIGURE NETWORKING< HERE'S HOW TO FIX IT AFTER INSTALLING STUFFS***
1. remount installation  media and boot into the usb device (or whatever media)
2. remount and enter chroot
3. check if internet works on there with ``` ip link```
4. install networkmanager
```
pacman -S networkmanager
systemctl enable NetworkManager
```
5. exit, unmount and reboot
```
exit
umount -R /mnt
reboot
```

##
On macbook pro (2009 A1278) here are the commands I used once ebooted into live install environment:
```
loadkeys us
setfont ter-124b
ip link
timedatctl
lsblk
fdisk /dev/sda
```
clearing partitions in disk
```
p
d
1
d
2
...
w
```
reenter fdisk. Note may be prompted to remove vfat ssignature if there was an existing partition prior. you can overwrite it (Yes).
```
lsblk
fdisk /dev/sda
# once in fdisk
g
n
1
<enter>
+512M
t
1
n
2
<enter>
<enter>
w
```
```
lsblk
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2

mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
pwd
ls /mnt  # countains boot
ls /mnt/boot  # empty
```
```
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```
```
#   once in chroot
ln -sf /usr/share/zoneinfo/America/Vancouver /etc/localtime
hwclock --systohc
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
echo "<desiredhostname>" > /etc/hostname
```
verify (if needed)
```
readlink /etc/localtime
timedatectl
locale
hwclock --show
cat /etc/locale.conf
cat /etc/vconsole.conf
cat /etc/hostname
```
```
pacman -S networkmanager
systemctl enable NetworkManager
ip link
```
```
passwd
```
Configure bootloader
```
lsblk -f
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```
Exit and unmount then reboot
```
exit
umount -R /mnt
reboot
```
### Revisiting after making the others andd getting a bit more comfy with the CLI
# Github Installation
Typing all the commands each time can get a little annoying so I've automated it with shell scripts.
here's how to run them:
first connect to internet. if wireless follow:
```
iwctl
device list                             # Find your Wi-Fi interface (usually wlan0)
station wlan0 scan                      # Scan the room for Wi-Fi routers
station wlan0 get-networks              # List all available Wi-Fi networks
station wlan0 connect SSID_NAME         # Replace with your actual Wi-Fi name
```
*If your Wi-Fi requires a password, it will prompt you securely. Once connected, type `exit` to return to your normal prompt.*

Verify your network link is active by pinging a public server:
```
ping archinux.org
```
Connect to the github repo soo you can run the thingies
```
curl -L https://raw.githubusercontent.com/Gabs-L/TheArchExperience/main/install.sh -o install.sh
curl -L https://raw.githubusercontent.com/Gabs-L/TheArchExperience/main/chroot.sh -o chroot.sh
```
```
ls -lh
```
```
chmod +x install.sh
./install.sh
```


After reboot and checking the thing works by using sudo to install fastfetch:
```
curl -L https://raw.githubusercontent.com/Gabs-L/TheArchExperience/main/postInstall.sh -o postInstall.sh
chmod +x post-install.sh.
./post-install.sh
```
