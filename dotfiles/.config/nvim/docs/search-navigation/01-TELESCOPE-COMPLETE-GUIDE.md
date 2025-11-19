# Telescope: Complete Fuzzy Finder Guide

## VSCode Feature Replacement

Telescope replaces **multiple VSCode features**:
- ✅ Quick Open (Ctrl+P)
- ✅ Command Palette (Ctrl+Shift+P)
- ✅ Find in Files (Ctrl+Shift+F)
- ✅ Go to Symbol
- ✅ Recent Files
- ✅ Problem List Navigation

**Advantage**: All in one unified, lightning-fast interface with better filtering.

## Your Configuration Analysis

**Location**: `lua/de100/plugins/telescope.lua` (135 lines)

### Installed Plugins

```lua
{
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',                    -- Async utilities
    'nvim-telescope/telescope-fzf-native.nvim', -- Fast C sorter
    'nvim-telescope/telescope-ui-select.nvim',  -- Replace vim.ui.select
    'nvim-tree/nvim-web-devicons',              -- File icons
  }
}
```

### Load Strategy

```lua
event = 'VimEnter'  -- Loads when Vim starts (not lazy)
```

**Why**: Telescope is used so frequently that lazy loading adds unnecessary delay.

## Your Keybindings

### File & Search Operations

| Keybinding | Picker | VSCode Equivalent | Description |
|------------|--------|-------------------|-------------|
| `<leader>sf` | `find_files` | Ctrl+P | Search files by name |
| `<leader>sg` | `live_grep` | Ctrl+Shift+F | Search text in files |
| `<leader>sw` | `grep_string` | - | Search current word globally |
| `<leader>s.` | `oldfiles` | Ctrl+R | Recently opened files |
| `<leader>sr` | `resume` | - | Resume last search |
| `<leader><leader>` | `buffers` | Ctrl+Tab | Open buffers |
| `<leader>/` | `current_buffer_fuzzy_find` | Ctrl+F | Search in current file |
| `<leader>s/` | `live_grep` (open files) | - | Search in open files only |

### Help & Config

| Keybinding | Picker | Description |
|------------|--------|-------------|
| `<leader>sh` | `help_tags` | Search Neovim help |
| `<leader>sk` | `keymaps` | Search keybindings |
| `<leader>ss` | `builtin` | Select Telescope picker |
| `<leader>sd` | `diagnostics` | Search LSP diagnostics |

## Inside Telescope: Navigation

### Your Custom Mappings (Insert Mode)

| Keybinding | Action | Default | Description |
|------------|--------|---------|-------------|
| `<C-k>` | Previous | `<Up>` | Move to previous result |
| `<C-j>` | Next | `<Down>` | Move to next result |
| `<C-l>` | Select | `<CR>` | Open selected file |

### Additional Built-in Mappings

#### Insert Mode (while typing)

| Keybinding | Action |
|------------|--------|
| `<C-c>` / `<Esc>` | Close Telescope |
| `<C-u>` | Clear prompt |
| `<C-q>` | Send to quickfix list |
| `<M-q>` | Send selected to quickfix |
| `<C-/>` | Show mappings help |
| `<C-w>` | Delete word backward |

#### Normal Mode (after Esc)

| Keybinding | Action |
|------------|--------|
| `j` / `k` | Navigate results |
| `gg` / `G` | First / Last result |
| `<CR>` | Select |
| `?` | Show mappings help |
| `q` / `<Esc>` | Close |

#### Preview Navigation

| Keybinding | Action |
|------------|--------|
| `<C-d>` / `<C-u>` | Scroll preview down/up |
| `<C-f>` / `<C-b>` | Page down/up in preview |

#### Multi-Select

| Keybinding | Action |
|------------|--------|
| `<Tab>` | Toggle selection |
| `<S-Tab>` | Toggle selection (reverse) |
| `<C-q>` | Send all to quickfix |
| `<M-q>` | Send selected to quickfix |

## Configuration Deep Dive

### Ignored Patterns

Your config explicitly ignores common directories:

```lua
find_files = {
    file_ignore_patterns = {
        'node_modules',
        '.git',
        '.venv'
    },
    hidden = true  -- Show hidden files (.)
}

live_grep = {
    file_ignore_patterns = {
        'node_modules',
        '.git',
        '.venv'
    },
    additional_args = function(_)
        return {'--hidden'}  -- Search hidden files
    end
}
```

### Extension Configuration

#### 1. FZF Native (Fast C Sorter)

```lua
require('telescope').load_extension('fzf')
```

**Benefits**:
- 10-100x faster than Lua sorting
- Better fuzzy matching algorithm
- Handles large file lists efficiently

**Build Requirement**: Requires `make` installed

#### 2. UI Select

