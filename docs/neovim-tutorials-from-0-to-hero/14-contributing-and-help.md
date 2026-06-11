# 14 · Contributing and Getting Help

> **Series:** Neovim 0 to Hero
> **Difficulty:** All levels — most useful after you've spent a few days with the config
> **Time:** ~60 minutes to read + exercises
> **Goal:** Know exactly where to look when something breaks, how to fix it yourself, and how to give back to the ecosystem

---

You made it to tutorial 14. That means you've survived Day One, learned modal editing, wired up LSP, configured DAP, tamed Treesitter, and probably broken your config at least three times in the process. Welcome to the club — every serious Neovim user has a folder of half-baked experiments and a git log full of "fix: why is this broken again" commits.

This final tutorial is about something different. It's about being _self-sufficient_. It's about knowing what to do at 11pm when a plugin update breaks your workflow and you can't open your editor. It's about understanding the feedback loops built into this config, and it's about learning how to contribute back — whether that means fixing a typo in this tutorial series, improving a plugin config, or helping someone else on Reddit who's stuck on the same problem you just solved.

Neovim's superpower isn't just that it's fast and customizable. It's that it has an extraordinarily generous community of people who document, maintain, and explain things at a depth that no commercial editor has ever matched. Once you know how to tap into that community — and how to use the diagnostic tools built into Neovim itself — you'll never feel stranded.

Let's build that foundation.

---

## 1. You're Not Alone — The Neovim Ecosystem

Before we get into commands, let's talk about why getting help in Neovim is genuinely _good_ compared to VSCode — not just "adequate."

In VSCode, when something breaks, your options are roughly: Google the error, check the extension's GitHub issues, or post on Stack Overflow and wait. The extension system is a black box — you click a button, something installs, and you hope. The settings UI hides the actual JSON. The docs are often out of date relative to the extension version.

In Neovim, every single piece of the system is either built into the editor with a `:help` page, or it's a Lua file you can read and modify directly. The plugin ecosystem is overwhelmingly open source on GitHub, and maintainers are often actively reading their issue trackers. The community spaces (r/neovim, GitHub Discussions, Discord servers) are full of people who understand the entire stack from the terminal emulator up to the Lua config file.

This config — the one this tutorial series accompanies — is built on that philosophy. It's organized into small, discoverable plugin files. It has a tutorial system (which you're reading right now) that links back from code comments to documentation. It uses standard tools (lazy.nvim, Mason, Treesitter) that have their own excellent docs. Nothing is magic that can't be understood.

Here's the shape of how help flows in this ecosystem:

```
                 ┌─────────────────────────────────────┐
                 │      Something breaks / confuses     │
                 └────────────────┬────────────────────┘
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                   │
              ▼                   ▼                   ▼
      :checkhealth          :messages            :LspInfo
      :Lazy health          :LspLog              :Lazy log
      :Lazy profile         Error traces         :Mason
              │                   │                   │
              └───────────────────┼───────────────────┘
                                  │
                          Can I fix it myself?
                          /                  \
                        YES                   NO
                         │                    │
                  :help <topic>         r/neovim
                  Plugin README         GitHub Issues
                  lazy.nvim docs        Neovim Discussions
                         │                    │
                         └────────────────────┘
                                  │
                          Found the fix?
                           /          \
                         YES           NO
                          │             │
                   Apply & test    Open an issue
                   Commit change   (with repro steps)
```

The key insight is that Neovim gives you diagnostic tools _inside the editor itself_. You don't need to exit to debug Neovim. Most problems can be diagnosed without leaving your terminal. That's a huge advantage over VSCode where debugging extension issues often means crawling through extension host logs in a separate window.

Let's go through every one of those diagnostic tools in depth.

---

## 2. Getting Help From Within Neovim — The Built-In Help System

This is the most underused feature in Neovim by people coming from VSCode. VSCode's built-in documentation is scattered — some things are in the command palette, some in the settings UI, some on the website. Neovim ships with a comprehensive, offline, hyperlinked documentation system that covers every built-in feature, every option, every function, and every command.

> **In VSCode you'd...** press `F1`, type something in the command palette, and hope the description is informative enough. Or open a browser and search the VS Code docs. The docs are on the internet, so you need connectivity. They may or may not match your installed version.
>
> **In Neovim you...** type `:help <topic>` and get the actual documentation for your installed version, with hyperlinks, examples, and cross-references. Works completely offline. Always accurate for your version.

### `:help <topic>` — Using It Effectively

The basic syntax is:

```vim
:help normal-index          " help on Normal mode key mappings index
:help quickfix              " help on the quickfix list
:help lua-guide             " the Lua in Neovim guide
:help vim.lsp               " LSP Lua API
:help autocmd               " autocommand documentation
:help :substitute           " the :substitute command
:help 'number'              " the 'number' option (note the quotes)
```

The quotes matter. Neovim's help system uses a tagging convention:

- `:help topic` — looks up the tag `topic` (usually a feature or concept name)
- `:help 'option'` — looks up an _option_ like `'number'`, `'wrap'`, `'tabstop'`
- `:help :command` — looks up the _ex command_ `:command`
- `:help CTRL-X` — looks up the key chord `CTRL-X` in Normal mode
- `:help i_CTRL-X` — same chord but in Insert mode (prefix `i_`)
- `:help v_CTRL-X` — same chord in Visual mode (prefix `v_`)
- `:help c_CTRL-X` — same chord on the command line (prefix `c_`)

This is critically important. If you type `:help CTRL-N` you get the Normal mode behavior (cycle through completion). If you mean the Insert mode completion trigger, you need `:help i_CTRL-N`. The mode prefix system is systematic and learnable.

### The Help File Syntax — Following Links

Help files use a special hyperlink syntax. You'll see things like:

```
|normal-index|    ← a hyperlink tag (shown with pipes)
*normal-index*    ← a tag definition (where links point to)
```

To navigate within a help file:

| Key      | Action                                                       |
| -------- | ------------------------------------------------------------ |
| `CTRL-]` | Follow the link under the cursor (like clicking a hyperlink) |
| `CTRL-O` | Go back (like browser Back button)                           |
| `CTRL-T` | Also go back (older alternative)                             |
| `CTRL-I` | Go forward (after going back)                                |
| `K`      | Look up the word under the cursor in the help system         |
| `gd`     | In help files, jump to the definition of the tag             |

The `K` key is particularly useful. Put your cursor on any word in a help file (or on a Lua function call in your config), press `K`, and Neovim looks it up in the relevant documentation. In a `.lua` file, `K` triggers LSP hover by default. In a help file, `K` does a help lookup of the word.

### Navigating Lua API Docs

Neovim's Lua API is thoroughly documented. The main entry points:

```vim
:help lua-guide              " The complete guide to Lua in Neovim
:help lua-guide-api          " Which Vim APIs are available from Lua
:help lua-guide-autocommands " Autocommands in Lua
:help lua-guide-mappings     " Keymaps in Lua
:help vim.api                " The vim.api namespace (nvim_* functions)
:help vim.lsp                " LSP Lua API
:help vim.diagnostic         " Diagnostic system API
:help vim.treesitter         " Treesitter Lua API
:help vim.keymap             " vim.keymap.set etc.
:help vim.fn                 " Access to built-in Vimscript functions
:help vim.opt                " Modern option setting API
:help vim.g                  " Global variables
:help vim.b                  " Buffer-local variables
:help vim.w                  " Window-local variables
```

The difference between `:help vim-script` and `:help lua`:

- `:help vim-script` takes you into the Vimscript (VimL) documentation — the older scripting language. You'll encounter this when reading legacy plugins.
- `:help lua` gets you into the Lua integration documentation, which is what you'll use for everything in this config.

### `:helpgrep` — Searching Across All Help

When you don't know the exact topic name, use `:helpgrep`:

```vim
:helpgrep diagnostic         " search all help for "diagnostic"
:helpgrep LSP.*attach        " regex search: LSP followed by attach
:helpgrep treesitter         " find treesitter references
```

After running `:helpgrep`, results appear in the quickfix list. Navigate them with:

```vim
:cnext              " next result
:cprev              " previous result
:copen              " open the quickfix window to see all results
```

Or just use `:Telescope help_tags` for a much better experience.

### `:Telescope help_tags` — Fuzzy Searching Help

If you have Telescope installed (and this config does), this is your preferred way to search help:

```vim
:Telescope help_tags
```

This opens a fuzzy finder over every help tag in your installation. Type a few characters, see matches in real time, press Enter to jump to the relevant help page. It's dramatically faster than `:helpgrep` for exploratory searching.

You can also bind it:

```lua
-- In your keymaps config:
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Search help tags" })
```

### Practical Examples — Help Topics You Should Know

These are the help pages that will save you the most time:

```vim
:help normal-index           " Every Normal mode key and what it does
:help insert-index           " Every Insert mode key
:help visual-index           " Every Visual mode key
:help ex-cmd-index           " Every : command
:help quickfix               " The quickfix/location list system
:help fold                   " Folding documentation
:help spell                  " Spell checking
:help diff                   " vimdiff mode
:help usr_41.txt             " Writing Vim scripts (good for understanding old configs)
:help usr_lua.txt            " Lua user manual (beginner-friendly)
:help news.txt               " Neovim changelog — read this after updates!
:help deprecated             " Deprecated features — check this when old code breaks
```

