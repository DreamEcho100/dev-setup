# 20. Shell, Terminal, Themes, and tmux

This chapter is the workstation layer around Neovim. VS Code bundles a terminal,
settings UI, theme picker, command palette, tasks, and remote-ish workflows into
one app. A terminal-native setup splits those jobs across focused tools.

## VS Code Translation

| VS Code feature | Terminal-native equivalent |
| --- | --- |
| Integrated terminal | Kitty or Ghostty |
| Terminal profile | zsh config in `~/.zshrc` |
| Command palette | shell aliases, `fzf`, `tmux-sessionizer`, Neovim Snacks |
| Theme picker | `de100-theme set <theme>` |
| Terminal font setting | Kitty/Ghostty font config |
| Terminal tabs/splits | tmux sessions, windows, and panes |
| Restore windows | `tmux-resurrect` and `tmux-continuum` |
| Tasks | `overseer.nvim`, shell scripts, tmux windows |
| Remote terminal | SSH plus tmux |

## Bootstrap

Run the terminal layer separately from Neovim:

```sh
ansible-playbook terminal.yml -K
dev-env/runs/terminal --dry
dev-env/runs/terminal
```

Then activate dotfiles:

```sh
dev-env/runs/dotfiles --dry
dev-env/runs/dotfiles
```

Open a new terminal and verify:

```sh
echo "$XDG_DATA_HOME"
echo "$XDG_STATE_HOME"
command -v zsh git starship zoxide fzf tmux
test -d ~/.oh-my-zsh && echo "oh-my-zsh ready"
```

`XDG_DATA_HOME` should be `~/.local/share`, not a VS Code Snap path. If it is
still under `~/snap/code/...`, the repo `.zshenv` is not active in that shell.

## zsh

The repo-managed shell is intentionally split:

- `~/.zshenv`: minimal XDG/PATH recovery for all zsh invocations.
- `~/.zshrc`: interactive shell UX.
- `~/.zshenv.local`: machine-local env/secrets, not tracked.
- `~/.zshrc.local`: aliases and personal overrides, not tracked.

The beginner/default setup uses Oh My Zsh plus Powerlevel10k. This matches the
previous working shell UX and is easier to debug while you are also learning
Neovim and Go.

Default Oh My Zsh plugins:

- Oh My Zsh `git`: git aliases and shell helpers.
- Oh My Zsh `colored-man-pages`: readable colored man pages.
- Oh My Zsh `colorize`: syntax-colored file preview helpers when dependencies exist.
- `zsh-autosuggestions`: suggestions from history.
- `zsh-autocomplete`: VS Code-like automatic completion listing while typing.
- `fast-syntax-highlighting`: fast command syntax colors.

The old config loaded both `zsh-syntax-highlighting` and
`fast-syntax-highlighting`. This repo keeps one syntax highlighter by default
because loading both can double-wrap zle widgets and break completion/prompt
behavior.

`fast-syntax-highlighting` is loaded before `zsh-autocomplete` in this setup.
That intentionally breaks the usual "syntax highlighter last" rule because this
plugin otherwise prints startup warnings for zsh-autocomplete widgets.

Oh My Zsh owns the default framework setup. Do not add a manual `compinit` call
or enable `fzf-tab` at the same time unless you are deliberately testing a
different completion stack. History/search behavior:

- `Ctrl+r`: zsh-autocomplete history search.
- `Ctrl+s`: menu text search / forward search.
- `Ctrl+w`: deletes one path segment because `/` is removed from zsh `WORDCHARS`.

Preserved compatibility hooks:

- NVM loads if `~/.nvm` exists and `DE100_LOAD_NVM` is not `0`.
- PNPM is added from `~/.local/share/pnpm` when present.
- envman loads from `~/.config/envman/load.sh` when present.
- Cursor aliases are created when the referenced files exist.
- Powerlevel10k is used automatically when `~/.p10k.zsh` and the P10k theme are present.
- Starship is installed but inactive by default. Force it with `DE100_SHELL_PROMPT=starship`.

Antidote remains available as an advanced opt-in path:

```sh
DE100_ZSH_PLUGIN_MANAGER=antidote exec zsh
```

