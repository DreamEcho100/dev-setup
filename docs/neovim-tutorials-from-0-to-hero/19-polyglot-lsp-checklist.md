# 19 · Polyglot LSP, Completion, and Diagnostics Checklist

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Goal: know what should work for each language, and how to prove which      │
│  layer is broken when completion, diagnostics, formatting, or linting feels │
│  wrong.                                                                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

This config is intentionally split into small tools:

```
filetype
  │
  ├─ LSP server        → definitions, hover, rename, code actions, diagnostics
  ├─ blink.cmp V2      → completion UI for LSP, snippets, paths, buffer words
  ├─ conform.nvim      → formatting on save and <leader>mp
  ├─ nvim-lint        → extra lint diagnostics on save/manual <leader>ll
  ├─ Treesitter        → highlighting, folding, text objects
  └─ DAP / neotest     → debugging and test workflows where configured
```

When something feels broken, do not start by editing config. First identify the broken layer.

## 1. First Checks

Run these inside Neovim:

```vim
:echo stdpath("config")
:echo stdpath("data")
:echo stdpath("state")
:echo stdpath("cache")
```

Expected paths:

```text
~/.config/nvim
~/.local/share/nvim
~/.local/state/nvim
~/.cache/nvim
```

If any path contains `snap/code`, the VS Code Snap terminal leaked sandboxed XDG variables.
Open a normal terminal or reload the shell after the `.zshenv`/`.profile` XDG fixes.

Then check the editor layers:

```vim
:Lazy
:Mason
:checkhealth vim.lsp
:checkhealth blink.cmp
:checkhealth mason
:ConformInfo
:LspInfo
:De100Doctor
```

Useful keys:

| Need | Key |
| --- | --- |
| Force completion menu / docs | `<C-Space>` |
| Terminal Ctrl-Space fallback | `<C-@>` |
| Accept selected completion | `<C-y>` |
| Hide completion menu | `<C-e>` |
| Hover docs | `K` |
| Signature help | `<C-k>` or `<leader>ls` |
| Current-line diagnostic details | `<leader>df` |
| Current-buffer diagnostics picker | `<leader>D` |
| Workspace diagnostics | `<leader>xw` |
| Document diagnostics | `<leader>xd` |
| Format file/range | `<leader>mp` |
| Run current-file linter | `<leader>ll` |

## 2. Completion UX Baseline

The intended Blink V2 behavior is calm and explicit:

| Behavior | Current setting |
| --- | --- |
| Engine | `blink.cmp` on main/V2 with `blink.lib` |
| Accept key | `<C-y>`, not Enter |
| First item | not preselected, not auto-inserted |
| Documentation | manual by default; toggle from completion with `<C-Space>` |
| Signature help | manual by default |
| Insert-mode ghost text | off |
| Cmdline ghost text | on |
| Prefetch | off because installed V2 marks it buggy/not recommended |
| Snippets | LuaSnip preset with explicit `;` triggers |

If completion is noisy, first press `<C-e>` and keep typing. If completion is missing:

```vim
:set ft?
:LspInfo
:Mason
:checkhealth blink.cmp
```

If snippets do not appear, type the exact `;` trigger from `snippets/<filetype>.lua`, for
example `;fn`, `;test`, or `;useState`.

## 3. Diagnostics UX Baseline

Inline diagnostics are deliberately quieter than VS Code's default Problems panel:

| Surface | Purpose |
| --- | --- |
| Sign column | always-visible severity marker |
| Inline virtual text | warning/error text only |
| Underline | marks the exact span |
| `<leader>df` | full message on demand |
| `<leader>D` | buffer-wide searchable review |
| `<leader>xw` | project/workspace review |
| `<leader>xd` | current-file Trouble panel |
| lualine | compact counts |

This keeps normal editing readable while still making diagnostics easy to inspect.

## 4. Language Matrix

### Web: JavaScript, TypeScript, React, Vue, Svelte, Astro, Angular

| Layer | Expected tool |
| --- | --- |
| LSP | `vtsls`, `eslint`, `biome`, `tailwindcss`, plus framework server |
| Framework servers | `astro`, `svelte`, `vue_ls`, `angularls` |
| Format | `biome-check`, then `prettierd`, then `prettier` |
| Lint | `biomejs` and `eslint_d` through `nvim-lint` |
| Snippets | `;fn`, `;inter`, `;comp`, `;useState`, JSX snippets |

