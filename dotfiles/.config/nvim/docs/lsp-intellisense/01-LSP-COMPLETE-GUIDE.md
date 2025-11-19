# LSP: Complete Language Server Protocol Guide

## VSCode Feature Replacement

LSP in Neovim replaces **ALL of VSCode's IntelliSense features**:
- ✅ Go to Definition
- ✅ Find References
- ✅ Hover Documentation
- ✅ Code Actions (Quick Fixes)
- ✅ Rename Symbol
- ✅ Signature Help
- ✅ Diagnostics (Errors/Warnings)
- ✅ Auto-imports
- ✅ Organize Imports

**Advantage**: Native integration, faster, more customizable, works over SSH.

## Your Configuration Analysis

Your LSP setup is split across multiple files:

### File Structure

```
lua/de100/
├── lsp.lua                    (78 lines) - Keybindings & diagnostics
└── plugins/lsp/
    ├── mason.lua              (72 lines) - Tool installer
    └── lsp.lua                (22 lines) - LSP capabilities
```

## Installed Language Servers

### Your Mason Configuration

**Location**: `lua/de100/plugins/lsp/mason.lua`

#### Comprehensive Language Support

```lua
ensure_installed = {
    -- JavaScript/TypeScript Ecosystem
    "ts_ls",         -- TypeScript/JavaScript LSP
    "eslint",        -- ESLint diagnostics
    "vtsls",         -- Vue/TypeScript LSP
    
    -- Web Development
    "html",          -- HTML LSP
    "cssls",         -- CSS LSP
    "cssmodules_ls", -- CSS Modules
    "tailwindcss",   -- Tailwind CSS
    "emmet_ls",      -- Emmet abbreviations
    
    -- Frontend Frameworks
    "svelte",        -- Svelte framework
    
    -- Backend & APIs
    "graphql",       -- GraphQL
    "prismals",      -- Prisma ORM
    
    -- Programming Languages
    "lua_ls",        -- Lua (for Neovim config)
    "pyright",       -- Python type checker
    "pylsp",         -- Python LSP
    "ruff",          -- Python linter/formatter
    "clangd",        -- C/C++ LSP
    
    -- Data & Config
    "jsonls",        -- JSON
    "yamlls",        -- YAML
    "sqlls",         -- SQL
    
    -- DevOps
    "dockerls",      -- Docker
    "terraformls",   -- Terraform
    
    -- Formatters
    "biome",         -- JS/TS/JSON formatter
}
```

### Additional Tools (mason-tool-installer)

```lua
ensure_installed = {
    -- Python
    "isort",         -- Import sorter
    "black",         -- Formatter
    "pylint",        -- Linter
    
    -- JavaScript/TypeScript
    "eslint_d",      -- Fast ESLint
    "prettierd",     -- Fast Prettier
    
    -- C/C++
    "clang-format",  -- Formatter
    "cpplint",       -- Linter
    
    -- Shell
    "shfmt",         -- Shell formatter
    
    -- Build Systems
    "checkmake",     -- Makefile linter
    
    -- Lua
    "stylua",        -- Lua formatter
}
```

## Keybindings Analysis

**Location**: `lua/de100/lsp.lua`

All LSP keybindings are set up via `LspAttach` autocmd:

```lua
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        -- Keybindings only available when LSP attaches to buffer
    end
})
```

### Your LSP Keybindings

#### Navigation Keybindings

| Keybinding | LSP Method | VSCode Equivalent | Description |
|------------|------------|-------------------|-------------|
| `gd` | `definition` | F12 | Go to definition |
| `gD` | `declaration` | - | Go to declaration (C/C++) |
| `gi` | `implementations` | Ctrl+F12 | Go to implementation |
| `gt` | `type_definitions` | - | Go to type definition |
| `gR` | `references` | Shift+F12 | Find all references |

#### Code Intelligence

| Keybinding | LSP Method | VSCode Equivalent | Description |
|------------|------------|-------------------|-------------|
| `K` | `hover` | Hover mouse | Show documentation |
| `<leader>ca` | `code_action` | Ctrl+. | Show code actions |
| `<leader>rn` | `rename` | F2 | Rename symbol |

#### Diagnostics (Errors/Warnings)

