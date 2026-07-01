# MFansible Neovim Docs

This directory documents the dotfiles bootstrap and Neovim configuration for two overlapping users:

- A VS Code power user moving to Neovim.
- A Neovim/tmux power user building a durable terminal-native workflow.

## Map

```text
mfansible/
|-- dotfiles.yml                 # Cross-platform-ish dotfile symlink playbook
|-- terminal.yml                 # zsh, terminal, prompt, font, and tmux playbook
|-- neovim.yml                   # Cross-platform-ish Neovim/tooling playbook
|-- dev-env/
|   |-- run                      # Runs scripts from dev-env/runs
|   `-- runs/
|       |-- dotfiles             # Ubuntu/Linux mirror of dotfiles.yml
|       |-- terminal             # Ubuntu/Linux mirror of terminal.yml
|       `-- neovim              # Ubuntu/Linux mirror of neovim.yml
|-- dotfiles/
|   |-- .config/
|   |   |-- ghostty/             # Ghostty config and themes
|   |   |-- kitty/               # Kitty config and themes
|   |   |-- nvim/                # Neovim config, managed by lazy.nvim
|   |   |-- starship/            # Starship prompt config
|   |   `-- tmux/                # tmux config
|   `-- .local/
|       `-- scripts/             # User scripts linked into ~/.local/scripts
|-- docs/
|   |-- setup.md                 # Bootstrap and dependency guide
|   |-- vscode-to-neovim.md      # VS Code feature translation
|   |-- neovim-power-user.md     # Vim/Neovim power path
|   |-- architecture.md          # Runtime and plugin architecture
|   `-- tutorials/               # Ordered deep-dive learning series
`-- current-plan.md              # Living implementation checklist
```

## Mental Model

```text
          +----------------------+
          |  repo/dotfiles       |
          |  source of truth     |
          +----------+-----------+
                     |
       symlink setup | dotfiles.yml / dev-env/runs/dotfiles
                     v
          +----------------------+
          |  ~/.config/nvim      |
          |  ~/.config/tmux      |
          |  ~/.config/kitty     |
          |  ~/.config/ghostty   |
          |  ~/.config/starship  |
          |  ~/.local/scripts    |
          +----------+-----------+
                     |
        Neovim boot | init.lua -> de100.core -> de100.lazy
                     v
          +----------------------+
          |  lazy.nvim           |
          |  plugin specs        |
          +----------+-----------+
                     |
     language tools | Mason + system packages
                     v
          +----------------------+
          |  LSP / DAP / format  |
          |  lint / test / git   |
          +----------------------+
```

Read these in order:

1. `setup.md`
2. `vscode-to-neovim.md`
3. `neovim-power-user.md`
4. `architecture.md`
5. `tutorials/README.md`

Terminal-first users should also read
`neovim-tutorials-from-0-to-hero/20-shell-terminal-tmux.md`.
