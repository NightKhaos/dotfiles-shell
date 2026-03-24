#!/bin/bash
set -uo pipefail

cd "$(dirname $0)"
WHEREAMI=$(pwd)
cd - >/dev/null
ZSHRC_SOURCE=$WHEREAMI/zshrc
ZSHENV_SOURCE=$WHEREAMI/zshenv
ZPROFILE_SOURCE=$WHEREAMI/zprofile

info()  { printf "  \033[34m→\033[0m %s\n" "$*"; }
ok()    { printf "  \033[32m✓\033[0m %s\n" "$*"; }
skip()  { printf "  \033[33m–\033[0m %s (already installed, skipping)\n" "$*"; }
fail()  { printf "  \033[31m✗\033[0m %s\n" "$*" >&2; exit 1; }

printf "\033[1mInstalling shell environment...\033[0m\n\n"

# Install Sheldon
printf "\033[1mSheldon\033[0m\n"
if ! which sheldon >/dev/null 2>/dev/null; then
  info "Installing sheldon..."
  if bash "$WHEREAMI/crate.sh" -- --repo rossmacarthur/sheldon --to ~/.local/bin; then
    ok "sheldon installed"
  else
    fail "sheldon install failed"
  fi
else
  skip "sheldon"
fi

# Install sheldon plugins (required post-steps)
printf "\n\033[1mSheldon plugins\033[0m\n"
FZF_DIR="${SHELDON_DATA_DIR:-$HOME/.local/share/sheldon}/repos/github.com/junegunn/fzf"
if [ -d "$FZF_DIR" ]; then
  info "Installing fzf binary..."
  if "$FZF_DIR/install" --bin; then
    ok "fzf binary installed"
  else
    fail "fzf binary install failed"
  fi
else
  info "fzf repo not found, run 'sheldon lock' first then re-run install"
fi
printf "\n"

# Install Starship
printf "\033[1mStarship\033[0m\n"
if [[ $(uname -m) != "armv7l" ]]; then
  if ! which starship >/dev/null 2>/dev/null; then
    info "Installing starship..."
    if curl -sS https://starship.rs/install.sh | sh; then
      ok "starship installed"
    else
      fail "starship install failed"
    fi
  else
    skip "starship"
  fi
else
  skip "starship (armv7l not supported)"
fi
printf "\n"

# Setup Shell
printf "\033[1mShell config symlinks\033[0m\n"
for pair in "$ZSHRC_SOURCE:$HOME/.zshrc" "$ZSHENV_SOURCE:$HOME/.zshenv" "$ZPROFILE_SOURCE:$HOME/.zprofile"; do
  src="${pair%%:*}"
  dst="${pair##*:}"
  if [ -e "$src" ]; then
    if [ -L "$dst" ]; then
      skip "$dst"
    else
      rm -f "$dst" && ln -s "$src" "$dst"
      ok "linked $dst → $src"
    fi
  fi
done

[ -e "$HOME/.zsh" ] || mkdir -p "$HOME/.zsh"
ok "~/.zsh directory exists"
printf "\n\033[32mDone.\033[0m\n"
