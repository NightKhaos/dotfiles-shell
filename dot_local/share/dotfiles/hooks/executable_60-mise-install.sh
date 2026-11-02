#!/bin/sh
# 60-mise-install.sh — install mise tools that are declared but missing.
#
# Tools are declared by drop-ins in ~/.config/mise/conf.d/ (contributed by any
# repo; dotfiles-shell manages the directory) and by the unmanaged
# ~/.config/mise/config.toml. chezmoi deploys the declarations; this hook makes
# them real.
#
# Hook behaviour per master CONTRACT:
#   - Ignores DOTFILES_APPLIED_REPOS: a tool can be missing without its
#     declaring repo having changed (e.g. a failed earlier install).
#   - No mise on this machine: warn and exit 0 — the declarations are inert.
#   - Nothing missing: exit 0 without touching the network (`mise ls
#     --missing` reads local state; `latest` resolves to what is installed).
#   - Install failure: exit non-zero so `dotfiles apply` reports it.
#
# Owner: dotfiles-shell

set -u

err() { printf 'mise-install: %s\n' "$*" >&2; }

if ! command -v mise >/dev/null 2>&1; then
    err "mise not installed; skipping (tools in ~/.config/mise/conf.d/ are not installed)"
    exit 0
fi

# Global scope only: run outside any project so a project's mise.toml in the
# caller's cwd is not pulled in.
cd / || exit 1

missing=$(mise ls --global --missing 2>/dev/null) || {
    err "cannot list mise tools"
    exit 1
}
[ -z "${missing}" ] && exit 0

printf '    mise-install: installing missing tools:\n%s\n' "${missing}" | sed 's/^/      /'
if ! mise install --yes; then
    err "mise install failed"
    exit 1
fi
