# 08. Maintenance And Health

Use this file after changing plugins, installers, or docs.

## Global Checks For This Repo

There is no top-level package script in this repo. Use the repository-native checks:

```sh
git diff --check
rg --files dotfiles/.config/nvim/lua -g "*.lua" | xargs luac -p
ansible-playbook --syntax-check dotfiles.yml
ansible-playbook --syntax-check neovim.yml
dev-env/runs/dotfiles --dry
dev-env/runs/neovim --dry
```

If Ansible cannot write temp files under the sandboxed home:

```sh
env ANSIBLE_LOCAL_TEMP=/tmp/ansible-local TMPDIR=/tmp ansible-playbook --syntax-check dotfiles.yml
env ANSIBLE_LOCAL_TEMP=/tmp/ansible-local TMPDIR=/tmp ansible-playbook --syntax-check neovim.yml
```

Dotfiles check mode:

```sh
env ANSIBLE_LOCAL_TEMP=/tmp/ansible-local TMPDIR=/tmp \
  ansible-playbook --check -e ansible_remote_tmp=/tmp/ansible-remote dotfiles.yml
```

## Neovim Isolated Health

Use isolated XDG dirs so VS Code Snap paths or local user plugin state do not contaminate the check.

```sh
env \
  XDG_CONFIG_HOME="$PWD/dotfiles/.config" \
  XDG_DATA_HOME=/tmp/mfansible-nvim-data \
  XDG_STATE_HOME=/tmp/mfansible-nvim-state \
  XDG_CACHE_HOME=/tmp/mfansible-nvim-cache \
  nvim --headless "+Lazy! sync" "+qa"
```

Startup check:

```sh
env \
  XDG_CONFIG_HOME="$PWD/dotfiles/.config" \
  XDG_DATA_HOME=/tmp/mfansible-nvim-data \
  XDG_STATE_HOME=/tmp/mfansible-nvim-state \
  XDG_CACHE_HOME=/tmp/mfansible-nvim-cache \
  nvim --headless "+qa"
```

Health check:

```sh
env \
  XDG_CONFIG_HOME="$PWD/dotfiles/.config" \
  XDG_DATA_HOME=/tmp/mfansible-nvim-data \
  XDG_STATE_HOME=/tmp/mfansible-nvim-state \
  XDG_CACHE_HOME=/tmp/mfansible-nvim-cache \
  nvim --headless "+checkhealth lazy" "+checkhealth provider" "+qa"
```

## Inside Neovim

| Command | Purpose |
| --- | --- |
| `:Lazy` | Inspect plugins |
| `:Lazy sync` | Install/update plugins and lockfile |
| `:Mason` | Inspect external tools |
| `:MasonToolsInstall` | Install configured Mason tools |
| `:checkhealth` | Full health report |
| `:ConformInfo` | Formatter resolution |
| `:LspInfo` or `:checkhealth vim.lsp` | LSP clients and diagnostics |

## Format, Lint, Type Check, Test Habit

For this repo:

```sh
git diff --check
luac -p path/to/file.lua
ansible-playbook --syntax-check playbook.yml
```

For projects edited with this Neovim config:

```text
format:     project formatter, then Conform
lint:       project linter, then nvim-lint
typecheck:  project typecheck command
test:       nearest test, file tests, then full suite
```

Use Overseer for repeatable project commands. Use tmux for long-running watchers.

## Lockfile Policy

`lazy-lock.json` should change when:

- a plugin is added
- a plugin is removed
- `:Lazy sync` intentionally updates plugin pins

Review lockfile diffs before committing.

## Commit Policy

Logical commit groups for this project:

1. backups and plan/docs scaffolding
2. bootstrap/playbook/script changes
3. Neovim plugin/config modernization
4. tutorial documentation
5. verification/plan updates
