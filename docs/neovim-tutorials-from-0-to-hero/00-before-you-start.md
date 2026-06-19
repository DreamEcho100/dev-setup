# 00 · Before You Start

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  This file covers everything BEFORE you write your first line of code in    │
│  Neovim. Philosophy, config structure, installation, first launch,          │
│  and the key concepts you'll rely on for the rest of the series.            │
│                                                                              │
│  Estimated time: 45–90 minutes (including actually running things)           │
│  Prerequisites: repo cloned, Ansible installed, sudo access                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Table of Contents

1. [What Even IS Neovim?](#1-what-even-is-neovim)
   - Terminal-first, keyboard-only
   - Why give up your GUI? — Honest timelines
   - VSCode vs Neovim mental model
   - The composable tools philosophy
2. [This Repo's Config Structure](#2-this-repos-config-structure)
   - Annotated directory tree
   - The boot sequence diagram
   - Purpose of each subdirectory
3. [Installation](#3-installation)
   - Prerequisites table
   - Running the Ansible playbook
   - What the playbook installs (categorized)
   - XDG paths: the Snap caveat
   - Manual install fallback
4. [First Launch](#4-first-launch)
   - Opening Neovim
   - What you see immediately
   - :Lazy sync — why first
   - :checkhealth — reading the output
   - Expected warnings vs real errors
5. [Config Key Concepts](#5-config-key-concepts)
   - lazy.nvim
   - mason.nvim
   - which-key.nvim
   - The leader key and keybinding notation
6. [The Reference Files You'll Use Most](#6-the-reference-files-youll-use-most)
   - :help
   - hawtkeys.nvim
   - :Lazy
   - :checkhealth
   - :LspInfo
   - :Mason
7. [Exercises](#7-exercises)

---

## 1. What Even IS Neovim?

### Terminal-First, Keyboard-Only

Let's be honest before diving in. Neovim is weird. When you first open it,
there's no toolbar, no sidebar, no tabs, no settings gear in the corner. There
is a cursor, a status bar, and silence.

That's not a bug. That's the entire point.

Neovim descends from Vi (1976) and Vim (1991) — editors designed for terminal
environments where mice don't exist and every keystroke is precious. Neovim
(2014) took that foundation and rebuilt it: async architecture, a real Lua
scripting engine, a built-in LSP client, a built-in terminal, and an API that
lets plugins do things Vim never could. It still runs in your terminal, but it
has the capability of a modern IDE.

The two foundational ideas that make Neovim feel alien to GUI users:

**1. Modal editing.** Most editors are always in "insert" mode — you press a
key, that character appears. Neovim has multiple modes. In **Normal mode** your
keystrokes are commands, not text input. `d` doesn't type the letter d — it
means "delete." This lets you say complex things with very few keystrokes, but
it requires learning a new reflex.

**2. Text as a language.** Normal mode has a grammar. `d` is a verb (delete).
`w` is a noun (word). `d` + `w` = "delete word." `c` + `i` + `"` = "change
inside quotes." Once you internalize this grammar, you stop thinking about
cursor positions and start thinking about what you want to do to text.

These two ideas feel slow and painful for a week or two, and then they feel
like superpowers.

> **💡 In VSCode you'd...** always be in "insert" mode. To delete a word you'd
> double-click it then press Delete. To rename a variable you'd Ctrl+D for
> each occurrence. **In Neovim you...** are in Normal mode most of the time.
> To delete a word: `dw`. To rename a variable project-wide: `<leader>rn`.
> The keyboard is your entire interface.

### "Why Give Up My GUI?" — An Honest Answer With Timelines

Nobody who's been using VSCode for years switches to Neovim because it's
slightly better. They switch because at some point they realize they've been
fighting their editor — moving hands to the mouse, clicking through menus,
waiting for extensions to load — and they want to eliminate all of that
friction.

Here is what you should actually expect:

```
═══════════════════════════════════════════════════════════════════════
 Timeline             Experience                         Speed
═══════════════════════════════════════════════════════════════════════

 Days 1–3            "I can't do anything. I keep pressing          25%
                      the wrong keys. How do I PASTE?"
                      → You're learning the alphabet of a
                        new language. Embarrassing but normal.

 Days 4–7            "OK I get modes now. Some of this is           40%
                      actually clever. But I miss Ctrl+P."
                      → You're starting to see the grammar.
                        Telescope exists. It's better than Ctrl+P.

 Weeks 2–3           "Oh. OH. I just changed every function         65%
                      argument in this file in 30 seconds."
                      → The grammar clicks. You start combining
                        verbs and nouns instinctively.

 Month 1             "I'm faster at the things I do most            90%
                      often. Slower at weird edge cases."
                      → Your muscle memory is rebuilding.
                        You stop thinking about keys.

 Month 2–3           "Why do I still have VSCode installed?"        110%+
                      → You've hit the VSCode speed ceiling
                        (mouse + click). Neovim's ceiling
                        is your thinking speed.

═══════════════════════════════════════════════════════════════════════
```

The honest caveat: some things that are instant in VSCode — installing an
extension via a GUI, connecting to a remote container with one click — require
more setup in Neovim. The tradeoff is that once something is configured in
Neovim, it's in a Lua file in your git repo and it works forever on every
machine you set up.

**When Neovim is clearly better:**

- Writing code for hours. The ergonomic reduction in mouse movement compounds.
- Refactoring. Structural text operations that would take 10 clicks take 3 keys.
- Remote work over SSH. No GUI overhead, runs at terminal speed.
- Working in 3+ files simultaneously. Splits + buffers + harpoon is faster than
  tabs.
- Scripting your editor. Any plugin behavior can be expressed in Lua.

**When VSCode is still fine:**

- Opening a project for the first time in an unfamiliar language.
- Pair programming with someone who can't drive Neovim.
- Quick one-off edits where you can't remember the keybindings.
- Jupyter notebooks (the plugin support is improving but VSCode has the lead).

### VSCode vs Neovim: The Mental Model

This is the most important conceptual shift you need to make. Print it out if
that helps.

```
╔══════════════════════════════════════════════════════════════════════════╗
║                      VSCode Mental Model                                 ║
╠══════════════════════════════════════════════════════════════════════════╣
║                                                                          ║
║  EVERYTHING IS A PANEL                                                   ║
║  ┌──────────────┬───────────────────────────────────────────────────┐   ║
║  │ EXPLORER     │  TAB BAR:  [app.ts ×]  [index.ts]  [style.css]   │   ║
║  │ ─────────    ├───────────────────────────────────────────────────┤   ║
║  │ ▼ src/       │                                                   │   ║
║  │   ▼ comp/    │   1  import React from 'react'                   │   ║
║  │     App.tsx  │   2  import { useState } from 'react'            │   ║
║  │   index.ts   │   3                                               │   ║
║  │   style.css  │   4  export function App() {                     │   ║
║  ├──────────────┤   5    const [n, setN] = useState(0)             │   ║
║  │ EXTENSIONS   │   6    return <div>{n}</div>                     │   ║
║  │ GIT          │   7  }                                           │   ║
║  │ RUN/DEBUG    ├───────────────────────────────────────────────────┤   ║
║  │ SEARCH       │  PROBLEMS │ OUTPUT │ TERMINAL │ PORTS            │   ║
║  └──────────────┴───────────────────────────────────────────────────┘   ║
║                                                                          ║
║  • One monolithic GUI application                                        ║
║  • Mouse-driven by default                                               ║
║  • Extensions live inside the app as bundled packages                    ║
║  • "Tabs" = one file per tab, always visible                            ║
║  • Configuration = JSON (settings.json, extensions settings)             ║
╚══════════════════════════════════════════════════════════════════════════╝

╔══════════════════════════════════════════════════════════════════════════╗
║                      Neovim Mental Model                                 ║
╠══════════════════════════════════════════════════════════════════════════╣
║                                                                          ║
║  BUFFERS ARE INVISIBLE. WINDOWS ARE VIEWPORTS. TABS ARE LAYOUTS.         ║
║                                                                          ║
║  Memory (you can't see this):                                            ║
║  ┌──────────────────────────────────────────────────────────────────┐   ║
║  │ Buffer #1: app.ts    Buffer #2: index.ts    Buffer #3: style.css │   ║
║  │ Buffer #4: types.ts  Buffer #5: test.ts     Buffer #6: README.md │   ║
║  └──────────────────────────────────────────────────────────────────┘   ║
║                                                                          ║
║  Screen (what you see):                                                  ║
║  ┌──────────────────────────────┬───────────────────────────────────┐   ║
║  │ Window 1                     │ Window 2                          │   ║
║  │ (showing Buffer #1: app.ts)  │ (showing Buffer #2: index.ts)    │   ║
║  │                              │                                   │   ║
║  │  1  import React from 'r'   │  1  export default function       │   ║
║  │  2  ...                      │  2  index() {                     │   ║
║  │                              │  3    return <App />              │   ║
║  │                              │  4  }                             │   ║
║  ├──────────────────────────────┴───────────────────────────────────┤   ║
║  │ app.ts [+]  lua  main  E:0 W:1          NORMAL       ln 2:15    │   ║
║  └───────────────────────────────────────────────────────────────────┘   ║
║                                                                          ║
║  • Neovim is a process. Plugins are Lua programs inside it.              ║
║  • Keyboard-driven by default (mouse supported but rarely used)          ║
║  • "Tabs" = screen layouts (each tab has its own window arrangement)     ║
║  • Files in memory = buffers. Visible areas = windows.                   ║
║  • Configuration = Lua code (full programming language)                  ║
╚══════════════════════════════════════════════════════════════════════════╝
```

The **most disorienting** thing for VSCode users: you can have 20 files
"open" (in buffers) with only 1 or 2 visible on screen. You navigate between
buffers using `<Tab>` / `<S-Tab>`, harpoon pins, or telescope fuzzy search —
not by clicking tabs in a tab bar.

The second most disorienting thing: you don't have a file tree panel open all
the time. You open files with `<leader>pf` (fuzzy file search), navigate the
filesystem with `-` (oil.nvim), or pin frequent files with harpoon. After a
week, you'll realize you never actually looked at the file tree — you were
clicking through it to find files, and fuzzy search finds them in 0.3 seconds.

### The Philosophy: Composable Tools vs Monolithic App

VSCode tries to be everything: run terminals, manage git, connect to remote
servers, run tests, format code, provide AI assistance. Each feature is a
bundled "panel" that adds to the application's weight and startup time.

Neovim's bet is different: **edit text brilliantly, then compose with the
best external tools for everything else.**

```
What you do             VSCode approach              Neovim approach
──────────────────────  ──────────────────────────── ─────────────────────────────
Find text in files      Built-in search panel        Telescope + ripgrep
                        (decent)                     (very fast, composable)

Git operations          Source Control panel         Neogit + Gitsigns + git CLI
                        (basic, GUI-oriented)        (full git power, fast)

File browser            Explorer panel               oil.nvim (files ARE buffers)
                        (hierarchical tree)          (edit filenames like text!)

Remote editing          Remote SSH extension         SSH into box, run nvim there
                        (VSCode server overhead)     (zero GUI, zero latency)

Running terminal        Built-in terminal panel      tmux panes (always available,
                        (one per project)            persistent, scriptable)

Format on save          Prettier extension           conform.nvim → prettier CLI
                        (depends on extension API)   (same prettier, faster call)

HTTP requests           REST Client extension        kulala.nvim → .http files
                        (`.rest` files, GUI)         (same format, in-editor)
```

The benefit: when `ripgrep` releases a 2x speed improvement, your Neovim
search gets 2x faster automatically — no extension update required. When a new
language server comes out, you add its name to `mason.lua` and it installs
itself. You are always using the best version of each tool, not whatever a
mega-extension bundled 8 months ago.

The cost: you spend more time on initial setup, and when something breaks, you
need to debug multiple layers (Neovim + the external tool + the plugin). That's
what this config — and this tutorial series — is designed to minimize.

---

## 2. This Repo's Config Structure

### Annotated Directory Tree

Here is the complete structure of the Neovim config, with every file explained:

```
dotfiles/.config/nvim/
│
├── init.lua                    ← THE ENTRY POINT. Three lines. Everything
│                                  loads from here. See boot sequence below.
│
├── lazy-lock.json              ← Plugin version lockfile. Like package-lock.json
│                                  for Node. Records exact git commit hash of
│                                  every installed plugin. Commit this to git
│                                  so teammates get the same plugin versions.
│
├── lua/
│   ├── current-theme.lua       ← One-line file that picks the active colorscheme.
│   │                              Edit this to switch themes without touching
│   │                              the colorscheme plugin config.
│   │
│   └── de100/                  ← The personal namespace. "de100" = DreamEcho100.
│       │                          Neovim looks for modules in lua/ so this is
│       │                          importable as require("de100.whatever").
│       │
│       ├── core/
│       │   ├── init.lua        ← Loads options then keymaps. Called from init.lua.
│       │   │                      Short glue file.
│       │   ├── options.lua     ← All vim.opt.* settings:
│       │   │                      - Line numbers (relative + absolute)
│       │   │                      - Tab/indent settings (2 spaces, no expandtab)
│       │   │                      - Search behavior (ignorecase + smartcase)
│       │   │                      - Clipboard sync with system (unnamedplus)
│       │   │                      - Split behavior (below + right)
│       │   │                      - Scrolloff (8 lines padding), colorcolumn at 80
│       │   │                      - Persistent undo, no swapfile
│       │   └── keymaps.lua     ← All non-plugin keybindings:
│       │                          - Leader = Space (Space kills default Space)
│       │                          - Ctrl+s = save (normal + insert + command)
│       │                          - Ctrl+hjkl = move between splits
│       │                          - Tab / S-Tab = next/prev buffer
│       │                          - Arrow keys = resize splits
│       │                          - v-mode J/K = move lines up/down
│       │                          - <leader>dd = open diagnostic float
│       │                          - [d / ]d = prev/next diagnostic
│       │
│       ├── lazy.lua            ← Bootstraps lazy.nvim (clones it if missing),
│       │                          then sets up the plugin system by importing
│       │                          de100.plugins and de100.plugins.lsp.
│       │                          Also configures auto-update checking (silent).
│       │
│       └── plugins/
│           ├── init.lua        ← Core shared dependencies:
│           │                      - plenary.nvim (utility lib, many plugins need it)
│           │                      - vim-tmux-navigator (Ctrl+hjkl across nvim+tmux)
│           │                      - lazydev.nvim (Lua type hints for Neovim API)
│           │
│           ├── lsp/            ← LSP-specific plugins (separate dir for clarity)
│           │   ├── mason.lua   ← Three plugins in one file:
│           │   │                  1. mason.nvim: the package manager for LSP tools
│           │   │                  2. mason-lspconfig.nvim: auto-installs LSP servers
│           │   │                  3. mason-tool-installer.nvim: auto-installs
│           │   │                     formatters, linters, debug adapters
│           │   └── lsp.lua     ← nvim-lspconfig + keymaps that activate on LspAttach:
│           │                      gd=go to definition, gR=references, K=hover,
│           │                      <leader>ca=code actions, <leader>rn=rename,
│           │                      <leader>lv=toggle virtual text,
│           │                      <leader>li=toggle inlay hints
│           │
│           ├── blink-cmp.lua   ← Autocompletion engine (modern replacement for
│           │                      nvim-cmp). Sources: LSP, path, snippets, buffer.
│           │                      Snippet trigger = ";" (type ;bash for bash snippet)
│           │                      Ctrl+Space = force show menu
│           │                      Tab/S-Tab = navigate snippet jump points
│           │
│           ├── luasnip.lua     ← Snippet engine. Contains:
│           │                      - LuaSnip + friendly-snippets (community snippets)
│           │                      - Custom markdown snippets (code blocks, links)
│           │                      - All snippets prefixed with ";" trigger
│           │                      - filetype_extend: tsx gets js+ts snippets, etc.
│           │
│           ├── treesitter.lua  ← Syntax highlighting (not regex-based — it's a
│           │                      real parser). Also provides: indentation,
│           │                      semantic text objects (function, class, block),
│           │                      incremental selection, context display.
│           │
│           ├── telescope.lua   ← Fuzzy finder powering most search/navigation:
│           │                      - <leader>pf = find files
│           │                      - <leader>pg = live grep
│           │                      - <leader>pb = open buffers
│           │                      Uses fzf-native for fast matching.
│           │
│           ├── snacks.lua      ← Folke's "snacks" mega-plugin. Provides:
│           │                      - Dashboard (on empty nvim start)
│           │                      - Float terminal
│           │                      - Smart picker (replaces Telescope for some things)
│           │                      - Notifications (replaces vim.notify)
│           │                      - Scroll animations
│           │
│           ├── oil.lua         ← File manager. Key idea: your filesystem IS a buffer.
│           │                      You can rename files by editing text, create files
│           │                      by typing names, delete by deleting lines.
│           │                      "-" = open parent dir
│           │                      "<leader>-" = open parent dir in float
│           │
│           ├── harpoon.lua     ← Quick-access pins for up to 4 files.
│           │                      Think "bookmarks" but for your current task.
│           │                      <leader>ha = add current file
│           │                      <leader>h1-4 = jump to pinned file 1-4
│           │
│           ├── which-key.lua   ← Shows available keybinding completions when you
│           │                      pause after a prefix (Space, g, z, etc.).
│           │                      Delay = 300ms. Groups are labeled for readability.
│           │
│           ├── gitstuff.lua    ← Gitsigns: git decorations in the sign column.
│           │                      See added/changed/removed lines.
│           │                      Stage hunks, preview hunks, blame, reset hunks.
│           │                      <leader>gs, <leader>gp, <leader>gb, etc.
│           │
│           ├── neogit.lua      ← Full git UI inside Neovim. Commit, push, pull,
│           │                      rebase, cherry-pick. Closer to Magit (Emacs)
│           │                      than to the VSCode Source Control panel.
│           │
│           ├── diffview.lua    ← Side-by-side diff viewer. Also provides full
│           │                      file history (like git log --follow with diffs).
│           │                      <leader>gd, <leader>gh
│           │
│           ├── formatting.lua  ← conform.nvim: format on save. Each filetype maps
│           │                      to one or more formatters (prettier for TS/JS,
│           │                      stylua for Lua, ruff/black for Python, gofmt for Go).
│           │
│           ├── linting.lua     ← nvim-lint: run linters on BufWrite/BufEnter.
│           │                      Uses shellcheck, pylint, golangci-lint, etc.
│           │
│           ├── nvim-dap.lua    ← Debug Adapter Protocol client. Breakpoints,
│           │                      step-through, variable inspection, REPL.
│           │                      Works with debugpy (Python), delve (Go),
│           │                      codelldb (C/C++/Rust), js-debug-adapter (JS/TS).
│           │
│           ├── trouble.lua     ← Pretty list UI for:
│           │                      - Diagnostics (errors/warnings across all files)
│           │                      - LSP references and definitions
│           │                      - Quickfix list
│           │                      - Location list
│           │                      <leader>xx, <leader>xb, <leader>xq
│           │
│           ├── grug-far.lua    ← Interactive search-and-replace across files.
│           │                      Like VSCode's find-and-replace but with preview
│           │                      and confirmation per match.
│           │
│           ├── flash.lua       ← Jump anywhere on screen with 2-3 keystrokes.
│           │                      's' in normal mode = activate flash jump.
│           │                      Type 2 chars of target, pick label. Faster than
│           │                      f/F/t/T for long-distance jumps.
│           │
│           ├── hardtime.lua    ← Enforces good habits by blocking repeated hjkl
│           │                      presses and other inefficient patterns.
│           │                      It will tell you off. That's the point.
│           │
│           ├── hawtkeys.lua    ← Analyzes all keybindings, finds duplicates and
│           │                      available "hot" (easy-to-type) key slots.
│           │                      :Hawtkeys to open the UI.
│           │
│           ├── noice.lua       ← Replaces the default command-line and notification
│           │                      system with a floating, styled UI. Makes :commands
│           │                      appear in a centered float, messages in a corner.
│           │
│           ├── aerial.lua      ← Code outline / symbol tree. Shows all functions,
│           │                      classes, variables in the current file.
│           │                      <leader>a or :AerialToggle
│           │
│           ├── auto-save.lua   ← Saves the current buffer automatically after
│           │                      TextChanged + idle time, and on FocusLost.
│           │                      Means you almost never need to think about saving.
│           │
│           ├── auto-session.lua← Saves and restores your full session (all open
│           │                      windows, splits, buffers) per git branch.
│           │                      When you reopen Neovim in a project dir, you're
│           │                      back exactly where you left off.
│           │
│           ├── colorscheme.lua ← All installed colorschemes (tokyonight, catppuccin,
│           │                      gruvbox, rose-pine, etc). Switch in current-theme.lua.
│           │
│           ├── lualine.lua     ← Status line at the bottom. Shows:
│           │                      - Current mode (NORMAL/INSERT/VISUAL)
│           │                      - File name + unsaved indicator
│           │                      - Git branch and diff stats
│           │                      - LSP diagnostics (E:2 W:1 H:0)
│           │                      - Filetype, encoding, cursor position
│           │
│           ├── undotree.lua    ← Visual undo history as a tree. Never lose a
│           │                      change again, even after save.
│           │                      <leader>u to toggle.
│           │
│           ├── kulala.lua      ← REST client for .http files. Replaces VSCode's
│           │                      REST Client extension. Run requests with <leader>Hr.
│           │
│           ├── dadbod-ui.lua   ← SQL client. Connect to Postgres, MySQL, SQLite,
│           │                      run queries, browse tables. <leader>dadui.
│           │
│           ├── mini.lua        ← mini.nvim collection: mini.surround (add/change/
│           │                      delete surrounding brackets/quotes), mini.ai
│           │                      (enhanced text objects), mini.pairs (auto-close).
│           │
│           ├── multicursor.lua ← Multi-cursor editing (like VSCode's Ctrl+D).
│           │
│           ├── flash.lua       ← Jump anywhere with 2-3 keys (s = flash search).
│           │
│           └── ... (more plugins, each documented in its respective file)
│
└── after/
    └── ftplugin/               ← Per-filetype settings. These files run AFTER all
        │                          plugins load, so they can safely override plugin
        │                          defaults. Named by filetype (go.lua for Go files).
        ├── go.lua              ← Go: tabstop=4, goimports on save, gopls settings
        ├── rust.lua            ← Rust: clippy linter, rust-analyzer formatting
        ├── python.lua          ← Python: 4-space indent, ruff formatter, pylint
        ├── markdown.lua        ← Markdown: wrap=true, spell=true, conceal=2,
        │                          render-markdown.nvim activated
        ├── yaml.lua            ← YAML: 2-space indent enforced
        ├── sql.lua             ← SQL: dadbod completion, sqlfluff formatter
        ├── c.lua               ← C: clang-format, clangd, tabstop=4
        ├── cpp.lua             ← C++: inherits C settings
        ├── sh.lua              ← Shell: shellcheck linter, shfmt formatter
        └── jsonc.lua           ← JSONC (JSON with comments): treated like JSON
```

### The Boot Sequence

When you run `nvim`, this is exactly what happens in order, with timing notes:

```
                     ┌─────────┐
                     │  nvim   │   (you press Enter)
                     └────┬────┘
                          │  ~0ms
                          ▼
              ┌───────────────────────┐
              │       init.lua        │  Three require() calls
              └─────┬────────┬────────┘
                    │        │        │
             ~1ms   │   ~2ms │   ~5ms │
                    ▼        ▼        ▼
          ┌──────────┐ ┌──────────┐ ┌────────────────┐
          │ de100    │ │ de100    │ │ current-theme  │
          │ .core    │ │ .lazy    │ │ .lua           │
          └────┬─────┘ └────┬─────┘ └───────┬────────┘
               │             │               │
        ┌──────┤      ┌──────┤         activates
        │      │      │      │         colorscheme
        ▼      ▼      ▼      ▼
  options  keymaps  bootstrap  setup()
  .lua     .lua     lazy.nvim  plugins

                          │
              lazy.nvim resolves dependency graph
              Eager plugins load now (~10-30ms total)
              Lazy plugins register event triggers
                          │
                     ┌────┴────┐
                     │  nvim   │  Ready to use (~30–80ms startup
                     │  READY  │  depending on eager plugin count)
                     └─────────┘

  Later (event-triggered lazy loading):
  ─────────────────────────────────────
  BufReadPre fired  →  lspconfig, treesitter, conform, nvim-lint load
  BufEnter fired    →  blink-cmp, gitsigns, auto-save load
  VeryLazy fired    →  which-key, noice, lualine load
  :Telescope called →  telescope loads on first use
  :Neogit called    →  neogit loads on first use
```

> **💡 In VSCode you'd...** wait 2-5 seconds for VSCode to start and load all
> extensions eagerly. **In Neovim...** startup is ~30-80ms because plugins load
> lazily — only when needed. Run `:Lazy profile` to see the exact timing
> breakdown for your setup.

### Purpose of Each Subdirectory

| Directory                | What lives there                          | When to edit it                            |
| ------------------------ | ----------------------------------------- | ------------------------------------------ |
| `lua/de100/core/`        | Editor fundamentals (options, keymaps)    | Tab size, line numbers, base keybindings   |
| `lua/de100/plugins/`     | One Lua file per plugin                   | Adding, removing, or configuring plugins   |
| `lua/de100/plugins/lsp/` | LSP-related plugins (mason, lspconfig)    | New language servers, LSP behavior         |
| `after/ftplugin/`        | Per-filetype overrides, run after plugins | Language-specific settings for a filetype  |
| `snippets/`              | LuaSnip snippets organized by filetype    | Custom code snippets (e.g., snippets/lua/) |

The separation between `core/` and `plugins/` is intentional: `core/` is what
makes Neovim _yours_ (your preferences, your keybindings), while `plugins/` is
the functionality layer. If you ever wanted to try a totally different plugin
set, you'd keep `core/` and swap out `plugins/`.

---

## 3. Installation

### Prerequisites

Check each of these before running the playbook:

| Prerequisite            | How to check                                                     | How to install (Debian/Ubuntu)                        |
| ----------------------- | ---------------------------------------------------------------- | ----------------------------------------------------- |
| **git 2.x**             | `git --version`                                                  | Pre-installed on most systems; `sudo apt install git` |
| **Ansible**             | `ansible --version`                                              | `sudo apt install ansible` or `pip3 install ansible`  |
| **Python 3.8+**         | `python3 --version`                                              | Usually pre-installed; `sudo apt install python3`     |
| **sudo / admin access** | `sudo whoami` → should print `root`                              | Talk to your sysadmin                                 |
| **~3 GB free disk**     | `df -h ~`                                                        | Neovim build + all tools + plugins                    |
| **Internet access**     | `curl -s https://github.com`                                     | Downloads packages, plugins, LSP servers              |
| **Nerd Font**           | Does your terminal show `` properly?                             | [nerdfonts.com](https://nerdfonts.com)                |
| **True-color terminal** | Run `echo $TERM` — should be `xterm-256color` or `tmux-256color` | Alacritty, Kitty, WezTerm all work well               |

> **On Nerd Fonts:** Neovim plugins use icons from Nerd Fonts heavily —
> file type icons, git status icons, LSP diagnostic icons, the statusline.
> Without a Nerd Font, you'll see boxes or question marks everywhere instead
> of icons. Install a font (JetBrains Mono Nerd Font is a popular choice),
> set it in your terminal emulator's font settings, and restart the terminal.

### Running the Ansible Playbook

```bash
# Navigate to the repo root
cd ~/mfansible    # adjust to wherever you cloned the repo

# Run with sudo password prompt (-K means "ask BECOME password"):
ansible-playbook neovim.yml -K

# You'll be prompted:
#   BECOME password: ___
# Enter your sudo password. This is needed to install system packages.
```

The playbook supports several variables you can override:

```bash
# Install nightly Neovim instead of latest stable:
ansible-playbook neovim.yml -K -e neovim_channel=nightly

# Pin a specific Neovim version (check github.com/neovim/neovim/releases):
ansible-playbook neovim.yml -K -e neovim_version=v0.10.4

# Also install Java (needed for jdtls — the Java LSP server):
ansible-playbook neovim.yml -K -e install_java=true

# Also install .NET SDK (needed for omnisharp — C# LSP server):
ansible-playbook neovim.yml -K -e install_dotnet=true

# Nightly + Java (combine any extras with spaces):
ansible-playbook neovim.yml -K -e neovim_channel=nightly -e install_java=true
```

Expect the first run to take **5–20 minutes** depending on your internet speed
and how fast your machine compiles (Neovim is built from source).

If the playbook fails partway through, you can usually run it again and it will
pick up where it left off — most tasks are idempotent (safe to run multiple
times).

### What the Playbook Installs

The playbook installs four categories of things:

**Category 1: Build tools and system utilities**

| Package                                   | Why                                                                   |
| ----------------------------------------- | --------------------------------------------------------------------- |
| `ninja-build`, `cmake`, `build-essential` | Compile Neovim from source                                            |
| `git`                                     | Version control (also used by lazy.nvim to install plugins)           |
| `curl`, `wget`, `tar`, `unzip`            | Download and extract tools                                            |
| `ripgrep`                                 | Extremely fast grep — the engine behind Telescope's live search       |
| `fd-find`                                 | Fast `find` replacement — used by Telescope for file finding          |
| `fzf`                                     | Fuzzy finder — backend for several fuzzy-selection features           |
| `jq`                                      | JSON processor — useful for scripting, used by some plugins           |
| `xclip`, `wl-clipboard`                   | Clipboard bridge between Neovim and the X11/Wayland clipboard         |
| `tmux`                                    | Terminal multiplexer — the recommended way to run persistent sessions |
| `imagemagick`, `graphviz`                 | Image processing and diagram rendering                                |
| `codespell`                               | Spell checker for code comments                                       |

**Category 2: Language runtimes**

| Package                                         | Why                                                            |
| ----------------------------------------------- | -------------------------------------------------------------- |
| `python3`, `python3-pip`, `python3-pynvim`      | Python runtime + Neovim Python provider                        |
| `python3-venv`                                  | Virtual environments for Python tooling                        |
| `nodejs`, `npm`                                 | JavaScript/TypeScript runtime — many LSP servers are Node apps |
| `golang-go`                                     | Go runtime — gopls (Go LSP) and goimports run as Go binaries   |
| `cargo`, `rustc`                                | Rust toolchain — some tools compile from source via cargo      |
| `lua5.1`, `luarocks`, `liblua5.1-0-dev`         | Lua runtime — used by some plugins at runtime                  |
| `clang`, `clangd`, `clang-format`, `clang-tidy` | C/C++ compiler + LSP server + formatter + linter               |
| `shellcheck`, `shfmt`                           | Shell script linter and formatter                              |

**Category 3: Optional packages (installed with `failed_when: false`)**

These are attempted but don't fail the playbook if they're unavailable:

| Package                | Why                                                               |
| ---------------------- | ----------------------------------------------------------------- |
| `lazygit`              | TUI git client (alternative to Neogit for some operations)        |
| `tree-sitter-cli`      | Treesitter parser compiler (for custom grammars)                  |
| `fzf`                  | Fuzzy finder                                                      |
| `wordnet`              | English dictionary (used by blink-cmp-dictionary for definitions) |
| `latexmk`, `texlive-*` | LaTeX compilation (for LaTeX editing support)                     |

**Category 4: npm-based editor tools (installed globally)**

```bash
npm install -g \
  tree-sitter-cli         # Treesitter parsers
  @mermaid-js/mermaid-cli # Mermaid diagram rendering
  prettier                # Universal code formatter
  typescript              # TypeScript compiler
  typescript-language-server  # TS/JS LSP server
  vscode-langservers-extracted # HTML/CSS/JSON/ESLint LSP servers
  neovim                  # Neovim Node.js provider
```

**Category 5: Python tools (via pip)**

```bash
pip3 install --user \
  pynvim      # Neovim Python provider
  debugpy     # Python debugger (used by nvim-dap)
  ruff        # Ultra-fast Python linter + formatter
  black       # Python formatter (alternative to ruff format)
  isort       # Python import sorter
  pylint      # Python linter
```

**Category 6: Go tools**

```bash
go install golang.org/x/tools/cmd/goimports@latest
# goimports: organizes Go imports + basic formatting
```

**Zig (via snap):**

```bash
snap install zig --classic --channel=edge
# Used by blink.cmp which builds a native Rust module via zig as the linker
```

> **💡 In VSCode you'd...** open the Extensions panel and click Install on
> "Python" or "Go". The extension bundles the LSP server internally.
> **In Neovim...** the Ansible playbook installs the _actual tools_
> (`ruff`, `goimports`, `clangd`) at the system or user level. The LSP
> plugins then call these tools directly. The benefit: you can also use these
> tools from your terminal, CI scripts, or other editors.

### Mason: The Second Layer of Tool Installation

The playbook installs system-level tools. Mason (which runs inside Neovim)
installs the LSP servers, debug adapters, formatters, and linters that
_mason-tool-installer.nvim_ configures as `ensure_installed`.

The current `ensure_installed` list in `mason.lua` includes:

**LSP servers (via mason-lspconfig):**

| Server                                        | Language                                  |
| --------------------------------------------- | ----------------------------------------- |
| `lua_ls`                                      | Lua                                       |
| `pyright`, `ruff`                             | Python                                    |
| `vtsls`                                       | TypeScript / JavaScript                   |
| `gopls`                                       | Go                                        |
| `clangd`                                      | C / C++                                   |
| `rust_analyzer`                               | Rust (often installed via rustup instead) |
| `html`, `cssls`, `jsonls`                     | HTML / CSS / JSON                         |
| `eslint`                                      | JavaScript/TypeScript linting via LSP     |
| `tailwindcss`                                 | Tailwind CSS class completions            |
| `bashls`                                      | Bash / Shell                              |
| `yamlls`                                      | YAML                                      |
| `dockerls`, `docker_compose_language_service` | Docker                                    |
| `ansiblels`                                   | Ansible                                   |
| `terraformls`                                 | Terraform                                 |
| `marksman`                                    | Markdown                                  |
| `sqlls`                                       | SQL                                       |
| `astro`, `svelte`, `vue_ls`                   | Astro / Svelte / Vue                      |
| `graphql`                                     | GraphQL                                   |
| `prismals`                                    | Prisma ORM                                |
| `taplo`                                       | TOML                                      |
| `texlab`                                      | LaTeX                                     |
| `omnisharp`                                   | C#                                        |
| `jdtls`                                       | Java (needs `-e install_java=true`)       |

**Formatters and linters (via mason-tool-installer):**

| Tool                     | Purpose                                |
| ------------------------ | -------------------------------------- |
| `stylua`                 | Lua formatter                          |
| `prettier`, `prettierd`  | JS/TS/CSS/HTML/JSON/Markdown formatter |
| `biome`                  | Fast JS/TS formatter + linter          |
| `black`, `isort`, `ruff` | Python formatters                      |
| `gofumpt`, `goimports`   | Go formatters                          |
| `google-java-format`     | Java formatter                         |
| `clang-format`           | C/C++ formatter                        |
| `shfmt`                  | Shell formatter                        |
| `yamlfmt`, `yamllint`    | YAML formatter + linter                |
| `markdownlint`           | Markdown linter                        |
| `shellcheck`             | Shell linter                           |
| `pylint`                 | Python linter                          |
| `golangci-lint`          | Go linter                              |
| `luacheck`               | Lua linter                             |
| `cpplint`                | C++ linter                             |
| `checkmake`              | Makefile linter                        |
| `ansible-lint`           | Ansible linter                         |
| `codespell`              | Spell checker                          |

**Debug adapters:**

| Tool                        | Purpose                        |
| --------------------------- | ------------------------------ |
| `debugpy`                   | Python debugger                |
| `delve`                     | Go debugger                    |
| `codelldb`                  | C/C++/Rust debugger            |
| `js-debug-adapter`          | JavaScript/TypeScript debugger |
| `java-debug-adapter`        | Java debugger                  |
| `netcoredbg`                | .NET/C# debugger               |
| `local-lua-debugger-vscode` | Lua debugger                   |

### XDG Paths: The Snap/VSCode Isolation Caveat

This is a subtle footgun that burns people who install VSCode as a snap package
on Ubuntu and then try to run Neovim from VSCode's integrated terminal.

**The problem:** Ubuntu snap packages run in a sandboxed environment. When
VSCode is a snap, its integrated terminal inherits that sandboxed environment.
Inside that sandbox, `$XDG_CONFIG_HOME` and `$HOME` may point to snap-managed
paths instead of your real home directory.

```bash
# In a normal terminal:
echo $XDG_CONFIG_HOME   # → /home/username/.config (or empty, defaults to ~/.config)
nvim --headless -c 'lua print(vim.fn.stdpath("config"))' -c q
# → /home/username/.config/nvim   ✓ Correct

# In VSCode's terminal (if VSCode is installed as snap):
nvim --headless -c 'lua print(vim.fn.stdpath("config"))' -c q
# → /home/username/snap/code/current/.config/nvim   ✗ Wrong sandbox path!
# Your config is at ~/.config/nvim but Neovim is looking in the snap sandbox!
```

**The symptoms:** Neovim opens but shows a blank editor with no plugins, no
colorscheme, no statusline. It looks like a fresh Neovim install because it IS
loading fresh — from an empty snap-sandboxed config directory.

**The fix:**

1. Use a real terminal (Alacritty, Kitty, GNOME Terminal, WezTerm, tmux)
   instead of VSCode's integrated terminal. This is the right long-term choice.
2. OR, if you must use VSCode's terminal, manually set `NVIM_APPNAME` or
   `XDG_CONFIG_HOME` in your shell rc file:
   ```bash
   # in ~/.bashrc or ~/.zshrc:
   export XDG_CONFIG_HOME="$HOME/.config"
   export XDG_DATA_HOME="$HOME/.local/share"
   export XDG_STATE_HOME="$HOME/.local/state"
   ```

**How to diagnose this right now:** Open Neovim and run:

```vim
:lua print(vim.fn.stdpath("config"))
:lua print(vim.fn.stdpath("data"))
```

`config` should be `~/.config/nvim`. `data` should be `~/.local/share/nvim`.
If either shows a path containing `snap/`, you're in the snap sandbox.

### Manual Install (If Ansible Fails)

If the playbook errors out or you can't run Ansible:

```bash
# Step 1: Install build prerequisites
sudo apt update && sudo apt install -y \
  git cmake ninja-build build-essential gettext unzip curl wget \
  ripgrep fd-find xclip wl-clipboard tmux \
  python3 python3-pip python3-pynvim nodejs npm

# Step 2: Build and install Neovim from source
git clone --depth 1 --branch stable \
  https://github.com/neovim/neovim.git ~/neovim-src

cd ~/neovim-src
make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr/local
sudo make install

# Verify:
nvim --version
# Should show NVIM v0.10+ and list build features

# Step 3: Install npm-based tools
sudo npm install -g \
  typescript typescript-language-server \
  vscode-langservers-extracted prettier neovim

# Step 4: Install Python tools
pip3 install --user pynvim debugpy ruff black isort pylint

# Step 5: Link (or copy) the config
# If the repo is at ~/mfansible:
mkdir -p ~/.config
ln -sf ~/mfansible/dotfiles/.config/nvim ~/.config/nvim

# Or copy it:
cp -r ~/mfansible/dotfiles/.config/nvim ~/.config/nvim

# Step 6: First launch — install plugins
nvim
# Inside Neovim, run: :Lazy sync
# Wait for all plugins to install.
# Then restart: :qa, then nvim again.

# Step 7: Install LSP servers and tools via Mason
# Inside Neovim: :Mason
# Or let mason-tool-installer auto-install on first launch.
```

---

## 4. First Launch

### Opening Neovim

There are three ways to start Neovim, each giving a different starting state:

```bash
# Most common — open in a directory. Shows oil.nvim file browser:
nvim .

# Open a specific file directly:
nvim path/to/file.lua
nvim ~/.config/nvim/lua/de100/core/keymaps.lua

# Open with no file — shows the dashboard (from snacks.nvim):
nvim
# You'll see a centered dashboard with recent files and project shortcuts.
```

For everyday use, `nvim .` in your project root is the most practical. You'll
see a listing of the directory, navigate with `j`/`k`, press `Enter` to enter
subdirectories or open files, press `-` to go up.

### What You See Immediately After Opening

Let's annotate the screen you'll see when opening a Lua file:

```
 1  ← │ -- This is keymaps.lua                               ←── Sign column
 2    │ vim.g.mapleader = ' '                                       (gutter)
 3    │                                                              Shows:
 4  + │ -- For conciseness                                           + = new git line
 5    │ local keymap = vim.keymap                                    ~ = changed line
 6    │                                                              E = LSP error
 7    │ local opts = {noremap = true, silent = true}                 W = warning
 8    │                                                              B = breakpoint
 9    │ local function tbl_merge(t1, t2)
10    │   return vim.tbl_extend('force', t1, t2)              ←── 80-char color column
11    │ end                                                     (thin vertical line)
12 ~  │
13 ~  │                              ←── Relative line numbers
      │                                  Current line = absolute
      │                                  Other lines = distance from cursor

──────────────────────────────────────────────────────────────────────────────
 NORMAL  keymaps.lua  [Git: main +2~1]  E:0 W:0    lua  UTF-8  10:5
 ─────   ───────────   ──────────────    ──────     ───  ─────  ────
 Mode    File name     Git branch+diff  Diagnostics  FT  Enc    Line:Col
```

The status line (lualine) at the bottom tells you everything important at a
glance:

- **NORMAL** — current mode. Changes to INSERT when editing, VISUAL when
  selecting, etc.
- **keymaps.lua** — current file (with `[+]` if unsaved)
- **[Git: main +2~1]** — git branch, number of added and modified hunks
- **E:0 W:0** — LSP diagnostics: 0 errors, 0 warnings in this file
- **lua** — filetype (determines which LSP server, formatter, and snippets)
- **10:5** — cursor position: line 10, column 5

> **💡 In VSCode you'd...** see this information split across the bottom
> status bar and the Problems panel. **In Neovim...** everything is in the
> one statusline and it updates in real time with no extra panel open.

### :Lazy sync — Why You Run This First

The config files in this repo are _specifications_ — they describe what plugins
to install, but they don't include the actual plugin code. Plugin code lives
in `~/.local/share/nvim/lazy/` and is downloaded by lazy.nvim.

On a fresh clone, that directory is empty (or missing). lazy.nvim will try to
bootstrap itself on first run, but you should manually trigger a full sync:

```vim
:Lazy sync
```

The `sync` command does three things in order:

1. **Installs** any plugins that are in the spec but not yet downloaded
2. **Updates** any plugins that have newer versions available
3. **Cleans** any plugins that were downloaded but are no longer in the spec

You'll see a progress UI with one row per plugin:

```
lazy.nvim ──────────────────────────────────────────────────────────
  ✓  plenary.nvim            Installed
  ✓  telescope.nvim          Installed
  ➜  blink.cmp               Downloading... (12/450 objects)
  ➜  treesitter              Downloading...
  ✓  which-key.nvim          Already up to date
  ✓  tokyonight.nvim         Already up to date
```

Wait for all the spinners (➜) to become checkmarks (✓). This can take 2-5
minutes on first run as it downloads ~60-80 plugins.

**After sync completes, restart Neovim.** This is important. Many plugins
register autocommands and keybindings only when they load. On first install,
some plugins need a clean start to initialize their native components (blink.cmp
builds a Rust binary, treesitter compiles parsers, etc).

```vim
:qa    " quit all windows
nvim . " reopen
```

### :Lazy sync vs :Lazy update vs :Lazy install

There are three sync-related commands, and they're not the same:

| Command         | What it does                               | When to use                                                   |
| --------------- | ------------------------------------------ | ------------------------------------------------------------- |
| `:Lazy sync`    | Install + update + clean                   | First launch, or when you've changed the plugin spec          |
| `:Lazy update`  | Update only (don't clean)                  | Regular updates to get bug fixes                              |
| `:Lazy install` | Install missing only (no updates)          | When you've added a new plugin and don't want others updated  |
| `:Lazy restore` | Pin all plugins to lazy-lock.json versions | After git pull, to reproduce exact teammate's plugin versions |
| `:Lazy clean`   | Remove plugins not in spec                 | After removing a plugin from the config                       |

The UI keyboard shortcuts inside `:Lazy`:

```
In the :Lazy UI:
  S     → Sync (recommended: does install + update + clean)
  U     → Update all plugins
  I     → Install missing plugins only
  C     → Clean unused plugins
  L     → Show log for the selected plugin
  Enter → Expand/collapse plugin details
  ?     → Show all keyboard shortcuts
  q     → Close the Lazy UI
```

### :checkhealth — Reading the Output

After your first `:Lazy sync` and restart, run:

```vim
:checkhealth
```

This opens a report in a new buffer. It looks like this:

```
==============================================================================
nvim: require("nvim.health").check()

  - OK: Neovim is up to date
  - OK: NVIM_APPNAME not set
  - OK: $TERM is 'xterm-256color'
  - WARNING: terminal does not support 256 colors
              ADVICE:
              Set $TERM to xterm-256color or tmux-256color

==============================================================================
provider: python3
  - OK: Latest pynvim package is installed
  - OK: python3.12 executable found

==============================================================================
telescope: require("telescope.health").check()
  - OK: nvim-treesitter found
  - OK: ripgrep 14.1.0 found
  - OK: fd found
  - WARNING: fd executable not in $PATH
              ADVICE: Install fd: https://github.com/sharkdp/fd
```

**How to read the severity levels:**

| Symbol    | Meaning                            | Action                                 |
| --------- | ---------------------------------- | -------------------------------------- |
| `OK`      | Working correctly                  | Nothing to do                          |
| `WARNING` | Suboptimal but functional          | Read the ADVICE; fix if it affects you |
| `ERROR`   | Broken — will affect functionality | Fix this before continuing             |

**Expected warnings on a fresh install (safe to ignore):**

| Warning                                        | Why it appears              | OK to ignore?                         |
| ---------------------------------------------- | --------------------------- | ------------------------------------- |
| `No Ruby neovim gem found`                     | Ruby provider not installed | Yes — Ruby plugins are rare           |
| `No PHP client found`                          | PHP provider not installed  | Yes — PHP plugins are rare            |
| `No Perl provider found`                       | Perl provider not installed | Yes — Perl plugins don't exist really |
| `python2 not found`                            | Python 2 is end-of-life     | Yes — nothing uses Python 2           |
| `node.js >= 12 required` (if on very old Node) | Check `node --version`      | Maybe — upgrade Node if needed        |

**Errors that need fixing:**

| Error                       | Likely cause                  | Fix                                                                 |
| --------------------------- | ----------------------------- | ------------------------------------------------------------------- |
| `pynvim module not found`   | Python provider not installed | `pip3 install --user pynvim`                                        |
| `node executable not found` | Node not in PATH              | Check `which node`; run the playbook                                |
| `ripgrep not found`         | `rg` not in PATH              | `sudo apt install ripgrep`                                          |
| `fd not found`              | `fd` not in PATH              | `sudo apt install fd-find && ln -s /usr/bin/fdfind ~/.local/bin/fd` |
| `lazy.nvim not loaded`      | Bootstrap failed              | Delete `~/.local/share/nvim/lazy/lazy.nvim` and restart             |

**Checking a specific component:**

```vim
:checkhealth nvim           " Core Neovim (providers, terminal)
:checkhealth telescope.nvim " Telescope (ripgrep, fd, treesitter)
:checkhealth mason          " Mason (node, git, curl)
:checkhealth treesitter     " Treesitter (compiled parsers)
:checkhealth lsp            " LSP client
```

Navigate the checkhealth buffer like any file: `j`/`k` to move, `/` to search,
`q` to close.

### Expected Experience After a Healthy First Launch

Here's what a working install looks like checklist-style:

```
[ ] lualine status bar is visible at the bottom with mode, file, git branch
[ ] When you open a .lua file, syntax highlighting has colors (not monochrome)
[ ] When you type in insert mode, a completion popup appears automatically
[ ] When you press Space and wait 300ms, a which-key popup appears
[ ] When you open a .ts file, :LspInfo shows typescript-language-server attached
[ ] Pressing gd on a function name opens its definition
[ ] :Lazy shows all plugins with checkmarks (no X marks)
[ ] :checkhealth nvim shows no ERRORs
```

If any of these aren't true, `:checkhealth <plugin>` and `:Lazy` are your
debugging starting points.

---

## 5. Config Key Concepts

### lazy.nvim — The Plugin Manager

lazy.nvim is the foundation that loads and manages all other plugins. It's
named "lazy" because it loads plugins _lazily_ — only when actually needed.

**Why lazy loading matters:** Imagine you have 60 plugins. If all 60 loaded at
startup, Neovim would take 2+ seconds to start. With lazy loading:

- 10 core plugins load at startup (~30ms total)
- 50 plugins load only when triggered (first relevant keypress, filetype, event)
- Neovim starts in ~50ms

**The plugin spec format.** Every file under `lua/de100/plugins/` returns a
table (or list of tables) describing one or more plugins:

```lua
-- Minimal plugin spec:
return {
  "author/plugin-name",         -- GitHub repo (author/repo)
}

-- With options:
return {
  "author/plugin-name",
  event = "BufReadPre",         -- when to load (lazy trigger)
  dependencies = {              -- other plugins to load first
    "nvim-lua/plenary.nvim",
  },
  opts = {                      -- passed to plugin's setup()
    option_one = true,
    option_two = "value",
  },
}

-- With custom config function:
return {
  "author/plugin-name",
  config = function()
    require("plugin-name").setup({
      -- more complex setup logic here
    })
    vim.keymap.set("n", "<leader>x", require("plugin-name").do_thing)
  end,
}
```

**Lazy loading triggers.** You control when a plugin loads:

| Trigger                       | Example                    | Meaning                                  |
| ----------------------------- | -------------------------- | ---------------------------------------- |
| `event = "BufReadPre"`        | treesitter, lspconfig      | Load before reading a buffer             |
| `event = "VeryLazy"`          | which-key, lualine         | Load after UI is stable (end of startup) |
| `cmd = "Telescope"`           | telescope                  | Load when `:Telescope` command is run    |
| `ft = "python"`               | python-specific plugins    | Load only for Python files               |
| `keys = {{"n", "<leader>x"}}` | plugin with one entrypoint | Load when keymap is pressed              |
| `lazy = false`                | mason, treesitter          | Load eagerly (no lazy loading)           |

**Commands you'll use frequently:**

```vim
:Lazy          " Open the plugin manager UI
:Lazy sync     " Install missing + update + clean (use this most often)
:Lazy update   " Update plugins (no clean)
:Lazy install  " Install missing only
:Lazy restore  " Roll back to lazy-lock.json versions
:Lazy log      " See recent update changes
:Lazy profile  " Show startup time per plugin
:Lazy health   " Run health checks for lazy itself
```

> **💡 In VSCode you'd...** open the Extensions panel (Ctrl+Shift+X), search,
> click Install, wait for the reload notification. Updates happen automatically
> in the background. **In Neovim...** you create a Lua file, run `:Lazy sync`,
> done. It's more manual but everything is code in your git repo.

### mason.nvim — The LSP/Tool Installer

Mason is a package manager specifically for editor tooling: LSP servers,
formatters, linters, and debug adapters. Think of it as the package manager
_inside_ Neovim, complementary to your system's apt/brew/cargo.

Mason installs tools into `~/.local/share/nvim/mason/`, isolated from your
system tools. This is intentional — you can have a different version of prettier
for Neovim than for your shell, and upgrades happen independently.

**Three Mason-related plugins work together in this config:**

```
mason.nvim               ← Core: the UI and installer infrastructure
mason-lspconfig.nvim     ← Bridge: maps LSP server names to mason package names
                            Auto-installs servers listed in ensure_installed
mason-tool-installer.nvim ← Extended: installs formatters, linters, debug adapters
```

**Using the Mason UI:**

```vim
:Mason          " Open the Mason package manager UI

Inside the UI:
  1             → Filter to show LSP servers
  2             → Filter to show DAP (debug) adapters
  3             → Filter to show Linters
  4             → Filter to show Formatters
  i             → Install the selected package
  X             → Uninstall the selected package
  u             → Update the selected package
  U             → Update ALL installed packages
  /             → Filter/search packages by name
  ?             → Show all keyboard shortcuts
  q             → Close Mason
```

**Icons in Mason UI:**

| Icon | Meaning                  |
| ---- | ------------------------ |
| `✓`  | Installed and up to date |
| `➜`  | Install in progress      |
| `✗`  | Not installed            |
| `⬆`  | Update available         |

**Installing a tool manually:**

```vim
:MasonInstall lua-language-server    " Install a single tool
:MasonInstall prettier stylua ruff   " Install multiple tools at once
:MasonUninstall some-tool            " Remove a tool
:MasonUpdate                         " Update all installed tools
:MasonLog                            " Show Mason's log (debug installs)
```

**Adding a new language server** to the auto-install list means editing
`lua/de100/plugins/lsp/mason.lua` and adding the server name to
`ensure_installed` in the `mason-lspconfig` config. On next `:Lazy sync`,
Mason will install it.

> **💡 In VSCode you'd...** install the "Pylance" extension and it comes with
> pyright bundled. **In Neovim...** Mason installs `pyright` (or `ruff`) as a
> standalone tool that `nvim-lspconfig` then connects to. Same effect, more
> transparent.

### which-key.nvim — Your Discoverable Keymap

which-key solves the biggest complaint new Neovim users have: "I can't
remember any of the keybindings."

When you press a prefix key and pause, which-key shows a popup with every
valid continuation key and its description. It's like auto-complete for your
keyboard shortcuts.

```
You press Space, wait 300ms:
┌─────────────────────────────────────────────────────────────────────────┐
│  b  buffers          g  git              s  splits/session               │
│  c  code             h  harpoon          t  tabs/tests/tasks             │
│  d  diagnostics/dbg  H  http/rest        u  ui/toggles                  │
│  e  explorer         k  keys/show        v  view/help                    │
│  f  file             l  lsp/lint         w  workspace/session            │
│                      m  make/format      x  trouble/lists                │
│                      n  noice            y  yank                         │
│                      p  pick/search      r  rename/refactor              │
└─────────────────────────────────────────────────────────────────────────┘

You press g (for git), wait 300ms:
┌─────────────────────────────────────────────────────────────────────────┐
│  b   blame current line    n   next hunk           R   reset buffer     │
│  B   blame buffer          N   prev hunk           s   stage hunk       │
│  d   diff current file     p   preview hunk        S   stage buffer     │
│  D   diff cached           r   reset hunk          u   unstage hunk     │
│  g   open Neogit           o   open in browser     L   list commits     │
└─────────────────────────────────────────────────────────────────────────┘
```

The group names in this config (defined in `lua/de100/plugins/which-key.lua`):

| Prefix      | Group name        |
| ----------- | ----------------- |
| `<leader>b` | buffers           |
| `<leader>c` | code              |
| `<leader>d` | diagnostics/debug |
| `<leader>e` | explorer          |
| `<leader>f` | file              |
| `<leader>g` | git               |
| `<leader>h` | harpoon           |
| `<leader>H` | http/rest         |
| `<leader>k` | keys/show         |
| `<leader>l` | lsp/lint          |
| `<leader>m` | make/format       |
| `<leader>p` | pick/search       |
| `<leader>r` | rename/refactor   |
| `<leader>s` | splits/session    |
| `<leader>t` | tabs/tests/tasks  |
| `<leader>u` | ui/toggles        |
| `<leader>v` | view/help         |
| `<leader>w` | workspace/session |
| `<leader>x` | trouble/lists     |
| `<leader>y` | yank              |

**The delay:** 300ms (set in `which-key.lua`). If you type `<leader>pf` quickly
(under 300ms between keys), which-key never appears and the command fires
immediately. If you pause, the popup shows. You have until `timeoutlen` (300ms,
set in `options.lua`) before Neovim gives up on an incomplete key sequence.

**Tip:** which-key also works for built-in prefixes. Press `g` in normal mode
and wait — you'll see all the `g`-prefixed commands. Press `z` and wait — all
fold/zoom commands. It works for any multi-key sequence.

### The Leader Key and Keybinding Notation

The **leader key** is `Space`. This is set in `keymaps.lua`:

```lua
vim.g.mapleader = ' '       -- Space is the leader
vim.g.maplocalleader = ' '  -- Space is also the local leader
```

The first line in `keymaps.lua` after setting the leader:

```lua
keymap.set({'n', 'v'}, '<Space>', '<Nop>', {silent = true})
```

This disables Space's default behavior (move cursor forward one space) so it
can be used purely as a prefix key. Without this, pressing Space in Normal mode
would just move the cursor.

**How to read keybinding notation throughout this series:**

| Notation     | Meaning                     | Example action                   |
| ------------ | --------------------------- | -------------------------------- |
| `<leader>pf` | Space, p, f                 | Open file finder                 |
| `<C-s>`      | Ctrl+s (hold Ctrl, press s) | Save file                        |
| `<S-Tab>`    | Shift+Tab                   | Previous buffer                  |
| `<A-j>`      | Alt+j                       | Move line down (in some plugins) |
| `<M-j>`      | Alt+j (same as `<A-j>`)     | Same                             |
| `<CR>`       | Enter/Return                | Confirm selection                |
| `<Esc>`      | Escape                      | Return to Normal mode            |
| `<BS>`       | Backspace                   | Delete character behind cursor   |
| `[d`         | `[` then `d` (no modifier)  | Previous diagnostic              |
| `]d`         | `]` then `d` (no modifier)  | Next diagnostic                  |
| `gd`         | `g` then `d` (motion)       | Go to definition                 |
| `K`          | Capital K                   | Show hover documentation         |

**Mode abbreviations** you'll see in plugin documentation:

| Code    | Mode                                              |
| ------- | ------------------------------------------------- |
| `n`     | Normal mode                                       |
| `i`     | Insert mode                                       |
| `v`     | Visual mode (character-wise)                      |
| `V`     | Visual Line mode                                  |
| `<C-v>` | Visual Block mode                                 |
| `c`     | Command-line mode (after `:`)                     |
| `t`     | Terminal mode                                     |
| `o`     | Operator-pending mode (after `d`, `c`, `y`, etc.) |
| `x`     | Visual mode (character only, excludes Select)     |

When you see "n: `<leader>pf`" it means the keybinding works only in Normal
mode. When you see `{"n", "v"}` in Lua, it means Normal and Visual modes.

---

## 6. The Reference Files You'll Use Most

### :help — Neovim's Built-in Documentation (Better Than You Think)

The `:help` system is a full-text documentation database built into every
Neovim installation. It covers:

- All built-in commands and options
- The Lua API (`vim.api`, `vim.fn`, `vim.lsp`, etc.)
- Every plugin that ships with Neovim
- Navigation concepts (motions, text objects, operators)

```vim
" Open the help index:
:help

" Search for a specific topic:
:help motion              " movement commands
:help text-objects        " text objects (iw, it, i(, etc.)
:help operator            " operators (d, c, y, >, <, etc.)
:help insert              " insert mode commands
:help :substitute         " the :s command (search and replace)
:help registers           " named registers (clipboard)
:help marks               " file marks (bookmarks)
:help folds               " code folding
:help autocmd             " autocommands
:help vim.lsp             " LSP API
:help vim.api             " Neovim Lua API
:help vim.fn              " Vimscript function bindings
:help vim.keymap          " keymap API
:help lua-guide           " Complete Lua guide for Neovim
```

**Navigation inside :help:**

| Key       | Action                                                        |
| --------- | ------------------------------------------------------------- |
| `Ctrl+]`  | Follow the link under the cursor (underlined words are links) |
| `Ctrl+o`  | Go back                                                       |
| `Ctrl+t`  | Go back (alternative)                                         |
| `/`       | Search within help                                            |
| `n` / `N` | Next / previous search result                                 |
| `q`       | Close the help window                                         |

**The most useful shortcut:** Put your cursor on any Lua function or Neovim
API call in your config file and press `K`. If `lazydev.nvim` is configured
(it is, in `plugins/init.lua`), this opens the help for that specific function.

For example, with cursor on `vim.tbl_extend` — press `K` — opens help for
`vim.tbl_extend()`. Cursor on `vim.keymap.set` — press `K` — opens
`vim.keymap.set()` docs. This is how you learn the API without leaving Neovim.

> **💡 In VSCode you'd...** hover over a function to get IntelliSense, or press
> F12 for definition. **In Neovim...** `K` opens the _documentation_, not the
> definition. For definition, use `gd`. For docs, use `K`. Both work without
> internet.

### hawtkeys.nvim — Find Duplicate / Conflicting Keybindings

When you're adding custom keybindings to your config, it's easy to accidentally
map a key that's already used by another plugin. hawtkeys.nvim analyzes all
registered keybindings and shows you:

- **Duplicates:** keys mapped to more than one action (conflicts!)
- **Available keys:** easy-to-type keys that aren't mapped yet
- **Key frequency stats:** which keys you're pressing most

```vim
:Hawtkeys           " Open the full analysis UI
:HawtkeysAll        " Show all mapped keys
:HawtkeysFind       " Search for a specific binding
```

Inside the Hawtkeys UI, you can see exactly which file and line each binding
was registered from — so when there's a conflict, you know which config to fix.

Use this before adding new keybindings. Run it periodically to audit your
setup.

### :Lazy — Plugin Status and Logs

When a plugin stops working, `:Lazy` is the first place to check:

```vim
:Lazy           " Open the plugin manager

" In the UI:
"   Look for plugins marked with ✗ (error) or ⚠ (warning)
"   Press Enter on a plugin to see its details
"   Press L to see the load log for that plugin
"   Press ? for all UI commands
```

**Common issues visible in :Lazy:**

| Indicator   | Meaning                          | Action                        |
| ----------- | -------------------------------- | ----------------------------- |
| `✗` (red X) | Plugin failed to install or load | Press Enter → L for error log |
| `⬆` (arrow) | Update available                 | Press `U` to update           |
| `⏱` (clock) | Lazy-loaded (not yet loaded)     | Normal — loads when triggered |
| `✓` (check) | Installed and loaded             | All good                      |
| `➜` (arrow) | Currently installing/updating    | Wait for it                   |

**Checking a specific plugin's log:**

```vim
:Lazy log           " Show recent changes across all plugins
" Then find the plugin of interest and press L
```

### :checkhealth — The Comprehensive Health Report

Run `:checkhealth` any time something weird happens. It's the universal
diagnostic tool.

```vim
:checkhealth              " Full report
:checkhealth nvim         " Core Neovim (providers, $TERM, Python, Node, Ruby)
:checkhealth lazy         " Plugin manager health
:checkhealth mason        " Mason package manager health
:checkhealth telescope.nvim   " Telescope (needs ripgrep, fd, treesitter)
:checkhealth treesitter   " Treesitter (parser compilation, highlight queries)
:checkhealth lsp          " LSP client
:checkhealth blink        " blink.cmp completion engine
:checkhealth nvim-dap     " Debug adapter protocol
```

The report is a regular Neovim buffer. Use all normal navigation: `gg` to go
to top, `G` to bottom, `/` to search, `q` to close.

### :LspInfo — Active Language Server Status

```vim
:LspInfo        " Show attached LSP servers for the current buffer

" Output looks like:
" Language client log: /tmp/nvim_lsp_log
" =========================================
" Detected filetype: typescript
"
" 1 client(s) attached to this buffer:
"
" Client: vtsls (id: 1, bufnr: [1])
"   Root dir: /home/user/myproject
"   Command: /home/user/.local/share/nvim/mason/bin/vtsls --stdio
"   Settings: { ... }
```

Other LSP commands:

```vim
:LspLog         " Show the LSP log file (very verbose, useful for debugging)
:LspRestart     " Restart all attached LSP servers for current buffer
:LspStop        " Stop all attached LSP servers
:LspStart <name> " Start a specific LSP server
```

When an LSP server isn't working (no completions, no go-to-definition):

1. `:LspInfo` — is the server attached?
2. If not attached: `:LspLog` — is there an error message?
3. If server not found: `:Mason` — is it installed?
4. If installed but not starting: check `:checkhealth lsp`

### :Mason — The Tool Manager UI

```vim
:Mason          " Open Mason package manager UI
```

The Mason UI is self-explanatory once you know the shortcuts:

```
Mason UI shortcuts:
  1 / 2 / 3 / 4   Filter by category (LSP / DAP / Linters / Formatters)
  i                Install selected package
  X                Uninstall selected package
  u                Update selected package
  U                Update ALL installed packages
  /                Search/filter by name
  g?               Show all shortcuts
  q                Close Mason
```

When you see a tool you need that isn't in the auto-install list, just open
Mason, search for it, and press `i`. Done.

### :Telescope — The Universal Fuzzy Finder

Telescope is how you find almost everything in this config. It's worth knowing
its navigation shortcuts by heart:

```vim
" Launching Telescope pickers (keybindings from telescope.lua / snacks.lua):
<leader>pf      " Find files in project
<leader>pg      " Live grep (search text across all files)
<leader>pb      " Open buffers list
<leader>ph      " Help tags
<leader>pd      " Diagnostics

" Inside any Telescope picker:
Ctrl+j / Down   " Move selection down
Ctrl+k / Up     " Move selection up
Enter           " Open selected item
Ctrl+v          " Open in vertical split
Ctrl+x          " Open in horizontal split
Ctrl+t          " Open in new tab
Ctrl+q          " Send results to quickfix list
Escape          " Close picker
```

---

## 7. Exercises

These exercises are designed to be done _right now_, before moving to file 01.
They'll take 30–45 minutes total. Do them in order — each builds on the last.

---

### Exercise 1: Verify Your Installation (10 min)

**Goal:** Confirm everything installed correctly and understand what you're
working with.

**Step 1:** Open Neovim in the repo directory:

```bash
nvim ~/.config/nvim
```

**Step 2:** Confirm you're loading the right config. Type this command in
Normal mode (you'll learn how to type `:` commands in file 01 — for now just
know that pressing `:` enters command mode, and you can type commands there):

```vim
:lua print(vim.fn.stdpath("config"))
```

The message bar at the bottom should show `/home/YOUR_USER/.config/nvim`.
If it shows a path containing `snap`, see the XDG paths section above.

**Step 3:** Run `:Lazy` and check that plugins are installed. You should see
a list of ~60-80 plugin names with checkmarks. If most show `✗` or no plugins
appear, run `:Lazy sync` and wait.

**Step 4:** After sync (or if already synced), quit and restart:

```vim
:qa
```

Then reopen: `nvim ~/.config/nvim`

**Step 5:** Run `:checkhealth nvim`. Read the output. Note any ERRORs (not
warnings). If you see an error about `pynvim` or `fd` or `ripgrep`, note it
down — you'll fix it by running the playbook.

**You've succeeded when:** `:Lazy` shows no red X marks, and `:checkhealth nvim`
shows no ERRORs (warnings are fine).

---

### Exercise 2: Navigate the Config Files With Oil (10 min)

**Goal:** Get comfortable navigating the filesystem with oil.nvim.

Oil.nvim is the file manager — it shows directory contents as a regular buffer.
You navigate it the same way you navigate text.

**Step 1:** Open Neovim in the nvim config directory:

```bash
nvim ~/.config/nvim
```

You should see a file listing in the main buffer.

**Step 2:** Navigate to `lua/` by pressing `j` to move down to that line, then
pressing `Enter` to enter the directory. (If you're not sure which key to
press: your cursor is already on the first line — use arrow keys if `j` doesn't
feel natural yet.)

**Step 3:** Keep navigating: `lua/` → `de100/` → `core/` → `options.lua`.
Press `Enter` on `options.lua` to open it.

**Step 4:** Look at the options. Find the line that sets `shiftwidth`. What's
it set to? (Answer: 2, for 2-space indentation.)

**Step 5:** Press `-` (minus key). You should go up one directory to `core/`.
Press `-` again to go to `de100/`. Navigate to `plugins/which-key.lua` and
open it.

**Step 6:** Find the `delay = 300` line. That's how many milliseconds you wait
before which-key appears. Try changing it temporarily to `delay = 600`. Save
with Ctrl+s. Now press Space in Normal mode and wait — the popup takes longer.
Change it back to `300` and save again.

**You've succeeded when:** You can navigate to any file in the config using
just `-` (go up) and Enter (go into dir / open file).

---

### Exercise 3: Explore the which-key Popup Tree (10 min)

**Goal:** Discover keybindings without memorizing anything.

**Step 1:** Open any file. Let's use keymaps.lua:

```vim
:e ~/.config/nvim/lua/de100/core/keymaps.lua
```

(The `:e` command means "edit" — you'll learn more in file 01.)

**Step 2:** Make sure you're in Normal mode (press Escape to be sure).

**Step 3:** Press `<Space>` and WAIT. The which-key popup should appear after
300ms. Look at the groups listed. Notice the letters and their group names.

**Step 4:** Without dismissing the popup, press `g`. You'll now see all the
git-related keybindings under `<leader>g`.

**Step 5:** Press `Escape` to dismiss. Press Space again. This time press `p`
for "pick/search". You'll see file-finding and search keybindings.

**Step 6:** Press `f` (for file fuzzy search). A Telescope picker should open.
Type a few letters of any filename you know. Press Escape to close.

**Step 7:** Try Space → `b` (buffers). You should see buffer management
keybindings.

**Step 8:** Try `g` without the leader — just press `g` in Normal mode and
wait. You should see built-in `g`-prefixed commands: `gd` (go to definition),
`gR` (references), `gg` (go to top of file), etc.

**You've succeeded when:** You've explored at least three which-key groups and
launched at least one picker.

---

### Exercise 4: Test the LSP (10 min)

**Goal:** Confirm the Language Server is running and providing useful
information.

**Step 1:** Create a test TypeScript file:

```bash
nvim /tmp/nvim-lsp-test.ts
```

**Step 2:** Enter Insert mode by pressing `i`. Type this code:

```typescript
const message: string = 42;
```

Then press Escape to go back to Normal mode. Wait 1-2 seconds.

**Step 3:** You should see a red underline or a diagnostic sign in the gutter
(sign column). If you don't see it immediately, try `:LspInfo` to check if the
server attached.

**Step 4:** Run `:LspInfo`. Confirm `vtsls` (or `typescript-language-server`)
is listed as attached. If no servers are listed, the LSP server may not be
installed — run `:Mason` and check if `vtsls` is installed (press `1` to filter
to LSP servers).

**Step 5:** Move your cursor to the `42` (the type error). Run:

```vim
:lua vim.diagnostic.open_float()
```

A floating window should appear showing the TypeScript error: something like
"Type 'number' is not assignable to type 'string'."

**Step 6:** Try running:

```vim
:lua vim.lsp.buf.hover()
```

This should show hover documentation for whatever's under your cursor. Move the
cursor to `string` (the type annotation) and try it — you should see TypeScript
type documentation.

**You've succeeded when:** You can see a diagnostic underline, open the
diagnostic float, and get hover documentation.

---

### Exercise 5: Understand the Boot Sequence in Practice (10 min)

**Goal:** Connect the theory to what actually loads on your machine.

**Step 1:** Open Neovim with startup time logging:

```bash
nvim --startuptime /tmp/nvim-startup.log
```

**Step 2:** Once inside Neovim, open the log file in a horizontal split:

```vim
:split /tmp/nvim-startup.log
```

(Press Escape first to make sure you're in Normal mode.)

**Step 3:** In the log file, look at the structure. Each line has:

- A timestamp (milliseconds since startup started)
- A delta (milliseconds since the previous event)
- The file or event name

**Step 4:** Find where `lazy.lua` appears. Everything before it is the core
loading. Everything after is lazy.nvim's bootstrap.

**Step 5:** Notice what's NOT in the log: most of your plugins! They aren't
listed because they haven't loaded yet — they're lazy-loaded. Only eager
plugins (mason, treesitter maybe, lualine) appear here.

**Step 6:** Close the log split (`:q`) and run:

```vim
:Lazy profile
```

This shows a much more readable version: plugin name, load time, and what
triggered the load. Sort by load time to see which plugins are slowest.

**Bonus challenge:** Can you find which plugin takes the longest to load?
Can you figure out why it's loaded eagerly vs lazily?

**You've succeeded when:** You can read the startup log, find lazy.nvim in it,
and understand why most plugins don't appear (because they're lazy-loaded).

---

## Troubleshooting Common First-Day Problems

Even with a perfect playbook run, first launches have surprises. Here are the
most common problems and their solutions.

---

### Problem: "Neovim opens but there are no colors / no plugins"

**Symptoms:** Monochrome text, no statusline, no icons.

**Diagnosis:**

```vim
:lua print(vim.fn.stdpath("config"))
```

Does this print `~/.config/nvim` or something under `snap/`?

**If it's a snap path:** See the XDG paths section. Run Neovim from a real
terminal. Fix `XDG_CONFIG_HOME` in your shell rc.

**If it's the right path:**

```vim
:Lazy
```

Do you see plugins? If not, they're not installed yet:

```vim
:Lazy sync
```

Wait for the sync to finish, then quit (`:qa`) and reopen.

---

### Problem: "I can't type anything — every key does weird things"

**Cause:** You're in Normal mode. Every key is a command, not text input.

**Fix:** Press `i` to enter Insert mode. The statusline at the bottom should
change from `NORMAL` to `INSERT`. Now you can type normally.

To go back to Normal mode: press `Escape` (or `Ctrl+c` — both work in this
config).

The hardest thing to internalize about Neovim: **you spend most of your time
in Normal mode, NOT in Insert mode.** You enter Insert to type, then immediately
return to Normal. This feels backward coming from VSCode, but it's the whole
point — Normal mode is where you navigate and transform text efficiently.

---

### Problem: "I typed :Lazy sync but I see 'E492: Not an editor command'"

**Cause:** You're in Insert mode. The `:` is being typed into the buffer, not
into the command line.

**Fix:** Press Escape first (to enter Normal mode), THEN type `:Lazy sync`.

When you press `:` in Normal mode, the cursor jumps to the bottom bar (command
line). That's where you type commands. In Insert mode, `:` just types a colon.

---

### Problem: "LSP diagnostics aren't appearing on a TypeScript file"

**Diagnosis steps:**

```vim
:LspInfo
```

Is any server listed as attached?

**If no servers attached:**

```vim
:Mason
" Press 1 to filter to LSP servers
" Search for vtsls or typescript-language-server
```

Is it installed? If not, press `i` to install it.

After installing, close Mason (`:q`) and re-open your TypeScript file. The
LSP server will start (may take 3-5 seconds on first run as it indexes the
project).

**If a server is attached but no diagnostics appear:**
Check that virtual_text is enabled:

```vim
:lua print(vim.inspect(vim.diagnostic.config()))
```

Look for `virtual_text = true`. If it's false, someone toggled it off
(or you pressed `<leader>lv` accidentally). Toggle it back:

```vim
:lua vim.diagnostic.config({ virtual_text = true })
```

Or use the keymap: `<leader>lv` (Toggle LSP virtual text).

---

### Problem: "Completion popup doesn't appear when I type"

**Diagnosis:** blink.cmp (the completion plugin) might not have loaded yet.

**Check:**

```vim
:Lazy
" Search for blink.cmp in the list
" Is it installed (checkmark)? Is it loaded (no clock icon)?
```

If blink.cmp shows an error: press Enter on it in the `:Lazy` UI, then press
`L` for its log. The most common error is a failed Rust binary build.

**If the Rust build failed:**

```vim
:Lazy build blink.cmp
```

This retries the build. It needs cargo (Rust) to be installed.
Check: `cargo --version`. If missing, run the Ansible playbook.

**Manual fix:**

```bash
cd ~/.local/share/nvim/lazy/blink.cmp
cargo build --release
```

Also check: blink.cmp is disabled for certain filetypes (TelescopePrompt,
minifiles, snacks_picker_input). Make sure you're not in one of those.

---

### Problem: "which-key popup doesn't appear when I press Space"

**Check that which-key loaded:**

```vim
:Lazy
" Find which-key.nvim in the list
```

**If it shows as lazy (not yet loaded):** which-key loads on `VeryLazy` event,
which fires after the initial UI is ready. It should load within the first
second of Neovim starting. Try pressing Space in a regular Normal mode buffer
(not command line, not insert mode).

**If the popup just feels too slow:** The delay is 300ms (configurable in
`which-key.lua`). If Neovim is under load (mason installing things, LSP
indexing), the popup may feel sluggish. This is temporary.

**If you need the popup right now:** Press `<Space>?` — this forces which-key
to show all Space-based keybindings immediately.

---

### Problem: "treesitter highlighting looks wrong / no highlighting"

**Symptom:** Code looks flat, or you see strings like `[ERROR]` in the buffer.

**Diagnosis:**

```vim
:checkhealth treesitter
```

Look for parsers that failed to compile.

**Fix — install/recompile parsers:**

```vim
:TSUpdate        " Update all installed parsers
:TSInstall lua   " Install a specific parser
:TSInstall all   " Install all parsers (takes a while)
```

Common cause: `tree-sitter-cli` not in PATH. The playbook installs it via npm.
Check: `tree-sitter --version`. If missing:

```bash
sudo npm install -g tree-sitter-cli
```

---

### Problem: "auto-save keeps triggering and causing LSP restarts"

**Cause:** auto-save.lua saves on `TextChanged` with a debounce. Some LSP
servers restart when they detect a file save, which briefly interrupts
completions.

**Temporary fix — disable auto-save for current session:**

```vim
:lua require("auto-save").toggle()
```

**Permanent fix:** Edit `lua/de100/plugins/auto-save.lua` and increase the
debounce delay, or change the trigger events to `FocusLost` only.

This is a known tension between auto-save and LSP behavior. Most users adapt
by using `Ctrl+s` explicitly when they want a "real" save that triggers LSP
re-indexing.

---

### Problem: "I see 'No information available' when pressing K for hover"

**Cause:** LSP hover only works when:

1. A language server is attached (check `:LspInfo`)
2. Your cursor is on a symbol the LSP knows about
3. The LSP server has finished indexing the project

**Try:** Wait 5-10 seconds after opening a file in a large project. Move your
cursor onto a function name (not a keyword or comment). Press `K`.

If it still shows nothing: the LSP might not support hover for that symbol
type, or the server is still starting. Check `:LspLog` for "initialized"
messages.

---

### Problem: "The playbook failed with 'could not lock the administration directory'"

**Cause:** Another process (apt auto-updater) has the apt lock.

**Fix:** Wait a minute and re-run. Or:

```bash
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock-frontend
sudo dpkg --configure -a
ansible-playbook neovim.yml -K
```

---

### Problem: "Neovim build fails: 'cmake: command not found'"

**Cause:** cmake isn't installed. This shouldn't happen if the playbook ran,
but if you're doing a manual install:

```bash
sudo apt install cmake ninja-build build-essential
```

---

## Summary of What You've Learned in File 00

Let's recap what this file covered, because it's a lot:

```
PHILOSOPHY
├── Neovim is terminal-first, modal, keyboard-only
├── The learning curve: painful week 1, fast month 2
├── Mental model: buffers (invisible) + windows (visible) + tabs (layouts)
└── Composable tools philosophy: Neovim edits text; everything else integrates

CONFIG STRUCTURE
├── init.lua → core (options + keymaps) → lazy (plugins) → current-theme
├── de100/core/ = editor defaults and base keybindings
├── de100/plugins/ = one file per plugin
├── de100/plugins/lsp/ = mason + lspconfig
└── after/ftplugin/ = per-language overrides

INSTALLATION
├── Playbook: ansible-playbook neovim.yml -K
├── Installs: build tools, runtimes, npm tools, Python tools, Go tools
├── Mason installs: LSP servers, formatters, linters, debug adapters
└── XDG caveat: don't run nvim from snap-sandboxed VSCode terminal

FIRST LAUNCH
├── :Lazy sync = install all plugins (do this first)
├── Restart after sync (important!)
├── :checkhealth = comprehensive health report
└── Expected warnings: Ruby/PHP/Perl missing = fine

KEY CONCEPTS
├── lazy.nvim: loads plugins lazily, :Lazy sync to install/update
├── mason.nvim: installs LSP tools, :Mason for UI
├── which-key.nvim: Space + wait = keybinding popup
└── Leader = Space, <leader>X means Space+X

REFERENCE TOOLS
├── :help <topic> = built-in documentation (better than you think)
├── :Hawtkeys = find duplicate/conflicting keybindings
├── :Lazy = plugin status and logs
├── :checkhealth = health report
├── :LspInfo = active language servers
└── :Mason = tool installer UI
```

---

## What's Next?

Move on to **[01-surviving-neovim.md](./01-surviving-neovim.md)** — where you
learn the modal editing model, how to move the cursor properly, how to insert
and delete text, and the core grammar that makes everything else click.

By the end of file 01, you'll be able to:

- Move the cursor in every direction efficiently
- Enter and exit insert mode correctly
- Delete, change, and copy text
- Undo and redo without thinking about it
- Open files, save files, and quit without panic

```
┌──────────────────────────────────────────────────────────────────┐
│  The 7 commands that will save your life right now:              │
│                                                                  │
│  Escape    → return to Normal mode (your safe harbor)            │
│  i         → enter Insert mode (to type text)                    │
│  :w        → save the current file                               │
│  :q        → quit (if no unsaved changes)                        │
│  :q!       → force quit (discard unsaved changes)                │
│  :wq       → save and quit                                       │
│  Ctrl+s    → save (works in normal + insert mode in this config) │
│                                                                  │
│  With just these, you can survive any Neovim situation.          │
└──────────────────────────────────────────────────────────────────┘
```

---

_File `00` of the Neovim: 0 to Hero series — `de100` config edition._
_See the [README](./README.md) for the full series index._
