# Go Development In This Neovim Config

> Goal: use Go comfortably without learning every Neovim power feature at once.

This config uses a balanced Go setup:

- `gopls` is the primary source of editor intelligence.
- `goimports` and `gofumpt` format Go files on save.
- `golangci-lint` is secondary linting, run on save and manually.
- `neotest-golang` gives a test UI.
- `nvim-dap-go` gives Go debugging through Delve.
- `overseer.nvim` gives task-runner workflows.

The important mental model: **Go tooling works best from the right module or
workspace root.** If imports fail in Neovim but `go build` works elsewhere,
first check which `go.mod` or `go.work` the tool sees.

---

## 1. The Minimum You Need First

For Go as a beginner, learn this order:

1. `go mod init` creates a module.
2. `go test ./...` checks every package.
3. `gopls` powers definitions, diagnostics, code actions, rename, and imports.
4. Format on save keeps code idiomatic.
5. `golangci-lint` catches extra issues after the basics are stable.

You do **not** need to understand every plugin before writing Go. If these work,
you have enough:

```sh
go version
gopls version
go test ./...
golangci-lint version
dlv version
```

VS Code comparison:

| VS Code feature | Neovim equivalent                         |
| --------------- | ----------------------------------------- |
| Go extension    | `gopls` through `nvim-lspconfig`          |
| Problems panel  | diagnostics, `<leader>D`, Trouble         |
| Format on save  | Conform running `goimports` and `gofumpt` |
| Test explorer   | `neotest-golang`                          |
| Debug panel     | `nvim-dap` plus `nvim-dap-go`             |
| Tasks           | `overseer.nvim`                           |

---

## 2. Modules, Packages, And Workspaces

A Go project usually has a `go.mod` file:

```sh
go mod init github.com/you/project
```

That file defines the module root. A package is normally a directory inside the
module.

For sibling local modules, use a `go.work` file at the shared parent:

```sh
go work init ./hellogo ./mystrings
go env GOWORK
```

Example layout:

```text
bootdotdev-learn-go/
|-- go.work
|-- hellogo/
|   |-- go.mod
|   `-- main.go
`-- mystrings/
    |-- go.mod
    `-- reverse.go
