# Debugging in Neovim: Complete Setup Guide

## VSCode Feature Replacement

This guide shows how to add **full debugging capabilities** to replace VSCode's debugger:
- ✅ Breakpoints
- ✅ Step through code
- ✅ Variable inspection
- ✅ Watch expressions
- ✅ Call stack navigation
- ✅ Debug console
- ✅ Conditional breakpoints

**Advantage**: Same debugging power, faster startup, works over SSH, fully keyboard-driven.

## Current Status in Your Config

❌ **Debugging is NOT currently configured** in your setup.

This guide will show you how to add it using **nvim-dap** (Debug Adapter Protocol).

---

## What is DAP?

**DAP (Debug Adapter Protocol)** is like LSP but for debugging:
- Created by Microsoft
- Language-agnostic
- Used by VSCode, Neovim, and others
- Supports all major languages

**nvim-dap** is the Neovim implementation of DAP.

---

## Installation

### Step 1: Add Plugins to Your Config

Create a new file: `lua/de100/plugins/dap.lua`

```lua
return {
    -- Main DAP plugin
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            -- UI for DAP
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            
            -- Virtual text showing variable values
            "theHamsta/nvim-dap-virtual-text",
            
            -- Mason integration for installing debuggers
            "jay-babu/mason-nvim-dap.nvim",
            
            -- Language-specific extensions
            "mfussenegger/nvim-dap-python",  -- Python
            "leoluz/nvim-dap-go",             -- Go
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            
            -- Setup UI
            dapui.setup()
            
            -- Setup virtual text
            require("nvim-dap-virtual-text").setup()
            
            -- Auto-open UI when debugging starts
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
            
            -- Keybindings
            vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
            vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'Debug: Step Over' })
            vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'Debug: Step Into' })
            vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'Debug: Step Out' })
            vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
            vim.keymap.set('n', '<leader>B', function()
                dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end, { desc = 'Debug: Set Conditional Breakpoint' })
            
            -- UI Toggle
            vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Debug: Toggle UI' })
        end,
    },
}
```

### Step 2: Install Debug Adapters via Mason

Add to your `lua/de100/plugins/lsp/mason.lua` in the `ensure_installed` list:

```lua
-- In mason-tool-installer ensure_installed:
"debugpy",        -- Python debugger
"delve",          -- Go debugger
"js-debug-adapter", -- JavaScript/TypeScript debugger
"codelldb",       -- C/C++/Rust debugger
```

### Step 3: Restart Neovim

```vim
:qa
nvim .
# Plugins will install automatically
```

---

## Configuration by Language

### JavaScript/TypeScript

```lua
-- Add to lua/de100/plugins/dap.lua config function
local dap = require("dap")

-- Node.js debugging
dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = {vim.fn.stdpath("data") .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'},
}

dap.configurations.javascript = {
    {
        type = 'node2',
        request = 'launch',
        program = '${file}',
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = 'inspector',
        console = 'integratedTerminal',
    },
    {
        type = 'node2',
        request = 'attach',
        processId = require'dap.utils'.pick_process,
    },
}

dap.configurations.typescript = dap.configurations.javascript
```

### Python

```lua
-- Add to lua/de100/plugins/dap.lua config function
require('dap-python').setup('~/.local/share/nvim/mason/packages/debugpy/venv/bin/python')

-- Add test configurations
require('dap-python').test_runner = 'pytest'
```

### Go

```lua
-- Add to lua/de100/plugins/dap.lua config function
require('dap-go').setup()
```

### C/C++

```lua
-- Add to lua/de100/plugins/dap.lua config function
local dap = require("dap")

dap.adapters.codelldb = {
    type = 'server',
    port = "${port}",
    executable = {
        command = vim.fn.stdpath("data") .. '/mason/bin/codelldb',
        args = {"--port", "${port}"},
    }
}

dap.configurations.cpp = {
    {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
    },
}

dap.configurations.c = dap.configurations.cpp
```

---

## Keybindings Reference

### Your New Debug Keybindings

| Key | Action | VSCode Equivalent |
|-----|--------|-------------------|
| `<F5>` | Start/Continue | F5 |
| `<F10>` | Step Over | F10 |
| `<F11>` | Step Into | F11 |
| `<F12>` | Step Out | Shift+F11 |
| `<leader>b` | Toggle Breakpoint | F9 |
| `<leader>B` | Conditional Breakpoint | - |
| `<leader>du` | Toggle Debug UI | - |

