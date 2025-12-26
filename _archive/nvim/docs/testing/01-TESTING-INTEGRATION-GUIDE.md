# Testing Integration: Complete Setup Guide

## VSCode Feature Replacement

This guide shows how to add **test runner integration** to replace VSCode's testing extensions:
- ✅ Run tests from editor
- ✅ See test results inline
- ✅ Debug failing tests
- ✅ Test coverage display
- ✅ Watch mode
- ✅ Test explorer
- ✅ Quick test navigation

**Advantage**: Faster, keyboard-driven, integrated with debugging, works over SSH.

## Current Status in Your Config

❌ **Testing integration is NOT currently configured** in your setup.

This guide will show you how to add it using **neotest**.

---

## What is Neotest?

**Neotest** is a framework for running tests in Neovim:
- Language-agnostic (adapters for each framework)
- Shows results inline
- Integrates with DAP for debugging
- Supports watch mode
- Works with popular test frameworks

---

## Installation

### Step 1: Add Neotest Plugin

Create a new file: `lua/de100/plugins/neotest.lua`

```lua
return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        
        -- Test adapters for different languages
        "nvim-neotest/neotest-python",          -- Python (pytest, unittest)
        "nvim-neotest/neotest-jest",            -- JavaScript (Jest)
        "nvim-neotest/neotest-go",              -- Go
        "nvim-neotest/neotest-plenary",         -- Lua (for plugin testing)
        "marilari88/neotest-vitest",            -- Vitest
        "rouge8/neotest-rust",                  -- Rust
    },
    config = function()
        local neotest = require("neotest")
        
        neotest.setup({
            adapters = {
                require("neotest-python")({
                    dap = { justMyCode = false },
                    args = {"--log-level", "DEBUG"},
                    runner = "pytest",
                }),
                require("neotest-jest")({
                    jestCommand = "npm test --",
                    env = { CI = true },
                    cwd = function()
                        return vim.fn.getcwd()
                    end,
                }),
                require("neotest-go"),
                require("neotest-vitest"),
            },
            
            -- Diagnostic display
            diagnostic = {
                enabled = true,
                severity = vim.diagnostic.severity.ERROR,
            },
            
            -- Floating window for output
            floating = {
                border = "rounded",
                max_height = 0.8,
                max_width = 0.8,
            },
            
            -- Icons
            icons = {
                passed = "✓",
                running = "●",
                failed = "✗",
                skipped = "○",
                unknown = "?",
            },
            
            -- Status display
            status = {
                enabled = true,
                signs = true,
                virtual_text = true,
            },
        })
        
        -- Keybindings
        vim.keymap.set("n", "<leader>tt", function()
            neotest.run.run()
        end, { desc = "Test: Run Nearest" })
        
        vim.keymap.set("n", "<leader>tf", function()
            neotest.run.run(vim.fn.expand("%"))
        end, { desc = "Test: Run File" })
        
        vim.keymap.set("n", "<leader>ta", function()
            neotest.run.run(vim.fn.getcwd())
        end, { desc = "Test: Run All" })
        
        vim.keymap.set("n", "<leader>ts", function()
            neotest.summary.toggle()
        end, { desc = "Test: Toggle Summary" })
        
        vim.keymap.set("n", "<leader>to", function()
            neotest.output.open({ enter = true })
        end, { desc = "Test: Show Output" })
        
        vim.keymap.set("n", "<leader>tO", function()
            neotest.output_panel.toggle()
        end, { desc = "Test: Toggle Output Panel" })
        
        vim.keymap.set("n", "<leader>td", function()
            neotest.run.run({ strategy = "dap" })
        end, { desc = "Test: Debug Nearest" })
        
        vim.keymap.set("n", "<leader>tw", function()
            neotest.watch.toggle()
        end, { desc = "Test: Toggle Watch" })
        
        vim.keymap.set("n", "[t", function()
            neotest.jump.prev({ status = "failed" })
        end, { desc = "Test: Previous Failed" })
        
        vim.keymap.set("n", "]t", function()
            neotest.jump.next({ status = "failed" })
        end, { desc = "Test: Next Failed" })
    end,
}
```

### Step 2: Restart Neovim

```vim
:qa
nvim .
# Plugins will install automatically
```

---

## Keybindings Reference

### Your New Test Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>tt` | Run nearest test | Run test under cursor |
| `<leader>tf` | Run file tests | Run all tests in file |
| `<leader>ta` | Run all tests | Run entire test suite |
| `<leader>ts` | Toggle summary | Test explorer sidebar |
| `<leader>to` | Show output | Open test output |
| `<leader>tO` | Toggle output panel | Bottom panel with all output |
| `<leader>td` | Debug test | Debug test under cursor |
| `<leader>tw` | Toggle watch | Auto-run on file save |
| `[t` | Previous failed test | Jump to previous failure |
| `]t` | Next failed test | Jump to next failure |

