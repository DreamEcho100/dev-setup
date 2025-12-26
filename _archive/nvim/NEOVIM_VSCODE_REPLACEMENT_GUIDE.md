# Neovim as a Complete VSCode Replacement - Configuration Analysis & Guide

**Author's Config Analysis Date**: November 2025  
**Configuration Owner**: DreamEcho100

---

## Table of Contents

1. [Overview](#overview)
2. [Core Configuration](#core-configuration)
3. [Plugin Ecosystem](#plugin-ecosystem)
4. [VSCode Feature Mapping](#vscode-feature-mapping)
5. [Essential Keybindings](#essential-keybindings)
6. [Missing Features & Recommendations](#missing-features--recommendations)
7. [Workflow Tips](#workflow-tips)
8. [Learning Resources](#learning-resources)

---

## Overview

This Neovim configuration provides a modern, VSCode-like development environment with extensive language support, Git integration, file exploration, fuzzy finding, and intelligent code completion. It's built using **Lazy.nvim** for plugin management and follows a modular structure.

### Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── lua/de100/
│   ├── core/
│   │   ├── options.lua      # Editor settings
│   │   └── keymaps.lua      # Key mappings
│   ├── lazy.lua             # Plugin manager setup
│   ├── lsp.lua              # LSP keybindings
│   └── plugins/             # Individual plugin configs
│       ├── lsp/             # LSP-specific plugins
│       └── *.lua            # Feature plugins
```

---

## Core Configuration

### Editor Settings (`lua/de100/core/options.lua`)

#### Key Features:

- **Line Numbers**: Absolute + relative line numbers for easy navigation
- **Clipboard**: System clipboard integration (`<Space>` is leader key)
- **Indentation**: 2-space tabs, smart indentation
- **Search**: Case-insensitive with smart case override
- **Performance**: Fast update time (250ms), optimized swap/backup settings
- **Persistent Undo**: Never lose your edit history
- **24-bit Colors**: True color support for modern themes

---

## Plugin Ecosystem

### 1. **File Management & Navigation**

#### Neo-tree (`nvim-neo-tree`)

**VSCode Equivalent**: File Explorer sidebar

**Features**:

- File tree with icons
- Git status integration
- File operations (create, delete, rename, move)
- Split support

**Keybindings**:

```vim
<leader>e     - Toggle Neo-tree (left side)
\             - Reveal current file in tree
<leader>ngs   - Open Git status window
```

**Usage**:

- `a` - Create new file/folder
- `d` - Delete file
- `r` - Rename file
- `x` - Cut file
- `c` - Copy file
- `p` - Paste
- `y` - Copy file path
- `?` - Show all commands

---

### 2. **Fuzzy Finding & Search**

#### Telescope (`nvim-telescope/telescope.nvim`)

**VSCode Equivalent**: Command Palette + File Search + Global Search

**Keybindings**:

```vim
<leader>sf    - [S]earch [F]iles (Ctrl+P in VSCode)
<leader>sg    - [S]earch by [G]rep (global text search)
<leader>sw    - [S]earch current [W]ord under cursor
<leader>sh    - [S]earch [H]elp documentation
<leader>sk    - [S]earch [K]eymaps
<leader>sd    - [S]earch [D]iagnostics (problems)
<leader>sr    - [S]earch [R]esume last search
<leader>s.    - [S]earch recent files
<leader><leader> - Find existing buffers (open files)
<leader>/     - Fuzzy search in current buffer
```

**Inside Telescope**:

```vim
<C-k>         - Move up
<C-j>         - Move down
<C-l>         - Open file
<C-/>         - Show help (insert mode)
?             - Show help (normal mode)
```

---

### 3. **Language Server Protocol (LSP)**

#### Mason + LSP Config

**VSCode Equivalent**: Built-in IntelliSense

**Installed Language Servers**:

- **JavaScript/TypeScript**: ts_ls, eslint
- **Web**: html, cssls, tailwindcss, emmet_ls
- **Python**: pyright, pylsp, ruff
- **Lua**: lua_ls
- **C/C++**: clangd
- **Database**: sqlls
- **DevOps**: dockerls, terraformls, yamlls
- **Others**: graphql, prismals, svelte, jsonls

**LSP Keybindings** (when LSP is attached):

```vim
gd            - [G]o to [D]efinition
gD            - [G]o to [D]eclaration
gi            - [G]o to [I]mplementation
gt            - [G]o to [T]ype definition
gR            - Show LSP [R]eferences (Telescope)
K             - Show documentation (hover)
<leader>ca    - [C]ode [A]ctions
<leader>rn    - [R]e[n]ame symbol
<leader>d     - Show line [D]iagnostics
<leader>D     - Show buffer [D]iagnostics
[d            - Go to previous diagnostic
]d            - Go to next diagnostic
<leader>rs    - [R]estart LSP [S]erver
```

---

### 4. **Code Completion**

#### nvim-cmp + LuaSnip

**VSCode Equivalent**: IntelliSense completion

**Features**:

- LSP-based completions
- Snippet support (VS Code-style snippets)
- Buffer text completion
- File path completion
- Visual icons for completion types

**Completion Keybindings** (in insert mode):

```vim
<C-k>         - Previous suggestion
<C-j>         - Next suggestion
<C-Space>     - Trigger completion
<C-e>         - Close completion
<CR>          - Confirm selection
<C-b>         - Scroll docs up
<C-f>         - Scroll docs down
```

---

### 5. **Code Formatting**

#### Conform.nvim

**VSCode Equivalent**: Format Document (Shift+Alt+F)

**Configured Formatters**:

- **JS/TS/JSX/TSX**: biome → prettierd → prettier (first available)
- **Python**: isort + black
- **Lua**: stylua
- **C/C++**: clang-format
- **Web**: prettier for CSS, HTML, JSON, YAML, Markdown

**Features**:

- **Auto-format on save** (enabled by default)
- TypeScript organize imports on save

**Keybindings**:

```vim
<leader>f     - Format buffer
<leader>mp    - Format file or range (visual mode)
<leader>sn    - Save without auto-formatting
```

---

### 6. **Linting**

#### nvim-lint

**VSCode Equivalent**: ESLint/Pylint integration

**Configured Linters**:

- **Python**: pylint

**Keybindings**:

```vim
<leader>l     - Trigger linting manually
```

**Auto-triggers**: On file enter, save, and leaving insert mode

---

### 7. **Git Integration**

#### Gitsigns

**VSCode Equivalent**: Git gutter + inline blame

**Features**:

- Git diff in sign column (gutter)
- Inline blame
- Hunk navigation and staging
- Preview changes

**Keybindings**:

```vim
]h            - Next git hunk
[h            - Previous git hunk
<leader>hs    - [H]unk [S]tage
<leader>hr    - [H]unk [R]eset
<leader>hS    - Stage entire buffer
<leader>hR    - Reset entire buffer
<leader>hu    - [U]ndo stage hunk
<leader>hp    - [H]unk [P]review
<leader>hb    - [B]lame line (full)
<leader>hB    - Toggle inline blame
<leader>hd    - [D]iff this
<leader>hD    - Diff against previous commit
```

#### LazyGit

**VSCode Equivalent**: GitLens + Source Control panel

**Keybindings**:

```vim
<leader>lg    - Open [L]azy[G]it (TUI Git client)
```

**LazyGit Features**:

- Full Git workflow in terminal UI
- Commit, push, pull, merge, rebase
- Visual diff and staging
- Branch management

---

### 8. **Syntax Highlighting**

#### Treesitter

**VSCode Equivalent**: TextMate grammars

**Features**:

- Accurate, AST-based syntax highlighting
- Code folding
- Incremental selection
- Auto-install parsers

**Supported Languages**:
JavaScript, TypeScript, HTML, CSS, Python, Lua, C, Go, Java, JSON, YAML, Markdown, SQL, Terraform, Docker, Bash, and more

**Keybindings**:

```vim
<C-space>     - Start/expand incremental selection
<BS>          - Shrink selection
```

---

### 9. **Diagnostics & Problems**

#### Trouble

**VSCode Equivalent**: Problems Panel

**Keybindings**:

```vim
<leader>xw    - Open workspace diagnostics
<leader>xd    - Open document diagnostics
<leader>xq    - Open quickfix list
<leader>xl    - Open location list
<leader>xt    - Open TODOs
```

#### TODO Comments

**Features**: Highlight and navigate TODO, FIXME, NOTE, etc.

**Keybindings**:

```vim
]t            - Next todo comment
[t            - Previous todo comment
```

---

### 10. **UI Enhancements**

#### Lualine

**VSCode Equivalent**: Status bar

**Displays**:

- Current mode
- Git branch
- File name and status
- LSP status
- Diagnostics count
- File encoding
- Cursor position

#### Bufferline

**VSCode Equivalent**: Tab bar

**Features**:

- Visual tab/buffer list
- Modified indicators
- Close buttons

#### Alpha (Dashboard)

**VSCode Equivalent**: Welcome screen

**Quick Actions**:

- New file
- Find files
- Find text
- Quit

---

### 11. **Theme**

#### Tokyo Night

**VSCode Equivalent**: Color theme

The config uses Tokyo Night theme with automatic dark mode detection.

---

## Recently added

### 1. **Multi-cursor Editing**

**VSCode**: Alt+Click or Ctrl+D

**Recommendation**: Install `vim-visual-multi`

```lua
return {
  "mg979/vim-visual-multi",
  branch = "master",
}
```

**Usage**:

- `<C-n>` - Start multi-cursor on word
- `<C-Down>/<C-Up>` - Add cursors vertically
- `n/N` - Get next/previous occurrence
- `q` - Skip current
- `Q` - Remove current cursor

---

## VSCode Feature Mapping

| VSCode Feature          | Neovim Equivalent    | Keybinding                |
| ----------------------- | -------------------- | ------------------------- |
| **File Explorer**       | Neo-tree             | `<leader>e`               |
| **Command Palette**     | Telescope            | `<leader>ss`              |
| **Quick Open (Ctrl+P)** | Telescope Find Files | `<leader>sf`              |
| **Find in Files**       | Telescope Live Grep  | `<leader>sg`              |
| **Go to Definition**    | LSP                  | `gd`                      |
| **Find References**     | LSP + Telescope      | `gR`                      |
| **Rename Symbol**       | LSP                  | `<leader>rn`              |
| **Code Actions**        | LSP                  | `<leader>ca`              |
| **Format Document**     | Conform              | `<leader>f`               |
| **Problems Panel**      | Trouble              | `<leader>xw`              |
| **Integrated Terminal** | Built-in             | `:term` or `<C-\>`        |
| **Git Integration**     | Gitsigns + LazyGit   | `<leader>lg`              |
| **Split Editor**        | Native splits        | `<leader>v` / `<leader>h` |
| **Next/Prev Error**     | Diagnostics          | `]d` / `[d`               |
| **Hover Info**          | LSP                  | `K`                       |
| **Search in File**      | Telescope            | `<leader>/`               |
| **IntelliSense**        | nvim-cmp             | `<C-Space>`               |
| **Breadcrumbs**         | Lualine              | (status bar)              |
| **Zen Mode**            | Not configured       | _See recommendations_     |
| **Live Share**          | Not available        | _See recommendations_     |

---

## Essential Keybindings

### Leader Key: `<Space>`

### Core Navigation

```vim
# Window/Split Navigation
<C-h>         - Move to left split
<C-j>         - Move to lower split
<C-k>         - Move to upper split
<C-l>         - Move to right split

# Window Management
<leader>v     - Split vertically
<leader>h     - Split horizontally
<leader>se    - Make splits equal size
<leader>xs    - Close current split

# Tab Management
<leader>to    - Open new tab
<leader>tx    - Close current tab
<leader>tn    - Next tab
<leader>tp    - Previous tab
<leader>tf    - Open current buffer in new tab

# Buffer Navigation
<Tab>         - Next buffer
<S-Tab>       - Previous buffer
<leader>bx     - Close current buffer
<leader>bo     - New buffer
```

### Editing

```vim
# Basic Operations
<C-s>         - Save file
<C-q>         - Quit file
<leader>sn    - Save without auto-format

# Delete/Cut/Paste
x             - Delete character (no copy)
p (visual)    - Paste without overwriting register

# Indentation (visual mode)
<             - Unindent and stay in visual
>             - Indent and stay in visual

# Scrolling
<C-d>         - Scroll down and center
<C-u>         - Scroll up and center
n             - Next search result (centered)
N             - Previous search result (centered)
```

### Window Resizing

```vim
<Up>          - Decrease height
<Down>        - Increase height
<Left>        - Decrease width
<Right>       - Increase width
```

### Utilities

```vim
<leader>lw    - Toggle line wrapping
<leader>nh    - Clear search highlights
```

---

#### **Debugging (DAP - Debug Adapter Protocol)**

**VSCode**: Built-in debugger with breakpoints

**Recommendation**: Install `nvim-dap` + UI plugins

```lua
-- Add to plugins/
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-telescope/telescope-dap.nvim",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- JavaScript/TypeScript
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}"
          },
        }
      }

      -- Python
      dap.adapters.python = {
        type = "executable",
        command = "python",
        args = { "-m", "debugpy.adapter" },
      }

      dapui.setup()

      -- Auto-open UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
    end,
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      { "<leader>bo", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
    },
  }
}
```

**Additional Tools** (install via Mason):

- `js-debug-adapter` (JS/TS)
- `debugpy` (Python)
- `codelldb` (C/C++/Rust)

**Debug controls:**

- `<F5>` - Continue/Start
- `<F1>` - Step Into
- `<F2>` - Step Over
- `<F3>` - Step Out
- `<F7>` - Toggle Debug UI
- `<leader>b` - Toggle Breakpoint
- `<leader>B` - Conditional Breakpoint

---

## Missing Features & Recommendations

### ❌ Features Not Yet Configured

#### 2. **Testing Integration**

**VSCode**: Test Explorer

**Recommendation**: Install `nvim-neotest`

```lua
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Language-specific adapters
    "nvim-neotest/neotest-python",
    "nvim-neotest/neotest-jest",
    "nvim-neotest/neotest-go",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-python"),
        require("neotest-jest")({
          jestCommand = "npm test --",
          env = { CI = true },
        }),
      },
    })
  end,
  keys = {
    { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
    { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run test file" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle test summary" },
    { "<leader>to", function() require("neotest").output.open() end, desc = "Show test output" },
  },
}
```

---

#### 3. **Database Client**

**VSCode**: Database extensions (e.g., SQLTools)

**Recommendation**: Install `vim-dadbod` + UI

```lua
return {
  {
    "tpope/vim-dadbod",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
    end,
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<cr>", desc = "Toggle Database UI" },
    },
  }
}
```

**Usage**: Add connections in `~/.config/nvim/db_ui/` or use `:DBUI`

---

#### 4. **REST Client**

**VSCode**: REST Client / Thunder Client extensions

**Recommendation**: Install `rest.nvim`

```lua
return {
  "rest-nvim/rest.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("rest-nvim").setup()
  end,
  keys = {
    { "<leader>rr", "<Plug>RestNvim", desc = "Run REST request" },
    { "<leader>rp", "<Plug>RestNvimPreview", desc = "Preview REST request" },
  },
}
```

**Usage**: Create `.http` files with requests, run with `<leader>rr`

---

#### 5. **Markdown Preview**

**VSCode**: Built-in Markdown preview

**Recommendation**: Install `markdown-preview.nvim`

```lua
return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview" },
  build = "cd app && npm install",
  ft = { "markdown" },
  keys = {
    { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown Preview" },
  },
}
```

---

#### 6. **Project/Session Management**

**VSCode**: Workspace concept

**Recommendation**: Install `auto-session` or `persistence.nvim`

```lua
return {
  "rmagatti/auto-session",
  config = function()
    require("auto-session").setup({
      log_level = "error",
      auto_session_suppress_dirs = { "~/", "~/Downloads", "/" },
    })
  end,
  keys = {
    { "<leader>wr", "<cmd>SessionRestore<cr>", desc = "Restore session" },
    { "<leader>ws", "<cmd>SessionSave<cr>", desc = "Save session" },
  },
}
```

---

#### 7. **Zen Mode / Distraction-Free Writing**

**VSCode**: Zen Mode (Ctrl+K Z)

**Recommendation**: Install `zen-mode.nvim`

```lua
return {
  "folke/zen-mode.nvim",
  config = function()
    require("zen-mode").setup({
      window = {
        width = 120,
        options = {
          number = false,
          relativenumber = false,
        }
      }
    })
  end,
  keys = {
    { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
  },
}
```

---

#### 8. **AI/Copilot Integration**

**VSCode**: GitHub Copilot

**Recommendations**:

**Option A: GitHub Copilot** (official)

```lua
return {
  "github/copilot.vim",
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
    })
  end,
}
```

**Option B: CopilotChat** (with chat interface)

```lua
return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "github/copilot.vim" },
    { "nvim-lua/plenary.nvim" },
  },
  opts = {},
  keys = {
    { "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "Toggle Copilot Chat" },
  },
}
```

**Option C: Local AI** (free, private)

```lua
return {
  "Exafunction/codeium.vim",
  config = function()
    vim.g.codeium_disable_bindings = 1
    vim.keymap.set("i", "<C-g>", function() return vim.fn["codeium#Accept"]() end, { expr = true })
  end,
}
```

---

#### 10. **Live Share / Collaborative Editing**

**VSCode**: Live Share extension

**Status**: No direct equivalent for Neovim yet

**Alternatives**:

- Use **tmux** with shared session: `tmux -S /tmp/pair new -s pair`
- Use **tmate**: Cloud-based tmux sharing
- Use **gotty**: Share terminal over web
- Use external tools: **Tuple**, **Screen**, **CodeTogether**

---

#### 11. **Advanced Git Blame & History**

**VSCode**: GitLens extension

**Recommendation**: Install `git-blame.nvim` and `diffview.nvim`

```lua
return {
  {
    "f-person/git-blame.nvim",
    config = function()
      require("gitblame").setup({
        enabled = false, -- Toggle with :GitBlameToggle
      })
    end,
    keys = {
      { "<leader>gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
    },
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diff View" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
    },
  },
}
```

---

#### 12. **Snippet Management**

**Current**: Basic snippet support via LuaSnip + friendly-snippets

**Enhancement**: Custom snippets

Create `~/.config/nvim/snippets/typescript.json`:

```json
{
  "React Functional Component": {
    "prefix": "rfc",
    "body": [
      "import React from 'react';",
      "",
      "interface ${1:ComponentName}Props {",
      "  $2",
      "}",
      "",
      "const $1: React.FC<$1Props> = ({ $3 }) => {",
      "  return (",
      "    <div>",
      "      $0",
      "    </div>",
      "  );",
      "};",
      "",
      "export default $1;"
    ],
    "description": "Create a React functional component with TypeScript"
  }
}
```

---

#### 13. **Better Terminal Integration**

**VSCode**: Integrated terminal with tabs

**Recommendation**: Install `toggleterm.nvim`

```lua
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    size = 20,
    open_mapping = [[<c-\>]],
    direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
    float_opts = {
      border = "curved",
    },
  },
  keys = {
    { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
  },
}
```

---

#### 14. **File Templates**

**VSCode**: Snippet extensions for file templates

**Recommendation**: Install `nvim-genghis` or create autocmds

```lua
-- Add to core/autocmds.lua
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.tsx",
  callback = function()
    local filename = vim.fn.expand("%:t:r")
    local template = {
      "import React from 'react';",
      "",
      "interface " .. filename .. "Props {",
      "",
      "}",
      "",
      "const " .. filename .. ": React.FC<" .. filename .. "Props> = () => {",
      "  return (",
      "    <div>",
      "      ",
      "    </div>",
      "  );",
      "};",
      "",
      "export default " .. filename .. ";",
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
  end,
})
```

---

#### 15. **Package Manager Integration**

**VSCode**: npm scripts in sidebar

**Recommendation**: Install `package-info.nvim`

```lua
return {
  "vuki656/package-info.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  config = function()
    require("package-info").setup()
  end,
  keys = {
    { "<leader>ns", "<cmd>lua require('package-info').show()<cr>", desc = "Show package info" },
    { "<leader>nu", "<cmd>lua require('package-info').update()<cr>", desc = "Update package" },
  },
}
```

---

## Workflow Tips

### 1. **Learning Vim Motions**

- **Start with basics**: `hjkl`, `w`, `b`, `e`, `0`, `$`
- **Master text objects**: `ciw` (change inner word), `dip` (delete inner paragraph), `vi{` (select inner braces)
- **Use counts**: `3dd` (delete 3 lines), `5j` (move down 5 lines)
- **Practice daily**: Use `vimtutor` or plugins like `vim-be-good`

### 2. **Project Workflow**

1. Open Neovim in project root: `nvim .`
2. Use `<leader>e` to toggle file tree
3. Use `<leader>sf` to fuzzy find files
4. Use `<leader>sg` to search code globally
5. Navigate with `gd`, `gR`, LSP keybindings
6. Use `<leader>lg` for Git operations

### 3. **Multi-file Editing**

- Use **buffers** instead of tabs (like VSCode's editor groups)
- `<Tab>` / `<S-Tab>` to cycle through open files
- `<leader><leader>` to see all buffers in Telescope
- Split windows with `<leader>v` and `<leader>h`

### 4. **Code Navigation**

- `gd` - Go to definition
- `<C-o>` - Jump back (built-in)
- `<C-i>` - Jump forward (built-in)
- `<leader>sw` - Search word under cursor across project
- `%` - Jump between matching brackets/tags

### 5. **Refactoring**

- `<leader>rn` - Rename symbol (LSP)
- `<leader>ca` - Code actions (organize imports, quick fixes)
- Visual select + `<leader>f` - Format selection
- `:.s/old/new/g` - Replace in line
- `:%s/old/new/g` - Replace in file

### 6. **Git Workflow**

1. `<leader>lg` - Open LazyGit for commits/push/pull
2. `<leader>hb` - Check Git blame
3. `[h` / `]h` - Navigate hunks
4. `<leader>hp` - Preview changes
5. `<leader>hs` - Stage hunk
6. `<leader>hr` - Reset hunk

### 7. **Customization**

- Edit `~/.config/nvim/lua/de100/core/keymaps.lua` for keybindings
- Edit `~/.config/nvim/lua/de100/core/options.lua` for settings
- Add plugins in `~/.config/nvim/lua/de100/plugins/`
- Run `:Lazy` to manage plugins (update, install, remove)

---

## Learning Resources

### Vim/Neovim Basics

- **vimtutor**: Built-in tutorial - run `vimtutor` in terminal
- **Vim Adventures**: gamified learning - vim-adventures.com
- **Neovim Kickstart**: josean.com/posts/neovim-setup
- **The Primeagen**: YouTube channel for Neovim workflows

### Advanced Topics

- **LSP Guide**: neovim.io/doc/user/lsp.html
- **Lua Guide**: learnxinyminutes.com/docs/lua/
- **Telescope**: github.com/nvim-telescope/telescope.nvim
- **Lazy.nvim**: github.com/folke/lazy.nvim

### Cheat Sheets

- **Vim**: vim.rtorr.com
- **Neovim**: neovim.io/doc/user/quickref.html
- **This Config**: Run `:Telescope keymaps` to see all keybindings

### Communities

- **Reddit**: r/neovim
- **Discord**: Neovim Discord server
- **GitHub Discussions**: github.com/neovim/neovim/discussions

---

## Quick Reference Card

### Most Used Commands (Print This!)

```
┌─────────────────────────────────────────────────────────────┐
│                    NEOVIM QUICK REFERENCE                   │
├─────────────────────────────────────────────────────────────┤
│ Leader Key: <Space>                                         │
├─────────────────────────────────────────────────────────────┤
│ FILE MANAGEMENT                                             │
│   <leader>e     Toggle file explorer                        │
│   <leader>sf    Search files (Ctrl+P)                       │
│   <leader>sg    Search in files (global grep)               │
│   <C-s>         Save file                                   │
│   <leader>bx     Close buffer                                │
├─────────────────────────────────────────────────────────────┤
│ CODE NAVIGATION                                             │
│   gd            Go to definition                            │
│   gR            Show references                             │
│   K             Show documentation                          │
│   [d / ]d       Previous/next diagnostic                    │
├─────────────────────────────────────────────────────────────┤
│ CODE EDITING                                                │
│   <leader>ca    Code actions                                │
│   <leader>rn    Rename symbol                               │
│   <leader>f     Format document                             │
│   <leader>l     Lint file                                   │
├─────────────────────────────────────────────────────────────┤
│ GIT                                                         │
│   <leader>lg    Open LazyGit                                │
│   <leader>hp    Preview hunk                                │
│   <leader>hs    Stage hunk                                  │
│   [h / ]h       Previous/next hunk                          │
├─────────────────────────────────────────────────────────────┤
│ WINDOWS & TABS                                              │
│   <C-h/j/k/l>   Navigate splits                             │
│   <leader>v     Vertical split                              │
│   <leader>h     Horizontal split                            │
│   <Tab>         Next buffer                                 │
│   <S-Tab>       Previous buffer                             │
├─────────────────────────────────────────────────────────────┤
│ DIAGNOSTICS                                                 │
│   <leader>xw    Workspace diagnostics                       │
│   <leader>xd    Document diagnostics                        │
│   <leader>d     Show line diagnostic                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Conclusion

This Neovim configuration provides **95% of VSCode's functionality** with superior performance, full keyboard control, and infinite customizability. The missing 5% (Live Share, some GUI features) can be filled with community plugins or alternative workflows.

**Advantages over VSCode**:

- ✅ Significantly faster startup and operation
- ✅ Lower memory usage
- ✅ Works over SSH seamlessly
- ✅ Fully keyboard-driven workflow
- ✅ Infinite customization
- ✅ Modal editing (once mastered)
- ✅ Open source and extensible

**Transition Tips**:

1. Start by using it for one hour a day
2. Keep VSCode open initially for reference
3. Focus on learning one new motion/command per day
4. Customize keybindings to match your VSCode muscle memory initially
5. After 2-3 weeks, you'll be more productive than in VSCode

**Remember**: The hardest part is the first week. After that, you'll never want to go back!

---

## Maintenance Commands

```bash
# Update all plugins
:Lazy update

# Install missing LSP servers/formatters
:Mason

# Check health
:checkhealth

# Reload configuration
:source ~/.config/nvim/init.lua

# View plugin logs
:Lazy log

# View LSP logs
:LspLog
```

---

**Config Version**: November 2025  
**Maintainer**: DreamEcho100  
**License**: Use freely, customize extensively! 🚀
