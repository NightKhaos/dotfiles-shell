#!/bin/bash
# Install sheldon (zsh plugin manager) if not present
set -uo pipefail

if command -v sheldon >/dev/null 2>&1; then
  echo "sheldon already installed"
  exit 0
fi

echo "Installing sheldon..."
curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
  | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin

if command -v sheldon >/dev/null 2>&1; then
  echo "sheldon installed, running initial lock..."
  sheldon lock
else
  echo "ERROR: sheldon installation failed" >&2
  exit 1
fi