| Keybinding | Action | VSCode Equivalent | Description |
|------------|--------|-------------------|-------------|
| `<leader>d` | `open_float` | Hover on error | Show line diagnostics |
| `<leader>D` | Telescope diagnostics | Ctrl+Shift+M | Show all diagnostics |
| `[d` | `goto_prev` | F8 | Previous diagnostic |
| `]d` | `goto_next` | Shift+F8 | Next diagnostic |
| `<leader>q` | `setloclist` | - | Open location list |
| `<leader>rs` | `:LspRestart` | - | Restart LSP server |

### Enhanced Diagnostic Navigation

Your config includes **smart diagnostic jumping** with floating windows:

```lua
-- Previous diagnostic
keymap.set("n", "[d", function()
    vim.diagnostic.jump({
        count = -1,
        float = true  -- Shows diagnostic in float
    })
end, opts)

-- Next diagnostic
keymap.set("n", "]d", function()
    vim.diagnostic.jump({
        count = 1,
        float = true  -- Shows diagnostic in float
    })
end, opts)
```

**Advantage over VSCode**: Diagnostic message appears immediately without hover.

## Diagnostic Configuration

**Location**: `lua/de100/lsp.lua` (bottom)

### Custom Diagnostic Symbols

```lua
vim.diagnostic.config({
    signs = {
        text = {
            [severity.ERROR] = " ",    -- Error icon
            [severity.WARN] = " ",     -- Warning icon
            [severity.HINT] = "󰠠 ",    -- Hint icon
            [severity.INFO] = " "      -- Info icon
        }
    }
})
```

These appear in the **sign column** (left gutter) next to line numbers.

### Diagnostic Severity Levels

1. **ERROR** `` - Code won't compile/run
2. **WARN** `` - Potential issues
3. **HINT** `󰠠` - Suggestions for improvement
4. **INFO** `` - Informational messages

## Language Server Behaviors

### TypeScript/JavaScript (ts_ls)

**Features Available**:
- Type checking
- Auto-imports
- Organize imports (via conform.nvim)
- Rename refactoring
- Extract to function/constant
- Implement interface
- Add missing imports
- Remove unused imports

**Your Integration**: Organize imports on save
```lua
-- In formatting.lua
client:request_sync("workspace/executeCommand", {
    command = "_typescript.organizeImports",
    arguments = {vim.api.nvim_buf_get_name(ev.buf)}
})
```

**Code Actions Available**:
- Fix all fixable issues
- Add missing function
- Implement interface
- Convert to async/await
- Infer return type

### Python (pyright + pylsp + ruff)

**Multi-Server Strategy**:
1. **pyright** - Type checking, IntelliSense
2. **pylsp** - Additional language features
3. **ruff** - Fast linting/formatting (via conform.nvim)

**Features**:
- Type inference
- Auto-imports
- Extract variable/method
- Implement abstract methods
- Generate docstrings (via code actions)

**Code Actions**:
- Add type hints
- Import symbol
- Organize imports
- Generate `__init__` method

### C/C++ (clangd)

**Features**:
- Symbol indexing
- Include management
- Signature help
- Type hierarchy
- Call hierarchy
- Code completion with snippets

**Code Actions**:
- Fix include paths
- Implement declarations
- Generate getters/setters
- Extract function

### Lua (lua_ls)

**Configured for Neovim Development**:
- Understands `vim.*` API
- Workspace library awareness
- Annotation support
- Type checking

**Enhanced by lazydev.nvim**:
```lua
dependencies = {
    { "folke/lazydev.nvim", opts = {} }
}
```

**Features**:
- Neovim API completion
- Plugin API completion
- Type annotations
- Workspace diagnostics

### HTML (html)

**Features**:
- Tag completion
- Attribute completion
- Auto-close tags
- Hover info for tags/attributes

### CSS (cssls + cssmodules_ls + tailwindcss)

**Multiple Servers**:
1. **cssls** - Standard CSS
2. **cssmodules_ls** - CSS Modules
3. **tailwindcss** - Tailwind classes

**Features**:
- Class name completion
- Color preview (with plugins)
- Property completion
- Vendor prefix suggestions

### Emmet (emmet_ls)

**HTML/CSS Abbreviations**:
```html
div>ul>li*3 → <div><ul><li></li><li></li><li></li></ul></div>
```

**Expansion Trigger**: Usually `<C-y>,` or integrated with completion

