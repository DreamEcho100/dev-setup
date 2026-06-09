# Setup Guide

This repo separates two jobs:

- Dotfile linking: put repo files in the right live locations.
- Tool installation: install Neovim and the external binaries that plugins expect.

## Commands

```sh
ansible-playbook dotfiles.yml -K
ansible-playbook neovim.yml -K
```

Ubuntu/Linux Bash mirrors:

```sh
dev-env/runs/dotfiles --dry
dev-env/runs/dotfiles

dev-env/runs/neovim --dry
dev-env/runs/neovim
```

Java and .NET are documented opt-ins because they are large runtime stacks:

```sh
ansible-playbook neovim.yml -K -e install_java=true
ansible-playbook neovim.yml -K -e install_dotnet=true

dev-env/runs/neovim --with-java
dev-env/runs/neovim --with-dotnet
```

## Bootstrap Flow

```text
                  +---------------------------+
                  | dotfiles.yml              |
                  | dev-env/runs/dotfiles     |
                  +-------------+-------------+
                                |
                                v
   +----------------+   +----------------+   +------------------+
   | ~/.config/nvim |   | ~/.config/tmux |   | ~/.local/scripts |
   +----------------+   +----------------+   +------------------+

                  +---------------------------+
                  | neovim.yml                |
                  | dev-env/runs/neovim       |
                  +-------------+-------------+
                                |
                                v
      +----------+----------+----------+----------+----------+
      | nvim    | build    | CLI deps | language | debug    |
      | stable  | tools    | rg/fd/jq | servers  | adapters |
      +----------+----------+----------+----------+----------+
```

## XDG Path Safety

VS Code Snap terminals can export `XDG_DATA_HOME` to a Snap-owned path. Neovim uses XDG paths for Lazy, Mason, logs, shada, cache, and remote plugin data. If those paths are read-only, plugin installation fails.

The shell environment dotfiles in this repo normalize:

- `XDG_CONFIG_HOME`
- `XDG_DATA_HOME`
- `XDG_STATE_HOME`
- `XDG_CACHE_HOME`
- `PATH`

Expected default paths:

```text
XDG_CONFIG_HOME=$HOME/.config
XDG_DATA_HOME=$HOME/.local/share
XDG_STATE_HOME=$HOME/.local/state
XDG_CACHE_HOME=$HOME/.cache
```

## External Tools

The Neovim config expects broad tooling:

```text
Core:        git curl wget unzip tar gzip jq ripgrep fd lazygit tree-sitter
Formatting: prettier prettierd biome stylua shfmt shellcheck codespell
Python:     pyright ruff black isort debugpy pynvim
Go:         gopls goimports delve
Rust:       rust-analyzer rustfmt codelldb cargo
C/C++:      clangd clang-format clang-tidy lldb cmake make ninja
Web:        eslint vtsls html css tailwind graphql prisma astro svelte vue angular
Docs:       markdown tools, mermaid-cli, texlive, latexmk
Remote:     ssh scp docker devpod tmux
Opt-in:     default-jdk for Java, dotnet-sdk for C#
```

Mason installs editor-facing LSP/DAP/formatter packages where possible. System package managers install compilers, runtimes, and binary dependencies Mason cannot reliably provide.

## Health Checks

Run after bootstrap:

```sh
nvim --headless "+checkhealth lazy mason conform snacks vim.lsp nvim-treesitter provider" "+qa"
```

If health checks fail inside VS Code, first inspect:

```sh
env | grep '^XDG_'
```