### Additional Useful Mappings

Add these to your config:

```lua
vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'Debug: Open REPL' })
vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'Debug: Run Last' })
vim.keymap.set({'n', 'v'}, '<leader>dh', require('dap.ui.widgets').hover, { desc = 'Debug: Hover' })
vim.keymap.set({'n', 'v'}, '<leader>dp', require('dap.ui.widgets').preview, { desc = 'Debug: Preview' })
vim.keymap.set('n', '<leader>df', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.frames)
end, { desc = 'Debug: Frames' })
vim.keymap.set('n', '<leader>ds', function()
    local widgets = require('dap.ui.widgets')
    widgets.centered_float(widgets.scopes)
end, { desc = 'Debug: Scopes' })
```

---

## Debug UI Layout

When debugging starts, nvim-dap-ui opens with this layout:

```
┌─────────────────┬─────────────────────────────┬──────────────┐
│   Scopes        │   Your Code                 │   Stacks     │
│   (Variables)   │   (with breakpoint)         │   (Frames)   │
│                 │                             │              │
│ • local vars    │  10  function hello() {     │ • main()     │
│ • globals       │  11 ►  const x = 1;        │ • fn2()      │
│ • upvalues      │  12    console.log(x);     │              │
│                 │  13  }                      │              │
├─────────────────┴─────────────────────────────┴──────────────┤
│   Console / REPL                                             │
│   > variable_name                                            │
│   > x                                                        │
│   1                                                          │
└──────────────────────────────────────────────────────────────┘
```

---

## Common Workflows

### 1. Basic Debugging Session

```vim
# Set breakpoint
<leader>b        " On line you want to pause

# Start debugging
<F5>             " Starts debugger

# When paused at breakpoint
<F10>            " Step over function
<F11>            " Step into function
<F12>            " Step out of function
<F5>             " Continue to next breakpoint

# Inspect variables
# Hover over variable or check Scopes panel

# Stop debugging
<leader>du       " Close debug UI
```

### 2. Debugging Tests (Python Example)

```python
# In test file
def test_my_function():
    result = my_function(5)  # Set breakpoint here
    assert result == 10
```

```vim
<leader>b        " Set breakpoint
:lua require('dap-python').test_method()  # Debug this test
<F10>            " Step through test
```

### 3. Conditional Breakpoints

```vim
<leader>B        " Set conditional breakpoint
# Enter: i > 5
# Breakpoint only triggers when i > 5

<F5>             " Start debugging
```

### 4. Inspecting Complex Objects

```vim
# When paused at breakpoint
<leader>dh       " Hover over variable (more detail)
<leader>ds       " Open scopes in float
# Or check Scopes panel in UI
```

### 5. Debug Console

```vim
<leader>dr       " Open REPL
# Type variable names to inspect
# Execute code to test fixes
```

### 6. Restart Last Debug Session

```vim
<leader>dl       " Runs last debug configuration
```

---

## Language-Specific Setup

### JavaScript/TypeScript with Node.js

**Debug Current File**:
```vim
<F5>             " Select "Launch file" configuration
```

**Debug Tests (Jest)**:
```json
// Add to .vscode/launch.json (nvim-dap reads this)
{
  "type": "node2",
  "request": "launch",
  "name": "Jest",
  "program": "${workspaceFolder}/node_modules/.bin/jest",
  "args": ["--runInBand"],
  "console": "integratedTerminal",
  "internalConsoleOptions": "neverOpen"
}
```

### Python with pytest

```lua
-- Already configured with dap-python
-- Debug test under cursor:
:lua require('dap-python').test_method()

-- Debug test class:
:lua require('dap-python').test_class()
```

### Go

```lua
-- Already configured with dap-go
-- Debug current test:
:lua require('dap-go').debug_test()

-- Debug last test:
:lua require('dap-go').debug_last_test()
```

---

## Integration with Telescope

Add Telescope DAP integration:

```lua
-- Add to telescope.lua or dap.lua
require('telescope').load_extension('dap')

-- Keybindings
vim.keymap.set('n', '<leader>dc', ':Telescope dap commands<CR>', { desc = 'DAP Commands' })
vim.keymap.set('n', '<leader>db', ':Telescope dap list_breakpoints<CR>', { desc = 'DAP Breakpoints' })
vim.keymap.set('n', '<leader>dv', ':Telescope dap variables<CR>', { desc = 'DAP Variables' })
vim.keymap.set('n', '<leader>dF', ':Telescope dap frames<CR>', { desc = 'DAP Frames' })
```

