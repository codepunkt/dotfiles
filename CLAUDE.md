# Claude Context: Dotfiles Repository

## Repository Purpose

This is a **declarative macOS environment configuration** repository. The goal is maintaining identical development environments across multiple machines through version-controlled configuration files.

## Core Principle: Idempotency

The `bootstrap.sh` script MUST be safe to run repeatedly. Each execution should:
1. Install missing packages
2. Upgrade outdated packages
3. Remove packages not in the Brewfile
4. Never break existing installations

This enables the workflow: `git pull && ./bootstrap.sh` to sync any machine to the repository state.

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

Add additional configs here maintaining the same directory structure as `~/.config/`

### bootstrap.sh
The setup orchestrator. Must:
- Install Homebrew if missing (first-time setup only)
- Configure PATH for Apple Silicon Macs
- Run `brew bundle install` to sync packages (installs + upgrades)
- Run `brew bundle cleanup --force` to remove extras
- Symlink config files from `.config/` to `~/.config/`
- Be idempotent and safe to re-run

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
When user uninstalls something:
1. They can either `brew uninstall` then `brew bundle dump --force`
2. Or manually edit the Brewfile to remove the entry
3. Either way, `bootstrap.sh` will remove it on other machines via cleanup

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
- Skip the cleanup step (user wants automatic removal of unlisted packages)
- Create backup/rollback mechanisms (trust git history)

### DO:
- Keep bootstrap.sh simple and linear
- Maintain the declarative nature (Brewfile = truth)
- Ensure any changes preserve idempotency
- Use `brew bundle dump --force` to capture system state

## Homebrew Bundle Behavior

Key `brew bundle` commands:
- `brew bundle install` - Installs missing + upgrades outdated (default behavior)
- `brew bundle cleanup --force` - Removes packages not in Brewfile
- `brew bundle dump --force` - Generates Brewfile from current system

The `--force` flag in cleanup means "actually do it" (without it, just shows what would be removed).

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

Sync system to Brewfile:
```bash
./bootstrap.sh
```

Check what would be cleaned up (without doing it):
```bash
brew bundle cleanup
```
