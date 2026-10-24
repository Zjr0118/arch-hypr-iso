#!/bin/bash
set -euo pipefail

echo "===== Arch Hyprland Post Install ====="

sudo pacman -Syu --noconfirm

# yay AUR helper
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
fi

# AUR themes
yay -S --noconfirm --needed catppuccin-gtk-theme-mocha catppuccin-hyprland-git

# zsh + oh-my-zsh
if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
chsh -s /usr/bin/zsh "$USER"

# zram
sudo tee /etc/systemd/zram-generator.conf > /dev/null <<'EOT'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOT
sudo systemctl daemon-reload
sudo systemctl enable --now systemd-zram-setup@zram0

# firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo systemctl enable --now ufw

# enable NetworkManager
sudo systemctl enable --now NetworkManager

# config dirs
mkdir -p ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/.config/alacritty ~/.config/hypr/scripts

# hyprland.conf
cat > ~/.config/hypr/hyprland.conf <<'EOT'
monitor=,preferred,auto,1
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(203 166 247 1.0) rgba(245 194 231 1.0) 45deg
    col.inactive_border = rgba(127 132 157 1.0)
}
decoration {
    rounding = 8
    blur {
        enabled = true
        size = 8
        passes = 3
    }
}
animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 5, default, popin 80%
}
dwindle {
    pseudotile = true
}
input {
    kb_layout = us
    follow_mouse = 1
}
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24

$terminal = alacritty
$fileManager = thunar
$menu = rofi -show drun

bind = SUPER, D, exec, $menu
bind = SUPER, Return, exec, $terminal
bind = SUPER, E, exec, $fileManager
bind = SUPER, Q, killactive
bind = SUPER, SHIFT, Q, exit
bind = SUPER, M, exec, wlogout
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5
bind = SUPER, 6, workspace, 6
bind = SUPER, 7, workspace, 7
bind = SUPER, 8, workspace, 8
bind = SUPER, 9, workspace, 9
bind = SUPER, Print, exec, grim -g "$(slop)" ~/Pictures/screenshot-$(date +%s).png
bind = SUPER, SHIFT, S, exec, grim -g "$(slop)" - | wl-copy

exec-once = ~/.config/hypr/scripts/autostart.sh
EOT

# waybar config
cat > ~/.config/waybar/config <<'EOT'
{
    "height": 30,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "tray"],
    "clock": { "format": "%H:%M  %m-%d" },
    "hyprland/workspaces": { "all-outputs": true }
}
EOT

cat > ~/.config/waybar/style.css <<'EOT'
* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
    border: none;
    border-radius: 0;
    min-height: 0;
}
window#waybar {
    background: rgba(30, 30, 46, 0.85);
    color: #cdd6f4;
}
#workspaces button {
    padding: 0 8px;
    color: #6c7086;
}
#workspaces button.active {
    color: #cdd6f4;
    background: #45475a;
    border-radius: 6px;
}
#clock, #cpu, #memory, #pulseaudio, #network {
    padding: 0 10px;
}
EOT

# alacritty
cat > ~/.config/alacritty/alacritty.toml <<'EOT'
[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
size = 12.0
[cursor]
style = { shape = "Beam", blinking = "On" }
[colors.primary]
background = "#1e1e2e"
foreground = "#cdd6f4"
[colors.cursor]
text = "#1e1e2e"
cursor = "#f5e0dc"
EOT

# autostart
cat > ~/.config/hypr/scripts/autostart.sh <<'EOT'
#!/bin/bash
waybar &
swayidle -w \
    timeout 300 'swaylock -f -c 1e1e2e' &
EOT
chmod +x ~/.config/hypr/scripts/autostart.sh

# GTK theme
gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Standard-Blue-Dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name 'WenQuanYi Micro Hei 11' 2>/dev/null || true

echo "======================================"
echo "✅ Post install done!"
echo "Run:  exec Hyprland   (or reboot)"
echo "Then: sudo timeshift --create"
