# Neovim Power User Path

Power in Neovim comes from composable primitives.

## Core Primitives

```text
Motions       w b e f t / ? % } {
Text objects  iw aw ip ap i" a" i) a) custom mini.ai objects
Operators     d c y gq = > <
Registers     " + * 0 _ a-z
Marks         m' mA `A 'A
Macros        qa ... q  @a  @@
Lists         quickfix, loclist, diagnostics, grep results
Buffers       loaded files, not UI tabs
Windows       views into buffers
Tabs          layouts/workspaces
Tmux          terminal/session/window/pane layer
```

## Editing Flow

```text
Need to change code?
  |
  +-- local single place  -> motion + operator
  +-- repeated pattern    -> dot repeat or macro
  +-- semantic symbol     -> LSP rename / code action
  +-- project-wide text   -> grug-far / ripgrep + quickfix
  +-- structured object   -> text object / treesitter / splitjoin
```

## Plugin Responsibilities

```text
UI/discovery       Snacks, which-key, lualine, incline
Finding            Snacks picker, ripgrep, quickfix
Editing            mini.ai, mini.surround, mini.splitjoin, autopairs, comments
Navigation         Flash, Harpoon, LSP locations, quickfix
Files              Oil, mini.files
Git                Gitsigns, Fugitive, LazyGit, Diffview
Language           nvim-lspconfig, Mason, Treesitter
Completion         Blink, LuaSnip, friendly-snippets
Format/lint        Conform, nvim-lint
Debug              nvim-dap, dap-ui, Mason DAP adapters
Tasks/tests        Overseer, neotest
Remote             remote-nvim, conn-manager, SSH, tmux
Docs/math          render-markdown, VimTeX, Mermaid/LaTeX tooling
```

## Quickfix Mindset

Quickfix is the terminal-native Problems/Search Results panel.

```text
grep -> quickfix -> inspect -> edit -> next -> repeat
diagnostics -> quickfix -> fix -> next -> repeat
compiler/test errors -> quickfix -> fix -> rerun
```

Useful habits:

- Keep search results as navigable state.
- Prefer repeatable commands over one-off UI clicks.
- Use location lists for buffer/window-local results.

## Tmux Layer

```text
tmux session = project
tmux window  = workflow area
tmux pane    = process
Neovim       = editor brain
shell tools  = build/test/run/debug support
```

Remote work should usually start with SSH + tmux for reliability. Editor-style remote plugins are useful when you need a local UI against a remote Neovim instance.

## AI Hooks

Keep AI tools outside the core editing contract:

- Copilot-style inline suggestions are completion aids.
- Codex/Claude Code are agent workflows.
- CodeCompanion is the documented default chat/edit layer, but it is disabled until explicitly enabled.
- Avante and Sidekick are optional chat/edit orchestration layers.
- API keys and tokens must stay in environment variables or external secret stores.

The config should expose clean hooks without making startup depend on any AI provider.