> **Pro tip:** `:help news.txt` is the most underrated help topic. Every time Neovim updates, this file gets new entries listing what changed, what's deprecated, and what's new. Read it after `nvim --version` changes. It's how you find out about breaking changes before they break you.

---

## 3. Health Checks — Your First Debugging Tool

When something feels wrong — LSP isn't attaching, Telescope is slow, clipboard doesn't work — your first stop should be `:checkhealth`. This is Neovim's built-in diagnostic system. It runs a battery of checks and reports their status in a human-readable report.

> **In VSCode you'd...** go to Help → Developer Tools → open the console and look for red errors. Or check extension output channels one by one. It's scattered, hard to read, and often doesn't tell you what to fix.
>
> **In Neovim you...** type `:checkhealth` and get a structured report with OK/WARNING/ERROR labels and actionable fix suggestions.

### Running Health Checks

```vim
:checkhealth                 " run ALL health checks (can be slow)
:checkhealth nvim            " core Neovim health (providers, clipboard, etc.)
:checkhealth lazy            " lazy.nvim plugin manager health
:checkhealth mason           " Mason LSP/tool installer health
:checkhealth nvim-treesitter " Treesitter parser health
:checkhealth telescope       " Telescope dependency check
:checkhealth lspconfig       " LSP config health
:checkhealth vim.lsp         " Built-in LSP health
```

Running `:checkhealth` with a specific name is much faster than running everything at once. Use the specific names when you're debugging a specific system.

### Reading the Output — OK vs WARNING vs ERROR

Health check output uses three status levels:

```
## nvim

  - OK: Neovim version 0.10.0
  - OK: +jit: LuaJIT 2.1.0-beta3

## Clipboard (optional)
  - WARNING: No clipboard tool found.
    ADVICE:
    - :help provider-clipboard
    - Install xsel, xclip, wl-clipboard, or win32yank

## Python3 provider (optional)
  - ERROR: "pynvim" not found, Python plugins will not work.
    ADVICE:
    - Run the following in your Python3 environment:
      pip3 install pynvim
```

The meaning of each level:

- **OK** — this system is working correctly, nothing to do
- **WARNING** — this system is impaired or missing optional functionality. Your editor still works, but some features won't be available. Fix when convenient.
- **ERROR** — this system is broken. A feature you might rely on will not work. Fix this.

The "ADVICE" section under each failure is critically important — it usually tells you exactly what command to run to fix it. Read it carefully.

### Common Failures and How to Fix Them

**Python provider not found:**

```
- ERROR: "pynvim" not found
```

Fix: install the Python package for Neovim bindings.

```bash
pip install pynvim
# or with pip3 if your system uses that:
pip3 install pynvim
# or in a virtualenv:
python -m pip install pynvim
```

Then re-run `:checkhealth nvim` to confirm it's green.

**Node provider not found:**

```
- WARNING: node.js provider not found
```

Fix: install the Node.js package for Neovim bindings.

```bash
npm install -g neovim
```

If you use `nvm` or `fnm`, make sure you install it in the Node version that Neovim will find. Neovim looks for `node` in your PATH, so it uses whichever Node version is active when you launch Neovim.

**No clipboard tool:**

```
- WARNING: No clipboard tool found. Clipboard registers (+/*) will not work.
```

This means `y` (yank), `p` (paste) won't communicate with your system clipboard. Fix depends on your OS:

```bash
# Linux with X11:
sudo apt install xclip
# or
sudo apt install xsel

# Linux with Wayland:
sudo apt install wl-clipboard

# macOS:
# pbcopy/pbpaste are built in, this warning shouldn't appear on macOS
# If it does, check that /usr/bin is in your PATH

# WSL (Windows Subsystem for Linux):
# Install win32yank in Windows and put it in your WSL PATH
```

**ripgrep not found:**

```
- WARNING: Ripgrep not found. Live grep won't work in Telescope.
```

Telescope's `:Telescope live_grep` uses `ripgrep` as its backend. Without it, you can fuzzy-find files but not search inside them.

```bash
# Debian/Ubuntu:
sudo apt install ripgrep

# Arch:
sudo pacman -S ripgrep

# macOS:
brew install ripgrep

# Or via the Ansible playbook in this repo:
ansible-playbook playbooks/neovim.yml -K
```

**fd not found:**

```
- WARNING: fd not found. File finding will use find (slower).
```

Telescope uses `fd` (also called `fd-find`) for fast file finding. It's much faster than the POSIX `find` command.

```bash
# Debian/Ubuntu:
sudo apt install fd-find
# Note: on Ubuntu the binary is called fdfind, not fd
# Add to your shell: alias fd=fdfind

# Arch:
sudo pacman -S fd

# macOS:
brew install fd
```

After fixing any of these, re-run the relevant health check to confirm the fix. Don't assume it worked — verify it.

### The Ansible Playbook Approach

This config ships with an Ansible playbook that can install all system dependencies at once:

```bash
# From the repo root:
ansible-playbook playbooks/neovim.yml -K
# -K prompts for sudo password
```

This is the preferred way to set up a new machine. It installs ripgrep, fd, node, python3, pynvim, clipboard tools, and other dependencies in one shot. But if you're fixing a specific missing dependency without running the full playbook, the individual commands above work fine.

---

## 4. LSP Diagnostics — When Language Features Break

LSP (Language Server Protocol) is the backbone of this config's language intelligence — completions, go-to-definition, hover docs, diagnostics. When it breaks, it breaks in specific, diagnosable ways.

> **In VSCode you'd...** click the error in the status bar, maybe get a vague "Language Server crashed" message, try reloading the window, and hope. The VS Code extension often wraps the actual LSP server and hides its output.
>
> **In Neovim you...** have direct access to which servers are running, their state, their full communication log, and you can start/stop/restart them individually.

### `:LspInfo` — Understanding What's Attached

Run `:LspInfo` when in any buffer. It shows you:

```
Language client log: /tmp/nvim.USER/lsp.log

Configured servers: tsserver, eslint, lua_ls, pyright

tsserver (id: 1)
  Status:   Running
  Root dir: /home/user/project
  Filetypes: typescript, javascript, typescriptreact, javascriptreact
  Autostart: true
  Cmd: /home/user/.local/share/nvim/mason/bin/typescript-language-server --stdio

lua_ls (id: 2)
  Status:   Running
  Root dir: /home/user/.config/nvim
  Filetypes: lua
```

The critical pieces to check:

1. **Is your server listed?** If not, it's not configured for this filetype.
2. **Status: Running?** If it shows "exited" or "starting", something is wrong.
3. **Root dir: correct?** LSP servers need to find the project root. If root dir is wrong, the server may not attach or may give wrong results.
4. **Cmd: pointing to the right binary?** Mason installs servers into `~/.local/share/nvim/mason/bin/`. If the path looks wrong, the binary isn't installed.

### `:LspLog` — Reading the Communication Log

When `:LspInfo` shows a server running but things still don't work, or when a server immediately exits, look at `:LspLog`:

```vim
:LspLog
```

This opens the LSP communication log. It's verbose — it shows every request and response between Neovim and all LSP servers. Look for:

- Lines starting with `[ERROR]` or `[WARN]`
- Error codes like `-32700` (parse error) or `-32601` (method not found)
- Stack traces from the server process

The log file path is also shown in `:LspInfo`. You can tail it in a terminal:

```bash
tail -f /tmp/nvim.USER/lsp.log
```

Or search within Neovim using Telescope:

```vim
:Telescope live_grep cwd=/tmp
```

### Starting, Stopping, and Restarting Servers

```vim
:LspStart                    " start the LSP server for the current buffer
:LspStart typescript-language-server  " start a specific server by name
:LspStop                     " stop all servers attached to current buffer
:LspStop typescript-language-server   " stop a specific server
:LspRestart                  " restart all servers attached to current buffer
```

`:LspRestart` is your most-used command here. After changing an LSP server config, or after a Mason update, restart the server without restarting Neovim.

### Common LSP Issues

**Server not attaching to a file:**

Symptoms: `:LspInfo` shows the server is configured but not in the current buffer's list.

Diagnosis: check the filetype. Run `:set filetype?` or `:lua print(vim.bo.filetype)`. If it returns something unexpected (empty, or `text` for a `.ts` file), the filetype detection failed.

```vim
:set filetype?              " what does Neovim think this file is?
:set ft=typescript          " manually set it (temporary test)
```

Also check the root directory detection. LSP servers often look for `package.json`, `tsconfig.json`, `pyproject.toml`, etc. to find the project root. If you open a file that isn't inside a recognized project, the server may refuse to start.

**Server installed by Mason but not found:**

Symptoms: `:LspInfo` shows the server as "not running" or `:LspStart` fails with "executable not found".

Diagnosis: Mason installs to `~/.local/share/nvim/mason/bin/`. Check if the binary is there:

