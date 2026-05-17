# Exit immediately if any command fails
set -e

echo "=== 1: Live USB Installation ==="
# 1 Network and Time Setup
timedatectl set-ntp true
timedatectl status
ip link

# 2 Drive Selection
echo ""
echo "=== Available Disks ==="
lsblk -dno NAME,SIZE,MODEL | grep -v "loop"
echo ""
read -p "Enter the drive name to install onto: " TARGET_DRIVE

# Define absolute paths for the disk and partitions
DRIVE="/dev/$TARGET_DRIVE"

# Handle naming convention difference between standard SATA (sda1) and NVMe (nvme0n1p1)
if [[ $TARGET_DRIVE == nvme* ]]; then
    BOOT_PART="${DRIVE}p1"
    ROOT_PART="${DRIVE}p2"
else
    BOOT_PART="${DRIVE}1"
    ROOT_PART="${DRIVE}2"
fi

echo "WARNING: All data on $DRIVE will be permanently banished to shadow realm!"
read -p "Are you absolutely sure you want to continue? (y/n): " CONFIRM
if [[ $CONFIRM != "y" && $CONFIRM != "Y" ]]; then
    echo "Installation aborted."
    exit 1
fi

# 3. Automated Partitioning with fdisk
echo "Partitioning $DRIVE..."
wipefs -a "$DRIVE"
fdisk "$DRIVE" <<EOF
g
n
1

+512M
t
1
n
2


w
EOF

# 4. Formatting Partitions
echo "Formatting partitions..."
mkfs.fat -F32 "$BOOT_PART"
mkfs.ext4 -F "$ROOT_PART"

# 5. Mounting File Systems
echo "Mounting filesystems..."
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot

# 6. Pacstrap (Base Installation)
echo "Running pacstrap..."
pacstrap -K /mnt base linux linux-firmware intel-ucode

# 7. Generate FSTAB
genfstab -U /mnt >> /mnt/etc/fstab

# 8. Copy the Chroot script inside and run it
# (Assuming chroot.sh was downloaded to the same directory on the Live USB)
cp chroot.sh /mnt/chroot.sh
chmod +x /mnt/chroot.sh

echo "Entering chroot..."
arch-chroot /mnt /bin/bash < /mnt/chroot.sh

# 9. Post-Chroot Clean up
rm -f /mnt/chroot.sh
umount -R /mnt

echo "=== Installation complete, reboot now! ==="
