set -e

echo "=== Phase 2: Chroot system config ==="
echo "--- Host/Username Setup ---"
read -p "Enter Hostname: " HOSTNAME
HOSTNAME=${HOSTNAME:-howdoyouforgettoputahostname} # Falls back to 'howdoyouforgettoputahostname' if left blank
echo ""
echo "Password for the root:"
passwd root

read -p "Enter Username: " USERNAME
while [[ -z "$USERNAME" ]]; do
    read -p "Username cannot be blank. Enter username: " USERNAME
done
echo ""
echo "Password for ($USERNAME):"

ln -sf /usr/share/zoneinfo/America/Vancouver /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

echo "$HOSTNAME" > /etc/hostname
useradd -m -G wheel,video,audio,render,input -s /bin/bash "$USERNAME"
passwd "$USERNAME"
pacman -Syu --noconfirm networkmanager sudo grub efibootmgr nvim
if [ -f /etc/sudoers ]; then
    sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
fi
systemctl enable NetworkManager
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

echo "Exiting Chroot..."
exit