---

## Test Interface

### Summary Window (Test Explorer)

When you press `<leader>ts`:

```
┌─ Test Summary ────────────────┐
│ 📁 src/                       │
│   📁 components/              │
│     📄 Button.test.tsx        │
│       ✓ renders correctly    │
│       ✗ handles click        │
│       ○ is accessible        │
│   📁 utils/                   │
│     📄 helpers.test.ts        │
│       ✓ formatDate           │
│       ✓ parseJSON            │
└───────────────────────────────┘
```

**Navigation**:
- `j`/`k` - Move up/down
- `<Enter>` - Run selected test
- `o` - Show output
- `d` - Debug test
- `q` - Close summary

### Inline Status

Tests show status in sign column:

```python
 1  │ def test_addition():
 2  │ ✓    assert 1 + 1 == 2
 3  │
 4  │ def test_subtraction():
 5  │ ✗    assert 5 - 3 == 1  # This fails
    │      AssertionError: assert 2 == 1
```

### Output Panel

Press `<leader>tO` for full output:

```
┌─ Test Output ─────────────────────────────────────────┐
│ test_my_function                                      │
│ FAILED                                                │
│                                                       │
│ tests/test_example.py:10: AssertionError             │
│     def test_my_function():                           │
│ >       assert result == expected                     │
│ E       AssertionError: assert 5 == 10                │
└───────────────────────────────────────────────────────┘
```

---

## Common Workflows

### 1. Run Single Test (TDD Workflow)

```vim
# Write test
def test_my_feature():
    assert my_function() == expected

# Run test
<leader>tt       " Run test under cursor
# See result inline: ✗ (red)

# Fix code
# ...

# Re-run test
<leader>tt       " Run again
# See result: ✓ (green)
```

### 2. Run All Tests in File

```vim
<leader>tf       " Run all tests in current file
<leader>to       " Check output for failures
]t               " Jump to next failed test
<leader>tt       " Run just that test
```

### 3. Debug Failing Test

```vim
<leader>td       " Debug test under cursor
# Debugger opens (requires nvim-dap)
# Set breakpoint in test or code
<F10>            " Step through
# Inspect variables
# Fix issue
```

### 4. Watch Mode (Auto-run on Save)

```vim
<leader>tw       " Enable watch mode
# Edit test or source code
<C-s>            " Save
# Tests automatically re-run
# See results inline immediately
```

### 5. Full Test Suite

```vim
<leader>ta       " Run all tests
<leader>ts       " Open summary
# Navigate with j/k
# See which areas have failures
<Enter>          " Run specific test
```

### 6. Jump Through Failures

```vim
<leader>tf       " Run file tests
# Multiple failures
]t               " Jump to next failure
# Review error
]t               " Next failure
[t               " Previous failure
```

---

## Language-Specific Configuration

### Python (pytest)

**Already configured** in the setup above.

**Project Setup**:
```bash
pip install pytest
```

**Run specific test types**:
```lua
-- Add to neotest setup
vim.keymap.set("n", "<leader>tm", function()
    neotest.run.run({
        suite = false,
        extra_args = { "-m", "slow" }  -- Run tests marked @pytest.mark.slow
    })
end, { desc = "Test: Run Marked" })
```

### JavaScript/TypeScript (Jest)

**Already configured** in the setup above.

**Project Setup**:
```bash
npm install --save-dev jest
```

**Custom Jest Config**:
```lua
-- Modify in neotest setup adapters
require("neotest-jest")({
    jestCommand = "npm test --",
    jestConfigFile = "custom.jest.config.js",
    env = { CI = true },
    cwd = function(path)
        return vim.fn.getcwd()
    end,
})
```

### Vitest

**Already configured** in the setup above.

**Project Setup**:
```bash
npm install --save-dev vitest
```

### Go

**Already configured** in the setup above.

**Project Setup**:
```bash
# Go tests use standard testing package
# No additional setup needed
```

**Run with race detector**:
```lua
vim.keymap.set("n", "<leader>tr", function()
    neotest.run.run({
        extra_args = { "-race" }
    })
end, { desc = "Test: Run with Race Detector" })
```

### Rust

```lua
-- Add to adapters in neotest setup
require("neotest-rust")({
    args = { "--no-capture" },
    dap_adapter = "codelldb",
})
```

