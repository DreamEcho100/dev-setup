# 02 · The VSCode Translator

> **Series:** Neovim 0 to Hero
> **Difficulty:** Beginner — assumes you finished Tutorial 01
> **Time:** ~60 minutes to read + use as a reference forever
> **Goal:** Know the Neovim equivalent of every VSCode action you rely on daily

---

This is the reference file. Bookmark it. The philosophy of this tutorial is simple: **you already know how to code — you just need to know how to do everything you already do, but in Neovim**.

We're not going to pretend Neovim and VSCode are the same. They're not. But 95% of what you do in VSCode has a direct or nearly-direct equivalent in Neovim, and in many cases the Neovim version is faster or more powerful once you know it. We'll call those out.

Let's start with the mental model shifts, because some VSCode concepts simply don't map 1:1 to Neovim — and if you try to force them, you'll be frustrated. Once you understand _why_ Neovim works differently, the new approach will make sense.

---

## 1. Mental Model Shifts

### Files vs Buffers vs Windows vs Tabs

This is the most important conceptual shift, and getting it wrong will make Neovim feel chaotic.

**In VSCode:**

- You open a "file" and it appears in a "tab" at the top
- You can split the editor into multiple panes
- Closing a "tab" closes that file from your view

**In Neovim, there are three separate layers:**

```
┌─────────────────────────────────────────────────────────┐
│                    NEOVIM SESSION                        │
│                                                          │
│  TABS  (rare — like workspaces, not file tabs)          │
│  ┌─────────────────────────────────────────────────┐    │
│  │                     TAB 1                        │    │
│  │                                                  │    │
│  │  WINDOWS (splits — what you see on screen)       │    │
│  │  ┌─────────────────┐  ┌──────────────────────┐  │    │
│  │  │                 │  │                      │  │    │
│  │  │  Window 1       │  │  Window 2            │  │    │
│  │  │  showing        │  │  showing             │  │    │
│  │  │  Buffer A       │  │  Buffer B            │  │    │
│  │  │                 │  │                      │  │    │
│  │  └─────────────────┘  └──────────────────────┘  │    │
│  └─────────────────────────────────────────────────┘    │
│                                                          │
│  BUFFERS  (open files — even "hidden" ones not shown)   │
│  Buffer A: /src/app.ts  (shown in Window 1)             │
│  Buffer B: /src/utils.ts (shown in Window 2)            │
│  Buffer C: /src/types.ts (open but not shown anywhere)  │
│  Buffer D: /README.md    (open but hidden)              │
└─────────────────────────────────────────────────────────┘
```

**Buffers** are loaded files. When you open a file, it becomes a buffer. That buffer stays in memory even if you close the window showing it. You can have 20 files open as buffers but only see 2 of them on screen at a time.

**Windows** are the visible panes. A window is a "viewport" showing a buffer. You can have the same buffer open in two windows simultaneously (useful for viewing different parts of the same file).

**Tabs** in Neovim are _not_ like browser tabs or VSCode tabs. A Neovim tab is a full window layout — each tab has its own arrangement of windows. Most Neovim users use them sparingly, for completely different workspace layouts. This is where VSCode refugees get confused: the "tab line" at the top of Neovim (if you have one configured) typically shows _buffers_, not Neovim tabs.

In this config:

- `Tab` / `Shift+Tab` cycles through buffers (like `Ctrl+Tab` in VSCode)
- `<leader>bx` closes a buffer (like closing a VSCode tab)
- `<leader>sv` / `<leader>sh` creates window splits
- `<leader>to` / `<leader>tx` manages Neovim tabs (rare)

**The practical upshot:** when you "open a file" in Neovim, you're creating a buffer. To switch between open files, use `<leader>pb` (buffer picker) or `Tab`/`Shift+Tab`. To close a file, use `<leader>bx`.

---

### Sidebar vs Picker

**In VSCode:** You have a permanent sidebar on the left. It always shows your file tree. You expand folders, click files, they open. The sidebar is always there eating screen space.

**In Neovim:** There is no permanent sidebar by default. Instead, you use **pickers** — fuzzy-search popups that let you find and open files instantly by typing a few characters of the name. This config uses **Snacks.nvim** for picking and **Oil.nvim** / **mini.files** for file browsing.

The VSCode workflow: open sidebar → expand folders → find file → click.

The Neovim workflow: press `<leader>pf` → type 3-4 chars of filename → Enter.

Once you're used to the picker workflow, the sidebar feels painfully slow. You'll go back to VSCode and think "why do I need to _click_ this?" Pickers are that good.

That said, sometimes you want to browse the file tree visually — especially for exploring an unfamiliar project. That's what Oil.nvim and mini.files are for.

---

### Mouse vs Keyboard

You can use the mouse in Neovim. Clicking places the cursor. Scrolling works. You can click to position in Insert mode. This config doesn't disable mouse support, and it's reasonable to use it as a crutch while learning.

However: the entire point of Neovim is to be keyboard-first. Every mouse action has a keyboard equivalent, and the keyboard equivalent is almost always faster. The mouse in Neovim is like bumper lanes in bowling — useful when starting out, but you'll want to remove them once you're ready to bowl properly.

The goal isn't to prove you don't need a mouse. It's to develop the fluency where reaching for the mouse simply feels slower than using the keyboard.

---

### Extensions vs Plugins

**In VSCode:** You install extensions from the marketplace with a GUI. Extensions are managed through a sidebar panel. Updates are automatic.

**In Neovim:** Everything is managed with **lazy.nvim** (the plugin manager configured in this setup). Plugins are Lua files that declare what to install, when to load it, and how to configure it. All plugin configs live in:

```
dotfiles/.config/nvim/lua/de100/plugins/
```

To install a new plugin: add a file (or add an entry to an existing file), describe the plugin spec, and run `:Lazy sync`. To update: `:Lazy update`. To see what's installed: `:Lazy` or `:Lazy show`.

**Key difference:** Neovim plugins are code, not black boxes. You can read their source, understand exactly what they do, and customize them completely. Your plugin config _is_ your editor configuration. This is both more powerful and more responsibility.

---

### Settings.json vs Lua Config

**In VSCode:** You have `settings.json` — a flat JSON file where you toggle options with string keys.

**In Neovim:** Your configuration is Lua code. Options are set in `dotfiles/.config/nvim/lua/de100/core/options.lua`. Keymaps are in `keymaps.lua`. Plugins each have their own config file.

The power of Lua config: you can use actual programming constructs. Conditionals, functions, loops, environment variable checks. This config, for example, enables Copilot only when an environment variable is set:

```lua
enabled = vim.env.DE100_ENABLE_COPILOT == "1",
```

No JSON can do that.

---

## 2. Editor Actions

The everyday actions you do dozens of times per session.

> **Note on `<leader>`:** In this config, the leader key is `Space`. So `<leader>pf` means press `Space` then `p` then `f`. You'll see `<leader>` throughout. When you press Space and then pause, the **which-key** plugin pops up a menu showing all available next keystrokes.

