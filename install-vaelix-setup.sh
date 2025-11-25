#!/usr/bin/env bash
set -euo pipefail

# Variables
start=$(date +%s)

# Color variables
PINK="\e[35m"
WHITE="\e[0m"
YELLOW="\e[33m"
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"

clear

echo -e "${PINK}\e[1m
 WELCOME!${PINK} Now we will install and setup Sway on Fedora Asahi (M2 Mac)
                       Created for Vaelix
${WHITE}"

echo -e "${PINK}
 *********************************************************************
 *                         ⚠️  \e[1;4mWARNING\e[0m${PINK}:                              *
 *               This script will modify your system!                *
 *         It will install Sway and several dependencies.            *
 *      Make sure you know what you are doing before continuing.     *
 *********************************************************************
\n
"

echo -e "${YELLOW} Do you still want to continue with Sway installation using this script? [y/N]: \n"
read -r confirm
case "$confirm" in
    [yY][eE][sS]|[yY])
        echo -e "\n${GREEN}[OK]${PINK} ==> Continuing with installation..."
        ;;
    *)
        echo -e "${BLUE}[NOTE]${PINK} ==> You 🫵 chose ${YELLOW}NOT${PINK} to proceed.. Exiting..."
        echo
        exit 1
        ;;
esac

cd ~

echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[1/11]${PINK} ==> Updating system packages\n---------------------------------------------------------------------\n${WHITE}"
sudo dnf update -y

echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[2/11]${PINK} ==> Installing development tools\n---------------------------------------------------------------------\n${WHITE}"
sudo dnf install -y \
    git curl wget vim neovim \
    gcc gcc-c++ make automake autoconf \
    cmake meson ninja-build \
    pkgconfig patch diffutils \
    libtool bison flex

echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[3/11]${PINK} ==> Installing Sway and Wayland components\n---------------------------------------------------------------------\n${WHITE}"
sudo dnf install -y sway swaylock swayidle swaybg waybar rofi-wayland swaync wlogout

echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[4/11]${PINK} ==> Downloading wallpapers\n---------------------------------------------------------------------\n${WHITE}"
if [[ ! -d ~/Pictures/Wallpapers ]]; then
    git clone --depth 1 https://github.com/ViegPhunt/Wallpaper-Collection.git ~/Wallpaper-Collection
    mkdir -p ~/Pictures/Wallpapers
    mv ~/Wallpaper-Collection/Wallpapers/* ~/Pictures/Wallpapers 2>/dev/null || true
    rm -rf ~/Wallpaper-Collection
else
    echo -e "${BLUE}[NOTE]${PINK} ==> Wallpapers already exist, skipping"
fi

echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[5/11]${PINK} ==> Installing required packages\n---------------------------------------------------------------------\n${WHITE}"
sudo dnf install -y \
    zsh tmux stow \
    cava \
    pipewire wireplumber pavucontrol \
    brightnessctl playerctl \
    grim slurp wl-clipboard \
    polkit-gnome \
    network-manager-applet blueman \
    thunar kitty alacritty firefox

echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[6/11]${PINK} ==> Enabling bluetooth & NetworkManager\n---------------------------------------------------------------------\n${WHITE}"
sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager

echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[7/11]${PINK} ==> Installing oh-my-posh (ARM64)\n---------------------------------------------------------------------\n${WHITE}"
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-arm64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
mkdir -p ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip -o ~/.poshthemes/themes.zip -d ~/.poshthemes
rm ~/.poshthemes/themes.zip

echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[8/11]${PINK} ==> Installing Nerd Fonts\n---------------------------------------------------------------------\n${WHITE}"
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
unzip -o JetBrainsMono.zip
rm JetBrainsMono.zip
cd ~

echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[9/11]${PINK} ==> Applying fonts\n---------------------------------------------------------------------\n${WHITE}"
fc-cache -fv

echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[10/11]${PINK} ==> Creating Sway configuration\n---------------------------------------------------------------------\n${WHITE}"
mkdir -p ~/.config/sway ~/.config/waybar ~/.config/kitty

# Sway config
cat > ~/.config/sway/config << 'SWAYEOF'
# Sway config for Vaelix - M2 MacBook Air

set $mod Mod4
set $term kitty
set $menu rofi -show drun

# Output configuration
output * bg ~/Pictures/Wallpapers/* fill

# Input configuration
input type:touchpad {
    tap enabled
    natural_scroll enabled
    dwt enabled
}

input type:keyboard {
    xkb_layout us
    repeat_delay 300
    repeat_rate 50
}

# Autostart
exec waybar
exec swaync
exec blueman-applet
exec nm-applet

# Key bindings - Basic
bindsym $mod+Return exec $term
bindsym $mod+d exec $menu
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec wlogout

# Navigation
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# Moving windows
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# Workspaces
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5
bindsym $mod+6 workspace number 6
bindsym $mod+7 workspace number 7
bindsym $mod+8 workspace number 8
bindsym $mod+9 workspace number 9

bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4
bindsym $mod+Shift+5 move container to workspace number 5
bindsym $mod+Shift+6 move container to workspace number 6
bindsym $mod+Shift+7 move container to workspace number 7
bindsym $mod+Shift+8 move container to workspace number 8
bindsym $mod+Shift+9 move container to workspace number 9

# Layout
bindsym $mod+b splith
bindsym $mod+v splitv
bindsym $mod+f fullscreen
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split
bindsym $mod+Shift+space floating toggle
bindsym $mod+space focus mode_toggle

# Resizing
mode "resize" {
    bindsym Left resize shrink width 10px
    bindsym Down resize grow height 10px
    bindsym Up resize shrink height 10px
    bindsym Right resize grow width 10px
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"

# Screenshots
bindsym Print exec grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png
bindsym $mod+Print exec grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png

# Volume
bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle

# Brightness
bindsym XF86MonBrightnessUp exec brightnessctl set +5%
bindsym XF86MonBrightnessDown exec brightnessctl set 5%-

# Media
bindsym XF86AudioPlay exec playerctl play-pause
bindsym XF86AudioNext exec playerctl next
bindsym XF86AudioPrev exec playerctl previous

# Gaps and borders
gaps inner 10
gaps outer 5
default_border pixel 2
default_floating_border pixel 2

# Colors (purple/pink theme)
client.focused          #c678dd #c678dd #ffffff #c678dd #c678dd
client.focused_inactive #44475a #44475a #f8f8f2 #44475a #44475a
client.unfocused        #282a36 #282a36 #bfbfbf #282a36 #282a36
client.urgent           #44475a #ff5555 #f8f8f2 #ff5555 #ff5555
SWAYEOF

# Waybar config
cat > ~/.config/waybar/config << 'WAYBAREOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "modules-left": ["sway/workspaces", "sway/mode"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery", "tray"],
    
    "sway/workspaces": {
        "disable-scroll": true,
        "all-outputs": true
    },
    
    "clock": {
        "format": "{:%H:%M  %Y-%m-%d}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": " {essid}",
        "format-disconnected": "⚠ Disconnected"
    },
    
    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-icons": ["", "", ""]
    }
}
WAYBAREOF

cat > ~/.config/waybar/style.css << 'WAYBARCSS'
* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
}

window#waybar {
    background-color: rgba(40, 42, 54, 0.9);
    color: #f8f8f2;
}

#workspaces button {
    padding: 0 10px;
    color: #f8f8f2;
}

#workspaces button.focused {
    background-color: #c678dd;
    color: #ffffff;
}

#clock, #battery, #network, #pulseaudio {
    padding: 0 10px;
}
WAYBARCSS

# Kitty config
cat > ~/.config/kitty/kitty.conf << 'KITTYEOF'
# Font
font_family JetBrainsMono Nerd Font
font_size 12.0

# Theme (purple/pink)
background #1e1e2e
foreground #cdd6f4
cursor #f5e0dc

# Colors
color0  #45475a
color1  #f38ba8
color2  #a6e3a1
color3  #f9e2af
color4  #89b4fa
color5  #f5c2e7
color6  #94e2d5
color7  #bac2de
color8  #585b70
color9  #f38ba8
color10 #a6e3a1
color11 #f9e2af
color12 #89b4fa
color13 #f5c2e7
color14 #94e2d5
color15 #a6adc8

# Window
window_padding_width 10
KITTYEOF

echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[11/11]${PINK} ==> Creating .zshrc\n---------------------------------------------------------------------\n${WHITE}"
cat > ~/.zshrc << 'ZSHEOF'
# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# oh-my-posh
eval "$(oh-my-posh init zsh --config ~/.poshthemes/jandedobbeleer.omp.json)"

# Aliases
alias ll='ls -lah'
alias update='sudo dnf update'
alias install='sudo dnf install'
alias swaycfg='nvim ~/.config/sway/config'

# Auto start Sway on TTY1
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec sway
fi
ZSHEOF

chsh -s $(which zsh)

sleep 0.7
clear

end=$(date +%s)
duration=$((end - start))
hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))
printf -v minutes "%02d" "$minutes"
printf -v seconds "%02d" "$seconds"

echo -e "\n
 *********************************************************************
 *                    Vaelix setup is complete!                      *
 *                                                                   *
 *             Duration : $hours hours, $minutes minutes, $seconds seconds            *
 *                                                                   *
 *              ✅ Sway installed (perfect for M2 Mac)                *
 *              ✅ Waybar status bar configured                       *
 *              ✅ Kitty terminal with purple theme                   *
 *              ✅ oh-my-posh shell prompt                            *
 *              ✅ Purple/pink color scheme applied                   *
 *                                                                   *
 *   It is recommended to \e[1;4mREBOOT\e[0m your system to apply all changes.   *
 *                                                                   *
 *                 \e[4mHave a great time with Vaelix!${WHITE}                    *
 *********************************************************************
 \n
 ${YELLOW}After reboot:${WHITE}
 - Login will auto-start Sway
 - Super+Enter = Terminal (Kitty)
 - Super+D = App launcher (Rofi)
 - Super+Shift+E = Logout menu
 
 ${BLUE}Keybinds:${WHITE}
 - Super+1-9 = Switch workspace
 - Super+Shift+Q = Close window
 - Super+F = Fullscreen
 - Print = Screenshot area
 
 ${PINK}Next steps:${WHITE}
 1. Reboot: sudo reboot
 2. Add your dotfiles from ViegPhunt's rice
 3. Customize colors in ~/.config/sway/config
 
 ${GREEN}Enjoy your setup! 🚀${WHITE}
 \n
"
