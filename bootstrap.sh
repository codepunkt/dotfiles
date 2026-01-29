#!/usr/bin/env bash

set -e

echo "🚀 Starting macOS setup..."

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        echo "🔧 Adding Homebrew to PATH for Apple Silicon..."
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew already installed"
fi

# Install and upgrade packages from Brewfile
echo "📦 Installing and upgrading packages from Brewfile..."
brew bundle install --file="${BASH_SOURCE%/*}/Brewfile"

# Remove packages not in Brewfile
echo "🧹 Removing packages not in Brewfile..."
brew bundle cleanup --force --file="${BASH_SOURCE%/*}/Brewfile"

# Symlink config files
echo "🔗 Linking configuration files..."
DOTFILES_DIR="${BASH_SOURCE%/*}"

# Create ~/.config if it doesn't exist
mkdir -p ~/.config

# Symlink mise config
if [ -d "$DOTFILES_DIR/.config/mise" ]; then
    if [ -L ~/.config/mise ]; then
        echo "  ✓ mise config already linked"
    elif [ -e ~/.config/mise ]; then
        echo "  ⚠ ~/.config/mise exists, backing up to ~/.config/mise.backup"
        mv ~/.config/mise ~/.config/mise.backup
        ln -s "$DOTFILES_DIR/.config/mise" ~/.config/mise
    else
        ln -s "$DOTFILES_DIR/.config/mise" ~/.config/mise
        echo "  ✓ Linked mise config"
    fi
fi

# Install mise tools (Node.js, etc.)
echo "🔧 Installing mise tools..."
mise install

echo "✨ Setup complete!"
