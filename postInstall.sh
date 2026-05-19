set -e
echo "=== Starting Post-Install Script ==="
sudo pacman -S --noconfirm \
mesa vulkan-intel intel-media-driver \
alacritty hyprland waybar wofi thunar tumbler \
xdg-desktop-portal xdg-desktop-portal-hyprland xorg-xwayland \
pipewire pipewire-pulse wireplumber sof-firmware alsa-utils pamixer \
brightnessctl playerctl grim slurp wl-clipboard polkit-gnome \
firefox mako 

echo "--- Enabling Services ---"
sudo systemctl enable sddm
sudo systemctl enable bluetooth

echo "=== System Configuration Complete! Please Restart ==="
