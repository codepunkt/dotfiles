# Dotfiles

My personal macOS setup configuration.

## Quick Setup

On a new macOS machine, run:

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

This will:
1. Install Homebrew (if not already installed)
2. Install all packages, casks, and VS Code extensions from the Brewfile

## Manual Setup

If you prefer to run steps individually:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install packages
brew bundle install
```

## Updating Brewfile

To update the Brewfile with your current installations:

```bash
brew bundle dump --force
```