## LSP Capabilities

**Location**: `lua/de100/plugins/lsp/lsp.lua`

### CMP Integration

```lua
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local capabilities = cmp_nvim_lsp.default_capabilities()

vim.lsp.config("*", {
    capabilities = capabilities
})
```

**What This Does**:
1. Tells LSP servers you support snippet expansion
2. Enables completion items (functions, variables, etc.)
3. Enables additional text edits (auto-imports)
4. Enables resolve support (lazy loading details)

### File Operations Integration

```lua
dependencies = {
    {
        "antosha417/nvim-lsp-file-operations",
        config = true
    }
}
```

**Auto-Updates**:
- Rename file → Updates imports automatically
- Move file → Updates imports automatically
- Delete file → Removes imports automatically

**Supported Languages**: TypeScript, JavaScript, Python, Go, Rust, etc.

## Mason: Package Manager

### Commands

```vim
:Mason                  " Open Mason UI
:MasonInstall ts_ls     " Install TypeScript LSP
:MasonUninstall ts_ls   " Uninstall
:MasonUpdate            " Update all packages
:MasonLog               " View installation logs
```

### Mason UI Navigation

| Key | Action |
|-----|--------|
| `i` | Install |
| `u` | Uninstall |
| `U` | Update |
| `X` | Uninstall all |
| `c` | Check for updates |
| `g?` | Help |
| `q` | Close |

### Installation Locations

All tools installed to:
```
~/.local/share/nvim/mason/
├── bin/           # Executables
└── packages/      # Package files
```

### Auto-Installation

Your config ensures tools are installed on startup:

```lua
{
    "williamboman/mason-lspconfig.nvim",
    opts = {
        ensure_installed = { ... }
    }
},
{
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
        ensure_installed = { ... }
    }
}
```

**First Launch**: All servers install automatically (takes 2-5 minutes)

## Common Workflows

### 1. Understanding Code

```vim
# Hover on function
K                 " Shows signature & docs
gd                " Go to definition
gR                " Find all usages
gi                " Go to implementation
```

### 2. Refactoring

```vim
# Rename variable
<leader>rn        " Rename across all files
Type new name
<Enter>

# Extract function
Visual select code
<leader>ca        " Code actions
Select "Extract to function"
```

### 3. Fixing Errors

```vim
]d                " Jump to error
<leader>d         " Read error message
<leader>ca        " See available fixes
Select fix
<Enter>
```

### 4. Import Management

```vim
# TypeScript example
# Saving file automatically:
1. Adds missing imports
2. Removes unused imports
3. Organizes alphabetically
# Thanks to conform.nvim integration!

# Manual trigger
<leader>f         " Format (includes organize imports)
```

### 5. Exploring API

```vim
# In Lua config file
vim.<C-Space>     " Shows vim.* API
Type: vim.api.nvim_
# Completion shows all nvim_* functions
<CR> on function
K                 " Shows documentation
```

## Language-Specific Tips

### TypeScript/JavaScript

**Auto-Import on Completion**:
```typescript
// Type component name
MyCompo<C-Space>
// Select from completion
// Import added automatically at top!
```

**Organize Imports on Save**: Already configured in `formatting.lua`

**Type Checking**:
```vim
# Check types without saving
:!tsc --noEmit
```

### Python

**Virtual Environment Detection**:
LSP automatically detects:
- `.venv/`
- `venv/`
- Poetry environments
- Conda environments

**Type Hints**:
```python
# Hover on function
K  # Shows inferred types

# Code action for type hints
<leader>ca
# Select "Add type hints"
```

### C/C++

**Compile Commands**:
Create `compile_commands.json` for best experience:
```bash
# CMake
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 .

# Make
bear -- make
```

**Code Actions**:
```cpp
// Declare function
void myFunc();

// On declaration, <leader>ca
// "Generate definition" → Creates function body
```

### Lua (Neovim Config)

**Annotations for Type Checking**:
```lua
---@param name string
---@param age number
---@return boolean
local function check(name, age)
    return age > 18
end
```

**Workspace Library**:
Your Neovim API is fully recognized thanks to `lazydev.nvim`

## Comparison: Neovim LSP vs VSCode

