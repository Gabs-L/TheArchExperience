set -e
echo "=== Starting Post-Install Script ==="
sudo pacman -S --noconfirm \
mesa vulkan-intel intel-media-driver \
alacritty hyprland waybar wofi thunar tumbler \
xdg-desktop-portal xdg-desktop-portal-hyprland xorg-xwayland \
pipewire pipewire-pulse wireplumber sof-firmware alsa-utils pamixer \
brightnessctl playerctl grim slurp wl-clipboard polkit-gnome \
ttf-jetbrains-mono-nerd ttf-liberation \
firefox mako hyprpaper git github-cli

echo "=== Making Config Files ==="
mkdir -p ~/.config/hypr
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/mako
mkdir -p ~/.config/fastfetch
cp /usr/share/hypr/hyprland.lua ~/.config/hypr/hyprland.lua

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

echo "--- writing to hyprland config ---"
cat << 'EOF' > ~/.config/hypr/hyprland.lua
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

local terminal    = "alacritty"
local fileManager = "thunar"
local menu        = "wofi --show drun"
local browser 	  = "firefox"
hl.on("hyprland.start", function () 
  hl.exec_cmd(terminal)
  hl.exec_cmd("waybar & hyprpaper & firefox")
end)

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) 
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
EOF

echo "--- writing to fastfetch config ---"
cat << 'EOF' > ~/.config/fastfetch/config.jsonc
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
  "modules": [
	"title",
    "separator",
	"host",
	"kernel",
	"uptime",
	"packages",
	"shell",
	"display",
	"wm",
	"terminalfont",
    {
	  "type": "cpu",
	  "temp": true,
	  "format": "{name} @ {freq-max} ({temperature})"
    },
	{
      "type": "gpu",
      "temp": true,
      "format": "{name} @ ({frequency})"
    },
    {
      "type": "gpuusage",
      "format": "{usage}"
    },
      "memory",
	  "disk",
	  "break",
	  "colors"
    ]
}
EOF

echo "=== System Configuration Complete! Please reboot ==="
