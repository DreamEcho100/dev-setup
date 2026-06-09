# VS Code Power User To Neovim

The goal is not to clone VS Code. The goal is to keep the productive parts while teaching the terminal-native model.

## Translation Table

| VS Code Concept | Neovim/Tmux Equivalent |
| --- | --- |
| Command Palette | Snacks picker, `which-key`, `:` commands |
| Explorer | Oil as default, `mini.files` as lightweight secondary |
| Quick Open | Snacks files/recent/buffers |
| Search in files | Snacks grep, `grug-far.nvim`, ripgrep |
| Source Control | Gitsigns, Fugitive, LazyGit, Diffview |
| Debug panel | `nvim-dap`, `nvim-dap-ui`, Mason DAP adapters |
| Tasks | `overseer.nvim`, tmux panes, project scripts |
| Problems panel | Trouble, diagnostics pickers, quickfix/location lists |
| Extensions | Lazy plugin specs, Mason tools |
| Settings JSON | Lua modules under `dotfiles/.config/nvim/lua/de100` |
| Remote SSH | `remote-nvim`, `conn-manager`, SSH + tmux |
| Integrated terminal | Neovim terminal buffers and tmux panes |
| Multi-cursor | `multicursor.nvim`, macros, visual block mode, substitutions |
| Snippets | LuaSnip + friendly-snippets through Blink |
| IntelliSense | LSP + Blink completion |
| Format on save | Conform |
| Linting | nvim-lint + LSP diagnostics |

## Daily Loop

```text
Open project
  |
  v
Find file     -> Snacks picker / Oil
  |
  v
Edit          -> motions, text objects, completion, snippets
  |
  v
Navigate      -> LSP, Flash, Harpoon, marks, buffers
  |
  v
Validate      -> diagnostics, tests, tasks, DAP
  |
  v
Commit        -> Gitsigns, Fugitive, LazyGit, Diffview
```

## Key Habit Changes

1. Think in buffers, windows, and tabs instead of editor tabs only.
2. Use quickfix/location lists for repeatable diagnostic/search navigation.
3. Use motions/text objects before reaching for the mouse.
4. Use tmux for terminal workspace management.
5. Use project-local tools when available, with Mason/system tools as fallback.

## VS Code Familiarity Kept

- `<C-s>` saves.
- F-key debug controls remain available.
- Pickers provide command-palette-like discovery.
- DAP reads VS Code-style `.vscode/launch.json` where possible.
- Tasks can map to package scripts and shell commands.
- AI provider hooks are documented but secrets stay outside the repo.
- Telescope stays installed only for plugin compatibility. User-facing picker workflows should use Snacks.

## Power Upgrade Path

```text
Week 1: file finding, save/quit, LSP navigation, Git signs
Week 2: text objects, surround, split/join, quickfix
Week 3: macros, marks, registers, substitutions
Week 4: tmux sessions, remote workflows, DAP, project tasks
Week 5+: language-specific tooling and custom Lua
```
