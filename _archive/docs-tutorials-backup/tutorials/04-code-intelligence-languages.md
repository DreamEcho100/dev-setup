# 04. Code Intelligence And Languages

The language stack has four layers.

```text
Treesitter -> syntax and structural parsing
LSP        -> diagnostics, completion, go-to, rename, code actions
Conform    -> formatting
nvim-lint  -> external lint diagnostics
```

## Completion

`blink.cmp` is the completion engine.

Useful behavior:

| Action | Key |
| --- | --- |
| Accept selected completion | `<Tab>` through super-tab behavior |
| Navigate completion menu | standard completion keys from Blink preset |
| Snippet expansion | LuaSnip through Blink |

Completion sources include LSP, snippets, path, and buffer text.

## LSP Keys

| Action | Key |
| --- | --- |
| Definition | `gd` |
| Declaration | `gD` |
| References | `gR` |
| Implementation | `gi` |
| Type definition | `gt` |
| Code action | `<leader>ca` |
| Rename | `<leader>rn` |
| Hover | `K` |
| Signature help | `<leader>ls` |
| Buffer diagnostics picker | `<leader>D` |
| Toggle virtual text | `<leader>lv` |
| Toggle diagnostics visibility | `<leader>lx` |

LSP location pickers use Snacks with native LSP fallbacks.

## Formatting

| Action | Key |
| --- | --- |
| Format current buffer/range | `<leader>mp` |
| Save with normal autocmds | `<C-s>` |
| Save without auto-formatting | `<leader>sn` |

Formatter policy:

| Language | Primary |
| --- | --- |
| JS/TS/Web | `biome-check`, then `prettierd`, then `prettier` |
| Python | `ruff_format`, `ruff_organize_imports`, fallback `isort`/`black` |
| Go | `goimports`, `gofmt` |
| Rust | `rustfmt` |
| C/C++ | `clang_format` |
| Lua | `stylua` |
| Shell | `shfmt` |
| Java | `google-java-format` when Java is installed |
| LaTeX | `latexindent` when installed |
| Zig | `zigfmt` |

## Linting

| Action | Key |
| --- | --- |
| Run lint now | `<leader>ll` |

Linting is filetype-based through `nvim-lint`. LSP diagnostics remain active separately.

## Mason

Mason installs editor-facing tools:

```text
LSP servers
formatters
linters
debug adapters
```

Use:

```vim
:Mason
:MasonToolsInstall
:Lazy
```

System package managers still install compilers, runtimes, Docker, LaTeX, and other binaries Mason should not own.

## Language Notes

| Area | Setup |
| --- | --- |
| Web | `vtsls`, ESLint, Biome, Tailwind, HTML/CSS, GraphQL, Prisma, Astro, Svelte, Vue, Angular |
| Python | Pyright plus Ruff; Black/isort fallback |
| Go | `gopls`, `goimports`, Delve, dap-go |
| Rust | `rustaceanvim`, `crates.nvim`, rustfmt, codelldb |
| C/C++ | clangd, clang-format, clang-tidy, LLDB |
| C# | Roslyn plugin and netcoredbg support; .NET SDK is opt-in |
| Java | `nvim-jdtls` workflow; JDK is opt-in |
| Lua | lua_ls plus Stylua/Luacheck |
| LaTeX | VimTeX, texlab, latexmk, TeX Live |
| Markdown | render-markdown plus Mermaid/image tooling |
| Zig/Odin/GDScript | LSP enabled where available; external tool availability varies |

## Java Opt-In

Java is not default-installed.

```sh
ansible-playbook neovim.yml -K -e install_java=true
dev-env/runs/neovim --with-java
```

After installing, use Mason for `jdtls`, `java-debug-adapter`, and `java-test`.

## .NET Opt-In

.NET is not default-installed.

```sh
ansible-playbook neovim.yml -K -e install_dotnet=true
dev-env/runs/neovim --with-dotnet
```

After installing, use Roslyn LSP support and `netcoredbg` for debugging.
