# Terminal Integration: Complete Guide

## VSCode Feature Replacement

This guide shows how to use Neovim's terminal capabilities to replace VSCode's integrated terminal:
- ✅ Built-in terminal
- ✅ Multiple terminals
- ✅ Terminal tabs/splits
- ✅ Send commands to terminal
- ✅ Floating terminals
- ✅ Persistent terminals
- ✅ Terminal file management

**Advantage**: Faster, fully integrated, keyboard-driven, works perfectly over SSH.

## Current Status in Your Config

⚠️ **Basic terminal is available** but not enhanced with toggleterm.

This guide covers:
1. Built-in terminal (already available)
2. Enhanced terminal with toggleterm (recommended addition)

---

## Built-in Terminal (Already Available)

### Basic Usage

```vim
:terminal           " Open terminal in current window
:split | terminal   " Open terminal in horizontal split
:vsplit | terminal  " Open terminal in vertical split
:tabnew | terminal  " Open terminal in new tab
```

### Terminal Modes

**Normal Mode** (default when opening):
- Navigate like normal buffer
- Copy text
- Search with `/`

**Terminal Mode** (for interaction):
- Press `i` or `a` to enter
- Type commands
- Press `<C-\><C-n>` to exit to Normal mode

### Your Current Terminal Keybindings

From your `keymaps.lua`:

```lua
-- Terminal window navigation
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l")
```

**Meaning**: In terminal mode, `<C-h/j/k/l>` switches to adjacent windows.

### Common Terminal Workflows

#### 1. Quick Command in Split

```vim
:split | terminal   " Open terminal below
# Run command
npm install
# Exit terminal mode
<C-\><C-n>
# Close terminal
:q
```

#### 2. Long-Running Process

```vim
:terminal
# Start server
npm run dev
# Switch to Normal mode
<C-\><C-n>
# Navigate to other window
<C-w>k
# Work in code while server runs
```

#### 3. Multiple Terminals

```vim
:vsplit | terminal  " Terminal on right
# Start database
docker-compose up
<C-h>               " Back to code
:split | terminal   " Terminal below
# Run tests
npm test
```

---

## Enhanced Terminal with toggleterm (Recommended)

### Installation

Create new file: `lua/de100/plugins/toggleterm.lua`

```lua
return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            open_mapping = [[<c-\>]],  -- Toggle terminal with Ctrl-\
            hide_numbers = true,
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true,
            terminal_mappings = true,
            persist_size = true,
            persist_mode = true,
            direction = "float",  -- 'vertical' | 'horizontal' | 'tab' | 'float'
            close_on_exit = true,
            shell = vim.o.shell,
            auto_scroll = true,
            float_opts = {
                border = "curved",
                winblend = 0,
                highlights = {
                    border = "Normal",
                    background = "Normal",
                },
            },
        })
        
        -- Custom terminals
        local Terminal = require("toggleterm.terminal").Terminal
        
        -- Lazygit terminal
        local lazygit = Terminal:new({
            cmd = "lazygit",
            dir = "git_dir",
            direction = "float",
            float_opts = {
                border = "double",
            },
            on_open = function(term)
                vim.cmd("startinsert!")
                vim.api.nvim_buf_set_keymap(
                    term.bufnr,
                    "n",
                    "q",
                    "<cmd>close<CR>",
                    { noremap = true, silent = true }
                )
            end,
        })
        
        function _lazygit_toggle()
            lazygit:toggle()
        end
        
        -- Node REPL
        local node = Terminal:new({
            cmd = "node",
            direction = "float",
        })
        
        function _node_toggle()
            node:toggle()
        end
        
        -- Python REPL
        local python = Terminal:new({
            cmd = "python3",
            direction = "float",
        })
        
        function _python_toggle()
            python:toggle()
        end
        
        -- Keybindings
        vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal: Float" })
        vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal: Horizontal" })
        vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal: Vertical" })
        vim.keymap.set("n", "<leader>tg", "<cmd>lua _lazygit_toggle()<cr>", { desc = "Terminal: Lazygit" })
        vim.keymap.set("n", "<leader>tn", "<cmd>lua _node_toggle()<cr>", { desc = "Terminal: Node" })
        vim.keymap.set("n", "<leader>tp", "<cmd>lua _python_toggle()<cr>", { desc = "Terminal: Python" })
        
        -- Terminal mode mappings
        function _G.set_terminal_keymaps()
            local opts = {buffer = 0}
            vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
            vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
            vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
            vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
            vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
        end
        
        vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    end,
}
```

