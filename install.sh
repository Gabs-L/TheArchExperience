set -e

echo "=== 1: Live USB Installation ==="
timedatectl set-ntp true
timedatectl status
ip link

echo ""
echo "=== Available Disks ==="
lsblk -dno NAME,SIZE,MODEL | grep -v "loop"
echo ""
read -p "Enter the drive name to install onto: " TARGET_DRIVE

DRIVE="/dev/$TARGET_DRIVE"

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

echo "--- Partitioning $DRIVE ---"
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

echo "--- Formatting partitions ---"
mkfs.fat -F32 "$BOOT_PART"
mkfs.ext4 -F "$ROOT_PART"

echo "--- Mounting filesystems ---"
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$BOOT_PART" /mnt/boot

echo "--- Running pacstrap ---"
pacstrap -K /mnt base linux linux-firmware intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab

cp chroot.sh /mnt/chroot.sh
chmod +x /mnt/chroot.sh

echo "--- Entering chroot ---"
arch-chroot /mnt /chroot.sh

rm -f /mnt/chroot.sh
umount -R /mnt

echo "=== Installation complete, reboot now! ==="
