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

echo "✨ Setup complete!"