### toggleterm Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `<C-\>` | Toggle terminal | Quick toggle (any mode) |
| `<leader>tf` | Float terminal | Floating window |
| `<leader>th` | Horizontal terminal | Bottom split |
| `<leader>tv` | Vertical terminal | Right split |
| `<leader>tg` | LazyGit | Git TUI |
| `<leader>tn` | Node REPL | JavaScript REPL |
| `<leader>tp` | Python REPL | Python REPL |
| `<Esc>` | Exit terminal mode | Back to Normal mode |

### Terminal Directions

#### Float (Default)

```vim
<C-\>            " Toggle floating terminal
# Appears as overlay
# Perfect for quick commands
```

```
┌────────────────────────────────────────┐
│  Your Code                             │
│                                        │
│    ┌──────────────────────┐           │
│    │ $ npm install        │           │
│    │ ...                  │           │
│    │ $ _                  │           │
│    └──────────────────────┘           │
│                                        │
└────────────────────────────────────────┘
```

#### Horizontal

```vim
<leader>th       " Horizontal split terminal
```

```
┌────────────────────────────────────────┐
│  Your Code                             │
│                                        │
├────────────────────────────────────────┤
│  Terminal                              │
│  $ npm run dev                         │
└────────────────────────────────────────┘
```

#### Vertical

```vim
<leader>tv       " Vertical split terminal
```

```
┌─────────────────────┬──────────────────┐
│  Your Code          │  Terminal        │
│                     │  $ npm test      │
│                     │  ...             │
└─────────────────────┴──────────────────┘
```

---

## Multiple Terminals

### toggleterm Approach

```vim
# Terminal 1
<C-\>            " Open terminal 1
npm run dev
<C-\>            " Hide terminal 1

# Terminal 2
2<C-\>           " Open terminal 2 (note the number prefix)
docker-compose up
<C-\>            " Hide terminal 2

# Switch between them
<C-\>            " Terminal 1
2<C-\>           " Terminal 2
3<C-\>           " Terminal 3 (creates if doesn't exist)
```

### Built-in Approach

```vim
:terminal        " Terminal 1
<C-\><C-n>
:bnext

:terminal        " Terminal 2
<C-\><C-n>

# Navigate buffers
:bnext
:bprevious
```

---

## Sending Commands to Terminal

### Using toggleterm's TermExec

```lua
-- Add to toggleterm config
vim.keymap.set("n", "<leader>tr", function()
    local cmd = vim.fn.input("Run: ")
    vim.cmd("TermExec cmd='" .. cmd .. "'")
end, { desc = "Terminal: Run Command" })
```

**Usage**:
```vim
<leader>tr       " Prompts: Run: 
# Type: npm test
<Enter>
# Runs in terminal
```

### Send Visual Selection

```lua
-- Add to toggleterm config
vim.keymap.set("v", "<leader>ts", function()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
    local text = table.concat(lines, "\n")
    
    require("toggleterm").exec(text)
end, { desc = "Terminal: Send Selection" })
```

**Usage**:
```python
# In Python file
print("hello")
print("world")

# Visual select both lines
V
j
<leader>ts       " Sends to terminal and executes
```

---

## Specialized Terminals

### LazyGit Integration

**Already configured** in toggleterm setup.

```vim
<leader>tg       " Open LazyGit in floating terminal
# Use LazyGit normally
q                " Close LazyGit
# Or Ctrl-\ to toggle
```

### Language REPLs

#### Node.js REPL

```vim
<leader>tn       " Open Node REPL
# Type JavaScript
> const x = 5
> x * 2
10
```

#### Python REPL

```vim
<leader>tp       " Open Python REPL
# Type Python
>>> x = 5
>>> x * 2
10
```

#### Custom REPL

```lua
-- Add to toggleterm config
local lua_repl = Terminal:new({
    cmd = "lua",
    direction = "float",
})

function _lua_toggle()
    lua_repl:toggle()
end

vim.keymap.set("n", "<leader>tl", "<cmd>lua _lua_toggle()<cr>", { desc = "Terminal: Lua" })
```

---

## Running Project Commands

### Quick Run Commands

```lua
-- Add to your config
local function run_npm_script()
    local scripts = vim.fn.system("npm run")
    local script = vim.fn.input("npm run: ", "", "custom,npm_scripts")
    if script ~= "" then
        vim.cmd("TermExec cmd='npm run " .. script .. "'")
    end
end

vim.keymap.set("n", "<leader>rn", run_npm_script, { desc = "Run: npm script" })
```

### Common Shortcuts

```lua
-- Add to toggleterm config
vim.keymap.set("n", "<leader>rt", "<cmd>TermExec cmd='npm test'<cr>", { desc = "Run: npm test" })
vim.keymap.set("n", "<leader>rb", "<cmd>TermExec cmd='npm run build'<cr>", { desc = "Run: npm build" })
vim.keymap.set("n", "<leader>rd", "<cmd>TermExec cmd='npm run dev'<cr>", { desc = "Run: npm dev" })
vim.keymap.set("n", "<leader>rl", "<cmd>TermExec cmd='npm run lint'<cr>", { desc = "Run: npm lint" })
```

