# Git Integration: Complete Workflow Guide

## VSCode Feature Replacement

Your Git setup replaces **all VSCode Git features** plus GitLens extension:
- ✅ Git gutter decorations
- ✅ Inline blame
- ✅ Hunk navigation
- ✅ Stage/unstage hunks
- ✅ Preview changes
- ✅ Diff view
- ✅ Commit interface
- ✅ Full Git TUI (LazyGit)
- ✅ File status in explorer

**Advantage**: Faster, keyboard-driven, more powerful, works perfectly over SSH.

## Your Configuration Analysis

### File Structure

```
lua/de100/plugins/
├── gitsigns.lua    (95 lines)  - Git decorations & operations
└── lazygit.lua     (20 lines)  - LazyGit TUI integration
```

Plus Git integration in:
- Neo-tree (file tree Git status)
- Telescope (Git pickers)
- Lualine (current branch)

## Gitsigns: Git Decorations

**Location**: `lua/de100/plugins/gitsigns.lua`

### Plugin Configuration

```lua
{
    'lewis6991/gitsigns.nvim',
    opts = { ... },  -- Extensive configuration
}
```

### Visual Git Status

#### Sign Column Symbols (Your Config)

```lua
signs = {
    add          = { text = '+' },   -- New lines
    change       = { text = '~' },   -- Modified lines
    delete       = { text = '_' },   -- Deleted lines
    topdelete    = { text = '‾' },   -- Deleted at top
    changedelete = { text = '~' },   -- Modified + deleted
    untracked    = { text = '┆' },   -- New file
}
```

**Example in buffer**:
```
  1  │ function hello() {
+ 2  │   console.log('new line');
~ 3  │   return 'modified';
_ 4  │                              ← deleted line
  5  │ }
┆ 6  │ // New function not in git yet
```

#### Staged Signs

```lua
signs_staged = {
    add          = { text = '+' },
    change       = { text = '~' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
}
signs_staged_enable = true
```

**Different colors** for staged vs unstaged changes.

### Git Blame Configuration

```lua
current_line_blame = false,  -- Disabled by default
current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol',  -- End of line
    delay = 1000,            -- 1 second delay
    ignore_whitespace = false,
    virt_text_priority = 100,
    use_focus = true
}
```

**Format**:
```lua
current_line_blame_formatter = '<author>, <author_time:%R> - <summary>'
```

**Example** (when enabled):
```javascript
const user = "John";  // John Doe, 2 hours ago - Add user variable
```

### Your Git Keybindings

All keybindings are set in the `on_attach` callback, meaning they're only active in Git-tracked buffers.

#### Navigation

| Keybinding | Action | Description |
|------------|--------|-------------|
| `]h` | Next hunk | Jump to next change |
| `[h` | Previous hunk | Jump to previous change |

**Hunk**: A contiguous block of changes (added/modified/deleted lines).

#### Hunk Operations (Normal Mode)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>hs` | Stage hunk | Stage current hunk |
| `<leader>hr` | Reset hunk | Discard changes in hunk |
| `<leader>hS` | Stage buffer | Stage all hunks in file |
| `<leader>hR` | Reset buffer | Discard all changes in file |
| `<leader>hu` | Undo stage hunk | Unstage hunk |
| `<leader>hp` | Preview hunk | Show diff in float |

#### Hunk Operations (Visual Mode)

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>hs` | Stage selection | Stage selected lines |
| `<leader>hr` | Reset selection | Discard selected lines |

**Your implementation**:
```lua
map("v", "<leader>hs", function()
    gs.stage_hunk({vim.fn.line("."), vim.fn.line("v")})
end, "Stage hunk")
```

#### Git Blame

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>hb` | Blame line (full) | Show full commit info |
| `<leader>hB` | Toggle inline blame | Toggle blame text |