| Feature | Neovim LSP | VSCode |
|---------|------------|--------|
| **Startup** | Instant | 2-5 seconds |
| **Memory** | 30-50 MB | 200-500 MB |
| **Customization** | Full control | Limited settings |
| **Multi-Server** | Native support | Requires coordination |
| **Over SSH** | Perfect | Slow/buggy |
| **Configuration** | Lua code | JSON settings |
| **Protocol Version** | Latest | May lag behind |
| **Performance** | Faster | Slower |

## Troubleshooting

### LSP Not Attaching

```vim
# Check if LSP is running
:LspInfo

# Check logs
:LspLog

# Restart LSP
<leader>rs
```

**Common Issues**:
1. File type not recognized
2. LSP server not installed
3. LSP server crashed
4. Workspace not configured

### Check LSP Status

```vim
:checkhealth lsp
:checkhealth mason
```

### Server Not Installing

```vim
:Mason
# Find server
i  # Install
# Check logs if fails
:MasonLog
```

### Slow Completions

1. **Check diagnostics frequency**:
   ```lua
   vim.opt.updatetime = 250  -- Already in your config
   ```

2. **Disable certain servers**:
   ```lua
   -- In mason.lua, remove from ensure_installed
   ```

3. **Check workspace size**:
   ```bash
   # Ignore large directories
   echo "node_modules/" >> .gitignore
   ```

### Errors in Config Files

**Lua Config**:
```vim
:checkhealth lazydev
```

**Missing Imports**:
Ensure `lazydev.nvim` is installed:
```lua
dependencies = {
    { "folke/lazydev.nvim", opts = {} }
}
```

## Advanced Customization

### Custom LSP Server

```lua
-- Add to lsp.lua
local lspconfig = require('lspconfig')
lspconfig.your_server.setup({
    capabilities = capabilities,
    settings = {
        -- Server-specific settings
    }
})
```

### Override Server Settings

```lua
-- Example: Configure ts_ls
require('lspconfig').ts_ls.setup({
    capabilities = capabilities,
    settings = {
        typescript = {
            inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayFunctionParameterTypeHints = true,
            }
        }
    }
})
```

### Disable Specific Diagnostic

```lua
vim.diagnostic.config({
    virtual_text = false,  -- Disable inline errors
    signs = true,
    underline = true,
    update_in_insert = false,
})
```

### Custom Diagnostic Handler

```lua
vim.diagnostic.config({
    float = {
        source = "always",  -- Show source in float
        border = "rounded",
    },
})
```

## Pro Tips

1. **Double K**: Press `K` twice to jump into hover documentation window
2. **`.` Repeat**: Use `.` to repeat code actions
3. **Quickfix from Diagnostics**: `<leader>D` → `<C-q>` → `:cfdo`
4. **Auto-Format on Save**: Already enabled in your config
5. **Multiple References**: `gR` shows in Telescope for easy filtering
6. **Jump Back**: `<C-o>` to return from definition jumps
7. **Peek Definition**: Use Telescope's preview instead of jumping
8. **Code Action Preview**: Some actions show preview before applying

## Hidden Gems

### 1. Signature Help (Insert Mode)

Many LSP servers support signature help while typing:
```typescript
function myFunc(arg1: string, arg2: number) {
myFunc(  ← Shows signature here
```

**Trigger**: Usually automatic or `<C-k>` in insert mode

### 2. Inlay Hints

For supported servers (TypeScript, Rust):
```typescript
const getValue = (x) => x * 2
         ↑ inlay: (x: number): number
```

**Enable**:
```lua
vim.lsp.inlay_hint.enable(true)
```

### 3. Workspace Symbols

```vim
:Telescope lsp_workspace_symbols
```
Search symbols across entire project

### 4. Document Symbols

```vim
:Telescope lsp_document_symbols
```
Outline of current file (like VSCode's outline)

### 5. Call Hierarchy

```vim
:lua vim.lsp.buf.incoming_calls()
:lua vim.lsp.buf.outgoing_calls()
```
See function call relationships

### 6. Type Hierarchy (Supported Languages)

```vim
:Telescope lsp_type_definitions
```
Navigate type relationships

## Resources

- **LSP Spec**: https://microsoft.github.io/language-server-protocol/
- **Neovim LSP Docs**: `:h lsp`
- **Mason Docs**: `:h mason`
- **Available Servers**: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
- **Your Config**: `~/.config/nvim/lua/de100/lsp.lua`