To make that permanent on one machine, put this in `~/.zshrc.local`:

```sh
export DE100_ZSH_PLUGIN_MANAGER=antidote
```

Use Antidote when you specifically want faster explicit plugin management and
are comfortable debugging plugin load order. Use Oh My Zsh while learning or
when you want the least surprising shell behavior.

## Kitty And Ghostty

Both terminal emulators are first-class:

- Kitty is better when you want advanced terminal features and scripting.
- Ghostty is intentionally simpler and fast to configure.

Both use:

- Tokyo Night by default.
- JetBrainsMono Nerd Font by default.
- High scrollback.
- Copy-on-select.
- Font zoom keymaps.
- Local override files.

Override font examples:

```conf
# ~/.config/kitty/local.conf
font_family FiraCode Nerd Font Mono
font_size 13.0
```

```conf
# ~/.config/ghostty/local.ghostty
font-family = FiraCode Nerd Font Mono
font-size = 13
```

## Theme Switching

Use one command for terminals, Starship, and Neovim:

```sh
de100-theme list
de100-theme current
de100-theme set tokyo-night
de100-theme set catppuccin-mocha
de100-theme set rose-pine-moon
de100-theme set gruvbox-dark
de100-theme set evergarden-spring
```

What it writes:

- `~/.config/kitty/local.conf`
- `~/.config/ghostty/local.ghostty`
- `~/.local/state/de100/theme/starship.toml`
- `~/.local/state/de100/theme/nvim.lua`

Those are local override/state files. They are ignored by Git, so theme changes
do not dirty the repo.

Reload behavior:

- Kitty: restart the terminal or reload config from Kitty controls.
- Ghostty: reload config or restart the terminal.
- Starship: open a new shell.
- Neovim: restart or run `:colorscheme <name>` manually for a live preview.

## tmux Basics

tmux gives you persistent terminal workspaces:

```sh
tmux new -s main
tmux attach -t main
tmux ls
```

Default prefix remains `Ctrl+b`.

Important bindings:

| Action | Binding |
| --- | --- |
| Reload config | `Ctrl+b r` |
| Split right | `Ctrl+b \|` |
| Split down | `Ctrl+b -` |
| New window | `Ctrl+b c` |
| Move pane left/down/up/right | `Ctrl+b h/j/k/l` |
| Project picker popup | `Ctrl+b f` |
| Project picker new window | `Ctrl+b F` |
| Copy mode | `Ctrl+b [` |

Persistence is enabled through TPM plugins:

- `tmux-resurrect`: save/restore sessions.
- `tmux-continuum`: auto-save and auto-restore.

If plugins do not load, install the terminal stack again or check:

```sh
ls ~/.tmux/plugins/tpm
```

## Sessionizer Roots

`tmux-sessionizer` searches these by default:

- `~/Desktop/workspaces`
- `~/projects`
- `~/personal`
- `~`

Override them with an env var:

```sh
export TMUX_SESSIONIZER_DIRS="$HOME/Desktop/workspaces:$HOME/personal"
```

Or create:

```text
~/.config/tmux/sessionizer-dirs
```

With one directory per line.

## Atuin

Atuin config is included but shell integration is disabled by default. To enable
local-only history later:

```sh
dev-env/runs/terminal --with-atuin
echo 'export DE100_ENABLE_ATUIN=1' >> ~/.zshrc.local
```

The repo config sets sync off by default. Do not enable sync until you choose
an account/encryption strategy.

## What Was Missing

Before this terminal phase, the repo had a strong Neovim config but an incomplete
workstation layer:

- No first-class zsh config in the repo.
- No safe activation path for existing `~/.zshrc`, `~/.zshenv`, or `~/.profile`.
- No repo-managed Kitty/Ghostty profiles.
- No shared font strategy.
- No shared terminal/Neovim theme switching strategy.
- No Starship prompt config that dotfile bootstrap would actually activate.
- tmux persistence was documented but not enabled.
- tmux session roots were hardcoded.
- VS Code Snap XDG leakage could still break Neovim plugin writes until the repo shell files were activated.

The result is now a complete editor workstation path: shell, terminal, tmux,
Neovim, language tools, and docs all live in the same repo.
