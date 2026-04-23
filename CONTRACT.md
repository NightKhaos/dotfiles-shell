# dotfiles-shell Contract

Authoritative ownership rules for applications managed by `dotfiles-shell`.
Consumer repos (e.g. `dotfiles-amzn`) must adhere to the constraints here when
contributing drop-ins.

Applications are listed alphabetically. Each entry describes what this repo
manages, what extension surfaces consumers may contribute to, and any
runtime-generated files.

See `~/.dotfiles/CONTRACT.md` for the master contract and cross-repo
conventions (filename ordering scheme, snapshot workflow, conflict detection).

---

## bash

**Config root**: `~/.bashrc`
**Ownership mode**: `readonly_` copy (444)

**Files managed**:
- `~/.bashrc` — placeholder for non-primary shell; zsh is the interactive
  default. Readonly to block drive-by modification by installers.

**Drop-in surfaces**: none. bash is not a first-class shell in this setup.

**Consumer constraints**: consumers must not contribute bash config. If bash
support is needed, propose widening this contract.

---

## sheldon

**Config root**: `~/.config/sheldon/`
**Ownership mode**: copy

**Files managed**:
- `plugins.toml` — zsh plugin manifest (SCM Breeze, etc.)

**Drop-in surfaces**: none. sheldon has a single canonical plugin file.

**Consumer constraints**: consumers must not add files to
`~/.config/sheldon/`. Plugin additions require a change to this repo.

---

## starship

**Config root**: `~/.config/starship.toml`
**Ownership mode**: copy

**Files managed**:
- `starship.toml` — prompt configuration

**Drop-in surfaces**: none today. The planned `~/.config/starship.d/`
fragment + synthesis model (see `specs/architecture.md` "Starship layering")
is deferred work; when implemented it will add a drop-in surface and a
`run_after_` synthesiser. Until then, consumers that need a distinct prompt
(e.g. work overlay) must export `STARSHIP_CONFIG` pointing at their own
file via the `~/.zsh/env.d/` surface.

**Consumer constraints**: consumers must not add files to
`~/.config/starship.toml` or a hypothetical `starship.d/` yet.

---

## zsh — init files

**Config root**: `~/`
**Ownership mode**: `readonly_` copy / `readonly_*.tmpl` rendered copy (444)

**Files managed**:
- `~/.zshenv` — sourced for all shell sessions; seeds PATH, sources
  `~/.zsh/env.d/*.env`
- `~/.zshrc` — sourced for interactive sessions; sources
  `~/.zsh/hooks/pre/*.rc`, base config, `~/.zsh/rc.d/*.rc`,
  `~/.zsh/hooks/post/*.rc`

**Drop-in surfaces**: none on these files directly. Extension happens via
`~/.zsh/*.d/` (below).

**Consumer constraints**: these files are 444 and must not be edited in
place. Tools that attempt to append (cargo, rustup, wssh, etc.) fail with
EACCES — this is intentional. See `specs/lessons-learned.md` "readonly_
protects files from external modification".

---

## zsh — drop-in surfaces

**Config root**: `~/.zsh/`
**Ownership mode**: copy (no `exact_`)

**Files managed**:
- `~/.zsh/README.md` — documents the surface layout
- `~/.zsh/env.d/50-*.env` — base environment (editor, history, java, podman)
- `~/.zsh/rc.d/50-*.rc` — base interactive config (aliases, aws, mise)
- `~/.zsh/hooks/pre/README.md`, `~/.zsh/hooks/post/README.md`
- `~/.zsh/completion/_dotfiles` — completion for the `dotfiles` CLI

**Drop-in surfaces** (consumers may contribute; master-contract `X0/X!0`
scheme applies — `X0-` prefixes are reserved for this repo, consumers use
any non-zero-tens prefix):
- `~/.zsh/env.d/NN-<ownertag>-*.env` — environment variables, all sessions
- `~/.zsh/rc.d/NN-<ownertag>-*.rc` — interactive shell config (aliases,
  functions, plugin config)
- `~/.zsh/hooks/pre/NN-<ownertag>-*.rc` — sourced at the top of zshrc,
  before base config (early injection, e.g. kiro-cli pre-hook)
- `~/.zsh/hooks/post/NN-<ownertag>-*.rc` — sourced at the bottom of zshrc,
  after base config (late injection)
- `~/.zsh/completion/_<command>` — fpath completions. Filenames follow the
  zsh `_command` convention, not the `NN-` scheme, because completion is
  keyed by command name not load order.

**Closed surfaces** (consumers MUST NOT contribute):
- `~/.zsh/` (root) — only this repo's README lives here
- Any filename using an `X0-` prefix in the drop-in directories

**Known-unmanaged runtime state** (chezmoi does NOT manage; created at
runtime; expected to appear in `dotfiles unmanaged` output — this is
correct, not drift):
- `~/.zsh/completion/_<command>` entries generated on demand by consumer
  `rc.d/` drop-ins (CLIs that emit their own zsh completion on first run)
- `~/.zsh/completion/.zcompdump*` — zsh compinit cache

---

## Environment (session-level)

**Config root**: `~/.config/environment.d/`

**Files managed by dotfiles-shell**: none currently. PATH and shell-scope
env vars live in `~/.zsh/env.d/` — the graphical session gets PATH from
other repos' `environment.d/` entries, and non-graphical sessions rely on
zshenv.

Cross-repo rules for this shared directory (ordering scheme, PATH pattern,
filename collisions) are defined in the master contract.
