# nvim-cmp: Complete Code Completion Guide

## VSCode Feature Replacement

nvim-cmp replaces **VSCode's IntelliSense** with these advantages:
- ✅ Faster completion popup (10-50ms vs 100-300ms)
- ✅ Multiple sources simultaneously (LSP + snippets + buffer + path)
- ✅ Fully customizable appearance
- ✅ Better snippet integration
- ✅ Lower memory usage
- ✅ Works identically over SSH

## Your Configuration Analysis

**Location**: `lua/de100/plugins/nvim-cmp.lua` (67 lines)

### Plugin Ecosystem

```lua
{
    "hrsh7th/nvim-cmp",             -- Completion engine
    event = "InsertEnter",          -- Load only in insert mode
    dependencies = {
        "hrsh7th/cmp-buffer",       -- Buffer text completions
        "hrsh7th/cmp-path",         -- File path completions
        "L3MON4D3/LuaSnip",         -- Snippet engine
        "saadparwaiz1/cmp_luasnip", -- Snippet completions
        "rafamadriz/friendly-snippets", -- VSCode-style snippets
        "onsails/lspkind.nvim"      -- VS-Code pictograms
    }
}
```

## Completion Sources

Your config enables **4 completion sources** in priority order:

### 1. LSP Completions (`nvim_lsp`)

**Priority**: Highest
**Provides**:
- Functions, methods, classes
- Variables, constants
- Types, interfaces
- Modules, imports
- Keywords
- Auto-imports

**Example**:
```typescript
import { use|  ← Type "use"
# Suggestions:
# useState (auto-import from 'react')
# useEffect (auto-import from 'react')
# useCallback (auto-import from 'react')
```

### 2. Snippet Completions (`luasnip`)

**Priority**: High
**Provides**:
- Pre-defined code templates
- Multi-cursor positions
- Dynamic placeholders
- Contextual snippets

**Sources**:
- `friendly-snippets` - VSCode-compatible snippets
- Custom snippets (if you add them)

**Example**:
```typescript
rfc|  ← Type "rfc"
# Expands to React Functional Component:
export const ComponentName = () => {
  return (
    <div>
      |  ← Cursor here
    </div>
  );
};
```

### 3. Buffer Text Completions (`buffer`)

**Priority**: Medium
**Provides**:
- Words from current buffer
- Words from other open buffers
- Variable names you've used
- Function names in file

**Example**:
```typescript
const handleUserSubmit = () => {}
// Later in file:
handleU|  ← Type "handleU"
# Suggests: handleUserSubmit (from buffer)
```

### 4. File Path Completions (`path`)

**Priority**: Low
**Provides**:
- File paths
- Directory paths
- Relative/absolute paths

**Example**:
```typescript
import MyComponent from './|  ← Type "./"
# Suggestions:
# ./components/
# ./utils/
# ./types/
# ./MyComponent.tsx
```

## Keybindings Analysis

### Your Custom Mappings (Insert Mode)

| Keybinding | Action | Default | Description |
|------------|--------|---------|-------------|
| `<C-k>` | Previous | `<C-p>` | Move to previous suggestion |
| `<C-j>` | Next | `<C-n>` | Move to next suggestion |
| `<C-b>` | Scroll up | - | Scroll documentation up |
| `<C-f>` | Scroll down | - | Scroll documentation down |
| `<C-Space>` | Complete | `<C-Space>` | Trigger completion manually |
| `<C-e>` | Abort | `<C-e>` | Close completion menu |
| `<CR>` | Confirm | `<CR>` | Accept selected completion |

### Completion Behavior

```lua
mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({
        select = false  -- Must explicitly select item
    })
})
```

**Important**: `select = false` means:
- Pressing `<CR>` without selection → Just inserts newline
- Must explicitly select with `<C-k>`/`<C-j>` first
- Prevents accidental completions

**VSCode Comparison**:
- VSCode: `<Tab>` accepts, `<CR>` depends on setting
- Your config: `<CR>` only accepts when explicitly selected
- More predictable behavior!

## Visual Appearance

### LSPKind Integration

