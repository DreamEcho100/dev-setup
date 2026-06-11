# 03. Project Navigation And Search

This config uses Snacks as the primary picker layer.

## Picker Flow

```text
Need something?
  |
  +-- file or buffer     -> Snacks picker
  +-- filesystem edit    -> Oil or mini.files
  +-- repeated location  -> Harpoon
  +-- nearby code jump   -> Flash
  +-- project replace    -> grug-far
  +-- search results     -> quickfix/location list
```

## Snacks Picker

| Action | Key |
| --- | --- |
| Find files | `<leader>pf` |
| Smart picker | `<leader>pF` |
| Buffers | `<leader>pb` |
| Recent files | `<leader>pr` |
| Grep project | `<leader>pg` |
| Commands | `<leader>pc` |
| Explorer picker | `<leader>pe` |
| Grep word or selection | `<leader>pws` |
| Search keymaps | `<leader>pk` |
| Help pages | `<leader>vh` |
| Color schemes | `<leader>th` |
| Git branches | `<leader>gbr` |

Telescope is intentionally not a normal user-facing picker. It remains installed for plugin compatibility and direct `:Telescope` use when needed.

## Oil

Oil edits directories like buffers.

| Action | Key |
| --- | --- |
| Open parent/current directory | `-` |
| Floating Oil | `<leader>-` |

Typical workflow:

```text
-
move to file
rename/delete/create like editing text
:w
```

Use Oil for real filesystem operations. Use Snacks for finding.

## mini.files

`mini.files` is the lightweight side explorer.

| Action | Key |
| --- | --- |
| Open mini.files | `<leader>ee` |
| Open at current file | `<leader>ef` |

Use it when you want a compact tree-like view without leaving the current editing context.

## Harpoon

Harpoon is for a tiny set of files you bounce between constantly.

| Action | Key |
| --- | --- |
| Add current file | `<leader>ha` |
| Open Harpoon menu | `<leader>hh` |
| Jump file 1-4 | `<leader>h1` to `<leader>h4` |
| Previous Harpoon file | `<leader>hp` |
| Next Harpoon file | `<leader>hn` |

Use Harpoon for the "main files" in a task, not every file in the project.

## Flash

Flash is fast on-screen navigation.

| Action | Key |
| --- | --- |
| Flash jump | `s` |
| Treesitter selection | `S` |
| Remote Flash operator | `r` in operator-pending mode |
| Treesitter search | `R` in operator/visual mode |

Use Flash when the target is visible. Use Snacks when the target is not visible.

## grug-far

`grug-far.nvim` is the VS Code-like project search/replace workflow.

| Action | Key |
| --- | --- |
| Search/replace | `<leader>ps` |
| Search current word | `<leader>pS` |

Use it for controlled replacements where previewing changed files matters.

## Trouble And Lists

Trouble is a focused UI for diagnostics, references, quickfix, and symbols.

Use quickfix/location lists when you want plain Vim-native navigation. Use Trouble when you want a structured panel.

## Recommended Pattern

1. Find file with `<leader>pf`.
2. Jump in file with `s` or `/`.
3. Jump semantically with `gd`, `gR`, `gi`, or `gt`.
4. Save core files to Harpoon.
5. Use grug-far for bulk edits.
