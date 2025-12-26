# Code Quality: Formatting & Linting Complete Guide

## VSCode Feature Replacement

Your formatting and linting setup replaces **multiple VSCode features**:
- ✅ Format Document (Shift+Alt+F)
- ✅ Format on Save
- ✅ Organize Imports
- ✅ ESLint integration
- ✅ Prettier integration
- ✅ Python formatting (Black, isort)
- ✅ Problems panel integration

**Advantage**: Faster, more control, works identically over SSH, multi-formatter support.

## Your Configuration Analysis

### File Structure

```
lua/de100/plugins/
├── formatting.lua    (142 lines) - Format-on-save, multiple formatters
└── linting.lua       (67 lines)  - Linting integration
```

## Formatting: conform.nvim

**Location**: `lua/de100/plugins/formatting.lua`

### Plugin Configuration

```lua
{
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },  -- Lazy load
    cmd = { "ConformInfo" },
}
```

### Your Keybindings

| Keybinding | Mode | Action | Description |
|------------|------|--------|-------------|
| `<leader>f` | Normal/Visual | Format buffer/selection | Async formatting |
| `<leader>mp` | Normal/Visual | Format synchronously | Waits for completion |
| `<C-s>` | Normal | Save (with format) | Auto-format enabled |
| `<leader>sn` | Normal | Save without format | Bypasses auto-format |

### Formatter Configuration by Language

#### JavaScript/TypeScript/React

```lua
javascript = { "biome", "prettierd", "prettier", stop_after_first = true },
typescript = { "biome", "prettierd", "prettier", stop_after_first = true },
javascriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
typescriptreact = { "biome", "prettierd", "prettier", stop_after_first = true },
```

**Strategy**: Waterfall selection
1. Try **biome** first (fastest, all-in-one)
2. If not available, try **prettierd** (daemon, fast)
3. Fall back to **prettier** (standard)
4. `stop_after_first = true` means use first available

**Installation** (via Mason):
```vim
:Mason
# Install: biome, prettierd
# Prettier usually installed via npm in project
```

##### Biome

**What**: Modern replacement for ESLint + Prettier
**Speed**: 10-100x faster than Prettier
**Features**:
- Formatting
- Linting
- Import sorting
- Written in Rust

**Config**: `biome.json` in project root
```json
{
  "formatter": {
    "indentStyle": "space",
    "indentWidth": 2
  }
}
```

##### Prettierd

**What**: Prettier as a daemon (persistent process)
**Speed**: 5-10x faster than regular Prettier
**Features**:
- Keeps Prettier loaded in memory
- No startup cost per format
- Full Prettier compatibility

##### Prettier

**What**: Standard JavaScript/TypeScript formatter
**Config**: `.prettierrc` or `package.json`
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2
}
```

#### Python

```lua
python = { "isort", "black" },
```

**Strategy**: Sequential execution
1. **isort** - Sorts imports
2. **black** - Formats code

**Both run every time** (not stop_after_first).

##### isort

**Purpose**: Sort and organize Python imports
**Features**:
- Groups imports (stdlib, third-party, local)
- Removes unused imports (with --remove-unused)
- Alphabetizes within groups

**Config**: `pyproject.toml` or `.isort.cfg`
```toml
[tool.isort]
profile = "black"  # Compatible with black
line_length = 88
```

##### black

**Purpose**: Uncompromising Python formatter
**Features**:
- Opinionated (minimal config)
- PEP 8 compliant
- Consistent output

**Config**: `pyproject.toml`
```toml
[tool.black]
line-length = 88
target-version = ['py38', 'py39', 'py310']
```

#### Web (HTML/CSS/JSON/YAML/Markdown)

```lua
html = { "biome", "prettierd", "prettier", stop_after_first = true },
css = { "biome", "prettierd", "prettier", stop_after_first = true },
json = { "biome", "prettierd", "prettier", stop_after_first = true },
yaml = { "biome", "prettierd", "prettier", stop_after_first = true },
markdown = { "biome", "prettierd", "prettier", stop_after_first = true },
```

**Same strategy** as JavaScript: biome → prettierd → prettier

#### C/C++

```lua
c = { "clang_format" },
cpp = { "clang_format" },
```

**clang-format**: Industry-standard C/C++ formatter
**Config**: `.clang-format` in project root
```yaml
BasedOnStyle: Google
IndentWidth: 4
```

#### Lua

```lua
lua = { "stylua" },
```

**stylua**: Fast Lua formatter
**Config**: `stylua.toml` or `.stylua.toml`
```toml
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferSingle"
```

### Format-on-Save Strategy

Your config includes **TWO autocmds** for format-on-save:

#### Autocmd 1: TypeScript Organize Imports + Format

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
    desc = "Format before save",
    pattern = "*",
    group = vim.api.nvim_create_augroup("FormatConfig", { clear = true }),
    callback = function(ev)
        local client = vim.lsp.get_clients({ name = "ts_ls", bufnr = ev.buf })[1]
        
        if not client then
            require("conform").format(conform_opts)
            return
        end
        
        -- TypeScript: Organize imports first
        local request_result = client:request_sync(
            "workspace/executeCommand",
            {
                command = "_typescript.organizeImports",
                arguments = { vim.api.nvim_buf_get_name(ev.buf) }
            }
        )
        
        if request_result and request_result.err then
            vim.notify(request_result.err.message, vim.log.levels.ERROR)
            return
        end
        
        -- Then format
        require("conform").format(conform_opts)
    end
})
```