**Full blame** shows:
```
┌─── Git Blame ─────────────────────────┐
│ Author:  John Doe <john@example.com> │
│ Date:    2024-01-15 14:30:00         │
│ SHA:     a1b2c3d                     │
│ Summary: Add user authentication     │
│                                      │
│ - Added login function               │
│ - Integrated OAuth                   │
└──────────────────────────────────────┘
```

**Inline blame** (toggled):
```javascript
const user = "John";  // John Doe, 2 hours ago - Add user variable
                      ↑ This text appears/disappears
```

#### Diff Operations

| Keybinding | Action | Description |
|------------|--------|-------------|
| `<leader>hd` | Diff this | Show diff against index |
| `<leader>hD` | Diff against HEAD~ | Show diff against previous commit |

**Your implementation**:
```lua
map("n", "<leader>hD", function()
    gs.diffthis("~")  -- Diff against HEAD~1
end, "Diff this ~")
```

#### Text Object

| Keybinding | Mode | Action | Description |
|------------|------|--------|-------------|
| `ih` | Operator/Visual | Select hunk | Inner hunk text object |

**Usage**:
```vim
vih    " Visual select current hunk
dih    " Delete current hunk
yih    " Yank (copy) current hunk
```

**Your implementation**:
```lua
map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
```

### Advanced Gitsigns Features

#### Watch Git Directory

```lua
watch_gitdir = {
    follow_files = true  -- Update when files renamed/moved
}
```

**Benefit**: Hunks update when files change externally (git pull, checkout, etc.)

#### Auto-attach

```lua
auto_attach = true  -- Automatically attach to git files
```

**Disables Gitsigns in**:
- Non-git repositories
- Files with `attach_to_untracked = false`

#### Update Frequency

```lua
update_debounce = 100  -- Wait 100ms after typing before updating
```

**Prevents**: Constant updates while typing, saves CPU.

#### Large File Handling

```lua
max_file_length = 40000  -- Disable for files >40k lines
```

**Performance**: Gitsigns can be slow on huge files.

## LazyGit: Terminal UI

**Location**: `lua/de100/plugins/lazygit.lua`

### Plugin Configuration

```lua
{
    "kdheepak/lazygit.nvim",
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    keys = {
        { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
    },
}
```

**Lazy Loading**: Only loads when `<leader>lg` is pressed.

### Your Keybinding

| Keybinding | Command | Description |
|------------|---------|-------------|
| `<leader>lg` | `:LazyGit` | Open LazyGit TUI |

### LazyGit Interface

LazyGit is a **full-featured Git terminal UI** (not written by you, external tool).

#### Main Panels

```
┌─ Status ────────┬─ Files ──────────┬─ Branches ──────┐
│ On main         │ M  src/app.ts    │ * main          │
│ Changes: 3      │ A  src/new.ts    │   develop       │
│ Ahead: 2        │ D  old.ts        │   feature/auth  │
└─────────────────┴──────────────────┴─────────────────┘
┌─ Commits ───────────────────────────────────────────┐
│ a1b2c3d Add authentication                         │
│ d4e5f6g Fix bug in login                           │
│ g7h8i9j Update dependencies                        │
└──────────────────────────────────────────────────────┘
```

#### Navigation (Inside LazyGit)

| Key | Action |
|-----|--------|
| `1` | Status panel |
| `2` | Files panel |
| `3` | Branches panel |
| `4` | Commits panel |
| `5` | Stash panel |
| `j/k` or `↓/↑` | Navigate items |
| `<Enter>` | Expand/select |
| `<Space>` | Stage/unstage |
| `?` | Help menu |

#### Common Operations

| Key | Operation |
|-----|-----------|
| `c` | Commit |
| `P` | Push |
| `p` | Pull |
| `f` | Fetch |
| `m` | Merge |
| `r` | Rebase |
| `n` | New branch |
| `d` | Delete (branch/commit) |
| `<Ctrl-s>` | Stash changes |
| `v` | View patch |
| `q` | Quit |

#### File Operations

