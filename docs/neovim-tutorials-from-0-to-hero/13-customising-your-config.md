# 13 · Customising Your Config

This is the tutorial you've been waiting for. Up to this point you've been using a config that someone else wrote — following keymaps, trusting plugin choices, living inside somebody else's workflow. That stops here. This tutorial is about ownership: understanding every file, knowing where to touch things, and making Neovim feel like it was grown for your specific hands.

Fair warning: this chapter is long. It's long on purpose. Config customisation has a lot of surface area, and shallow coverage of each topic would leave you stranded the moment you hit an edge case. We go deep here so you don't have to go searching later.

---

## 1. Introduction — Your Config Is a Lua Program

Here's the first mental shift, and it matters more than anything else in this chapter.

In VSCode, your configuration is a JSON blob. Open `settings.json` and you have key-value pairs. Want tab size 4? You write `"editor.tabSize": 4`. Want word wrap? You write `"editor.wordWrap": "on"`. You're filling out a form. There's a finite set of things you can change because there's a finite set of keys the settings schema knows about.

Neovim is different in a way that seems small at first but is actually enormous. Your Neovim config is Lua code. It's a real program. That means:

- You can write functions, loops, conditionals, and data structures.
- You can read environment variables, check if files exist, fetch the hostname of the machine.
- You can dynamically enable plugins based on whether you're running inside Neovide, SSH, or a terminal.
- You can build your own keymaps that call Lua functions with complex logic.
- You can write your own mini-plugins directly in your config without publishing anything.

VSCode's extension system is powerful, but the *settings* layer is deliberately dumb. Neovim collapses that distinction. Your config *is* an extension, permanently loaded.

This also means the config in this repo is not sacred. It's not a product somebody sells you. It's a starting point, written by a real person, with real opinions, and you are expected to disagree with some of those opinions and change them. The directory structure has been deliberately designed to make those changes surgical — one file per plugin, a core directory for foundational settings, clear separation of concerns.

Let's map the whole thing before we touch anything.

---

## 2. Config Structure Map

### 2.1 The Full Directory Tree

Here's the complete layout of the Neovim config. Every file you'll ever touch lives somewhere in this tree.

```
~/.config/nvim/
│
├── init.lua                          ← Entry point. Three lines. Loads everything.
│
├── lazy-lock.json                    ← Auto-generated. Records exact plugin versions.
│                                       Commit this to git for reproducible installs.
│
├── lua/
│   ├── current-theme.lua             ← ONE line: vim.cmd("colorscheme <name>")
│   │                                   This is the only file you edit to change theme.
│   │
│   └── de100/
│       ├── core/
│       │   ├── init.lua              ← Requires options then keymaps. Don't touch.
│       │   ├── options.lua           ← All vim.opt.* settings live here.
│       │   └── keymaps.lua           ← Leader key + all core keymaps live here.
│       │
│       ├── lazy.lua                  ← Bootstraps lazy.nvim, runs require("lazy").setup()
│       │
│       └── plugins/
│           ├── init.lua              ← Plugin list module loader (auto-scanned by lazy)
│           │
│           ├── aerial.lua            ← Code outline / symbol tree
│           ├── ai.lua                ← AI completions (Copilot / Codeium)
│           ├── auto-pairs.lua        ← Auto bracket pairing
│           ├── auto-save.lua         ← Automatic file saving
│           ├── auto-session.lua      ← Session save/restore
│           ├── bind-syntax.lua       ← Keybinding syntax highlighting
│           ├── blink-cmp.lua         ← Completion engine (replaces nvim-cmp)
│           ├── bullets.lua           ← Markdown bullet list helpers
│           ├── colorizer.lua         ← Hex color preview inline
│           ├── colorscheme.lua       ← All colorscheme plugins (rose-pine, gruvbox, etc.)
│           ├── comment.lua           ← Toggle comments
│           ├── conn-manager.lua      ← SSH / remote connection manager
│           ├── dadbod-ui.lua         ← Database UI
│           ├── diffview.lua          ← Git diff viewer
│           ├── disabled.lua          ← Plugins disabled or conditionally enabled
│           ├── emmet.lua             ← HTML/CSS Emmet expansion
│           ├── fff.lua               ← Fast file finder
│           ├── flash.lua             ← Jump-to-character navigation
│           ├── formatting.lua        ← Code formatter (conform.nvim)
│           ├── gitstuff.lua          ← Gitsigns, gitworktree
│           ├── grug-far.lua          ← Search and replace (UI)
│           ├── hardtime.lua          ← Bad habit breaker
│           ├── harpoon.lua           ← File bookmarks (ThePrimeagen's harpoon)
│           ├── hawtkeys.lua          ← Keymap conflict finder
│           ├── img-clip.lua          ← Paste images from clipboard
│           ├── incline.lua           ← Floating filename in winbar
│           ├── kubectl.lua           ← Kubernetes inside Neovim
│           ├── kulala.lua            ← HTTP client (like REST Client in VSCode)
│           ├── languages.lua         ← Language-specific plugin overrides
│           ├── linting.lua           ← Linter integration (nvim-lint)
│           ├── lualine.lua           ← Status line
│           ├── luasnip.lua           ← Snippet engine + custom snippets
│           ├── markdown-preview.lua  ← Browser preview for markdown
│           ├── mini.lua              ← Mini.nvim family (ai, surround, files, etc.)
│           ├── multicursor.lua       ← Multiple cursors
│           ├── neogit.lua            ← Magit-like git UI
│           ├── noice.lua             ← Better UI for messages, cmdline, popups
│           ├── nvim-dap.lua          ← Debugger (DAP)
│           ├── nvim-ufo.lua          ← Code folding
│           ├── oil.lua               ← File explorer as buffer
│           ├── qmk.lua               ← QMK keyboard layout editor
│           ├── remote-nvim.lua       ← Remote Neovim support
│           ├── render-markdown.lua   ← Rendered markdown view
│           ├── search-replace.lua    ← Search/replace helpers
│           ├── showkeys.lua          ← Keystroke display for screencasts
│           ├── snacks.lua            ← Snacks.nvim utility collection
│           ├── stay-centered.lua     ← Keep cursor centered
│           ├── tasks.lua             ← Task runner
│           ├── telescope.lua         ← Fuzzy finder
│           ├── testing.lua           ← Test runner integration
│           ├── todo-comments.lua     ← Highlight TODO/FIXME/NOTE comments
│           ├── treesitter-context.lua← Sticky function/class context header
│           ├── treesitter.lua        ← Tree-sitter parsing + highlighting
│           ├── trouble.lua           ← Diagnostics list panel
│           ├── undotree.lua          ← Visual undo history
│           ├── which-key.lua         ← Keymap discovery popup
│           ├── yanky.lua             ← Yank history ring
│           │
│           └── lsp/
│               ├── lsp.lua           ← LSP client setup (nvim-lspconfig)
│               └── mason.lua         ← LSP/formatter/linter installer
│
├── after/
│   └── ftplugin/                     ← Auto-sourced when filetype is detected
│       ├── c.lua
│       ├── cpp.lua
│       ├── go.lua
│       ├── json.lua
│       ├── jsonc.lua
│       ├── markdown.lua
│       ├── python.lua
│       ├── rust.lua
│       ├── sh.lua
│       ├── sql.lua
│       └── yaml.lua
│
└── snippets/                         ← LuaSnip snippets, one file per filetype
    ├── all.lua                       ← Available in every filetype
    ├── c.lua
    ├── go.lua
    ├── javascript.lua
    ├── javascriptreact.lua
    ├── lua.lua
    ├── python.lua
    ├── rust.lua
    ├── sh.lua
    └── typescript.lua
```

That's the whole thing. Every single file, every directory, explained in one place. Keep this map in your head. When you want to change something, ask yourself: "which part of the tree does this live in?"

### 2.2 The Loading Order

Understanding the loading order is essential when you're debugging why something doesn't work, or why an option you set isn't taking effect.

```
                    NEOVIM STARTS
                         │
                         ▼
                    init.lua
                    ─────────
                    require("de100.core")
                    require("de100.lazy")
                    require("current-theme")
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
      de100/core/init.lua       de100/lazy.lua
      ─────────────────         ──────────────
      require("de100.core.options")    Bootstraps lazy.nvim
      require("de100.core.keymaps")    require("lazy").setup({
                                         import = "de100.plugins",
                                         import = "de100.plugins.lsp"
                                       })
              │                              │
              ▼                              ▼
      vim.opt.* applied          Each plugin file in
      Leader key set             de100/plugins/ is loaded.
      All core keymaps           lazy.nvim handles timing:
      registered                 event, ft, cmd, keys triggers
                                         │
                                         ▼
                                 current-theme.lua
                                 ─────────────────
                                 vim.cmd("colorscheme rose-pine-moon")
                                 (runs after plugins loaded so theme
                                  plugin is already available)

                    Later, when you open a file:
                    filetype detected → after/ftplugin/<ft>.lua sourced
```

The order matters for a few practical reasons:

