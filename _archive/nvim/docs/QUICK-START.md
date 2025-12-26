# Quick Start Guide - 30 Minutes to Productivity

> **Goal**: Learn the essential keybindings to match your VSCode productivity in 30 minutes.

## The Absolute Essentials

### Leader Key

```vim
<Space>  = <leader>
```

Everything starts with Space.

---

## File Navigation (5 minutes)

### Open/Close File Explorer

```vim
<leader>e        Toggle Neo-tree
\                Reveal current file in tree
```

### Inside Neo-tree

```vim
j/k              Navigate up/down
<Enter>          Open file
a                Create new file/folder
d                Delete file
r                Rename file
q                Close Neo-tree
```

**Practice**: Open Neo-tree, navigate to a file, open it.

---

## Finding Files (5 minutes)

### Search Files by Name

```vim
<leader>sf       [S]earch [F]iles (like Ctrl+P in VSCode)
```

### Inside Telescope

```vim
<C-j>            Next item
<C-k>            Previous item
<C-l>            Open file
<Esc>            Close
```

### Search Text in Files

```vim
<leader>sg       [S]earch by [G]rep (like Ctrl+Shift+F in VSCode)
```

**Practice**: Press `<leader>sf`, type partial filename, open it.

---

## Code Navigation (5 minutes)

### Jump to Definition/References

```vim
gd               Go to Definition (F12 in VSCode)
gR               Find References (Shift+F12)
gi               Go to Implementation
K                Show documentation (hover)
<C-o>            Jump back
```

### Navigate Errors

```vim
]d               Next error
[d               Previous error
<leader>d        Show error details
```

**Practice**: Place cursor on a function, press `gd`, then `<C-o>` to return.

---

## Code Intelligence (5 minutes)

### Autocompletion (appears automatically)

```vim
<C-j>            Next suggestion
<C-k>            Previous suggestion
<C-Space>        Show completions manually
<CR>             Accept completion
```

### Code Actions

```vim
<leader>ca       Code Actions (Ctrl+. in VSCode)
<leader>rn       Rename symbol (F2 in VSCode)
```

**Practice**: Start typing a function name, use `<C-j>`/`<C-k>` to select, press `<CR>`.

---

## Editing (5 minutes)

### Basic Operations

```vim
<C-s>            Save file
<C-q>            Quit file
<leader>f        Format document (Shift+Alt+F)
```

### Window Management

```vim
<leader>v        Split vertically
<leader>h        Split horizontally
<C-h/j/k/l>      Navigate between splits
<leader>bxs       Close current split
```

### Buffer (Tab) Management

```vim
<Tab>            Next buffer (like Ctrl+Tab)
<S-Tab>          Previous buffer
<leader>bx        Close current buffer
```

**Practice**: Open 2 files, switch between them with `<Tab>`, close one with `<leader>bx`.

---

## Git (5 minutes)

### Git Operations

```vim
<leader>lg       Open LazyGit (full Git TUI)
]h               Next git change (hunk)
[h               Previous git change
<leader>hp       Preview change
<leader>hs       Stage change
```

### In LazyGit

```vim
<Space>          Stage/unstage file
c                Commit
P                Push
q                Quit
?                Help
```

**Practice**: Make a change, press `<leader>lg`, stage with `<Space>`, commit with `c`.

---

## Search Everything (Bonus)

```vim
<leader>sh       Search help
<leader>sk       Search keymaps (find any keybinding!)
<leader>sw       Search current word
<leader>sd       Search diagnostics (problems)
<leader><leader> Search open buffers
```

---

## Your First 30-Minute Workflow

1. **Open Neovim in project**: `nvim .`
2. **Toggle file tree**: `<leader>e`
3. **Find file**: `<leader>sf`, type name, `<C-l>`
4. **Edit file**: Type code, autocompletion appears
5. **Go to definition**: Place cursor on symbol, `gd`
6. **Jump back**: `<C-o>`
7. **Format**: `<leader>f`
8. **Save**: `<C-s>`
9. **Check errors**: `]d` to navigate
10. **Fix error**: `<leader>ca` for code actions
11. **Git commit**: `<leader>lg`, stage, commit, push
12. **Close**: `<C-q>`