In Files panel:
| Key | Operation |
|-----|-----------|
| `<Space>` | Stage/unstage file |
| `a` | Stage all files |
| `d` | Discard changes |
| `e` | Edit file |
| `o` | Open file |
| `i` | Ignore file |
| `c` | Commit |

#### Commit Flow

```
1. Stage files (<Space> on each file)
2. Press 'c' for commit
3. Enter commit message
4. Save and close (:wq in vim mode)
5. Press 'P' to push
```

#### Branch Operations

```
1. Press '3' to go to Branches panel
2. Press 'n' for new branch
3. Enter branch name
4. Branch created and checked out

Or:
1. Navigate to branch
2. Press <Enter> to checkout
```

#### Merge/Rebase

```
Merge:
1. Checkout target branch
2. Press 'm'
3. Select branch to merge
4. Confirm

Rebase:
1. Checkout feature branch
2. Press 'r'
3. Select branch to rebase onto
4. Resolve conflicts if any
```

### LazyGit vs VSCode

| Feature | LazyGit | VSCode |
|---------|---------|--------|
| **Interface** | TUI | GUI |
| **Speed** | Instant | Slow |
| **Keyboard** | 100% | Partial |
| **Features** | All Git features | Limited |
| **Diff View** | Built-in | Separate panel |
| **Staging** | Per-hunk | Per-file |
| **History** | Interactive | Static |
| **Stash** | Full support | Basic |
| **Rebase** | Interactive | Limited |
| **Cherry-pick** | Yes | No |

## Neo-tree Git Integration

Your Neo-tree config includes Git status:

### Git Symbols (from neo-tree/opt.lua)

```lua
git_status = {
    symbols = {
        added     = "",      -- or "✚"
        modified  = "",      -- or ""
        deleted   = "✖",
        renamed   = "󰁕",
        untracked = "",
        ignored   = "",
        unstaged  = "󰄱",
        staged    = "",
        conflict  = ""
    }
}
```

### Git Status View

```vim
:Neotree git_status float
```

**Shows**:
- All modified files
- Staged/unstaged status
- Quick git operations (stage, unstage, commit)

**Keybindings in Git Status view**:
```lua
["A"]  = "git_add_all",
["ga"] = "git_add_file",
["gu"] = "git_unstage_file",
["gc"] = "git_commit",
["gp"] = "git_push",
["gg"] = "git_commit_and_push",
```

## Telescope Git Pickers

Though not in your explicit config, Telescope includes Git pickers:

```vim
:Telescope git_files        " Git-tracked files
:Telescope git_commits      " Commit history
:Telescope git_bcommits     " Buffer's commit history
:Telescope git_branches     " Branches
:Telescope git_status       " Modified files
:Telescope git_stash        " Stash list
```

**Recommendation**: Add keybindings
```lua
-- Add to telescope.lua
vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = '[G]it [C]ommits' })
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = '[G]it [F]iles' })
vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = '[G]it [B]ranches' })
```

## Complete Git Workflows

### 1. Review Changes Before Commit

```vim
# See what's changed
]h                   " Jump to first hunk
<leader>hp           " Preview hunk
]h                   " Next hunk
<leader>hp           " Preview
# Continue...
```

### 2. Stage Specific Changes

```vim
# Line-by-line staging
Visual select lines
<leader>hs           " Stage selection

# Or hunk-by-hunk
<leader>hp           " Preview hunk
<leader>hs           " Stage hunk
]h                   " Next hunk
<leader>hs           " Stage this one too
```

### 3. Commit with LazyGit

```vim
<leader>lg           " Open LazyGit
# In LazyGit:
<Space>              " Stage files
c                    " Commit
# Enter message
:wq                  " Save commit
P                    " Push
q                    " Quit LazyGit
```

### 4. Quick Commit Current File

```vim
<leader>hS           " Stage entire buffer
<leader>lg           " Open LazyGit
c                    " Commit
# Message
:wq
P
q
```

### 5. Discard Changes

```vim
# Discard specific hunk
<leader>hr           " Reset hunk

# Discard entire file
<leader>hR           " Reset buffer

# Or in LazyGit
<leader>lg
d                    " Discard on file
```