```bash
ls ~/.local/share/nvim/mason/bin/
```

If it's there but Neovim can't find it, the issue is that `vim.env.PATH` doesn't include this directory. This is usually handled automatically by Mason, but can break if your shell config is unusual.

Also check that `mason-lspconfig.nvim` is correctly mapping Mason package names to lspconfig server names. Some servers have different names in Mason versus lspconfig.

**Server crashing immediately:**

Symptoms: `:LspInfo` shows "exited (1)" right after starting.

Diagnosis: `:LspLog` will show the crash. Common causes:

- The server binary itself has a bug or incompatibility (check its GitHub issues)
- Missing runtime dependency (e.g., `pyright` needs Python, `tsserver` needs Node)
- Wrong configuration passed to the server (check your lspconfig setup for that server)

**Slow LSP performance:**

Symptoms: completions lag, hover takes 2+ seconds, formatting times out.

Diagnosis: usually one of three causes:

1. **Large file size** — LSP servers often struggle with files over ~5000 lines. Check file size with `:echo line('$')`.
2. **Large project** — `tsserver` and `pyright` index the entire project on startup. With large projects (10k+ files), this takes time.
3. **Misconfigured server options** — check if the server has options to exclude `node_modules`, `__pycache__`, or other large directories from indexing.

### `:Mason` — The Package Manager UI

Run `:Mason` to open Mason's full UI:

```
Mason
/─────────────────────────────────────\
│ [1] LSP  [2] DAP  [3] Linters  [4] Formatters │
│                                               │
│ Installed:                                    │
│   ● lua-language-server              [X]      │
│   ● typescript-language-server       [X]      │
│   ● pyright                          [X]      │
│                                               │
│ Available:                                    │
│   ○ rust-analyzer                             │
│   ○ gopls                                     │
└───────────────────────────────────────────────┘
```

Keymaps within the Mason UI:

| Key    | Action                                       |
| ------ | -------------------------------------------- |
| `i`    | Install the package under cursor             |
| `u`    | Uninstall the package under cursor           |
| `U`    | Update the package under cursor              |
| `g?`   | Show help and all keymaps                    |
| `<CR>` | Expand package details                       |
| `1-4`  | Switch between LSP/DAP/Linter/Formatter tabs |

From the command line:

```vim
:MasonInstall lua-language-server     " install a specific server
:MasonUninstall lua-language-server   " uninstall it
:MasonUpdate                          " update all installed packages
:MasonLog                             " view Mason's activity log
```

---

## 5. Diagnosing Messages and Notifications

Neovim displays messages at the bottom of the screen. The problem is that they disappear quickly, especially if multiple messages appear in sequence. You've almost certainly experienced the frustration of seeing a flash of red text and then it's gone.

> **In VSCode you'd...** see a toast notification in the corner that stays for a few seconds. Important errors go to the Problems panel. You can always re-open the Problems panel.
>
> **In Neovim you...** use `:messages` to see everything that was printed, and if noice.nvim is installed, you get a full message history UI with filtering.

### `:messages` — The Message History

```vim
:messages                    " show all messages from this session
```

This is a simple list of every message Neovim has shown. Use it when:

- An error flashed by too fast to read
- You saw something concerning but weren't sure what it said
- A plugin printed something on startup that you want to review

The output isn't pretty, but it's complete. Every `:echo`, `vim.notify()`, `print()`, and error message ends up here.

### `:Noice` — The Better Message History

If `noice.nvim` is installed in this config (check `lua/de100/plugins/noice.lua`), you have a much better UI:

```vim
:Noice                       " open the full message history
:Noice last                  " show the last notification
:Noice dismiss               " dismiss the current notification popup
:NoiceHistory                " alternative way to open history
:NoiceTelescope              " open message history in Telescope (filterable!)
```

The `:NoiceTelescope` command is particularly useful. You can fuzzy-search through all past messages, filter by type (error, warning, info), and see which messages came from which source.

### `vim.notify()` — How Plugins Communicate

Most well-written plugins use `vim.notify()` to send messages. This function takes a message, a level, and options:

```lua
vim.notify("Server started", vim.log.levels.INFO, { title = "LSP" })
vim.notify("Could not find config", vim.log.levels.WARN, { title = "plugin-name" })
vim.notify("Fatal error: " .. err, vim.log.levels.ERROR, { title = "plugin-name" })
```

Log levels:

| Level | Constant               | Meaning                            |
| ----- | ---------------------- | ---------------------------------- |
| 0     | `vim.log.levels.TRACE` | Extremely verbose debug info       |
| 1     | `vim.log.levels.DEBUG` | Debug info                         |
| 2     | `vim.log.levels.INFO`  | Normal information                 |
| 3     | `vim.log.levels.WARN`  | Warning — something might be wrong |
| 4     | `vim.log.levels.ERROR` | Error — something is wrong         |

When noice.nvim is installed, it intercepts `vim.notify()` and routes messages to its history. When it's not installed, messages appear briefly at the bottom of the screen and go to `:messages`.

### Reading Lua Error Stack Traces

When a Lua error occurs in Neovim, you'll see something like:

```
Error in ... 'plugins/lsp/mason.lua':
...vim/lazy/nvim-lspconfig/lua/lspconfig/manager.lua:45: attempt to index a nil value
stack traceback:
  ...vim/lazy/nvim-lspconfig/lua/lspconfig/manager.lua:45: in function 'new'
  ...vim/lazy/nvim-lspconfig/lua/lspconfig/init.lua:112: in function 'setup'
  ...config/nvim/lua/de100/plugins/lsp/mason.lua:28: in main chunk
```

Reading this from bottom to top:

1. `mason.lua:28` — your config file called something at line 28
2. `lspconfig/init.lua:112` — that called `setup()` in lspconfig
3. `lspconfig/manager.lua:45` — which tried to index a nil value

So the actual bug is in your `mason.lua` at line 28 — you passed something nil to `setup()`. Open that file, find line 28, and check what you're passing.

The bottom of the stack trace (your file) is almost always where you need to make the fix, even though the error appears deeper in the stack.

---

## 6. Plugin Debugging — The Lazy.nvim Ecosystem

Lazy.nvim is this config's plugin manager. It has a comprehensive UI and set of commands for managing, debugging, and profiling plugins.

> **In VSCode you'd...** go to the Extensions panel, which shows installed extensions. You can enable/disable them but you can't see their startup impact, read their changelogs, or profile their load time. The panel is a list, not a diagnostic tool.
>
> **In Neovim you...** open `:Lazy` and get a full interactive plugin manager with health checks, profiling, change logs, and more.

### `:Lazy` — The Plugin Manager UI

```vim
:Lazy                        " open the Lazy UI
```

The UI shows all configured plugins with their status:

```
Lazy.nvim                                               <version>
──────────────────────────────────────────────────────────────────
 ✓ Loaded (42)                  ○ Not loaded (8)
 ✗ Broken (0)                   ⟳ Updates (3)

  ✓ nvim-treesitter        lua/de100/plugins/treesitter.lua
  ✓ telescope.nvim         lua/de100/plugins/telescope.lua
  ✓ nvim-lspconfig         lua/de100/plugins/lsp/mason.lua
  ○ lazy-loaded-plugin     lua/de100/plugins/something.lua
  ⟳ blink-cmp              lua/de100/plugins/blink-cmp.lua
```

Keymaps within the Lazy UI:

| Key    | Action                          |
| ------ | ------------------------------- |
| `U`    | Update all plugins              |
| `I`    | Install missing plugins         |
| `S`    | Sync (install + update + clean) |
| `C`    | Clean unused plugins            |
| `R`    | Restore from lazy-lock.json     |
| `P`    | Show profile                    |
| `L`    | Show log                        |
| `H`    | Show health                     |
| `<CR>` | Expand plugin details           |
| `o`    | Open plugin on GitHub           |
| `?`    | Show help                       |

### `:Lazy health` — Plugin Health Checks

```vim
:Lazy health
```

This runs health checks specifically for lazy.nvim and its plugin ecosystem. It verifies:

- Plugin directory structure
- Plugin files are loadable
- No circular dependencies
- Lock file consistency

### `:Lazy log` — Recent Plugin Activity

```vim
:Lazy log
```

Shows a git-style log of plugin changes. After an update, this lets you see what actually changed in each plugin — the same information as reading each plugin's git log, but aggregated into one view. This is how you find out if an update introduced a breaking change.

### `:Lazy profile` — Startup Profiling

This is one of the most powerful features. After your editor starts:

```vim
:Lazy profile
```

You get a breakdown of startup time by plugin, sorted by load time:

```
Profile
──────────────────────────────────────────────────────────
  Total: 234ms

  Plugin                          Load time   Type
  ────────────────────────────────────────────────
  nvim-treesitter                  89ms       start
  telescope.nvim                   42ms       start
  nvim-lspconfig                   31ms       start
  blink-cmp                        18ms       event:InsertEnter
  gitsigns.nvim                    12ms       event:BufReadPre
```

Plugins with `event:InsertEnter` or `event:BufReadPre` type are _lazy-loaded_ — they don't contribute to startup time until triggered. Plugins with `start` type load at startup.

