# 07 · LSP and Completions

> This is chapter 7 of the Neovim 0-to-Hero series. This chapter covers the Language Server
> Protocol stack, completions with blink.cmp, the ; snippet system, the aerial symbols outline,
> and the kulala.nvim HTTP client. By the end, Neovim will feel like a full-featured IDE.

---

## Table of Contents

1. [The Language Intelligence Stack](#1-the-language-intelligence-stack)
2. [Mason — Your Language Server Manager](#2-mason--your-language-server-manager)
3. [LSP Navigation — The Core Commands](#3-lsp-navigation--the-core-commands)
4. [Diagnostics — Your Error and Warning System](#4-diagnostics--your-error-and-warning-system)
5. [Code Actions — The Smart Fix Menu](#5-code-actions--the-smart-fix-menu)
6. [Rename — LSP-Aware Refactoring](#6-rename--lsp-aware-refactoring)
7. [blink.cmp — Your Completion Engine](#7-blinkcmp--your-completion-engine)
8. [The ; Snippet System](#8-the--snippet-system)
9. [Aerial — Symbols Outline](#9-aerial--symbols-outline)
10. [Inlay Hints](#10-inlay-hints)
11. [kulala.nvim — REST/HTTP Client](#11-kulalanvim--resthttp-client)
12. [Complete Reference Table](#12-complete-reference-table)
13. [Exercises](#13-exercises)

---

## 1. The Language Intelligence Stack

One of the most common misconceptions about Neovim is that it is "just a text editor" — that
it lacks the intelligence of IDEs like VS Code, IntelliJ, or WebStorm. This misconception comes
from VSCode's bundled approach: install a Python extension and you immediately get completions,
error highlighting, hover docs, formatting, linting, and debugging, all from a single package.
It feels seamless because the wiring is hidden.

Neovim takes a different philosophy. It **separates the concerns** of language intelligence and
lets each component do one thing well. The result is a system that is more flexible, often
faster, and fully configurable — but it requires understanding which component does what.

Here is the complete pipeline for a file you open in this config:

```
Your Code File
      │
      ▼
┌───────────────────────┐
│      Treesitter       │  ← Syntax highlighting, smart indentation,
│                       │    structural text objects (daf = delete a function,
│                       │    vac = visually select a class, etc.),
│                       │    context-aware code folding
└───────────────────────┘
      │
      ▼
┌───────────────────────┐
│     LSP Server        │  ← Deep semantic analysis: type checking,
│                       │    cross-file references, symbol lookup,
│  gopls     (Go)       │    error detection, refactoring capabilities.
│  vtsls     (TS/JS)    │    Runs as a separate process and talks to
│  pyright   (Python)   │    Neovim via the Language Server Protocol
│  lua_ls    (Lua)      │    (an open standard).
│  rust_analyzer        │
│  ...many more         │
└───────────────────────┘
      │
      ├─────────────────────────────► ┌──────────────────────────┐
      │                               │       blink.cmp          │ ← Completion popup
      │                               │    (completion engine)   │   Queries LSP + snippets
      │                               └──────────────────────────┘   + path + buffer
      │
      ├─────────────────────────────► ┌──────────────────────────┐
      │                               │      conform.nvim        │ ← Format on save
      │                               │     (formatting)         │   prettier, gofmt,
      │                               └──────────────────────────┘   black, stylua...
      │
      └─────────────────────────────► ┌──────────────────────────┐
                                      │       nvim-lint          │ ← Lint diagnostics
                                      │       (linting)          │   eslint, golangci-lint,
                                      └──────────────────────────┘   ruff, selene...
```

The **LSP server** is the brain. It is a separate process — not part of Neovim — that deeply
understands your language. Neovim sends it your code, the server analyzes it, and sends back
a stream of information: error locations, completion suggestions, definition locations, symbol
references, rename targets, and much more. The Language Server Protocol is an open standard,
which is why the same `gopls` that powers Go in VSCode also powers Go in Neovim.

**Treesitter** works at the syntax level — it parses your code into an abstract syntax tree
(AST) and uses that for fast, accurate highlighting, indentation, and structural text objects.
Treesitter does not know about types or semantic correctness; that is LSP's responsibility.

**blink.cmp** is the completion engine. It listens to what you type in Insert mode, queries
all configured sources simultaneously (LSP, snippets, filesystem paths, buffer words), merges
the results, and displays them in a popup with documentation.

**conform.nvim** and **nvim-lint** run formatters and linters when you save a file. They are
largely invisible — you save, the code gets formatted and linted, diagnostics appear.

> 💡 **VSCode equivalent**
>
> In VSCode, a single extension (e.g., "Python" by Microsoft) bundles the language server
> (Pylance), formatter (Black), linter (Pylance/Pylint), and completion provider together.
> In Neovim, these are separate tools: Mason manages language server installation, conform.nvim
> runs formatters, nvim-lint runs linters, and blink.cmp drives the completion UI. More
> moving parts visible to you, but each independently configurable and replaceable.

---

## 2. Mason — Your Language Server Manager

Mason is the package manager for language servers, formatters, linters, and debug adapters.
It handles downloading, installing, updating, and removing these tools in a Neovim-managed
directory (`~/.local/share/nvim/mason/`), isolated from your system package manager.

### Opening the Mason UI

```
:Mason   → open the Mason package manager panel
```

```
╭──────────────────────────────────────────────────────────────────╮
│  Mason v1.x  ──────────────────────  [i] help  [g] refresh      │
├──────────────────────────────────────────────────────────────────┤
│  Installed (14)                                                  │
│  ──────────────────────────────────────────────────────────      │
│  ✓ gopls                      Go language server                 │
│  ✓ vtsls                      TypeScript/JavaScript LS (modern)  │
│  ✓ pyright                    Python type-checking LS            │
│  ✓ lua-language-server        Lua LS with Neovim API definitions │
│  ✓ rust-analyzer              Rust LS                            │
│  ✓ prettier                   Opinionated code formatter         │
│  ✓ eslint-lsp                 ESLint as a language server        │
│  ✓ black                      Python formatter                   │
│  ✓ stylua                     Lua formatter                      │
│  ...                                                             │
├──────────────────────────────────────────────────────────────────┤
│  Available  (hundreds more)                                      │
│  ──────────────────────────────────────────────────────────      │
│  ○ clangd                     C/C++ language server              │
│  ○ ruby-lsp                   Ruby language server               │
╰──────────────────────────────────────────────────────────────────╯
  [i] install  [X] uninstall  [u] update  [<CR>] expand details
```

### Navigating Mason

```
j / k          → move cursor up/down
i              → install the package under the cursor
X              → uninstall the package under the cursor
u              → update the selected package
U              → update ALL installed packages
<CR>           → expand package details (changelog, version, install path)
q              → close Mason
```

### Installing from the command line

```
:MasonInstall gopls                → install Go language server
:MasonInstall lua-language-server  → install Lua language server
:MasonInstall prettier             → install Prettier formatter
:MasonUpdate                       → update all installed packages
:MasonUninstall gopls              → remove a specific package
```

### Auto-installation on first launch

This config uses `mason-tool-installer.nvim` to automatically install a curated set of tools
the first time you open Neovim. You will see a progress notification as Mason downloads them.
The list is defined in `dotfiles/.config/nvim/lua/de100/plugins/lsp/mason.lua`:

**Language servers:**
`gopls`, `vtsls`, `pyright`, `lua_ls`, `rust_analyzer`, `clangd`,
`jsonls`, `yamlls`, `html`, `cssls`, `tailwindcss`, `eslint`

**Formatters:**
`prettier`, `gofmt`, `goimports`, `black`, `stylua`, `rustfmt`

**Linters:**
`golangci-lint`, `ruff`, `selene`

> 💡 **VSCode equivalent**
>
> Mason is the equivalent of VS Code's Extensions panel (Ctrl+Shift+X), but specifically for
> backend language intelligence tools. In VS Code you install "Python" and it bundles pyright
> + black + pylint automatically. In Neovim you install each tool individually through Mason,
> giving you full visibility and control over exactly what is running.

---

## 3. LSP Navigation — The Core Commands

These keymaps are **buffer-local** — they activate only when a language server is attached to
the current buffer. When you open a TypeScript file and `vtsls` connects (usually within a
second or two), all these bindings become live. Open a plain `.txt` file and they do nothing.

Verify LSP is attached and see which server is running: `:LspInfo`

### gd — Go to definition

```
gd   → jump to the DEFINITION of the symbol under the cursor
```

Press `gd` on a function name and Neovim jumps to where that function is defined. Press `gd`
on a type and you see the type definition. Press `gd` on an imported name and you jump to its
source in the module.

If there is **one** definition, Neovim jumps directly. If there are **multiple** definitions
(overloaded functions, multiple exports, barrel re-exports), the **Snacks picker** opens
showing all candidates — navigate with `j/k`, press `Enter` to jump.

```
# Cursor is on: useCallback (imported from react)
gd → jumps to React's source type definitions for useCallback

# Cursor is on: User (a type you defined)
gd → jumps to types.ts where: export type User = { id: string; ... }

# Multiple results (after fuzzy re-export in barrel index.ts):
gd → Snacks picker opens showing all matching definitions
     Press j/k to select, Enter to jump
```

> 💡 **VSCode equivalent:** F12 (Go to Definition)

### gD — Go to declaration

```
gD   → jump to the DECLARATION of the symbol under the cursor
```

The distinction between declaration and definition matters primarily in C/C++ (where functions
are declared in `.h` header files and defined in `.c`/`.cpp` files), and in TypeScript with
`declare` statements. In most dynamic languages they are the same. `gD` is there when you need it.

> 💡 **VSCode equivalent:** Right-click → "Go to Declaration" (rarely exposed as a shortcut)

### gR — Show references

```
gR   → show ALL places in the ENTIRE PROJECT where this symbol is USED
```

This is one of the most useful LSP features for understanding a codebase. Press `gR` on a
function and every call site opens in the Snacks picker. Press `gR` on a type and see every
file that uses it. The results show filename, line number, and a preview of the line.

```
# Cursor is on: validateEmail (defined in utils.ts)
gR → Snacks picker opens:
     src/auth/register.ts:34     if (!validateEmail(input.email)) {
     src/auth/login.ts:18         validateEmail(user.email)
     src/profile/update.ts:52    const ok = validateEmail(newEmail)
     tests/utils.test.ts:12      expect(validateEmail('a@b.com')).toBe(true)
     tests/utils.test.ts:13      expect(validateEmail('bad')).toBe(false)

Navigate with j/k, press Enter to jump to any result.
```

> 💡 **VSCode equivalent:** Shift+F12 (Find All References), or right-click → "Find All References"

### gi — Show implementations

```
gi   → show ALL TYPES or FUNCTIONS that implement the interface/abstract under the cursor
```

Most useful with interfaces and abstract types. Press `gi` on an interface definition and see
every concrete type that implements it. Press `gi` on an abstract method and see every class
that provides an implementation.

```
# Cursor is on: Repository (an interface)
gi → Snacks picker shows:
     src/users/UserRepo.ts:8      class UserRepo implements Repository<User>
     src/posts/PostRepo.ts:6      class PostRepo implements Repository<Post>
     src/cache/RedisRepo.ts:12    class RedisRepo implements Repository<any>
```

> 💡 **VSCode equivalent:** Ctrl+F12 (Go to Implementations), or right-click menu

### gt — Go to type definition

```
gt   → jump to the TYPE DEFINITION of the variable under the cursor
```

The difference from `gd`: `gd` shows you where something is *declared*, `gt` shows you where
its *type* is defined. They differ when you are on a variable:

```
# In app.ts:
const user = await getUser(id)  ← cursor here

gd → jumps to: const user = await getUser(id)  (the declaration of 'user' — same place)
gt → jumps to: export type User = { id: string; name: string }  (the User type definition)
```

> 💡 **VSCode equivalent:** Right-click → "Go to Type Definition"

### K — Hover documentation

```
K   → show documentation for the symbol under the cursor in a floating popup
```

Press `K` on any identifier — a function, type, variable, library export — and you get a
floating window showing:
- The type signature
- The full JSDoc/docstring/godoc comment
- Parameter descriptions and return types
- Any deprecation notices

Press `K` a second time to **focus** the floating window (now you can scroll it). Press `q`
or `<Esc>` to close. This means: `K` to open, `K` again to enter, scroll with arrow keys,
`q` to close.

```
# Cursor on: useState
K → shows:
   ╭─────────────────────────────────────────────────────────────╮
   │ (alias) function useState<S>(                               │
   │   initialState: S | (() => S)                               │
   │ ): [S, Dispatch<SetStateAction<S>>]                         │
   │                                                             │
   │ Returns a stateful value, and a function to update it.      │
   │ During the initial render, the returned state (state) is    │
   │ the same as the value passed as the first argument (initial  │
   │ State).                                                     │
   │                                                             │
   │ @param initialState — The initial state value, or a lazy    │
   │ initializer function that returns the initial state value.  │
   ╰─────────────────────────────────────────────────────────────╯
```

> 💡 **VSCode equivalent:** Hovering the mouse over a symbol. `K` is the keyboard equivalent —
> you never have to reach for the mouse to read documentation while coding.

### leader+ls — Signature help

```
<leader>ls   → show the parameter signature for the function being called
               Works in both Normal mode AND Insert mode
```

When you are inside a function call and want to check the signature without leaving insert mode:

```
# You are typing:   createUser(  ← cursor is here, inside the parens
<leader>ls → shows:
   ╭──────────────────────────────────────────────────────────────────╮
   │ createUser(name: string, email: string, role?: UserRole): User  │
   │            ──────────────                                        │
   │            ▲ Currently typing this parameter                    │
   ╰──────────────────────────────────────────────────────────────────╯
```

The current parameter is underlined/bolded. As you fill in arguments and type `,` to move to
the next parameter, the highlighting shifts.

> 💡 **VSCode equivalent:** Ctrl+Shift+Space (Trigger Parameter Hints)

---

## 4. Diagnostics — Your Error and Warning System

**Diagnostics** are structured messages from LSP servers and linters about problems in your
code. They are not just colored underlines — each diagnostic has a severity level, a message,
a source (which server generated it), and an error code.

Diagnostics appear in multiple places at once:

```
                    Sign column        Virtual text (end of line)
                    (left margin)                 │
                         │                        ▼
  42 │ E  │  const user: User = getUser(null)  ← Type 'null' is not assignable to...
  43 │ W  │  const unused = "hello"             ← 'unused' is declared but never read
  44 │    │  const name = user.name
```

The sign column shows severity icons on the left margin. Virtual text shows the message inline
after the code. Both appear simultaneously.

### Severity levels

```
E   Error   — definitely broken (type mismatch, undefined variable, syntax error)
              Red. Blocks compilation or runtime. Fix these.

W   Warning — suspicious but possibly intentional (unused var, deprecated API)
              Yellow. Will not break things but should be reviewed.

H   Hint    — a suggestion (use const instead of let, simplify this expression)
              Light blue or gray. Style and convention improvements.

I   Info    — informational context (this is async, this type came from...)
              Blue. Just for understanding.
```

### Navigating between diagnostics

```
[d   → jump to the PREVIOUS diagnostic in the current buffer
]d   → jump to the NEXT diagnostic in the current buffer
```

Use `[d`/`]d` to hop between all errors and warnings in the file. Combined with `<leader>df`
to read each one, this is the fastest way to review and address all issues in a file.

### Reading diagnostic details

```
<leader>df   → open a floating window for the diagnostic on the CURRENT LINE
```

The floating diagnostic window shows much more than the inline virtual text:

```
╭────────────────────────────────────────────────────────────────────╮
│  E  Type 'string | undefined' is not assignable to type 'string'. │
│     Type 'undefined' is not assignable to type 'string'.          │
│                                                                    │
│  Source: typescript (vtsls)                    Code: TS2322        │
╰────────────────────────────────────────────────────────────────────╯
```

For complex TypeScript errors that span multiple lines, `<leader>df` shows the complete
error message — the virtual text often truncates long messages.

```
<leader>D    → show ALL diagnostics for the current buffer in the Snacks picker
               Searchable, navigable — jump to any diagnostic directly
```

### Trouble — The diagnostics dashboard

For a persistent overview of problems, Trouble provides a dedicated bottom panel:

```
<leader>xw   → workspace diagnostics (ALL errors across ALL files in the project)
<leader>xd   → document diagnostics (all errors in the current file only)
<leader>xq   → quickfix list displayed in Trouble format
<leader>xt   → TODO/FIXME comments across the project (from todo-comments.nvim)
```

`<leader>xw` (workspace diagnostics) is particularly valuable when you open a new or legacy
codebase for the first time — you can see the full scope of issues across every file at once.

### Controlling diagnostic display

```
<leader>lv   → toggle virtual text ON/OFF
               Inline messages after each problem line. When they are very long or
               very numerous, toggle them off for a cleaner view.

<leader>lx   → toggle ALL diagnostics visibility entirely
               Hides sign column marks and virtual text. The underlying issues still
               exist — you have just hidden the indicators temporarily. Useful when
               onboarding into a messy codebase and the red marks are overwhelming.
```

> 💡 **VSCode equivalent**
>
> | Neovim key       | VSCode equivalent                                |
> |------------------|--------------------------------------------------|
> | `]d` / `[d`      | F8 / Shift+F8 (Go to Next/Prev Problem)          |
> | `<leader>df`     | Hover over the red squiggly underline            |
> | `<leader>D`      | View → Problems (Ctrl+Shift+M)                   |
> | `<leader>xw`     | Problems panel with "All Files" scope            |
> | `<leader>lv`     | No equivalent (always on in VSCode)              |
> | `<leader>lx`     | No equivalent                                    |

---

## 5. Code Actions — The Smart Fix Menu

Code actions are context-sensitive operations the language server can perform at your cursor
position. They range from simple fixes ("add missing import") to complex refactors ("extract
to function"). The available actions depend entirely on what is under your cursor and what the
language server understands about your code at that moment.

### Triggering code actions

```
<leader>ca   → open the code actions menu (Normal mode — cursor position)
<leader>ca   → open the code actions menu (Visual mode — selected range)
```

The key works in both Normal and Visual mode. In Visual mode, you unlock range-based
actions like "extract selection to function."

A small popup appears with a numbered list of available actions. Navigate with `j`/`k` and
press `Enter` to apply.

### TypeScript/JavaScript actions

**On an undefined identifier or import line:**

```
<leader>ca → options:
  1. Add import 'React' from 'react'
  2. Add import 'useState' from 'react'
  3. Organize all imports (sort and remove unused)
  4. Remove all unused imports
  5. Add missing await keyword
```

**On ESLint-highlighted code:**

```
<leader>ca → options:
  1. Fix: Replace with const    (prefer-const rule)
  2. Disable eslint rule for this line
  3. Disable eslint rule for this file
  4. Show documentation for this rule
```

**On a `let` variable that is never reassigned:**

```
<leader>ca → options:
  1. Convert 'let' to 'const'
```

**On a function or variable:**

```
<leader>ca → options:
  1. Extract to named function
  2. Move to new file
  3. Convert arrow function to function declaration
  4. Infer all return types in function
  5. Add type annotation
```

**On a selected block of code (Visual mode `<leader>ca`):**

```
<leader>ca → options:
  1. Extract to function in module scope
  2. Extract to constant (replace expression with variable)
  3. Extract to React component (TypeScript React files)
  4. Move to new file
```

### Python actions (pyright + ruff)

```
# On an unused import:
<leader>ca → Remove unused import 'os'

# On a ruff rule violation:
<leader>ca → Fix: [UP006] Use 'list' instead of 'typing.List'
             Fix: [I001] Import block is unsorted

# On a bare except:
<leader>ca → Add exception type: 'except Exception as e:'

# On a function parameter missing a type:
<leader>ca → Add type annotation based on usage
```

### Go actions (gopls)

```
# On an interface type name:
<leader>ca → Stub out interface methods
             (generates all the method signatures you need to implement)

# On a struct literal missing fields:
<leader>ca → Fill struct fields with zero values

# On a function call that returns an error you are ignoring:
<leader>ca → Add error return: 'if err != nil { return err }'

# On a variable that shadows an outer variable:
<leader>ca → Rename to avoid shadowing

# On an import path:
<leader>ca → Extract to separate package
```

### Rust actions (rust-analyzer)

```
# On a match expression with missing arms:
<leader>ca → Fill in missing match arms

# On a struct without derives:
<leader>ca → Add #[derive(Debug)]
             Add #[derive(Clone, PartialEq)]

# On an expression:
<leader>ca → Extract into variable
             Extract into function
             Inline variable

# On a lifetime:
<leader>ca → Introduce named lifetime
```

> 💡 **VSCode equivalent**
>
> `<leader>ca` is exactly Ctrl+. (Quick Fix / Lightbulb) in VS Code. The lightbulb icon that
> appears on lines with auto-fixable problems, the yellow squiggles you can click on — all of
> that is accessed through `<leader>ca` in Neovim. The keyboard-only approach is actually
> faster once you are used to it: no mouse movement to click the lightbulb.

---

## 6. Rename — LSP-Aware Refactoring

### Symbol rename — leader+rn

```
<leader>rn   → rename the symbol under the cursor ACROSS ALL FILES IN THE PROJECT
```

Place your cursor on any identifier — function, variable, type, class, method, interface —
and press `<leader>rn`. An input prompt appears pre-filled with the current name:

```
 New name: getUser█
```

Type the new name and press Enter. The LSP server analyzes every reference to that symbol
across your entire codebase — not just the current file — and renames all of them atomically.
Neovim then shows a summary:

```
Renamed 'getUser' to 'fetchUser' in 7 files (23 occurrences)
```

### Why LSP rename is better than Find & Replace

A plain search-and-replace for "getUser" would also match:
- The string literal `"getUser"` in tests or comments
- A different `getUser` in another module or scope
- The method name `getUserById` (partial match)
- Comments like `// getUser is deprecated`

LSP rename is **semantically aware**. It understands that `getUser` in `components/UserCard.tsx`
refers to the same symbol as `getUser` in `utils/api.ts`. It knows that a variable named
`getUser` in a different scope is a different symbol and should not be renamed. It leaves
string literals and comments untouched unless they are actual references.

```
# Before:
const getUser = (id: string) => fetch(`/users/${id}`)    ← will be renamed
const result = getUser(userId)                            ← will be renamed
// Call getUser to get user data                          ← NOT renamed (comment)
const card = { getUser: someOtherFn }                    ← NOT renamed (different symbol)

# After <leader>rn → fetchUser:
const fetchUser = (id: string) => fetch(`/users/${id}`)
const result = fetchUser(userId)
// Call getUser to get user data                          ← unchanged
const card = { getUser: someOtherFn }                    ← unchanged
```

> 💡 **VSCode equivalent:** F2 (Rename Symbol). Neovim's `<leader>rn` is exactly this.

### File rename — leader+rN

```
<leader>rN   → rename the CURRENT FILE on disk
               Also updates import statements in other files that reference it
               (TypeScript "update imports on file rename" feature via Snacks)
```

This is distinct from symbol rename — `<leader>rN` renames the actual file, not a symbol
within it. In TypeScript, it also triggers the "Update imports" functionality so files that
import the renamed module get their import paths updated.

---

## 7. blink.cmp — Your Completion Engine

blink.cmp is the completion plugin in this config. It replaces the traditional nvim-cmp with
a faster, asynchronous implementation that has noticeably lower latency, especially on large
files. Understanding how it is configured here will make your Insert mode experience smooth
from day one.

### How blink.cmp works

When you enter Insert mode and begin typing, blink.cmp:

1. Detects each keypress and triggers completion queries
2. Queries all configured **sources** simultaneously:
   - **LSP** (priority 90): the language server's completions for your current code context
   - **Snippets** (priority 85): triggered by your `;prefix` snippet triggers
   - **Path** (priority 25): filesystem paths when you type `./`, `../`, or `/`
   - **Buffer** (priority 15): words that appear anywhere in the current open buffers
3. Merges results, deduplicates, and sorts by priority + fuzzy match score
4. Displays the popup with a documentation preview panel on the right

The `prefetch_on_insert = true` setting in this config pre-warms all sources the instant you
press `i`, `a`, `o`, or any key entering Insert mode — before you type anything. This means
the first completion suggestion appears with no latency.

### Triggering and dismissing the menu

```
<C-Space>   → force-show the completion menu
              If already showing: toggle between menu-only, menu+docs, hidden
              Cycle: hidden → menu → menu+docs → hidden → ...

<C-e>       → hide/dismiss the menu without accepting anything
              Use when the popup is blocking your view of the code
```

### Navigating the completion list

```
<C-p> or Arrow Up     → select PREVIOUS item in the list (move cursor up)
<C-n> or Arrow Down   → select NEXT item in the list (move cursor down)
```

### Accepting completions — Ctrl+Y, NOT Enter

```
<C-y>   → ACCEPT the currently highlighted/selected completion item
```

This is the most important config-specific detail in this entire chapter. **You accept
completions with Ctrl+Y in this config, not Enter.**

This is an intentional design decision. The reason is Markdown compatibility: this config
is used for Markdown files, prose writing, and documentation. In a Markdown document, pressing
Enter while a completion popup is showing should insert a newline — not accept a code
completion. If Enter accepted completions, every time you typed a word and pressed Enter in
a prose document, you might accidentally trigger and accept a completion instead of ending
the paragraph.

`<C-y>` is consistent, explicit, and works identically across all filetypes. Once you retrain
the muscle memory, it becomes second nature.

The **preselect** feature highlights the first item in the list automatically. Pressing `<C-y>`
immediately accepts that first suggestion without needing to press `<C-n>` first. If you want
the second suggestion, press `<C-n>` once then `<C-y>`. If you want to type the word literally
without accepting any completion, press `<C-e>` to dismiss.

### Scrolling the documentation pane

```
<S-k>   → scroll the documentation preview window UP
<S-j>   → scroll the documentation preview window DOWN
```

When the completion menu is open and a documentation panel is visible on the right, use
`<S-k>` and `<S-j>` to read through it without closing the menu or moving to a different item.

### Snippet placeholder navigation

```
<Tab>     → jump to the NEXT placeholder in the currently active snippet
            (if not in a snippet: insert a regular Tab character)
<S-Tab>   → jump to the PREVIOUS placeholder in the currently active snippet
```

When a snippet expands, you move between its fillable positions with `<Tab>` and `<S-Tab>`.
After the last placeholder, `<Tab>` exits the snippet and inserts a regular tab.

### Anatomy of the completion popup

```
┌───────────────────────────────────────────────────────────────────────┐
│  useState          ●  ┌────────────────────────────────────────────┐  │
│  useEffect         ●  │  function useState<S>(                     │  │
│  useCallback       ●  │    initialState: S | (() => S)             │  │
│  useMemo           ●  │  ): [S, Dispatch<SetStateAction<S>>]       │  │
│  useRef            ●  │                                            │  │
│  useContext        ●  │  Returns a stateful value, and a function  │  │
│  ;useState (snip)  ▶  │  to update it. On the initial render, the  │  │
│                       │  returned state is the same as the value   │  │
│                       │  passed as the first argument.             │  │
│                       └────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────┘
  ● = LSP item    ▶ = snippet    [C-y]=accept   [C-e]=close
  [C-n/p]=navigate   [S-k/j]=scroll docs   (preselect = first item highlighted)
```

---

## 8. The ; Snippet System

Snippets are pre-written code templates. You type a short trigger, accept the snippet from the
completion menu, and the full template expands with your cursor positioned at the first blank
you need to fill in. Tab moves you through each blank in sequence.

### Why the ; prefix?

Every snippet trigger in this config starts with `;`. Type `;fn` for a function snippet,
`;try` for a try/catch, `;useState` for the useState hook pattern. The semicolon prefix is
deliberate and solves a real problem:

Without a prefix, if you have a snippet triggered by `fn`, it shows up in the completion menu
every time you type "fn" — including when you are typing "function", "findIndex", "font", or
any variable named "fn". The constant snippet suggestion noise becomes disruptive fast. It
feels like the editor is constantly second-guessing you.

With `;` as the prefix, snippets appear in the completion menu **only when you type `;`**.
The semicolon is not a word character in any programming language, so it can only appear as
the intentional start of a snippet trigger. When you type `;fn`, you are explicitly saying
"I want a snippet named fn right here." When you type just "fn", no snippets appear.

### How to expand a snippet step by step

```
1. Enter Insert mode (press i, a, o, etc.)
2. Type ;  followed by the trigger without any space: ;fn
3. The completion popup appears showing the snippet with a ▶ icon
4. If the snippet is the first item (preselected): press <C-y> to accept
5. If you need to navigate to it: press <C-n> a few times, then <C-y>
6. The full template expands, cursor lands at the first placeholder
7. Type your content for that placeholder
8. Press <Tab> to advance to the next placeholder
9. Repeat until all placeholders are filled
10. Press <Tab> one more time to exit the snippet
```

### Example expansion — TypeScript function

```
Before: | (cursor in insert mode, | = cursor position)

Type:   ;fn

Completion popup shows:
  ▶ fn  →  function name(params): ReturnType { ... }

Press <C-y>:

function functionName(params) {
         ────────────
         ^ cursor here (highlighted placeholder)
  
}

Press <Tab>:

function functionName(params) {
                      ──────
                      ^ cursor advances here

Press <Tab>:

function functionName(params) {
  |     ^ cursor is now inside the body

Press <Tab> again: exits the snippet
```

### Complete snippet trigger reference

Snippets live in `dotfiles/.config/nvim/snippets/`. Filetype inheritance is configured:
TypeScript inherits JavaScript, TypeScript React inherits TypeScript and JSX, etc.

---

#### JavaScript / TypeScript (both filetypes)

| Trigger     | Expands to                                            |
|-------------|-------------------------------------------------------|
| `;fn`       | Named function declaration                            |
| `;afn`      | Async named function                                  |
| `;fun`      | `function` keyword function                           |
| `;afun`     | Async `function` keyword function                     |
| `;cl`       | `console.log()`                                       |
| `;cle`      | `console.error()`                                     |
| `;clw`      | `console.warn()`                                      |
| `;clt`      | `console.table()`                                     |
| `;clj`      | `console.log(JSON.stringify(value, null, 2))`          |
| `;imp`      | `import { } from ''`                                  |
| `;impa`     | `import * as name from ''`                            |
| `;imd`      | `import name from ''` (default import)                |
| `;ife`      | Immediately Invoked Function Expression (IIFE)        |
| `;tern`     | Ternary: `condition ? a : b`                          |
| `;try`      | `try { } catch (error) { }`                           |
| `;tryf`     | `try { } catch { } finally { }`                       |
| `;map`      | `.map(item => )`                                      |
| `;filter`   | `.filter(item => )`                                   |
| `;reduce`   | `.reduce((acc, item) => , initial)`                   |
| `;foreach`  | `.forEach(item => )`                                  |
| `;find`     | `.find(item => )`                                     |
| `;prom`     | `new Promise((resolve, reject) => )`                  |
| `;fetch`    | fetch + .then chain                                   |
| `;await`    | `const result = await expression`                     |
| `;obj`      | Object literal with key/value placeholders            |
| `;spread`   | `{ ...object }`                                       |
| `;cls`      | Full ES6 class declaration                            |
| `;timeout`  | `setTimeout(() => { }, delay)`                        |
| `;interval` | `setInterval(() => { }, delay)`                       |

---

#### TypeScript only (in addition to JS)

| Trigger      | Expands to                                           |
|--------------|------------------------------------------------------|
| `;type`      | `type Name = `                                       |
| `;inter`     | `interface Name { }`                                 |
| `;iext`      | `interface Name extends Base { }`                    |
| `;enum`      | `enum Name { }`                                      |
| `;cenum`     | `const enum Name { }`                                |
| `;generic`   | `function name<T>(arg: T): T`                        |
| `;record`    | `Record<KeyType, ValueType>`                         |
| `;partial`   | `Partial<Type>`                                      |
| `;required`  | `Required<Type>`                                     |
| `;pick`      | `Pick<Type, 'key1' \| 'key2'>`                        |
| `;omit`      | `Omit<Type, 'key1' \| 'key2'>`                        |
| `;readonly`  | `Readonly<Type>`                                     |
| `;as`        | `value as Type`                                      |
| `;satis`     | `value satisfies Type`                               |
| `;guard`     | Type guard: `function isName(x: unknown): x is Type` |
| `;nna`       | Non-null assertion: `value!`                         |
| `;opt`       | Optional chain: `value?.property`                    |
| `;null`      | Nullish coalesce: `value ?? fallback`                |
| `;dec`       | TypeScript decorator                                 |

---

#### JSX / React (typescriptreact, javascriptreact)

| Trigger       | Expands to                                          |
|---------------|-----------------------------------------------------|
| `;el`         | `<Tag>children</Tag>`                               |
| `;elf`        | `<Tag />` (self-closing)                            |
| `;frag`       | `<>children</>`                                     |
| `;comp`       | Full React functional component                     |
| `;compp`      | React component with Props type defined             |
| `;hook`       | Custom hook boilerplate (`useMyHook`)               |
| `;ctx`        | Context + Provider boilerplate                      |
| `;cond`       | `{condition && <Component/>}`                       |
| `;ternr`      | `{condition ? <A/> : <B/>}`                         |
| `;listr`      | `{items.map(item => <li key={item.id}>...</li>)}`   |
| `;useState`   | `const [state, setState] = useState(initial)`       |
| `;useEffect`  | `useEffect(() => { }, [deps])`                      |
| `;useCallback`| `useCallback(() => { }, [deps])`                    |
| `;useMemo`    | `useMemo(() => value, [deps])`                      |
| `;useRef`     | `const ref = useRef<Type>(null)`                    |
| `;useContext` | `const value = useContext(MyContext)`               |
| `;onclick`    | `onClick={() => handleClick()}`                     |
| `;onchange`   | `onChange={(e) => setValue(e.target.value)}`        |
| `;onsubmit`   | `onSubmit={(e) => { e.preventDefault(); ... }}`     |
| `;handler`    | Full event handler function                         |
| `;cn`         | `className=""`                                      |
| `;cns`        | `className={cn()}` (with clsx/tailwind-merge)       |
| `;style`      | `style={{ }}`                                       |
| `;suspense`   | `<Suspense fallback={<Loading/>}>...</Suspense>`     |
| `;lazy`       | `const C = lazy(() => import('./Component'))`       |
| `;portal`     | `createPortal(children, document.body)`             |

---

#### Go

| Trigger    | Expands to                                            |
|------------|-------------------------------------------------------|
| `;fn`      | Named function                                        |
| `;mfn`     | Method with receiver                                  |
| `;main`    | `func main() { }`                                     |
| `;ife`     | `if err != nil { return err }`                        |
| `;ifew`    | `if err != nil { return fmt.Errorf("op: %w", err) }`  |
| `;ifen`    | `if err := call; err != nil { return err }`           |
| `;errorf`  | `fmt.Errorf("msg: %w", err)`                          |
| `;errors`  | `errors.New("message")`                               |
| `;struct`  | Struct type declaration                               |
| `;iface`   | Interface declaration                                 |
| `;impl`    | Implement interface (stub all methods)                |
| `;test`    | Test function boilerplate                             |
| `;bench`   | Benchmark function                                    |
| `;trun`    | `t.Run("name", func(t *testing.T) { })`               |
| `;go`      | `go func() { }()` (goroutine)                         |
| `;ch`      | `ch := make(chan Type)`                               |
| `;select`  | `select { case v := <-ch: ... }`                      |
| `;wg`      | WaitGroup with Add/Done/Wait                          |
| `;fmtp`    | `fmt.Printf("", )`                                    |
| `;fmtpl`   | `fmt.Println()`                                       |
| `;fmts`    | `fmt.Sprintf("", )`                                   |
| `;logf`    | `log.Printf("", )`                                    |
| `;handler` | HTTP handler function                                 |
| `;hroute`  | Route registration                                    |
| `;defer`   | `defer func() { ... }()`                              |
| `;ctx`     | `ctx := context.Background()`                         |
| `;ctxt`    | `ctx, cancel := context.WithTimeout(ctx, dur)`        |
| `;sw`      | `switch { case ...: }`                                |

---

#### Python

| Trigger    | Expands to                                            |
|------------|-------------------------------------------------------|
| `;fn`      | Regular function definition                           |
| `;afn`     | Async function definition                             |
| `;main`    | `if __name__ == "__main__": main()`                   |
| `;cls`     | Class definition                                      |
| `;clsi`    | Class with `__init__`                                 |
| `;dc`      | Dataclass with fields                                 |
| `;prop`    | `@property` with getter and setter                    |
| `;try`     | `try: ... except Exception as e:`                     |
| `;tryf`    | `try: ... except: ... finally:`                       |
| `;with`    | `with open(path, 'r') as f:`                          |
| `;lc`      | List comprehension                                    |
| `;dc2`     | Dict comprehension                                    |
| `;gc`      | Generator expression                                  |
| `;afor`    | `async for item in iterable:`                         |
| `;awith`   | `async with context as var:`                          |
| `;test`    | `def test_name(self):`                                |
| `;fix`     | `# type: ignore`                                      |
| `;topt`    | `Optional[Type]`                                      |
| `;tunion`  | `Union[TypeA, TypeB]`                                 |

---

#### Lua

| Trigger    | Expands to                                            |
|------------|-------------------------------------------------------|
| `;fn`      | `local function name() end`                           |
| `;fnm`     | `M.name = function() end`                             |
| `;loc`     | `local name = value`                                  |
| `;req`     | `local name = require("module")`                      |
| `;mod`     | Full module with `local M = {}` ... `return M`        |
| `;ife`     | `if condition then ... end`                           |
| `;ifn`     | `if not condition then ... end`                       |
| `;for`     | `for i = 1, n do ... end`                             |
| `;fori`    | `for i, v in ipairs(t) do ... end`                    |
| `;forp`    | `for k, v in pairs(t) do ... end`                     |
| `;map`     | `vim.tbl_map(fn, table)`                              |
| `;au`      | `vim.api.nvim_create_autocmd("event", { ... })`       |
| `;aug`     | Augroup boilerplate                                   |
| `;notify`  | `vim.notify("msg", vim.log.levels.INFO)`              |
| `;tbl`     | Table literal with entries                            |
| `;pcall`   | `local ok, result = pcall(fn, args)`                  |

---

#### Rust

| Trigger    | Expands to                                            |
|------------|-------------------------------------------------------|
| `;fn`      | `fn name() { }`                                       |
| `;pfn`     | `pub fn name() { }`                                   |
| `;afn`     | `async fn name() { }`                                 |
| `;main`    | `fn main() { }`                                       |
| `;struct`  | Struct definition                                     |
| `;pstruct` | `pub struct` definition                               |
| `;enum`    | Enum definition                                       |
| `;penum`   | `pub enum` definition                                 |
| `;impl`    | `impl StructName { }`                                 |
| `;trait`   | Trait definition                                      |
| `;implfor` | `impl TraitName for StructName { }`                   |
| `;res`     | `Result<T, E>`                                        |
| `;opt`     | `Option<T>`                                           |
| `;qm`      | `?` operator on an expression                         |
| `;ok`      | `Ok(value)`                                           |
| `;err`     | `Err(error)`                                          |
| `;some`    | `Some(value)`                                         |
| `;match`   | Full match expression with arms                       |
| `;iflet`   | `if let Some(val) = option { }`                       |
| `;wlet`    | `while let Some(v) = iter.next() { }`                 |
| `;pl`      | `println!("{}", value)`                               |
| `;ep`      | `eprintln!("{}", value)`                              |
| `;dbg`     | `dbg!(&value)`                                        |
| `;vec`     | `vec![...]`                                           |
| `;derive`  | `#[derive(Debug, Clone, PartialEq)]`                  |
| `;test`    | Test function with assert_eq!                         |
| `;testmod` | `#[cfg(test)] mod tests { }` block                    |
| `;assert`  | `assert_eq!(actual, expected)`                        |
| `;spawn`   | `tokio::spawn(async move { })`                        |
| `;amain`   | `#[tokio::main] async fn main() { }`                  |

---

#### Bash

| Trigger    | Expands to                                            |
|------------|-------------------------------------------------------|
| `;shebang` | `#!/usr/bin/env bash` + `set -euo pipefail`           |
| `;fn`      | Bash function definition                              |
| `;if`      | `if [ condition ]; then ... fi`                       |
| `;ife`     | `if ... then ... else ... fi`                         |
| `;for`     | `for item in list; do ... done`                       |
| `;while`   | `while [ condition ]; do ... done`                    |
| `;case`    | `case $var in pattern) ;; esac`                       |
| `;log`     | `echo "[INFO] message"`                               |
| `;die`     | `echo "[ERROR] message" >&2; exit 1`                  |
| `;check`   | Check that a command exists before calling it         |
| `;args`    | Argument parsing boilerplate                          |
| `;trap`    | `trap 'cleanup' EXIT INT TERM`                        |
| `;tmpdir`  | `mktemp -d` with cleanup trap                         |
| `;readonly`| `readonly VARNAME="value"`                            |

---

#### C / C++

| Trigger   | Expands to                                             |
|-----------|--------------------------------------------------------|
| `;main`   | `int main(int argc, char *argv[]) { return 0; }`       |
| `;fn`     | Function with return type, parameters, body            |
| `;guard`  | `#ifndef FILE_H #define FILE_H ... #endif`             |
| `;inc`    | `#include "header.h"`                                  |
| `;incs`   | `#include <stdlib.h>`                                  |
| `;printf` | `printf("format\n", args);`                            |
| `;scanf`  | `scanf("format", &var);`                               |
| `;struct` | `typedef struct { } Name;`                             |
| `;malloc` | `Type *ptr = malloc(sizeof(Type));`                    |
| `;free`   | `free(ptr); ptr = NULL;`                               |
| `;for`    | `for (int i = 0; i < n; i++) { }`                      |
| `;switch` | `switch (var) { case VAL: break; default: }`           |

---

#### All filetypes (available everywhere)

| Trigger   | Expands to                                             |
|-----------|--------------------------------------------------------|
| `;todo`   | `TODO: description` (highlighted by todo-comments)     |
| `;fixme`  | `FIXME: description`                                   |
| `;note`   | `NOTE: description`                                    |
| `;hack`   | `HACK: description`                                    |
| `;bug`    | `BUG: description`                                     |
| `;perf`   | `PERF: description` (performance improvement note)     |
| `;warn`   | `WARN: description`                                    |

---

## 9. Aerial — Symbols Outline

Aerial provides a code structure panel — a hierarchical list of all symbols in the current file:
functions, classes, types, methods, interfaces, variables. It gives you a bird's-eye view of a
file's architecture without scrolling through the full content.

### Opening and toggling aerial

```
<leader>lo   → toggle the aerial panel (opens as a sidebar on the right)
```

For a TypeScript service class, the panel looks like this:

```
  ╔═══════════════════════════════════╗
  ║  AERIAL OUTLINE                   ║
  ║  ───────────────────────────────  ║
  ║  ▶ UserService (class)   line 12  ║
  ║    ├─ constructor         line 16  ║
  ║    ├─ findById            line 25  ║
  ║    ├─ findAll             line 38  ║
  ║    ├─ create              line 52  ║
  ║    ├─ update              line 68  ║
  ║    └─ delete              line 85  ║
  ║  ▶ formatUser (fn)        line 98  ║
  ║  ▶ validateEmail (fn)    line 106  ║
  ║  ▶ UserRepository (iface) line 115 ║
  ║    ├─ findById            line 116  ║
  ║    ├─ findAll             line 117  ║
  ║    └─ save                line 118  ║
  ╚═══════════════════════════════════╝
```

### Navigating with aerial keys

```
[a   → jump to the PREVIOUS symbol (without opening the panel)
]a   → jump to the NEXT symbol (without opening the panel)
```

`[a` and `]a` are the aerial keys you will use most often. In a large file with dozens of
functions, press `]a` repeatedly to jump to the next function definition — or `[a` to go back.
You do not need the panel open to use these.

**Inside the aerial panel (when open):**

```
j / k        → move cursor through the symbol list
Enter        → jump the main editor window to the selected symbol
q            → close the aerial panel
```

Aerial has a cursor-follow mode: as you navigate in the aerial list, the main editor
automatically scrolls to show that symbol. This lets you browse the file structure and see
each function's content without jumping to it yet.

### When to use aerial

- **Large files** (200+ lines): aerial gives you a map of the file's structure so you know
  where everything is without mentally tracking it
- **Unfamiliar code**: open a file you have never seen before, `<leader>lo` to understand
  its API surface immediately
- **Quick function jump**: `]a`/`[a` to navigate between functions without scrolling

> 💡 **VSCode equivalent**
>
> `<leader>lo` opens the equivalent of VS Code's "OUTLINE" section (bottom of the Explorer
> panel). VS Code shows it as a permanent collapsible panel; in Neovim it is a toggleable
> overlay. Many developers find the on-demand toggle cleaner — it is there when you need
> a structural overview, gone when you want maximum screen space for code.

---

## 10. Inlay Hints

Inlay hints are virtual text decorations inserted by language servers to show additional type
information that is not written in the source code. They appear inline but are not real text —
they cannot be edited or deleted.

Examples of what inlay hints show:

```typescript
// Without inlay hints:
const result = getUserById(42)
const [count, setCount] = useState(0)
function greet(name, age) {

// With inlay hints enabled:
const result: User = getUserById(42)
const [count: number, setCount] = useState(0)
function greet(name: string, age: number) {
```

```go
// Without:
x, err := db.Query(query)

// With:
x: *sql.Rows, err: error := db.Query(query)
```

### Inlay hints key

```
<leader>li   → toggle inlay hints ON or OFF for the current buffer
```

### Why inlay hints are disabled by default in this config

This config disables inlay hints by default due to a rendering bug in **Neovim 0.12.2**.

The problem: LSP servers occasionally return hint positions that are past the end of a line.
For example, they report that a hint should appear at column 45 in a line that is only 43
characters long. When Neovim tries to place a virtual text extmark at column 45 on a 43-char
line, it throws:

```
E5108: Error executing Lua [C]: in function nvim_buf_set_extmark
  Invalid 'col': out of range
```

This error crashes the LSP display and can interrupt editing flow. Because several language
servers (particularly `vtsls` for TypeScript and `rust-analyzer`) occasionally return these
out-of-range positions, the safe default is off.

**Expected fix:** Neovim 0.12.3+ is expected to include a bounds check that clamps hint
positions to valid column ranges. Once you upgrade to a version that includes this fix, inlay
hints should work without crashes.

**To enable inlay hints by default** (after upgrading, or if your servers do not trigger the
bug), edit `dotfiles/.config/nvim/lua/de100/plugins/lsp/lsp.lua`. In the `LspAttach`
autocmd callback, add this line:

```lua
vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
```

For now, `<leader>li` lets you toggle them on per-buffer when you want them, and turn them off
if you encounter the crash.

---

## 11. kulala.nvim — REST/HTTP Client

kulala.nvim brings an HTTP client into Neovim. Instead of switching to Postman, Insomnia,
HTTPie, or a browser tab to test an API endpoint, you write the request in a `.http` file and
run it from the editor. The response appears in a split buffer next to your request.

This fits Neovim's philosophy completely: everything is a text buffer. Your API test cases are
version-controlled text files. They live in your repository next to the code that uses the API.
You can copy, edit, commit, and review them with the same tools you use for code.

### Creating a .http request file

Create any file with the `.http` or `.rest` extension:

```http
### List all users
GET https://api.example.com/users
Authorization: Bearer {{token}}
Content-Type: application/json

### Get a specific user
GET https://api.example.com/users/{{userId}}
Authorization: Bearer {{token}}

### Create a new user
POST https://api.example.com/users
Content-Type: application/json
Authorization: Bearer {{token}}

{
  "name": "Alice Johnson",
  "email": "alice@example.com",
  "role": "admin"
}

### Update a user (partial update)
PATCH https://api.example.com/users/{{userId}}
Content-Type: application/json
Authorization: Bearer {{token}}

{
  "name": "Alice Smith"
}

### Delete a user
DELETE https://api.example.com/users/{{userId}}
Authorization: Bearer {{token}}
```

**Syntax rules:**
- `### Comment` starts a new request block (the comment is shown in the response header)
- `METHOD url` is the request line (GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS)
- Headers follow immediately, one per line, in `Key: Value` format
- An empty line separates headers from the body
- `{{variable}}` is resolved from environment files at runtime

### Running requests

```
<leader>Hr   → run the request the cursor is currently IN
               (kulala finds the nearest ### block above the cursor)

<leader>Ha   → run ALL requests in the file, one by one
               Useful for running a full API test suite

<leader>Hp   → replay the LAST request you ran
               Your cursor does not need to be in that request block

<leader>Hi   → inspect the current request
               Shows the fully-resolved request (variables substituted, all headers)
               before actually sending — useful for debugging

<leader>Hc   → copy the current request as a cURL command
               Useful for sharing with teammates or running in a terminal
```

After running `<leader>Hr`, the response appears in a split:

```
┌───────────────────────────────────────────────────────────────────┐
│ api-tests.http                                                    │
│                                                                   │
│  ### List all users                                               │
│  GET https://api.example.com/users                                │
│  Authorization: Bearer {{token}}               ← cursor here     │
├───────────────────────────────────────────────────────────────────┤
│  HTTP/1.1 200 OK                                      47ms        │
│  ─────────────────────────────────────────────────────────────    │
│  Content-Type: application/json; charset=utf-8                   │
│  X-Request-Id: req_abc123def456                                   │
│  X-RateLimit-Remaining: 99                                        │
│                                                                   │
│  [                                                                │
│    {                                                              │
│      "id": "user_001",                                            │
│      "name": "Bob",                                               │
│      "email": "bob@example.com",                                  │
│      "createdAt": "2024-01-15T10:30:00Z"                          │
│    },                                                             │
│    ...                                                            │
│  ]                                                                │
└───────────────────────────────────────────────────────────────────┘
```

The response buffer is a regular Neovim buffer — you can yank JSON from it, search it, copy
values. If the response is JSON, kulala formats it with pretty-printing automatically.

### Navigating between requests

```
]r   → jump to the NEXT request block (next ### separator)
[r   → jump to the PREVIOUS request block
```

In a file with 10+ request blocks, `]r`/`[r` moves you through them efficiently. Combined with
`<leader>Hr` to run the one you land on, you can test requests in sequence quickly.

### Environment variables and files

Variables in `{{doubleBraces}}` are resolved from environment configuration files. Create a
`.env` (or environment-specific files) in the same directory as your `.http` file:

```bash
# .env  (development defaults)
baseUrl=https://dev-api.example.com
token=dev_token_abc123
userId=user_001

# .env.staging
baseUrl=https://staging-api.example.com
token=staging_token_xyz789

# .env.prod  (do NOT commit this to git)
baseUrl=https://api.example.com
token=prod_secret_token_here
```

Using different environments lets you run the same `.http` file against development, staging,
and production without editing the request files. Switch between environments via kulala's
environment selector (`:KulalaSelectEnv` or through the kulala menu).

### The .http file as living documentation

One powerful workflow: keep a `requests/` directory in your project with `.http` files for
every API endpoint your service exposes:

```
your-project/
├── src/
│   └── routes/
│       ├── users.ts
│       └── auth.ts
└── requests/
    ├── users.http
    ├── auth.http
    └── .env
```

These files serve as executable documentation. A new team member can open `users.http` and
immediately see every endpoint with example request bodies. They can run each request to
verify the API is working. The `.http` files and the source code evolve together.

> 💡 **VSCode equivalent**
>
> kulala.nvim is the equivalent of the **REST Client** extension for VS Code, which uses
> identical `.http` file syntax with `### separator` and `{{variable}}` syntax (kulala is
> directly inspired by and compatible with the REST Client format). If you have existing REST
> Client `.http` files, they work in kulala without modification. VS Code also has Thunder
> Client and Postman extensions; kulala covers the same use case without leaving Neovim.

---

## 12. Complete Reference Table

### LSP Navigation

| Key           | Action                                         | VSCode              |
|---------------|------------------------------------------------|---------------------|
| `gd`          | Go to definition                               | F12                 |
| `gD`          | Go to declaration                              | (context menu)      |
| `gR`          | Show all references (Snacks picker)            | Shift+F12           |
| `gi`          | Show implementations (Snacks picker)           | Ctrl+F12            |
| `gt`          | Go to type definition                          | (context menu)      |
| `K`           | Hover documentation                            | Mouse hover         |
| `<leader>ca`  | Code actions (Normal + Visual)                 | Ctrl+.              |
| `<leader>rn`  | Rename symbol across project                   | F2                  |
| `<leader>rN`  | Rename current file                            | Explorer context    |
| `<leader>ls`  | Signature help                                 | Ctrl+Shift+Space    |

### Diagnostics

| Key           | Action                                              |
|---------------|------------------------------------------------------|
| `[d`          | Go to previous diagnostic                           |
| `]d`          | Go to next diagnostic                               |
| `<leader>df`  | Floating window for current line's diagnostic       |
| `<leader>D`   | All buffer diagnostics in Snacks picker             |
| `<leader>lv`  | Toggle virtual text (inline diagnostic messages)    |
| `<leader>lx`  | Toggle all diagnostics visibility                   |
| `<leader>li`  | Toggle inlay hints                                  |
| `<leader>xw`  | Trouble: workspace diagnostics (all files)          |
| `<leader>xd`  | Trouble: document diagnostics (current file)        |
| `<leader>xq`  | Trouble: quickfix list                              |
| `<leader>xt`  | Trouble: TODOs and FIXMEs                           |

### blink.cmp Completion

| Key          | Action                                               |
|--------------|------------------------------------------------------|
| `<C-Space>`  | Show completion menu (or cycle: menu → docs → hide)  |
| `<C-e>`      | Dismiss completion menu without accepting            |
| `<C-y>`      | Accept selected item (NOT Enter)                     |
| `<C-p>` / ↑  | Select previous item                                 |
| `<C-n>` / ↓  | Select next item                                     |
| `<S-k>`      | Scroll documentation pane up                         |
| `<S-j>`      | Scroll documentation pane down                       |
| `<Tab>`      | Next snippet placeholder                             |
| `<S-Tab>`    | Previous snippet placeholder                         |

### Mason

| Command                  | Action                                      |
|--------------------------|----------------------------------------------|
| `:Mason`                 | Open Mason UI                               |
| `:MasonInstall <name>`   | Install a specific package                  |
| `:MasonUninstall <name>` | Remove a package                            |
| `:MasonUpdate`           | Update all installed packages               |
| `i` (in Mason UI)        | Install package under cursor                |
| `X` (in Mason UI)        | Uninstall package under cursor              |
| `U` (in Mason UI)        | Update all packages                         |

### Aerial

| Key           | Action                                              |
|---------------|------------------------------------------------------|
| `<leader>lo`  | Toggle aerial symbols outline panel                 |
| `[a`          | Jump to previous symbol in file                     |
| `]a`          | Jump to next symbol in file                         |
| `Enter`       | Jump to symbol (inside aerial panel)                |
| `q`           | Close aerial panel                                  |

### kulala.nvim

| Key           | Action                                              |
|---------------|------------------------------------------------------|
| `<leader>Hr`  | Run request under cursor                            |
| `<leader>Ha`  | Run all requests in the file                        |
| `<leader>Hp`  | Replay the last request                             |
| `<leader>Hi`  | Inspect current request (preview before sending)    |
| `<leader>Hc`  | Copy request as cURL command                        |
| `]r`          | Jump to next request block                          |
| `[r`          | Jump to previous request block                      |

---

## 13. Exercises

Work through these exercises with a real project open. LSP and completion features need actual
code with a real language server attached to be meaningful. Run `:LspInfo` first to confirm
your language server is connected.

---

### Exercise 1 — LSP navigation fluency

**Goal:** Build the reflex to use LSP navigation instead of searching manually.

1. Open a TypeScript (or Go, Python, Rust) file in a real project.
2. Run `:LspInfo` and read which language server is attached and the root directory it detected.
3. Find a function that is called in the current file but defined elsewhere. Place your cursor
   on the function name. Press `gd`. Did you jump to its definition? Press `Ctrl+O` to jump
   back. (Ctrl+O is Neovim's native "jump back" — not a config key, but essential.)
4. Now press `gR` on the same function. How many places use it? Navigate through at least 5
   results with `j`/`k` and read the preview. Jump to one by pressing Enter.
5. Find an interface or abstract type. Press `gi` on it. How many implementations does it have?
6. Press `K` on a standard library function (e.g., `console.log`, `fmt.Println`). Read the
   documentation. Press `K` again to focus the popup, scroll down with arrow keys, then close
   with `q`.
7. Type a function call somewhere: `myFunction(|` with cursor inside. Press `<leader>ls`.
   Watch the parameter hint popup appear.
8. Repeat steps 3-7 three times each until you do not need to think about which key to press.

---

### Exercise 2 — Diagnostics workflow

**Goal:** Navigate and address diagnostics efficiently without using the mouse.

1. Find (or create) a file with at least 3 diagnostics. If needed, in TypeScript:
   ```typescript
   const x: string = 42           // error: type mismatch
   let unused = "never used"       // warning: declared but never read
   import something from 'nowhere' // error: module not found
   ```
2. Run `]d` repeatedly to cycle through all diagnostics. Count how many there are.
3. On each diagnostic, press `<leader>df` and read the full message, error code, and source.
4. Press `<leader>D` to open the Snacks picker with all diagnostics. Navigate and preview each.
5. Press `<leader>lv` to toggle virtual text off. Notice the lines look "clean" but the sign
   column icons remain. Press `<leader>lv` to restore.
6. Press `<leader>ca` on each diagnostic and see if there are auto-fix options. Apply one.
7. Open `<leader>xd` (Trouble document diagnostics) and compare the view to `<leader>D`.
   Which do you prefer for reviewing errors?

---

### Exercise 3 — Snippet muscle memory

**Goal:** Make snippet expansion as automatic as typing.

Open files in the languages you use most (TypeScript, Go, Python) and practice:

1. **TypeScript:** In a `.ts` file, expand each of these one by one:
   - `;fn` — type a function name and parameter in the placeholders
   - `;inter` — type an interface name and one property
   - `;try` — write a try/catch block
   - `;imp` — write a real import you need
   - `;useState` — write a state hook with a real state name

2. **Go:** In a `.go` file, expand:
   - `;fn` — a named function with a real name
   - `;ife` — the error check pattern
   - `;struct` — a struct with 3 fields
   - `;test` — a test function

3. **All filetypes:** In any file, expand:
   - `;todo` — write a real TODO note
   - `;fixme` — note something that needs fixing

4. For each snippet: pay attention to the Tab stops. Practice Tab/S-Tab navigation until
   moving between placeholders feels natural.
5. Time yourself: can you expand `;comp` (React component) and fill in all placeholders in
   under 15 seconds?

---

### Exercise 4 — Symbol rename across files

**Goal:** Trust LSP rename for multi-file refactoring instead of Find & Replace.

1. Find a function, type, or variable in your project that is referenced in at least 3 different
   files. (Use `gR` to check how many references it has — you need at least 3.)
2. Place your cursor on the definition.
3. Press `<leader>rn` and type a new name with a clearly different prefix (e.g., add "V2" or
   "New" to the name).
4. Press Enter and read the rename summary. Note how many files were changed.
5. Use `<leader>pr` or `<leader>pf` to open 2 of the affected files. Verify the new name
   appears in the correct places.
6. Check that string literals and comments containing the old name were NOT changed.
7. Undo the rename: in each changed file, press `u` to undo. Verify all files return to the
   original name. (You may need to undo in each file individually.)

---

### Exercise 5 — REST API testing with kulala

**Goal:** Replace an external HTTP client tool with kulala for a real API test.

1. Create a file `test-api.http` in your project or `/tmp/`.
2. Write 4 request blocks using the JSONPlaceholder API (no auth needed):
   ```http
   ### Get all todos
   GET https://jsonplaceholder.typicode.com/todos?_limit=5

   ### Get todo by ID
   GET https://jsonplaceholder.typicode.com/todos/{{todoId}}

   ### Create a todo
   POST https://jsonplaceholder.typicode.com/todos
   Content-Type: application/json

   {
     "title": "Test from Neovim kulala",
     "completed": false,
     "userId": 1
   }

   ### Update a todo
   PUT https://jsonplaceholder.typicode.com/todos/{{todoId}}
   Content-Type: application/json

   {
     "title": "Updated from Neovim",
     "completed": true,
     "userId": 1
   }
   ```
3. Create a `.env` file in the same directory: `todoId=1`
4. Navigate between requests with `]r` and `[r`.
5. Run the first request with `<leader>Hr`. Read the response in the split buffer.
6. Use `<leader>Hp` to replay the same request without moving your cursor.
7. Navigate to the POST request and run it. Check the response — you should get a 201 Created.
8. Press `<leader>Hc` on the POST request. Paste the cURL output in a terminal and verify it
   produces the same result: `:terminal` (open Neovim terminal), paste and run.
9. Press `<leader>Hi` on the last request to inspect it before sending.
10. Bonus: add a real API endpoint from a project you are working on. Test it with kulala
    instead of switching to Postman.

---

*Continue to [Chapter 08 — Git Workflow](./08-git-workflow.md) to learn how Gitsigns,*
*Diffview, Neogit, LazyGit, and Fugitive work together for a complete in-editor git workflow.*
