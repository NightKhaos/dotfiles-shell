#!/bin/sh
# 50-compose-starship.sh — synthesise ~/.config/starship.toml from a base
# plus drop-in fragments.
#
# Sources, merged in order:
#   1. ~/.config/starship/base.toml        (required; owned by dotfiles-shell)
#   2. ~/.config/starship/starship.d/*.toml  (optional; contributed by any repo)
#
# Output:
#   ~/.config/starship.toml (atomic write via tmp + rename)
#
# Hook behaviour per master CONTRACT:
#   - Inherits DOTFILES_APPLIED_REPOS; this hook ignores it and always
#     recomposes, because a fragment could have been added without the owning
#     repo's apply changing (e.g. timer-driven re-apply, cross-machine sync).
#     Recompose is cheap.
#   - Failure is non-aborting: errors go to stderr, exit non-zero.
#
# This hook is idempotent: when inputs are unchanged, merge-toml produces
# byte-identical output, so the rename is effectively a no-op on mtime IF
# we skip the rename when content matches.
#
# Owner: dotfiles-shell

set -u

MERGE_TOML="${HOME}/.local/share/dotfiles-shell/merge-toml"
BASE="${HOME}/.config/starship/base.toml"
DROPIN_DIR="${HOME}/.config/starship/starship.d"
OUTPUT="${HOME}/.config/starship.toml"

err() { printf 'compose-starship: %s\n' "$*" >&2; }

if [ ! -x "${MERGE_TOML}" ]; then
    err "merge-toml utility not found or not executable at ${MERGE_TOML}"
    exit 1
fi

if [ ! -f "${BASE}" ]; then
    err "base config missing: ${BASE}"
    exit 1
fi

# Collect fragments. Globs expand to the literal pattern when no matches;
# guard against that explicitly so we don't pass a non-existent filename
# to the merger.
fragments=""
if [ -d "${DROPIN_DIR}" ]; then
    for f in "${DROPIN_DIR}"/*.toml; do
        [ -f "${f}" ] || continue
        fragments="${fragments} ${f}"
    done
fi

# shellcheck disable=SC2086  # deliberate word-splitting on fragments
tmp="$(mktemp "${OUTPUT}.XXXXXX")" || {
    err "failed to create temp file for ${OUTPUT}"
    exit 1
}
trap 'rm -f "${tmp}"' EXIT

if ! "${MERGE_TOML}" "${BASE}"${fragments} -o "${tmp}"; then
    err "merge-toml failed; leaving ${OUTPUT} untouched"
    exit 1
fi

# Skip the rename if output is unchanged — preserves mtime for downstream
# mtime-based staleness signals (shell-staleness indicator design).
if [ -f "${OUTPUT}" ] && cmp -s "${tmp}" "${OUTPUT}"; then
    rm -f "${tmp}"
    trap - EXIT
    exit 0
fi

# Atomic rename. mv is POSIX atomic when src and dst are on the same fs,
# which they are here (both under $HOME).
if ! mv "${tmp}" "${OUTPUT}"; then
    err "failed to write ${OUTPUT}"
    exit 1
fi
trap - EXIT