If your startup is slow, look for `start` type plugins that could be lazy-loaded. See section 12 (Performance Tips) for more detail.

### `:Lazy clean` — Removing Unused Plugins

```vim
:Lazy clean
```

Lazy tracks which plugins are configured. If you remove a plugin from your config but don't run `:Lazy clean`, the plugin directory still exists on disk. `:Lazy clean` removes those orphaned directories.

You'll see a confirmation prompt showing what will be deleted. Review it carefully — make sure you didn't accidentally remove a plugin you wanted to keep.

### `:Lazy restore` — Rolling Back to the Lock File

```vim
:Lazy restore
```

Restores all plugins to the exact versions recorded in `lazy-lock.json`. This is the nuclear option when an update breaks things — it rolls everything back to a known-good state.

See section 7 for more about `lazy-lock.json` and when to use this.

### Reading Plugin Errors in `:messages`

When a plugin fails to load or throws an error, the error goes to `:messages`. Look for lines like:

```
Error detected while processing /path/to/plugin/init.lua:
line 42: module 'some.dependency' not found
```

The "module not found" error almost always means either:

1. A dependency plugin isn't installed (check `:Lazy` to see if it's listed)
2. The load order is wrong (a plugin tried to require something that loads later)
3. A typo in the module name

The fix is usually to add the missing plugin to your config, or to use lazy.nvim's `dependencies` field to ensure load order.

---

## 7. Updating Everything

One of the most important habits in any tool ecosystem is knowing how to update things safely. "Works on my machine" is never a good excuse, and updates are where things most often break unexpectedly.

> **In VSCode you'd...** let extensions auto-update in the background. This is convenient but means things can silently break overnight. You can enable auto-update notifications, but rollback is painful — you have to find the old VSIX file.
>
> **In Neovim you...** update explicitly and deliberately. lazy-lock.json records exactly what version everything is at, so you can always roll back. Updates are visible and you can review changelogs.

### The Update Workflow

Here's the recommended update workflow:

```
1. :Lazy update         ← update all plugins
2. :Lazy log            ← review what changed (look for BREAKING CHANGES)
3. :Lazy profile        ← check startup time didn't regress
4. :checkhealth         ← verify no new health issues
5. Test your workflow   ← actually use it for a bit
6. :MasonUpdate         ← update LSP servers and tools
7. :TSUpdate            ← update Treesitter parsers
8. git add lazy-lock.json && git commit -m "chore: update plugins"
```

Only commit `lazy-lock.json` after you've verified the updates don't break anything. The lock file is your record of a known-good state.

### `:Lazy update` — Updating Plugins

```vim
:Lazy update             " update all plugins
:Lazy update telescope   " update only telescope.nvim
```

After running, Lazy shows a diff of what changed in each plugin. Read the changelogs. Plugin maintainers often put "BREAKING" or "MIGRATION" in commit messages when they make incompatible changes.

### `:Lazy sync` — The All-In-One Update

```vim
:Lazy sync
```

This is equivalent to running install + update + clean in one step:

1. Installs any newly configured plugins that aren't installed yet
2. Updates all existing plugins to their latest versions
3. Removes plugins that are no longer in your config

Use `:Lazy sync` when you've made changes to your config (added/removed plugins) and want to bring the actual installed state in sync with the config.

### `:MasonUpdate` — Updating LSP Servers

```vim
:MasonUpdate             " update all Mason-installed packages
```

Mason installs LSP servers, DAP adapters, linters, and formatters into `~/.local/share/nvim/mason/`. These are separate from your Neovim plugins (which live in `~/.local/share/nvim/lazy/`). They need their own update command.

After updating, restart affected LSP servers with `:LspRestart`. Some server updates change capabilities or configuration format — check the server's changelog if things behave differently after the update.

### `:TSUpdate` — Updating Treesitter Parsers

```vim
:TSUpdate                " update all installed Treesitter parsers
:TSUpdate typescript     " update only the TypeScript parser
:TSInstall typescript    " install a parser (if missing)
:TSInstallInfo           " show installed parsers and their versions
```

Treesitter parsers are compiled C code that gets loaded as shared libraries. They have their own versioning system separate from the `nvim-treesitter` plugin. You can have an up-to-date plugin with outdated parsers, or vice versa.

After updating `nvim-treesitter` the plugin, always run `:TSUpdate` to ensure parsers are compatible with the new plugin version. Mismatched parser/plugin versions are a common source of "Treesitter highlighting looks broken" issues.

### `lazy-lock.json` — The Reproducibility Engine

This file is automatically managed by lazy.nvim. It looks like:

```json
{
  "blink.cmp": {
    "branch": "main",
    "commit": "a5a7c8e2b..."
  },
  "nvim-treesitter": {
    "branch": "main",
    "commit": "f4b3d9c1e..."
  },
  "telescope.nvim": {
    "branch": "0.1.x",
    "commit": "9bc1e5b2d..."
  }
}
```

Every plugin has a locked commit hash. This means:

- If you and a teammate both use the same `lazy-lock.json`, you have identical plugin versions
- If you clone this config on a new machine, `:Lazy restore` gives you the exact same versions
- If an update breaks something, you can roll back to the last committed lock file state with `:Lazy restore`

**When to commit `lazy-lock.json`:**

- After verifying a set of updates works correctly: commit to record the new good state
- When setting up a new machine: pull the latest lock file to get known-good versions
- Before starting a significant project: lock your config to a stable state

**When NOT to immediately commit `lazy-lock.json`:**

- Right after running `:Lazy update` without testing
- After a major Neovim version upgrade (test first)
- If you're troubleshooting a problem (you might need to roll back)

The `:Lazy restore` command brings all plugins back to whatever commit is recorded in the current `lazy-lock.json`. It's your rollback button.

---

## 8. The `_archive` Pattern

This config uses a convention that you'll see in the plugin directory: a `_archive/` subfolder. Understanding why it exists will make you a more confident config maintainer.

### What the Archive Is

```
lua/de100/plugins/
├── blink-cmp.lua
├── telescope.lua
├── treesitter.lua
├── lsp/
│   ├── mason.lua
│   └── ...
└── _archive/
    ├── nvim-cmp.lua       ← replaced by blink-cmp, kept for reference
    ├── old-telescope.lua  ← superseded config, kept for reference
    └── vim-maximizer.lua  ← tried it, didn't stick
```

Files in `_archive/` are not loaded by Neovim. Lazy.nvim only loads what's explicitly listed in your plugin spec. Putting a file in `_archive/` is effectively the same as deleting it, except you can get it back instantly by moving it back out.

### Why Archive Instead of Delete?

The philosophy is about information preservation and reversibility:

1. **You learned something by writing that config.** The old `nvim-cmp.lua` might have patterns or settings you want to reference when configuring `blink-cmp`. Deleting it means you have to rediscover them.

2. **Switches aren't always permanent.** You might replace completion plugin A with plugin B, use B for six months, then find that a new version of A has features B lacks. Having the old config to reference makes the switch back much faster.

3. **History is more honest than git blame.** A file in `_archive/` tells you "this was tried and set aside." Git history tells you "this was deleted," which doesn't communicate intent.

4. **Config debt feels different when it's archived.** A file in `_archive/` is explicitly "not active." A commented-out file in your main directory is ambiguously active. The archive makes the distinction clear.

### When to Archive vs When to Delete

**Archive when:**

- You're replacing a plugin with a different one (keep the old config)
- You're experimenting with removing a feature (archive it, see if you miss it)
- You're not 100% sure you're done with the config
- Less than 2 weeks since you made the change

**Delete when:**

- You archived something 6 months ago and never looked at it
- The archived plugin is abandoned upstream (no updates in 2+ years)
- The archived config is so old it would need a full rewrite anyway
- You're absolutely certain you're moving on

A practical rule: do a quarterly archive cleanup. Every three months, look at `_archive/`. Anything that's been there more than 3 months and you haven't needed — delete it.

### How to Restore from Archive

Moving a config back from archive is simple:

```bash
# Move it back out of archive:
mv lua/de100/plugins/_archive/nvim-cmp.lua lua/de100/plugins/nvim-cmp.lua
```

Then in Neovim:

```vim
:Lazy sync               " installs the plugin and removes the replacement if needed
```

You might also need to adjust your config if the plugin's API changed since you archived it.

### The "Try It for Two Weeks" Philosophy

When evaluating a new plugin, the cycle is:

1. Install it (add to config, `:Lazy sync`)
2. Use it for two weeks — actively try to use it, don't fall back to old habits
3. At the end of two weeks, make a decision:
   - **Keep:** it's actually improving your workflow, keep it
   - **Archive:** it was interesting but didn't stick, archive it
   - **Delete immediately:** it caused problems or you know it's not for you