### 6. View File History

```vim
# Check who modified line
<leader>hb           " See full blame

# Check all commits for file
<leader>lg
4                    " Go to commits
# Filter by file (f key in LazyGit)
```

### 7. Compare Versions

```vim
# Diff against staging
<leader>hd

# Diff against previous commit
<leader>hD

# In LazyGit: press 'v' on commit
```

### 8. Branch Workflow

```vim
<leader>lg
3                    " Branches panel
n                    " New branch
# Enter name
<Enter>
# Work on branch
# ...
P                    " Push new branch
```

### 9. Merge Branch

```vim
<leader>lg
3                    " Branches
# Navigate to main
<Enter>              " Checkout main
m                    " Merge
# Select feature branch
<Enter>
# Resolve conflicts if any
```

### 10. Stash Changes

```vim
<leader>lg
<Ctrl-s>             " Stash
# Enter stash message
:wq
# Work on something else
# ...
5                    " Stash panel
<Enter>              " Apply stash
```

## Git + LSP Integration

### Renamed Files

With `nvim-lsp-file-operations` (from Neo-tree config):

```vim
# Rename file in Neo-tree
r                    " Rename
# Enter new name
<Enter>
# LSP automatically updates imports!
```

**Example**:
```typescript
// Before: import { User } from './User'
// Rename User.ts → UserModel.ts in Neo-tree
// After: import { User } from './UserModel'  ← Auto-updated!
```

### Organize Imports on Commit

Your format-on-save (in `formatting.lua`) runs on `BufWritePre`, including before git commits.

**Flow**:
```vim
<C-s>                " Save (triggers format + organize imports)
<leader>lg           " Open LazyGit
c                    " Commit (file already formatted)
```

## Statusline Git Info

Your lualine config shows:
- Current branch name
- Diff stat (added/modified/removed lines)

**Example statusline**:
```
 NORMAL  main  +12 ~5 -3  user.ts  󰦪 1:15  50%
         ↑     ↑    ↑  ↑
      branch  add  mod del
```

## Performance Considerations

### Gitsigns

Your config:
```lua
update_debounce = 100  -- 100ms delay
max_file_length = 40000  -- Skip large files
```

**Why**: Prevents lag when typing in large files.

### LazyGit

LazyGit runs in **separate terminal buffer**, doesn't affect Neovim performance.

## Troubleshooting

### Gitsigns Not Showing

1. **Check in git repo**:
   ```bash
   git status
   ```

2. **Check gitsigns attached**:
   ```vim
   :Gitsigns attach
   ```

3. **Check health**:
   ```vim
   :checkhealth gitsigns
   ```

4. **Re-attach**:
   ```vim
   :Gitsigns detach
   :Gitsigns attach
   ```

### LazyGit Not Opening

1. **Install LazyGit**:
   ```bash
   # Ubuntu/Debian
   sudo apt install lazygit

   # macOS
   brew install lazygit

   # Arch
   sudo pacman -S lazygit
   ```

2. **Check keybinding**:
   ```vim
   :map <leader>lg
   ```

3. **Open manually**:
   ```vim
   :LazyGit
   ```

### Hunks Not Updating

1. **Save file**: Gitsigns updates on write
2. **Wait**: 100ms debounce delay
3. **Refresh**:
   ```vim
   :Gitsigns refresh
   ```

### Diff Issues

If `<leader>hd` doesn't work:
1. Ensure file is saved
2. Ensure you're in git repo
3. Try `:Gitsigns diffthis` manually

## Customization Examples

### Always Show Blame

```lua
-- In gitsigns.lua opts
current_line_blame = true,  -- Enable by default
```

### Change Hunk Symbols

```lua
signs = {
    add = { text = '│' },
    change = { text = '│' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
    untracked = { text = '┆' },
}
```

### Different Blame Format

```lua
current_line_blame_formatter = '<author> • <author_time:%Y-%m-%d> • <summary>'
```