**Special TypeScript Handling**:
1. Detects if `ts_ls` is attached
2. Runs organize imports command
3. Then runs normal formatting

**Result**: TypeScript files get:
- Unused imports removed
- Imports organized alphabetically
- Code formatted

#### Autocmd 2: General Format

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        require("conform").format({ bufnr = args.buf })
    end
})
```

**Note**: This seems redundant with Autocmd 1. You may want to remove one.

### Format Options

```lua
default_format_opts = {
    lsp_format = "fallback"  -- Use LSP if no formatter available
},
format_on_save = {
    lsp_fallback = true,
    async = false,          -- Wait for format to complete
    timeout_ms = 3000       -- Max 3 seconds
}
```

**`lsp_format = "fallback"`**: If conform has no formatter, use LSP's formatting.

**Example**: JSON file
1. conform tries biome → prettierd → prettier
2. If none available, uses `jsonls` LSP formatter
3. Ensures file always gets formatted

### Timeout Configuration

```lua
timeout_ms = 3000  -- 3 seconds max
```

**Why**:
- Large files can take time
- Network formatters (rare) need time
- Prevents hanging on save

**If formatter exceeds timeout**: File saves without formatting, error message shown.

### Formatter Customization

```lua
formatters = {
    shfmt = {
        append_args = { "-i", "2" }  -- 2-space indent for shell scripts
    }
}
```

**Your shell script formatter**: 2-space indentation

## Linting: nvim-lint

**Location**: `lua/de100/plugins/linting.lua`

### Plugin Configuration

```lua
{
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },  -- Lazy load
}
```

### Your Keybinding

| Keybinding | Mode | Action | Description |
|------------|------|--------|-------------|
| `<leader>l` | Normal | Trigger linting | Manual lint |

### Linter Configuration

```lua
lint.linters_by_ft = {
    python = { "pylint" }
}
```

**Currently**: Only Python linting configured with pylint.

**Why limited?**: LSP handles most linting (ts_ls for TS, eslint LSP, etc.)

### Auto-Lint Triggers

```lua
vim.api.nvim_create_autocmd(
    { "BufEnter", "BufWritePost", "InsertLeave" },
    {
        group = lint_augroup,
        callback = function()
            try_linting()
        end
    }
)
```

**Linting runs on**:
1. **BufEnter** - Opening/switching to buffer
2. **BufWritePost** - After saving file
3. **InsertLeave** - Exiting insert mode

**Why InsertLeave?**: See errors immediately after typing, don't wait for save.

### Conditional Linting

Your config includes **smart config file detection**:

```lua
local function file_in_cwd(file_name)
    return vim.fs.find(file_name, {
        upward = true,
        stop = vim.loop.cwd():match("(.+)/"),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        type = "file"
    })[1]
end

local function remove_linter_if_missing_config_file(linters, linter_name, config_file_name)
    if linter_in_linters(linters, linter_name) and
       not file_in_cwd(config_file_name) then
        remove_linter(linters, linter_name)
    end
