# 05. Debugging, Tests, Tasks, And Git

This setup keeps VS Code-like workflows while using terminal-native tools.

## Debugging With nvim-dap

| Action | Key |
| --- | --- |
| Start/continue | `F5` |
| Step over | `F10` |
| Step into | `F11` |
| Step out | `F12` |
| Toggle breakpoint | `F9` |
| Conditional breakpoint | leader debug key from DAP config |
| Toggle DAP UI | DAP UI key from config |

The DAP config supports:

```text
Python: debugpy
Go: delve through nvim-dap-go
Rust/C/C++: codelldb/lldb
JavaScript/TypeScript: js-debug-adapter where installed
C#: netcoredbg when .NET tooling is installed
```

Project-specific debug config can live in `.vscode/launch.json` or project Lua hooks where supported.

## Tests With neotest

| Action | Key |
| --- | --- |
| Run nearest test | `<leader>tN` |
| Run file tests | `<leader>tF` |
| Open test output | `<leader>tO` |
| Toggle test summary | `<leader>tS` |

Adapters enabled:

```text
Python
Plenary/Lua
Vitest
Rust
```

Use project-native commands when a framework is not covered by a neotest adapter.

## Tasks With Overseer

| Action | Key |
| --- | --- |
| Run task | `<leader>tr` |
| Toggle task panel | `<leader>tt` |
| Task action | `<leader>ta` |

Use Overseer for repeatable project tasks:

```text
build
test
dev server
lint
format
deploy dry run
```

Use tmux panes for long-running processes that should survive editor restarts.

## Git

| Action | Key |
| --- | --- |
| LazyGit through Snacks | `<leader>lg` |
| LazyGit log | `<leader>gl` |
| Fugitive fullscreen | `<leader>gg` |
| Git push inside Fugitive | `<leader>gP` |
| Git pull rebase inside Fugitive | `<leader>gpr` |
| Git push upstream prompt | `<leader>gup` |
| Next hunk | `]h` |
| Previous hunk | `[h` |
| Stage hunk | `<leader>gs` |
| Reset hunk | `<leader>gr` |
| Stage buffer | `<leader>gS` |
| Reset buffer | `<leader>gR` |
| Preview hunk | `<leader>gp` |
| Blame line | `<leader>gbl` |
| Toggle line blame | `<leader>gB` |
| Diff current file | `<leader>gd` |
| Diff against previous | `<leader>gD` |

## Diffview

| Action | Key |
| --- | --- |
| Open diff view | `<leader>gdo` |
| Close diff view | `<leader>gdc` |
| Current file history | `<leader>gdh` |
| Repo history | `<leader>gdH` |

Use Diffview for code review, branch comparisons, and file history.

## Recommended Validation Loop

```text
edit
  -> format/lint
  -> test nearest or file
  -> run task if needed
  -> inspect Git hunks
  -> commit with Fugitive/LazyGit
```