```lua
extensions = {
    ['ui-select'] = {
        require('telescope.themes').get_dropdown()
    }
}
```

**Purpose**: Replaces Vim's default picker for:
- Code actions (`<leader>ca`)
- LSP implementations
- References
- Any vim.ui.select() call

**Result**: Consistent, beautiful selection interface everywhere.

## Picker Deep Dives

### 1. Find Files (`<leader>sf`)

**Your Configuration**:
```lua
find_files = {
    file_ignore_patterns = {'node_modules', '.git', '.venv'},
    hidden = true
}
```

**How It Works**:
1. Uses `fd` if available (faster), falls back to `find`
2. Respects `.gitignore` by default
3. Shows hidden files (dotfiles)

**Pro Tips**:
- Type partial path: `src/com/But` → finds `src/components/Button.tsx`
- Use `/`: Search in subdirectories explicitly
- Case-insensitive by default

**Comparison to VSCode Quick Open**:
| Feature | Telescope | VSCode |
|---------|-----------|--------|
| Speed | Instant | ~100-500ms delay |
| Fuzzy matching | Advanced | Basic |
| Preview | Yes | No |
| Hidden files | Yes | Requires setting |
| Multi-select | Yes | No |

### 2. Live Grep (`<leader>sg`)

**Your Configuration**:
```lua
live_grep = {
    file_ignore_patterns = {'node_modules', '.git', '.venv'},
    additional_args = function(_)
        return {'--hidden'}
    end
}
```

**Backend**: Uses `ripgrep` (rg)

**Capabilities**:
- Search across all files in project
- Real-time results as you type
- Preview with line context
- Jump directly to matches

**Advanced Searches**:
```
# Literal string
hello world

# Regex
function.*\(

# File type filter (built into ripgrep)
--type=ts function

# Case sensitive
--case-sensitive MyComponent
```

**Pro Tips**:
1. Use `<C-q>` to send all results to quickfix
2. Navigate quickfix with `:cnext` / `:cprev`
3. Open quickfix list with `:copen`

**Comparison to VSCode Find in Files**:
| Feature | Telescope live_grep | VSCode |
|---------|---------------------|--------|
| Search speed | Instant | 1-5 seconds |
| Live preview | Yes | No (separate panel) |
| Regex | Full | Basic |
| Results limit | None | Requires "Load More" |
| Jump to line | Instant | Opens in new tab |

### 3. Grep String (`<leader>sw`)

**Purpose**: Search for the word under cursor across entire project

**Workflow**:
1. Cursor on a variable/function name
2. Press `<leader>sw`
3. See all occurrences instantly

**Use Cases**:
- Find where a function is called
- Find all usages of a variable
- Check where a class is imported
- Find all todos with specific tag

**Alternative**: `gR` (LSP references) - but that only works for defined symbols

### 4. Buffers (`<leader><leader>`)

**Purpose**: Switch between open files (like Alt+Tab for buffers)

**Features**:
- Shows all open buffers
- Preview buffer content
- Sort by: Most recent, Name, Modification time

**Workflow**:
```vim
<leader><leader>  " Open buffer picker
Type partial name
<CR> to switch
```

**Better than VSCode's Ctrl+Tab**:
- Shows more than 2 files
- Has fuzzy finding
- Shows preview
- Can delete buffers with `<C-d>`

### 5. Recent Files (`<leader>s.`)

**Purpose**: Open recently edited files

**Your Prompt Hint**: `[S]earch Recent Files ("." for repeat)`

The `.` represents "repeat" or "again" - searching files you've used again.

**Comparison to VSCode**:
- VSCode: File → Open Recent (menu)
- Telescope: `<leader>s.` (instant, fuzzy searchable)

### 6. Current Buffer Fuzzy Find (`<leader>/`)

**Your Configuration**:
```lua
require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false
}
```

**Features**:
- Searches text in current file only
- Dropdown UI (centered, no preview)
- Fuzzy matching
- Jump to line

**Use Case**: Find function in large file
```
# In 2000-line component file
<leader>/
Type: handleSubmit
<CR> - Jumps to function
```

