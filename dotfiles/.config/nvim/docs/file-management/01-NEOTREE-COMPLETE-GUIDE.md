# Neo-tree: Complete File Explorer Guide

## VSCode Feature Replacement

Neo-tree replaces **VSCode's File Explorer** with these advantages:
- ✅ Faster file operations
- ✅ Git status integration
- ✅ Fuzzy finding within tree
- ✅ Multiple view modes (filesystem, buffers, git)
- ✅ Keyboard-first navigation
- ✅ Customizable icons and colors

## Your Configuration Analysis

**Location**: `lua/de100/plugins/neotree/`
- `init.lua` - Plugin setup and keybindings
- `opt.lua` - Detailed configuration (423 lines!)

### Installed Plugins

```lua
{
  "nvim-neo-tree/neo-tree.nvim",  -- Main plugin
  dependencies = {
    "nvim-lua/plenary.nvim",       -- Async utilities
    "MunifTanjim/nui.nvim",        -- UI components
    "nvim-tree/nvim-web-devicons", -- File icons
    "3rd/image.nvim"               -- Image preview (optional)
  }
}
```

## Global Keybindings

### Your Custom Mappings

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>e` | `:Neotree toggle position=left<CR>` | Toggle file explorer |
| `\` | `:Neotree reveal<CR>` | Reveal current file in tree |
| `<leader>ngs` | `:Neotree float git_status<CR>` | Open Git status window |

## Inside Neo-tree: Navigation

### File Operations (Your Config)

| Key | Command | Action |
|-----|---------|--------|
| `<Enter>` / `<CR>` | `open` | Open file |
| `<2-LeftMouse>` | `open` | Open file (double-click) |
| `<Space>` | `toggle_node` | Expand/collapse directory |
| `l` | `focus_preview` | Focus on preview window |
| `P` | `toggle_preview` | Toggle preview pane |

### Split Management

| Key | Command | Action |
|-----|---------|--------|
| `S` | `open_split` | Open in horizontal split |
| `s` | `open_vsplit` | Open in vertical split |
| `t` | `open_tabnew` | Open in new tab |
| `w` | `open_with_window_picker` | Choose window to open in |

### Directory Navigation

| Key | Command | Action |
|-----|---------|--------|
| `<BS>` | `navigate_up` | Go to parent directory |
| `.` | `set_root` | Set current directory as root |
| `C` | `close_node` | Close current node |
| `z` | `close_all_nodes` | Close all nodes |

### File Management

| Key | Command | Action | Notes |
|-----|---------|--------|-------|
| `a` | `add` | Create new file/directory | Use `/` at end for directory |
| `A` | `add_directory` | Create new directory | |
| `d` | `delete` | Delete file/directory | Asks for confirmation |
| `r` | `rename` | Rename file/directory | Full path rename |
| `b` | `rename_basename` | Rename only the basename | Extension preserved |

#### Creating Files: Advanced Syntax

Your config supports **BASH-style brace expansion**:

```
# Create multiple files at once
file{1,2,3}.txt  →  file1.txt, file2.txt, file3.txt

# Create nested structure
src/{components,utils}/index.ts  →  src/components/index.ts, src/utils/index.ts

# Create with extensions
test.{js,test.js,spec.js}  →  test.js, test.test.js, test.spec.js
```

### Clipboard Operations

| Key | Command | Action |
|-----|---------|--------|
| `y` | `copy_to_clipboard` | Copy file path to clipboard |
| `x` | `cut_to_clipboard` | Cut file to clipboard |
| `c` | `copy` | Copy file (prompts destination) |
| `m` | `move` | Move file (prompts destination) |
| `p` | `paste_from_clipboard` | Paste from clipboard |
| `<C-C>` | `clear_clipboard` | Clear clipboard |

### Searching & Filtering

| Key | Command | Action |
|-----|---------|--------|
| `/` | `fuzzy_finder` | Fuzzy find files in tree |
| `D` | `fuzzy_finder_directory` | Fuzzy find directories |
| `#` | `fuzzy_sorter` | Fuzzy sort using fzy algorithm |
| `f` | `filter_on_submit` | Filter files |
| `<C-x>` | `clear_filter` | Clear filter |
| `H` | `toggle_hidden` | Toggle hidden files |

#### Fuzzy Finder Controls

When in fuzzy finder mode:

| Key | Action |
|-----|--------|
| `<C-n>` / `<Down>` | Move cursor down |
| `<C-p>` / `<Up>` | Move cursor up |
| `<Esc>` | Close finder |
| `<S-CR>` | Close keeping filter |
| `<C-CR>` | Close clearing filter |

In normal mode within fuzzy finder:
- `j` - Down
- `k` - Up

### Sorting & Ordering

Your config includes extensive ordering options:

| Key | Sort By |
|-----|---------|
| `oc` | Created date |
| `od` | Diagnostics |
| `og` | Git status |
| `om` | Modified date |
| `on` | Name |
| `os` | Size |
| `ot` | Type |

Prefix: Press `o` to see ordering menu

### Git Operations