**Result**:
```javascript
const x = 1;  // John Doe • 2024-01-15 • Add variable
```

### Add Git Telescope Keybindings

```lua
-- In telescope.lua
local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = '[G]it [C]ommits' })
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = '[G]it [F]iles' })
vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = '[G]it [B]ranches' })
vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = '[G]it [S]tatus' })
```

### Stage All Modified Files

```lua
-- In gitsigns.lua on_attach
map("n", "<leader>hA", function()
    vim.cmd("Git add -A")
end, "Stage all files")
```

### Quick Commit

```lua
map("n", "<leader>cc", function()
    local msg = vim.fn.input("Commit message: ")
    if msg ~= "" then
        vim.cmd("Git commit -m '" .. msg .. "'")
    end
end, "Quick commit")
```

## Comparison: Your Setup vs VSCode + GitLens

| Feature | Your Setup | VSCode + GitLens |
|---------|-----------|------------------|
| **Gutter decorations** | Gitsigns | Built-in + GitLens |
| **Inline blame** | Gitsigns | GitLens (paid) |
| **Hunk navigation** | `]h`/`[h` | Click gutter |
| **Stage hunks** | `<leader>hs` | Click gutter |
| **Diff view** | `<leader>hd` | Separate panel |
| **Full Git UI** | LazyGit | Multiple extensions |
| **Speed** | Instant | 100-500ms |
| **Keyboard** | 100% | 50% |
| **Commit** | LazyGit or cmdline | GUI |
| **Branch switching** | LazyGit | Dropdown |
| **Merge conflicts** | LazyGit | Extension |
| **Interactive rebase** | LazyGit | No |
| **Stash** | LazyGit | Limited |
| **Memory** | Low | High |

## Pro Tips

1. **Preview Before Stage**: Always `<leader>hp` before `<leader>hs`
2. **Visual Line Stage**: Select exact lines to stage
3. **LazyGit Speed**: Learn single-key commands (c, P, m, r)
4. **Text Object**: `vih` to select hunk, `yih` to copy hunk
5. **Quick Navigation**: `]h` + `<leader>hp` rapid review
6. **Blame Investigation**: `<leader>hb` on surprising code
7. **Reset Safety**: `<leader>hr` resets hunk, `<leader>hR` resets file
8. **Undo Stage**: `<leader>hu` if you staged wrong hunk
9. **Diff Compare**: `<leader>hD` to see original version
10. **LazyGit Filtering**: Use 'f' in LazyGit to filter files/commits

## Advanced Workflows

### Interactive Staging

```vim
# Stage parts of a hunk
<leader>hp           " Preview
V                    " Visual line mode
jj                   " Select specific lines
<leader>hs           " Stage selection
]h                   " Next hunk
```

### Code Review

```vim
<leader>lg           " Open LazyGit
4                    " Commits panel
<Enter>              " Expand commit
v                    " View patch
# Review all changes
j/k                  " Navigate
<Enter>              " Jump to file
```

### Conflict Resolution

```vim
# After merge conflict
<leader>lg           " LazyGit shows conflicts
<Enter>              " On conflicted file
e                    " Edit file
# Resolve conflicts
<C-s>                " Save
# Back to LazyGit
<Space>              " Stage resolved file
c                    " Continue merge
```

### Hotfix Workflow

```vim
<leader>lg
3                    " Branches
n                    " New branch: hotfix/bug-123
# Fix bug
<C-s>                " Save
<leader>hS           " Stage file
<leader>lg
c                    " Commit
P                    " Push hotfix branch
```

## Resources

- **Gitsigns GitHub**: https://github.com/lewis6991/gitsigns.nvim
- **LazyGit GitHub**: https://github.com/jesseduffield/lazygit
- **LazyGit Docs**: https://github.com/jesseduffield/lazygit#keybindings
- **Gitsigns Docs**: `:h gitsigns`
- **Your Config**: `~/.config/nvim/lua/de100/plugins/gitsigns.lua`