1. Options are set before plugins load. This means if a plugin reads a vim option during setup, it gets the right value.
2. Keymaps are set before plugins load. Plugin keymaps defined in `keys = {}` specs are registered lazily by lazy.nvim and don't conflict.
3. `current-theme.lua` runs last, after all colorscheme plugins have been set up. If it ran before `de100.lazy`, the colorscheme plugin wouldn't be installed yet.
4. `after/ftplugin/` files run *after* all of the above, triggered by filetype detection events. This is intentional — they override global settings with buffer-local ones.

### 2.3 VSCode Comparison

Here's the philosophical contrast laid out plainly:

```
VSCode                              Neovim (this config)
──────────────────────────────────  ────────────────────────────────────
One settings.json file              ~80 Lua files, each with one purpose
JSON: no logic, no functions        Real Lua: functions, loops, conditions
Editor settings are one namespace   Options / Keymaps / Plugins separated
Extensions loaded uniformly         Plugins lazy-loaded by event/filetype
Theme picker writes to settings.json One-line current-theme.lua file
Per-language via [language] blocks  after/ftplugin/language.lua files
Snippets in .vscode/ JSON files     LuaSnip Lua files in snippets/
No concept of loading order         Explicit, auditable load chain
```

The VSCode approach is easier to get started with. The Neovim approach scales better. Once your config grows to 20+ settings you care about, having them in one JSON blob is harder to navigate than having them in labeled Lua files with comments explaining each decision.

---

## 3. Adding a Custom Keymap

This is the most common customisation. Let's do it properly.

### 3.1 Where to Add It

Core keymaps that aren't tied to any specific plugin belong in:

```
lua/de100/core/keymaps.lua
```

Plugin-specific keymaps belong in the plugin's lazy spec file, in the `keys = {}` table. We'll cover that in section 5. For now, we're adding standalone keymaps.

### 3.2 The vim.keymap.set() Pattern

The function signature is:

```lua
vim.keymap.set(mode, lhs, rhs, opts)
```

Every argument has a specific meaning:

**mode** — Which mode(s) to activate the keymap in. Can be a string or a table of strings:

```lua
"n"           -- Normal mode
"i"           -- Insert mode
"v"           -- Visual and Select mode
"x"           -- Visual mode only (not Select)
"s"           -- Select mode only
"o"           -- Operator-pending mode
"t"           -- Terminal mode
"c"           -- Command-line mode
{"n", "v"}    -- Multiple modes at once
{"n", "i", "v"} -- Three modes
```

The difference between `"v"` and `"x"` trips people up. `"v"` activates in both Visual and Select mode. Select mode is what you get in some GUI applications when you click and drag to select. Most of the time you want `"x"` for visual-mode-only keymaps that do something to selected text.

**lhs** — The key sequence that triggers the keymap. This is what you press:

```lua
"<leader>hw"    -- Space + h + w (because leader is space in this config)
"<C-s>"         -- Ctrl + s
"<A-j>"         -- Alt + j
"<S-Tab>"       -- Shift + Tab
"<F5>"          -- F5
"gd"            -- Just the letters g then d
```

**rhs** — What happens when you press the keys. Can be:

```lua
-- A command string:
":w<CR>"                   -- Runs :w then Enter
"<cmd>Telescope find_files<CR>"  -- The <cmd> form (preferred, doesn't mess with mode)

-- A Lua function:
function() vim.cmd.write() end

-- Another key sequence (rarely needed):
"<C-w>v"        -- Maps to another key combo
```

**opts** — A table of options. The most important ones:

```lua
{
  desc = "Description shown in which-key",  -- Always include this
  noremap = true,   -- Don't allow the rhs to be remapped again (always use true)
  silent = true,    -- Don't echo the command to the command line
  expr = true,      -- rhs is a Lua expression, return value used as keys
  buffer = 0,       -- Only apply to current buffer (for ftplugin use)
}
```

### 3.3 The noremap and silent Explained

**noremap = true** means your keymap can't be accidentally re-mapped by something else. Without it, if rhs is another key sequence, and *that* key sequence is also mapped to something, both mappings chain. That's almost never what you want. Always set `noremap = true` unless you explicitly need chaining.

**silent = true** means when the keymap runs a command, the command string doesn't appear in the command line at the bottom of the screen. Without it, pressing `<Tab>` (mapped to `:bnext<CR>`) would flash `:bnext` in the command line for a fraction of a second. With `silent = true`, it's clean.

Notice how the config defines a local table for these defaults:

```lua
local opts = {noremap = true, silent = true}
```

And then merges additional options with `tbl_merge`:

```lua
local function tbl_merge(table1, table2)
    return vim.tbl_extend('force', table1, table2)
end

-- Usage:
keymap.set('n', '<leader>bx', ':bdelete!<CR>',
           tbl_merge(opts, {desc = 'Close current buffer'}))
```

`vim.tbl_extend('force', ...)` merges tables, with the second table's keys overwriting the first when there's a conflict. The `'force'` strategy means "right side wins."

### 3.4 The desc Field — Why It Matters

The `desc` field is not just documentation. It's actively used by which-key.nvim, which reads all registered keymap descriptions and displays them in the popup menu that appears when you pause after pressing `<leader>`. If you add a keymap without a `desc`, which-key shows it as an anonymous entry with no label. If you add one with `desc`, it shows up clearly labeled.

This is the VSCode equivalent of naming your keybinding in `keybindings.json` with a `"name"` field — except in Neovim it actually does something at runtime.

Make it a habit: every keymap gets a `desc`. Every single one.

### 3.5 Practical Example: Hello World Keymap

Open `lua/de100/core/keymaps.lua` and add this anywhere after the `local opts` table:

```lua
-- Say hello (learning example)
keymap.set('n', '<leader>hw', function()
    print("Hello World from Neovim!")
end, tbl_merge(opts, {desc = 'Print Hello World'}))
```

Save the file, then source it with `:luafile %` (or restart Neovim). Now press `<leader>hw` in Normal mode. You should see the message in the command line area at the bottom.

To verify the keymap is registered, run:

```vim
:nmap <leader>hw
```

Neovim will print something like:

```
n  <Space>hw       * <Lua function>
```

The asterisk means it's a Lua function rather than a string command. The `n` means Normal mode.

### 3.6 Practical Example: Toggle Relative Line Numbers

This is a more useful real-world example. Relative line numbers are great for vim motions (`5j` to go down 5 lines) but can be distracting when reading code. A toggle is handy:

```lua
-- Toggle relative line numbers
keymap.set('n', '<leader>ur', function()
    vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, tbl_merge(opts, {desc = 'Toggle relative line numbers'}))
```

This uses `vim.opt.relativenumber:get()` to read the current value (note the `:get()` call — `vim.opt.X` returns a special object, not a raw boolean, so you need `:get()` to extract the value). Then it negates it and assigns it back.

You could also write this with `vim.o` which is simpler for boolean reads:

```lua
keymap.set('n', '<leader>ur', function()
    vim.o.relativenumber = not vim.o.relativenumber
end, tbl_merge(opts, {desc = 'Toggle relative line numbers'}))
```

`vim.o.relativenumber` returns a plain boolean, so the not works directly.

### 3.7 Common Modes in Practice

Here's a concrete example showing a keymap in multiple modes:

```lua
-- Move selected lines up/down while in visual mode (already in keymaps.lua)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv",
               {desc = "moves lines down in visual selection"})
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv",
               {desc = "moves lines up in visual selection"})
```

These two keymaps override `J` and `K` in Visual mode. Normally `J` in visual mode joins lines. Here it moves the selected block down one line. Note the `gv=gv` at the end: `gv` re-selects the previous selection, `=` re-indents it. So after moving the block, you stay in visual mode with the same selection.

A terminal-mode keymap example:

```lua
-- Exit terminal mode with Escape (terminal buffers otherwise trap you)
keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>',
           tbl_merge(opts, {desc = 'Exit terminal mode'}))
```

In terminal mode, `<C-\\><C-n>` is the sequence to return to Normal mode. Mapping `<Esc><Esc>` to that lets you press Escape twice to exit terminal buffers, which is far more natural.

### 3.8 which-key Groups

The `which-key.lua` file defines groups — prefix labels that appear in the which-key popup. Here's the current spec:

```lua
spec = {
    {"<leader>b", group = "buffers"},
    {"<leader>c", group = "code"},
    {"<leader>d", group = "diagnostics/debug"},
    {"<leader>e", group = "explorer"},
    {"<leader>f", group = "file"},
    {"<leader>g", group = "git"},
    {"<leader>h", group = "harpoon"},
    {"<leader>H", group = "http/rest"},
    {"<leader>l", group = "lsp/lint"},
    {"<leader>m", group = "make/format"},
    {"<leader>p", group = "pick/search"},
    {"<leader>r", group = "rename/refactor"},
    {"<leader>s", group = "splits/session"},
    {"<leader>t", group = "tabs/tests/tasks"},
    {"<leader>u", group = "ui/toggles"},
    {"<leader>v", group = "view/help"},
    {"<leader>w", group = "workspace/session"},
    {"<leader>x", group = "trouble/lists"},
    {"<leader>y", group = "yank"},
    {"<leader>k", group = "keys/show"},
}
```

If you're adding keymaps with a new prefix (say `<leader>n` for "notes"), add an entry to this spec:

```lua
{"<leader>n", group = "notes"},
```