```lua
formatting = {
    format = lspkind.cmp_format({
        maxwidth = 50,
        ellipsis_char = "..."
    })
}
```

**Pictograms** (VSCode-style icons):
- 󰊕 Function
- 󰀫 Variable
- 󰙅 Class
- 󰕘 Method
- 󰜢 Property
- 󰻂 Module
- 󰘦 Keyword
-  Snippet
-  File

**Menu Appearance**:
```
┌─────────────────────────────────────────────┐
│ useState        Function  react          │
│ useEffect       Function  react          │
│ useCallback     Function  react          │
│ userInfo        Variable                  │
│ for            Snippet                   │
└─────────────────────────────────────────────┘
```

**Columns**:
1. Item text
2. Icon (pictogram)
3. Source (where it came from)

### Documentation Window

Shows additional info about selected item:
```
┌─── Documentation ────────────┐
│ useState<S>(                │
│   initialState: S | (() => S)│
│ ): [S, Dispatch<...>]       │
│                             │
│ Returns a stateful value    │
│ and function to update it.  │
└──────────────────────────────┘
```

**Scrollable** with `<C-f>` / `<C-b>`

## Snippet Engine: LuaSnip

### Configuration

```lua
snippet = {
    expand = function(args)
        luasnip.lsp_expand(args.body)
    end
}
```

### Included Snippets

From `friendly-snippets`, includes snippets for:
- **JavaScript/TypeScript**: 50+ snippets
- **React**: Components, hooks
- **HTML/CSS**: Tags, properties
- **Python**: Classes, functions, doctstrings
- **Lua**: Functions, tables
- **Many more languages**

### Common Snippets by Language

#### JavaScript/TypeScript
```javascript
// clg → console.log()
clg|  → console.log(object)

// fn → function
fn|  → function name(params) { }

// afn → arrow function
afn|  → const name = (params) => { }

// imp → import
imp|  → import name from 'module'

// ex → export
ex|  → export { name }
```

#### React/TypeScript
```typescript
// rfc → React Functional Component
rfc|  → 
import React from 'react'
export const ComponentName = () => {
  return <div></div>
}

// rfce → with export default
// rus → useState
// rue → useEffect
// ruc → useCallback
```

#### Python
```python
# def → function
def|  → 
def function_name(args):
    pass

# class → class definition
class|  → 
class ClassName:
    def __init__(self):
        pass

# ifmain → if __name__ == '__main__'
```

#### HTML
```html
<!-- html5 → full HTML5 boilerplate -->
html5|  → 
<!DOCTYPE html>
<html lang="en">
<head>...</head>
<body></body>
</html>

<!-- div → div.class -->
<!-- link → stylesheet link -->
<!-- script → script tag -->
```

### Snippet Navigation

When snippet is expanded:
1. Type trigger + `<CR>` or select from completion
2. Snippet expands with placeholders
3. Navigate placeholders:
   - Next: `<Tab>` or `<C-j>`
   - Previous: `<S-Tab>` or `<C-k>`
4. Edit each placeholder
5. Exit snippet mode automatically when done

**Note**: Your config doesn't explicitly set `<Tab>` for snippets, so standard `<C-j>`/`<C-k>` navigation applies.

## Completion Trigger Behavior

### Auto-Trigger

Completion menu appears automatically when:
1. You start typing (after 1-2 characters)
2. You type a trigger character (`.`, `:`, `::`, etc.)
3. LSP suggests items

### Manual Trigger

```vim
# In insert mode, not seeing completions
<C-Space>  " Shows completion menu
```

### Completion Context

Smart about when to show:
- ✅ After `.` (object property access)
- ✅ After `import` keyword
- ✅ In string literals (for paths)
- ❌ In comments (usually)
- ❌ In strings (unless path)

## Source Priority

Your configuration:

```lua
sources = cmp.config.sources({
    { name = "nvim_lsp" },   -- Highest priority
    { name = "luasnip" },    -- Second
    { name = "buffer" },     -- Third
    { name = "path" }        -- Lowest
})
```

