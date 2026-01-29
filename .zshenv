# Load Rust/Cargo environment if installed
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

# Initialize zoxide for non-interactive shells (e.g., scripts, tool calls)
# For interactive shells, this is handled in .zshrc to avoid double initialization
if [[ ! -o interactive ]]; then
  eval "$(zoxide init --cmd cd zsh)"
fi
