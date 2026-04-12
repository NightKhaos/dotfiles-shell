# dotfiles-shell

Zsh shell configuration managed by [chezmoi](https://chezmoi.io/).

## Not a Standalone Repo

This repo is consumed as a chezmoi external by [`~/.dotfiles`](https://github.com/NightKhaos/dotfiles). It relies on chezmoi template data defined in the parent repo's `chezmoi.toml`:

```toml
[data]
  zsh_profiling = false
  mise_enabled = true
```

Do not run `chezmoi init` or `chezmoi apply` directly from this repo.

## What It Manages

- `~/.zshrc` — interactive shell config (templated)
- `~/.zshenv` — environment setup for all sessions
- `~/.config/starship.toml` — Starship prompt config
- `~/.config/sheldon/plugins.toml` — Sheldon plugin manager config
- `~/.zsh/` — drop-in directory skeleton (`env.d/`, `rc.d/`, `hooks/`, `completion/`)

## Bootstrap

On first `chezmoi apply`, `run_once_` scripts install:
- [sheldon](https://github.com/rossmacarthur/sheldon) — zsh plugin manager
- [starship](https://starship.rs/) — cross-shell prompt

## Extension Points

Other repos (e.g. `~/.dotfiles-amzn`) extend shell config by dropping files into `~/.zsh/`:
- `env.d/*.env` — environment variables (sourced by zshenv)
- `rc.d/*.rc` — interactive config (sourced by zshrc)
- `hooks/pre/*.rc` / `hooks/post/*.rc` — early/late injection points
- `completion/_*` — zsh completion functions

See `~/.zsh/README.md` for conventions.

## Known Gaps

- **`.bashrc` protection**: Tools inject content into `~/.bashrc` without asking
  (same problem as `~/.profile`). Needs to be deployed as `readonly_` to prevent
  drive-by modification. Requires OS-aware content to preserve distro-specific
  defaults from `/etc/skel/.bashrc`. See `~/.dotfiles/specs/discovery.md`.