**How It Works**:
1. LSP provides items first
2. If LSP has nothing, check snippets
3. If snippets empty, check buffer
4. If buffer empty, check paths

**Example**:
```typescript
import { | ← Empty after {
# Priority:
1. LSP: Suggests exports from modules
2. Snippets: None applicable
3. Buffer: Variable names from file
4. Path: File paths
# Result: Shows LSP suggestions (imports)
```

## Performance Optimizations

### Lazy Loading

```lua
event = "InsertEnter"
```

**Benefit**: nvim-cmp only loads when entering insert mode
**Impact**: Saves ~3-5 MB memory, ~20-30ms startup time

### Efficient Sources

Your sources are ordered by usefulness:
1. LSP (most relevant)
2. Snippets (highly useful)
3. Buffer (contextual)
4. Path (specific cases)

**No slow sources** like:
- Dictionary
- Spell
- Tags (can be slow)

## Workflows

### 1. Auto-Import Workflow

```typescript
// File: Component.tsx
useState|  ← Type "useState"
<C-Space>  ← If not auto-shown
<C-j>      ← Select "useState"
<CR>       ← Confirm

// Auto-added at top:
import { useState } from 'react';

// Cursor position:
const [state, setState] = useState(|)
```

### 2. Snippet Expansion

```typescript
for|       ← Type "for"
<C-j>      ← Navigate to "for loop" snippet
<CR>       ← Expand

// Expands to:
for (let i = 0; i < array.length; i++) {
  |← First placeholder
}

// Continue:
<Tab> or <C-j>  ← Jump to "array" placeholder
Type: items
<Tab>           ← Jump to loop body
```

### 3. Path Completion

```typescript
import Comp from './|  ← Type "./"
<C-Space>              ← Show completions
<C-j> to navigate
<CR> on component file

// Result:
import Comp from './components/MyComponent'
```

### 4. Buffer Word Completion

```typescript
// Earlier in file:
const handleUserAuthentication = () => {}

// Later:
handle|    ← Start typing
<C-Space>  ← Trigger completion
# Shows: handleUserAuthentication from buffer
<CR>       ← Accept
```

### 5. Documentation Review

```typescript
Array.|  ← Type "Array."
# Completion shows Array methods
<C-j>    ← Navigate to "filter"
# Documentation window shows:
#   filter<S>(predicate: ...)
#   Returns array elements that meet condition
<C-f>    ← Scroll down in docs
<C-b>    ← Scroll up in docs
<CR>     ← Accept completion
```

## LSP-Specific Completions

### TypeScript/JavaScript

**Functions**:
```typescript
Array.map|  → Array.map((value, index, array) => {})
```

**Auto-Imports**:
```typescript
React.|  → Shows React exports, auto-imports
```

**Type Completions**:
```typescript
const user: U|  → Shows User type, auto-imports
```

### Python

**Methods**:
```python
list.|  → Shows list methods (append, extend, etc.)
```

**Type Hints**:
```python
def func(param: s|  → Shows str, Set, etc.
```

### HTML/CSS

**Tags**:
```html
<di|  → <div>
```

**Classes** (with Tailwind LSP):
```html
<div class="flex |"  → Shows Tailwind classes
```

### SQL

**Keywords**:
```sql
SEL|  → SELECT
```

**Table Names** (if LSP configured):
```sql
SELECT * FROM |  → Shows available tables
```

## Customization Examples

### Change Keybindings

```lua
-- Edit in nvim-cmp.lua
mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),  -- Tab for next
    ["<S-Tab>"] = cmp.mapping.select_prev_item(), -- Shift-Tab for prev
    ["<CR>"] = cmp.mapping.confirm({ select = true }) -- Auto-select
})
```

### Add More Sources

```lua
-- Add spell checker
sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
    { name = "spell" }  -- Add spell checking
})
```

**Requires**: `hrsh7th/cmp-spell` plugin

### Change Max Items

```lua
completion = {
    max_item_count = 20  -- Default is unlimited
}
```

### Disable for Certain Files