---

## Terminal File Manager

### Yazi (File Manager)

```lua
-- Add to toggleterm config
local yazi = Terminal:new({
    cmd = "yazi",
    direction = "float",
    float_opts = {
        border = "double",
        width = math.floor(vim.o.columns * 0.9),
        height = math.floor(vim.o.lines * 0.9),
    },
})

function _yazi_toggle()
    yazi:toggle()
end

vim.keymap.set("n", "<leader>ty", "<cmd>lua _yazi_toggle()<cr>", { desc = "Terminal: Yazi" })
```

**Install Yazi**:
```bash
# Ubuntu/Debian
cargo install yazi-fm

# macOS
brew install yazi

# Arch
sudo pacman -S yazi
```

### ranger (Alternative File Manager)

```lua
local ranger = Terminal:new({
    cmd = "ranger",
    direction = "float",
})

function _ranger_toggle()
    ranger:toggle()
end

vim.keymap.set("n", "<leader>tr", "<cmd>lua _ranger_toggle()<cr>", { desc = "Terminal: Ranger" })
```

---

## Docker Integration

### Docker Commands

```lua
-- Add shortcuts
vim.keymap.set("n", "<leader>du", "<cmd>TermExec cmd='docker-compose up'<cr>", { desc = "Docker: Up" })
vim.keymap.set("n", "<leader>dd", "<cmd>TermExec cmd='docker-compose down'<cr>", { desc = "Docker: Down" })
vim.keymap.set("n", "<leader>dl", "<cmd>TermExec cmd='docker-compose logs -f'<cr>", { desc = "Docker: Logs" })
```

### LazyDocker

```lua
local lazydocker = Terminal:new({
    cmd = "lazydocker",
    direction = "float",
    float_opts = {
        border = "double",
    },
})

function _lazydocker_toggle()
    lazydocker:toggle()
end

vim.keymap.set("n", "<leader>tD", "<cmd>lua _lazydocker_toggle()<cr>", { desc = "Terminal: LazyDocker" })
```

---

## Database CLIs

### PostgreSQL

```lua
local psql = Terminal:new({
    cmd = "psql -U postgres",
    direction = "float",
})

function _psql_toggle()
    psql:toggle()
end

vim.keymap.set("n", "<leader>tP", "<cmd>lua _psql_toggle()<cr>", { desc = "Terminal: PostgreSQL" })
```

### MongoDB

```lua
local mongo = Terminal:new({
    cmd = "mongosh",
    direction = "float",
})

function _mongo_toggle()
    mongo:toggle()
end

vim.keymap.set("n", "<leader>tM", "<cmd>lua _mongo_toggle()<cr>", { desc = "Terminal: MongoDB" })
```

### Redis

```lua
local redis = Terminal:new({
    cmd = "redis-cli",
    direction = "float",
})

function _redis_toggle()
    redis:toggle()
end

vim.keymap.set("n", "<leader>tR", "<cmd>lua _redis_toggle()<cr>", { desc = "Terminal: Redis" })
```

---

## Common Workflows

### 1. Development Server + Watch Tests

```vim
# Terminal 1: Dev server
<leader>th       " Horizontal terminal
npm run dev
<C-\><C-n>       " Exit terminal mode
<C-k>            " Back to code

# Terminal 2: Test watcher
2<C-\>           " Terminal 2
npm test -- --watch
<C-\>            " Hide

# Edit code
# Tests auto-run in background
2<C-\>           " Check test results
```

### 2. Quick Command Execution

```vim
<C-\>            " Float terminal
ls -la
<Enter>
git status
<C-\>            " Hide when done
```

### 3. REPL-Driven Development

```vim
<leader>tp       " Python REPL
# Test function
>>> from mymodule import myfunction
>>> myfunction(5)
10

# Doesn't work as expected
<C-\><C-n>       " Exit REPL
# Fix code
# Re-run REPL
<leader>tp
>>> from importlib import reload
>>> import mymodule
>>> reload(mymodule)
>>> mymodule.myfunction(5)
```

### 4. Docker Development

```vim
<leader>du       " Docker up
# Wait for containers
<leader>dl       " View logs
# Keep running in background
<C-h>            " Back to code

# When done
<leader>dd       " Docker down
```

### 5. Database Query Testing

```vim
<leader>tP       " PostgreSQL
# Test query
SELECT * FROM users WHERE id = 1;
# Got the data
<C-\>            " Hide
# Update code based on schema
```

---

## Terminal Buffer Management

### List Open Terminals