Requires:
```lua
-- Add to dependencies in telescope.lua
"nvim-telescope/telescope-dap.nvim",
```

---

## Breakpoint Signs

Customize breakpoint appearance in your `dap.lua`:

```lua
vim.fn.sign_define('DapBreakpoint', {
    text = '🔴',
    texthl = 'DapBreakpoint',
    linehl = 'DapBreakpoint',
    numhl = 'DapBreakpoint'
})
vim.fn.sign_define('DapBreakpointCondition', {
    text = '🟡',
    texthl = 'DapBreakpoint',
    linehl = 'DapBreakpoint',
    numhl = 'DapBreakpoint'
})
vim.fn.sign_define('DapStopped', {
    text = '▶️',
    texthl = 'DapStopped',
    linehl = 'DapStopped',
    numhl = 'DapStopped'
})
```

---

## Troubleshooting

### Debugger Not Starting

1. **Check adapter installed**:
   ```vim
   :Mason
   # Verify debugpy, delve, js-debug-adapter installed
   ```

2. **Check DAP setup**:
   ```vim
   :lua print(vim.inspect(require('dap').adapters))
   ```

3. **Check logs**:
   ```vim
   :DapShowLog
   ```

### Breakpoints Not Hitting

1. **Verify source maps** (JavaScript/TypeScript):
   ```json
   // tsconfig.json
   {
     "compilerOptions": {
       "sourceMap": true
     }
   }
   ```

2. **Check file paths** match compiled output

3. **Try logging**:
   ```lua
   require('dap').set_log_level('TRACE')
   :DapShowLog
   ```

### Variables Not Showing

1. **Ensure debug build** (C/C++):
   ```bash
   gcc -g myfile.c  # -g flag for debug symbols
   ```

2. **Check DAP UI is open**:
   ```vim
   <leader>du
   ```

---

## Advanced Features

### Log Points

Set a log point instead of breakpoint:

```lua
vim.keymap.set('n', '<leader>lp', function()
    require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end, { desc = 'Debug: Log Point' })
```

### Exception Breakpoints

```lua
vim.keymap.set('n', '<leader>de', function()
    require('dap').set_exception_breakpoints({"all"})
end, { desc = 'Debug: Break on Exceptions' })
```

### Multi-Session Debugging

```lua
-- Start multiple debug sessions
-- Useful for client + server debugging
vim.keymap.set('n', '<leader>d2', function()
    require('dap').continue({new_session = true})
end, { desc = 'Debug: New Session' })
```

---

## Comparison: nvim-dap vs VSCode Debugger

| Feature | nvim-dap | VSCode |
|---------|----------|--------|
| **Setup** | Manual config | Auto-detect |
| **Speed** | Instant | 500ms-1s delay |
| **UI** | Customizable | Fixed |
| **Keyboard** | 100% | Mixed |
| **SSH** | Perfect | Slow |
| **Memory** | ~10MB | ~50MB |
| **Languages** | All DAP-supported | Same |
| **Launch Configs** | Lua or JSON | JSON only |

---

## Recommended Keybindings Summary

```lua
-- Quick reference - add to your config
-- Debugging
<F5>         -- Start/Continue
<F10>        -- Step Over
<F11>        -- Step Into
<F12>        -- Step Out
<leader>b    -- Toggle Breakpoint
<leader>B    -- Conditional Breakpoint
<leader>du   -- Toggle UI
<leader>dr   -- Open REPL
<leader>dl   -- Run Last
```

---

## Next Steps

1. **Install**: Add dap.lua to your config
2. **Test**: Debug a simple script
3. **Language-specific**: Configure for your main language
4. **Practice**: Debug a real bug
5. **Customize**: Adjust UI layout and keybindings

---

## Resources

- **nvim-dap GitHub**: https://github.com/mfussenegger/nvim-dap
- **nvim-dap-ui**: https://github.com/rcarriga/nvim-dap-ui
- **DAP Protocol**: https://microsoft.github.io/debug-adapter-protocol/
- **Wiki**: https://github.com/mfussenegger/nvim-dap/wiki
- **Debug Adapters**: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

---

**With DAP configured, you'll have VSCode's debugging power directly in Neovim! 🐛🔍**
