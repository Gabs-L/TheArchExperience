set -e
echo "=== Starting Post-Install Script ==="
sudo pacman -S --noconfirm \
mesa vulkan-intel intel-media-driver \
alacritty hyprland waybar wofi thunar tumbler \
xdg-desktop-portal xdg-desktop-portal-hyprland xorg-xwayland \
pipewire pipewire-pulse wireplumber sof-firmware alsa-utils pamixer \
brightnessctl playerctl grim slurp wl-clipboard polkit-gnome \
ttf-jetbrains-mono-nerd ttf-liberation \
firefox mako hyprpaper

echo "=== Making Config Files ==="
mkdir -p ~/.config/hypr
cp /usr/share/hyprland/hyprland.conf ~/.config/hypr/hyprland.conf

mkdir -p ~/.config/alacritty
mkdir -p ~/.config/mako

echo "--- writing to alacritty config ---"
cat << 'EOF' > ~/.config/alacritty/alacritty.toml
[window]
opacity = 0.85
blur = true

[font]
size = 11.0
EOF

echo "--- writing to mako config ---"
cat << 'EOF' > ~/.config/mako/config
background-color=#1e1e2e
text-color=#cdd6f4
border-color=#89b4fa
border-size=2
border-radius=5
font=monospace 10
EOF

# echo "--- Enabling Services ---"

echo "=== System Configuration Complete! Please reboot ==="
