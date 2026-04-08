# ~/.zsh/ — Shell Drop-in Directory

This directory is the extension point for shell configuration. Files here are
sourced automatically by `~/.zshenv` and `~/.zshrc` based on location and
extension.

## Structure

```
~/.zsh/
  env.d/          Sourced by zshenv (all sessions). Use for environment variables.
                  Files: *.env, numbered prefix for ordering (e.g. 50-editor.env)

  rc.d/           Sourced by zshrc (interactive sessions only). Use for aliases,
                  functions, plugin config. Files: *.rc

  hooks/
    pre/          Sourced at the TOP of zshrc, before any other config.
                  Use for tools that must inject early (e.g. kiro-cli pre-hook).
                  Files: *.rc

    post/         Sourced at the BOTTOM of zshrc, after all other config.
                  Use for tools that must inject late (e.g. kiro-cli post-hook).
                  Files: *.rc

  completion/     Added to fpath for zsh completion functions.
                  Drop _command files here.
```

## Conventions

- Numeric prefixes control source order: `00-` loads first, `99-` loads last
- Base config uses `50-` prefix. Work overrides use `00-` (early) or `90-` (late)
- `.env` files should only set environment variables (no interactive features)
- `.rc` files can assume an interactive shell
- Complementary repos (e.g. `~/.dotfiles-amzn`) drop files here without conflicts