---

## Advanced Features

### Coverage Display

Install coverage plugin:

```lua
-- Add to dependencies in neotest.lua
"andythigpen/nvim-coverage",
```

Configure:
```lua
require("coverage").setup({
    auto_reload = true,
    lang = {
        python = {
            coverage_file = ".coverage",
        },
    },
})

-- Keybindings
vim.keymap.set("n", "<leader>tc", function()
    require("coverage").load(true)
end, { desc = "Test: Load Coverage" })

vim.keymap.set("n", "<leader>tC", function()
    require("coverage").summary()
end, { desc = "Test: Coverage Summary" })
```

**Usage**:
```bash
# Python
pytest --cov=. --cov-report=term-missing

# JavaScript
npm test -- --coverage
```

```vim
<leader>tc       " Load coverage
# Green highlights: covered lines
# Red highlights: not covered
<leader>tC       " Coverage summary
```

### Parameterized Tests

**Python**:
```python
@pytest.mark.parametrize("input,expected", [
    (1, 2),
    (2, 4),
    (3, 6),
])
def test_double(input, expected):
    assert input * 2 == expected
```

Neotest shows each parameter set as separate test.

### Test Filtering

```lua
-- Run only tests matching pattern
vim.keymap.set("n", "<leader>tg", function()
    local pattern = vim.fn.input("Test pattern: ")
    neotest.run.run({
        suite = true,
        extra_args = { "-k", pattern }  -- pytest
    })
end, { desc = "Test: Run by Pattern" })
```

---

## Integration with Other Tools

### With Telescope

```lua
-- Add to telescope.lua or neotest.lua
vim.keymap.set("n", "<leader>ft", function()
    require("telescope").extensions.neotest.neotest()
end, { desc = "Find: Tests" })
```

Requires:
```lua
-- Add to telescope extensions
require('telescope').load_extension('neotest')
```

### With DAP (Debugging)

**Already integrated** with `<leader>td` keybinding.

**Debug with arguments**:
```lua
vim.keymap.set("n", "<leader>tD", function()
    neotest.run.run({
        strategy = "dap",
        extra_args = function()
            return vim.split(vim.fn.input("Test args: "), " ")
        end
    })
end, { desc = "Test: Debug with Args" })
```

### With Neo-tree

Show test status in file tree:

```lua
-- Add to neo-tree config (if desired)
-- Would require custom implementation
```

---

## Customization Examples

### Change Status Icons

```lua
-- In neotest.setup()
icons = {
    passed = "✅",
    running = "🏃",
    failed = "❌",
    skipped = "⏭️",
    unknown = "❓",
},
```

### Customize Output Window

```lua
-- In neotest.setup()
output = {
    open_on_run = true,      -- Auto-open on run
    enter = false,           -- Don't enter window
},

output_panel = {
    enabled = true,
    open = "botright split | resize 15",
},
```

### Auto-run on Save

```lua
-- Add autocmd to auto-run nearest test on save
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.test.*",
    callback = function()
        require("neotest").run.run()
    end,
})
```

### Notify on Test Complete

```lua
-- Add to neotest setup
consumers = {
    notify = function(client)
        client.listeners.results = function(_, results)
            local failed = 0
            for _, result in pairs(results) do
                if result.status == "failed" then
                    failed = failed + 1
                end
            end
            
            if failed > 0 then
                vim.notify(
                    string.format("Tests failed: %d", failed),
                    vim.log.levels.ERROR
                )
            else
                vim.notify("All tests passed!", vim.log.levels.INFO)
            end
        end
    end,
},
```

---

## Comparison: Neotest vs VSCode Test Explorer

| Feature | Neotest | VSCode |
|---------|---------|--------|
| **Setup** | Per-language adapter | Auto-detect |
| **Speed** | Instant | 500ms-1s delay |
| **Inline Results** | Yes | Limited |
| **Debug Integration** | Built-in | Requires extension |
| **Watch Mode** | Yes | Extension-dependent |
| **Coverage** | Via plugin | Extension-dependent |
| **Keyboard** | 100% | Mixed |
| **SSH** | Perfect | Slow |

---

## Troubleshooting

### Tests Not Discovered

1. **Check adapter installed**:
   ```vim
   :Lazy
   # Verify neotest-python, neotest-jest, etc.
   ```

2. **Check test file pattern**:
   ```lua
   -- Python default: *_test.py or test_*.py
   -- Jest default: *.test.js, *.spec.js
   ```

3. **Check project structure**:
   ```bash
   # Python needs __init__.py in test directories
   touch tests/__init__.py
   ```