| Action                      | VSCode                 | Neovim (this config)                           |
| --------------------------- | ---------------------- | ---------------------------------------------- |
| Open file                   | `Ctrl+O` / File menu   | `:e path/to/file` OR `<leader>pf` (picker)     |
| Open recent files           | File > Open Recent     | `<leader>pr` (Snacks recent)                   |
| Smart file picker           | `Ctrl+P`               | `<leader>pF` (smart: recent + frecency)        |
| Save                        | `Ctrl+S`               | `Ctrl+S` or `:w`                               |
| Save without format         | —                      | `<leader>sn`                                   |
| Save all                    | `Ctrl+K S`             | `:wa`                                          |
| Close file/tab              | `Ctrl+W`               | `<leader>bx` (bdelete)                         |
| Close buffer (confirm)      | —                      | `<leader>bD` (Snacks bufdelete, asks first)    |
| New empty buffer            | `Ctrl+N`               | `<leader>bo` (enew)                            |
| Next buffer                 | `Ctrl+Tab`             | `Tab`                                          |
| Previous buffer             | `Ctrl+Shift+Tab`       | `Shift+Tab`                                    |
| List/pick open buffers      | —                      | `<leader>pb`                                   |
| Undo                        | `Ctrl+Z`               | `u`                                            |
| Redo                        | `Ctrl+Y`               | `Ctrl+R`                                       |
| Find in current file        | `Ctrl+F`               | `/pattern` then `n`/`N`                        |
| Find + Replace in file      | `Ctrl+H`               | `:%s/old/new/gc`                               |
| Find in project (grep)      | `Ctrl+Shift+F`         | `<leader>pg` (Snacks grep)                     |
| Grep word under cursor      | `Ctrl+Shift+F` + paste | `<leader>pws`                                  |
| Command palette             | `Ctrl+Shift+P`         | `<leader>pc` (commands picker)                 |
| Go to file                  | `Ctrl+P`               | `<leader>pf`                                   |
| Format document             | `Shift+Alt+F`          | `<leader>mp` (conform.nvim)                    |
| Toggle terminal             | `` Ctrl+` ``           | See terminal section                           |
| Edit settings               | `Ctrl+,`               | `:e ~/.config/nvim/lua/de100/core/options.lua` |
| Copy file path to clipboard | —                      | `<leader>fp`                                   |
| Clear search highlights     | `Esc` in search        | `<leader>nh`                                   |
| Help pages                  | `F1`                   | `<leader>vh` (Snacks help picker)              |
| View keymaps                | `Ctrl+K Ctrl+S`        | `<leader>pk` (Snacks keymap picker)            |

### Notes on Find + Replace

The command `:%s/old/new/gc` breaks down as:

- `%` — apply to the whole file
- `s` — substitute command
- `/old/` — search pattern
- `new` — replacement string
- `g` — global (all occurrences per line)
- `c` — confirm each replacement

For more powerful project-wide search and replace, this config has **grug-far.nvim**. Check the dedicated tutorial or the `grug-far.lua` config for keybindings.

---

## 3. Navigation

Getting around your codebase — jumping to definitions, finding references, navigating your edit history.

> **💡 In VSCode you'd...** use the Go menu, right-click context menus, or keyboard shortcuts like `F12`. The LSP features are mostly mouse-friendly.
>
> **In Neovim you...** use keyboard shortcuts mapped in the LSP `on_attach` callback (in `lsp/lsp.lua`). These activate when an LSP server attaches to your buffer.

| Action                | VSCode                  | Neovim (this config)                |
| --------------------- | ----------------------- | ----------------------------------- |
| Go to definition      | `F12`                   | `gd`                                |
| Go to declaration     | (right-click menu)      | `gD`                                |
| Find all references   | `Shift+F12`             | `gR` (opens Snacks picker)          |
| Go to implementation  | `Ctrl+F12`              | `gi` (opens Snacks picker)          |
| Go to type definition | (right-click)           | `gt` (opens Snacks picker)          |
| Hover documentation   | Hover / `Ctrl+K Ctrl+I` | `K`                                 |
| Signature help        | Auto-popup in insert    | `<leader>ls` (in normal and insert) |
| Back in jump list     | `Alt+Left`              | `Ctrl+O`                            |
| Forward in jump list  | `Alt+Right`             | `Ctrl+I`                            |
| Go to line number     | `Ctrl+G`                | `:{number}` or `{number}G`          |
| Go to symbol in file  | `Ctrl+Shift+O`          | `<leader>lo` (Aerial toggle)        |
| Next symbol           | —                       | `]a` (Aerial next)                  |
| Previous symbol       | —                       | `[a` (Aerial prev)                  |
| Next diagnostic       | `F8`                    | `]d`                                |
| Previous diagnostic   | `Shift+F8`              | `[d`                                |
| Next git hunk         | —                       | `]h` (gitsigns)                     |
| Previous git hunk     | —                       | `[h` (gitsigns)                     |

### Jump List Explained

> **💡 In VSCode you'd...** use `Alt+Left` and `Alt+Right` to navigate your cursor history (jump back and forward). This is invaluable when you jump to a definition and want to go back.
>
> **In Neovim you...** use `Ctrl+O` (jump Out — go back) and `Ctrl+I` (jump In — go forward). These navigate the **jump list**, which records every "big" cursor jump: definition jumps, file opens, searches, etc. Think of it as a cursor history.

The jump list is powerful: if you jump to a definition in a different file, `Ctrl+O` takes you back to exactly where you were before the jump. Works across files. Essential.

### Aerial Symbols Outline

> **💡 In VSCode you'd...** use the Outline panel in the sidebar (showing classes, functions, methods). Or `Ctrl+Shift+O` to jump to a symbol by name.
>
> **In Neovim you...** use `<leader>lo` to toggle the Aerial symbols outline. It appears as a panel on the right side, showing your file's structure (functions, classes, types). Press `<CR>` in the aerial panel to jump to that symbol.

---

## 4. Code Intelligence (LSP Features)

This is where Neovim has genuinely caught up to — and in some ways surpassed — VSCode. The Language Server Protocol (LSP) powers all these features, and Neovim's LSP integration is excellent.

> **💡 In VSCode you'd...** get code intelligence "for free" from extensions like the TypeScript extension, Pylance, etc. You might not even know LSP is involved — it just works.
>
> **In Neovim you...** get the same LSP backends (same language servers!), configured via Mason (the LSP installer) and `nvim-lspconfig`. The servers are the same; the editor integration is different but equally capable.

| Action                              | VSCode                    | Neovim (this config)                    |
| ----------------------------------- | ------------------------- | --------------------------------------- |
| Code actions (quick fixes)          | `Ctrl+.`                  | `<leader>ca`                            |
| Rename symbol                       | `F2`                      | `<leader>rn`                            |
| Rename file (preserving imports)    | Right-click > Rename      | `<leader>rN` (Snacks rename)            |
| Show workspace diagnostics          | Problems panel            | `<leader>xw` (Trouble workspace)        |
| Show file diagnostics               | Problems panel (filtered) | `<leader>xd` (Trouble document)         |
| Open todos/fixmes list              | (extension)               | `<leader>xt` (Trouble + todo-comments)  |
| Open quickfix list                  | Quick fix panel           | `<leader>xq` (Trouble quickfix)         |
| Show diagnostic float               | Hover on error            | `<leader>df` or `<leader>dd`            |
| Toggle virtual text (inline errors) | Settings: inline hints    | `<leader>lv` (toggle virtual text)      |
| Toggle inlay hints                  | Settings: inlay hints     | `<leader>li` (toggle inlay hints)       |
| Signature help                      | Auto-popup                | `<leader>ls`                            |
| Buffer diagnostics picker           | —                         | `<leader>D` (Snacks diagnostics_buffer) |
| Open Mason (LSP manager)            | Extensions sidebar        | `:Mason`                                |

### About Inlay Hints

> **💡 In VSCode you'd...** see inlay hints (TypeScript parameter names, return types, etc.) automatically if your extension supports them.
>
> **In Neovim you...** can toggle inlay hints with `<leader>li`. However, **inlay hints are disabled by default in this config** because of a bug in Neovim 0.12 where certain LSP servers returning end-of-line hint positions crash the extmark renderer. If you're on a newer Neovim version where this is fixed, enable them per-buffer with `<leader>li`.

### About Trouble.nvim

Trouble is the VSCode "Problems" panel equivalent, but much more powerful. It aggregates diagnostics from all LSP servers, lets you jump between issues, and integrates with TODO comments. The `<leader>x` group is your Trouble home:

```
<leader>xw  →  workspace diagnostics (all files)
<leader>xd  →  document diagnostics (current file only)
<leader>xq  →  quickfix list
<leader>xl  →  location list
<leader>xt  →  TODO/FIXME/HACK comments across project
```

---

## 5. File Explorer

Neovim uses two complementary file management tools in this config: **Oil.nvim** (edit your filesystem like a buffer) and **mini.files** (visual explorer). Both are keyboard-driven.

> **💡 In VSCode you'd...** use the Explorer sidebar (`Ctrl+Shift+E`). Expand folders, right-click for new files/folders, drag and drop, F2 to rename.
>
> **In Neovim you...** use either Oil or mini.files. The philosophy is different: **you edit the filesystem the same way you edit text**. Want to rename a file? Edit the text that is the filename. Want to move a file? Cut its line and paste it somewhere else. Want to create a file? Type a new name. It's wild the first time. Then it's brilliant.

| Action                        | VSCode                   | Neovim (this config)                                |
| ----------------------------- | ------------------------ | --------------------------------------------------- |
| Toggle file explorer          | `Ctrl+Shift+E`           | `<leader>ee` (mini.files)                           |
| Open explorer at current file | Right-click > Reveal     | `<leader>ef` (mini.files to current file)           |
| Open parent directory (Oil)   | —                        | `-` (minus key)                                     |
| Open parent dir in float      | —                        | `<leader>-` (Oil float)                             |
| Open explorer picker          | —                        | `<leader>pe` (Snacks explorer picker)               |
| Navigate into folder          | Click arrow/folder       | `L` or `Enter` (mini.files) / `Enter` (Oil)         |
| Navigate out/up               | Click parent             | `H` or `-` (mini.files)                             |
| Create new file               | Right-click > New File   | Edit a new line (Oil) or type filename (mini.files) |
| Create new folder             | Right-click > New Folder | Type `foldername/` (Oil handles trailing slash)     |
| Rename file                   | `F2` in explorer         | Edit the filename text in the buffer                |
| Delete file                   | `Delete` key             | Delete the line in Oil (`dd`), auto-confirms        |
| Move file                     | Drag and drop            | Cut line (`dd`) and paste in new location           |
| Refresh                       | —                        | `Ctrl+R` (Oil keybinding)                           |
| Close Oil                     | —                        | `q`                                                 |

### Oil.nvim Mental Model

Oil opens the current directory as a text buffer. The filenames ARE the buffer text. You use normal Neovim editing to manipulate files:

```
# This is an Oil buffer — it looks like this:
../
src/
  index.ts
  utils.ts
  types.ts
README.md
package.json
```

To rename `utils.ts` to `helpers.ts`: navigate to that line, press `cw` (change word), type `helpers`, save with `:w`. The file is renamed on disk.

To delete `types.ts`: go to that line, `dd` to delete the line, save. File is deleted.

To create a new file: go to a line, press `o`, type `newfile.ts`, save. File is created.

This is genuinely one of the coolest Neovim-specific workflows. Oil treats the filesystem as just another text buffer.

---

## 6. Git

This config has an excellent Git workflow, arguably better than VSCode's default Git integration. It layers several tools:

- **gitsigns.nvim**: inline hunk indicators, staging hunks, blame
- **neogit**: a Magit-style full Git UI
- **vim-fugitive**: the classic Vim Git integration
- **diffview.nvim**: beautiful diff viewer and file history
- **lazygit**: full TUI Git client (via Snacks.nvim integration)

> **💡 In VSCode you'd...** use the Source Control panel (`Ctrl+Shift+G`), with GitLens for extra features like inline blame. You'd click to stage files, type a commit message in a box, click commit.
>
> **In Neovim you...** have multiple powerful options. The most approachable (closest to VSCode) is Neogit. The fastest is using gitsigns keybindings for hunk-level operations. The most powerful is LazyGit for complex operations.

| Action                       | VSCode               | Neovim (this config)                  |
| ---------------------------- | -------------------- | ------------------------------------- |
| Open Git UI                  | `Ctrl+Shift+G`       | `<leader>gn` (Neogit)                 |
| Open LazyGit (full TUI)      | (GitLens extension)  | `<leader>lg`                          |
| View git log                 | GitLens panel        | `<leader>gl` (Snacks lazygit log)     |
| Stage current hunk           | Stage hunk button    | `<leader>gs`                          |
| Unstage/reset current hunk   | Discard hunk         | `<leader>gr`                          |
| Stage entire file/buffer     | Stage file           | `<leader>gS`                          |
| Reset entire file/buffer     | Discard all changes  | `<leader>gR`                          |
| Undo last stage              | —                    | `<leader>gu` (undo stage hunk)        |
| Preview hunk (inline diff)   | Hover on gutter      | `<leader>gp`                          |
| Toggle line blame            | GitLens inline blame | `<leader>gB` (toggle on/off)          |
| Show full line blame         | GitLens hover        | `<leader>gbl`                         |
| Open diff view               | Diff view panel      | `<leader>gdo` (Diffview open)         |
| Close diff view              | Close diff panel     | `<leader>gdc`                         |
| View current file history    | GitLens timeline     | `<leader>gdh` (Diffview file history) |
| View repo history            | GitLens repo history | `<leader>gdH`                         |
| Open fugitive                | —                    | `<leader>gf` (fullscreen tab)         |
| Git push (in fugitive)       | Push button          | `<leader>gP` (in fugitive buffer)     |
| Git pull --rebase (fugitive) | Pull button          | `<leader>gpr` (in fugitive buffer)    |
| Next hunk                    | —                    | `]h`                                  |
| Previous hunk                | —                    | `[h`                                  |
| Pick/switch git branch       | —                    | `<leader>gbr` (Snacks branch picker)  |
| Diff this file (inline)      | Split diff           | `<leader>gdi`                         |

### LazyGit Integration

> **💡 In VSCode you'd...** never have anything quite like LazyGit. It's a terminal UI that shows your repo's full state — staged/unstaged changes, commit history, branches, stashes — all navigable with keyboard shortcuts.

`<leader>lg` opens LazyGit in a floating window via Snacks.nvim. From there you can do complex operations: interactive rebase, cherry-pick, stash, reflog — all without leaving Neovim.

### The Gitsigns Workflow (Most Common)

For the 80% case (stage hunk, commit, push), here's the typical flow:

1. Make your code changes
2. `<leader>gs` — stage the current hunk (or `<leader>gS` to stage the whole file)
3. `<leader>gn` — open Neogit
4. In Neogit: press `c` then `cc` to open the commit dialog
5. Type your commit message
6. `Ctrl+C` to commit (or Neogit's commit key)
7. Back in Neogit: `P` to push

---

## 7. Debugging

This config uses **nvim-dap** (Debug Adapter Protocol) with **nvim-dap-ui** for a graphical debugging interface. It's the Neovim equivalent of VSCode's built-in debugger — using the same underlying protocol.

> **💡 In VSCode you'd...** press `F9` for breakpoints, `F5` to start debugging, `F10`/`F11` to step. The Debug panel appears on the left with variables, call stack, watch expressions.
>
> **In Neovim you...** use the same F-key shortcuts (mostly), and `F7` toggles the dap-ui panel which shows the same panels: variables, call stack, breakpoints, REPL.

| Action                      | VSCode                 | Neovim (this config)                   |
| --------------------------- | ---------------------- | -------------------------------------- |
| Toggle breakpoint           | `F9`                   | `F9` or `<leader>daptb`                |
| Set conditional breakpoint  | Right-click breakpoint | `<leader>dapb` (prompts for condition) |
| Start / Continue debug      | `F5`                   | `F5`                                   |
| Stop                        | `Shift+F5`             | `Shift+F5`                             |
| Step over (next line)       | `F10`                  | `F10`                                  |
| Step into (into function)   | `F11`                  | `F11`                                  |
| Step out (out of function)  | `Shift+F11`            | `Shift+F11`                            |
| Toggle debug UI panels      | Run and Debug panel    | `F7` or `<leader>dapu`                 |
| Show debug UI automatically | Yes                    | Yes (auto-opens on debug start)        |

### Supported Languages (Auto-Configured)

This config ships with debug adapters pre-configured for:

| Language/runtime      | Adapter                        | Notes                                      |
| --------------------- | ------------------------------ | ------------------------------------------ |
| Go                    | Delve via `nvim-dap-go`         | Program and nearest-test debugging         |
| JavaScript/TypeScript | current `js-debug-adapter`     | Node and Chromium browser sessions         |
| Python                | debugpy via `nvim-dap-python`  | Uses project virtual environments          |
| C/C++/Zig/Odin        | CodeLLDB                       | Build with debug symbols                   |
| Rust                  | CodeLLDB via `rustaceanvim`    | Rust-specific ownership                    |
| Lua/Neovim Lua        | Local Lua Debugger / OSV       | Launch standalone Lua or attach to Neovim  |
| Java                  | Java debug/test bundles        | Optional; requires Java 21+ and JDTLS       |
| C#/.NET               | netcoredbg                     | Optional; requires .NET                    |
| Godot/GDScript        | Godot built-in DAP server      | Optional; Godot listens on port 6006       |

### VSCode launch.json Compatibility

Current nvim-dap discovers `.vscode/launch.json` on demand, so no deprecated
manual loader is needed. Most portable adapter configurations work in both
editors, but VS Code extension commands are not DAP features and may not carry
over. A project `.nvim/dap.lua` is executable code: this config loads it only
after `<leader>dapP`/`:De100DapLoadProject` shows its path and asks for trust.

Run `<leader>daph` in a source buffer to inspect the selected configurations,
adapter executables, project files, and DAP log path.

---

## 8. Testing

This config uses **neotest** for a unified testing interface. It supports multiple test frameworks and shows results inline.

> **💡 In VSCode you'd...** use the Test Explorer extension (built-in in newer versions). You'd see pass/fail icons next to test functions, run individual tests from the gutter.
>
> **In Neovim you...** use neotest, which shows pass/fail signs in the gutter, lets you run individual tests, and has an output panel.

| Action                | VSCode              | Neovim (this config) |
| --------------------- | ------------------- | -------------------- |
| Run nearest test      | Click play button   | `<leader>tN`         |
| Run all tests in file | "Run File" button   | `<leader>tF`         |
| View test output      | Output panel        | `<leader>tO`         |
| Toggle test summary   | Test Explorer panel | `<leader>tS`         |

### Supported Test Frameworks

Neotest adapters configured in this setup:

| Framework  | Language                  | Adapter         |
| ---------- | ------------------------- | --------------- |
| vitest     | JavaScript/TypeScript     | neotest-vitest  |
| pytest     | Python                    | neotest-python  |
| plenary    | Lua (Neovim plugin tests) | neotest-plenary |
| cargo test | Rust                      | neotest-rust    |

---

## 9. Multi-Cursor

Multi-cursor is one of VSCode's most-loved features. Neovim has it too, via the **multicursor.nvim** plugin. The workflow is slightly different but equally powerful.

> **💡 In VSCode you'd...** `Ctrl+D` to select next occurrence of current word/selection, `Ctrl+Shift+L` to select ALL occurrences, `Alt+Click` to add arbitrary cursors. Then type to edit all at once.
>
> **In Neovim you...** use `<leader>cm` to add a cursor at the next match of the current word, or `<leader>cM` to add cursors at ALL matches. Then type normally — all cursors change together.

| Action                         | VSCode         | Neovim (this config)                                               |
| ------------------------------ | -------------- | ------------------------------------------------------------------ |
| Add cursor at next occurrence  | `Ctrl+D`       | `<leader>cm`                                                       |
| Add cursors at ALL occurrences | `Ctrl+Shift+L` | `<leader>cM`                                                       |
| Cancel / clear all cursors     | `Esc`          | `Esc` (first press clears search highlight, second clears cursors) |

### Multi-Cursor in Visual Mode

You can also use `<leader>cm` from Visual mode — it adds a cursor at the next match of your selection. This lets you select arbitrary text (not just whole words) and add cursors at each occurrence.

### Vim's Alternative: The `.` Command and Macros

> **Deep thought:** Experienced Vim users often use the `.` command (repeat last change) or macros (`q` to record, `@` to replay) instead of multi-cursor for many use cases. These are often more powerful because they can handle non-identical operations across positions. But multi-cursor is the intuitive VSCode-like option, so it's here when you need it.

---

## 10. Splitting and Layout

Splitting your editor view is a core workflow. In VSCode you drag editor tabs into split positions. In Neovim you use keybindings.

> **💡 In VSCode you'd...** drag a tab to the right side of the editor to split it. Or `Ctrl+\` to split right. `Ctrl+W` on a tab to close it.
>
> **In Neovim you...** use `<leader>s` prefix for split management, and `Ctrl+H/J/K/L` to navigate between splits (mirroring the `h/j/k/l` navigation keys).

| Action                        | VSCode               | Neovim (this config)          |
| ----------------------------- | -------------------- | ----------------------------- |
| Split editor right            | `Ctrl+\`             | `<leader>sv`                  |
| Split editor down             | (via menu)           | `<leader>sh`                  |
| Make all splits equal size    | (drag borders)       | `<leader>se`                  |
| Close current split           | Drag to merge        | `<leader>sx`                  |
| Focus split left              | `Ctrl+K Ctrl+Left`   | `Ctrl+H`                      |
| Focus split below             | `Ctrl+K Ctrl+Down`   | `Ctrl+J`                      |
| Focus split above             | `Ctrl+K Ctrl+Up`     | `Ctrl+K`                      |
| Focus split right             | `Ctrl+K Ctrl+Right`  | `Ctrl+L`                      |
| Maximize / zoom current split | Drag to full screen  | `<leader>sm` (toggle zoom)    |
| Resize split (larger height)  | Drag border          | `Down arrow` (in Normal mode) |
| Resize split (smaller height) | Drag border          | `Up arrow` (in Normal mode)   |
| Resize split (wider)          | Drag border          | `Right arrow`                 |
| Resize split (narrower)       | Drag border          | `Left arrow`                  |
| Open new Neovim tab           | `Ctrl+T` (sometimes) | `<leader>to`                  |
| Close Neovim tab              | `Ctrl+W` on tab      | `<leader>tx`                  |
| Next Neovim tab               | `Ctrl+PageDown`      | `<leader>tn`                  |
| Previous Neovim tab           | `Ctrl+PageUp`        | `<leader>tp`                  |
| Open current file in new tab  | —                    | `<leader>tf`                  |

### The Zoom Feature

`<leader>sm` is a custom toggle-zoom implemented directly in `keymaps.lua` without a plugin. It saves the current window layout, then maximizes the current window by doing `resize` (max height) and `vertical resize` (max width). Pressing it again restores the original layout. It's the "I want to focus on this one file" button.

---

## 11. Themes and UI

> **💡 In VSCode you'd...** `Ctrl+K Ctrl+T` to open the theme picker. Install themes from the marketplace. Toggle various settings via the Settings UI.
>
> **In Neovim you...** use `<leader>th` to open a live colorscheme picker (Snacks), and toggle various display settings with keybindings.

| Action                                  | VSCode           | Neovim (this config)                     |
| --------------------------------------- | ---------------- | ---------------------------------------- |
| Change color theme                      | `Ctrl+K Ctrl+T`  | `<leader>th` (Snacks colorscheme picker) |
| Toggle line wrap                        | View > Word Wrap | `<leader>lw`                             |
| Toggle virtual text (LSP errors inline) | Settings         | `<leader>lv`                             |
| Toggle inlay hints                      | Settings         | `<leader>li`                             |
| Undo tree (non-linear history)          | —                | `<leader>uu`                             |
| Search keymaps                          | `Ctrl+K Ctrl+S`  | `<leader>pk`                             |
| Help pages                              | `F1`             | `<leader>vh`                             |
| Copy current file path                  | —                | `<leader>fp`                             |
| Clear search highlights                 | `Esc`            | `<leader>nh`                             |

### Colorschemes in This Config

The `colorscheme.lua` file includes several themes configured and ready:

- **rose-pine** (primary)
- Others can be added via the colorschemes file

The `<leader>th` picker lets you preview and switch themes live. The active theme is saved in `lua/current-theme.lua`.

---

## 12. Extensions → Plugins Equivalents

Here's the big reference table: every popular VSCode extension mapped to its Neovim equivalent in this config (or the recommended Neovim equivalent).

| VSCode Extension               | Neovim Equivalent                     | Plugin in This Config?             | Notes                                           |
| ------------------------------ | ------------------------------------- | ---------------------------------- | ----------------------------------------------- |
| **Prettier**                   | conform.nvim + prettierd              | Yes (`formatting.lua`)             | Format on save, `<leader>mp`                    |
| **ESLint**                     | nvim-lint + eslint_d                  | Yes (`linting.lua`)                | Auto-lint on save                               |
| **GitLens**                    | gitsigns.nvim + neogit                | Yes (`gitstuff.lua`, `neogit.lua`) | Inline blame, hunk ops, full UI                 |
| **GitHub Copilot**             | copilot.lua                           | Yes (`ai.lua`)                     | Enable with `DE100_ENABLE_COPILOT=1` env var    |
| **GitHub Copilot Chat**        | CodeCompanion.nvim                    | Yes (`ai.lua`)                     | Enable with `DE100_ENABLE_CODECOMPANION=1`      |
| **Avante (Cursor-like AI)**    | avante.nvim                           | Yes (`ai.lua`)                     | Enable with `DE100_ENABLE_AVANTE=1`             |
| **Thunder Client**             | kulala.nvim                           | Yes (`kulala.lua`)                 | `.http` file REST client, `<leader>H` group     |
| **SQLTools**                   | vim-dadbod-ui                         | Yes (`dadbod-ui.lua`)              | Database explorer and query runner              |
| **Remote SSH**                 | remote-nvim.nvim                      | Yes (`remote-nvim.lua`)            | Edit files on remote servers                    |
| **Live Server**                | (not needed in Neovim)                | N/A                                | Run your own dev server externally              |
| **Bracket Pair Colorizer**     | Built-in Neovim 0.10+                 | N/A — built-in                     | `vim.opt.set_indent_with_tab = true`            |
| **Auto Rename Tag**            | nvim-ts-autotag                       | Via languages.lua                  | Auto-closes and renames HTML/JSX tags           |
| **Path Intellisense**          | blink.cmp path source                 | Yes (`blink-cmp.lua`)              | Auto-completes file paths                       |
| **Todo Highlight**             | todo-comments.nvim                    | Yes (loaded via trouble)           | Highlights TODO/FIXME/HACK/NOTE                 |
| **Error Lens**                 | Diagnostics virtual text + Trouble    | Yes (built-in + trouble.lua)       | `<leader>lv` to toggle, `<leader>xw` for panel  |
| **File Icons**                 | nvim-web-devicons                     | Yes (as dependency)                | Icons in file pickers, explorer, lualine        |
| **Rainbow Brackets**           | Treesitter highlights                 | Yes (`treesitter.lua`)             | Built into treesitter — no extra config needed  |
| **indent-rainbow**             | indent-blankline (not in this config) | Not installed                      | Can be added if desired                         |
| **Better Comments**            | todo-comments.nvim                    | Yes                                | `TODO:`, `FIXME:`, `HACK:`, `NOTE:` highlighted |
| **Code Spell Checker**         | codespell (in conform.nvim)           | Yes (`formatting.lua`)             | Runs as a formatter via `["*"] = {"codespell"}` |
| **Markdown Preview**           | markdown-preview.nvim                 | Yes (`markdown-preview.lua`)       | Opens in browser                                |
| **Render Markdown**            | render-markdown.nvim                  | Yes (`render-markdown.lua`)        | Inline markdown rendering in Neovim             |
| **Image Preview**              | snacks.image                          | Yes (in `snacks.lua`)              | Images in markdown buffers                      |
| **Kubernetes**                 | kubectl.nvim                          | Yes (`kubectl.lua`)                | Kubernetes management from Neovim               |
| **REST Client**                | kulala.nvim                           | Yes (`kulala.lua`)                 | Same as Thunder Client replacement              |
| **Draw.io / Diagrams**         | (none great)                          | Not installed                      | Consider PlantUML via CLI                       |
| **Live Share**                 | (no equivalent)                       | N/A                                | Use tmux with `pair` or `tmate`                 |
| **Vim**                        | Neovim itself                         | N/A                                | You're already here                             |
| **Which Key**                  | (no equivalent)                       | Yes (`which-key.lua`)              | Shows all leader key options on pause           |
| **Auto Save**                  | auto-save.nvim                        | Yes (`auto-save.lua`)              | Currently disabled (`enabled = false`)          |
| **Surround**                   | mini.surround                         | Yes (`mini.lua`)                   | `sa`, `ds`, `ca` for surround operations        |
| **Text Objects**               | mini.ai                               | Yes (`mini.lua`)                   | Enhanced text objects for selections            |
| **Harpoon**                    | (no equivalent)                       | Yes (`harpoon.lua`)                | Bookmark + instantly jump to 4 files            |
| **Session Manager**            | auto-session                          | Yes (`auto-session.lua`)           | Saves/restores window layouts                   |
| **Status Bar**                 | lualine                               | Yes (`lualine.lua`)                | Mode, git branch, diagnostics, file info        |
| **Fuzzy Finder (like Ctrl+P)** | snacks.picker                         | Yes (`snacks.lua`)                 | Replaces Telescope for most use cases           |
| **Treesitter**                 | nvim-treesitter                       | Yes (`treesitter.lua`)             | Syntax, text objects, highlights                |
| **Flash / Leap**               | (no equivalent)                       | Yes (`flash.lua`)                  | Jump anywhere on screen with 2 chars            |
| **Noice**                      | (no equivalent)                       | Yes (`noice.lua`)                  | Beautiful command line and notifications        |
| **Multicursor**                | VSCode native                         | Yes (`multicursor.lua`)            | `<leader>cm` / `<leader>cM`                     |

---

## 13. Complete Leader Key Map

`Space` is the leader key. When you press Space in Normal mode, which-key will show you all available next keys after a short delay (300ms by default). Here's the complete reference organized by group.

> **Tip:** Press `<leader>` (Space) and then pause. Which-key will show you all the groups. Then press a group key (like `p` for picks) and pause again to see the full submenu. You never need to memorize all of this — which-key is your in-editor cheat sheet.

### `<leader>b` — Buffers

| Keybinding   | Action                                   |
| ------------ | ---------------------------------------- |
| `<leader>bx` | Close (delete) current buffer            |
| `<leader>bo` | Open new empty buffer                    |
| `<leader>bD` | Delete buffer (with confirmation prompt) |

_(Navigate buffers: `Tab` for next, `Shift+Tab` for previous)_

---

### `<leader>c` — Code

| Keybinding   | Action                                      |
| ------------ | ------------------------------------------- |
| `<leader>ca` | Code actions (LSP — normal and visual mode) |
| `<leader>cm` | Multi-cursor: add cursor at next match      |
| `<leader>cM` | Multi-cursor: add cursors at ALL matches    |

---

### `<leader>d` — Diagnostics / Debug

| Keybinding      | Action                                                  |
| --------------- | ------------------------------------------------------- |
| `<leader>D`     | Show buffer diagnostics (Snacks picker)                 |
| `<leader>dd`    | Open floating diagnostic message                        |
| `<leader>df`    | Open floating diagnostic (same as dd — from LSP config) |
| `<leader>daptb` | DAP: Toggle breakpoint                                  |
| `<leader>dapb`  | DAP: Set conditional breakpoint                         |
| `[d`            | Go to previous diagnostic                               |
| `]d`            | Go to next diagnostic                                   |
| `<leader>q`     | Open diagnostics list (loclist)                         |

---

### `<leader>e` — Explorer

| Keybinding   | Action                          |
| ------------ | ------------------------------- |
| `<leader>ee` | Toggle mini.files explorer      |
| `<leader>ef` | Open mini.files at current file |
| `<leader>pe` | Snacks explorer picker          |
| `-`          | Oil: open parent directory      |
| `<leader>-`  | Oil: toggle float               |

---

### `<leader>f` — File

| Keybinding   | Action                              |
| ------------ | ----------------------------------- |
| `<leader>fp` | Copy current file path to clipboard |

---

### `<leader>g` — Git

| Keybinding    | Action                         |
| ------------- | ------------------------------ |
| `<leader>gn`  | Open Neogit                    |
| `<leader>lg`  | Open LazyGit (Snacks)          |
| `<leader>gl`  | LazyGit log view               |
| `<leader>gs`  | Stage hunk                     |
| `<leader>gr`  | Reset hunk                     |
| `<leader>gS`  | Stage entire buffer            |
| `<leader>gR`  | Reset entire buffer            |
| `<leader>gu`  | Undo stage hunk                |
| `<leader>gp`  | Preview hunk                   |
| `<leader>gbl` | Show full blame for line       |
| `<leader>gB`  | Toggle line blame (inline)     |
| `<leader>gdi` | Diff this (inline)             |
| `<leader>gD`  | Diff this ~                    |
| `<leader>gdo` | Open Diffview                  |
| `<leader>gdc` | Close Diffview                 |
| `<leader>gdh` | Diffview: current file history |
| `<leader>gdH` | Diffview: repo history         |
| `<leader>gbr` | Pick and switch git branch     |
| `<leader>gf`  | Fugitive fullscreen tab        |
| `]h`          | Next git hunk                  |
| `[h`          | Previous git hunk              |

---

### `<leader>h` — Harpoon

| Keybinding   | Action                           |
| ------------ | -------------------------------- |
| `<leader>ha` | Add current file to Harpoon list |
| `<leader>hh` | Open Harpoon quick menu          |
| `<leader>h1` | Jump to Harpoon file 1           |
| `<leader>h2` | Jump to Harpoon file 2           |
| `<leader>h3` | Jump to Harpoon file 3           |
| `<leader>h4` | Jump to Harpoon file 4           |
| `<leader>hp` | Harpoon: previous in list        |
| `<leader>hn` | Harpoon: next in list            |

> **Harpoon context:** Harpoon lets you bookmark up to 4 files and jump to them with a single keystroke. No more hunting through buffer lists for your most-used files. Mark your 4 most important files for the current task, then `<leader>h1` through `<leader>h4` to teleport between them.

---

### `<leader>H` — HTTP / REST

| Keybinding   | Action                    |
| ------------ | ------------------------- |
| `<leader>Hr` | Run HTTP request (kulala) |
| `<leader>Ha` | Run all HTTP requests     |
| `<leader>Hp` | Replay last request       |
| `<leader>Hi` | Inspect request           |
| `<leader>Hc` | Copy as cURL              |
| `<leader>HE` | Set environment           |
| `]r`         | Next request in file      |
| `[r`         | Previous request in file  |

---

### `<leader>l` — LSP / Lint

| Keybinding   | Action                                                       |
| ------------ | ------------------------------------------------------------ |
| `<leader>lo` | Toggle Aerial symbols outline                                |
| `<leader>lv` | Toggle LSP virtual text (inline errors)                      |
| `<leader>lx` | Toggle LSP diagnostics visibility (underline + virtual text) |
| `<leader>li` | Toggle inlay hints                                           |
| `<leader>lw` | Toggle line wrap                                             |
| `<leader>ls` | LSP signature help                                           |

---

### `<leader>m` — Make / Format

| Keybinding   | Action                                          |
| ------------ | ----------------------------------------------- |
| `<leader>mp` | Format current file or selection (conform.nvim) |

---

### `<leader>p` — Pick / Search

| Keybinding    | Action                                    |
| ------------- | ----------------------------------------- |
| `<leader>pf`  | Find files (Snacks picker)                |
| `<leader>pF`  | Smart picker (recent + frecency weighted) |
| `<leader>pb`  | Pick open buffers                         |
| `<leader>pr`  | Recent files                              |
| `<leader>pg`  | Grep project (live grep)                  |
| `<leader>pc`  | Commands picker                           |
| `<leader>pe`  | Explorer picker                           |
| `<leader>pws` | Grep word under cursor / visual selection |
| `<leader>pk`  | Search keymaps (ivy layout)               |

---

### `<leader>r` — Rename / Refactor

| Keybinding   | Action                                         |
| ------------ | ---------------------------------------------- |
| `<leader>rn` | Smart rename (LSP)                             |
| `<leader>rN` | Rename current file (Snacks — updates imports) |

---

### `<leader>s` — Splits / Session

| Keybinding   | Action                               |
| ------------ | ------------------------------------ |
| `<leader>sv` | Split window vertically              |
| `<leader>sh` | Split window horizontally            |
| `<leader>se` | Make all splits equal size           |
| `<leader>sx` | Close current split                  |
| `<leader>sm` | Toggle split zoom (maximize/restore) |
| `<leader>sn` | Save file without autoformat         |

---

### `<leader>t` — Tabs / Tests / Tasks

| Keybinding   | Action                         |
| ------------ | ------------------------------ |
| `<leader>to` | Open new tab                   |
| `<leader>tx` | Close current tab              |
| `<leader>tn` | Go to next tab                 |
| `<leader>tp` | Go to previous tab             |
| `<leader>tf` | Open current buffer in new tab |
| `<leader>tN` | Neotest: run nearest test      |
| `<leader>tF` | Neotest: run all tests in file |
| `<leader>tO` | Neotest: open output panel     |
| `<leader>tS` | Neotest: toggle summary panel  |

---

### `<leader>u` — UI / Toggles

_(This group is available for custom UI toggles — check which-key for current bindings)_

---

### `<leader>v` — View / Help

| Keybinding   | Action                     |
| ------------ | -------------------------- |
| `<leader>vh` | Help pages (Snacks picker) |

---

### `<leader>w` — Workspace / Session

_(Session management via auto-session — check `auto-session.lua` for bindings)_

---

### `<leader>x` — Trouble / Lists

| Keybinding   | Action                         |
| ------------ | ------------------------------ |
| `<leader>xw` | Trouble: workspace diagnostics |
| `<leader>xd` | Trouble: document diagnostics  |
| `<leader>xq` | Trouble: quickfix list         |
| `<leader>xl` | Trouble: location list         |
| `<leader>xt` | Trouble: TODO/FIXME list       |

---

### `<leader>y` — Yank

_(Yanky.nvim for enhanced clipboard — configured in `yanky.lua`. Provides yank history and paste cycling.)_

---

### `<leader>k` — Keys / Show

| Keybinding   | Action                                 |
| ------------ | -------------------------------------- |
| `<leader>pk` | Search all keymaps (Snacks ivy picker) |

---

### `<leader>n` — Clear

| Keybinding   | Action                  |
| ------------ | ----------------------- |
| `<leader>nh` | Clear search highlights |

---

### Non-leader Important Keybindings

These don't use the leader but are important to know:

| Keybinding           | Mode                    | Action                                  |
| -------------------- | ----------------------- | --------------------------------------- |
| `Ctrl+S`             | Normal, Insert, Command | Save current buffer                     |
| `Ctrl+Q`             | Normal                  | Quit                                    |
| `Ctrl+H`             | Normal                  | Focus left split                        |
| `Ctrl+J`             | Normal                  | Focus lower split                       |
| `Ctrl+K`             | Normal                  | Focus upper split                       |
| `Ctrl+L`             | Normal                  | Focus right split                       |
| `Ctrl+D`             | Normal                  | Scroll down half page (+ center)        |
| `Ctrl+U`             | Normal                  | Scroll up half page (+ center)          |
| `Ctrl+F`             | Normal                  | New tmux session via tmux-sessionizer   |
| `Tab`                | Normal                  | Next buffer                             |
| `Shift+Tab`          | Normal                  | Previous buffer                         |
| `n`                  | Normal                  | Next search result (+ center)           |
| `N`                  | Normal                  | Previous search result (+ center)       |
| `Up/Down/Left/Right` | Normal                  | Resize current split                    |
| `gd`                 | Normal (LSP)            | Go to definition                        |
| `gD`                 | Normal (LSP)            | Go to declaration                       |
| `gR`                 | Normal (LSP)            | Find references                         |
| `gi`                 | Normal (LSP)            | Go to implementation                    |
| `gt`                 | Normal (LSP)            | Go to type definition                   |
| `K`                  | Normal (LSP)            | Hover documentation                     |
| `Ctrl+O`             | Normal                  | Jump list back                          |
| `Ctrl+I`             | Normal                  | Jump list forward                       |
| `s`                  | Normal/Visual           | Flash jump                              |
| `S`                  | Normal/Visual           | Flash treesitter jump                   |
| `F5`                 | Normal                  | DAP: start/continue debug               |
| `F1`                 | Normal                  | DAP: step into                          |
| `F2`                 | Normal                  | DAP: step over                          |
| `F3`                 | Normal                  | DAP: step out                           |
| `F7`                 | Normal                  | DAP: toggle UI                          |
| `]a` / `[a`          | Normal                  | Aerial: next/prev symbol                |
| `]h` / `[h`          | Normal                  | Gitsigns: next/prev hunk                |
| `]d` / `[d`          | Normal                  | Next/prev diagnostic                    |
| `>` / `<`            | Visual                  | Indent/unindent (stays in visual)       |
| `J` / `K`            | Visual                  | Move selected lines down/up             |
| `x`                  | Normal                  | Delete char without copying to register |
| `Ctrl+C`             | Insert                  | Escape (back to Normal)                 |
| `-`                  | Normal                  | Oil: open parent directory              |

---

## 14. Exercises

These exercises are designed to build real fluency with the VSCode-equivalent workflows. Do them in order — each assumes completion of the previous.

---

### Exercise 1: The File Workflow (10 minutes)

**Goal:** Open, navigate, edit, and close files using Neovim's tools.

1. Open any project directory in Neovim
2. Press `<leader>pf` — the file picker opens. Type a few chars of a filename you know exists. Press `Enter` to open it.
3. Press `<leader>pb` — the buffer picker opens. You should see the file you just opened. Press `Esc` to close.
4. Press `<leader>pr` — recent files. Notice the history. Press `Esc`.
5. Press `<leader>pg` — live grep. Type a function name you know exists in the project. Press `Enter` to jump to it.
6. Press `Ctrl+O` to jump back to where you were before.
7. Press `<leader>bx` to close the current buffer.
8. Press `<leader>pb` again — notice the buffer is gone.

**Compare:** How does this feel vs. `Ctrl+P` in VSCode?

---

### Exercise 2: LSP Features (10 minutes)

**Goal:** Use code intelligence keybindings until they feel natural.

Open any TypeScript or JavaScript file (or your language of choice with LSP support).

1. Navigate your cursor to a function call
2. Press `K` — hover docs should appear
3. Press `gd` — jump to the definition
4. Press `Ctrl+O` — jump back
5. Press `gR` — all references should open in a Snacks picker
6. Press `Esc` to close the picker
7. Navigate to a variable with a type annotation
8. Press `gt` — go to type definition
9. Press `Ctrl+O` — back
10. Press `<leader>ca` — code actions should appear. Press `Esc` to cancel.
11. Press `<leader>xd` — Trouble document diagnostics. Navigate with `j/k`, press `Enter` to jump to an issue. Press `Esc` to close Trouble.

---

### Exercise 3: Git Hunk Workflow (10 minutes)

**Goal:** Stage changes at the hunk level (faster than staging entire files).

1. Open a file and make some changes (add a line, modify a line, delete a line — make them in different areas of the file)
2. Save with `Ctrl+S`
3. Navigate to the area where you made a change
4. Press `<leader>gp` — preview the hunk. You should see a diff popup.
5. Press `<leader>gs` — stage just that hunk
6. Navigate to another changed area
7. Press `<leader>gr` — reset (undo) that hunk, reverting just that change
8. Press `<leader>gn` — open Neogit. Verify the staged hunk is there.
9. Press `q` to close Neogit.
10. Press `<leader>lg` — open LazyGit. Explore for 2 minutes. Press `q` to close.

---

### Exercise 4: Split Workflow (5 minutes)

**Goal:** Use splits like a pro.

1. Open any file
2. Press `<leader>sv` — vertical split. Two windows now, both showing the same file.
3. Press `Ctrl+H` — focus the left window
4. Press `<leader>pf` and open a different file in this window
5. Now you have two different files side by side
6. Press `Ctrl+L` — focus right window
7. Press `<leader>sm` — maximize (zoom) this window
8. Press `<leader>sm` again — restore the split
9. Press `<leader>sx` — close the focused split
10. You're back to one window

---

### Exercise 5: The Complete VSCode-to-Neovim Translation Challenge (15 minutes)

For each of these VSCode actions, perform the Neovim equivalent without looking at the tables above. After you do each one, check your answer. This tests how much has sunk in.

1. "Open the Command Palette" → What's the Neovim keybinding?
2. "Format the current document with Prettier" → What key?
3. "See all errors in the current file" → What's the Trouble keybinding?
4. "Rename a symbol (refactor rename)" → What key?
5. "Toggle inline blame (like GitLens)" → What key?
6. "Jump to definition, then jump back" → What two keys?
7. "Open the file explorer at the current file's location" → What key?
8. "Select the next occurrence of the current word (like Ctrl+D)" → What key?
9. "Open a diff view of the current file's history" → What leader key combo?
10. "Toggle the symbols outline (like VSCode's Outline panel)" → What key?

_(Answers: `<leader>pc`, `<leader>mp`, `<leader>xd`, `<leader>rn`, `<leader>gB`, `gd` then `Ctrl+O`, `<leader>ef`, `<leader>cm`, `<leader>gdh`, `<leader>lo`)_

---

## What's Next

You now have a complete translation map from VSCode to this Neovim config. This file is your cheat sheet — come back to it whenever you're hunting for "how do I do X in Neovim?"

The next tutorials go deeper:

- **Tutorial 03:** Moving Like a Ninja — Flash.nvim, marks, text objects, advanced motions
- **Tutorial 04:** Editing Mastery — operators (`d/c/y`), the `.` repeat, macros, surround
- **Tutorial 05:** The Leader Key System — deep dive into every `<Space>` combination with use cases
- **Tutorial 06:** Files, Buffers, Windows, Tabs — mastering Oil, mini.files, Harpoon, session management
- **Tutorial 07:** LSP and Completions — Mason, language servers, blink.cmp, snippets
- **Tutorial 08:** Git Workflow — Neogit, Diffview, gitsigns, LazyGit together
- **Tutorial 09:** Debugging and Testing — DAP, neotest, language-specific setups

The path from "VSCode refugee" to "Neovim native" is measured in weeks, not months. You're already past the hardest part — you know how to survive, and you have the map.

---

## 15. Deep Dive: Understanding the Picker System

The Snacks.nvim picker is the engine behind most of the `<leader>p` bindings. It's worth understanding how it works because it's more powerful than a simple file search.

### Picker Layouts

The picker can appear in different layouts, and this config has custom layouts defined:

```
split_preview (default):
┌──────────────────────┬──────────────────────────────┐
│                      │                              │
│  Results list        │  Preview pane                │
│  (files / items)     │  (file content preview)      │
│                      │                              │
│  ┌──────────────┐    │                              │
│  │  search bar  │    │                              │
│  └──────────────┘    │                              │
└──────────────────────┴──────────────────────────────┘

ivy (compact, appears at bottom):
┌────────────────────────────────────────────────────┐
│ > search term...                                   │
├────────────────────────────────────────────────────┤
│ results...          │  preview...                  │
└─────────────────────┴──────────────────────────────┘

select (simple dropdown):
            ┌─────────────────────────────┐
            │  > search                   │
            │  ─────────────────────      │
            │  result 1                   │
            │  result 2                   │
            │  result 3                   │
            └─────────────────────────────┘
```

### Picker Navigation Keys

Once a picker is open:

| Key                | Action                                       |
| ------------------ | -------------------------------------------- |
| Type anything      | Fuzzy filter the list                        |
| `Ctrl+J` or `Down` | Move selection down                          |
| `Ctrl+K` or `Up`   | Move selection up                            |
| `Enter`            | Open the selected item                       |
| `Ctrl+V`           | Open in vertical split                       |
| `Ctrl+S`           | Open in horizontal split                     |
| `Ctrl+T`           | Open in new tab                              |
| `Esc`              | Close picker without selecting               |
| `Ctrl+C`           | Also close (since C-c is Esc in this config) |
| `Tab`              | Mark multiple items (for multi-open)         |

### Frecency Weighting

This config enables `frecency = true` in the picker settings. **Frecency** = frequency + recency. Files you open often AND recently float to the top of the results. This means `<leader>pf` gets smarter over time — after a week, the files you work with most are always near the top of the list.

> **💡 In VSCode you'd...** use `Ctrl+P` which also has some frecency weighting. The behavior is similar, but Snacks' frecency is configurable.

---

## 16. The Completion System (blink.cmp)

When you're in Insert mode and typing, completions appear automatically. This config uses **blink.cmp** for autocompletion. Understanding how to interact with it is essential.

> **💡 In VSCode you'd...** see IntelliSense popup automatically. Press `Tab` or `Enter` to accept. Press `Esc` to dismiss. Arrow keys to navigate. Completions come from the language extension.
>
> **In Neovim you...** see blink.cmp popup. It sources completions from LSP servers, snippets (LuaSnip), buffer text, and file paths.

### Completion Interaction

When the completion menu appears:

| Key          | Action                                |
| ------------ | ------------------------------------- |
| `Tab`        | Select next item / accept if only one |
| `Shift+Tab`  | Select previous item                  |
| `Enter`      | Accept current selection              |
| `Ctrl+Space` | Manually trigger completion           |
| `Ctrl+E`     | Close/dismiss completion menu         |
| `Ctrl+N`     | Next completion item                  |
| `Ctrl+P`     | Previous completion item              |

### Snippet Navigation

When you accept a snippet completion (e.g., a function template), the cursor lands in a "snippet tabstop". You can jump between tabstops with:

| Key         | Action                                 |
| ----------- | -------------------------------------- |
| `Tab`       | Jump to next tabstop                   |
| `Shift+Tab` | Jump to previous tabstop               |
| `Esc`       | Exit snippet, return to normal editing |

### Completion Sources

blink.cmp aggregates completions from multiple sources:

```
While you type "useS..." in a React component:

┌─────────────────────────────────────────────┐
│  [LSP]  useState          React hook        │  ← from vtsls/TypeScript LSP
│  [LSP]  useSelector       Redux hook        │  ← from LSP
│  [SNP]  useState snippet  Full boilerplate  │  ← from LuaSnip snippets
│  [BUF]  useStyles         from this file    │  ← from buffer text
│  [PTH]  ./useSearch       file path match   │  ← from path source
└─────────────────────────────────────────────┘
```

The source indicator (`[LSP]`, `[SNP]`, etc.) tells you where each completion comes from.

---

## 17. Working With the Terminal Inside Neovim

Neovim has a built-in terminal emulator. You can run shell commands without leaving the editor.

> **💡 In VSCode you'd...** press `` Ctrl+` `` to toggle the integrated terminal panel at the bottom. It's always available, always split below your code.
>
> **In Neovim you...** open terminals more explicitly. You have several options depending on the workflow.

### Terminal Options in This Config

**Option 1: The built-in :terminal command**

```vim
:terminal          " opens terminal in current window
:vs | terminal    " opens terminal in a vertical split
:sp | terminal    " opens terminal in horizontal split
```

**Option 2: Snacks terminal (if configured)**
Check the snacks.lua for any terminal bindings. The snacks terminal module can create floating terminals.

**Option 3: External tmux integration**
This config has `Ctrl+F` mapped to launch `tmux-sessionizer` — a script for quickly creating/switching tmux sessions:

```lua
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
```

This is the ThePrimeagen-style workflow: Neovim for editing, tmux for terminal management. Many experienced Neovim users prefer this over an integrated terminal.

### Navigating in the Terminal Buffer

When you open a terminal inside Neovim, it starts in **Terminal mode** (a special mode). To exit back to Normal mode from a Neovim terminal:

```
Ctrl+\ then Ctrl+N     ← standard Neovim terminal escape
```

Once in Normal mode within the terminal buffer, you can copy text, navigate with `hjkl`, etc. Press `i` or `a` to go back into terminal input mode.

### Terminal Mode Status Line

The status line shows `TERMINAL` when you're in terminal mode. This is your visual indicator that keypresses are going to the shell process, not Neovim commands.

---

## 18. The Snacks Dashboard

When you open Neovim without a file (`nvim` with no arguments), you see the Snacks dashboard. This config has it set up with:

```
╔══════════════════════════════════════════════════════╗
║                                                      ║
║             [NEOVIM ASCII HEADER ART]                ║
║                                                      ║
║    > Find File                    <leader>pf         ║
║    > Recent Files                 <leader>pr         ║
║    > Find Text                    <leader>pg         ║
║    > New File                     <leader>bo         ║
║    > Quit                         :q                 ║
║                                                      ║
║                 Startup: 45ms                        ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
```

The dashboard also (via the config) tries to show an ASCII art image from a profile photo using `ascii-image-converter`. If that tool isn't installed, that section just won't appear.

The startup time shown in the dashboard is real — it's how long Neovim took to initialize. This config typically starts in under 100ms thanks to aggressive lazy loading.

---

## 19. Linting vs Formatting — What's the Difference?

This confuses a lot of people coming from VSCode, where ESLint + Prettier are often treated as one thing.

> **💡 In VSCode you'd...** install ESLint extension (linting) + Prettier extension (formatting). They do different jobs but both affect how your code looks and whether it has errors.

**Formatting** = making code look consistent (indentation, line length, quote style, trailing commas). Does NOT catch logical errors. Examples: Prettier, stylua, gofumpt.

**Linting** = static analysis for bugs and code quality issues (unused variables, wrong types, security issues, style violations). Does NOT format code. Examples: ESLint, ruff, clippy.

### How This Config Handles Each

**Formatting** → `conform.nvim` (`formatting.lua`)

- Runs automatically after each save (`format_after_save`)
- Uses the best available formatter for each filetype
- For JS/TS: tries `biome-check`, then `prettierd`, then `prettier` (first available wins)
- Manual trigger: `<leader>mp`

**Linting** → `nvim-lint` (`linting.lua`)

- Runs on save and other events
- Integrates with the LSP diagnostic system
- Errors/warnings appear as virtual text and in Trouble

**LSP diagnostics** → the language server itself (via Mason)

- TypeScript errors from `vtsls`
- Python errors from `pyright` + `ruff`
- Go errors from `gopls`
- These are "live" — update as you type

The three layers work together. The LSP gives you real-time type errors. The linter gives you style/quality warnings on save. The formatter fixes presentation on save.

---

## 20. Snippets — LuaSnip

Snippets are pre-written code templates that expand from a short trigger. You've probably used them in VSCode — type `for` and Tab expands it into a for loop template.

This config uses **LuaSnip** with a library of snippet files in:

```
dotfiles/.config/nvim/snippets/
```

Custom snippets exist for: TypeScript, JavaScript, Lua, Python, Go, Rust, C, shell scripts, and a universal `all.lua` for snippets that work in every filetype.

> **💡 In VSCode you'd...** use snippets via the built-in snippet engine or extensions like `friendly-snippets`. Type a prefix and press `Tab` to expand.
>
> **In Neovim you...** use LuaSnip + blink.cmp integration. Snippets appear in the completion menu with a `[SNP]` indicator. Accept them the same way as other completions (`Tab` or `Enter`). Then `Tab` to jump between placeholder positions within the snippet.

### Writing Custom Snippets

You can add your own snippets to the appropriate file in `snippets/`. Example format (from `typescript.lua`):

```lua
ls.add_snippets("typescript", {
  s("comp", {  -- trigger: "comp"
    t("const "), i(1, "ComponentName"), t([[ = () => {
  return (
    <div>
      ]]), i(2, "content"), t([[
    </div>
  );
};
export default ]]), rep(1),  -- repeats the component name
  }),
})
```

LuaSnip snippets are Lua code — you can make them as smart as you want, with dynamic placeholders, conditional parts, and transformations.

---

## 21. The Auto-Pairs System

This config uses a combination of auto-pairing features so that when you type `(`, the editor automatically inserts `)` and positions your cursor in the middle. Same for `[`, `{`, `"`, `'`, `` ` ``, `<`.

The `auto-pairs.lua` plugin handles this. It's similar to VSCode's built-in bracket completion.

> **💡 In VSCode you'd...** type `(` and automatically get `()` with cursor inside. This is VSCode's built-in "Auto Closing Brackets" feature.
>
> **In Neovim you...** get the same behavior from the auto-pairs plugin. It's so seamless you won't notice it's a separate plugin.

**Smart pairs behavior:**

- Type `(` → gets `()`, cursor inside
- Type `"` in a string → closes the string
- Press Backspace on an empty pair `()` → deletes both characters
- `nvim-ts-autotag` (in `languages.lua`) also handles HTML/JSX tag auto-closing and renaming

---

## 22. Working With Multiple Files: The Full Workflow

Let's walk through a realistic multi-file workflow to see how all the pieces fit together.

**Scenario:** You need to add a new feature to a React component, update its types file, add a test, and commit the changes.

```
1. Open the project
   nvim .           ← opens oil.nvim in current dir
   OR
   nvim             ← opens dashboard, then <leader>pf

2. Find the component file
   <leader>pf       ← file picker
   Type: "button"   ← fuzzy matches ButtonComponent.tsx
   Enter            ← opens it

3. Harpoon it (you'll be back here)
   <leader>ha       ← add to Harpoon slot 1

4. Open the types file
   <leader>pf       ← file picker again
   Type: "types"    ← finds types.ts
   Enter

5. Harpoon it
   <leader>ha       ← add to Harpoon slot 2

6. Open the test file
   <leader>pf → "button.test" → Enter
   <leader>ha       ← Harpoon slot 3

7. Now you have 3 files instantly accessible:
   <leader>h1       ← jump to ButtonComponent.tsx
   <leader>h2       ← jump to types.ts
   <leader>h3       ← jump to button.test.tsx

   No searching, no scrolling — instant teleportation.

8. Make your changes across all 3 files

9. Stage changes hunk by hunk
   <leader>gs       ← stage the hunk you're on

10. Open Neogit to review and commit
    <leader>gn      ← Neogit opens
    c → cc          ← commit
    Type message
    <leader>gP      ← push (or use LazyGit: <leader>lg)
```

This workflow is faster than the equivalent VSCode workflow because:

- No mouse (opens files faster)
- Harpoon (4 files instantly accessible instead of scanning tab bar)
- Hunk-level staging (precise commits without leaving the editor)
- Neogit inline (no context switch to a different app)

---

## 23. When Things Don't Work: Diagnostics and Debugging Your Config

Sometimes a plugin stops working or a LSP server doesn't start. Here's how to diagnose issues.

### Check What LSP Servers Are Running

```vim
:LspInfo           " shows LSP servers attached to current buffer
:Mason             " opens Mason UI — see what's installed
:MasonUpdate       " update all installed Mason packages
```

### Check Plugin Status

```vim
:Lazy              " opens lazy.nvim UI
:Lazy health       " runs health checks on all plugins
:checkhealth       " comprehensive Neovim health check
```

The `:checkhealth` command is your first stop for any "why isn't X working" question. It checks:

- Provider health (Python, Node.js, Ruby)
- Plugin health
- LSP server status
- Performance issues

### Common Fixes

**"LSP not working on my file"**

1. `:LspInfo` — is a server attached? If not, check Mason has the server installed.
2. `:Mason` — find the server, install if missing.
3. `:e` the file again — sometimes LSP attaches late.

**"Formatter not running on save"**

1. `<leader>mp` to manually format — does it work?
2. `:ConformInfo` — check what formatters are configured for this filetype.
3. Check Mason has the formatter installed (prettierd, stylua, etc.).

**"Plugin keybinding not working"**

1. `<leader>pk` or `:Telescope keymaps` — search for the keybinding to verify it's registered.
2. `:Lazy` — is the plugin loaded? (Check if it's lazy-loaded and hasn't triggered yet)
3. Check the plugin spec for `enabled = false` flags (some are feature-flagged with env vars).

**"Neovim is slow"**

1. `:Lazy profile` — shows startup time breakdown per plugin
2. Check for synchronous operations in plugins on large files
3. Treesitter can be slow on huge files — `:TSBufDisable highlight` to disable for a buffer

---

## 24. Keyboard Shortcuts That Work Everywhere

Some shortcuts work across all modes and contexts. These are your universal tools:

| Shortcut            | Works In                | Action                          |
| ------------------- | ----------------------- | ------------------------------- |
| `Ctrl+S`            | Normal, Insert, Command | Save file                       |
| `Ctrl+C`            | Insert mode             | Escape to Normal                |
| `Ctrl+[`            | Insert mode             | Escape to Normal (Vim standard) |
| `Esc`               | All modes               | Return to Normal / cancel       |
| `Ctrl+\` + `Ctrl+N` | Terminal mode           | Exit terminal, return to Normal |

### The `Ctrl+C` Warning

`Ctrl+C` in Normal mode (not Insert mode) sends an interrupt signal — in Neovim it typically just acts like Escape. But be careful: in some contexts (long-running operations, file watchers) it can interrupt a process. The safe universal escape is `Esc`.

---

## 25. The VSCode Remote Development Comparison

VSCode has Remote SSH as a first-class feature — open a remote folder, and VSCode runs locally but your files are on the server. This config has an equivalent.

> **💡 In VSCode you'd...** use the "Remote - SSH" extension. It seamlessly opens remote directories, runs language servers on the remote, and everything feels local.
>
> **In Neovim you...** have `remote-nvim.nvim` (`remote-nvim.lua`). It installs a Neovim server on the remote host and connects to it, giving you full LSP and plugin support on remote files. `:RemoteStart` to connect.

**Alternative approach many prefer:** Use SSH to connect to a remote server, then run Neovim directly on the remote in a tmux session. This is simpler (Neovim runs natively on the server), and combined with `tmux attach` you can detach and reattach to your remote editing session from any machine.

---

## 26. Language-Specific Feature Reference

Different languages have different LSP servers and capabilities. Here's what to expect for the most common languages in this config.

### TypeScript / JavaScript

**LSP Server:** `vtsls` (a faster, more capable TypeScript server than `typescript-language-server`)
**Formatter:** `biome` (first), then `prettierd`, then `prettier`
**Linter:** `eslint_d`

Enabled features:

- Full type checking and inference
- Auto-imports
- Organize imports (via `<leader>ca` → organize imports)
- Inlay hints: parameter names, return types, variable types (toggle with `<leader>li`)
- JSX/TSX auto-tag closing/renaming (nvim-ts-autotag)
- Tailwind CSS class completions (tailwindcss LSP)
- Emmet expansion for JSX (emmet_language_server)

**Workflow note:** The inlay hints for TypeScript are rich — you'll see parameter names inline, inferred types, and more. However they're off by default due to the Neovim 0.12 bug. Toggle with `<leader>li` when you want them.

### Go

**LSP Server:** `gopls`
**Formatter:** `goimports` + `gofumpt`
**Debug:** `delve` via `nvim-dap-go`

Enabled inlay hints: parameter names, return types, composite literal types, range variable types. Go's inlay hints are particularly useful since Go has type inference but you often want to see what types are inferred.

### Python

**LSP Server:** `pyright` (type checking) + `ruff` (linting)
**Formatter:** `ruff_format` + `ruff_organize_imports` (if ruff available), else `isort` + `black`
**Debug:** `debugpy`

The dual LSP setup (pyright for types + ruff for linting) gives you excellent Python support comparable to the Pylance extension in VSCode.

### Rust

**LSP Server:** `rust-analyzer` (install via Mason)
**Formatter:** `rustfmt`
**Debug:** `codelldb`

Rust's LSP has excellent inlay hints — essentially every inferred type is shown inline. Very useful given Rust's complex type system.

### C / C++

**LSP Server:** `clangd`
**Formatter:** `clang_format`
**Debug:** `codelldb`

Requires a `compile_commands.json` or `.clangd` config at project root for best results. CMake and bear can generate this.

### Lua (Neovim configuration itself)

**LSP Server:** `lua_ls` (configured to know about `vim` global)
**Formatter:** `stylua`

The Lua LSP is configured with knowledge of the Neovim API, so you get full completion and documentation for `vim.*` functions when editing your own config. Meta!

---

## 27. Keybinding Conflicts and How to Resolve Them

As your config grows, you'll occasionally hit keybinding conflicts. Here's how to diagnose and fix them.

### Finding What a Key Is Mapped To

```vim
:verbose nmap <leader>x     " show what <leader>x does in normal mode
:verbose imap <C-a>         " show what Ctrl+A does in insert mode
:Snacks picker keymaps      " search all keymaps visually
<leader>pk                  " same as above
```

The `:verbose` prefix tells you not just what the mapping is, but WHERE it was defined (which file and line number).

### Understanding Mapping Modes

Vim has multiple modes and a mapping only applies in the modes it was registered for:

| Mode prefix     | Applies in                         |
| --------------- | ---------------------------------- |
| `n`             | Normal mode                        |
| `i`             | Insert mode                        |
| `v`             | Visual mode (and select)           |
| `x`             | Visual mode only (not select)      |
| `o`             | Operator-pending mode              |
| `c`             | Command-line mode                  |
| `t`             | Terminal mode                      |
| `nv` or `{n,v}` | Multiple modes                     |
| (none / `map`)  | Normal + visual + operator-pending |

So `nmap <C-s>` only affects Normal mode. `imap <C-s>` only Insert mode. This is why some keybindings work in one mode but not another.

### Plugin Keymap Precedence

When a plugin maps a key and you also map the same key in your config, the last mapping wins. In lazy.nvim, plugin key specs are loaded before your personal keymaps (since core/keymaps.lua loads during init). So your personal mappings in `keymaps.lua` override plugin defaults.

If you want to disable a specific plugin-default mapping, set it to `false` in the plugin's `keys` table:

```lua
keys = {
  { "<C-h>", false },  -- disable the default Ctrl+H mapping from this plugin
}
```

---

## 28. The Macro System

Macros are another feature that has no real VSCode equivalent but is extremely powerful once you know it.

A macro is a **recorded sequence of keystrokes** that you can replay. Think of it as a keyboard shortcut you define on the fly, right in the editor, for exactly the transformation you need right now.

> **💡 In VSCode you'd...** not have an equivalent for in-editor macro recording. You might write a regex Find+Replace, or use the Macro Recorder extension. Neovim's macros are built-in and instant.

### Recording and Replaying Macros

```
qa      " start recording macro into register 'a'
        " (do your operations — any sequence of normal/insert/etc. mode commands)
q       " stop recording

@a      " replay macro stored in 'a'
@@      " replay last-used macro
5@a     " replay macro 'a' five times
```

### Example: Converting a JSON Array to a TypeScript Interface

Given:

```json
"firstName": "string",
"lastName": "string",
"age": "number",
```

Goal — transform each line to:

```typescript
firstName: string;
lastName: string;
age: number;
```

**Macro approach:**

1. Position cursor on first line: `"firstName": "string",`
2. `qa` — start recording into register 'a'
3. `0` — go to start of line
4. `f"` — jump to the first quote
5. `x` — delete the quote
6. `f:` — jump to the colon
7. `f"` — jump to the space+quote after colon
8. `2x` — delete ` "`
9. `$` — go to end of line
10. `F"` — jump back to the last quote
11. `x` — delete it
12. `F,` — find the comma
13. `r;` — replace comma with semicolon
14. `j` — move to next line
15. `q` — stop recording

Now: `2@a` to apply to the next 2 lines. Done.

Macros shine for repetitive structural transformations that don't fit a simple regex.

---

## 29. Understanding Lazy.nvim: Managing Your Plugins

The plugin manager is lazy.nvim. Here's the full reference for managing it.

### The Lazy UI

```vim
:Lazy              " open the Lazy UI
:Lazy sync         " install new plugins, update, clean removed ones
:Lazy update       " update all plugins
:Lazy install      " install any missing plugins
:Lazy clean        " remove unused plugins
:Lazy restore      " restore plugins to lazy-lock.json versions (pinned versions)
:Lazy profile      " show startup time breakdown
:Lazy log          " recent plugin update log
:Lazy health       " health checks for lazy + plugins
```

The UI is self-explanatory: `j/k` to navigate, `Enter` to expand, `u` to update a specific plugin.

### The lazy-lock.json File

The `lazy-lock.json` file in your config directory pins every plugin to a specific commit. This means your config is **reproducible** — if a plugin update breaks something, you can restore to the last known good state with `:Lazy restore`.

**Workflow for updating:**

1. `:Lazy update` — update all plugins
2. Test that everything works
3. If something breaks: `:Lazy restore` to roll back
4. Find the breaking plugin, pin it to an older version if needed

The `lazy-lock.json` in this repo is tracked with git, so you can always see what changed between sessions with `git diff lazy-lock.json`.

### Adding a New Plugin

To add a new plugin, create a new file in `dotfiles/.config/nvim/lua/de100/plugins/` or add to an existing one:

```lua
return {
  "author/plugin-name",
  event = "VeryLazy",     -- when to load
  keys = {
    { "<leader>xx", "<cmd>SomeCommand<CR>", desc = "Do something" }
  },
  opts = {
    -- plugin options
  }
}
```

Then `:Lazy sync` to install it.

### Lazy Loading Events

Lazy loading means a plugin doesn't load until it's needed. Common trigger events:

| Event               | When it fires                             |
| ------------------- | ----------------------------------------- |
| `BufReadPre`        | Before reading any file                   |
| `BufReadPost`       | After reading any file                    |
| `BufNewFile`        | When creating a new file                  |
| `VeryLazy`          | After the initial UI is loaded (deferred) |
| `InsertEnter`       | When entering Insert mode the first time  |
| `CmdlineEnter`      | When entering command line                |
| `ft = "typescript"` | When a TypeScript file is opened          |

Using `keys = { ... }` without an event means the plugin loads the first time that key is pressed.

---

## 30. Searching and Navigation: The Full Arsenal

Let's go beyond basic `/` search. Here's the complete navigation toolkit.

### In-File Search

| Command      | Action                                       |
| ------------ | -------------------------------------------- |
| `/pattern`   | Search forward                               |
| `?pattern`   | Search backward                              |
| `n`          | Next match (+ centers screen in this config) |
| `N`          | Previous match                               |
| `*`          | Search for word under cursor (forward)       |
| `#`          | Search for word under cursor (backward)      |
| `g*`         | Like `*` but without word boundary           |
| `<leader>nh` | Clear search highlights                      |

### Flash.nvim: Jump Anywhere

> **💡 In VSCode you'd...** use the `easymotion` extension or similar. Or just click.
>
> **In Neovim (this config) you...** press `s` in Normal mode and type 1-2 characters of your target. Flash labels all visible matches with unique letter hints. Type the hint to jump instantly. No mouse, no arrow navigation.

Flash usage:

1. Press `s`
2. Type the first 1-2 characters you see at your target
3. Flash highlights all matches with letters (`a`, `b`, `c`, etc.)
4. Type the letter next to where you want to jump
5. Cursor teleports there

This is faster than mouse clicks for targets visible on screen.

`S` (capital S) does Flash Treesitter — jumps to tree-sitter syntax nodes.

### Snacks Picker Grep: Finding Across Files

`<leader>pg` opens a live grep that searches all project files as you type. It respects `.gitignore` automatically. This is the Neovim equivalent of VSCode's `Ctrl+Shift+F`.

`<leader>pws` runs grep with the word currently under your cursor as the search term — no need to type the function name, just hover over it and search.

### Going to Line Numbers

```vim
:42         " jump to line 42
42G         " also jump to line 42
42gg        " also line 42
```

In the Snacks picker, many pickers support `filename:linenumber` syntax: type `Button:42` in the file picker to open Button.tsx at line 42.

---

## 31. The Surrounding System: mini.surround

Working with surrounding characters (parentheses, quotes, brackets, HTML tags) is a daily task. mini.surround makes it effortless.

> **💡 In VSCode you'd...** manually navigate to the opening character, delete it, navigate to the closing character, delete it. Or use a Surround extension.
>
> **In Neovim (this config) you...** use mini.surround for instant surrounding operations with the `s` prefix (when not in a motion context).

| Command            | Action                 | Example                                |
| ------------------ | ---------------------- | -------------------------------------- |
| `sa{motion}{char}` | Add surrounding        | `saiwb` → surround word with `()`      |
| `ds{char}`         | Delete surrounding     | `ds"` → remove `"` from `"hello"`      |
| `ca{old}{new}`     | Change surrounding     | `ca'"` → change `'hello'` to `"hello"` |
| `sf{char}`         | Find surrounding right |                                        |
| `sF{char}`         | Find surrounding left  |                                        |
| `sh{char}`         | Highlight surrounding  |                                        |

**Character mappings for surround:**

| Char       | What it means        |
| ---------- | -------------------- |
| `b` or `(` | `( )` parentheses    |
| `B` or `{` | `{ }` braces         |
| `r` or `[` | `[ ]` brackets       |
| `'`        | `' '` single quotes  |
| `"`        | `" "` double quotes  |
| `` ` ``    | `` ` ` `` backticks  |
| `t`        | HTML tag             |
| `>`        | `< >` angle brackets |

**Examples:**

- Cursor inside `hello`: `sa iw"` → `"hello"` (add double quotes around word)
- Cursor inside `"world"`: `ds"` → `world` (delete surrounding double quotes)
- Cursor inside `'text'`: `ca'"` → `"text"` (change single to double quotes)
- Cursor inside `<p>content</p>`: `dst` → `content` (delete HTML tag)

---

## 32. The Session System

One of the underrated features for VSCode users is automatic session restoration. When you open Neovim in a project directory, it remembers your open files, window layouts, and cursor positions from last time.

> **💡 In VSCode you'd...** rely on VSCode automatically reopening your last workspace and files. This is mostly automatic.
>
> **In Neovim you...** use `auto-session.nvim` (configured in `auto-session.lua`). Sessions are saved per directory. When you `cd ~/projects/my-app && nvim`, it restores exactly where you left off.

The session stores:

- Open buffers
- Window/split layout
- Cursor positions in each buffer
- Current working directory
- Folds (if configured)

### Session Commands

Check `auto-session.lua` for the specific keybindings, but common auto-session commands:

```vim
:SessionSave         " manually save current session
:SessionRestore      " manually restore session
:SessionDelete       " delete the saved session for current directory
:Autosession search  " search through all saved sessions (via Telescope)
```

The session is automatically saved when you quit (`ZZ`, `:wq`, etc.) and automatically restored when you open Neovim in that directory.

---

## 33. Color and Theme Deep Dive

The visual environment matters for a tool you'll spend hours in every day. Let's cover everything about themes in this config.

### Changing the Theme

```
<leader>th    " opens Snacks colorscheme picker — live preview!
```

As you navigate the picker, the colorscheme applies in real-time so you can see it on your actual code. Press Enter to confirm, Esc to revert.

### The Current Theme System

The active theme is stored in:

```
dotfiles/.config/nvim/lua/current-theme.lua
```

This file is loaded by the config to apply your chosen theme on startup. It's a simple Lua file:

```lua
return "rose-pine"  -- or whatever theme you picked
```

### Available Themes in This Config

The `colorscheme.lua` plugin file includes several themes configured and ready to use. You can add more by installing colorscheme plugins.

### Rose-Pine (The Default)

The default theme is Rose-Pine (main variant). It's configured with custom highlight groups in `colorscheme.lua`:

```lua
ColorColumn = { bg = "#1C1C21" },   -- column guide color
NormalFloat = { bg = "#1C1C21" },   -- floating window background
Pmenu = { bg = "#191724" },         -- completion menu background
```

These tweaks make the UI feel cohesive — floating windows and the completion menu blend with the overall theme.

### Dark/Light Mode

Rose-Pine has:

- `main` — dark with warm rose tones
- `moon` — darker, cooler variation
- `dawn` — light mode

Switch between them by updating `variant = "main"` in `colorscheme.lua`.

---

## 34. The Noice.nvim UI Enhancement

This config includes **noice.nvim** which upgrades several Neovim UI elements:

> **💡 In VSCode you'd...** have a polished UI by default — command palette looks nice, notifications are in the corner, the search bar is styled.
>
> **In Neovim (default) you'd...** have a fairly plain command line at the bottom and basic messages. With noice.nvim, you get...

**What Noice does:**

- Moves the command line (`/`, `:`) into a beautiful centered floating window
- Shows completion documentation in styled floating windows
- Provides notification popups in the corner instead of the command line
- Makes `vim.notify()` messages appear as styled toasts
- Shows macro recording indicator in a styled popup

The result is a significantly more polished visual experience. If noice causes issues with a specific plugin, check `noice.lua` for how to configure exclusions.

---

## 35. Folding: Hiding Code You Don't Need

Code folding lets you collapse sections of code to reduce visual noise.

> **💡 In VSCode you'd...** click the triangle/arrow in the gutter to fold/unfold a function, class, or block. `Ctrl+K Ctrl+0` folds all, `Ctrl+K Ctrl+J` unfolds all.
>
> **In Neovim you...** use fold commands. This config uses **nvim-ufo** for better folding (with LSP and treesitter-based fold regions).

| Command | Action                          |
| ------- | ------------------------------- |
| `zc`    | Close (fold) current fold       |
| `zo`    | Open (unfold) current fold      |
| `za`    | Toggle fold under cursor        |
| `zC`    | Close all folds in current tree |
| `zO`    | Open all folds in current tree  |
| `zM`    | Close ALL folds in buffer       |
| `zR`    | Open ALL folds in buffer        |
| `zj`    | Move to next fold               |
| `zk`    | Move to previous fold           |

With nvim-ufo (configured in `nvim-ufo.lua`), folding is powered by LSP and treesitter, so fold regions correspond to actual code structures (functions, classes, blocks) rather than just indentation.

---

## 36. HTTP REST Client Workflow (kulala.nvim)

For anyone who used Thunder Client or REST Client in VSCode, this config has a full replacement.

> **💡 In VSCode you'd...** use the Thunder Client sidebar (or REST Client extension with `.http` files) to send HTTP requests.
>
> **In Neovim you...** create `.http` files and use kulala.nvim. The `.http` file format is the same as VSCode's REST Client — so if you have existing `.http` files, they work immediately.

### Creating an HTTP File

Create a file `requests.http`:

```http
### Get users
GET https://api.example.com/users
Authorization: Bearer {{$env TOKEN}}
Accept: application/json

###

### Create user
POST https://api.example.com/users
Content-Type: application/json

{
  "name": "Alice",
  "email": "alice@example.com"
}
```

### kulala.nvim Keybindings (from kulala.lua)

| Key          | Action                           |
| ------------ | -------------------------------- |
| `<leader>Hr` | Run request under cursor         |
| `<leader>Ha` | Run all requests in file         |
| `<leader>Hp` | Replay last request              |
| `<leader>Hi` | Inspect current request          |
| `<leader>Hc` | Copy request as cURL command     |
| `<leader>HE` | Set active environment           |
| `]r`         | Jump to next request in file     |
| `[r`         | Jump to previous request in file |

### Environment Variables

kulala supports environment files (`.env` or `.env.dev`) for per-environment variables:

```
# .env.dev
TOKEN=my-dev-token
BASE_URL=https://api.dev.example.com
```

Then in your `.http` file: `GET {{$env BASE_URL}}/users`

---

## 37. Database Workflow (dadbod-ui)

For SQL database work, this config has vim-dadbod-ui — a full database UI inside Neovim.

> **💡 In VSCode you'd...** use SQLTools extension (with a connection sidebar, query editor, result table) or DBeaver as a separate app.
>
> **In Neovim you...** use vim-dadbod-ui which provides a similar sidebar-style interface for databases.

Setting up a database connection: `:DBUI` opens the interface. From there you add connection strings, browse tables, run queries, and see results.

Supported databases: PostgreSQL, MySQL, SQLite, MongoDB, Redis, and more via connection URL.

Check `dadbod-ui.lua` for the specific keybindings configured in this setup.

---

## 38. The Incline Status Line: Per-Window File Names

This config includes **incline.nvim** which shows the current filename in the top-right corner of each window. This is particularly useful when you have multiple splits open and want to know at a glance which file is in each window.

> **💡 In VSCode you'd...** see the file name in the tab at the top of each split editor.
>
> **In Neovim you...** see the filename (with git status) floating at the top-right of each window via incline.

It shows:

- File name with icon
- `[+]` for modified buffers
- Git status indicators

---

## 39. Todo Comments Integration

The `todo-comments.nvim` plugin (integrated with Trouble) highlights specific comment patterns throughout your codebase:

| Pattern  | Color  | Use For               |
| -------- | ------ | --------------------- |
| `TODO:`  | Yellow | Things to implement   |
| `FIXME:` | Red    | Bugs to fix           |
| `HACK:`  | Orange | Temporary workarounds |
| `NOTE:`  | Blue   | Important information |
| `WARN:`  | Orange | Warnings              |
| `PERF:`  | Purple | Performance issues    |
| `TEST:`  | Green  | Test-related notes    |

You've probably noticed these already in the config files themselves! For example in `lsp/lsp.lua`:

```lua
-- Inlay hints are off by default due to a Neovim 0.12.2 bug where
-- LSP servers returning end-of-line hint positions crash the extmark
-- renderer. Toggle on/off with <leader>li when needed.
```

And in `snacks.lua`:

```lua
-- HACK: read picker docs @ https://...
-- NOTE: Options
```

Press `<leader>xt` to see ALL todo comments in the current project via Trouble. You can navigate between them, jump to each location, and track your technical debt systematically.

---

## 40. Reference: VSCode Keyboard Shortcut Cheat Sheet vs Neovim

For those who want a single lookup table covering the most-used VSCode shortcuts:

```
╔═══════════════════════════════════════════════════════════════════════╗
║           VSCODE → NEOVIM MASTER TRANSLATION TABLE                   ║
╠═══════════════════════════════════════╦═══════════════════════════════╣
║  VSCODE                               ║  NEOVIM (this config)         ║
╠═══════════════════════════════════════╬═══════════════════════════════╣
║  Ctrl+P       — Go to file            ║  <leader>pf                   ║
║  Ctrl+Shift+P — Command palette       ║  <leader>pc                   ║
║  Ctrl+Shift+F — Find in files         ║  <leader>pg                   ║
║  Ctrl+H       — Find + replace        ║  :%s/old/new/gc               ║
║  Ctrl+F       — Find in file          ║  /pattern                     ║
║  Ctrl+G       — Go to line            ║  :42 or 42G                   ║
║  Ctrl+Shift+O — Go to symbol          ║  <leader>lo (aerial)          ║
║  Ctrl+O       — Open file             ║  :e path or <leader>pf        ║
║  Ctrl+S       — Save                  ║  Ctrl+S or :w                 ║
║  Ctrl+Z       — Undo                  ║  u                            ║
║  Ctrl+Y       — Redo                  ║  Ctrl+R                       ║
║  Ctrl+D       — Select next occ.      ║  <leader>cm                   ║
║  Ctrl+Shift+L — Select all occ.       ║  <leader>cM                   ║
║  F12          — Go to definition      ║  gd                           ║
║  Shift+F12    — Find all references   ║  gR                           ║
║  Ctrl+F12     — Go to impl.           ║  gi                           ║
║  F2           — Rename symbol         ║  <leader>rn                   ║
║  Ctrl+.       — Code actions          ║  <leader>ca                   ║
║  F9           — Toggle breakpoint     ║  <leader>daptb                  ║
║  F5           — Start/continue debug  ║  F5                           ║
║  F10          — Step over             ║  F2                           ║
║  F11          — Step into             ║  F1                           ║
║  Shift+F11    — Step out              ║  F3                           ║
║  Shift+Alt+F  — Format document       ║  <leader>mp                   ║
║  Ctrl+Shift+G — Source control        ║  <leader>gn (neogit)          ║
║  Ctrl+Shift+E — File explorer         ║  <leader>ee or -              ║
║  Ctrl+\       — Split right           ║  <leader>sv                   ║
║  Ctrl+K Ctrl+S — Keyboard shortcuts   ║  <leader>pk                   ║
║  Ctrl+K Ctrl+T — Change theme         ║  <leader>th                   ║
║  Ctrl+`       — Toggle terminal       ║  :terminal or Ctrl+F          ║
║  Alt+Left     — Jump back             ║  Ctrl+O                       ║
║  Alt+Right    — Jump forward          ║  Ctrl+I                       ║
║  Ctrl+Tab     — Next tab              ║  Tab                          ║
║  Ctrl+W       — Close tab             ║  <leader>bx                   ║
║  Ctrl+K Ctrl+W — Close all            ║  :bufdo bd                    ║
║  Hover        — Show docs             ║  K                            ║
╚═══════════════════════════════════════╩═══════════════════════════════╝
```

---

_"A week into Neovim you'll wonder how you ever worked without it. A month in, you'll try VSCode at someone else's computer and feel like you're coding with oven mitts."_
