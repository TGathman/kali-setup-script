#!/bin/bash

set -e

# ============================================================================
# Kali Linux VM Setup Script
# ============================================================================

REPO="https://raw.githubusercontent.com/TGathman/kali-setup-script/refs/heads/main"

HOME_DIR="$HOME"
SCRIPT_DIR="$HOME_DIR/scripts"
LOGIN_DIR="$SCRIPT_DIR/login"
AUTOSTART_DIR="$HOME_DIR/.config/autostart"
FONT_DIR="$HOME_DIR/.local/share/fonts"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME_DIR/.oh-my-zsh/custom}"

# ============================================================================
# System update / packages
# ============================================================================

echo "=== Updating Kali ==="

sudo apt update
sudo apt upgrade -y

echo "=== Installing packages ==="

sudo apt install -y \
    zsh \
    git \
    curl \
    wget \
    pipx \
    eza \
    bat \
    btop \
    imwheel

# ============================================================================
# Oh My Zsh
# ============================================================================

echo "=== Installing Oh My Zsh ==="

if [ ! -d "$HOME_DIR/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ============================================================================
# Zsh plugins
# ============================================================================

echo "=== Installing Zsh plugins ==="

mkdir -p "$ZSH_CUSTOM/plugins"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone \
        https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone \
        https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ============================================================================
# Powerlevel10k
# ============================================================================

echo "=== Installing Powerlevel10k ==="

if [ ! -d "$HOME_DIR/powerlevel10k" ]; then
    git clone --depth=1 \
        https://github.com/romkatv/powerlevel10k.git \
        "$HOME_DIR/powerlevel10k"
fi

echo "=== Installing MesloLGS NF fonts ==="

mkdir -p "$FONT_DIR"

for font in \
    "MesloLGS NF Regular.ttf" \
    "MesloLGS NF Bold.ttf" \
    "MesloLGS NF Italic.ttf" \
    "MesloLGS NF Bold Italic.ttf"
do
    if [ ! -f "$FONT_DIR/$font" ]; then
        wget -O "$FONT_DIR/$font" \
            "https://github.com/romkatv/powerlevel10k-media/raw/master/${font// /%20}"
    fi
done

fc-cache -f

# ============================================================================
# Zsh configuration
# ============================================================================

echo "=== Installing Zsh configuration ==="

wget -O "$HOME_DIR/.p10k.zsh" \
    "$REPO/.p10k.zsh"

wget -O "$HOME_DIR/.zshrc" \
    "$REPO/.zshrc"

# ============================================================================
# eza
# ============================================================================

echo "=== Installing eza themes ==="

mkdir -p "$SCRIPT_DIR"

if [ ! -d "$SCRIPT_DIR/eza-themes" ]; then
    git clone \
        https://github.com/eza-community/eza-themes.git \
        "$SCRIPT_DIR/eza-themes"
fi

mkdir -p "$HOME_DIR/.config/eza"

ln -sf \
    "$SCRIPT_DIR/eza-themes/themes/tokyonight.yml" \
    "$HOME_DIR/.config/eza/theme.yml"

# ============================================================================
# CLI utilities
# ============================================================================

echo "=== Installing CLI utilities ==="

pipx install tldr 2>/dev/null || true

pipx install \
    git+https://github.com/brightio/penelope \
    2>/dev/null || true

pipx ensurepath

curl -sS https://webinstall.dev/curlie | bash

# ============================================================================
# Atuin
# ============================================================================

echo "=== Installing Atuin ==="

if ! command -v atuin >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -LsSf \
        https://setup.atuin.sh | sh
fi

mkdir -p "$HOME_DIR/.config/atuin"

wget -O "$HOME_DIR/.config/atuin/config.toml" \
    "$REPO/atuin_config.toml"

# ============================================================================
# imwheel
# ============================================================================

echo "=== Configuring imwheel ==="

mkdir -p "$LOGIN_DIR"
mkdir -p "$AUTOSTART_DIR"

wget -O "$LOGIN_DIR/imwheel.sh" \
    "$REPO/imwheel.sh"

chmod +x "$LOGIN_DIR/imwheel.sh"

cat > "$AUTOSTART_DIR/imwheel.desktop" <<EOF
[Desktop Entry]
Exec=$LOGIN_DIR/imwheel.sh
Type=Application
X-KDE-AutostartScript=true
EOF

# ============================================================================
# Finished
# ============================================================================

echo
echo "============================================"
echo " Kali VM setup complete!"
echo "============================================"
echo
echo "Some changes may require logging out and"
echo "back in, particularly Zsh/PATH/font changes."
echo