| Key | Command | Action |
|-----|---------|--------|
| `[g` | `prev_git_modified` | Previous git-modified file |
| `]g` | `next_git_modified` | Next git-modified file |

#### Git Status Window (Floating)

In git status mode (`:Neotree float git_status`):

| Key | Command | Action |
|-----|---------|--------|
| `A` | `git_add_all` | Stage all changes |
| `ga` | `git_add_file` | Stage current file |
| `gu` | `git_unstage_file` | Unstage current file |
| `gU` | `git_undo_last_commit` | Undo last commit |
| `gr` | `git_revert_file` | Revert file changes |
| `gc` | `git_commit` | Commit staged changes |
| `gp` | `git_push` | Push commits |
| `gg` | `git_commit_and_push` | Commit and push |

### Information & Help

| Key | Command | Action |
|-----|---------|--------|
| `?` | `show_help` | Show all commands |
| `i` | `show_file_details` | Show file info (size, date, type) |
| `R` | `refresh` | Refresh tree |
| `q` | `close_window` | Close Neo-tree |
| `<Esc>` | `cancel` | Close preview or cancel operation |

### Source Switching

| Key | Command | Action |
|-----|---------|--------|
| `<` | `prev_source` | Previous source (filesystem→buffers→git) |
| `>` | `next_source` | Next source |

## Configuration Deep Dive

### Window Settings

```lua
window = {
    position = "left",    -- Can be: left, right, top, bottom, float, current
    width = 40,           -- Fixed width
}
```

### Icon Configuration

Your config uses Nerd Font icons:

```lua
icon = {
    folder_closed = "",
    folder_open = "",
    folder_empty = "󰜌",
}
```

### Git Status Symbols

```lua
git_status = {
    symbols = {
        added = "",      -- or "✚"
        modified = "",   -- or ""
        deleted = "✖",
        renamed = "󰁕",
        untracked = "",
        ignored = "",
        unstaged = "󰄱",
        staged = "",
        conflict = ""
    }
}
```

### Filtered Items

Your config hides these by default:

```lua
filtered_items = {
    hide_dotfiles = true,
    hide_gitignored = true,
    ignore_files = {
        ".neotreeignore",
        ".ignore",
        ".DS_Store",
        "thumbs.db",
        "node_modules",
        "__pycache__",
        ".virtual_documents",
        ".git",
        ".python-version",
        ".venv",
        ".rgignore"
    }
}
```

To toggle visibility: Press `H`

### Columns Display

Neo-tree shows additional columns when window is wide enough:

| Column | Min Width | Your Config |
|--------|-----------|-------------|
| File Size | 64px | Enabled (12 chars) |
| Type | 122px | Enabled (10 chars) |
| Last Modified | 88px | Enabled (20 chars) |
| Created | 110px | Enabled (20 chars) |

### Diagnostics Integration

```lua
enable_diagnostics = true
```

Shows LSP diagnostics (errors, warnings) in the tree with these symbols:
- `` - Error
- `` - Warning
- `` - Info
- `󰌵` - Hint

## View Modes

### 1. Filesystem Mode (Default)

```vim
:Neotree filesystem left
```

Features:
- Browse file system
- File operations
- Git status per file
- Diagnostics per file

### 2. Buffers Mode

```vim
:Neotree buffers left
```