4. **Reload tests**:
   ```vim
   :lua require("neotest").run.reload()
   ```

### Tests Run But Show No Results

1. **Check treesitter installed**:
   ```vim
   :TSInstall python javascript typescript
   ```

2. **Check test output**:
   ```vim
   <leader>to       " See actual output
   ```

3. **Enable debug logging**:
   ```lua
   -- In neotest.setup()
   log_level = vim.log.levels.DEBUG,
   ```

   Check logs:
   ```vim
   :lua vim.cmd('e ' .. vim.fn.stdpath('log') .. '/neotest.log')
   ```

### Watch Mode Not Working

1. **Check file watcher**:
   ```lua
   -- Ensure this is in your neotest adapter config
   watch = {
       enabled = true,
       mode = "interval",  -- or "watch"
   }
   ```

2. **Try manual watch**:
   ```vim
   <leader>tw       " Toggle watch
   <C-s>            " Save and see if tests run
   ```

---

## Test File Templates

### Python (pytest)

```python
import pytest

def test_basic():
    """Basic test example."""
    assert 1 + 1 == 2

def test_with_fixture(tmp_path):
    """Test with pytest fixture."""
    file = tmp_path / "test.txt"
    file.write_text("hello")
    assert file.read_text() == "hello"

@pytest.mark.parametrize("input,expected", [
    (1, 2),
    (5, 10),
])
def test_parametrized(input, expected):
    """Parametrized test."""
    assert input * 2 == expected

class TestClass:
    """Test class grouping."""
    
    def test_method_one(self):
        assert True
    
    def test_method_two(self):
        assert True
```

### JavaScript (Jest)

```javascript
describe('MyComponent', () => {
  test('renders correctly', () => {
    const result = render(<MyComponent />);
    expect(result).toMatchSnapshot();
  });

  test('handles click', () => {
    const onClick = jest.fn();
    const { getByRole } = render(<MyComponent onClick={onClick} />);
    
    fireEvent.click(getByRole('button'));
    expect(onClick).toHaveBeenCalled();
  });

  test.each([
    [1, 2],
    [5, 10],
  ])('doubles %i to %i', (input, expected) => {
    expect(input * 2).toBe(expected);
  });
});
```

### Go

```go
package mypackage

import "testing"

func TestBasic(t *testing.T) {
    result := Add(1, 2)
    if result != 3 {
        t.Errorf("Expected 3, got %d", result)
    }
}

func TestTable(t *testing.T) {
    tests := []struct {
        name     string
        input    int
        expected int
    }{
        {"double 1", 1, 2},
        {"double 5", 5, 10},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Double(tt.input)
            if result != tt.expected {
                t.Errorf("Expected %d, got %d", tt.expected, result)
            }
        })
    }
}
```

---

## Pro Tips

1. **Run Nearest First**: `<leader>tt` is your most-used command
2. **Use Watch Mode**: `<leader>tw` for instant feedback
3. **Debug Don't Print**: `<leader>td` instead of adding print statements
4. **Jump Through Failures**: `]t` / `[t` for quick navigation
5. **Summary for Overview**: `<leader>ts` when working on multiple files
6. **Output for Details**: `<leader>to` when test fails
7. **Test File Tests**: `<leader>tf` after refactoring
8. **Full Suite Before Commit**: `<leader>ta` before git commit
9. **Coverage for Completeness**: Run coverage to find untested code
10. **Parameterize for Thoroughness**: Test multiple inputs at once

---

## Recommended Workflow

```vim
# TDD Workflow
1. Write test: <leader>tt (fails - red)
2. Write code to make it pass
3. Save: <C-s>
4. Test auto-runs (or <leader>tt)
5. Passes (green)
6. Refactor if needed
7. Run all file tests: <leader>tf
8. Commit

# Debugging Workflow
1. Test fails: <leader>tf
2. Jump to failure: ]t
3. Check output: <leader>to
4. Debug test: <leader>td
5. Step through with <F10>
6. Fix issue
7. Re-run: <leader>tt

# Before Commit Workflow
1. Run all tests: <leader>ta
2. Check summary: <leader>ts
3. Any failures? Navigate with j/k
4. Fix and re-run
5. All green? Commit!
```

---

## Resources

- **Neotest GitHub**: https://github.com/nvim-neotest/neotest
- **Adapters**: https://github.com/nvim-neotest/neotest#supported-runners
- **Documentation**: `:h neotest`
- **Examples**: https://github.com/nvim-neotest/neotest/tree/master/tests

---

**With Neotest, you'll never leave Neovim to run tests again! 🧪✅**