Then your new keymaps:

```lua
keymap.set('n', '<leader>nn', '<cmd>e ~/notes/index.md<CR>',
           tbl_merge(opts, {desc = 'Open notes index'}))
keymap.set('n', '<leader>nd', function()
    local date = os.date("%Y-%m-%d")
    vim.cmd('e ~/notes/daily/' .. date .. '.md')
end, tbl_merge(opts, {desc = 'Open today\'s daily note'}))
```

Now when you press `<leader>n` and pause, which-key shows a popup labeled "notes" with `n` and `d` listed below it.

### 3.9 Testing Your Keymap

After adding a keymap, verify it in these ways:

```vim
" Check if it's registered in normal mode:
:nmap <leader>hw

" Check all leader keymaps:
:nmap <leader>

" Open the which-key picker to see all keymaps:
<leader>pk
```

The `:nmap` command lists all Normal mode maps. You can filter by prefix. If your keymap doesn't appear, either the file wasn't sourced after your edit, or there's a syntax error in the Lua. Check `:messages` for Lua errors.

---

## 4. Changing an Existing Keymap

### 4.1 Finding the Keymap

Before you change a keymap, you need to find it. There are three methods, each best for different situations.

**Method 1: grep**

```bash
grep -r "leader>sv" ~/.config/nvim/
```

This gives you the exact file and line number. Fastest method when you know part of the key sequence.

**Method 2: :Telescope keymaps**

```vim
:Telescope keymaps
```

Or via the picker: `<leader>pk` (which-key discover). This opens a searchable list of all currently active keymaps. You can filter by mode, key sequence, or description. It shows you the file and line where each keymap is defined.

**Method 3: which-key discover**

Press `<leader>` and wait. which-key shows a popup. Navigate the tree visually to find the keymap you're looking for.

### 4.2 The Right Approach: Modify at the Source

When you find the keymap, the right move is almost always to edit the file where it's defined — not to override it in a separate file. Overrides create confusion: you change something in `keymaps.lua`, but there's also an override somewhere else, and you can't figure out which one is actually active.

The exception is plugin keymaps you can't easily change without forking the plugin. But for anything in this config's Lua files, edit the source directly.

### 4.3 Plugin Keymaps in Lazy Specs

Many plugins define their keymaps in the `keys = {}` table of their lazy spec. Here's an example from a hypothetical `harpoon.lua`:

```lua
return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {"nvim-lua/plenary.nvim"},
    keys = {
        {"<leader>ha", function() require("harpoon"):list():add() end,
         desc = "Harpoon: add file"},
        {"<leader>hh", function() require("harpoon").ui:toggle_quick_menu(
            require("harpoon"):list()) end,
         desc = "Harpoon: toggle menu"},
    },
}
```

To change `<leader>ha` to `<leader>hA`, you edit the `keys` table directly in `lua/de100/plugins/harpoon.lua`. There's no need to override anywhere else.

The `keys` table also tells lazy.nvim when to load the plugin. Until one of those key sequences is pressed, the plugin is *not loaded*. This is lazy loading — the plugin only initializes when you actually invoke it for the first time.

### 4.4 Conflict Checking

Key conflicts — two keymaps assigned to the same sequence — are subtle bugs. The second one registered silently overwrites the first. To detect conflicts, use hawtkeys.nvim (already in this config):

```vim
:Hawtkeys
```

This scans all active keymaps and flags duplicates, similar to the "Detect keybinding conflicts" feature in VSCode.

You can also check a specific sequence:

```vim
:nmap <leader>sv
```

If it prints two entries, you have a conflict. The last one registered wins.

The `:checkhealth` command also surfaces some keymap issues:

```vim
:checkhealth which-key
```

which-key does its own conflict detection and reports it in `:checkhealth`.

### 4.5 When to Use vim.keymap.del()

Sometimes you want to completely remove a keymap rather than replace it. `vim.keymap.del()` does this:

```lua
-- Remove the normal-mode mapping for gd
vim.keymap.del('n', 'gd')

-- Remove multiple modes at once
vim.keymap.del({'n', 'v'}, '<leader>old')
```

A common pattern: a plugin sets a default keymap you don't want. You can't edit the plugin's source. So in your plugin's config function, after the setup call, you delete the unwanted keymap:

```lua
config = function()
    require("some-plugin").setup({})
    -- Plugin sets <leader>x to something we don't want
    pcall(vim.keymap.del, 'n', '<leader>x')
end
```

The `pcall` wraps the delete in a protected call — if the keymap doesn't exist (maybe it's not created on every Neovim version), `pcall` swallows the error instead of crashing.

---

## 5. Adding a New Plugin

This is where the real power of the modular structure shines. Adding a plugin is creating one new file.

### 5.1 The Lazy.nvim Spec Format

Every plugin is described by a "spec" — a Lua table with a specific set of fields. Here's the full anatomy:

```lua
return {
    -- Required: the GitHub path "author/repo-name"
    -- Can also be a full URL or a local path
    "author/repo-name",

    -- Optional fields:

    name = "short-name",          -- Override the name lazy uses internally.
                                   -- Useful when two plugins have the same repo name.

    version = "1.2.3",            -- Pin to a specific tag/version.
    branch = "main",              -- Use a specific branch.
    commit = "abc1234",           -- Pin to exact commit.
    tag = "v2.0",                 -- Use a specific git tag.

    lazy = true,                  -- Don't load on startup (lazy.nvim infers this
                                   -- from event/ft/cmd/keys, but you can force it).

    priority = 1000,              -- Higher priority plugins load first.
                                   -- Use for colorschemes that must load early.

    enabled = true,               -- Set to false to completely disable the plugin.
                                   -- It won't even be installed.

    cond = function()             -- A boolean or function returning boolean.
        return vim.g.neovide      -- If false, plugin is skipped this session.
    end,                          -- Unlike enabled=false, cond is checked at runtime.

    event = "BufReadPre",         -- Load on a Neovim event.
                                   -- Can be a string or table of strings.

    ft = "rust",                  -- Load when this filetype is detected.
                                   -- Can be a string or table.

    cmd = "SomCommand",           -- Load when this Ex command is first run.
                                   -- Can be a string or table.

    keys = {                      -- Load when one of these key sequences is pressed.
        {"<leader>xx", desc = "Do something"},
        {"<leader>xy", mode = "v", desc = "Do something in visual"},
    },

    dependencies = {              -- Other plugins this one needs.
        "nvim-lua/plenary.nvim",  -- These are loaded first.
        "nvim-tree/nvim-web-devicons",
    },

    build = "make",               -- Shell command or Lua function run after install.
                                   -- Used for compiled plugins (telescope-fzf-native, etc.)

    opts = {                      -- A table passed directly to require("plugin").setup().
        option_one = true,        -- This is the simple way to configure a plugin.
        option_two = 42,          -- Use this when you don't need any logic.
    },

    config = function(_, opts)    -- A Lua function for complex setup.
        -- _ is the plugin spec itself
        -- opts is the table from the opts field above
        require("some-plugin").setup({
            -- Can do logic here, modify opts, etc.
        })
        -- Can also set keymaps, autocommands, etc. here
    end,

    init = function()             -- Runs when Neovim starts, before the plugin loads.
                                   -- Use for settings that must be set before the
                                   -- plugin is initialized (e.g., vim.g.* variables).
    end,
}
```

### 5.2 The Difference Between opts and config

This is a source of confusion. Both `opts` and `config` let you configure the plugin, but they're for different situations.

**Use `opts`** when you just need to pass a table to `setup()`. lazy.nvim will automatically call `require("plugin-name").setup(opts)` for you. Clean, simple, no boilerplate:

```lua
return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        delay = 300,
    }
}
```

**Use `config`** when you need to do more than just call setup:
- Run code after setup (like setting keymaps)
- Conditionally modify the opts table
- Set up multiple components of the plugin
- Register autocommands
- Access the plugin's API after initialization

```lua
return {
    "some/plugin",
    config = function()
        require("some-plugin").setup({
            fancy_option = true,
        })
        -- Now do things that require the plugin to be initialized:
        vim.keymap.set("n", "<leader>sp", require("some-plugin").do_thing,
                       {desc = "Do the thing"})
        vim.api.nvim_create_autocmd("BufWritePost", {
            callback = function()
                require("some-plugin").on_save()
            end
        })
    end
}
```

You can also combine them. When both `opts` and `config` are present, lazy.nvim passes `opts` as the second argument to your `config` function:

```lua
return {
    "some/plugin",
    opts = {
        base_option = true,
    },
    config = function(_, opts)
        -- opts here is the table from the opts field
        opts.extra_thing = "added in config"
        require("some-plugin").setup(opts)
    end
}
```

### 5.3 Where to Put Your New Plugin File

Create a new file in `lua/de100/plugins/`. The filename is up to you — it's just a label. Use something descriptive. lazy.nvim auto-discovers all `.lua` files in the plugins directory (and subdirectories).

```bash
# Example:
touch ~/.config/nvim/lua/de100/plugins/my-new-plugin.lua
```

### 5.4 Lazy Loading Strategies

Lazy loading means the plugin doesn't load on Neovim startup. Instead, it loads on demand. This dramatically speeds up startup time. Here are the common strategies:

**On event — load when something happens in a buffer:**

```lua
event = "BufReadPre",   -- Before reading a buffer (good for editing plugins)
event = "BufWritePost", -- After saving
event = "VeryLazy",     -- After everything else is done (good for UI enhancements)
event = "InsertEnter",  -- When you enter Insert mode for the first time
event = {"BufReadPre", "BufNewFile"},  -- Multiple events
```

**On filetype — load only for specific languages:**

```lua
ft = "rust",
ft = {"javascript", "typescript", "tsx"},
```

**On command — load when an Ex command is first used:**

```lua
cmd = "Telescope",
cmd = {"Mason", "MasonInstall"},
```

**On keymap — load when a key is first pressed:**

```lua
keys = {
    {"<leader>gg", desc = "Open Neogit"},
}
```

This is the most aggressive lazy loading. The plugin doesn't load until you literally press the key for the first time. After that, subsequent uses are fast (the plugin is already in memory).

### 5.5 Example: Adding mini.animate

Let's add `mini.animate` — a plugin that adds smooth cursor and scroll animations. It's part of the mini.nvim ecosystem.

Create `lua/de100/plugins/mini-animate.lua`:

```lua
-- Smooth animations for cursor movement and scrolling
-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/13-customising-your-config.md
return {
    "echasnovski/mini.animate",
    event = "VeryLazy",  -- Load after startup to avoid slowing initial load
    opts = {
        -- Cursor movement animation
        cursor = {
            enable = true,
            timing = require("mini.animate").gen_timing.linear({duration = 80}),
        },
        -- Scroll animation
        scroll = {
            enable = true,
            timing = require("mini.animate").gen_timing.linear({duration = 150}),
        },
        -- Window resize animation
        resize = {
            enable = true,
        },
        -- Window open/close animation
        open = {
            enable = false,  -- Can be jarring, disabled by default
        },
        close = {
            enable = false,
        },
    },
}
```

After saving this file, run `:Lazy sync` to install the plugin. Or use `:Lazy load mini.animate` to load it immediately without restarting.

### 5.6 Installing: :Lazy sync

After adding a new plugin file, open Neovim and run:

```vim
:Lazy sync
```

This command:
1. Reads all plugin specs
2. Installs any missing plugins
3. Updates plugins that need updating
4. Removes plugins that were removed from specs

The `:Lazy` command without arguments opens the lazy.nvim UI, where you can navigate with arrow keys and see install status.

To test a plugin without restarting:

```vim
:Lazy load plugin-name
```

Replace `plugin-name` with the `name` field from the spec, or the repo name if no `name` was provided.

---

## 6. Disabling a Plugin

### 6.1 The enabled = false Approach

The simplest way to disable a plugin is to add `enabled = false` to its spec:

```lua
return {
    "some/plugin",
    enabled = false,   -- Plugin is completely ignored
    -- rest of config...
}
```

With `enabled = false`, lazy.nvim doesn't install the plugin, doesn't load it, and doesn't show it in `:Lazy`. It's as if the spec doesn't exist.

### 6.2 The disabled.lua Pattern in This Config

`lua/de100/plugins/disabled.lua` is a dedicated file for plugins that are disabled or conditionally enabled. Here's its current content:

```lua
-- dotfiles/.config/nvim/lua/de100/plugins/disabled.lua
local is_neovide = vim.g.neovide or false

return {
    -- (conditionally enabled plugins would go here)
    -- {"akinsho/bufferline.nvim", enabled = is_neovide},
}
```

The `is_neovide` variable reads `vim.g.neovide`, which Neovide (the GUI Neovim frontend) sets to `true` when it starts. In a terminal Neovim session, `vim.g.neovide` is `nil`, so `is_neovide` is `false`.

This pattern lets you have plugins that only run in Neovide:

```lua
local is_neovide = vim.g.neovide or false

return {
    -- Smooth cursor trail — nice in Neovide, broken in terminal
    {"sphamba/smear-cursor.nvim", enabled = is_neovide},

    -- Bufferline tabs — Neovide looks good with them, terminal is cluttered
    {"akinsho/bufferline.nvim", enabled = is_neovide},
}
```

### 6.3 The cond Field vs enabled Field

`enabled` and `cond` both prevent a plugin from loading, but they work differently:

```
enabled = false
  - Plugin not installed (won't show in :Lazy)
  - Evaluated once when lazy.nvim reads specs
  - Can be a boolean value

cond = function() return vim.g.neovide end
  - Plugin might be installed but not loaded
  - Evaluated at runtime, just before loading
  - Can be a function (allows dynamic decisions)
  - If false, plugin is "disabled" for this session but stays installed
```

Use `enabled` for plugins you genuinely don't want at all (they won't be installed). Use `cond` for plugins that should be installed but conditionally activated:

```lua
return {
    "some/gui-plugin",
    -- Install it, but only actually load it in Neovide
    cond = function()
        return vim.g.neovide == true
    end,
    opts = {},
}
```

Environment-variable based conditions are also useful:

```lua
return {
    "some/work-only-plugin",
    cond = function()
        return os.getenv("WORK_MACHINE") == "1"
    end,
    opts = {},
}
```

### 6.4 Example: Disabling hardtime.nvim

Hardtime.nvim is the habit-breaker plugin that prevents you from repeating navigation keys. You want it on for learning but maybe off in production. To disable it without deleting the file:

In `lua/de100/plugins/hardtime.lua`, change:

```lua
-- Before:
return {
    "m4xshen/hardtime.nvim",
    -- ...rest of config
}

-- After:
return {
    "m4xshen/hardtime.nvim",
    enabled = false,
    -- ...rest of config
}
```

Or, to keep it but disable it at runtime when a specific environment variable is set:

```lua
return {
    "m4xshen/hardtime.nvim",
    cond = function()
        -- Disable hardtime when NVIM_RELAX=1 is set
        return os.getenv("NVIM_RELAX") ~= "1"
    end,
    opts = {
        -- config here
    }
}
```

Then launch with `NVIM_RELAX=1 nvim` when you want it off.

---

## 7. Per-Language Settings with ftplugin

### 7.1 What after/ftplugin/ Does

When Neovim opens a file and detects its filetype, it automatically sources the corresponding file from `after/ftplugin/`. For example:

- Open `README.md` → `after/ftplugin/markdown.lua` is sourced
- Open `main.go` → `after/ftplugin/go.lua` is sourced
- Open `script.py` → `after/ftplugin/python.lua` is sourced

The `after/` prefix means these files are sourced *after* any filetype plugins from plugins (including plugins installed by lazy.nvim). This is important: your settings get the last word, overriding any defaults set by plugins.

This is similar to VSCode's per-language settings syntax:

```json
// VSCode settings.json
"[python]": {
    "editor.tabSize": 4,
    "editor.formatOnSave": true
}
```

But in Neovim, each language gets its own file, and each file is a Lua program.

### 7.2 Buffer-local Settings: vim.bo vs vim.opt_local

When you're in an ftplugin file, you want to set buffer-local options — options that only affect the current file, not all open buffers. There are two ways to do this:

```lua
-- vim.bo: buffer-local options, simple string/number/boolean access
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true

-- vim.opt_local: like vim.opt but for the local buffer
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
```

Both work. `vim.opt_local` is more consistent with the `vim.opt` style used in `options.lua`. `vim.bo` is slightly lower-level and doesn't support all options. Use `vim.opt_local` for ftplugin files — it's the right tool.

The difference between these and `vim.opt` (global):

```lua
-- This affects ALL buffers (set in options.lua):
vim.opt.tabstop = 2

-- This affects only the CURRENT buffer (in an ftplugin file):
vim.opt_local.tabstop = 4
```

### 7.3 Creating after/ftplugin/javascript.lua

Create `after/ftplugin/javascript.lua`:

```lua
-- JavaScript-specific settings
-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/13-customising-your-config.md

-- Indentation: JavaScript convention is 2-space indentation
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.expandtab = true  -- Convert tabs to spaces

-- Line length: ESLint default is 80 or 100
vim.opt_local.textwidth = 100
vim.opt_local.colorcolumn = "100"  -- Visual guide at column 100

-- Don't auto-wrap in JavaScript (let formatters handle it)
vim.opt_local.formatoptions:remove({ "t", "c" })

-- Conceallevel: don't conceal anything in JS (relevant for some plugins)
vim.opt_local.conceallevel = 0

-- A local keymap just for JavaScript buffers:
vim.keymap.set("n", "<leader>co", function()
    -- Opens the package.json in the nearest project root
    local pkg = vim.fn.findfile("package.json", ".;")
    if pkg ~= "" then
        vim.cmd("edit " .. pkg)
    else
        vim.notify("No package.json found", vim.log.levels.WARN)
    end
end, {buffer = true, desc = "Open package.json"})
```

Note the `buffer = true` in the keymap opts. This makes the keymap buffer-local — it only exists in JavaScript buffers.

### 7.4 Creating after/ftplugin/markdown.lua

The existing `markdown.lua` is a good example:

```lua
-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/10-formatting-linting.md
vim.opt_local.spell = true           -- Enable spell checking
vim.opt_local.spelllang = "en_us"    -- US English dictionary
vim.opt_local.wrap = true            -- Wrap long lines (prose, not code)
vim.opt_local.textwidth = 0          -- No auto line-break insertion
vim.opt_local.conceallevel = 2       -- Hide markdown syntax characters
vim.opt_local.colorcolumn = ""       -- No column guide (not writing code)
```

You could extend this with more settings:

```lua
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"
vim.opt_local.wrap = true
vim.opt_local.linebreak = true        -- Break at word boundaries when wrapping
vim.opt_local.textwidth = 0
vim.opt_local.conceallevel = 2
vim.opt_local.colorcolumn = ""

-- Markdown-specific keymaps
-- Bold the current word
vim.keymap.set("n", "<leader>mb", function()
    vim.cmd("normal! viw")
    vim.cmd("normal! s****")
    vim.cmd("normal! 2l")
end, {buffer = true, desc = "Bold current word"})

-- Jump to next heading
vim.keymap.set("n", "]h", "/^#<CR>", {buffer = true, desc = "Next heading"})
vim.keymap.set("n", "[h", "?^#<CR>", {buffer = true, desc = "Previous heading"})
```

### 7.5 Common Settings to Put in ftplugin

Here's a reference table of the options most commonly adjusted per language:

```
Option          Type     What It Controls
──────────────  ───────  ────────────────────────────────────────────────
tabstop         number   How many spaces a tab character DISPLAYS as
shiftwidth      number   How many spaces >> and << indent by
softtabstop     number   How many spaces Tab key inserts in Insert mode
expandtab       bool     Convert tab characters to spaces on input
textwidth       number   Auto-break lines at this column (0 = off)
colorcolumn     string   Visual ruler at this column ("80" or "100")
wrap            bool     Visually wrap long lines (doesn't add newlines)
linebreak       bool     Wrap at word boundaries (not mid-word)
spell           bool     Enable spell checking
spelllang       string   Which language dictionary to use
conceallevel    number   How aggressively syntax is concealed (0-3)
formatoptions   string   Controls auto-formatting behavior
```

The `formatoptions` string is especially powerful. The default includes `c`, `r`, `o` which means:
- `c`: auto-wrap comments
- `r`: auto-insert comment leader on Enter
- `o`: auto-insert comment leader on `o`/`O`

The global options.lua already removes these:
```lua
opt.formatoptions:remove({'c', 'r', 'o'})
```

But you might want to add them back for specific languages:
```lua
-- In after/ftplugin/markdown.lua
-- Add "t" (auto-wrap text) for prose writing
vim.opt_local.formatoptions:append("t")
```

### 7.6 How Filetype Detection Works

Neovim detects filetypes through these mechanisms, in priority order:

1. The file extension (`.py` → python, `.lua` → lua, `.tsx` → typescriptreact)
2. The file content — a shebang line (`#!/usr/bin/env python3`) or specific patterns
3. The filename itself (`Makefile`, `Dockerfile`, etc.)
4. Manual override with `:set ft=` or `vim.bo.filetype =`

To check the current filetype:
```vim
:set ft?
```

To force a filetype for the current buffer:
```vim
:set ft=javascript
```

To make it permanent for a specific file pattern, add to options.lua:
```lua
vim.filetype.add({
    extension = {
        env = "sh",    -- Treat .env files as shell scripts
        mdx = "markdown",  -- Treat .mdx as markdown
    },
    filename = {
        [".babelrc"] = "json",
    },
    pattern = {
        [".*/.env.*"] = "sh",  -- .env.local, .env.production, etc.
    },
})
```

### 7.7 ftplugin vs Autocmd Approach

You can achieve the same per-language settings with autocommands in a central location:

```lua
-- Alternative approach: autocommand in options.lua or a separate file
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.wrap = true
    end
})
```

The ftplugin approach is generally preferred over autocommands for per-language settings because:

1. Files are easier to find — you know exactly where to look for markdown settings.
2. Each language is isolated in its own file — markdown settings don't accidentally affect python.
3. Neovim's built-in ftplugin system is purpose-built for this use case.
4. Less boilerplate — no `nvim_create_autocmd` call needed.

Use autocommands when you need more complex logic — for example, setting a keymap only when both the filetype is Python AND a specific plugin is loaded.

---

## 8. Adding Snippets

### 8.1 The Explicit `;` Prefix System

Most custom snippets in this config are prefixed with `;`. When you type `;fn` in a JavaScript file and the completion popup appears, it shows you the arrow function snippet. When you type `;comp`, you get the React component boilerplate.

The semicolon prefix serves a critical purpose: namespace isolation. Without a prefix, a snippet trigger like `fn` would pop up every time you typed the letters "fn" anywhere in a JavaScript file — in variable names, in comments, in strings. That would be maddening.

With `;` as a prefix, snippets only appear when you deliberately trigger them. The `;` character rarely appears in regular code, so false positives are essentially zero.

The prefix is explicit in snippet files. Write the trigger exactly as you want to type it:

```lua
s({trig = ";fn", name = "Arrow function"}, { ... })
-- ^ Explicit semicolon trigger
```

This is intentionally boring. There is no hidden decorator and no Blink transform rewriting
snippet labels, so debugging completion behavior is much easier.

### 8.2 The snippets/ Directory Structure

Each file in `snippets/` corresponds to a filetype:

```
snippets/
├── all.lua           ← Available in every file, every language
├── c.lua             ← Only in .c files
├── go.lua            ← Only in .go files
├── javascript.lua    ← .js files (also extends to ts, tsx, jsx via filetype_extend)
├── javascriptreact.lua
├── lua.lua
├── python.lua
├── rust.lua
├── sh.lua
├── typescript.lua
```

The filename must match a valid filetype name. To check the filetype of a file: `:set ft?`.

Snippet files for related languages are linked with `filetype_extend`:

```lua
-- In luasnip.lua:
ls.filetype_extend("typescript", {"javascript"})
ls.filetype_extend("javascriptreact", {"javascript"})
ls.filetype_extend("typescriptreact", {"javascript", "typescript", "javascriptreact"})
ls.filetype_extend("svelte", {"javascript"})
ls.filetype_extend("astro", {"javascript", "typescript"})
ls.filetype_extend("vue", {"javascript"})
ls.filetype_extend("cpp", {"c"})
ls.filetype_extend("bash", {"sh"})
```

This means TypeScript files get all JavaScript snippets automatically, plus any TypeScript-specific ones. You get code reuse for free.

### 8.3 LuaSnip Snippet Syntax: The Building Blocks

LuaSnip has several node types that compose into snippets. Here's each one:

**s() — The snippet itself:**

```lua
local s = ls.snippet

s(
    {
        trig = "trigger",        -- What you type to trigger it
        name = "Human name",     -- Shown in completion popup
        desc = "Description",    -- Shown as documentation
    },
    {
        -- Array of nodes that compose the snippet body
    }
)
```

**t() — Text node (static text):**

```lua
local t = ls.text_node

t("hello world")              -- Simple string
t({"line one", "line two"})   -- Multiple lines (array of strings)
```

**i() — Insert node (cursor stop where you type):**

```lua
local i = ls.insert_node

i(1)             -- Jump stop #1, empty
i(2, "default")  -- Jump stop #2, pre-filled with "default"
i(0)             -- The final cursor position (convention: always node 0)
```

Insert nodes are numbered. Pressing Tab jumps through them in order: 1, 2, 3... then 0 at the end.

**f() — Function node (dynamic text based on other nodes):**

```lua
local f = ls.function_node

-- Reads the value of insert node 1 and returns it
f(function(args) return args[1][1] end, {1})

-- Reads node 1 and capitalizes the first letter
f(function(args)
    local str = args[1][1] or ""
    return str:sub(1, 1):upper() .. str:sub(2)
end, {1})
```

The `args` parameter is a table of tables. `args[1]` is the value of the first referenced node (as a table of lines). `args[1][1]` is the first line of that node's content.

**c() — Choice node (pick from multiple options):**

```lua
local c = ls.choice_node

c(1, {
    t("option A"),
    t("option B"),
    i(nil, "custom"),
})
```

Press `<C-n>` and `<C-p>` to cycle through choices while the cursor is on a choice node.

**rep() — Repeat a previous insert node:**

```lua
local rep = require("luasnip.extras").rep

-- Repeats whatever is typed into insert node 1
rep(1)
```

This is a shorthand for the function node pattern.

### 8.4 Writing a Simple Snippet: TODO Comment

