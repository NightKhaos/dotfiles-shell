#!/bin/bash
# Install starship prompt if not present (skipped on armv7l)
set -uo pipefail

if [[ $(uname -m) == "armv7l" ]]; then
  echo "starship not supported on armv7l, skipping"
  exit 0
fi

if command -v starship >/dev/null 2>&1; then
  echo "starship already installed"
  exit 0
fi

echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh -s -- --yes

if command -v starship >/dev/null 2>&1; then
  echo "starship installed"
else
  echo "ERROR: starship installation failed" >&2
  exit 1
fi