```lua
-- In nvim-cmp.lua config
cmp.setup({
    enabled = function()
        -- Disable in telescope prompts
        local buftype = vim.api.nvim_buf_get_option(0, "buftype")
        if buftype == "prompt" then return false end
        
        -- Disable in comments
        local context = require('cmp.config.context')
        if context.in_treesitter_capture("comment") then
            return false
        end
        
        return true
    end,
    -- ... rest of config
})
```

### Custom Snippets

Create custom snippets:

```lua
-- ~/.config/nvim/snippets/typescript.lua
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("typescript", {
    s("customLog", {
        t("console.log('"),
        i(1, "message"),
        t(":', "),
        i(2, "variable"),
        t(");")
    })
})
```

## Comparison: nvim-cmp vs VSCode IntelliSense

| Feature | nvim-cmp | VSCode |
|---------|----------|--------|
| **Popup Speed** | 10-50ms | 100-300ms |
| **Memory** | 3-5 MB | 30-50 MB |
| **Sources** | Unlimited plugins | Limited API |
| **Customization** | Full Lua control | JSON settings only |
| **Snippet Engine** | LuaSnip, UltiSnips, etc. | Built-in only |
| **Appearance** | Fully customizable | Fixed with themes |
| **Performance** | Configurable | Fixed |
| **Multi-source** | Native | Extension-dependent |

## Troubleshooting

### Completions Not Showing

1. **Check LSP is running**:
   ```vim
   :LspInfo
   ```

2. **Check cmp sources**:
   ```vim
   :lua =vim.inspect(require('cmp').get_sources())
   ```

3. **Manually trigger**:
   ```vim
   <C-Space>
   ```

4. **Check if disabled**:
   ```vim
   :lua =require('cmp').setup.enabled
   ```

### Slow Completions

1. **Limit sources**:
   Remove buffer source if file is large

2. **Reduce max items**:
   ```lua
   performance = {
       max_view_entries = 10
   }
   ```

3. **Check LSP performance**:
   ```vim
   :LspLog
   ```

### Snippets Not Working

1. **Check LuaSnip**:
   ```vim
   :lua =require('luasnip').available()
   ```

2. **Reload snippets**:
   ```vim
   :lua require('luasnip.loaders.from_vscode').lazy_load()
   ```

3. **Check snippet source**:
   ```vim
   :lua =vim.tbl_contains(require('cmp').get_sources(), 'luasnip')
   ```

### Documentation Not Showing

Ensure window config allows it:
```lua
window = {
    documentation = cmp.config.window.bordered()
}
```

## Pro Tips

1. **Quick Accept**: Type enough letters to be unique, then `<CR>`
2. **Fuzzy Matching**: Don't type full words, "usSt" matches "useState"
3. **Scroll Docs**: Always read docs with `<C-f>`/`<C-b>`
4. **Path Relative**: `./ for relative, / for absolute`
5. **Buffer Local**: Current buffer suggestions appear faster
6. **Case Sensitive**: Uppercase in query = case-sensitive match
7. **Snippet Prefix**: Learn common prefixes (fn, cl, imp, etc.)
8. **Manual Trigger**: `<C-Space>` when auto-complete isn't working
9. **Preview Before Accept**: Read documentation first!
10. **Abort on Mistake**: `<C-e>` to close and retype

## Hidden Features

### 1. Experimental Ghost Text

```lua
experimental = {
    ghost_text = true  -- Shows inline completion suggestion
}
```

### 2. Compare Items

```lua
sorting = {
    comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
    }
}
```

### 3. Keyword Length

```lua
-- Minimum characters before showing completions
completion = {
    keyword_length = 1  -- Default
}
```

### 4. Preselect

```lua
preselect = cmp.PreselectMode.Item  -- Auto-select first item
```

## Resources

- **nvim-cmp GitHub**: https://github.com/hrsh7th/nvim-cmp
- **Documentation**: `:h nvim-cmp`
- **LuaSnip Docs**: `:h luasnip`
- **Friendly Snippets**: https://github.com/rafamadriz/friendly-snippets
- **Your Config**: `~/.config/nvim/lua/de100/plugins/nvim-cmp.lua`
