# Claude Context: Dotfiles Repository

## Repository Purpose

This is a **declarative macOS environment configuration** repository. The goal is maintaining identical development environments across multiple machines through version-controlled configuration files.

## Core Principle: Idempotency

The `bootstrap.sh` script MUST be safe to run repeatedly. Each execution should:
1. Install missing packages
2. Upgrade outdated packages
3. Never break existing installations
4. Allow locally-installed packages not in the Brewfile

**Philosophy:** The Brewfile defines the **minimum required** setup, not the exact state. This allows for machine-specific customizations without them being removed.

This enables the workflow: `git pull && ./bootstrap.sh` to ensure all machines have the baseline tools.

## File Structure

### Brewfile
The single source of truth for installed software. Contains three types of entries:
- `brew "package"` - CLI tools and libraries
- `cask "app"` - GUI applications
- `vscode "extension"` - VS Code extensions

**Update Command**: `brew bundle dump --force` (overwrites with current system state)

### .config/
Mirrors the `~/.config/` directory structure. Contains application configurations:
- `mise/config.toml` - mise (runtime manager) configuration with Node.js version and settings
- `ohmyposh/zen.toml` - oh-my-posh prompt theme configuration

Add additional configs here maintaining the same directory structure as `~/.config/`

### ZSH Configuration Files
- `.zshrc` - Main shell configuration (zinit plugins, aliases, keybindings, integrations)
- `.zshenv` - Environment variables for non-interactive shells
- `.zprofile` - Login shell configuration (Homebrew, OrbStack)

**Plugin Manager**: Uses zinit (auto-installs on first run)
**Prompt**: oh-my-posh with zen theme
**Key Features**: Auto-suggestions, syntax highlighting, fuzzy completions, mise/fzf/zoxide integration

### bootstrap.sh
The setup orchestrator. Must:
- Install Homebrew if missing (first-time setup only)
- Configure PATH for Apple Silicon Macs
- Run `brew bundle install` to sync packages (installs + upgrades)
- Symlink config files:
  - `.config/mise` → `~/.config/mise`
  - `.config/ohmyposh` → `~/.config/ohmyposh`
  - `.zshrc` → `~/.zshrc`
  - `.zshenv` → `~/.zshenv`
  - `.zprofile` → `~/.zprofile`
- Run `mise install` to install Node.js and other tools
- Be idempotent and safe to re-run (backs up existing files to `*.backup`)

### .gitignore
Excludes:
- `.DS_Store` - macOS metadata
- `Brewfile.lock.json` - Homebrew lock file (generated, not tracked)

## Common Maintenance Tasks

### Adding New Software
When user installs something new on one machine:
1. Suggest running `brew bundle dump --force` to update Brewfile
2. Commit the updated Brewfile
3. Other machines sync via `git pull && ./bootstrap.sh`

### Removing Software
When user wants to remove something from the baseline setup:
1. Remove the entry from the Brewfile
2. Manually uninstall it on each machine: `brew uninstall <package>`
3. The Brewfile now reflects the updated baseline for new machines

Note: Removing from Brewfile doesn't auto-uninstall from existing machines (no cleanup step).

### Syncing Machines
The workflow is always:
```bash
git pull              # Get latest Brewfile
./bootstrap.sh        # Sync system to Brewfile
```

## Important Constraints

### DO NOT:
- Add features without user request (no shell configs, symlinks, etc. unless asked)
- Make bootstrap.sh non-idempotent
- Add cleanup step (allows machine-specific packages to coexist with baseline)
- Create backup/rollback mechanisms (trust git history)

### DO:
- Keep bootstrap.sh simple and linear
- Maintain the declarative nature (Brewfile = truth)
- Ensure any changes preserve idempotency
- Use `brew bundle dump --force` to capture system state

## Git Commit Guidelines

When creating commits for this repository:

### Commit Message Format
Use **Conventional Commits** syntax:
```
<type>: <description>

[optional body]
```

**Types:**
- `feat:` - New feature or capability
- `fix:` - Bug fix
- `chore:` - Maintenance tasks (e.g., updating Brewfile)
- `docs:` - Documentation changes
- `refactor:` - Code restructuring without functional changes

**Example:**
```
feat: add mise configuration management

- Add .config/mise/config.toml with Node.js LTS setup
- Update bootstrap.sh to symlink config files
- Update CLAUDE.md with .config directory documentation
```

### Co-authorship
**NEVER include Claude co-authorship lines** in commits. Do not add:
- `Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>`
- Any similar attribution to AI assistance

Commits should only reflect the user's authorship.

## Homebrew Bundle Behavior

Key `brew bundle` commands used in this repository:
- `brew bundle install` - Installs missing + upgrades outdated (used in bootstrap.sh)
- `brew bundle dump --force` - Generates Brewfile from current system

Commands NOT used (but available):
- `brew bundle cleanup --force` - Removes packages not in Brewfile (deliberately not used to allow machine-specific packages)

## Future Extensions

User may request adding:
- Shell configs (`.zshrc`, `.bashrc`)
- Git config (`.gitconfig`)
- Application preferences
- Symlink management
- SSH/GPG key setup

Each addition should maintain the same principle: declarative config + idempotent bootstrap.

## Testing Changes

When modifying bootstrap.sh, verify:
1. Can run multiple times without errors
2. Installs Homebrew on fresh system
3. Respects existing Homebrew installation
4. Applies Brewfile changes correctly
5. Cleanup removes unlisted packages

## Quick Reference

Update Brewfile with current system:
```bash
brew bundle dump --force
```

Sync system to Brewfile (installs missing, upgrades outdated):
```bash
./bootstrap.sh
```