end
```

**Purpose**: Only run linters if config file exists
**Example**: Only run eslint_d if `eslint.config.js` exists

**Your commented-out example**:
```lua
-- remove_linter_if_missing_config_file(linters, "eslint_d", "eslint.config.js")
```

### pylint Configuration

**Installation**: Via Mason (`mason-tool-installer.nvim`)

**Config**: `.pylintrc` or `pyproject.toml`
```toml
[tool.pylint]
max-line-length = 88
disable = [
    "C0103",  # Invalid name
    "C0114",  # Missing module docstring
]
```

**pylint checks**:
- Code errors
- Code smells
- Unused variables
- Import issues
- Type errors
- Style violations

## Formatter vs Linter vs LSP

### Formatter (conform.nvim)
**Purpose**: Code style and appearance
**Examples**:
- Indentation
- Line length
- Quote style
- Semicolons
- Spacing

**Action**: Modifies code

### Linter (nvim-lint)
**Purpose**: Code quality and correctness
**Examples**:
- Unused variables
- Missing imports
- Deprecated APIs
- Complexity warnings
- Security issues

**Action**: Shows diagnostics, doesn't modify

### LSP (Language Server)
**Purpose**: Language intelligence + diagnostics
**Examples**:
- Type errors
- Syntax errors
- Undefined variables
- Wrong function arguments

**Action**: Shows diagnostics + provides fixes

### Your Stack

| Language | Formatter | Linter | LSP |
|----------|-----------|--------|-----|
| **TypeScript** | biome/prettier | eslint (LSP) | ts_ls |
| **JavaScript** | biome/prettier | eslint (LSP) | ts_ls |
| **Python** | black + isort | pylint | pyright |
| **Lua** | stylua | - | lua_ls |
| **C/C++** | clang-format | cpplint | clangd |
| **HTML** | prettier | - | html |
| **CSS** | prettier | - | cssls |
| **JSON** | biome/prettier | - | jsonls |

## Common Workflows

### 1. Format Current File

```vim
<leader>f        " Format buffer
# Async, doesn't block editing
```

### 2. Format Selection

```vim
Visual mode      " Select code
<leader>f        " Format selection only
```

### 3. Format Before Save

```vim
<C-s>            " Saves with auto-format
```

### 4. Save Without Formatting

```vim
<leader>sn       " Save, skip format (save no-format)
```

### 5. Check Available Formatters

```vim
:ConformInfo     " Shows formatters for current buffer
```

### 6. Manual Lint

```vim
<leader>l        " Trigger linting manually
```

### 7. TypeScript Organize Imports

```vim
# Happens automatically on save for .ts/.tsx files
<C-s>
# 1. Removes unused imports
# 2. Organizes alphabetically
# 3. Formats code
```

### 8. Python Workflow

```vim
# Edit Python file
<C-s>
# 1. isort organizes imports
# 2. black formats code
# 3. pylint shows issues (autocmd)
# 4. pyright shows type errors (LSP)
```

## Tool Installation

### Via Mason

```vim
:Mason
# Search and install:
i on tool        " Install
```

**Your auto-installed tools** (from `mason.lua`):
- biome
- prettierd
- isort
- black
- pylint
- eslint_d
- clang-format
- cpplint
- shfmt
- stylua

### Via Project (npm/pip)

Some tools prefer project-local installation:

```bash
# Prettier (project-local)
npm install --save-dev prettier

# ESLint (project-local)
npm install --save-dev eslint

# Black (project)
pip install black

# isort (project)
pip install isort
```

**conform.nvim priority**:
1. Project-local tool
2. Mason-installed tool
3. System-installed tool

## Configuration Files

### TypeScript/JavaScript

#### .prettierrc
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```

#### biome.json
```json
{
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "single",
      "semicolons": "always"
    }
  }
}
```

### Python

#### pyproject.toml
```toml
[tool.black]
line-length = 88
target-version = ['py39']

[tool.isort]
profile = "black"
line_length = 88

[tool.pylint]
max-line-length = 88
disable = ["C0111"]
```

### C/C++

#### .clang-format
```yaml
BasedOnStyle: Google
IndentWidth: 4
ColumnLimit: 100
```

### Lua

#### stylua.toml
```toml
indent_type = "Spaces"
indent_width = 2
column_width = 120
```

## Troubleshooting

### Formatter Not Running

1. **Check formatter installed**:
   ```vim
   :ConformInfo
   ```

2. **Check file type**:
   ```vim
   :set filetype?
   ```

3. **Check format-on-save**:
   ```vim
   :autocmd BufWritePre
   ```

4. **Manual format**:
   ```vim
   <leader>f
   ```

### Wrong Formatter Used

**Check priority** in `formatting.lua`:
```lua
javascript = {
    "biome",      -- First choice
    "prettierd",  -- Second choice
    "prettier",   -- Third choice
    stop_after_first = true
}
```

**Force specific formatter**:
```lua
require("conform").format({
    formatters = { "prettier" }  -- Force prettier
})
```

### Format Timeout

Increase timeout in `formatting.lua`:
```lua
format_on_save = {
    timeout_ms = 5000  -- Increase from 3000
}
```

### Linter Not Running

1. **Check linter installed**:
   ```vim
   :Mason
   ```

2. **Check linter configured**:
   ```lua
   -- In linting.lua
   lint.linters_by_ft = {
       python = { "pylint" }
   }
   ```

