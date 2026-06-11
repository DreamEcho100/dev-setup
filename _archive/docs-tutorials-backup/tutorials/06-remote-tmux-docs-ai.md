# 06. Remote, Tmux, Docs, Images, And AI

This config treats remote and terminal workflows as first-class.

## Tmux

Use tmux as the project process layer.

```text
tmux session = project
tmux window  = workflow area
tmux pane    = process
Neovim       = editor
```

Useful Neovim integration:

| Action | Key |
| --- | --- |
| Launch tmux sessionizer | `<C-f>` |
| Navigate splits | `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` |

Use tmux for dev servers, test watchers, database shells, and remote sessions.

## Remote Workflows

Three supported paths:

```text
SSH + tmux + nvim
remote-nvim plugin
conn-manager plugin
```

Use SSH + tmux by default for reliability.

Use `remote-nvim` when you want a local UI against a remote host/container/devpod.

Use `conn-manager` when you want saved SSH connection workflows.

The remote plugins are dependency-aware and will not load when required tools are missing.

## Markdown, Mermaid, Images

Enabled tooling:

```text
render-markdown.nvim
Snacks image support
Mermaid CLI
ImageMagick
ascii-image-converter
Graphviz
```

Use Markdown preview/rendering inside Neovim for reading and authoring docs. Mermaid and image tools are default-installed by the bootstrap path.

## LaTeX

Enabled tooling:

```text
VimTeX
texlab
latexmk
TeX Live packages
```

Use VimTeX for compile/view workflows and texlab for LSP diagnostics/completion.

## Multicursor

Multicursor remains enabled for VS Code-style editing.

| Action | Key |
| --- | --- |
| Add cursor at match | `<leader>mc` |
| Add cursors at all matches | `<leader>mC` |
| Clear cursors/search | `<Esc>` |

Vim-native alternatives:

```text
:%s/old/new/g
macro recording with qa ... q and @a
visual block mode with <C-v>
text objects with ciw, di", yip
dot repeat with .
```

Use multicursor when it is actually clearer. Prefer substitutions/macros for repeatable mechanical edits.

## AI Hooks

AI is disabled by default.

Documented default when you choose to enable AI:

```text
CodeCompanion for chat/edit orchestration
```

Optional hooks:

```text
Copilot for inline suggestions
Avante for chat/edit experiments
Codex CLI or Claude Code in terminal/tmux workflows
Sidekick can be evaluated later if you want another Folke-native AI layer
```

Enable manually:

```sh
export DE100_ENABLE_CODECOMPANION=1
export DE100_ENABLE_COPILOT=1
export DE100_ENABLE_AVANTE=1
```

Do not put API keys or tokens in this repo.