Two weeks is long enough to form a real opinion (you've hit edge cases), but short enough that your config doesn't accumulate infinite experimental plugins.

### Example: Archiving a Plugin You're Replacing

Say you're replacing `nvim-cmp` with `blink-cmp`:

```bash
# Step 1: move the old config to archive
mv lua/de100/plugins/nvim-cmp.lua lua/de100/plugins/_archive/nvim-cmp.lua

# Step 2: create the new config
# (write lua/de100/plugins/blink-cmp.lua)

# Step 3: sync in Neovim
# :Lazy sync
# This installs blink-cmp and removes nvim-cmp from disk

# Step 4: test for two weeks

# Step 5a: if satisfied, optionally delete the archive:
# rm lua/de100/plugins/_archive/nvim-cmp.lua

# Step 5b: if not satisfied, restore and reverse:
# mv lua/de100/plugins/_archive/nvim-cmp.lua lua/de100/plugins/nvim-cmp.lua
# rm lua/de100/plugins/blink-cmp.lua
# :Lazy sync
```

---

## 9. Contributing to the Tutorial Series

This tutorial is part of a numbered series (`01-surviving-day-one.md` through `14-contributing-and-help.md`). The series is meant to be a living document that improves over time with community contributions.

### The Tutorial Reference System

A key design pattern in this config is the "Tutorial reference comment." In plugin configuration files, you'll see comments like:

```lua
-- 📖 See: docs/neovim-tutorials-from-0-to-hero/05-lsp.md
-- This file configures Mason (LSP server installer) and nvim-lspconfig.
-- The tutorial explains what LSP is and how these plugins work together.
```

These comments serve as a navigation aid: someone reading a plugin file and wondering "what does this do?" can follow the path to the relevant tutorial. This creates a two-way link between the config and the documentation.

When you add a new plugin or significantly change an existing one, consider adding (or updating) this comment to link to the relevant tutorial.

### How the Tutorials Are Organized

```
docs/neovim-tutorials-from-0-to-hero/
├── README.md               ← table of contents and series overview
├── 00-before-you-start.md  ← prerequisites, what to expect
├── 01-surviving-day-one.md ← modes, basic navigation, quit without panicking
├── 02-...
├── 03-moving-like-a-ninja.md
├── ...
├── 13-...
└── 14-contributing-and-help.md  ← you are here
```

Each tutorial follows a consistent structure:

1. Metadata block (difficulty, time, goal)
2. Introduction (the "why" before the "how")
3. Multiple sections with headers
4. VSCode comparisons in callout blocks
5. Code examples throughout
6. ASCII diagrams where they help
7. Tables for reference material
8. Exercises at the end

### Finding Gaps

The tutorials don't cover everything — nobody's docs do. When you run into a workflow that isn't explained, that's a gap worth filling. Good candidates for new content:

- A workflow that took you a week to figure out (others will struggle with it too)
- A common error that has a non-obvious fix
- A plugin that exists in the config but has no tutorial coverage
- A VSCode comparison that would have helped you in the first week

When writing new content, ask: "If I had read this in my first week, what would I have understood faster?"

### How to Update an Existing Tutorial

1. Find the file in `docs/neovim-tutorials-from-0-to-hero/`
2. Edit the relevant section
3. Update `README.md` if you added a new top-level section
4. Test the commands you describe (don't document commands you haven't tried)
5. Submit a PR (see section 10 for the PR process)

Editing in the spirit of the existing content means:

- Keeping the conversational tone
- Adding VSCode comparisons when relevant
- Using ASCII diagrams for visual concepts
- Including real, working command examples
- Adding exercises so readers can practice

### The Style Guide

**Conversational tone, not corporate tone:**

Bad: "Users may utilize the `:checkhealth` command to ascertain system health status."
Good: "When something feels wrong, `:checkhealth` is your first stop."

**VSCode comparisons in callout blocks:**

```markdown
> **In VSCode you'd...** use the Extensions panel to manage plugins.
>
> **In Neovim you...** use `:Lazy` which has profiling, changelogs, and health checks.
```

**ASCII diagrams for flows and relationships:**

```
Plugin File → Lazy loads it → Plugin active → Keymap works
                ↓
         lazy-lock.json updated
```

**Real commands that actually work:**

Don't write `:Telescope live_grep` if the correct command in this config is `<leader>fg`. Use the actual keybinding and explain what it does.

**Exercises with specific things to try:**

Not: "Try using Telescope."
Better: "Run `:Telescope find_files`, find a Lua file in this config, open it, and then press `<leader>fh` to search help tags for 'vim.keymap.set'."

### Submitting Changes

The workflow is:

1. Fork the repository on GitHub
2. Clone your fork
3. Create a branch: `git checkout -b docs/improve-lsp-tutorial`
4. Make your changes to the markdown file
5. Preview the changes (GitHub renders markdown, or use a local preview)
6. Commit: `git commit -m "docs: add troubleshooting section to LSP tutorial"`
7. Push and open a PR

For tutorial changes, the PR description should briefly explain:

- What gap or inaccuracy you found
- What you added or changed
- (Optional) What prompted you to look into this

---

## 10. Contributing to the Config

Contributing to the Neovim configuration itself — plugin files, options, keymaps, the Ansible playbook — follows the same GitHub workflow but has some additional considerations.

### Setting Up Your Development Environment

```bash
# Fork on GitHub first (click Fork on the repo page)
# Then clone your fork:
git clone https://github.com/YOUR_USERNAME/mfansible.git
cd mfansible

# Add the upstream remote so you can pull future changes:
git remote add upstream https://github.com/DreamEcho100/mfansible.git

# Create a feature branch:
git checkout -b feat/add-rust-analyzer-support
```

Always work on a branch, never directly on `main`. This keeps your fork's `main` clean and makes it easy to sync with upstream changes.

### Making Changes to the Config

The Neovim config lives in `dotfiles/.config/nvim/`. The structure:

```
dotfiles/.config/nvim/
├── init.lua                      ← entry point
├── lua/
│   └── de100/
│       ├── core/
│       │   ├── options.lua       ← vim options
│       │   ├── keymaps.lua       ← keymaps
│       │   └── autocmds.lua      ← autocommands
│       └── plugins/
│           ├── init.lua          ← lazy.nvim setup
│           ├── telescope.lua     ← each plugin in its own file
│           ├── treesitter.lua
│           └── ...
└── lazy-lock.json                ← version lockfile
```

For adding a new plugin:

1. Create a new file `lua/de100/plugins/my-plugin.lua`
2. Return a lazy.nvim plugin spec from it
3. Run `:Lazy sync` to install
4. Test thoroughly
5. Add a tutorial reference comment pointing to relevant docs

For modifying an existing plugin:

1. Find the plugin's file (e.g., `lua/de100/plugins/telescope.lua`)
2. Make your changes
3. Source the file (`:source %`) or restart Neovim
4. Test the change
5. Update any relevant tutorial cross-references

### Testing Your Changes

Before submitting, verify:

```vim
:checkhealth                 " no new errors introduced
:Lazy health                 " all plugins healthy
:Lazy profile                " startup time not significantly increased
```

Test the specific feature you changed:

- If you changed keymaps, test the keymaps
- If you added a plugin, test all its features you configured
- If you changed LSP config, test with a relevant file type

Restart Neovim at least once during testing — some bugs only appear on fresh startup, not after a live reload.

### Commit Format — Conventional Commits

This repo follows Conventional Commits format:

```
<type>(<scope>): <short description>

<body — optional, explains why not what>

<footer — optional, e.g., "BREAKING CHANGE: ..." or "Closes #123">
```

Types:

| Type       | When to use                                            |
| ---------- | ------------------------------------------------------ |
| `feat`     | New feature or plugin                                  |
| `fix`      | Bug fix in config                                      |
| `chore`    | Updates, maintenance (e.g., updating lazy-lock.json)   |
| `docs`     | Tutorial or documentation changes only                 |
| `refactor` | Config restructuring without functional change         |
| `perf`     | Performance improvements (e.g., lazy loading a plugin) |
| `style`    | Formatting only (no functional change)                 |

Examples:

```bash
git commit -m "feat(lsp): add rust-analyzer support via Mason"
git commit -m "fix(telescope): fix live_grep not respecting .gitignore"
git commit -m "chore: update plugins to latest versions"
git commit -m "docs: improve LSP troubleshooting section in tutorial 05"
git commit -m "perf(plugins): lazy-load gitsigns on BufReadPre instead of start"
```

Good commit messages make `:Lazy log`-style history reading much more useful — future maintainers (including you in 6 months) can understand what changed and why.

### The PR Process

When opening a PR:

**Title:** Follow conventional commits format. `feat: add rust-analyzer support`

**Description should include:**

```markdown
## What this does

Brief explanation of the change.

## Why

Why is this improvement / what problem does it solve?

## Testing

- Opened a .rs file, rust-analyzer attached successfully
- :LspInfo shows correct root directory detection
- Completions, hover, and go-to-definition all work
- :checkhealth shows no new issues
- :Lazy profile shows startup time unchanged (rust-analyzer is lazy-loaded)

## Notes

- Requires rust and cargo to be installed on the system
- rust-analyzer is installed via Mason (no manual installation needed)
```

Don't open PRs for untested changes. "It works on my machine" is fine — but "I haven't tested it at all" is not.

### How Config Changes Interact with the Ansible Playbook

The Ansible playbook in this repo provisions entire machines, not just the Neovim config. It installs system packages, configures shell environments, and symlinks dotfiles.

If your config change requires a new system dependency (a new CLI tool, a new language runtime), you should also update the relevant playbook task. For example, if you add `rust-analyzer` support via Mason, Mason handles the server installation — but if the feature requires `rust` and `cargo` to be on the system, those might need to be in the playbook.

Check `roles/neovim/` or `playbooks/neovim.yml` for the pattern of how existing dependencies are installed, and follow the same pattern.

When making playbook changes, test them:

```bash
# Dry run (shows what would happen without making changes):
ansible-playbook playbooks/neovim.yml --check -K

# Full run:
ansible-playbook playbooks/neovim.yml -K
```

---

## 11. Common Issues Table

The following table covers the most common problems encountered with this config. Use it as a quick reference when debugging.

| #   | Problem                                     | Symptoms                                               | Diagnosis                                                    | Fix                                                                                                                                                                      |
| --- | ------------------------------------------- | ------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | Plugins not loading after adding to config  | Plugin features absent, no error                       | `:Lazy` — is the plugin listed? Is it loaded?                | Run `:Lazy sync` to install. Check for syntax errors in the plugin spec file (`:messages` will show Lua errors).                                                         |
| 2   | LSP not attaching to a file                 | No completions, no diagnostics, `:LspInfo` shows empty | Run `:set filetype?` — is the filetype correct?              | Check filetype detection (`:set ft=<correct_type>`). Verify the server is installed in Mason. Check root directory detection.                                            |
| 3   | Completions not showing                     | Typing doesn't trigger completion popup                | `:LspInfo` attached? blink-cmp/nvim-cmp loaded?              | Check if blink-cmp is loaded (`:Lazy`). Check LSP is attached. Try manually triggering with `<C-Space>`. Check blink-cmp sources config.                                 |
| 4   | Snippets not appearing in completion        | Completion works but snippets missing                  | Is luasnip/snippet plugin loaded and configured as a source? | Check snippet source in blink-cmp/nvim-cmp config. Ensure LuaSnip is loaded (`:Lazy`). Check that snippet files exist.                                                   |
| 5   | Formatting not working on save              | Save doesn't auto-format, `=` doesn't format           | `:LspInfo` shows formatter? conform.nvim loaded?             | Verify conform.nvim or LSP formatter config. Check filetype in formatter config. Try manual `:lua vim.lsp.buf.format()`.                                                 |
| 6   | Git signs missing from gutter               | No `+`/`~`/`-` in the sign column                      | Is this a git repo? Is gitsigns loaded?                      | Run `git status` in the directory. Ensure gitsigns is loaded (`:Lazy`). Check `:checkhealth gitsigns`.                                                                   |
| 7   | Colors look wrong or no colors              | Everything is one color, no syntax highlighting        | `:set termguicolors?` — is it on?                            | Add `vim.opt.termguicolors = true` to options. Ensure terminal emulator supports true color. Check colorscheme is installed.                                             |
| 8   | Slow startup (>500ms)                       | Editor takes a long time to open                       | `:Lazy profile`                                              | Find plugins with large `start` type load times. Convert them to lazy loading with `event`, `cmd`, or `ft` triggers.                                                     |
| 9   | Telescope not finding files                 | `:Telescope find_files` shows empty results            | Is fd installed? What is the cwd?                            | Run `:checkhealth telescope`. Install `fd-find`. Check if files are gitignored and whether `hidden` option is needed.                                                    |
| 10  | Treesitter syntax highlighting broken       | Code has wrong colors or no highlighting               | `:TSInstallInfo` — are parsers installed?                    | Run `:TSInstall <lang>` for the language. Run `:TSUpdate` to update parsers. Check for parser/plugin version mismatch.                                                   |
| 11  | Mason installer failing                     | `:MasonInstall` shows error or hangs                   | `:MasonLog` shows the error                                  | Check internet connectivity. Check if the required runtime (Node, Python, Go) is installed. Read the specific error in `:MasonLog`.                                      |
| 12  | which-key popup not appearing               | No key binding hints after `<leader>`                  | Is which-key loaded and configured? Time out?                | Run `:Lazy` to verify which-key is loaded. Check `timeout` setting in which-key config. Try pressing `<leader>` and waiting 1+ seconds.                                  |
| 13  | Terminal colors wrong in tmux               | Colors look different inside tmux                      | `$TERM` variable, tmux color settings                        | Add `set -g default-terminal "tmux-256color"` and `set -ga terminal-overrides ",*:Tc"` to `~/.tmux.conf`.                                                                |
| 14  | Neovim crashing on startup                  | Immediately exits or shows crash report                | Start with `nvim --clean` to isolate                         | Bisect config: comment out half of `init.lua`, see if crash persists. Binary search for the culprit.                                                                     |
| 15  | Cannot find module error in Lua             | `module 'x.y.z' not found` on startup                  | `:messages` shows the error                                  | Check if the plugin is installed. Verify the module name matches what the plugin exports. Check load order in lazy.nvim config.                                          |
| 16  | Keymaps not working                         | `<leader>ff` does nothing                              | `:verbose map <leader>ff` — is it defined?                   | Run `:verbose map` to see all keymaps and where they're defined. Check for conflicting mappings. Verify which-key isn't intercepting.                                    |
| 17  | Auto-pairs not working                      | `(` doesn't automatically add `)`                      | Is autopairs plugin loaded?                                  | Check `:Lazy` for nvim-autopairs or similar. Verify it's configured for the current filetype. Check if it's disabled for a specific context.                             |
| 18  | DAP debugger not connecting                 | Debug session starts but immediately fails             | `:DapShowLog` — check the adapter log                        | Verify the debug adapter is installed (check Mason). Check the DAP configuration for the correct program path. Verify the debug adapter's required runtime is available. |
| 19  | Search not finding results (ripgrep issues) | `:Telescope live_grep` finds nothing                   | Is ripgrep installed? Are files in search path?              | Run `rg pattern` in terminal to test ripgrep directly. Check `:checkhealth telescope`. Verify `cwd` is correct. Check `.rgignore` or `.gitignore` files.                 |
| 20  | Session not restoring properly              | Opening nvim doesn't restore previous session          | Is auto-session loaded? Session file exists?                 | Check `auto-session` or `persistence.nvim` config. Verify session directory exists (`~/.local/share/nvim/sessions/`). Check if last exit was clean or crashed.           |

---

## 12. Performance Tips

Performance in Neovim has two dimensions that new users often conflate: **startup time** (how long until the editor is ready) and **response time** (how fast the editor responds during use). They have different causes and different fixes.

> **In VSCode you'd...** accept that startup takes 2-5 seconds (or more with many extensions) as a fact of life. The editor is a heavy Electron app. You can disable extensions but the core app is slow regardless.
>
> **In Neovim you...** routinely achieve <100ms startup time, and when you don't, you have the tools to find exactly why and fix it. Response time issues are rare because Neovim is a native application, not a web app.

### Understanding Startup Time

Startup time is measured from when you run `nvim` to when the editor is ready for input. The biggest contributors:

1. **Plugin loading** — every plugin you `require` at startup costs time
2. **Treesitter parsing** — if you start Neovim with a file open, Treesitter parses it immediately
3. **LSP initialization** — servers initialize in the background but the startup handshake has overhead
4. **Lua module loading** — `require()` has overhead; called once at startup for each module

### `:Lazy profile` — Finding Slow Plugins

After startup:

```vim
:Lazy profile
```

Sort by load time. Plugins showing `start` type are loaded unconditionally at startup. The goal is to have as few `start` plugins as possible, and to have those that must start be fast.

The sweet spot:

- Total startup: under 100ms is excellent, under 200ms is fine, over 500ms is worth fixing
- Individual plugins: under 10ms each for `start` plugins is good

### Lazy Loading Strategies

Lazy.nvim gives you several ways to defer plugin loading:

```lua
-- Load when the editor has finished starting up:
{ "plugin-name", event = "VimEnter" }

-- Load when a file is opened:
{ "plugin-name", event = "BufReadPre" }

-- Load when entering Insert mode for the first time:
{ "plugin-name", event = "InsertEnter" }

-- Load when a specific command is first called:
{ "plugin-name", cmd = { "MyCommand", "MyOtherCommand" } }

-- Load only for specific filetypes:
{ "plugin-name", ft = { "lua", "python", "javascript" } }

-- Load when a keymap is triggered (see lazy.nvim docs):
{ "plugin-name", keys = { { "<leader>fg", "<cmd>...<cr>" } } }
```

Common lazy-loading transformations:

| Plugin         | Before         | After                                 |
| -------------- | -------------- | ------------------------------------- |
| gitsigns.nvim  | `start` (50ms) | `event = "BufReadPre"` (0ms startup)  |
| comment.nvim   | `start` (20ms) | `event = "VeryLazy"` (0ms startup)    |
| nvim-autopairs | `start` (15ms) | `event = "InsertEnter"` (0ms startup) |
| telescope.nvim | `start` (40ms) | `cmd = {"Telescope"}` (0ms startup)   |
| trouble.nvim   | `start` (25ms) | `cmd = {"Trouble"}` (0ms startup)     |

The `VeryLazy` event is a special lazy.nvim event that fires after startup is complete. It's a catch-all for "load this, but not during the startup sequence."

### Large File Performance

For files over ~5000 lines, many plugins start causing performance problems. Treesitter highlighting a 50000-line JSON file will bring Neovim to its knees.

This config (and most serious configurations) includes a big-file detection pattern:

```lua
-- In your autocmds:
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function(ev)
    local file = ev.match
    local size = vim.fn.getfsize(file)
    if size > 1024 * 1024 then  -- larger than 1MB
      -- Disable expensive features for this buffer
      vim.b.bigfile = true
      vim.opt_local.syntax = "off"
      vim.treesitter.stop()
      vim.opt_local.foldmethod = "manual"
    end
  end,
})
```

Some plugins have built-in large-file support. Check `vim.g.bigfile_size` — some configs set this globally and plugins check it.

### The `--startuptime` Flag

For detailed startup profiling outside Neovim:

```bash
nvim --startuptime /tmp/startup.log <file>
cat /tmp/startup.log
```

This creates a log of every `require()` and file source operation during startup, with timestamps. The last entries take the longest. This is more granular than `:Lazy profile` because it shows individual module loads, not just plugin totals.

### Common Performance Culprits

| Culprit                                  | Symptom                              | Fix                                                                                |
| ---------------------------------------- | ------------------------------------ | ---------------------------------------------------------------------------------- |
| Not lazy-loading completions             | Slow to enter Insert mode first time | Load blink-cmp/nvim-cmp on `InsertEnter`                                           |
| Treesitter on huge files                 | Editor freezes on open               | Disable Treesitter for files > 1MB                                                 |
| LSP indexing large project               | Slow typing right after open         | Normal; wait for indexing to complete, or configure server to exclude node_modules |
| Many `require()` at top level            | Slow startup across the board        | Profile with `--startuptime`, find hot modules                                     |
| Regex-heavy syntax file (non-Treesitter) | Slow on certain filetypes            | Replace with Treesitter parser for that filetype                                   |
| status line redraws                      | Flickering/slow cursor movement      | Simplify status line or use `lazy_update` option                                   |

---

## 13. Staying Up to Date

Using a rolling configuration (one that updates regularly) means you need strategies for keeping up with changes without getting surprised by breakage.

> **In VSCode you'd...** see a notification badge on the Extensions icon, click Update All, and hope nothing breaks. There's no changelog, no rollback, no impact assessment.
>
> **In Neovim you...** control when updates happen, see exactly what changed in each plugin, can roll back anything, and can read changelogs before deciding whether to apply an update.

### Watching the Repository

On GitHub, click Watch → Custom → select Releases to get notified when this config has a new release or significant update. Alternatively, watch the repository to get notifications on all commits.

To understand what updated between your current state and a new commit:

```bash
git fetch upstream
git log HEAD..upstream/main --oneline
git diff HEAD..upstream/main -- dotfiles/.config/nvim/lazy-lock.json
```

The `lazy-lock.json` diff is particularly revealing — it shows exactly which plugins moved to new commits.

### Checking `lazy-lock.json` Changes in Commits

When you pull new changes from upstream, scan the `lazy-lock.json` diff:

```bash
git diff HEAD~1 -- dotfiles/.config/nvim/lazy-lock.json
```

Look for:

- Plugins that jumped many commits (major changes)
- Plugins you know are actively developed (likely interesting changes)
- Plugins that changed name or moved (may require config updates)

Then check the changelogs for anything that looks significant with `:Lazy log` after running `:Lazy restore` to sync to the new lock file.

### Reading Plugin Changelogs With `:Lazy log`

After running `:Lazy update`, open `:Lazy` and press `L` for the log. Each plugin shows its recent commits. Look for:

- `BREAKING CHANGE:` — requires action on your part
- `fix:` or `feat:` — informational, understand what changed
- `refactor:` — usually safe, might change behavior slightly

For plugins following Conventional Commits format, the log is very readable. For plugins with undisciplined commit messages, you might need to read the plugin's GitHub releases page.

### `:help news.txt` — The Neovim Changelog

After a Neovim version update:

```vim
:help news.txt
```

This file is updated with every Neovim release. It documents:

- New features added
- Changes to existing behavior
- Deprecated features (things you should stop using)
- Removed features (things that no longer exist)

The deprecation section is critical. When Neovim deprecates a function, it still works for a few versions — but eventually it gets removed. Reading `news.txt` after each upgrade lets you update your config proactively before the removal breaks things.

### The BREAKING CHANGES Pattern in Lock File Diffs

When reading `lazy-lock.json` diffs in commit history, watch for the BREAKING CHANGES pattern:

```diff
-  "nvim-treesitter": { "commit": "a1b2c3d4" }
+  "nvim-treesitter": { "commit": "e5f6g7h8" }
```

If this jump spans a major version (you can check by looking at the nvim-treesitter releases page), it may include breaking changes. The safest approach:

1. Run `:Lazy update` on a day when you have time to debug
2. After updating, test your most-used workflows
3. If something breaks, `:Lazy restore` brings you back
4. Then debug the issue before re-updating

### Following r/neovim

The subreddit at [reddit.com/r/neovim](https://reddit.com/r/neovim) is where:

- Plugin authors announce new releases
- The community discusses breaking changes
- People share config improvements
- New Neovim features are explained with examples

Posts with high upvotes in "Plugin releases" or "News" categories are worth reading. The community is generally helpful, technically deep, and appreciates concrete examples over vague questions.

For faster discussions, many plugin authors have Discord servers. Check individual plugin READMEs for links.

---

## 14. Resources — Comprehensive Reference List

This section is a curated, opinionated list of resources for going deeper on any aspect of Neovim and this config.

### Built-In Resources (Always Available Offline)

**`:help`** — The single best resource for anything built into Neovim. If you're wondering how something works, `:help` is faster than Google for built-in features. Some essential starting points:

```vim
:help lua-guide            " Neovim's own guide to Lua integration
:help news.txt             " What's new in each version
:help vim-differences      " How Neovim differs from Vim
:help nvim-from-vim        " Migration guide for Vim users
:help quickref             " A dense quick-reference of common commands
```

**`:Telescope help_tags`** — Fuzzy search the entire built-in help system. Faster than `:help` for exploratory searches.

**Plugin READMEs via `:Lazy`** — In the Lazy UI, press `<CR>` on any plugin to expand its details, then press `o` to open its GitHub page. Every plugin's README is the authoritative source for that plugin's configuration.

### Official Online Documentation

**[neovim.io/doc](https://neovim.io/doc/)** — The official Neovim documentation website. Same content as `:help`, but web-accessible and searchable with a browser. Useful for sharing links with colleagues.

**[vimhelp.org](https://vimhelp.org/)** — Web version of the Vim/Neovim help files. Nicely formatted, good for reading extended sections that are harder to browse in the terminal help viewer.

**[lazy.nvim documentation](https://github.com/folke/lazy.nvim#readme)** — The README and wiki for lazy.nvim are comprehensive. Plugin spec options, lazy loading configuration, the lock file format — all documented here. When a `:Lazy` command behaves unexpectedly, check here.

**[Mason documentation](https://github.com/williamboman/mason.nvim#readme)** — Covers the Mason package registry, the registry API, and how to configure Mason behavior. Essential when a Mason install fails in a way that `:MasonLog` doesn't fully explain.

### Guides and Learning Resources

**[nvim-lua-guide](https://github.com/nanotee/nvim-lua-guide)** — The definitive community guide to writing Lua in Neovim. Covers the entire `vim.api`, how Vimscript and Lua interact, autocommands, keymaps, and more. If you're writing config beyond what this tutorial series covers, start here.

**[Lua 5.1 Reference Manual](https://www.lua.org/manual/5.1/)** — Neovim embeds LuaJIT (Lua 5.1 compatible). When you're confused by Lua syntax or behavior, this is the spec. Most useful sections: tables (Lua's only data structure), string functions, and metatables.

**[awesome-neovim](https://github.com/rockerBOO/awesome-neovim)** — A curated list of plugins organized by category. When you want to add new functionality (e.g., "I want a better file tree"), check here to find the options and read their comparative discussions.

### Community

**[r/neovim](https://reddit.com/r/neovim)** — The main community hub. Plugin announcements, config sharing, troubleshooting help. Use the search before posting — most common issues have been answered before.

**[Neovim GitHub Discussions](https://github.com/neovim/neovim/discussions)** — Official Q&A for Neovim itself (not plugins). For questions about built-in behavior, API usage, or potential bugs. More authoritative than Reddit for Neovim-core questions.

**[This Config's Issue Tracker](https://github.com/DreamEcho100/mfansible/issues)** — For problems specific to this config, this is the right place. Before opening an issue, check if it's already reported. Include your Neovim version (`:version`), the relevant config file, and the exact error from `:messages`.

### Plugin-Specific Resources

Most plugins have both a GitHub README and a Neovim help file. The help file is accessible with:

```vim
:help plugin-name           " e.g., :help telescope
:help nvim-treesitter       " Treesitter help
:help lspconfig             " LSP config help
:help lazy.nvim             " lazy.nvim help
```

Key plugin help files worth reading once:

| Plugin          | Help tag                | What to read                              |
| --------------- | ----------------------- | ----------------------------------------- |
| Telescope       | `:help telescope`       | Pickers, sorters, previewers              |
| nvim-treesitter | `:help nvim-treesitter` | Module system, custom queries             |
| lspconfig       | `:help lspconfig`       | Server configurations, root dir detection |
| which-key       | `:help which-key.nvim`  | Group naming, icons, spec format          |
| nvim-dap        | `:help dap`             | Configuration, adapter setup              |
| gitsigns        | `:help gitsigns`        | Configuration, all available keymaps      |

### Workflow Resources

**[Practical Vim (book)](https://pragprog.com/titles/dnvim2/practical-vim-second-edition/)** by Drew Neil — The best book on modal editing. Covers Vim, most of which applies directly to Neovim. Even if you never buy another programming book, this one pays for itself in productivity within the first week.

**[Modern Neovim (video series)](https://www.youtube.com/results?search_query=neovim+config+from+scratch)** — Searching YouTube for "neovim config from scratch" turns up several high-quality series. Watching how someone builds a config from zero is extremely instructive even if you're not starting from scratch yourself.

**[TJ DeVries on YouTube](https://www.youtube.com/@teej_dv)** — TJ is a Neovim core maintainer and prolific teacher. His videos on Lua APIs, Treesitter, and LSP internals are the best in the ecosystem. If you want to go deeper on any of those topics, search his channel.

---

## Exercises

These exercises are designed to build your self-sufficiency with the diagnostic and contribution tools covered in this tutorial.

### Exercise 1 — Full Health Check Audit

Run a complete health check audit of your system:

```vim
:checkhealth nvim
:checkhealth lazy
:checkhealth mason
:checkhealth nvim-treesitter
:checkhealth telescope
```

For each WARNING or ERROR you find, fix it. Don't proceed until `:checkhealth nvim` has no ERRORs.

_Goal: know the current health baseline of your system._

### Exercise 2 — Help Navigation

Open a help file and practice navigating it:

1. Run `:help normal-index`
2. Move your cursor to any `|tag|` that interests you
3. Press `CTRL-]` to follow the link
4. Press `CTRL-O` to go back
5. Try `:Telescope help_tags` and search for "diagnostic"

_Goal: be comfortable navigating the help system without a mouse._

### Exercise 3 — Read the Message History

1. Restart Neovim
2. Open a few different file types (`.lua`, `.ts`, `.md` if they exist in this repo)
3. Run `:messages`
4. Read through the startup messages — find any warnings or informational messages
5. If noice.nvim is installed, try `:NoiceTelescope` for a better view

_Goal: know what your editor says when it starts up._

### Exercise 4 — LSP Diagnostic Workflow

1. Open a TypeScript or Python file (or any file that has an LSP server configured)
2. Run `:LspInfo` — verify the server is attached and running
3. Find a deliberate syntax error in the file (or add one temporarily)
4. Verify the diagnostic appears (red squiggle or sign column indicator)
5. Run `:lua vim.diagnostic.setloclist()` to see diagnostics in the location list
6. Use `:lnext` and `:lprev` to navigate between diagnostics
7. Fix the error and verify the diagnostic disappears

_Goal: understand the full LSP diagnostic feedback loop._

### Exercise 5 — Profile Your Startup

1. Open Neovim fresh (close and reopen)
2. Immediately run `:Lazy profile`
3. Find the three plugins with the highest load time
4. Check if any of them are `start` type that could be lazy-loaded
5. If you find one, look up its documentation and try adding a lazy-loading trigger

_Goal: understand your startup performance and the concept of lazy loading._

### Exercise 6 — Update and Verify

1. Run `:Lazy update` to update all plugins
2. After the update completes, press `L` in the Lazy UI to see the changelog
3. Look for any entries with "BREAKING" or "DEPRECATED"
4. Run `:checkhealth` to verify no new issues
5. Test your most-used workflow (open a file, trigger completions, use go-to-definition)
6. If everything is fine, commit the new `lazy-lock.json`

_Goal: complete the full update workflow safely._

### Exercise 7 — Archive an Unused Plugin

Find a plugin in your config that you haven't used in a month (or one that you know you're not using):

1. Identify the plugin's config file
2. Move it to `lua/de100/plugins/_archive/`
3. Run `:Lazy clean` to remove the installed plugin files
4. Use the editor without it for a week
5. At the end of the week, decide: restore it (move back) or delete the archive file

_Goal: practice the archive workflow and understand the try/archive/keep cycle._

### Exercise 8 — Find Something Missing in the Tutorials

Read through this tutorial series (`docs/neovim-tutorials-from-0-to-hero/`). Find one thing that:

- You struggled to figure out that isn't documented here
- Or a VSCode comparison that would have helped you
- Or an error you encountered whose fix isn't mentioned

Write a rough paragraph explaining the fix or concept. If you want to contribute it, follow the contribution workflow in section 10.

_Goal: identify a real gap and write the seed of a contribution._

---

## Summary and What's Next

You've covered everything this tutorial series set out to teach. Let's take stock:

```
01 — Surviving Day One:          modes, basic navigation, quit without panic
02 — Files and Buffers:          opening, saving, managing multiple files
03 — Moving Like a Ninja:        motions, text objects, efficient navigation
04 — Search and Replace:         /, ?, :substitute, global patterns
05 — LSP:                        completions, diagnostics, go-to-definition
06 — Treesitter:                 syntax highlighting, text objects, queries
07 — Telescope:                  fuzzy finding everything
08 — Git Integration:            gitsigns, neogit, diffs inside the editor
09 — Debugging (DAP):            breakpoints, step-through debugging
10 — Formatting and Linting:     conform.nvim, automatic code cleanup
11 — Keymaps and Which-key:      custom keymaps, discoverable bindings
12 — Terminal Integration:       built-in terminal, workflow integration
13 — Advanced Configuration:     Lua scripting, custom plugins, deep config
14 — Contributing and Help:      this tutorial (diagnostics, updates, community)
```

The progression has taken you from "how do I quit this thing" to "here's how to fix it when it breaks and here's how to make it better." That's the full arc.

What's next is simply: use it. The muscle memory for modal editing takes a few weeks to form. The instinct to reach for `:checkhealth` when something feels wrong takes a few incidents to build. The habit of reading `:help` before Googling takes a few rewarding experiences to reinforce.

Every Neovim expert was once someone who couldn't figure out how to quit. The difference between then and now is just time and the willingness to work with the editor's grain rather than against it.

Welcome to the other side.

---

## Quick Reference Card

Cut this out and tape it to your monitor. Or memorize it. Or just remember that `:help` exists.

```
┌─────────────────────────────────────────────────────────────────┐
│                 NEOVIM DIAGNOSTIC QUICK REFERENCE               │
├──────────────────────┬──────────────────────────────────────────┤
│  SOMETHING'S BROKEN  │  FIRST STEPS                            │
├──────────────────────┼──────────────────────────────────────────┤
│ General weirdness    │ :checkhealth nvim                        │
│ Plugin not working   │ :Lazy health  →  :Lazy log               │
│ LSP not attaching    │ :LspInfo  →  :LspLog                     │
│ Missing messages     │ :messages  →  :Noice                     │
│ Slow startup         │ :Lazy profile  →  lazy-load heavy plugins│
│ Clipboard broken     │ :checkhealth nvim  (look for clipboard)  │
│ Colors wrong         │ :set termguicolors?  →  enable it        │
│ Parser broken        │ :TSUpdate  →  :TSInstall <lang>          │
│ Mason install failed │ :MasonLog                                │
├──────────────────────┼──────────────────────────────────────────┤
│  KEEPING UP TO DATE  │  COMMANDS                                │
├──────────────────────┼──────────────────────────────────────────┤
│ Update plugins       │ :Lazy update                             │
│ Update LSP servers   │ :MasonUpdate                             │
│ Update parsers       │ :TSUpdate                                │
│ Roll back plugins    │ :Lazy restore                            │
│ See Neovim changes   │ :help news.txt                           │
├──────────────────────┼──────────────────────────────────────────┤
│  GETTING HELP        │  WHERE TO LOOK                           │
├──────────────────────┼──────────────────────────────────────────┤
│ Built-in features    │ :help <topic>                            │
│ Fuzzy search help    │ :Telescope help_tags                     │
│ Search all help      │ :helpgrep <pattern>                      │
│ Community help       │ reddit.com/r/neovim                      │
│ Neovim Q&A           │ github.com/neovim/neovim/discussions      │
└──────────────────────┴──────────────────────────────────────────┘
```

---

_This is tutorial 14 of 14 in the Neovim 0 to Hero series._
_To contribute improvements to this tutorial, see section 9 and 10._
_For issues specific to this config, see the GitHub issue tracker._
