#!/usr/bin/env bash
set -euo pipefail

# Variables
#----------------------------

# time variable
start=$(date +%s)

# Color variables
PINK="\e[35m"
WHITE="\e[0m"
YELLOW="\e[33m"
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"

clear

# Welcome message
echo -e "${PINK}\e[1m
 WELCOME!${PINK} Now we will install and setup Hyprland on Fedora Asahi (M2 Mac)
                       Modified for ARM64 Architecture
${WHITE}"

# Warning message
echo -e "${PINK}
 *********************************************************************
 *                         ⚠️  \e[1;4mWARNING\e[0m${PINK}:                              *
 *               This script will modify your system!                *
 *         It will install Hyprland and several dependencies.        *
 *      Make sure you know what you are doing before continuing.     *
 *                                                                   *
 *           ⚠️  Hyprland on ARM is EXPERIMENTAL ⚠️                   *
 *        If Hyprland fails, Sway will be installed instead         *
 *********************************************************************
\n
"

# Asking if the user want to proceed
echo -e "${YELLOW} Do you still want to continue with Hyprland installation using this script? [y/N]: \n"
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

# Prompt for dotfiles repository URL
echo -e "${YELLOW}\nEnter your dotfiles repository URL (or press Enter to use default): ${WHITE}"
read -r DOTFILES_REPO
if [[ -z "$DOTFILES_REPO" ]]; then
    DOTFILES_REPO="https://github.com/Vaelixv/dotfiles.git"
    echo -e "${BLUE}[NOTE]${PINK} ==> Using default repo (you'll need to update this)"
fi

# Start of the install procedure
cd ~

# Full system update
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[1/13]${PINK} ==> Updating system packages\n---------------------------------------------------------------------\n${WHITE}"
sudo dnf update -y

# Install essential development tools
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[2/13]${PINK} ==> Installing development tools\n---------------------------------------------------------------------\n${WHITE}"
sudo dnf groupinstall "Development Tools" -y
sudo dnf install -y git curl wget vim neovim gcc-c++ cmake meson ninja-build

# Install base dependencies for Wayland/Hyprland
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[3/13]${PINK} ==> Installing Wayland and Hyprland dependencies\n---------------------------------------------------------------------\n${WHITE}"
sudo dnf install -y \
    wayland-devel wayland-protocols-devel \
    libxkbcommon-devel pixman-devel \
    libdrm-devel mesa-libgbm-devel \
    cairo-devel pango-devel \
    libinput-devel systemd-devel \
    libudev-devel mesa-libEGL-devel \
    libxcb-devel xcb-util-wm-devel \
    xcb-util-renderutil-devel \
    wlroots-devel libdisplay-info-devel \
    hwdata-devel libliftoff-devel \
    tomlplusplus-devel hyprlang-devel \
    hyprcursor-devel hyprwayland-scanner

# Try to build and install Hyprland
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[4/13]${PINK} ==> Attempting to build Hyprland (this may take 10-20 minutes)\n---------------------------------------------------------------------\n${WHITE}"
HYPRLAND_SUCCESS=false

if git clone --recursive https://github.com/hyprwm/Hyprland ~/Hyprland; then
    cd ~/Hyprland
    if make all && sudo make install; then
        HYPRLAND_SUCCESS=true
        echo -e "${GREEN}[SUCCESS]${PINK} ==> Hyprland compiled successfully!"
        cd ~
    else
        echo -e "${RED}[FAILED]${PINK} ==> Hyprland compilation failed"
        cd ~
        rm -rf ~/Hyprland
    fi
else
    echo -e "${RED}[FAILED]${PINK} ==> Could not clone Hyprland repository"
fi

# Install Sway as fallback
if [[ "$HYPRLAND_SUCCESS" = false ]]; then
    echo -e "${YELLOW}\n[FALLBACK]${PINK} ==> Installing Sway as alternative to Hyprland\n${WHITE}"
    sudo dnf install -y sway swaylock swayidle
    echo -e "${BLUE}[NOTE]${PINK} ==> Sway installed. Your dotfiles will mostly work with Sway too!"
fi

# Clone dotfiles
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[5/13]${PINK} ==> Cloning dotfiles repository\n---------------------------------------------------------------------\n${WHITE}"
if [[ -d ~/dotfiles ]]; then
    echo -e "${YELLOW}[WARNING]${PINK} ==> ~/dotfiles already exists. Backing up to ~/dotfiles.backup"
    mv ~/dotfiles ~/dotfiles.backup
fi
git clone "$DOTFILES_REPO" ~/dotfiles

# Make scripts executable
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[6/13]${PINK} ==> Making scripts executable\n---------------------------------------------------------------------\n${WHITE}"
if [[ -d ~/dotfiles/.config/viegphunt ]]; then
    sudo chmod +x ~/dotfiles/.config/viegphunt/*
fi
# Make all .sh files in dotfiles executable
find ~/dotfiles -name "*.sh" -type f -exec chmod +x {} \;

# Download wallpapers
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[7/13]${PINK} ==> Downloading wallpapers\n---------------------------------------------------------------------\n${WHITE}"
if [[ ! -d ~/Pictures/Wallpapers ]]; then
    git clone --depth 1 https://github.com/ViegPhunt/Wallpaper-Collection.git ~/Wallpaper-Collection
    mkdir -p ~/Pictures/Wallpapers
    mv ~/Wallpaper-Collection/Wallpapers/* ~/Pictures/Wallpapers
    rm -rf ~/Wallpaper-Collection
else
    echo -e "${BLUE}[NOTE]${PINK} ==> Wallpapers directory already exists, skipping"
fi

# Install required packages for the dotfiles setup
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[8/13]${PINK} ==> Installing required packages\n---------------------------------------------------------------------\n${WHITE}"
sudo dnf install -y \
    zsh tmux \
    waybar \
    swaync \
    rofi-wayland \
    wlogout \
    cava \
    pipewire wireplumber pavucontrol \
    brightnessctl \
    playerctl \
    grim slurp \
    wl-clipboard \
    polkit-gnome \
    network-manager-applet \
    blueman \
    thunar \
    kitty \
    firefox \
    stow

# Install oh-my-posh (ARM64 version)
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[9/13]${PINK} ==> Installing oh-my-posh (ARM64)\n---------------------------------------------------------------------\n${WHITE}"
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-arm64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh

# Download oh-my-posh themes
mkdir -p ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip -o ~/.poshthemes/themes.zip -d ~/.poshthemes
rm ~/.poshthemes/themes.zip

# Attempt to install Ghostty (may fail, will use Kitty as fallback)
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[10/13]${PINK} ==> Attempting to build Ghostty terminal\n---------------------------------------------------------------------\n${WHITE}"
GHOSTTY_SUCCESS=false

# Check if Zig is installed
if ! command -v zig &> /dev/null; then
    echo -e "${BLUE}[NOTE]${PINK} ==> Installing Zig compiler"
    cd ~
    wget https://ziglang.org/download/0.11.0/zig-linux-aarch64-0.11.0.tar.xz
    tar -xf zig-linux-aarch64-0.11.0.tar.xz
    sudo mv zig-linux-aarch64-0.11.0 /opt/zig
    export PATH=$PATH:/opt/zig
    echo 'export PATH=$PATH:/opt/zig' >> ~/.bashrc
    rm zig-linux-aarch64-0.11.0.tar.xz
fi

# Try to build Ghostty
if git clone https://github.com/ghostty-org/ghostty ~/ghostty; then
    cd ~/ghostty
    if zig build -Doptimize=ReleaseFast && sudo zig build -Doptimize=ReleaseFast --prefix /usr/local install; then
        GHOSTTY_SUCCESS=true
        echo -e "${GREEN}[SUCCESS]${PINK} ==> Ghostty compiled successfully!"
    else
        echo -e "${RED}[FAILED]${PINK} ==> Ghostty compilation failed, using Kitty as fallback"
    fi
    cd ~
else
    echo -e "${RED}[FAILED]${PINK} ==> Could not clone Ghostty, using Kitty as fallback"
fi

if [[ "$GHOSTTY_SUCCESS" = false ]]; then
    echo -e "${BLUE}[NOTE]${PINK} ==> Kitty terminal is already installed as fallback"
fi

# Enable services
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[11/13]${PINK} ==> Enabling bluetooth & NetworkManager\n---------------------------------------------------------------------\n${WHITE}"
sudo systemctl enable --now bluetooth
sudo systemctl enable --now NetworkManager

# Apply fonts
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[12/13]${PINK} ==> Applying fonts\n---------------------------------------------------------------------\n${WHITE}"
fc-cache -fv

# Stow dotfiles
echo -e "${PINK}\n---------------------------------------------------------------------\n${YELLOW}[13/13]${PINK} ==> Stowing dotfiles\n---------------------------------------------------------------------\n${WHITE}"
cd ~/dotfiles
stow -t ~ . || echo -e "${YELLOW}[WARNING]${PINK} ==> Some stow conflicts occurred. You may need to manually resolve them."
cd ~

# Set default shell to zsh
echo -e "${PINK}\n==> Setting zsh as default shell\n${WHITE}"
chsh -s $(which zsh)

# Wait a little just for the last message
sleep 0.7
clear

# Calculate how long the script took
end=$(date +%s)
duration=$((end - start))

hours=$((duration / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))

printf -v minutes "%02d" "$minutes"
printf -v seconds "%02d" "$seconds"

# Final message
echo -e "\n
 *********************************************************************
 *               Hyprland/Sway setup is complete!                    *
 *                                                                   *
 *             Duration : $hours hours, $minutes minutes, $seconds seconds            *
 *                                                                   *"

if [[ "$HYPRLAND_SUCCESS" = true ]]; then
    echo -e " *                  ✅ Hyprland installed successfully                 *"
else
    echo -e " *              ⚠️  Hyprland failed, Sway installed instead            *"
fi

if [[ "$GHOSTTY_SUCCESS" = true ]]; then
    echo -e " *                  ✅ Ghostty installed successfully                  *"
else
    echo -e " *              ⚠️  Ghostty failed, using Kitty instead                *"
fi

echo -e " *                                                                   *
 *         It is STRONGLY recommended to \e[1;4mREBOOT\e[0m your system           *
 *                                                                   *
 *                   \e[4mHave a great time on Asahi!${WHITE}                      *
 *********************************************************************
 \n
 ${YELLOW}Quick start after reboot:${WHITE}
 - To start Hyprland: Type 'Hyprland' in TTY
 - To start Sway: Type 'sway' in TTY
 - Your default shell is now zsh
 - Terminal: ${GHOSTTY_SUCCESS:+Ghostty}${GHOSTTY_SUCCESS:-Kitty}
 
 ${BLUE}Post-install TODO:${WHITE}
 1. Update your dotfiles repo URL if you used the default
 2. Check Hyprland config: ~/.config/hypr/hyprland.conf
 3. Adjust keybinds and monitor settings
 4. Test all applications
 
 ${PINK}Enjoy your new setup! 🚀${WHITE}
 \n
"
