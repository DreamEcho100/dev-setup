# Neovim: 0 to Hero

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗                       ║
║    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║                       ║
║    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║                       ║
║    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║                       ║
║    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║                       ║
║    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝                       ║
║                                                                              ║
║              0  ──────────────────────────────────►  Hero                   ║
║                                                                              ║
║    [ VSCode refugee? You're in the right place. ]                            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## What Is This Series?

You clicked the clone button, ran the Ansible playbook (maybe), and now you're
staring at a terminal with a blinking cursor and absolutely no idea where the
File menu went. That's fine. That's exactly where this series starts.

**Neovim: 0 to Hero** is a structured, practical, no-fluff guide to becoming
genuinely fast in Neovim — specifically with the `de100` config in this repo.
It's not a dry reference manual. It's written like a senior developer sitting
next to you, explaining not just _what_ to press but _why_ it works that way
and how it compares to what you already know from VSCode.

Every file in the series builds on the previous one. The goal isn't to memorize
200 keybindings in a weekend — it's to understand the mental model so deeply
that new keybindings become obvious instead of arbitrary.

> **Who is this for?** VSCode users who are curious about or committed to
> switching to Neovim. You don't need prior Vim experience — but you should be
> comfortable in a terminal, know what git is, and have at least a little
> tolerance for things being weird before they become fast.

---

## Learning Path

```
docs/neovim-tutorials-from-0-to-hero/
│
├── README.md          ← You are here. Overview, glossary, survival guide.
│
├── 00-before-you-start.md
│   └── Philosophy, installation, first launch, config structure
│
├── 01-surviving-neovim.md
│   └── Modes, how to quit, basic movement, inserting text
│
├── 02-the-vscode-translator.md
│   └── which-key, Space as leader, every VSCode shortcut mapped to Neovim
│
├── 03-navigating-like-a-pro.md
│   └── hjkl, motions, text objects, flash.nvim jumps, Telescope
│
├── 04-editing-at-the-speed-of-thought.md
│   └── Operators, text objects, macros, multicursor, visual modes
│
├── 05-files-and-projects.md
│   └── oil.nvim, harpoon, buffers vs tabs, sessions, auto-session
│
├── 06-splits-and-windows.md
│   └── Horizontal/vertical splits, resize, zoom, tmux integration
│
├── 07-lsp-and-completions.md
│   └── blink.cmp V2, LuaSnip explicit ;triggers, LSP keymaps, Mason, diagnostics
│
├── 08-git-in-neovim.md
│   └── Neogit, Gitsigns, Diffview, git worktrees
│
├── 09-search-and-replace.md
│   └── /, ?, grug-far.nvim, Telescope live_grep, search-replace.nvim
│
├── 10-debugging-with-dap.md
│   └── nvim-dap, breakpoints, watch expressions, REPL
│
├── 11-terminal-and-tasks.md
│   └── Toggleterm / snacks terminal, overseer tasks, tmux workflow
│
├── 12-language-extras.md
│   └── Per-filetype config (after/ftplugin/), emmet, kulala (HTTP), dadbod
│
├── 13-customizing-the-config.md
│   └── Adding plugins, editing keymaps, writing your own ftplugin
│
├── 14-workflow-and-muscle-memory.md
│   └── hardtime.nvim, hawtkeys.nvim, building speed, personal workflow tips
│
├── 15-go-development.md
│   └── Beginner-friendly Go setup: gopls, go.work, tests, linting, debugging
│
├── 16-tmux-from-scratch.md
│   └── Complete tmux noob guide: sessions, windows, panes, copy mode, sessionizer
│
├── 17-tmux-neovim-workflow.md
│   └── vim-tmux-navigator, clipboard bridge, <C-f> sessionizer, project patterns
│
├── 18-cpp-development.md
│   └── C/C++ setup: clangd, compile_commands.json, cmake-tools, codelldb, snippets
│
├── 19-polyglot-lsp-checklist.md
│   └── Language-by-language LSP/completion/diagnostics audit and troubleshooting
│
└── 20-shell-terminal-tmux.md
    └── zsh, Kitty, Ghostty, Starship, themes, tmux persistence, and VS Code terminal equivalents
```

Each file is self-contained — you can jump to any topic once you've got the
basics from `00` and `01`. The numbers are a suggested progression, not a
requirement.

---

## Prerequisites Checklist

Before starting, confirm you have these. Check them off as you go:

- [ ] **Terminal basics** — you can navigate directories with `cd`, list files
      with `ls`, and you know what `~` means.
- [ ] **git installed** — run `git --version`. You should see a version number.
- [ ] **This repo cloned** — `git clone <repo-url> ~/mfansible` or wherever
      you've put it.
- [ ] **Ansible installed** — `ansible --version`. If missing:
      `sudo apt install ansible` (Debian/Ubuntu) or `brew install ansible` (mac).
- [ ] **Playbook run at least once** — `cd ~/mfansible && ansible-playbook neovim.yml -K`.
      This builds Neovim from source, installs LSP servers, formatters,
      ripgrep, fd, and a bunch of other tools.
- [ ] **Neovim >= 0.10** — `nvim --version`. The config uses APIs that require
      at least 0.10; 0.11+ recommended.
- [ ] **A Nerd Font** — install one from [nerdfonts.com](https://www.nerdfonts.com/)
      and set it in your terminal emulator. Icons will be boxes/question marks
      without it.
- [ ] **True-color terminal** — Alacritty, Kitty, WezTerm, or any modern
      terminal. The old Ubuntu `gnome-terminal` works but some themes look off.

---

## Quick Orientation: The Config's Key Bindings at a Glance

The five things you must know before anything else:

| What                 | Key                       | Notes                                      |
| -------------------- | ------------------------- | ------------------------------------------ |
| **Leader key**       | `Space`                   | Almost every custom keybinding starts here |
| **Snippet trigger**  | `;`                       | Type `;shebang` in insert mode → bash snippet |
| **Force completion** | `Ctrl+Space`              | Show the completion menu right now         |
| **Which-key hint**   | Press `Space`, wait 300ms | A popup shows all available next keys      |
| **Save file**        | `Ctrl+s`                  | Works in normal, insert, and command mode  |

And the most important thing you will ever learn in Neovim:

```
To exit Neovim:  press Escape (make sure you're in Normal mode)
                 then type    :q  (and hit Enter)

If you have unsaved changes:  :q!   (force quit, discard changes)
                          or  :wq   (save and quit)
                          or  :wa   (save all open files)
```

---

## How to Verify the Config Works

After your first launch, run these two commands (type them in Normal mode
prefixed with `:`):

**1. Check overall health:**

```
:checkhealth
```

This opens a report. Look for lines with `OK` or `WARNING`. Real problems show
as `ERROR`. Missing Ruby/PHP/Perl providers? Fine — you don't need them.
Missing `fd` or `ripgrep`? Run the playbook.

**2. Check plugin status:**

```
:Lazy
```

A beautiful UI opens. Press `S` to sync (install/update everything). Press `?`
for help. Press `q` to close. If you see plugins with an `X` (error), press
`Enter` on them to see the error log.

**3. After `:Lazy sync` finishes, restart Neovim.** Many plugins only fully
activate after a restart post-install.

---

## Glossary

You're going to see these words everywhere. Here they are in plain English:

| Term            | What it actually means                                                                                                                                                   |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Buffer**      | A file loaded into memory. Think of it like an open document. You can have 20 buffers open even if only 2 are visible on screen.                                         |
| **Window**      | A rectangular panel displaying a buffer. When you split the screen, each pane is a window. Multiple windows can show the same buffer.                                    |
| **Split**       | The act of dividing your screen into multiple windows. Horizontal split = `<leader>sh`. Vertical split = `<leader>sv`.                                                   |
| **Tab**         | In Neovim, a tab is a _layout_ — a collection of windows. It's NOT like a browser tab showing one file. Most people stick to one tab and use buffers instead.            |
| **LSP**         | Language Server Protocol. A background process that understands your code and provides completions, go-to-definition, diagnostics, etc. Managed by Mason in this config. |
| **DAP**         | Debug Adapter Protocol. The debugging layer — breakpoints, step-through, variable inspection. Like VSCode's debugger, but in Neovim.                                     |
| **Register**    | A named clipboard slot. `"` is the default. `+` is the system clipboard. `_` is the black hole (delete without saving).                                                  |
| **Motion**      | A command that moves the cursor. `w` (next word), `}` (next paragraph), `gg` (top of file), `G` (bottom), `f<char>` (find character).                                    |
| **Operator**    | A command that does something to text. `d` (delete), `c` (change), `y` (yank/copy), `>` (indent). Operators + motions = power.                                           |
| **Text Object** | A semantic chunk of text: `iw` (inner word), `it` (inner tag), `i(` (inside parens), `ap` (around paragraph). Used with operators.                                       |
| **Mode**        | Neovim is always in one mode. Normal = navigate/command. Insert = type text. Visual = select text. Command = type `:commands`. Replace = overwrite.                      |

---

## "I Just Want to Open a File RIGHT NOW" — Survival Guide

You've got 5 minutes and you need to edit a config file. Here's the minimum:

```bash
# 1. Open a file
nvim path/to/file.lua

# 2. Or open Neovim in a directory (shows oil.nvim file browser)
nvim .
```

Once inside:

```
# 3. Move the cursor — use arrow keys (hjkl also work once you learn them)
     Arrow keys work fine in insert mode AND normal mode for now.

# 4. Enter Insert mode to type text
     Press  i  (cursor stays before current position)
     Press  A  (jumps to end of line and enters insert mode) ← very useful

# 5. Go back to Normal mode (stop editing)
     Press  Escape  (or Ctrl+c — both work in this config)

# 6. Save the file
     Press  Ctrl+s  (works in both normal and insert mode)

# 7. Quit
     In normal mode:  :q   (quit if no changes)
                      :wq  (save and quit)
                      :q!  (force quit, lose changes)
```

That's it. You can use Neovim right now with just those 5 concepts. Everything
else in this series makes you faster.

---

## How to Use This Series

Each tutorial file follows the same structure:

1. **The concept** — what it is, why it matters, how it maps to VSCode
2. **Key tables** — the bindings you'll actually use, in a scannable format
3. **Worked examples** — real scenarios showing the keystrokes
4. **VSCode comparison** — explicit before/after so you know where you landed
5. **Exercises** — 5 practical tasks to do right now before moving on

> **On exercises:** Don't skip them. Reading about motions and actually doing
> them are completely different experiences. Each exercise is designed to take
> 3-10 minutes. Do them in a real file — ideally one from this very repo.

**Suggested pace:**

- Day 1: Files 00 + 01 (philosophy + survival)
- Day 2-3: Files 02 + 03 (VSCode mapping + navigation)
- Week 1: Files 04-06 (editing, files, splits)
- Week 2: Files 07-09 (LSP, git, search)
- Week 3+: Files 10-14 at your own speed
- Language extras (pick what applies to you):
  - File 15 — Go development
  - Files 16-17 — tmux (noob-friendly) + tmux+Neovim integration
  - File 18 — C/C++ development

You'll feel slow for about a week. You'll feel _interesting_ by week two. You'll
never want to go back by week four. This is normal.

---

## Navigation Within Each File

All tutorial files use consistent section headers. You can jump between them
inside Neovim using Telescope:

```
<leader>pb  →  search buffer (finds headings by text)
```

Or use the built-in jump: in Normal mode, type `/` followed by the section
name and press Enter.

---

_Made with stubbornness and too much coffee. Good luck — you'll need it for
about a week, and then you won't._
