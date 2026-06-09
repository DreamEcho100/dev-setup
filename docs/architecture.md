# Architecture Tour

This is the big-picture map of the repo and runtime.

## Repo To Machine

```text
                         MFANSIBLE REPO
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  dotfiles.yml                  neovim.yml                           │
│      │                            │                                  │
│      │ mirrors                    │ mirrors                          │
│      v                            v                                  │
│  dev-env/runs/dotfiles        dev-env/runs/neovim                   │
│      │                            │                                  │
│      │ symlinks                   │ installs                         │
│      v                            v                                  │
│  dotfiles/.config/nvim        Neovim source + system tools          │
│  dotfiles/.config/tmux        Mason prerequisites                   │
│  dotfiles/.local/scripts      Language/debug/doc tooling            │
│  dotfiles/.zshenv                                                    │
│  dotfiles/.profile                                                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                         │
                         v
                        HOME
┌─────────────────────────────────────────────────────────────────────┐
│ ~/.config/nvim   -> repo/dotfiles/.config/nvim                     │
│ ~/.config/tmux   -> repo/dotfiles/.config/tmux                     │
│ ~/.local/scripts -> repo/dotfiles/.local/scripts                   │
│ ~/.zshenv        -> repo/dotfiles/.zshenv                          │
│ ~/.profile       -> repo/dotfiles/.profile                         │
└─────────────────────────────────────────────────────────────────────┘
```

## Neovim Boot

```text
init.lua
  │
  ├─ require("de100.core")
  │    │
  │    ├─ options.lua
  │    │   ├─ numbers, clipboard, indentation, search
  │    │   ├─ split behavior, undo, completion menu
  │    │   └─ baseline UI defaults
  │    │
  │    └─ keymaps.lua
  │        ├─ VS Code bridge keys: <C-s>, buffers, splits
  │        ├─ Vim power keys: centered jumps, diagnostics, movement
  │        └─ utility keys: copy path, diagnostics toggle, split zoom
  │
  ├─ require("de100.lazy")
  │    │
  │    ├─ bootstraps lazy.nvim
  │    ├─ imports de100.plugins
  │    └─ imports de100.plugins.lsp
  │
  └─ require("current-theme")
       └─ applies persisted colorscheme
```

## Plugin Domains

```text
┌──────────────────┬──────────────────────────────────────────────────┐
│ Domain           │ Plugins                                           │
├──────────────────┼──────────────────────────────────────────────────┤
│ UI/discovery     │ snacks, which-key, lualine, incline, showkeys     │
│ Finding          │ snacks, ripgrep, quickfix                         │
│ Files            │ oil, mini.files                                   │
│ Editing          │ mini.ai, mini.surround, splitjoin, comments       │
│ Completion       │ blink.cmp, LuaSnip, friendly-snippets             │
│ LSP              │ nvim-lspconfig, mason-lspconfig, lazydev          │
│ Format/lint      │ conform, nvim-lint                                │
│ Git              │ gitsigns, fugitive, lazygit through snacks        │
│ Diff/review      │ diffview                                          │
│ Debug            │ nvim-dap, dap-ui, dap-go, Mason DAP adapters      │
│ Test/tasks       │ neotest, overseer                                 │
│ Remote           │ remote-nvim, conn-manager, ssh, tmux              │
│ Docs/math        │ render-markdown, vimtex, Mermaid/LaTeX tooling    │
│ AI hooks         │ codecompanion default hook, copilot/avante optional │
└──────────────────┴──────────────────────────────────────────────────┘
```

## Language Tool Flow

```text
                 open a source file
                         │
                         v
                  Treesitter parser
                         │
           ┌─────────────┴─────────────┐
           v                           v
      syntax/indent              LSP root detect
                                       │
                                       v
                                  LSP server
                                       │
          ┌────────────────────────────┼────────────────────────────┐
          v                            v                            v
    diagnostics                   completion                   code actions
          │                            │                            │
          v                            v                            v
    trouble/snacks                blink.cmp                    rename/fix/etc

                 save or format command
                         │
                         v
                      conform
                         │
          ┌──────────────┼──────────────┐
          v              v              v
       project        Mason tool      LSP fallback
       binary         fallback        if formatter exists

                 lint trigger
                         │
                         v
                     nvim-lint
                         │
                         v
              external linter diagnostics
```

## Debug Flow

```text
F5 / DAP command
      │
      v
 nvim-dap
      │
      ├─ reads global defaults from nvim-dap.lua
      ├─ reads .nvim/dap.lua when a project has custom Lua config
      ├─ reads .vscode/launch.json when present
      │
      v
 debug adapter
      │
      ├─ js-debug-adapter      JS/TS/Node/browser
      ├─ debugpy               Python
      ├─ delve                 Go
      ├─ codelldb              C/C++/Rust
      └─ netcoredbg            C#/.NET
```

## Remote Flow

```text
Option A: terminal-native, most reliable

local terminal -> ssh host -> tmux session -> nvim

Option B: editor-style remote UI

local nvim -> remote-nvim -> ssh/devpod/docker -> remote nvim server -> local UI

Option C: connection manager

ConnManager -> ssh target -> opens tab/window or terminal -> optional tmux/nvim
```

## VS Code Bridge Philosophy

```text
Keep familiar:
  Ctrl-S, command palette, file picker, diagnostics panel, debug keys,
  task runner, project search/replace, Git UI, remote workflows.

Teach power:
  motions, text objects, operators, registers, marks, macros, quickfix,
  buffers/windows/tabs, tmux sessions, ripgrep, LSP-native refactors.

Avoid trap:
  Do not rebuild VS Code inside Neovim plugin-by-plugin.
  Use familiar surfaces as training wheels, then graduate to primitives.
```
