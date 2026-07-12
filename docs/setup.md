# Setup Guide

This repo separates two jobs:

- Dotfile linking: put repo files in the right live locations.
- Tool installation: install Neovim and the external binaries that plugins expect.

## Commands

```sh
ansible-playbook dotfiles.yml -K
ansible-playbook terminal.yml -K
ansible-playbook neovim.yml -K
```

Ubuntu/Linux Bash mirrors:

```sh
dev-env/runs/dotfiles --dry
dev-env/runs/dotfiles

dev-env/runs/terminal --dry
dev-env/runs/terminal

dev-env/runs/neovim --dry
dev-env/runs/neovim
```

If `sudo` cannot prompt because you are running from a noninteractive shell,
install only the user-local terminal pieces:

```sh
dev-env/runs/terminal --skip-apt
```

Optional terminal stack installs:

```sh
DE100_INSTALL_ATUIN=true ansible-playbook terminal.yml -K
DE100_INSTALL_GHOSTTY_SNAP=true ansible-playbook terminal.yml -K

dev-env/runs/terminal --with-atuin
dev-env/runs/terminal --with-ghostty-snap
```

Java, .NET, and Godot are documented opt-ins because they are large runtime
stacks:

```sh
ansible-playbook neovim.yml -K -e install_java=true
ansible-playbook neovim.yml -K -e install_dotnet=true
ansible-playbook neovim.yml -K -e install_godot=true

dev-env/runs/neovim --with-java
dev-env/runs/neovim --with-dotnet
dev-env/runs/neovim --with-godot
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

                  +---------------------------+
                  | terminal.yml              |
                  | dev-env/runs/terminal     |
                  +-------------+-------------+
                                |
                                v
      +----------+----------+----------+----------+----------+
      | zsh      | kitty    | ghostty  | starship | tmux     |
      | antidote | themes   | themes   | prompt   | TPM/persist |
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
Python:     pyright ruff black isort pynvim; Mason debugpy adapter
Go:         gopls goimports; Mason Delve adapter
Rust:       rust-analyzer rustfmt codelldb cargo
C/C++:      clangd clang-format clang-tidy lldb cmake make ninja
Web:        eslint vtsls html css tailwind graphql prisma astro svelte vue angular
Docs:       markdown tools, mermaid-cli, texlive, latexmk
Remote:     ssh scp docker devpod tmux
Debug:      js-debug debugpy delve codelldb local-lua-debugger OSV
Opt-in:     OpenJDK 21 + Java DAP, .NET 10 + netcoredbg, Godot 4 + built-in DAP
```

## Terminal Stack

The terminal layer manages the shell/workstation experience around Neovim:

- `zsh` with Antidote plugins.
- Kitty and Ghostty configs.
- Starship prompt.
- JetBrainsMono Nerd Font by default.
- tmux with TPM, resurrect, and continuum.
- Atuin config as local-only opt-in.

Theme switching is centralized:

```sh
de100-theme list
de100-theme current
de100-theme set tokyo-night
de100-theme set catppuccin-mocha
de100-theme set rose-pine-moon
de100-theme set gruvbox-dark
```

The default is Tokyo Night. `de100-theme` writes ignored local override/state
files, so switching themes does not dirty the tracked repo config.

Mason installs editor-facing LSP/DAP/formatter packages where possible. System package managers install compilers, runtimes, and binary dependencies Mason cannot reliably provide.

## Health Checks

Run after bootstrap:

```sh
nvim --headless "+checkhealth lazy mason conform snacks vim.lsp nvim-treesitter provider dap" "+qa"
```

Inside a supported source buffer, run `:De100DapHealth` to see the exact DAP
configurations, adapters, executables, project files, and log path selected for
that filetype.

If health checks fail inside VS Code, first inspect:

```sh
env | grep '^XDG_'
```

Expected after opening a new terminal:

```sh
echo "$XDG_DATA_HOME"
# /home/YOU/.local/share
```