**Better than Ctrl+F in VSCode**:
- Fuzzy matching (don't need exact text)
- Shows all matches at once
- Quick navigation with j/k

### 7. Help Tags (`<leader>sh`)

**Purpose**: Search Neovim's help documentation

**Example Searches**:
```
telescope          " Telescope help
lsp                " LSP documentation
options            " All Vim options
commands           " All commands
```

**Pro Tip**: Preview shows full help text, `<CR>` opens in split

### 8. Keymaps (`<leader>sk`)

**Purpose**: Search all keybindings (yours + plugins)

**Incredible for**:
- Finding what `<leader>x` does
- Discovering available keybindings
- Checking key conflicts

**Live Demo**:
```vim
:lua vim.keymap.set('n', '<leader>test', ':echo "test"<CR>')
<leader>sk
Search: test
# Shows your new mapping!
```

### 9. Diagnostics (`<leader>sd`)

**Purpose**: Search LSP diagnostics (errors, warnings, hints)

**Your Integration**: Works with your LSP setup

**Workflow**:
```vim
<leader>sd        " Open diagnostics
Filter: error     " Show only errors
<CR>              " Jump to error
```

**Columns Shown**:
1. Filename
2. Line number
3. Severity (error/warn/info/hint)
4. Message

**Better than VSCode Problems Panel**:
- Fuzzy searchable
- Instant navigation
- Shows in context
- No separate panel needed

### 10. Resume (`<leader>sr`)

**Purpose**: Resume last Telescope search with same query

**Use Case**:
```vim
# First search
<leader>sg
Type: handleSubmit
Look at results, close

# Later...
<leader>sr
# Reopens with "handleSubmit" search
```

**Time Saver**: No need to retype searches

### 11. Builtin (`<leader>ss`)

**Purpose**: Telescope picker for Telescope pickers (meta!)

**Shows all available pickers**:
- find_files
- live_grep
- buffers
- help_tags
- git_commits
- lsp_references
- ...and 50+ more

**Use Case**: Explore Telescope features

## Advanced Features

### 1. Multi-Select Workflow

```vim
<leader>sf        " Find files
<Tab>             " Select file 1
<Tab>             " Select file 2
<Tab>             " Select file 3
<C-q>             " Send to quickfix list
:copen            " Open quickfix
:cfdo %s/old/new/g | update  " Bulk edit!
```

### 2. Quickfix Integration

**Send Results to Quickfix**:
- `<C-q>` - Send all results
- `<M-q>` - Send selected results

**Navigate Quickfix**:
```vim
:copen            " Open list
:cnext / :cprev   " Navigate
:cfdo {cmd}       " Run command on all
```

### 3. Search History

Telescope remembers your searches:
```vim
<leader>sg        " Live grep
<C-n> / <C-p>     " Cycle through previous searches
```

### 4. File Preview

When searching files:
- Preview updates as you navigate
- Syntax highlighting included
- Shows line numbers
- Scrollable with `<C-d>` / `<C-u>`

### 5. Layout Themes

Your config uses `get_dropdown` for current buffer search:
```lua
require('telescope.themes').get_dropdown({
    winblend = 10,         -- Transparency
    previewer = false      -- No preview for current buffer
})
```

**Available Themes**:
- `get_dropdown()` - Centered, compact
- `get_cursor()` - At cursor position
- `get_ivy()` - Bottom of screen
- Default - Split layout

## Git Integration

Though not explicitly shown in your config, Telescope includes Git pickers:

```vim
:Telescope git_files        " Git-tracked files only
:Telescope git_commits      " Commit history
:Telescope git_branches     " Switch branches
:Telescope git_status       " Modified files
:Telescope git_stash        " Stash list
```

**Recommendation**: Add keybindings:
```lua
vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = '[G]it [C]ommits' })
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = '[G]it [F]iles' })
```

## LSP Integration

Telescope seamlessly integrates with your LSP setup:

```vim
# Already mapped in your lsp.lua
gR              " LSP References (via Telescope)
gi              " LSP Implementations (via Telescope)
gt              " LSP Type Definitions (via Telescope)
<leader>D       " Buffer Diagnostics (via Telescope)
```

**Your LSP Config Shows**:
```lua
keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
```

**Additional LSP Pickers**:
- `:Telescope lsp_definitions`
- `:Telescope lsp_document_symbols`
- `:Telescope lsp_workspace_symbols`
- `:Telescope lsp_dynamic_workspace_symbols`

## Performance Optimization

### Your Config Optimizations

1. **FZF Native Extension**: C-based sorting (much faster)
2. **Ignore Patterns**: Skip node_modules, .git, .venv
3. **Eager Loading**: Loads on VimEnter (no first-use delay)

### System Dependencies

**For Best Performance, Install**:
1. **ripgrep** (rg) - For live_grep
2. **fd** - For find_files (faster than find)
3. **make** - To build fzf-native

```bash
# Ubuntu/Debian
sudo apt install ripgrep fd-find make gcc

# macOS
brew install ripgrep fd make

# Arch Linux
sudo pacman -S ripgrep fd make gcc
```

**Check Status**:
```vim
:checkhealth telescope
```

## Customization Examples

### Change Default Layout

```lua
-- Add to telescope.lua
defaults = {
    layout_strategy = 'vertical',  -- or 'horizontal', 'center', 'cursor'
    layout_config = {
        vertical = {
            width = 0.9,
            height = 0.95,
            preview_height = 0.5,
        }
    }
}
```

### Add File Type Filters

```lua
-- Quick picker for TypeScript files only
vim.keymap.set('n', '<leader>st', function()
    require('telescope.builtin').find_files({
        find_command = {'rg', '--files', '--type=ts', '--type=tsx'}
    })
end, { desc = '[S]earch [T]ypeScript files' })
```

### Search Config Files

```lua
vim.keymap.set('n', '<leader>sc', function()
    require('telescope.builtin').find_files({
        cwd = vim.fn.stdpath('config')
    })
end, { desc = '[S]earch [C]onfig files' })
```

### Search Only in Specific Directory

```lua
vim.keymap.set('n', '<leader>sp', function()
    require('telescope.builtin').find_files({
        cwd = '~/projects'
    })
end, { desc = '[S]earch [P]rojects' })
```

## Common Workflows

### 1. Finding a File in Large Project

```vim
<leader>sf        " Open find_files
Type: comp But    " Fuzzy: components/Button
<CR>              " Open file
```

**Speed**: Instant in 10,000+ file projects

### 2. Finding Function Usage

```vim
# Cursor on function name
<leader>sw        " Search word
Review results
<C-q>             " Send to quickfix if many results
```

### 3. Reviewing Recent Work

```vim
<leader>s.        " Recent files
Browse list
<CR> on file      " Continue editing
```

### 4. Finding Help

```vim
<leader>sh        " Help tags
Type: lsp         " Find LSP help
<CR>              " Open in split
```

### 5. Multi-File Editing

```vim
<leader>sg        " Live grep
Type: TODO:       " Find all TODOs
<Tab>             " Select item 1
<Tab>             " Select item 2
<C-q>             " Send to quickfix
:cfdo s/TODO/DONE/g | update  " Replace in all
```

## Troubleshooting

### Slow Searches

1. **Check ripgrep installation**:
   ```bash
   rg --version
   ```

2. **Add more ignore patterns**:
   ```lua
   file_ignore_patterns = {
       'node_modules', '.git', 'dist', 'build', 'target'
   }
   ```

3. **Limit depth**:
   ```lua
   find_command = {'rg', '--files', '--max-depth=3'}
   ```

### No File Icons

1. Install Nerd Font
2. Check `:checkhealth nvim-web-devicons`

### FZF Extension Not Working

```bash
cd ~/.local/share/nvim/lazy/telescope-fzf-native.nvim
make
```

Then restart Neovim.

## Comparison Table: Telescope vs VSCode

| Feature | Telescope | VSCode Quick Open |
|---------|-----------|-------------------|
| **Speed** | Instant | 100-500ms |
| **Fuzzy Matching** | Advanced | Basic |
| **Preview** | Yes | No |
| **Multi-select** | Yes | No |
| **Quickfix Integration** | Yes | No |
| **Custom Pickers** | Unlimited | Limited |
| **Memory Usage** | 5-10 MB | 50-100 MB |
| **Extensibility** | Full Lua API | Extension API |
| **Search Types** | 50+ built-in | ~5 built-in |

## Pro Tips

1. **Double Tap**: Many searches respond to `<CR><CR>` (select default)
2. **Preview Toggle**: `<C-/>` shows all mappings
3. **Smart Case**: Lowercase = case-insensitive, any uppercase = case-sensitive
4. **Resume is Power**: `<leader>sr` saves so much time
5. **Explore Builtins**: `<leader>ss` to discover new pickers
6. **Quickfix for Bulk**: Multi-select + quickfix + `:cfdo` = bulk refactoring
7. **History Navigation**: `<C-n>`/`<C-p>` in prompt to recall searches
8. **Path Segments**: Type folder names: `src/com/But` works perfectly

## Hidden Gems

### 1. Command History
```vim
:Telescope command_history
```
See all Ex commands you've run

### 2. Search History
```vim
:Telescope search_history
```
See all `/` searches

### 3. Vim Options
```vim
:Telescope vim_options
```
Search and modify options interactively

### 4. Registers
```vim
:Telescope registers
```
See clipboard/register contents

### 5. Marks
```vim
:Telescope marks
```
Navigate to marks

### 6. Jumplist
```vim
:Telescope jumplist
```
Better than `<C-o>`/`<C-i>`

### 7. Spell Suggest
```vim
:Telescope spell_suggest
```
Better than `z=`

## Resources

- **Telescope GitHub**: https://github.com/nvim-telescope/telescope.nvim
- **Documentation**: `:h telescope`
- **Builtin Pickers**: `:h telescope.builtin`
- **Configuration**: `:h telescope.setup`
- **Your Config**: `~/.config/nvim/lua/de100/plugins/telescope.lua`
