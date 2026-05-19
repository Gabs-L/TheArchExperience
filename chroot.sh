set -e

echo "--- Chroot system config ---"
pacman -Syu --noconfirm networkmanager sudo grub efibootmgr nvim terminus-font
systemctl enable NetworkManager

echo "=== Host/Username Setup ==="
read -p "Enter Hostname: " HOSTNAME
HOSTNAME=${HOSTNAME:-howdoyouforgettoputahostname} # Falls back to 'howdoyouforgettoputahostname' if left blank

read -p "Enter Username: " USERNAME
while [[ -z "$USERNAME" ]]; do
    read -p "Username cannot be blank. Enter username: " USERNAME
done
echo ""

echo "=== Password Setup ==="
useradd -m -G wheel,video,audio,render,input -s /bin/bash "$USERNAME"
echo ""
echo "--- Password for root ---"
passwd root || true
echo ""
echo "--- Password for ($USERNAME) ---"
passwd "$USERNAME" || true
if [ -f /etc/sudoers ]; then
    sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
fi

echo "--- System time and locale config ---"
ln -sf /usr/share/zoneinfo/America/Vancouver /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
{
    echo "KEYMAP=us"
    echo "FONT=ter-124b"
} > /etc/vconsole.conf
echo "$HOSTNAME" > /etc/hostname

echo "--- Configuring GRUB ---"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

echo "--- Exiting Chroot ---"
exit