```vim
:ToggleTermToggleAll  " Hide/show all terminals
:ToggleTermSendVisualSelection 1  " Send to terminal 1
```

### Close Specific Terminal

```vim
# From terminal
exit             " Close terminal

# Or
:bd!             " Force close buffer
```

### Close All Terminals

```vim
:bufdo bd!       " Close all buffers (including terminals)
```

---

## Customization Examples

### Auto-start Server on Launch

```lua
-- Add to toggleterm config
vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    callback = function()
        -- Only in specific projects
        if vim.fn.filereadable("package.json") == 1 then
            vim.defer_fn(function()
                require("toggleterm").exec("npm run dev", 1, 12, nil, "horizontal")
            end, 1000)
        end
    end,
})
```

### Terminal in Tab

```lua
vim.keymap.set("n", "<leader>tt", function()
    vim.cmd("tabnew")
    vim.cmd("terminal")
    vim.cmd("startinsert")
end, { desc = "Terminal: New Tab" })
```

### Named Terminals

```lua
local terminals = {}

local function get_or_create_terminal(name, cmd)
    if not terminals[name] then
        terminals[name] = Terminal:new({
            cmd = cmd,
            direction = "float",
        })
    end
    return terminals[name]
end

vim.keymap.set("n", "<leader>tF", function()
    local name = vim.fn.input("Terminal name: ")
    local cmd = vim.fn.input("Command: ")
    get_or_create_terminal(name, cmd):toggle()
end, { desc = "Terminal: Named" })
```

---

## Comparison: toggleterm vs VSCode Terminal

| Feature | toggleterm | VSCode |
|---------|-----------|--------|
| **Toggle Speed** | Instant | 100-200ms |
| **Multiple Terms** | Yes (numbered) | Yes (tabs) |
| **Float/Split** | Both | Split only |
| **Persistent** | Yes | Yes |
| **Send Code** | Yes | Extension |
| **Custom Terminals** | Full Lua control | Limited |
| **Memory** | Low | High |
| **Keyboard** | 100% | Mixed |

---

## Troubleshooting

### Terminal Not Opening

1. **Check plugin installed**:
   ```vim
   :Lazy
   # Look for toggleterm
   ```

2. **Try manual open**:
   ```vim
   :ToggleTerm
   ```

3. **Check keybinding**:
   ```vim
   :map <C-\>
   ```

### Terminal Closes Immediately

1. **Check shell**:
   ```vim
   :lua print(vim.o.shell)
   ```

2. **Set shell explicitly**:
   ```lua
   -- In toggleterm config
   shell = "/bin/bash",  -- or "/bin/zsh"
   ```

### Can't Exit Terminal Mode

Default: `<C-\><C-n>`

With toggleterm config: `<Esc>`

```lua
-- In terminal keymaps function
vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
```

### Terminal Size Issues

```lua
-- In toggleterm setup
size = function(term)
    if term.direction == "horizontal" then
        return 20  -- Increase this
    elseif term.direction == "vertical" then
        return vim.o.columns * 0.5  -- Adjust percentage
    end
end,
```

---

## Pro Tips

1. **Float for Quick Commands**: `<C-\>` for quick git status, npm install
2. **Horizontal for Long Output**: `<leader>th` for logs, test output
3. **Vertical for Side-by-Side**: `<leader>tv` for REPL while coding
4. **Numbered Terminals**: `2<C-\>` for multiple persistent terminals
5. **Exit Fast**: Configure `<Esc>` to exit terminal mode
6. **Send Selections**: Visual select code, send to REPL
7. **Named Terminals**: Use for specific long-running processes
8. **LazyGit Integration**: Better than terminal git commands
9. **REPL-Driven**: Keep Python/Node REPL open while coding
10. **Auto-start Servers**: Let terminal start dev server on launch

---

## Complete Keybinding Reference

```lua
-- With toggleterm installed:
<C-\>         -- Toggle floating terminal
<leader>tf    -- Floating terminal
<leader>th    -- Horizontal split terminal
<leader>tv    -- Vertical split terminal
<leader>tg    -- LazyGit
<leader>tn    -- Node REPL
<leader>tp    -- Python REPL

-- In terminal mode:
<Esc>         -- Exit to Normal mode
<C-h/j/k/l>   -- Navigate to adjacent windows

-- Multiple terminals:
1<C-\>        -- Terminal 1
2<C-\>        -- Terminal 2
3<C-\>        -- Terminal 3
```

---

## Resources

- **toggleterm GitHub**: https://github.com/akinsho/toggleterm.nvim
- **Built-in Terminal**: `:h terminal`
- **Neovim Terminal**: `:h terminal-emulator`
- **Terminal Mode**: `:h terminal-mode`

---

**With proper terminal integration, you can do everything without leaving Neovim! 💻🚀**