```

If `hellogo` imports `github.com/DreamEcho100/mystrings`, the workspace lets
`gopls`, `go test`, and `golangci-lint` understand both modules when you open
the parent directory.

Useful checks:

```sh
go env GOMOD
go env GOWORK
go list ./...
go test ./...
```

---

## 3. LSP Workflow

The language server is `gopls`. It provides the features you used from the VS
Code Go extension.

Common keys:

| Action                  | Key          |
| ----------------------- | ------------ |
| Go to definition        | `gd`         |
| Go to declaration       | `gD`         |
| Go to implementation    | `gi`         |
| Go to type definition   | `gt`         |
| Code action / quick fix | `<leader>ca` |
| Rename symbol           | `<leader>rn` |
| Hover docs              | `K`          |
| Signature help          | `<leader>ls` |
| Toggle inlay hints      | `<leader>li` |
| Buffer diagnostics      | `<leader>D`  |
| Current line diagnostic | `<leader>df` |

Useful Go code actions:

- Add missing imports.
- Remove unused imports.
- Fill struct fields.
- Stub interface methods.
- Rename safely across files.

If `gopls` looks confused, check:

```vim
:LspInfo
:De100Doctor
:checkhealth vim.lsp
```

Then check the shell:

```sh
go env GOMOD
go env GOWORK
gopls check ./path/to/file.go
```

---

## 4. Formatting And Imports

Go formatting is intentionally strict. This config formats Go through:

- `goimports`: formats code and fixes imports.
- `gofumpt`: stricter `gofmt`-compatible formatting.

You normally just save:

```vim
:w
```

Manual format:

```text
<leader>mp
```

Go uses real tabs for indentation. The Go ftplugin sets:

```lua
expandtab = false
tabstop = 4
shiftwidth = 4
```

Do not fight this. Let `gofmt`/`goimports` win.

---

## 5. Linting

Use `gopls` diagnostics first. They are fast and enough while learning.

`golangci-lint` is extra checking. In this config it runs:

- after saving a `.go` file
- when you press `<leader>ll`

It does not run on every buffer switch or every Insert-mode exit for Go, because
that is noisy and expensive.

Manual lint:

```text
<leader>ll
```

Shell equivalent:

```sh
golangci-lint run ./...
```

If linting reports import errors but build works:

1. Check `go env GOWORK`.
2. Open Neovim inside the module or workspace parent.
3. Run `go list ./...`.
4. Run `golangci-lint run ./...` from the same directory.

---

## 6. Tests

Shell first:

```sh
go test ./...
go test ./hellogo
go test -run TestName ./...
```

Neovim test UI:

| Action              | Key          |
| ------------------- | ------------ |
| Run nearest test    | `<leader>tN` |
| Run file tests      | `<leader>tF` |
| Open test output    | `<leader>tO` |
| Toggle test summary | `<leader>tS` |

The adapter is `neotest-golang`, using `gotestsum` when installed. It supports
table tests, nested tests, monorepos, inline diagnostics, and DAP integration.

Typical workflow:

1. Put cursor inside `func TestSomething(t *testing.T)`.
2. Press `<leader>tN`.
3. If it fails, press `<leader>tO`.
4. Fix the code.
5. Press `<leader>tN` again.

---

## 7. Debugging

The debugger is Delve through `nvim-dap-go`.

| Action                | Key             |
| --------------------- | --------------- |
| Start/continue        | `F5`            |
| Stop                  | `Shift+F5`      |
| Step over             | `F10`           |
| Step into             | `F11`           |
| Step out              | `Shift+F11`     |
| Toggle breakpoint     | `F9` or `<leader>daptb` |
| Debug nearest Go test | `<leader>dapt`  |
| Rerun last session    | `<leader>dapl`  |
| Toggle debug UI       | `F7` or `<leader>dapu` |
| Inspect DAP setup     | `<leader>daph`  |

Beginner debugging flow:

1. Open a Go test file.
2. Put cursor inside a test.
3. Press `<leader>daptb` on a line you want to stop at.
4. Press `<leader>dapt`.
5. Use `F10` to step over and `F5` to continue.

Shell equivalent:

```sh
dlv test ./...
```

---

## 8. Tasks

Overseer gives VS Code-like tasks.

Open task picker:

```text
<leader>tr
```

Task UI:

```text
<leader>tt
```

Configured Go tasks:

- `Go: test all packages`
- `Go: test current package`
- `Go: build current module`
- `Go: mod tidy`
- `Go: golangci-lint current module`

Use tasks when you want repeatable project commands without leaving Neovim.

---

## 9. Troubleshooting

### Import says "no required module provides package"

Check:

```sh
go env GOMOD
go env GOWORK
go list ./...
```

If you have sibling modules, create or update `go.work`:

```sh
go work init ./module-a ./module-b
go work use ./another-module
```

### `gopls` is attached to the wrong root

Run:

```vim
:LspInfo
:De100Doctor
```

Expected root priority:

1. nearest `go.work`
2. nearest `go.mod`
3. nearest `.git`

If the root is wrong, restart Neovim after creating `go.work`.

### `golangci-lint` is noisy or slow

Use `gopls` diagnostics while learning. Run `golangci-lint` manually with
`<leader>ll` or from a task when you need deeper checks.

### Tests are not discovered

Check:

```vim
:TSInstall go
:TSUpdate go
:checkhealth nvim-treesitter
```

Then check:

```sh
gotestsum --version
go test ./...
```

### Formatting changed tabs/spaces

That is normal. Go uses tabs for indentation. Trust `goimports` and `gofumpt`.

---

## 10. What To Learn Next

Do this in order:

1. Write small functions and run `go test ./...`.
2. Use `gd`, `K`, `<leader>ca`, and `<leader>rn` daily.
3. Trust format on save.
4. Use `<leader>ll` only when you want stronger linting.
5. Add tests and run them with `<leader>tN`.
6. Debug tests with `<leader>dapt` when prints are not enough.
7. Move repeatable commands to Overseer tasks.

You become effective in Go by understanding packages, modules, tests, errors,
and interfaces. Neovim should support that learning, not bury it under custom
editor code.
