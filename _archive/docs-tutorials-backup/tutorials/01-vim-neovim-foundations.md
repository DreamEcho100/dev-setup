# 01. Vim And Neovim Foundations

This is the minimum mental model needed to use the config effectively.

## Modes

```text
Normal  -> move, operate, run commands
Insert  -> type text
Visual  -> select text
Command -> run Ex commands after :
Terminal -> interact with shell programs
```

Core keys:

| Action | Key |
| --- | --- |
| Leave Insert mode | `<Esc>` or `<C-c>` |
| Save | `<C-s>` |
| Save without format/autocmd | `<leader>sn` |
| Quit current window | `<C-q>` |
| Command mode | `:` |
| Clear search highlight | `<leader>nh` |

## Operators, Motions, Text Objects

Vim edits are usually `operator + motion`.

```text
dw     delete word
ciw    change inner word
yi"    yank inside quotes
dap    delete around paragraph
=ap    reindent around paragraph
gqap   format paragraph
```

Use this pattern before reaching for multicursor. It is faster once learned.

## Buffers, Windows, Tabs

```text
buffer = loaded file
window = view into a buffer
tab    = layout of windows
tmux   = terminal workspace outside Neovim
```

Config keys:

| Action | Key |
| --- | --- |
| Next buffer | `<Tab>` |
| Previous buffer | `<S-Tab>` |
| Close buffer | `<leader>bx` |
| New empty buffer | `<leader>bo` |
| Vertical split | `<leader>sv` |
| Horizontal split | `<leader>sh` |
| Equalize splits | `<leader>se` |
| Close split | `<leader>sx` |
| Toggle split zoom | `<leader>sm` |
| Move split left/down/up/right | `<C-h>`, `<C-j>`, `<C-k>`, `<C-l>` |
| New tab | `<leader>to` |
| Close tab | `<leader>tx` |
| Next/previous tab | `<leader>tn`, `<leader>tp` |

## Registers

Registers are named clipboards.

| Register | Meaning |
| --- | --- |
| `"` | default register |
| `0` | last yank |
| `+` | system clipboard |
| `_` | black-hole register |
| `a-z` | named registers |

Examples:

```text
"+y    yank to system clipboard
"_d    delete without replacing default register
"ap    paste from register a
```

This config maps visual `p` to paste without overwriting the last yank.

## Macros

Macros are repeatable recordings.

```text
qa     start recording into register a
...    do edits
q      stop recording
@a     replay macro a
@@     replay last macro
```

Use macros for repeated structural edits before using multicursor across many lines.

## Quickfix And Location Lists

Quickfix is the terminal-native Problems/Search Results panel.

| Action | Command |
| --- | --- |
| Open diagnostics list | `<leader>q` |
| Previous diagnostic | `[d` |
| Next diagnostic | `]d` |
| Floating diagnostic | `<leader>d` or `df` |

Typical loop:

```text
grep or diagnostics
  -> quickfix/location list
  -> jump
  -> edit
  -> repeat
```

## Daily Practice

1. Open files with Snacks or Oil.
2. Move with `hjkl`, words, search, Flash, and LSP.
3. Edit with text objects and operators.
4. Use quickfix for diagnostics and search results.
5. Use tmux for project processes.
