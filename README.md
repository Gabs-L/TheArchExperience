# TheArchExperience
<sub>_The beginning of a potentially regrettable era_</sub>
### [THE INSTALLATION GUIDE](https://wiki.archlinux.org/title/Installation_guide)
### [THE MIRROR I USED](https://mirror.csclub.uwaterloo.ca/archlinux/iso/2026.03.01/)

Link spam: 

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

<ins>**Configuring Keyboard and Console for Current Session**</ins>  
0.0 Before anything else, here are some [handy keyboard shortcuts](https://wiki.archlinux.org/title/Linux_console#Keyboard_shortcuts) that work in the terminal.
  ```poweroff``` shuts down the system
1.0 to view available [keyboard layouts](https://wiki.archlinux.org/title/Linux_console/Keyboard_configuration), use
  ```localectl list-keymaps```
  to navigate, press "h" for help,  and "q" to exit.
  select the desired keymap using
  ```loadkeys [layout_name]``` in my case, I will use the "us" layout: ```loadkeys us```
  Note that this keyboard layout assignment is only for the current session and is not saved, we will do that later.
2.0 now we can set the console [font and size](https://wiki.archlinux.org/title/Linux_console#Fonts).
  ```setfont [font_name]``` sets the console font for the current session.
  ```showconsolefont``` shows the glyph set for the current font.
  ```ls /usr/share/kbd/consolefonts/``` lists available fonts to set, I used ```setfont ter-124b``` to make things bigger and easier to read but for uber high density you can try "iso08.16", if you want uber massive font, you can try "ter-v32b".  

<ins>**Verifying boot mode if unsure and** [**connecting to the interwebs**](https://wiki.archlinux.org/title/Installation_guide#Connect_to_the_internet)</ins>  
0.0 ```# cat /sys/firmware/efi/fw_platform_size``` to check the UEFI bitness. If the command returns 64, then you are 64-bit x64, if it returns 32, then you are 32-bit IA32. If "No such file or directory" then you are probably using BIOS. My system was 64 so x64.
1.0 ```ip link``` to list network interfaces. In my case, I wanted to connect to my ethernet so this is when I plug in my ethernet cable. See the above link if you you want to connect to wireless.
  Since I am connecting to le web via ethernet, no additional setup was needed. Check that the indeface state is "UP" by retyping the command.

<ins>**Updating the System Clock**</ins>  
0.0 ```timedatectl``` very simple :)

<ins>**TIME TO PARTITION!**</ins>  
0.0 first, use ```lsblk``` or ```fdisk -l``` if you want more detal to identify storage devices, for the following steps, I use [fdisk](https://wiki.archlinux.org/title/Fdisk), but you can also use sfdisk, gdisk, or cfdisk.
  Since this is my first time installing arch, I will be doing a [single root partition scheme](https://wiki.archlinux.org/title/Partitioning#Single_root_partition) where we will need 3 partitions, one for EFI (boot), one for root (system), and one for swap (ram overflow). Since my laptop has 20GB of ram, I don't think I need a big swap, so I will leave it as a smaller partition. Here is the scheme I used:
  EFI: 1GB
  Root: 32GB
  Swap: 8GB
