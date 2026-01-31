#!/usr/bin/env bash

# Opt out of Homebrew analytics for this script
export HOMEBREW_NO_ANALYTICS=1

# Skip macOS quarantine dialogs for Homebrew Cask applications
export HOMEBREW_CASK_OPTS="--no-quarantine"

echo "🚀 Starting macOS setup..."

# Keep sudo credentials alive throughout the script
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!

# Prompt for computer name
current_computer_name=$(scutil --get ComputerName 2>/dev/null || echo "Not set")
echo ""
read -p "💻 Enter computer name (current: $current_computer_name) [press Enter to keep]: " new_computer_name

if [ -n "$new_computer_name" ]; then
    echo "🔧 Setting computer names..."
    sudo scutil --set ComputerName "$new_computer_name"

    # Convert to hostname format (lowercase, spaces to hyphens)
    hostname=$(echo "$new_computer_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    sudo scutil --set HostName "$hostname"
    sudo scutil --set LocalHostName "$hostname"

    echo "✅ Computer name set to: $new_computer_name"
    echo "✅ Hostname set to: $hostname"
else
    echo "✅ Keeping current computer name: $current_computer_name"
fi
echo ""

# Install Rosetta 2 on Apple Silicon Macs
if [[ $(uname -m) == 'arm64' ]]; then
    if ! /usr/bin/pgrep -q oahd; then
        echo "🔧 Installing Rosetta 2..."
        softwareupdate --install-rosetta --agree-to-license
    else
        echo "✅ Rosetta 2 already installed"
    fi
fi

# Install Homebrew if not already installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        echo "🔧 Adding Homebrew to PATH for Apple Silicon..."
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "✅ Homebrew already installed"
fi

# Configure git
echo "🔧 Configuring git..."
git config --global user.email "christoph@codepunkt.de"
git config --global user.name "Christoph Werner"

# Install and upgrade packages from Brewfile
echo "📦 Installing and upgrading packages from Brewfile..."
brew bundle install --file="${BASH_SOURCE%/*}/Brewfile"

# Disable Spotlight's Cmd+Space shortcut for Raycast
echo "⌨️  Configuring keyboard shortcuts..."
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "
<dict>
    <key>enabled</key>
    <false/>
    <key>value</key>
    <dict>
        <key>parameters</key>
        <array>
            <integer>32</integer>
            <integer>49</integer>
            <integer>1048576</integer>
        </array>
        <key>type</key>
        <string>standard</string>
    </dict>
</dict>"

# Configure Raycast: skip onboarding, set hotkey
defaults write com.raycast.macos onboardingSkipped -bool true
defaults write com.raycast.macos raycastGlobalHotkey -string "Command-49"

# Configure power management and screen lock settings
echo "⚡ Configuring power settings..."
# Refresh sudo credentials before running pmset
sudo -v
# Never sleep the display
sudo pmset -a displaysleep 0
# Disable requiring password after sleep/screen saver
defaults write com.apple.screensaver askForPassword -int 0

# Add Raycast to login items if not already present
if ! osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | grep -q "Raycast"; then
    osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Raycast.app", hidden:false}'
    echo "  ✓ Added Raycast to login items"
fi

# Start Raycast if not running
if ! pgrep -x "Raycast" > /dev/null; then
    open -a Raycast
    echo "  ✓ Started Raycast"
fi

# Apply keyboard shortcut changes immediately
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

# Symlink config files
echo "🔗 Linking configuration files..."
DOTFILES_DIR="$(cd "${BASH_SOURCE%/*}" && pwd)"

# Create ~/.config if it doesn't exist
mkdir -p ~/.config

# Helper function to create symlinks
link_file() {
    local source="$1"
    local target="$2"
    local name="$3"

    if [ -L "$target" ]; then
        local current_target
        current_target=$(readlink "$target")
        if [ "$current_target" = "$source" ]; then
            echo "  ✓ $name already linked"
        else
            echo "  ⚠ $name symlink points to wrong location, fixing..."
            rm "$target"
            ln -s "$source" "$target"
            echo "  ✓ Linked $name"
        fi
    elif [ -e "$target" ]; then
        echo "  ⚠ $name exists, backing up to ${target}.backup"
        mv "$target" "${target}.backup"
        ln -s "$source" "$target"
        echo "  ✓ Linked $name"
    else
        ln -s "$source" "$target"
        echo "  ✓ Linked $name"
    fi
}

# Symlink mise config
if [ -d "$DOTFILES_DIR/.config/mise" ]; then
    link_file "$DOTFILES_DIR/.config/mise" ~/.config/mise "mise config"
fi

# Symlink oh-my-posh config
if [ -d "$DOTFILES_DIR/.config/ohmyposh" ]; then
    link_file "$DOTFILES_DIR/.config/ohmyposh" ~/.config/ohmyposh "oh-my-posh config"
fi

# Symlink zsh files
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    link_file "$DOTFILES_DIR/.zshrc" ~/.zshrc ".zshrc"
fi

if [ -f "$DOTFILES_DIR/.zshenv" ]; then
    link_file "$DOTFILES_DIR/.zshenv" ~/.zshenv ".zshenv"
fi

if [ -f "$DOTFILES_DIR/.zprofile" ]; then
    link_file "$DOTFILES_DIR/.zprofile" ~/.zprofile ".zprofile"
fi

# Install mise tools (Node.js, etc.)
echo "🔧 Installing mise tools..."
mise install

echo "✨ Setup complete!"
echo "✅ Raycast configured with Cmd+Space and added to login items"

# Stop the sudo keepalive process
kill "$SUDO_KEEPALIVE_PID" 2>/dev/null
