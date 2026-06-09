# 02. VS Code Transition And Binding Equivalents

This file maps common VS Code actions to this Neovim config.

## High-Value Equivalents

| VS Code Action | VS Code Default | Neovim Equivalent |
| --- | --- | --- |
| Save | `Ctrl+S` | `<C-s>` |
| Command Palette | `Ctrl+Shift+P` | `<leader>pc` |
| Quick Open file | `Ctrl+P` | `<leader>pf` |
| Recent files | `Ctrl+R` varies | `<leader>pr` |
| Open buffers/editors | `Ctrl+P` then list | `<leader>pb` |
| Search in files | `Ctrl+Shift+F` | `<leader>pg` |
| Search and replace in files | `Ctrl+Shift+H` | `<leader>ps` |
| Explorer | `Ctrl+Shift+E` | `-`, `<leader>-`, `<leader>ee`, `<leader>pe` |
| Go to definition | `F12` | `gd` |
| Go to declaration | no universal default | `gD` |
| Find references | `Shift+F12` | `gR` |
| Go to implementation | `Ctrl+F12` | `gi` |
| Type definition | no universal default | `gt` |
| Rename symbol | `F2` | `<leader>rn` |
| Code action | `Ctrl+.` | `<leader>ca` |
| Hover docs | mouse hover | `K` |
| Signature help | `Ctrl+Shift+Space` | `<leader>ls` |
| Problems panel | `Ctrl+Shift+M` | Trouble, `<leader>D`, `<leader>q` |
| Toggle terminal/sessionizer | terminal panel | `<C-f>` tmux sessionizer |
| Run task | `Tasks: Run Task` | `<leader>tr` |
| Toggle tasks | task output panel | `<leader>tt` |
| Debug start/continue | `F5` | `F5` |
| Debug step over | `F10` | `F10` |
| Debug step into | `F11` | `F11` |
| Debug step out | `Shift+F11` | `F12` in this config |
| Toggle breakpoint | `F9` | `F9` |
| Git source control | `Ctrl+Shift+G` | `<leader>lg`, `<leader>gg`, Gitsigns keys |
| Diff view | click changed file | `<leader>gdo` |
| File history | Timeline | `<leader>gdh` |
| Multi-cursor next match | `Ctrl+D` | `<leader>mc` |
| Multi-cursor all matches | `Ctrl+Shift+L` | `<leader>mC` |

## Leader Namespaces

Press `<leader>` and wait for which-key.

| Namespace | Meaning |
| --- | --- |
| `<leader>b` | buffers |
| `<leader>c` | code actions/comments |
| `<leader>d` | diagnostics/debug |
| `<leader>e` | explorer |
| `<leader>f` | file utilities |
| `<leader>g` | Git |
| `<leader>h` | Harpoon |
| `<leader>l` | LSP/lint |
| `<leader>m` | make/format/multicursor |
| `<leader>p` | pick/search |
| `<leader>r` | rename/refactor |
| `<leader>s` | splits/session |
| `<leader>t` | tabs/tests/tasks |
| `<leader>w` | workspace/session |
| `<leader>x` | Trouble/lists |

## VS Code Habits To Keep

- Save constantly with `<C-s>`.
- Use a command palette/picker for discovery.
- Run tasks and tests through a consistent UI.
- Use the debugger when it gives faster feedback than logs.
- Keep remote and terminal workflows first-class.

## VS Code Habits To Replace

| Old Habit | Replacement |
| --- | --- |
| Mouse selecting everywhere | motions, text objects, visual mode |
| Many editor tabs | buffers plus Harpoon |
| Search panel as one-off UI | ripgrep/Snacks/quickfix workflow |
| Extension UI for everything | CLI tools plus small focused plugins |
| Manual repeated edits | macros, substitutions, text objects, multicursor when appropriate |

## First Week Routine

1. Use `<leader>pf`, `<leader>pg`, `gd`, `gR`, and `<C-s>` for normal work.
2. Use Oil with `-` for file operations.
3. Use `<leader>pc` and `<leader>pk` when you forget commands.
4. Use `<leader>mc` only when multicursor is clearly the fastest path.
5. Practice one text-object edit per day until it becomes automatic.