Check:

```vim
:set ft?
:LspInfo
:ConformInfo
:Mason
```

Common issues:

| Symptom | Likely cause |
| --- | --- |
| No TS completions | missing `package.json`, wrong filetype, or `vtsls` not installed |
| Tailwind classes do not complete | filetype not in Tailwind config or no Tailwind config in project |
| Duplicate diagnostics | both Biome and ESLint are active; project config decides whether that is wanted |
| React snippets missing | filetype is `typescript`, not `typescriptreact` |

### Python

| Layer | Expected tool |
| --- | --- |
| LSP | `pyright` for type intelligence, `ruff` for lint/code actions |
| Format | `ruff_format` + `ruff_organize_imports`, fallback `isort` + `black` |
| Lint | `ruff`, `pylint` |
| Debug | `debugpy` |
| Tests | `neotest-python` when available |
| Snippets | `;fn`, `;afn`, `;dc`, `;try`, `;test` |

Check:

```vim
:LspInfo
:ConformInfo
:!python -m pyright --version
:!ruff --version
```

Common issues:

| Symptom | Likely cause |
| --- | --- |
| Imports unresolved | wrong virtualenv or project opened outside its root |
| Ruff and Pylint disagree | normal; prefer Ruff while learning, keep Pylint for deeper review |
| Format does nothing | `ruff` missing, or buffer has no Python filetype |

### Go

| Layer | Expected tool |
| --- | --- |
| LSP | `gopls` |
| Format | `goimports`, then `gofumpt` |
| Lint | `golangci-lint`, module/workspace-aware |
| Debug | `delve` through `nvim-dap-go` |
| Tests | `neotest-golang` / Go test tasks |
| Snippets | `;fn`, `;ife`, `;test`, `;struct`, `;handler` |

Check:

```vim
:LspInfo
:ConformInfo
:!go env GOWORK
:!go test ./...
:!golangci-lint run ./...
```

Common issues:

| Symptom | Likely cause |
| --- | --- |
| Sibling local import unresolved | missing root `go.work`, or editor opened above/below expected workspace |
| Lint slower than typing | expected; Go linting is save/manual-first, not every keystroke |
| Duplicate diagnostics | `gopls` catches basics; `golangci-lint` catches deeper rules |

### Lua

| Layer | Expected tool |
| --- | --- |
| LSP | `lua_ls` |
| Format | `stylua` |
| Lint | `luacheck` |
| Debug | local Lua debugger adapter installed |
| Snippets | `;fn`, `;req`, `;map`, `;au`, `;pcall` |

Check:

```vim
:LspInfo
:ConformInfo
:checkhealth vim.lsp
:lua print(vim.inspect(vim.lsp.get_clients({ bufnr = 0 })))
```

For Neovim config files, `lua_ls` should know about `vim` and the config's Lua directory.

### Rust

| Layer | Expected tool |
| --- | --- |
| LSP owner | `rustaceanvim` |
| LSP process | `rust-analyzer` from the Rust toolchain |
| Crates | `crates.nvim` in `Cargo.toml` |
| Format | `rustfmt`, with LSP fallback |
| Debug | `codelldb` |
| Snippets | `;fn`, `;struct`, `;impl`, `;match`, `;test` |

Check:

```vim
:LspInfo
:RustLsp reloadWorkspace
:!rustup component list --installed
:!cargo check
```

Do not add `rust_analyzer` to the central `vim.lsp.enable` list unless you intentionally stop
using `rustaceanvim`. Two Rust owners can create confusing duplicate behavior.

### C and C++

| Layer | Expected tool |
| --- | --- |
| LSP | `clangd` with background index and clang-tidy |
| Extras | `clangd_extensions.nvim` |
| Format | `clang-format` |
| Lint | `clang-tidy`, `cpplint` |
| Build | `cmake-tools.nvim`, Overseer tasks |
| Debug | `codelldb` |
| Snippets | C `;main`, `;fn`; C++ `;class`, `;rule5`, `;gtest` |

Check:

```vim
:LspInfo
:ConformInfo
:!ls compile_commands.json
:!clangd --version
```

If go-to-definition is weak, generate `compile_commands.json` first.

### C# / .NET