Shows all open buffers (like VSCode's "Open Editors")

Special mappings:
- `d` / `bd` - Close buffer (delete)
- Shows unloaded buffers: `show_unloaded = true`

### 3. Git Status Mode

```vim
:Neotree git_status float
```

Shows all modified files in git
- Perfect for reviewing changes
- Quick staging/unstaging
- Commit directly from tree

## Advanced Features

### Preview Mode

Press `P` to toggle preview:
- Shows file content in floating window
- Navigate tree, preview updates automatically
- Image support (if `3rd/image.nvim` installed)

```lua
toggle_preview = {
    config = {
        use_float = true,
        use_snacks_image = true,
        use_image_nvim = true
    }
}
```

### Window Picker Integration

When opening files with `w`:
1. Shows window picker overlay
2. Type the highlighted character
3. File opens in selected window

Configured with `nvim-window-picker` plugin.

### LSP File Operations

The `nvim-lsp-file-operations` dependency means:
- Renaming updates imports automatically
- Moving files updates import paths
- Works with TypeScript, JavaScript, Python, etc.

## Comparison with VSCode Explorer

| Feature | Neo-tree | VSCode Explorer |
|---------|----------|-----------------|
| **Open file** | `<CR>` | Click |
| **Reveal file** | `\` | Right-click → Reveal |
| **New file** | `a` | Right-click → New File |
| **Rename** | `r` | F2 or Right-click |
| **Delete** | `d` | Delete key |
| **Copy** | `c` | Ctrl+C |
| **Paste** | `p` | Ctrl+V |
| **Search** | `/` | Ctrl+F |
| **Git status** | Built-in icons | Needs GitLens |
| **Fuzzy find** | `/` | Not available |
| **Preview** | `P` | Not available |
| **Multiple views** | `<` / `>` | Manual switching |

## Common Workflows

### 1. Creating a New Component

```vim
# In Neo-tree
1. Press <leader>e to open
2. Navigate to src/components/
3. Press a
4. Type: MyComponent/{index.tsx,styles.css,types.ts}
5. Press Enter
# Creates:
#   src/components/MyComponent/index.tsx
#   src/components/MyComponent/styles.css
#   src/components/MyComponent/types.ts
```

### 2. Reviewing Git Changes

```vim
1. Press <leader>ngs (opens git status float)
2. Navigate with j/k
3. Press <Enter> to see file
4. Press ga to stage
5. Press gc to commit
```

### 3. Finding a File Fast

```vim
1. Press <leader>e
2. Press /
3. Type partial filename
4. Press <Enter> to open
```

### 4. Organizing Files

```vim
# Cut and paste
1. Navigate to file
2. Press x (cut)
3. Navigate to destination folder
4. Press p (paste)

# Copy with new name
1. Navigate to file
2. Press c
3. Type new path
4. Press Enter
```

### 5. Quick File Info

```vim
1. Navigate to file
2. Press i
# Shows:
#   - File size
#   - Created date
#   - Modified date
#   - File type
```

## Performance Considerations

### File Watchers

```lua
use_libuv_file_watcher = false
```

Your config disables OS-level file watchers for:
- Better performance
- Lower battery usage
- Less OS integration issues

To refresh manually: Press `R`

### Follow Current File

```lua
follow_current_file = {
    enabled = false,
    leave_dirs_open = false
}
```

Disabled for performance (doesn't auto-reveal on buffer switch)

To manually reveal: Press `\`

## Customization Tips

### Change Window Width

Edit `lua/de100/plugins/neotree/opt.lua`:

```lua
window = {
    width = 50,  -- Change from 40 to 50
}
```

### Always Show Hidden Files

```lua
filtered_items = {
    visible = true,  -- Change from false
    hide_dotfiles = false,  -- Change from true
}
```

### Auto-follow Current File

```lua
follow_current_file = {
    enabled = true,  -- Change from false
}
```

### Different Position

```lua
window = {
    position = "float",  -- or "right", "current"
}
```

## Troubleshooting

### Icons Not Showing

1. Install a Nerd Font: https://www.nerdfonts.com/
2. Set terminal font to Nerd Font
3. Restart Neovim
4. Run: `:checkhealth nvim-web-devicons`

### Git Status Not Working

```vim
:checkhealth gitsigns
```

Ensure you're in a git repository.

### Slow Performance

1. Disable file watchers (already done in your config)
2. Add more patterns to `ignore_files`
3. Reduce window width
4. Disable preview mode

### Can't Create Files

Check permissions in the directory:
```bash
ls -la
```

## Commands Reference

All available Ex commands:

```vim
:Neotree                         " Toggle with last position
:Neotree reveal                  " Reveal current file
:Neotree toggle                  " Toggle on/off
:Neotree close                   " Close
:Neotree show                    " Show
:Neotree focus                   " Focus tree
:Neotree filesystem              " Switch to filesystem
:Neotree buffers                 " Switch to buffers
:Neotree git_status              " Switch to git status
:Neotree position=left           " Open on left
:Neotree position=float          " Open as floating window
:Neotree dir=/path/to/dir        " Open specific directory
```

## Integration with Other Plugins

### With Telescope

```vim
# Find file in Telescope, then reveal in Neo-tree
<leader>sf → select file → \ (reveal)
```

### With LSP

- Automatic import updates on rename
- Automatic path updates on move
- Provided by `nvim-lsp-file-operations`

### With Gitsigns

- Git status shows in tree
- Modified files highlighted
- Navigate git changes: `[g` / `]g`

## Pro Tips

1. **Bulk Operations**: Use visual mode (V) + multiple selections
2. **Quick Parent**: `<BS>` repeatedly to go up directory tree
3. **Root Switch**: `.` to set current directory as root (useful for large projects)
4. **Copy Path**: `y` to copy file path to clipboard
5. **Git Review**: `<leader>ngs` + `[g`/`]g` for fast change review
6. **Fuzzy Everything**: `/` works everywhere in Neo-tree
7. **Preview While Browsing**: Enable preview with `P`, navigate with arrows
8. **Multi-Window**: Use `w` to choose which window to open file in

## Keyboard-Only Workflow

Completely replace mouse usage:

1. `<leader>e` - Open tree
2. `j`/`k` or `<C-n>`/`<C-p>` - Navigate
3. `/` - Fuzzy find
4. `<Enter>` - Open file
5. `<leader>e` - Close tree
6. Edit file
7. `<C-s>` - Save
8. Repeat

Zero mouse interaction needed!

## Resources

- **Neo-tree GitHub**: https://github.com/nvim-neo-tree/neo-tree.nvim
- **Documentation**: `:h neo-tree`
- **Commands**: `:h neo-tree-commands`
- **Mappings**: `:h neo-tree-mappings`
- **Your Config**: `~/.config/nvim/lua/de100/plugins/neotree/`