Add to `snippets/all.lua` (or create it if it doesn't exist):

```lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
    -- TODO comment with optional detail
    s({trig = "todo", name = "TODO comment", desc = "Insert a TODO: comment"},
    {
        t("TODO: "),
        i(1, "describe what needs to be done"),
    }),

    -- FIXME comment
    s({trig = "fixme", name = "FIXME comment", desc = "Insert a FIXME: comment"},
    {
        t("FIXME: "),
        i(1, "describe the bug"),
    }),

    -- NOTE comment
    s({trig = "note", name = "NOTE comment", desc = "Insert a NOTE: comment"},
    {
        t("NOTE: "),
        i(1, "explain the reasoning"),
    }),
}
```

Since these triggers include `;` directly, you type `;todo` and it expands. Tab moves you to the text placeholder.

### 8.5 Writing a Complex Snippet: React Component

Here's a snippet with multiple tab stops, a function node for capitalization, and mirroring. This is already in `snippets/javascript.lua` but let's dissect it:

```lua
s({trig = "compp", name = "React component with props",
   desc = "TypeScript React component with interface"},
{
    -- i(1) = the component name, e.g. "UserCard"
    t("interface "), i(1, "Component"), t({"Props {", "\t"}),
    -- i(2) = the props interface body
    i(2, ""),
    t({"", "}", "", "export default function "}),
    -- mirror(1) repeats whatever was typed in i(1)
    mirror(1),
    t("({ "),
    -- i(3) = the destructured props
    i(3, ""),
    t(" }: "),
    -- mirror again — the interface name
    mirror(1),
    t({"Props) {", "\treturn (", "\t\t"}),
    -- i(4) = the JSX to return
    i(4, "<div></div>"),
    t({"", "\t)", "}"}),
}),
```

When you type `;compp` and trigger it, you get:

```tsx
interface ComponentProps {
    [cursor here]
}

export default function Component({ [props] }: ComponentProps) {
    return (
        [jsx]
    )
}
```

Tab once, type the component name (say "UserCard") and notice that all three `mirror(1)` references update:

```tsx
interface UserCardProps {
    [cursor here]
}

export default function UserCard({ [props] }: UserCardProps) {
    return (
        [jsx]
    )
}
```

### 8.6 Testing Snippets

1. Open a file with the right filetype (e.g., `test.ts` for TypeScript)
2. Enter Insert mode
3. Type the trigger exactly as written in the snippet file (e.g., `;fn`)
4. The completion popup should show the snippet
5. Press Tab or Enter to expand
6. The cursor moves to the first insert node
7. Type the placeholder value
8. Press Tab to jump to the next insert node
9. Continue until all nodes are filled

If the snippet doesn't appear in the completion popup:
- Check that the filetype is correct: `:set ft?`
- Check that the trigger is right (remember the `;` prefix)
- Check for Lua errors: `:messages`
- Restart Neovim (snippets are loaded at startup)

### 8.7 VSCode Comparison

```
VSCode                              Neovim / LuaSnip
──────────────────────────────────  ─────────────────────────────────────
.vscode/snippets/javascript.json    snippets/javascript.lua
JSON format (strict, verbose)       Lua format (flexible, programmatic)
"prefix": "fn"                      trig = "fn"
"body": ["const $1 = ($2) => {"]   t("const "), i(1), t(" = ("), i(2)...
"$1" for tab stops                  i(1) for tab stops
"$TM_FILENAME" for variables        f(function() return ... end)
Can't do logic in snippets          Full Lua: loops, functions, API calls
One snippet format only             Multiple formats (LuaSnip, VSCode, Ultisnips)
```

The VSCode JSON snippet format is well-known and LuaSnip can actually load VSCode-format snippets. But the native Lua format is more powerful — you can use any Lua logic inside function nodes, generate snippets dynamically from files (the YouTube snippets in `luasnip.lua` are a real example of this), and create reusable helpers.

---

## 9. Colorscheme

### 9.1 The Theme Picker: <leader>th

The config includes a theme picker bound to `<leader>th`. This opens a Telescope window listing all installed colorschemes. Select one and it previews live. However, this change is temporary — it resets when you restart Neovim.

To make it permanent, see section 9.3.

### 9.2 Available Themes in This Config

The `colorscheme.lua` file configures several themes:

```
Theme               Plugin                          Variants
──────────────────  ──────────────────────────────  ─────────────────────────
rose-pine           rose-pine/neovim                main, moon, dawn
gruvbox             ellisonleao/gruvbox.nvim         dark, light
kanagawa            rebelot/kanagawa.nvim            wave, dragon, lotus
solarized-osaka     craftzdog/solarized-osaka.nvim   night, day, storm
tokyonight          folke/tokyonight.nvim             night, storm, moon, day
monokai-pro         loctvl842/monokai-pro.nvim       default, spectrum, ristretto
catppuccin          catppuccin/nvim                  latte, frappe, macchiato, mocha
```

To use a variant, the colorscheme command includes the variant name:

```vim
:colorscheme rose-pine          " Uses default (main) variant
:colorscheme rose-pine-moon     " Uses moon variant
:colorscheme rose-pine-dawn     " Uses dawn variant
:colorscheme kanagawa-wave      " Kanagawa wave
:colorscheme kanagawa-dragon    " Kanagawa dragon
:colorscheme catppuccin-mocha   " Catppuccin mocha
:colorscheme tokyonight-night   " Tokyo Night night
```

### 9.3 Making It Permanent: current-theme.lua

The file `lua/current-theme.lua` contains exactly one line:

```lua
vim.cmd("colorscheme rose-pine-moon")
```

To change your theme permanently, edit this file. That's it. The entire theming system is designed around this single file being trivially editable.

For example, to switch to catppuccin-mocha:

```lua
vim.cmd("colorscheme catppuccin-mocha")
```

Save the file, restart Neovim (or source the file with `:luafile ~/.config/nvim/lua/current-theme.lua`), and your theme is changed.

Why is this a separate file rather than a setting in `options.lua`? Because options.lua runs early, before plugins are loaded. Colorscheme plugins aren't available yet. `current-theme.lua` runs last in `init.lua`, after `require("de100.lazy")` has loaded all plugins. So the colorscheme plugin is guaranteed to be available when this file runs.

The loading chain in `init.lua`:
```lua
require("de100.core")    -- options + keymaps (no plugin needed here)
require("de100.lazy")    -- installs and loads plugins including colorschemes
require("current-theme") -- safe to set colorscheme NOW
```

Notice `options.lua` also sets a fallback:
```lua
vim.cmd('colorscheme default')
```

This runs early and sets the built-in default colorscheme. If plugins fail to load for any reason, you still get a working (if plain) editor. Then `current-theme.lua` overwrites this with your chosen theme.

### 9.4 Dark vs Light Variants

Most themes support both dark and light modes. The background is controlled by:

```lua
vim.opt.background = 'dark'   -- or 'light'
```

This is set in `options.lua`. Some themes (like catppuccin) use this to pick the variant automatically:

```lua
background = {light = "latte", dark = "mocha"},
```

So setting `vim.opt.background = 'light'` with catppuccin selected automatically switches to catppuccin-latte.

For themes that don't auto-detect background, you switch manually:

```lua
-- current-theme.lua for light mode with tokyonight:
vim.opt.background = 'light'
vim.cmd("colorscheme tokyonight-day")
```

### 9.5 Terminal Color Compatibility

The `termguicolors` option (set in `options.lua`) enables 24-bit RGB colors:

```lua
opt.termguicolors = true
```

Without this, Neovim uses your terminal's 256-color palette, and most modern themes look wrong. With it, Neovim sends exact RGB values directly to the terminal.

Your terminal emulator must support true color (most modern ones do: Alacritty, Kitty, WezTerm, iTerm2, Windows Terminal, recent gnome-terminal). If you see weird colors or square blocks instead of unicode characters, `termguicolors` might be the culprit — temporarily set it to false and see if that fixes the display.

### 9.6 Highlight Overrides

After a colorscheme loads, you can override specific highlight groups. This is how `colorscheme.lua` customizes each theme:

```lua
-- From the rose-pine config in colorscheme.lua:
highlight_groups = {
    ColorColumn = {bg = "#1C1C21"},
    NormalFloat = {bg = "#1C1C21"},
    Pmenu = {bg = "#191724"},
    PmenuSel = {bg = "#4a465d", fg = "NONE"},
    FloatBorder = {bg = "base"},
    FloatTitle = {bg = "base"}
},
```

If you want to override highlights without modifying the plugin file, use an autocommand in `options.lua` or a separate file:

```lua
-- Override highlights after any colorscheme loads
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        -- Make comments italic
        vim.api.nvim_set_hl(0, "Comment", {italic = true})
        -- Make the cursor line background darker
        vim.api.nvim_set_hl(0, "CursorLine", {bg = "#1e1e2e"})
        -- Make LSP virtual text smaller and dimmer
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", {
            fg = "#f38ba8",
            italic = true,
        })
    end
})
```

The `ColorScheme` autocommand fires whenever a colorscheme is activated, including at startup when `current-theme.lua` runs. Your overrides apply on top of the theme.

`vim.api.nvim_set_hl(0, name, attrs)`:
- `0` means the global namespace
- `name` is the highlight group name (get them with `:Telescope highlights`)
- `attrs` is a table with `fg`, `bg`, `bold`, `italic`, `underline`, `link`, etc.

---

## 10. Vim Options Deep Dive

### 10.1 Reading options.lua

Every option in `options.lua` has a comment explaining its default value and what it does. Here's a detailed walkthrough of the most important ones.

### 10.2 Line Numbers

```lua
opt.number = true          -- Show absolute line numbers (default: false)
opt.relativenumber = true  -- Show relative numbers (default: false)
opt.numberwidth = 4        -- Width of the number column (default: 4)
```

**number = true** shows the line number next to each line. Without this, you get nothing — a pure text editor feel.

**relativenumber = true** shows how far each line is from the cursor. Line under cursor shows `0`. One line above shows `1`, one below shows `1`, two above shows `2`, etc. This is transformative for Vim motions: to jump 7 lines down, you glance at the relative number and type `7j`. No counting.

When both `number` and `relativenumber` are true, the cursor line shows its absolute number while all others show relative. This is called "hybrid" mode and is the most useful combination.

### 10.3 Indentation Settings

```lua
opt.shiftwidth = 2    -- >> and << indent by this many spaces
opt.tabstop = 2       -- Tab character displays as this many spaces
opt.softtabstop = 2   -- Tab key inserts this many spaces in Insert mode
opt.expandtab = false -- Don't convert tabs to spaces (keep real tab characters)
```

The three settings are often confused:

- `tabstop`: display width of existing tab characters in the file
- `softtabstop`: how many spaces the Tab key inserts. If `expandtab` is false, inserts actual tab when multiple of `tabstop`
- `shiftwidth`: how many spaces `>>`, `<<`, and autoindent use

Setting all three to the same value is the most consistent behavior. The global default here is 2, which is the JavaScript/TypeScript convention. Python needs 4 (override in `after/ftplugin/python.lua`), Go uses tabs (override with `expandtab = false, tabstop = 4`).

### 10.4 Scroll Padding

```lua
opt.scrolloff = 8      -- Keep 8 lines visible above and below cursor
opt.sidescrolloff = 8  -- Keep 8 columns visible left and right of cursor
```

`scrolloff = 8` means you'll never be within 8 lines of the top or bottom of the screen. When you're near the bottom, the file scrolls to keep those 8 lines of context visible. This is critical for not losing your place while navigating.

A value of 999 keeps the cursor permanently centered (though `stay-centered.lua` does this more elegantly). 8 is a good balance.

### 10.5 Search Behavior

```lua
opt.ignorecase = true  -- Searches are case-insensitive by default
opt.smartcase = true   -- Unless you type an uppercase letter
opt.hlsearch = true    -- Highlight all matches
opt.incsearch = true   -- Show matches as you type
```

`ignorecase + smartcase` together is the ideal search setup. Typing `/foo` matches "foo", "Foo", "FOO". Typing `/Foo` matches only "Foo" because the uppercase F overrides ignorecase. You never need to think about case — just type what you want to find.

`hlsearch` highlights all search matches in yellow (or your theme's color). Clear the highlights after you're done searching with `<leader>nh` (`:nohl`).

`incsearch` is enabled by default in modern Neovim but worth knowing about. As you type your search pattern, matches highlight live. It's essentially "find as you type."

### 10.6 Persistent Undo

```lua
opt.undofile = true
```

This is one of the most powerful settings that most people don't know about. With `undofile = true`, Neovim writes your undo history to a file. When you close and reopen a file, you can still undo changes from your previous editing session.

VSCode does not have this. If you close a file in VSCode, undo history is gone. In Neovim with `undofile`, that history can persist for weeks. Combined with undotree.nvim, you get a full branching undo tree that you can navigate visually.

The undo files are stored in `~/.local/share/nvim/undo/` and are automatically cleaned up by Neovim's built-in mechanisms.

### 10.7 System Clipboard

```lua
opt.clipboard = 'unnamedplus'
```

Without this, Neovim has its own internal clipboard, separate from the system clipboard. Yanking in Neovim doesn't copy to clipboard; pasting in Neovim doesn't paste from clipboard.

With `clipboard = 'unnamedplus'`, the unnamed register (`"`) is linked to the system clipboard. Yanking with `y` copies to clipboard. Pasting with `p` pastes from clipboard.

This is the setting most VSCode users need immediately on day one of Neovim. Without it, `Ctrl+V` in your browser and `p` in Neovim don't interact.

### 10.8 Sign Column

```lua
opt.signcolumn = 'yes'
```

The sign column is the 2-character column on the far left of the screen. It shows LSP diagnostics (red circle for errors, yellow for warnings), git change indicators, breakpoint markers for the debugger, etc.

Setting `signcolumn = 'yes'` always shows this column, even in files with no signs. Without this, the editor layout shifts when signs appear (because the column suddenly materializes, pushing text to the right). Setting it to always-on prevents the layout jank.

### 10.9 updatetime — The Hidden Performance Knob

```lua
opt.updatetime = 250
```

`updatetime` controls how quickly Neovim triggers the `CursorHold` event — the event that fires when you stop moving the cursor. LSP hover documentation, which-key, and many other features depend on `CursorHold`.

The default is 4000ms (4 seconds). This means hovering over a symbol waits 4 seconds before showing LSP hover docs. That's painfully slow. Setting it to 250ms means hover docs appear almost instantly when you stop moving.

The downside of a very low `updatetime` is that `CursorHold` autocmds run more frequently, which can cause CPU usage if you have many heavy `CursorHold` handlers. 250ms is the community consensus sweet spot.

### 10.10 timeoutlen

```lua
opt.timeoutlen = 300
```

`timeoutlen` is how long Neovim waits after a key sequence before deciding you're not going to press another key. This affects multi-key sequences like `<leader>sv`.

When you press `<leader>s`, Neovim waits 300ms to see if you press something after `s`. If you do nothing, it gives up. If you press `v`, it executes the `<leader>sv` keymap.

Lower values make sequential key sequences feel snappier but require you to type faster. 300ms is a good default — fast enough to feel responsive, forgiving enough that you don't accidentally trigger partial keymaps.

### 10.11 VSCode ↔ Neovim Settings Comparison Table

```
VSCode Setting                      Neovim (vim.opt) Equivalent
──────────────────────────────────  ──────────────────────────────────────────
editor.tabSize                      opt.tabstop / opt.shiftwidth / opt.softtabstop
editor.insertSpaces                 opt.expandtab
editor.wordWrap                     opt.wrap
editor.lineNumbers                  opt.number / opt.relativenumber
editor.scrollBeyondLastLine         (no direct equivalent, scrolloff is similar)
editor.minimap.enabled              (no built-in minimap, use plugins)
editor.fontSize                     (set in terminal emulator, not Neovim)
editor.fontFamily                   (set in terminal emulator or GUI)
editor.cursorStyle                  opt.guicursor
editor.renderWhitespace             opt.list + opt.listchars
editor.bracketPairColorization      (done by treesitter highlight plugins)
editor.formatOnSave                 (conform.nvim with autocmd on BufWritePre)
editor.rulers                       opt.colorcolumn
editor.mouseWheelScrollSensitivity  (set in terminal emulator)
files.autoSave                      (auto-save.lua plugin)
search.smartCase                    opt.ignorecase + opt.smartcase
files.encoding                      opt.fileencoding
editor.wrappingIndent               opt.breakindent
editor.linkedEditing                (LSP rename: <leader>rn)
editor.inlineSuggest.enabled        (blink-cmp / copilot handles this)
workbench.colorTheme                vim.cmd("colorscheme name")
window.title                        opt.title + opt.titlestring
terminal.integrated.shell           (configured per-terminal or vim.o.shell)
editor.suggest.insertMode           opt.completeopt
```

---

## 11. which-key Groups

### 11.1 How which-key Groups Work

which-key.nvim is the popup that appears when you press `<leader>` and wait. It shows all registered keymaps under that prefix, organized into labeled groups.

Groups are defined in the `spec` table inside `which-key.lua`:

```lua
spec = {
    {"<leader>b", group = "buffers"},
    {"<leader>c", group = "code"},
    -- etc.
}
```

Each entry maps a key prefix to a human-readable label. When you press `<leader>b`, the popup shows all keymaps starting with `<leader>b`, with the header "buffers".

Groups nest. If you have:

```lua
{"<leader>g", group = "git"},
```

And keymaps like:
- `<leader>gs` — git status
- `<leader>gc` — git commit  
- `<leader>gd` — git diff

They all appear under the "git" header when you press `<leader>g`.

### 11.2 Adding Your Own Group

Open `lua/de100/plugins/which-key.lua` and add to the `spec` table:

```lua
spec = {
    -- Existing groups:
    {"<leader>b", group = "buffers"},
    -- ... all the current entries ...

    -- Your new group:
    {"<leader>n", group = "notes"},
    {"<leader>j", group = "journal"},
    {"<leader>z", group = "zettelkasten"},
}
```

The order doesn't matter — which-key sorts alphabetically in the popup.

After adding the group, define the actual keymaps in `keymaps.lua` (or wherever is appropriate). The keymaps don't need to know about the which-key group — which-key infers groups from the prefix you define in the spec.

### 11.3 Current Group Inventory

Here's every group in the current config with a brief description of what lives under each:

```
Prefix      Group             What's There
──────────  ────────────────  ────────────────────────────────────────────
<leader>b   buffers           bdelete, bnext, bprev, new buffer
<leader>c   code              LSP code actions, whitespace cleanup
<leader>d   diagnostics/debug DAP debugger, diagnostic open/close
<leader>e   explorer          mini.files, oil, file tree toggles
<leader>f   file              copy file path, format, save without autoformat
<leader>g   git               gitsigns, neogit, diffview, worktree
<leader>h   harpoon           add, navigate, menu
<leader>H   http/rest         kulala HTTP client
<leader>l   lsp/lint          lint run, diagnostics toggle
<leader>m   make/format       format buffer, tasks
<leader>p   pick/search       telescope pickers (files, grep, buffers, etc.)
<leader>r   rename/refactor   LSP rename, refactor operations
<leader>s   splits/session    split management, auto-session
<leader>t   tabs/tests/tasks  tab management, neotest, task runner
<leader>u   ui/toggles        various UI toggles
<leader>v   view/help         view help, documentation
<leader>w   workspace/session LSP workspace, session management
<leader>x   trouble/lists     trouble.nvim diagnostics list, location list
<leader>y   yank              yanky history, clipboard operations
<leader>k   keys/show         hawtkeys, showkeys, which-key
```

### 11.4 Naming Conventions

The groups in this config follow a consistent pattern: the group label describes what the key category does, often with a `/` joining two related themes when there's overlap. For example, `"lsp/lint"` under `<leader>l` because both LSP commands and lint commands start with `l` and are conceptually related.

When you add your own group, use the same format:
- Short (1-2 words)
- Lowercase
- Slash-separated for dual-purpose groups

### 11.5 The which-key Spec Format in Full

Here's the complete syntax for a which-key spec entry:

```lua
-- Group entry (no action, just a label):
{"<prefix>", group = "label"}

-- Group with an icon (decorative):
{"<prefix>", group = "label", icon = ""}

-- Group that's hidden from the popup:
{"<prefix>", group = "label", hidden = true}

-- Individual keymap entry (adds a desc to an existing keymap):
{"<leader>xx", desc = "Description"}

-- Individual entry with mode:
{"<leader>xx", desc = "Description", mode = "v"}

-- Nested spec (groups within groups):
{
    "<leader>g",
    group = "git",
    {
        {"<leader>gs", desc = "Git status"},
        {"<leader>gc", desc = "Git commit"},
    }
}
```

In practice, you rarely need to define individual keymap entries in the which-key spec — the `desc` field in `vim.keymap.set()` serves that purpose automatically. which-key reads all registered keymaps and their descriptions. The spec is mostly for defining group labels.

---

## 12. The Tutorial Reference System

### 12.1 The 📖 Comment Convention

Open any plugin file in `lua/de100/plugins/` and you'll notice the first or second line is often:

```lua
-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/07-lsp-and-completions.md
```

This is a deliberate navigation aid. When you're editing code and encounter a plugin you don't understand, the comment tells you exactly which tutorial covers it. You can follow the path to the tutorial file in this repo, read it, and come back to the plugin file with context.

For example:
- `which-key.lua` points to `02-the-vscode-translator.md`
- `luasnip.lua` points to `07-lsp-and-completions.md`
- `telescope.lua` points to `05-search-and-replace.md`
- `disabled.lua` and `colorscheme.lua` point to this file

The convention helps the config be self-documenting. You don't need an external wiki — the documentation is co-located with the code, and the code points to the documentation.

### 12.2 When You Add a Plugin

When you add a new plugin and create its file, consider whether it warrants a tutorial reference. If you're adding a plugin that has a non-obvious configuration, add a comment pointing to wherever you documented your reasoning:

```lua
-- My custom plugin setup
-- Reference: see keymaps.lua for keybindings added by this plugin
return {
    "author/myplugin",
    -- ...
}
```

Even a simple self-referential comment adds value when you revisit the file six months later.

---

## 13. Exercises

Practice is how settings become second nature. Work through each exercise before moving to the next.

### Exercise 1: Add a Keymap to Open Your init.lua Quickly

**Goal:** Add `<leader>vi` (v for view, i for init) that opens `~/.config/nvim/init.lua` in a new split.

**Where to add it:** `lua/de100/core/keymaps.lua`

**Hints:**
- Use `vim.fn.stdpath("config")` to get the config path instead of hardcoding `~/.config/nvim`
- Use `vim.cmd("vsplit " .. path)` to open in a vertical split
- Add a `desc` so it shows in which-key

**Expected result:** `<leader>vi` opens `init.lua` in a vertical split. which-key shows "Open init.lua" (or similar) under `<leader>v`.

**Verification:** After adding and sourcing the keymap, run `:nmap <leader>vi` to confirm it's registered.

---

### Exercise 2: Create a Custom ftplugin for Python

**Goal:** Create `after/ftplugin/python.lua` with Python-correct settings.

**Python conventions:**
- 4-space indentation (PEP 8)
- Maximum line length 88 (Black formatter default) or 79 (PEP 8 strict)
- Spaces, not tabs

**Requirements:**
1. Set tabstop, shiftwidth, softtabstop to 4
2. Set expandtab to true (Python requires spaces)
3. Set colorcolumn to "88"
4. Add a buffer-local keymap `<leader>tr` that runs `:!python3 %<CR>` to run the current file

**Verification:** Open a `.py` file, run `:set tabstop?` to see 4, `:set expandtab?` to see true, and verify the color column appears at column 88.

---

### Exercise 3: Add a Snippet for a Python Dataclass

**Goal:** Add a snippet to `snippets/python.lua` (create the file if it doesn't exist) that expands to a Python dataclass skeleton.

**The snippet trigger:** `;dclass`

**What it should expand to:**
```python
from dataclasses import dataclass

@dataclass
class ClassName:
    field: Type = default
```

**Requirements:**
1. The class name should be an insert node (i(1))
2. The field name should be an insert node (i(2))
3. The field type should be an insert node (i(3))
4. The default value should be an insert node (i(4))

**Hints:**
- Use `t({"line1", "line2"})` for multi-line text nodes
- Use `\t` for tab characters in the strings
- Don't forget to return the table from the file

**Verification:** Open a `.py` file, enter Insert mode, type `;dclass`, expand it, and Tab through all four insert nodes.

---

### Exercise 4: Disable a Plugin You Don't Use

**Goal:** Identify a plugin in the config you don't use and disable it properly.

**Steps:**
1. Browse the plugins directory: `ls ~/.config/nvim/lua/de100/plugins/`
2. Pick a plugin that seems unnecessary for your workflow (suggestions: `qmk.lua` if you don't use QMK keyboards, `kubectl.lua` if you don't work with Kubernetes, `kulala.lua` if you don't make HTTP requests)
3. Add `enabled = false` to the plugin spec in that file
4. Run `:Lazy sync` and verify the plugin is no longer in the list

**Bonus:** Add a comment explaining why you disabled it:
```lua
return {
    "some/plugin",
    enabled = false,  -- Disabled: I don't use X, and it adds 50ms to startup
    -- ...
}
```

**Verification:** After disabling and syncing, `:Lazy` should not show the plugin. Run `:lua vim.print(package.loaded["plugin-name"])` — it should return `nil`.

---

### Exercise 5: Create a New which-key Group and Two Keymaps

**Goal:** Create a `<leader>n` group for "notes" with two keymaps: one to open a notes index file, and one to create a dated daily note.

**Steps:**

1. Add to `which-key.lua` spec:
   ```lua
   {"<leader>n", group = "notes"},
   ```

2. Add to `keymaps.lua` (after the existing keymaps):

   ```lua
   -- Notes management
   local notes_dir = vim.fn.expand("~/notes")

   keymap.set('n', '<leader>ni', function()
       vim.cmd('e ' .. notes_dir .. '/index.md')
   end, tbl_merge(opts, {desc = 'Open notes index'}))

   keymap.set('n', '<leader>nd', function()
       local date = os.date("%Y-%m-%d")
       local daily_path = notes_dir .. '/daily/' .. date .. '.md'
       vim.cmd('e ' .. daily_path)
   end, tbl_merge(opts, {desc = 'Open daily note'}))
   ```

3. Create `~/notes/` and `~/notes/daily/` directories so the keymaps work.

**Verification:**
- Press `<leader>n` and pause: which-key should show the "notes" group header
- `<leader>ni` opens `~/notes/index.md`
- `<leader>nd` opens today's dated note in `~/notes/daily/YYYY-MM-DD.md`
- `:nmap <leader>ni` and `:nmap <leader>nd` both show registered keymaps

---

## Summary

You now have the full picture of how this config is structured and how to modify every layer of it. The key mental model:

1. **Options** live in `core/options.lua` — change vim behavior globally
2. **Keymaps** live in `core/keymaps.lua` or inside plugin `keys = {}` specs — define how you navigate
3. **Plugins** live in `plugins/<name>.lua` — one file per plugin, enable/disable cleanly
4. **Per-language settings** live in `after/ftplugin/<lang>.lua` — override globally for specific languages
5. **Snippets** live in `snippets/<filetype>.lua` — custom snippets usually use explicit `;prefix` triggers
6. **Colorscheme** is the single line in `lua/current-theme.lua`

The which-key group system in `plugins/which-key.lua` is the map of your entire `<leader>` namespace — keep it updated as you add keymaps, and the popup remains a useful discovery tool rather than a confusing wall of unlabeled keys.

Everything in this config is meant to be read, questioned, and modified. The `📖 Tutorial:` comments point you to documentation. The `desc` fields on every keymap make the system self-describing. The modular file layout makes changes surgical. This is your editor, and this is your config. Go break things — that's how you learn what they do.