3. **Check autocmd**:
   ```vim
   :autocmd InsertLeave
   ```

4. **Manual trigger**:
   ```vim
   <leader>l
   ```

### Conflicting Formatters

**LSP formatter conflicts** with conform:

Option 1: Disable LSP formatter
```lua
vim.lsp.buf.format = function() end  -- Disable LSP format
```

Option 2: Prefer conform
```lua
default_format_opts = {
    lsp_format = "never"  -- Never use LSP format
}
```

Your config uses `"fallback"` (good middle ground).

## Customization Examples

### Add ESLint Linting

```lua
-- In linting.lua
lint.linters_by_ft = {
    python = { "pylint" },
    javascript = { "eslint_d" },
    typescript = { "eslint_d" },
}
```

**Requires**: `eslint_d` via Mason

### Add Rust Formatting

```lua
-- In formatting.lua
formatters_by_ft = {
    rust = { "rustfmt" },
}
```

### Custom Formatter Arguments

```lua
formatters = {
    prettier = {
        prepend_args = { "--prose-wrap", "always" },
    },
    black = {
        prepend_args = { "--line-length", "100" },
    }
}
```

### Disable Format-on-Save

```lua
format_on_save = false  -- In conform opts
```

Then use `<leader>f` manually.

### Format on Save for Specific Files Only

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },  -- Only JS/TS
    callback = function(args)
        require("conform").format({ bufnr = args.buf })
    end
})
```

### Different Formatters for Different Projects

```lua
-- In formatting.lua
local cwd = vim.fn.getcwd()
if cwd:match("legacy%-project") then
    -- Old project uses prettier
    formatters_by_ft.javascript = { "prettier" }
else
    -- New projects use biome
    formatters_by_ft.javascript = { "biome" }
end
```

## Performance Considerations

### Formatter Speed Comparison

| Formatter | Language | Speed | Memory |
|-----------|----------|-------|--------|
| **biome** | JS/TS | ⚡⚡⚡⚡⚡ (100x) | Low |
| **prettierd** | JS/TS | ⚡⚡⚡⚡ (10x) | Medium |
| **prettier** | JS/TS | ⚡⚡ (baseline) | High |
| **stylua** | Lua | ⚡⚡⚡⚡⚡ | Low |
| **black** | Python | ⚡⚡⚡ | Medium |
| **clang-format** | C/C++ | ⚡⚡⚡⚡ | Low |

### Your Optimizations

1. **Lazy loading**: Formatters load on first use
2. **Daemon mode**: prettierd stays in memory
3. **Async formatting**: `<leader>f` doesn't block
4. **Stop after first**: Only runs one formatter
5. **Timeout**: Prevents hanging

### Large File Handling

For large files (>10,000 lines):

```lua
format_on_save = function(bufnr)
    -- Disable for large files
    local lines = vim.api.nvim_buf_line_count(bufnr)
    if lines > 10000 then
        return
    end
    return { timeout_ms = 3000, lsp_fallback = true }
end
```

## Comparison: Neovim vs VSCode

| Feature | Your Setup | VSCode |
|---------|-----------|--------|
| **Format Speed** | <50ms (biome) | 100-500ms |
| **Multi-formatter** | Yes (waterfall) | Manual switching |
| **Custom args** | Full control | Limited |
| **Organize imports** | Auto (TS) | Manual or auto |
| **Conditional formatting** | Via Lua | Via settings |
| **Linting** | Real-time | Delayed |
| **Config** | Per-project files | .vscode/settings.json |
| **Performance** | Very fast | Slower |

## Pro Tips

1. **Check Before Commit**: `<leader>f` on all changed files
2. **Project Standards**: Keep formatter configs in git
3. **Team Consistency**: Share `.prettierrc`, `biome.json`, etc.
4. **Large Files**: Disable format-on-save, use manual `<leader>f`
5. **Speed**: Use biome/prettierd for best performance
6. **Debugging**: `:ConformInfo` shows what's running
7. **Multiple Languages**: conform handles all in one config
8. **LSP Fallback**: Always have backup formatting
9. **Async Manual**: `<leader>f` lets you keep typing
10. **Save Without Format**: `<leader>sn` for generated code

## Resources

- **conform.nvim**: https://github.com/stevearc/conform.nvim
- **nvim-lint**: https://github.com/mfussenegger/nvim-lint
- **Biome**: https://biomejs.dev/
- **Prettier**: https://prettier.io/
- **Black**: https://black.readthedocs.io/
- **Your Config**: `~/.config/nvim/lua/de100/plugins/`