| Layer | Expected tool |
| --- | --- |
| LSP owner | `roslyn.nvim` |
| LSP process | Roslyn language server |
| Format | LSP fallback |
| Debug | `netcoredbg` |
| Prerequisite | `install_dotnet=true` or manual .NET SDK + Roslyn LS install |

Check:

```vim
:LspInfo
:!dotnet --info
:!which roslyn-language-server
```

This config does not enable OmniSharp as the default C# LSP. Roslyn is the intended modern
path, but it requires Neovim 0.12+ and the Roslyn server executable.

### Java

| Layer | Expected tool |
| --- | --- |
| LSP | `jdtls` |
| Extras | `nvim-jdtls` commands attach when the `jdtls` client is active |
| Format | `google-java-format` |
| Debug/test adapters | `java-debug-adapter`, `java-test` |
| Prerequisite | `install_java=true` or manual JDK install |

Check:

```vim
:LspInfo
:!java -version
:!jdtls --version
```

For serious Java debug/test workflows, validate a real Maven/Gradle project. Java is more
project-shape-sensitive than Go or Python.

### Zig, Odin, GDScript

| Language | LSP | Format | Notes |
| --- | --- | --- | --- |
| Zig | `zls` | `zigfmt` | Requires a working Zig install |
| Odin | `ols` | external/manual | Tooling is younger than Go/Rust/C++ |
| GDScript | `gdscript` | LSP fallback | Usually depends on Godot editor/LSP connection |

Check:

```vim
:LspInfo
:ConformInfo
```

These ecosystems are less standardized; expect more project-specific setup.

### LaTeX, Markdown, Docs

| Layer | Expected tool |
| --- | --- |
| LaTeX LSP | `texlab` |
| LaTeX plugin | VimTeX |
| LaTeX build | `latexmk`, TeX Live packages |
| Markdown LSP | `marksman` |
| Markdown format | Prettier path |
| Markdown lint | `markdownlint`, `codespell` |
| Diagrams | Mermaid CLI, Graphviz |

Check:

```vim
:LspInfo
:VimtexInfo
:ConformInfo
:!latexmk --version
:!mmdc --version
```

### SQL

| Layer | Expected tool |
| --- | --- |
| LSP | `sqlls` |
| Database UI | `vim-dadbod-ui` |
| Completion | Dadbod completion source for SQL buffers |

Check:

```vim
:set ft?
:LspInfo
:DBUI
```

### YAML, JSON, TOML, Docker, Terraform, Ansible

| Filetype | LSP | Format | Lint |
| --- | --- | --- | --- |
| YAML | `yamlls` | `yamlfmt` or Prettier path | `yamllint` |
| JSON/JSONC | `jsonls` | Prettier path | LSP diagnostics |
| TOML | `taplo` | `taplo` | `taplo` |
| Docker | `dockerls`, compose LS | external/LSP | LSP diagnostics |
| Terraform | `terraformls` | external/manual | LSP diagnostics |
| Ansible | `ansiblels` | YAML formatting | `ansible-lint` |

Check:

```vim
:set ft?
:LspInfo
:ConformInfo
:!ansible-lint --version
```

## 5. Fast Debugging Flow

Use this order when a language feels broken:

1. `:set ft?` - confirm Neovim detected the language.
2. `:LspInfo` - confirm the expected LSP attached.
3. `:Mason` - confirm the tool is installed.
4. `:ConformInfo` - confirm the formatter exists for this buffer.
5. `<leader>df` - read the exact diagnostic source and message.
6. `<leader>D` or `<leader>xd` - inspect all diagnostics in the file.
7. Run the same tool in the shell, for example `go test ./...`, `ruff check .`,
   `npm run typecheck`, `cargo check`, or `clangd --version`.

If the command-line tool fails, Neovim is not the problem yet. Fix the project/tool first.

## 6. When to Change Config

Only edit the Neovim config after you can answer these questions:

| Question | Example answer |
| --- | --- |
| Which filetype? | `typescriptreact` |
| Which layer? | LSP completion, not formatter |
| Which server/client? | `vtsls` attached, `eslint` not attached |
| Does the CLI tool work? | `npm run typecheck` fails too |
| Is this one project or all projects? | only this monorepo |

That discipline prevents random config churn. Most "Neovim broke" problems are actually one
of these: wrong filetype, missing external tool, wrong project root, bad virtualenv, missing
`go.work`, missing `compile_commands.json`, or VS Code Snap leaking XDG paths.