---

## Cheat Sheet (Print This!)

```
┌─────────────────────────────────────────────────┐
│              ESSENTIAL KEYBINDINGS              │
├─────────────────────────────────────────────────┤
│ FILES                                           │
│   <leader>e     Toggle file explorer            │
│   <leader>sf    Find files (Ctrl+P)             │
│   <leader>sg    Find in files (Ctrl+Shift+F)    │
├─────────────────────────────────────────────────┤
│ CODE                                            │
│   gd            Go to definition                │
│   gR            Find references                 │
│   K             Show docs                       │
│   <leader>ca    Code actions                    │
│   <leader>rn    Rename                          │
├─────────────────────────────────────────────────┤
│ EDITING                                         │
│   <C-s>         Save                            │
│   <C-q>         Quit                            │
│   <leader>f     Format                          │
│   <Tab>         Next buffer                     │
│   <S-Tab>       Previous buffer                 │
├─────────────────────────────────────────────────┤
│ GIT                                             │
│   <leader>lg    Open LazyGit                    │
│   ]h / [h       Next/prev change                │
│   <leader>hp    Preview change                  │
│   <leader>hs    Stage change                    │
├─────────────────────────────────────────────────┤
│ ERRORS                                          │
│   ]d / [d       Next/prev error                 │
│   <leader>d     Show error                      │
├─────────────────────────────────────────────────┤
│ SPLITS                                          │
│   <C-h/j/k/l>   Navigate splits                 │
│   <leader>v     Split vertical                  │
│   <leader>h     Split horizontal                │
└─────────────────────────────────────────────────┘
```

---

## Next Steps

After mastering these basics:

1. **Day 2-3**: Learn Vim motions (hjkl, w, b, e, 0, $)
2. **Week 1**: Read [Neo-tree Complete Guide](./file-management/01-NEOTREE-COMPLETE-GUIDE.md)
3. **Week 2**: Read [Telescope Complete Guide](./search-navigation/01-TELESCOPE-COMPLETE-GUIDE.md)
4. **Week 3**: Read [LSP Complete Guide](./lsp-intellisense/01-LSP-COMPLETE-GUIDE.md)
5. **Week 4**: Customize your config

---

## Common Questions

### Q: How do I exit insert mode?

**A**: Press `<Esc>` or `jj` (if configured)

### Q: How do I undo?

**A**: `u` in normal mode

### Q: How do I redo?

**A**: `<C-r>` in normal mode

### Q: How do I search in current file?

**A**: `<leader>/` for fuzzy search, or `/` for normal search

### Q: How do I comment code?

**A**: Not configured by default, but see [Additional Plugins](#additional-plugins)

### Q: I'm stuck, how do I get help?

**A**:

- Press `<leader>sk` to search keymaps
- Press `<leader>sh` to search help
- Type `:checkhealth` to diagnose issues
- Type `:Telescope` to explore features

---

## Additional Plugins to Consider

After getting comfortable, consider adding:

1. **Comment.nvim** - Code commenting (`gcc` to toggle line)
2. **nvim-surround** - Surround text with brackets/quotes
3. **vim-visual-multi** - Multi-cursor editing (Ctrl+D in VSCode)
4. **toggleterm.nvim** - Better terminal integration

See [main guide](../NEOVIM_VSCODE_REPLACEMENT_GUIDE.md) for installation instructions.

---

## Troubleshooting

### Completions not showing

```vim
:LspInfo        " Check if LSP is running
<C-Space>       " Manually trigger completion
```

### File tree not opening

```vim
:Neotree        " Try manual command
:checkhealth    " Check for issues
```

### Keybinding not working

```vim
<leader>sk      " Search for the keybinding
:map <key>      " Check what <key> is mapped to
```

---

## Remember

- **Leader = Space**: Everything starts with Space
- **Telescope = Ctrl+P**: File finding and more
- **LSP = IntelliSense**: Code intelligence
- **LazyGit = Git GUI**: Full Git workflow
- **Practice 30 min/day**: Muscle memory takes time

---

**You've got this! In 2-3 weeks, you'll be faster than you ever were in VSCode. 🚀**

For detailed documentation, see [docs/README.md](./README.md)
