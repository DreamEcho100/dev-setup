# 10 · Formatting and Linting

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║    F O R M A T T I N G   &   L I N T I N G                                 ║
║                                                                              ║
║    conform.nvim  ──────────────────────────►  makes code look right         ║
║    nvim-lint     ──────────────────────────►  tells you when code is wrong  ║
║                                                                              ║
║    [ Two tools. One responsibility each. Zero excuses for messy code. ]     ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## Table of Contents

1. [Introduction — Why Two Plugins?](#1-introduction--why-two-plugins)
2. [The Formatting + Linting Pipeline](#2-the-formatting--linting-pipeline)
3. [conform.nvim Deep Dive](#3-conformnvim-deep-dive)
4. [Per-Language Formatter Table](#4-per-language-formatter-table)
5. [Prettier Config Details](#5-prettier-config-details)
6. [nvim-lint Deep Dive](#6-nvim-lint-deep-dive)
7. [ftplugin Settings — Per-Language Editor Behavior](#7-ftplugin-settings--per-language-editor-behavior)
8. [Ansible LSP — ansiblels and ansible-lint](#8-ansible-lsp--ansiblels-and-ansible-lint)
9. [Troubleshooting](#9-troubleshooting)
10. [Quick Reference](#10-quick-reference)
11. [Exercises](#11-exercises)

---

## 1. Introduction — Why Two Plugins?

### The Problem They Solve

Let's say you're working on a TypeScript file. You write a function, forget to add
a semicolon (or add too many), use inconsistent quote styles, leave trailing
whitespace on line 47, and accidentally introduce a variable that shadows an outer
scope. There are actually **two completely different categories of problem** there:

- **Style violations** — things that are inconsistent but technically valid. Extra
  spaces, quote style, trailing commas, line length. These are things a computer
  can fix automatically without knowing anything about your program's logic.

- **Logical/quality issues** — things that might indicate a bug, a maintainability
  problem, or a bad pattern. Shadowed variables, unused imports, unreachable code,
  missing return types. These need to be *reported* so a human can decide what to
  do, not silently "fixed" by a computer.

This distinction is the entire reason we have two separate plugins instead of one.

**Formatting** is the act of automatically transforming code into a canonical style.
The tool makes a decision and rewrites your file. You don't get a choice — that's
the whole point. When everyone on the team uses the same formatter with the same
config, nobody wastes time arguing about code style in code reviews. The diff stays
clean because whitespace and style churn never shows up.

**Linting** is the act of analyzing code and reporting potential problems — but
*not* automatically fixing them. You get a list of diagnostics: "line 23 uses a
variable that's never defined," "line 47 has a function with cognitive complexity
of 47 (max is 15)," "line 91 imports a module but never uses it." You then decide
what to do. Sometimes the fix is obvious. Sometimes it's a design decision.

### VSCode Analogy

If you're coming from VSCode, you've almost certainly used this setup:

- **Prettier extension** — auto-format on save. You press `Ctrl+S`, the file
  magically reformats. Style arguments end.
- **ESLint extension** — shows red/yellow squiggles under code problems. The
  Problems panel lists all the issues. You fix them manually (or sometimes
  ESLint can auto-fix the simple ones).

In Neovim with this config:

| VSCode | Neovim equivalent | Plugin |
|---|---|---|
| Prettier extension | `<leader>mp` or format on save | conform.nvim |
| ESLint extension diagnostics | Red/yellow squiggles + diagnostic float | nvim-lint |
| Problems panel | `:Trouble diagnostics` | trouble.nvim |
| Quick Fix | `<leader>ca` (code action) | LSP |
| Format Document | `<leader>mp` | conform.nvim |
| Format Selection | `<leader>mp` in visual mode | conform.nvim |

The mental model maps almost perfectly. The difference is that in Neovim,
everything is more configurable and more composable — you can mix and match
formatters per language, run multiple linters simultaneously, and override
behavior per project or even per buffer.

### Why Not Just Use LSP Formatting?

You might wonder: the LSP server (like `vtsls` for TypeScript or `pyright` for
Python) already knows how to format code. Why bother with a separate formatter?

A few reasons worth understanding:

1. **Consistency across languages.** Your LSP servers are different for every
   language, and they have different formatting opinions. Prettier will format
   your TypeScript, your HTML, your CSS, and your JSON *consistently*, using the
   same rules everywhere. The TypeScript LSP's built-in formatter has different
   defaults and may not format your HTML at all.

2. **Dedicated formatters are better at their job.** `ruff_format` is
   astronomically faster than the Python LSP's formatting. `gofumpt` is stricter
   than what `gopls` applies by default. Biome formats TypeScript faster than any
   LSP. These tools were built for one job.

3. **LSP formatting is a fallback, not the primary path.** In this config,
   `lsp_format = "fallback"` means "only use LSP formatting if no external
   formatter is available." This gives you the best of both worlds — dedicated
   formatters when they exist, LSP as the safety net.

4. **Debuggability.** When something goes wrong with VSCode's "Format on Save,"
   it can be nearly impossible to tell which extension ran, which version of the
   formatter was used, or why it silently did nothing. In Neovim, you run
   `:ConformInfo` and get an exact answer.

### Two Plugins, One Codebase

The config files that implement this chapter:

```
dotfiles/.config/nvim/lua/de100/plugins/
├── formatting.lua    ← conform.nvim config
└── linting.lua       ← nvim-lint config

dotfiles/.config/nvim/after/ftplugin/
├── python.lua        ← Python editor settings
├── yaml.lua          ← YAML editor settings
├── json.lua          ← JSON editor settings
├── jsonc.lua         ← JSONC editor settings
├── go.lua            ← Go editor settings
├── markdown.lua      ← Markdown editor settings
├── rust.lua          ← Rust editor settings
├── c.lua             ← C editor settings
├── cpp.lua           ← C++ editor settings
├── sh.lua            ← Shell script settings
└── sql.lua           ← SQL editor settings
```

All of these work together to give you a coherent, consistent editing experience
across every language you touch.

---

## 2. The Formatting + Linting Pipeline

Understanding exactly what happens when you format or lint helps you diagnose
problems and reason about the system. Let's trace both paths in detail.

### The Formatting Pipeline

```
  You press <leader>mp  (or file is saved with format_after_save enabled)
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │                        conform.nvim                             │
  │                                                                 │
  │  1. What is the current buffer's filetype?                      │
  │     e.g., "typescript"                                          │
  │                                                                 │
  │  2. Look up formatters_by_ft["typescript"]                      │
  │     → { "biome-check", "prettierd", "prettier",                │
  │           stop_after_first = true }                             │
  │                                                                 │
  │  3. stop_after_first = true: try each in order,                │
  │     stop when the first one that IS available runs successfully │
  │                                                                 │
  │  4. Is biome-check available? (check PATH + Mason bin)         │
  │     YES → use biome-check, DONE                                │
  │     NO  → try next                                              │
  │                                                                 │
  │  5. Is prettierd available?                                     │
  │     YES → use prettierd, DONE                                  │
  │     NO  → try next                                              │
  │                                                                 │
  │  6. Is prettier available?                                      │
  │     YES → use prettier, DONE                                   │
  │     NO  → no formatter found (log if notify_on_error)          │
  │                                                                 │
  │  7. Also apply ["*"] formatters (codespell) — always runs      │
  │  8. ["_"] formatters (trim_whitespace) — for filetypes         │
  │     with no other formatters configured                         │
  └─────────────────────────────────────────────────────────────────┘
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │  Formatter runs as external process                             │
  │                                                                 │
  │  conform sends buffer content via stdin                         │
  │  formatter reads stdin, processes it, writes to stdout          │
  │  conform reads stdout                                           │
  │                                                                 │
  │  The formatter never touches the file on disk directly.         │
  │  It operates purely on the content conform sends it.           │
  └─────────────────────────────────────────────────────────────────┘
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │  Buffer replacement (minimal diff)                              │
  │                                                                 │
  │  conform does NOT just overwrite the entire buffer.             │
  │  It computes a minimal diff between old and new content         │
  │  and applies only the changed lines.                            │
  │                                                                 │
  │  This matters because:                                          │
  │  - Cursor position is preserved as much as possible            │
  │  - Undo history is granular — u undoes the format              │
  │  - Extmarks (LSP decorations) are not unnecessarily invalidated │
  └─────────────────────────────────────────────────────────────────┘
           │
           ▼
  Buffer shows formatted code. Undo (u) reverses the format completely.
```

When conform formats on save, it works *asynchronously* via `format_after_save`.
The save completes instantly, and the formatted version appears a fraction of a
second later without blocking your workflow. The `<leader>mp` keybinding uses
`async = false` with a `timeout_ms = 1500`, meaning it blocks up to 1.5 seconds
waiting for the result. For interactive formatting that's fine — you want to see
the result immediately before your next keystroke.

### The Linting Pipeline

```
  Trigger event fires:
  BufEnter (opening / switching to a buffer)
  BufWritePost (after saving)
  InsertLeave (when you press Escape to leave insert mode)
           │
           OR
  You press <leader>ll manually
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │                        nvim-lint                                │
  │                                                                 │
  │  1. What is the current buffer's filetype?                      │
  │     e.g., "python"                                              │
  │                                                                 │
  │  2. Look up linters_by_ft["python"]                             │
  │     → { "ruff", "pylint" }                                      │
  │                                                                 │
  │  3. For EACH linter in the list (no stop_after_first):         │
  │     - Is the binary available in PATH or Mason bin?             │
  │     - If yes, run it as an external process                     │
  │     - Pass the file path as argument                            │
  │                                                                 │
  │  Unlike formatters, ALL configured linters run.                │
  │  You get diagnostics from ruff AND pylint combined.            │
  └─────────────────────────────────────────────────────────────────┘
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │  Each linter produces output in its own format                  │
  │                                                                 │
  │  ruff  → JSON array: [{filename, row, col, code, message}]     │
  │  pylint → text format: filename:line:col: code message          │
  │                                                                 │
  │  nvim-lint has built-in parsers for each linter's output.      │
  │  Each parser extracts: line, column, severity, message, code.  │
  └─────────────────────────────────────────────────────────────────┘
           │
           ▼
  ┌─────────────────────────────────────────────────────────────────┐
  │  Diagnostics population via vim.diagnostic.set()               │
  │                                                                 │
  │  nvim-lint calls vim.diagnostic.set() with parsed results      │
  │  These go into the SAME diagnostic system used by LSP          │
  │                                                                 │
  │  They appear as:                                               │
  │    - Colored squiggles under the relevant code                 │
  │    - Signs in the gutter (E / W / H / I)                       │
  │    - Virtual text at end of line (if not toggled off)          │
  │    - Items in :Trouble diagnostics                             │
  │    - Accessible via <leader>df (diagnostic float)              │
  │    - Accessible via <leader>D (Snacks buffer diagnostics)      │
  └─────────────────────────────────────────────────────────────────┘
           │
           ▼
  You see the diagnostics. Fix the issues. Save. Diagnostics update.
```

The key insight: **linter diagnostics and LSP diagnostics live in the same place**.
When you have both `ruff` (linter) and `pyright` (LSP) running on a Python file,
their diagnostics are merged in the same gutter, same virtual text, same Trouble
window. This is intentional — you shouldn't need to care where a diagnostic came
from. A problem is a problem.

You can distinguish the source by looking at the diagnostic float (`<leader>df`),
which shows the source name in brackets like `[ruff]` or `[pyright]`.

### Side-by-Side: Formatting vs Linting

```
  ┌─────────────────────────────┬──────────────────────────────────┐
  │       FORMATTING             │           LINTING                │
  │       conform.nvim           │           nvim-lint              │
  ├─────────────────────────────┼──────────────────────────────────┤
  │ Modifies your buffer        │ Never modifies your buffer       │
  │ Makes style decisions       │ Reports quality issues            │
  │ Runs on save or <leader>mp  │ Runs on enter/save/insert leave  │
  │ stop_after_first = pick one │ All linters run simultaneously   │
  │ Output: formatted text      │ Output: diagnostics list         │
  │ Undo-able with u            │ Disappears when issues are fixed │
  │ VSCode: Prettier extension  │ VSCode: ESLint extension         │
  └─────────────────────────────┴──────────────────────────────────┘
```

---

## 3. conform.nvim Deep Dive

### The `<leader>mp` Keymap

The keymap is defined at the bottom of
`dotfiles/.config/nvim/lua/de100/plugins/formatting.lua`:

```lua
vim.keymap.set({"n", "v"}, "<leader>mp", function()
    conform.format({
        lsp_format = "fallback",
        async = false,
        timeout_ms = 1500
    })
end, {desc = "Format file or range"})
```

Several things here worth understanding carefully:

**`{"n", "v"}` — it works in both Normal and Visual mode.** This is important.

- In **Normal mode**, `<leader>mp` formats the **entire buffer**. Every line gets
  processed through the formatter. This is "Format Document" in VSCode terms.

- In **Visual mode**, `<leader>mp` formats only the **selected range**. This is
  the Neovim equivalent of "Format Selection" in VSCode (`Ctrl+K Ctrl+F`). Not
  all formatters support range formatting — prettier and biome do, stylua does not
  (it always formats the whole file). conform handles this gracefully; if the
  formatter doesn't support ranges, it falls back to whole-file formatting.

**`async = false`** means the format call blocks. The function doesn't return until
formatting completes or the timeout expires. This is intentional for the manual
trigger — you want to see the formatted result before your next keystroke.

**`timeout_ms = 1500`** is a 1.5-second hard limit. If the formatter takes longer
than that, conform kills it and returns an error notification. For most files this
is extremely generous — biome and prettierd typically respond in under 100ms.

**`lsp_format = "fallback"`** means: "if no external formatter is configured for
this filetype, fall back to asking the LSP server to format." This covers the edge
cases like `gdscript` (GDScript/Godot) and `cs` (C#) where we have an LSP but
haven't configured an external formatter.

### How to Use It in Practice

```
-- Scenario 1: Format a whole TypeScript file
-- Cursor anywhere in Normal mode in src/App.tsx
-- Press: <leader>mp
-- Conform checks filetype → typescript → finds biome-check → runs it

-- Scenario 2: Format only one function
-- Select the function using visual mode: V to enter, j/k to select lines
-- With selection active, press: <leader>mp
-- Only the selected lines are formatted

-- Scenario 3: Format a Lua config file
-- In ~/.config/nvim/lua/de100/plugins/some-plugin.lua
-- Press: <leader>mp
-- Conform checks filetype → lua → finds stylua → runs it
-- (stylua always formats the whole file; visual selection is respected
--  where supported but stylua ignores it)

-- Scenario 4: Python file with ruff available
-- Press: <leader>mp
-- conform.get_formatter_info("ruff_format", bufnr).available → true
-- Runs ruff_format (fixes style), then ruff_organize_imports (sorts imports)

-- Scenario 5: File with no configured formatter
-- e.g., a .env file
-- ["_"] = {"trim_whitespace"} runs — trailing spaces are removed
-- That is the minimum intervention on unconfigured filetypes
```

### Formatter Priority and `stop_after_first`

The `web_formatters` variable in the config defines a key concept:

```lua
local web_formatters = {
    "biome-check",
    "prettierd",
    "prettier",
    stop_after_first = true
}
```

`stop_after_first = true` means this is a **priority list**, not a **run all**
list. conform tries each formatter in the order listed and stops as soon as one
is available and successfully runs. If biome-check is available, prettierd and
prettier are never even invoked.

**Why this specific order?**

**biome-check** first because Biome is the fastest. It's written in Rust, starts
in milliseconds, and handles TypeScript/JavaScript/JSON/CSS beautifully. If you're
on a project that uses Biome (has a `biome.json` in the project root), this is
what you want. The `biome-check` variant applies both formatting and safe lint
auto-fixes in one pass.

**prettierd** second because it's a long-running daemon that keeps Prettier warm.
Cold-starting Prettier (Node.js startup + parsing node_modules) takes 300-500ms
on a typical machine. prettierd keeps a Node.js process running in the background,
so subsequent calls take 50-100ms instead. If Biome isn't available on a project,
prettierd gives you Prettier-speed formatting without the cold-start tax.

**prettier** last as the fallback. Exact same output as prettierd (they're the
same underlying tool) but with the Node.js cold-start overhead every time. Still
completely functional, just slightly slower on first use in a session.

**Without `stop_after_first`**, listing multiple formatters means ALL run in
sequence. That makes sense for Go (run `goimports` THEN `gofumpt`) or for Python
(run `ruff_format` THEN `ruff_organize_imports`). It's intentional when you want
a pipeline of transforms where each step builds on the previous.

Here's the mental model for when to use each mode:

```
stop_after_first = true  →  "I have multiple tools that do the SAME job,
                              pick the best available one on this machine"

                              JS/TS:   biome-check OR prettierd OR prettier

no stop_after_first      →   "These tools do DIFFERENT jobs, all must run"

                              Go:     goimports (fix imports) + gofumpt (style)
                              Python: ruff_format (style) + ruff_organize_imports
```

### `format_after_save` and Why It's Async

The config has:

```lua
format_after_save = {lsp_format = "fallback"},
```

This enables automatic formatting every time you save a file — the Neovim
equivalent of VSCode's `"editor.formatOnSave": true`. The `lsp_format = "fallback"`
option here works identically to the manual trigger.

`format_after_save` (note: **after** save, not before) runs asynchronously. The
save completes immediately, and the formatted version is applied to the buffer
shortly after. You'll notice a tiny flicker as the changes land. This is the
deliberate tradeoff for not blocking your save operation.

The reason "after" is preferred over "before" (there's also a `format_on_save`
option for synchronous before-save formatting): blocking on slow formatters makes
the save feel laggy. With `format_after_save`, `Ctrl+S` always returns instantly
and the format happens in the background.

**Disabling format on save for a specific buffer** — sometimes you're working with
legacy code that wasn't formatted and you don't want to muddy the git diff. You
can disable it per buffer:

```lua
-- Set interactively in command mode, or put in .nvim.lua at project root:
vim.b.disable_autoformat = true
```

You'd also need to check that flag in an autocmd (or add a toggle keybinding —
Exercise #2 at the end of this chapter walks you through it).

### How conform Finds Formatters

When conform tries to run `biome-check`, where exactly does it look?

```
  Search order for formatter binaries:
  ─────────────────────────────────────────────────────────────────

  1. Project-local node_modules (for JS ecosystem tools)
     ./node_modules/.bin/biome
     ./node_modules/.bin/prettier
     → Checked first for JS tools
     → Ensures project-pinned versions are used
     → package.json "biome": "^1.8.0" → that exact version runs

  2. Mason bin directory
     ~/.local/share/nvim/mason/bin/biome
     ~/.local/share/nvim/mason/bin/prettierd
     → Added to PATH when Neovim starts
     → Mason-installed tools are always visible here

  3. System PATH
     /usr/local/bin/biome
     /usr/bin/prettier
     → Standard Unix executable search path
     → Global npm installs, Homebrew, apt installs land here

  4. Tool-specific config discovery (affects behavior, not binary)
     Biome reads biome.json walking up the directory tree.
     Prettier reads .prettierrc from the closest ancestor.
     This affects which CONFIG is used, not which binary.
```

You can inspect exactly what conform finds with `:ConformInfo` — covered in
depth in the Troubleshooting section.

### Injected Language Formatting

This is a power feature that most people don't know about. Consider this Python
code:

```python
def get_active_users(conn):
    return conn.execute("""
        SELECT id,name,email FROM users WHERE active=1 ORDER BY name
    """).fetchall()
```

The SQL inside that string is technically Python string content — but it's also
SQL, and it would be nice to format it like SQL. Conform supports "injected
language formatting" for exactly this case.

When Treesitter parses the Python file, it recognizes certain string patterns as
embedded SQL and creates an injected language region. Conform can detect these
regions and apply the appropriate formatter to each one independently.

The formatted result:

```python
def get_active_users(conn):
    return conn.execute("""
        SELECT
            id,
            name,
            email
        FROM users
        WHERE active = 1
        ORDER BY name
    """).fetchall()
```

The Python outer structure is unchanged; only the SQL content inside the string
was reformatted.

To enable injected formatting you'd pass `{ formatters = { injected = {} } }` as
part of your format call options, or configure it per filetype. The current config
doesn't enable this by default because it can be surprising and slow on large files
with many injected regions.

Common injected language scenarios:
- SQL in Python strings (often delimited by triple quotes)
- HTML in JavaScript template literals
- CSS in styled-components
- GraphQL in TypeScript (`gql\`...\`` tagged template literals)

---

## 4. Per-Language Formatter Table

Here's the complete picture of what formatter runs for each language, why it was
chosen, and how to install it.

| Language | Formatter(s) | Mode | Notes | Install Command |
|---|---|---|---|---|
| JavaScript | biome-check → prettierd → prettier | stop_after_first | Biome fastest; prettierd warm daemon | `:MasonInstall biome prettierd prettier` |
| TypeScript | biome-check → prettierd → prettier | stop_after_first | Same as JS | `:MasonInstall biome prettierd prettier` |
| JSX (React) | biome-check → prettierd → prettier | stop_after_first | `.jsx` files | `:MasonInstall biome prettierd prettier` |
| TSX (React) | biome-check → prettierd → prettier | stop_after_first | `.tsx` files | `:MasonInstall biome prettierd prettier` |
| CSS | biome-check → prettierd → prettier | stop_after_first | Biome now supports CSS formatting | `:MasonInstall biome prettierd prettier` |
| SCSS | biome-check → prettierd → prettier | stop_after_first | Sass; biome-check may skip SCSS | `:MasonInstall prettierd prettier` |
| Less | biome-check → prettierd → prettier | stop_after_first | Less CSS preprocessor | `:MasonInstall prettierd prettier` |
| HTML | biome-check → prettierd → prettier | stop_after_first | HTML formatting via prettier | `:MasonInstall prettierd prettier` |
| JSON | biome-check → prettierd → prettier | stop_after_first | JSON is Biome's sweet spot | `:MasonInstall biome` |
| JSONC | biome-check → prettierd → prettier | stop_after_first | JSON with comments | `:MasonInstall biome` |
| YAML | biome-check → prettierd → prettier | stop_after_first | YAML formatting via prettier | `:MasonInstall prettierd prettier` |
| Markdown | biome-check → prettierd → prettier | stop_after_first | Prettier handles MD very well | `:MasonInstall prettierd prettier` |
| GraphQL | biome-check → prettierd → prettier | stop_after_first | GraphQL document formatting | `:MasonInstall prettierd prettier` |
| Astro | biome-check → prettierd → prettier | stop_after_first | `.astro` component files | `:MasonInstall prettierd prettier` |
| Svelte | biome-check → prettierd → prettier | stop_after_first | `.svelte` single-file components | `:MasonInstall prettierd prettier` |
| Vue | biome-check → prettierd → prettier | stop_after_first | `.vue` single-file components | `:MasonInstall prettierd prettier` |
| Liquid | biome-check → prettierd → prettier | stop_after_first | Shopify Liquid templates | `:MasonInstall prettierd prettier` |
| Lua | stylua | single | The Lua community standard; opinionated | `:MasonInstall stylua` |
| Bash | shfmt | single | Handles bash-specific syntax | `:MasonInstall shfmt` |
| Shell (sh) | shfmt | single | POSIX shell scripts | `:MasonInstall shfmt` |
| Zsh | shfmt | single | Zsh scripts | `:MasonInstall shfmt` |
| C | clang_format | single | Uses project `.clang-format` if present | `:MasonInstall clang-format` |
| C++ | clang_format | single | Same as C | `:MasonInstall clang-format` |
| C# | LSP fallback | lsp | `roslyn.nvim`/Roslyn provides formatting when available | `install_dotnet=true` |
| GDScript | LSP fallback | lsp | Godot's LSP handles formatting | LSP auto-installed |
| Go | goimports → gofumpt | pipeline | `goimports` fixes imports; `gofumpt` adds stricter style | `:MasonInstall goimports gofumpt` |
| Java | google-java-format | single | Google's Java formatter | `:MasonInstall google-java-format` |
| Python | ruff_format + ruff_organize_imports | pipeline (if ruff available) | Fastest option; written in Rust | `:MasonInstall ruff` |
| Python (fallback) | isort → black | pipeline | Classic pipeline when ruff not installed | `:MasonInstall isort black` |
| Rust | rustfmt + LSP fallback | pipeline+lsp | `rustfmt` first; LSP supplements | `rustup component add rustfmt` |
| LaTeX | latexindent | single | LaTeX document formatting | system: `texlive-extra-utils` |
| Zig | zigfmt | single | Official Zig formatter, ships with `zig` | included with zig compiler |
| ALL files | codespell | always | Spell-checks source code for typos | `:MasonInstall codespell` |
| Filetypes with no other formatter | trim_whitespace | fallback | Removes trailing whitespace | built into conform |

### Understanding the `["*"]` and `["_"]` Special Keys

```lua
["*"] = {"codespell"},
["_"] = {"trim_whitespace"}
```

**`["*"]`** runs these formatters on every filetype, IN ADDITION to whatever
filetype-specific formatters are configured. `codespell` is a spell-checker
designed for source code. It understands that code uses abbreviations and
unconventional casing, and only flags common typos like `recieve`, `seperate`,
`teh`, `occured`. It won't touch your variable names unless they contain obvious
misspellings. It's lightweight and runs after the primary formatter.

**`["_"]`** runs ONLY for filetypes that have no other formatters configured.
The underscore key is the "no-formatter fallback." If you open a `.env` file or
a `.txt` file that isn't in `formatters_by_ft`, `trim_whitespace` still runs and
at least ensures no trailing spaces are committed.

### The Python Formatter Function — Dynamic Selection

Python has special treatment because we want `ruff` when available but need to
fall back gracefully to the older isort+black pipeline:

```lua
python = function(bufnr)
    if conform.get_formatter_info("ruff_format", bufnr).available then
        return {"ruff_format", "ruff_organize_imports"}
    end
    return {"isort", "black"}
end,
```

This is a **function** instead of a table. conform supports this — you can pass
a function that receives the buffer number and dynamically returns the formatter
list. This enables runtime decisions based on what's actually available.

`conform.get_formatter_info("ruff_format", bufnr).available` checks whether the
ruff binary can be found from the perspective of the given buffer.

- **If ruff is available**: use `ruff_format` (fast reformatter, written in Rust,
  understands Python semantics) followed by `ruff_organize_imports` (sorts,
  deduplicates, and optimizes imports — similar to `isort` but integrated with
  ruff's semantic understanding of imports).

- **If ruff is not available**: fall back to `isort` (import sorting, the
  long-standing Python standard) followed by `black` (opinionated code formatting,
  which inspired ruff's formatting behavior).

In practice, since mason-tool-installer installs `ruff` automatically, this always
takes the ruff path. The fallback exists for machines where Mason cannot install
tools (air-gapped servers, locked-down CI environments).

---

## 5. Prettier Config Details

### The Configured Arguments

```lua
formatters = {
    prettier = {
        args = {
            "--stdin-filepath", "$FILENAME",
            "--tab-width", "2",
            "--use-tabs", "true",
            "--trailing-comma", "all"
        }
    },
    prettierd = {
        args = {
            "--stdin-filepath", "$FILENAME",
            "--tab-width", "2",
            "--use-tabs", "true",
            "--trailing-comma", "all"
        }
    },
    shfmt = {prepend_args = {"-i", "4"}}
}
```

Let's examine every argument in detail.

### `--stdin-filepath $FILENAME`

Prettier reads source code from stdin — it doesn't open files directly. But it
needs to know the filename to determine which parser to use. A `.ts` file uses
the TypeScript parser. A `.json` file uses the JSON parser. A `.vue` file uses
the Vue parser.

Without `--stdin-filepath`, Prettier sees content on stdin with no filename and
can't determine the right parser. It would either fail or guess incorrectly.

The `$FILENAME` token is a special conform variable. conform substitutes it with
the actual file path of the current buffer before invoking prettier. So if you're
editing `/home/user/project/src/App.tsx`, prettier receives:

```
--stdin-filepath /home/user/project/src/App.tsx
```

This is standard practice for every stdin-based formatter in the ecosystem.

### `--tab-width 2` and `--use-tabs true` — The Accessibility Case for Tabs

This combination surprises people accustomed to spaces-everywhere conventions.
Let's break it down:

**`--use-tabs true`** inserts real ASCII tab characters (`\t`) for indentation
instead of spaces. This is the more accessible option.

Here's why: **tab-width is configurable, spaces are not**. When your code uses
tab characters for indentation, every developer can set their editor to display
tabs at whatever width they find comfortable:

```
Developer A (prefers compact):    editor renders tabs as 2 spaces wide
Developer B (prefers spacious):   editor renders tabs as 4 spaces wide
Developer C (accessibility need): editor renders tabs as 6 spaces wide

All three are looking at the same file. Same tab characters. Different widths.
Nobody has to change the file to accommodate different preferences.
```

With spaces, the file itself enforces a specific visual width. If you use 2-space
indentation, everyone sees 2-space indentation whether they like it or not. You
cannot provide accessibility without modifying the file.

**`--tab-width 2`** doesn't set the number of spaces inserted (we're using tabs,
not spaces). Instead, it sets the *display width* that prettier uses when it
decides whether a line is too long and needs to be broken. Prettier internally
calculates line length for wrapping decisions, and it uses `tab-width` to count
how many characters a tab contributes to that calculation.

So with `--tab-width 2 --use-tabs true`:
- Real tab characters are inserted for indentation
- For the purpose of "does this fit within the print width," each tab counts as 2
- The rendered width on your screen depends on your editor's `tabstop` setting

If you have strong opinions about spaces vs tabs, you can override this with a
project-level `.prettierrc`. See the next section.

### `--trailing-comma all` — Cleaner Diffs

`trailing-comma all` adds a trailing comma after the last item in any multi-line
structure: function parameters, function arguments, array literals, object literals,
destructuring patterns, TypeScript type annotations, and more.

**Without trailing commas:**

```typescript
function createUser(
  name: string,
  email: string,
  role: UserRole  // no trailing comma
) {}
```

Adding a new parameter produces a diff that touches TWO lines:
```diff
   role: UserRole,   ← comma added to old last line
+  preferences: UserPreferences
```

**With `trailing-comma all`:**

```typescript
function createUser(
  name: string,
  email: string,
  role: UserRole,  // trailing comma
) {}
```

Adding a new parameter produces a diff that touches ONE line:
```diff
+  preferences: UserPreferences,
```

The diff is cleaner, easier to review, and `git blame` attributes the original
line correctly.

`all` applies trailing commas everywhere including function parameters (valid
in ES2017+). The older `es5` option only added them in ES5-valid positions.
Since any modern JavaScript/TypeScript project targets ES2017+, `all` is correct.

### How `args` vs `prepend_args` Work

Two different override strategies are shown in the config:

```lua
-- prettier: args is a FULL REPLACEMENT of the command arguments
prettier = {
    args = {
        "--stdin-filepath", "$FILENAME",  -- MUST include this
        "--tab-width", "2",
        "--use-tabs", "true",
        "--trailing-comma", "all"
    }
}

-- shfmt: prepend_args ADDS to the front of conform's default args
shfmt = {
    prepend_args = {"-i", "4"}  -- 4-space indentation
}
```

When you use `args`, you're completely replacing whatever conform would have passed
by default. You're responsible for including everything the formatter needs
(including `--stdin-filepath`).

When you use `prepend_args`, you're adding flags before conform's built-in
defaults. This is safer for formatters where conform already has working default
args and you just want to add one option.

For shfmt, the default args handle stdin/stdout correctly and conform just needs
`-i 4` prepended to set indentation. Using `prepend_args` keeps conform's
stdin handling intact.

### `.prettierrc` Project Override

Here's critically important behavior: **conform respects `.prettierrc`** project
configuration files.

When prettier executes, it performs config file discovery by walking up the
directory tree from the file being formatted until it finds one of:

```
.prettierrc
.prettierrc.json
.prettierrc.yaml
.prettierrc.yml
.prettierrc.toml
.prettierrc.js
.prettierrc.cjs
prettier.config.js
"prettier" key in package.json
```

If any of these exist, their settings **override** the `--tab-width`, `--use-tabs`,
and `--trailing-comma` args you configured in conform. Project-level config wins.

This means:

```json
// .prettierrc in a project root
{
  "tabWidth": 4,
  "useTabs": false,
  "trailingComma": "es5",
  "singleQuote": true,
  "semi": false
}
```

If a project has this file, running `<leader>mp` on a TypeScript file in that
project will use 4-space indentation with spaces. Your editor config becomes the
"global default for projects without .prettierrc" and yields gracefully to projects
that have their own config.

**Debugging which config is active:** In a terminal in the project directory:
```bash
prettier --find-config-path path/to/file.ts
```
This shows which config file prettier found (or `undefined` if none).

### `.prettierignore` Support

Prettier respects `.prettierignore` files. Since conform passes the actual filepath
via `--stdin-filepath`, prettier checks whether that path matches any ignore patterns
and skips formatting if it does.

Common `.prettierignore` contents:
```
# Generated files
dist/
build/
*.min.js
*.min.css
coverage/

# Third-party code
node_modules/
vendor/

# Files with intentional non-standard formatting
*.snap
CHANGELOG.md
```

Format-on-save is safe even in repos with generated files — prettier simply no-ops
on ignored files, and conform sees the unchanged output and makes no modifications
to the buffer.

---

## 6. nvim-lint Deep Dive

### The `<leader>ll` Manual Trigger

```lua
vim.keymap.set("n", "<leader>ll", function() lint.try_lint() end,
               {desc = "Trigger linting for current file"})
```

`lint.try_lint()` runs all configured linters for the current buffer's filetype.
Each runs as an external process, their output gets parsed, and diagnostics are
updated.

When would you use this manually rather than waiting for the auto-trigger?

- **After changing a linter config file** (`.eslintrc`, `ruff.toml`,
  `pyproject.toml`): the linting cache is stale. Force a re-lint.
- **Debugging a linting issue** where you want to see exactly what the linter
  produces right now without saving and re-opening.
- **The auto-triggers didn't fire** — for example, you switched to a buffer that
  was already loaded and BufEnter already fired without linting.

### Auto-Trigger Events

Most filetypes are wired to three autocommand events:

```lua
local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", {clear = true})
vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost", "InsertLeave"}, {
    group = lint_augroup,
    callback = function(args)
        if vim.bo[args.buf].filetype ~= "go" then
            lint.try_lint()
        end
    end
})

vim.api.nvim_create_autocmd("BufWritePost", {
    group = lint_augroup,
    pattern = "*.go",
    callback = function()
        -- Simplified: the real config computes the nearest go.mod/go.work root.
        lint.try_lint("golangcilint", {cwd = computed_go_root})
    end
})
```

**`BufEnter`** fires when you enter (switch to) a buffer, whether it's a new file
or an already-open buffer you're navigating back to. This ensures that when you
open a file, you immediately see any existing linting issues without having to save
first. In VSCode terms: "ESLint runs when you open a file."

**`BufWritePost`** fires after a buffer is written to disk. This is the most
important trigger — it catches any issues introduced by your latest changes.

**`InsertLeave`** fires when you leave Insert mode (pressing Escape or Ctrl+C to
return to Normal mode). This gives near-real-time feedback: you type something,
press Escape to review it, and diagnostics update immediately. It doesn't lint
while you type (that would be extremely noisy), only when you pause.

Combined for most languages: lint when you open a file, lint when you save, and
lint each time you stop typing. Every meaningful editing transition is covered.

Go is intentionally quieter. `gopls` already provides fast diagnostics while you
edit, so `golangci-lint` only runs after saving a `.go` file or when you press
`<leader>ll`. This avoids slow or noisy lint feedback while learning Go.

### How Results Appear as Diagnostics

The result of linting flows through Neovim's native diagnostic system — the same
one LSP servers use. Everything that works for LSP diagnostics works for linter
diagnostics:

```
<leader>df   →  open diagnostic float for the line under cursor
<leader>D    →  show all buffer diagnostics in a Snacks picker
:Trouble diagnostics  →  comprehensive list in Trouble pane
```

The diagnostic severity levels and how linters map to them:

```
vim.diagnostic.severity.ERROR  →  Red   (E in gutter)
vim.diagnostic.severity.WARN   →  Yellow (W in gutter)
vim.diagnostic.severity.INFO   →  Blue  (I in gutter)
vim.diagnostic.severity.HINT   →  Grey  (H in gutter)
```

Linter-specific mappings:
```
shellcheck:  error → ERROR, warning → WARN, info → INFO, style → HINT
ruff:        E (error) → ERROR, W (warning) → WARN, I → INFO, D → HINT
eslint:      2 (error) → ERROR, 1 (warning) → WARN
```

### Per-Language Linter Table

Here's the complete linting setup, what each tool checks, and how to install it:

| Language | Linter(s) | What It Checks | Install |
|---|---|---|---|
| Bash | shellcheck | POSIX compliance, quoting errors, command substitution pitfalls, unbound variables, deprecated syntax | `:MasonInstall shellcheck` |
| Shell (sh) | shellcheck | Same as Bash; applies POSIX shell rules strictly | `:MasonInstall shellcheck` |
| Go | golangci-lint | Secondary meta-linter for deeper checks beyond `gopls`; runs from the nearest `go.mod`/`go.work` root | `:MasonInstall golangci-lint` |
| C | clangtidy | Clang-based: modernization, readability, performance, bugprone, portability | `:MasonInstall clang-tidy` |
| C | cpplint | Google C++ style guide compliance | `:MasonInstall cpplint` |
| C++ | clangtidy | Same as C + C++-specific smart pointer and STL checks | `:MasonInstall clang-tidy` |
| C++ | cpplint | Google C++ style guide | `:MasonInstall cpplint` |
| JavaScript | biomejs | Correctness, suspicious patterns, accessibility, performance, nursery rules | `:MasonInstall biome` |
| JavaScript | eslint_d | Project's `.eslintrc` rules + all installed ESLint plugins | `:MasonInstall eslint_d` |
| TypeScript | biomejs | Same as JS + TypeScript-specific correctness rules | `:MasonInstall biome` |
| TypeScript | eslint_d | ESLint + `@typescript-eslint` rules | `:MasonInstall eslint_d` |
| JSX/TSX | biomejs | React-specific linting rules | `:MasonInstall biome` |
| JSX/TSX | eslint_d | ESLint react/jsx/hooks rules | `:MasonInstall eslint_d` |
| Svelte | biomejs | Svelte component linting | `:MasonInstall biome` |
| Svelte | eslint_d | ESLint svelte plugin rules | `:MasonInstall eslint_d` |
| Lua | luacheck | Unused variables, undefined globals, variable shadowing, accessing undefined fields | `:MasonInstall luacheck` |
| Markdown | markdownlint | Heading levels, list formatting, blank lines, code blocks, link format, line length | `:MasonInstall markdownlint` |
| Markdown | codespell | Spell checking for document prose and code blocks | `:MasonInstall codespell` |
| Python | ruff | 700+ rules: PEP 8, unused imports, f-string issues, type annotations, security (bandit rules) | `:MasonInstall ruff` |
| Python | pylint | Deep static analysis: type inference, naming conventions, complexity, refactoring suggestions | `:MasonInstall pylint` |
| YAML | yamllint | Syntax validation, indentation, line length, truthy value style, duplicate keys | `:MasonInstall yamllint` |

### Running Both biomejs AND eslint_d

For JavaScript/TypeScript files, BOTH `biomejs` and `eslint_d` run simultaneously
(no `stop_after_first` in linting). They check different things:

**Biome** focuses on universal code quality: correctness, performance patterns,
accessibility (A11Y), suspicious code patterns. Biome's rules are built-in and
version-controlled with Biome itself. Zero config needed.

**ESLint** focuses on your project's specific rules: whatever's in `.eslintrc`.
Your team might have 50 custom rules about naming conventions, forbidden APIs,
import order, React best practices, etc. None of that is in Biome.

Running both gives you Biome's universal quality checks PLUS your project's custom
ESLint rules. The overlap (both complain about the same issue) is a minor annoyance
compared to the coverage benefit.

### Understanding eslint_d — The Daemon Architecture

`eslint_d` (ESLint as a daemon) differs from standard ESLint in important ways.

**The cold-start problem:** Regular ESLint starts a Node.js process, loads
`package.json`, resolves all dependencies, discovers and loads `.eslintrc`, loads
and initializes all configured plugins. For a project with 20 ESLint plugins, this
can take 3-5 seconds per lint run. With `InsertLeave` and `BufWritePost` triggers,
that's a 3-5 second delay every time you stop typing or save. Unacceptable.

**eslint_d's solution:** Run as a persistent background daemon. The first run
starts the daemon (takes the same 3-5 seconds). All subsequent runs connect to
the running daemon via a socket and return results in under 100ms.

**The stale config gotcha:** The daemon caches your ESLint configuration. If you
change `.eslintrc` or add a new ESLint plugin, the daemon has a stale version.

Fix: restart the daemon:
```bash
eslint_d restart
# or
eslint_d stop   # daemon restarts automatically on next lint request
```

---

## 7. ftplugin Settings — Per-Language Editor Behavior

### What Are ftplugins?

Ftplugins ("filetype plugins") are Lua files that run automatically when you open
a specific type of file. In this config they live at:

```
dotfiles/.config/nvim/after/ftplugin/<filetype>.lua
```

The `after/` prefix means these files run *after* any built-in Neovim ftplugins
and any plugin-provided ftplugins for the same filetype. Your settings win over
defaults.

These files use `vim.opt_local` instead of `vim.opt`. The `_local` suffix is
critical — it means the setting applies only to the current buffer, not globally.
If you have a Python file and a Go file open in splits, the Python buffer has
4-space settings and the Go buffer has tab settings. They're completely independent.

**VSCode equivalent:** per-language settings in `settings.json`:

```json
{
  "[python]": {
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "editor.rulers": [88]
  },
  "[go]": {
    "editor.tabSize": 4,
    "editor.insertSpaces": false,
    "editor.rulers": [120]
  }
}
```

Same concept. Neovim expresses it as files instead of JSON keys.

### Python: `after/ftplugin/python.lua`

```lua
-- Python: PEP 8 + ruff/black enforce 4 spaces
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.textwidth = 88
vim.opt_local.colorcolumn = "88"
```

**Why 4 spaces?** PEP 8, Python's official style guide, mandates 4 spaces for
indentation. This is enforced by every major Python formatter (black, ruff,
autopep8) and is an unusually strong convention. Python 3 raises a `TabError`
if you mix tabs and spaces in the same file's indentation. With `expandtab = true`,
pressing Tab inserts spaces — mixed indentation is physically impossible.

**`softtabstop = 4`** is the companion setting: when you press Backspace and the
cursor is in indentation that was inserted as spaces, it deletes 4 spaces at once
(treating them as if they were one tab). Without this, Backspace would delete one
space at a time.

**Why 88 columns, not 79?** PEP 8's original line length limit is 79 characters.
This comes from 1970s terminals (80 columns wide, with 1 column reserved for a
line-end marker).

Then `black` (released 2018) changed the default to **88** with the justification:
88 was chosen empirically — it reduces the number of reformatted lines by about
10% compared to 79 while staying comfortable on modern displays.

`ruff_format` follows black's defaults, so 88 is correct for this setup. The rule:
**match your formatter's default** so the colorcolumn reflects what the formatter
enforces.

**What `textwidth` and `colorcolumn` do:**
- `textwidth = 88` — Neovim auto-wraps lines (inserts a newline) when you type
  past column 88. Also used by `gq` to determine wrapping width.
- `colorcolumn = "88"` — draws a vertical line at column 88. Visual guide, no
  automatic behavior. The Neovim equivalent of `"editor.rulers": [88]` in VSCode.

### YAML: `after/ftplugin/yaml.lua`

```lua
-- YAML: parsers reject tab characters
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
```

**Why `expandtab = true` is NON-NEGOTIABLE for YAML:**

The YAML 1.1 and 1.2 specifications explicitly forbid tab characters for
indentation. From the YAML spec: "Tab characters must not be used in indentation,
since different systems treat tabs differently."

This isn't a style preference — it's a hard requirement of the format. If you
indent YAML with tab characters, every YAML parser (PyYAML, js-yaml, libyaml,
Go's yaml.v3) will raise an error. Your Kubernetes manifests won't apply. Your
Ansible playbooks won't run. Your GitHub Actions workflows won't trigger.

`expandtab = true` makes Tab insert spaces, making tab-in-YAML physically
impossible during normal editing.

**Why 2 spaces?** YAML doesn't mandate a specific indentation width — only that
indentation is consistent. But the community has strongly converged on 2 spaces:
- All Kubernetes documentation uses 2 spaces
- Ansible playbooks conventionally use 2 spaces
- GitHub Actions docs use 2 spaces
- `yamllint` checks for 2-space indentation by default
- Prettier formats YAML with 2 spaces

This repo is an Ansible project — Ansible playbooks use 2-space YAML indentation
throughout. This ftplugin makes the editor match.

### JSON and JSONC: `after/ftplugin/json.lua` / `after/ftplugin/jsonc.lua`

```lua
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
```

JSON doesn't technically forbid tabs (the JSON specification is silent on
indentation style) but the universal community convention is 2-space indentation.
Every JSON formatter (Biome, Prettier, `jq`) defaults to 2 spaces. Your
`package.json`, `tsconfig.json`, `biome.json`, `.eslintrc.json` — they all use
2 spaces.

JSONC ("JSON with Comments") is a superset of JSON that allows `//` and `/* */`
comments. Used by TypeScript configuration files, VSCode settings, and other
tooling where JSON's "no comments" rule is inconvenient. Same indentation rules.

### Go: `after/ftplugin/go.lua`

```lua
-- Go: gofmt enforces tabs; allow longer lines per convention
vim.opt_local.expandtab = false
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.textwidth = 120
vim.opt_local.colorcolumn = ""
```

**`expandtab = false`** — Go uses real tab characters for indentation. This is
not optional. `gofmt`, the official Go formatter, always outputs tabs. If you
write Go code with spaces in this editor, formatting will replace them with tabs
on the next `<leader>mp` or save.

`expandtab = false` ensures the editor itself uses real tabs for Go, so the
display stays consistent before and after formatting.

**`tabstop = 4` and `shiftwidth = 4`** control how wide tabs are *displayed*.
This doesn't affect the actual characters — just the visual rendering. 4 is the
Go community default for display width.

**`textwidth = 120`** — Go doesn't have an official line length recommendation.
The Go FAQ says: "There is no line length limit; if a line feels too long, wrap it
and indent with an extra tab." Community practice has converged on around 80-120
as a soft guideline. 120 is common in modern Go projects.

`gofmt` itself never wraps lines — it's formatting-only in other dimensions but
leaves line length entirely to the programmer.

**`colorcolumn = ""`** — empty string explicitly disables the column ruler for Go.
This reflects Go's philosophy: no mandatory line length. A hard column marker would
imply a stricter limit than the language community actually uses.

### Markdown: `after/ftplugin/markdown.lua`

```lua
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"
vim.opt_local.wrap = true
vim.opt_local.textwidth = 0
vim.opt_local.conceallevel = 2
vim.opt_local.colorcolumn = ""
```

Markdown is the most configuration-intensive ftplugin because Markdown is a
prose format, not code. The settings are optimized for comfortable writing.

**`spell = true`** enables Neovim's built-in spell checker. Misspelled words get
a distinct underline. This is the equivalent of VSCode's Code Spell Checker
extension, but built into Neovim.

Useful spell commands:
```
]s        →  jump to next misspelled word
[s        →  jump to previous misspelled word
z=        →  open suggestions for word under cursor
zg        →  add word to personal dictionary (good word)
zw        →  mark word as wrong (add to wrong-words list)
zug       →  undo zg (remove from personal dictionary)
```

Your personal word list lives at `~/.config/nvim/spell/en.utf-8.add`.

**`spelllang = "en_us"`** — American English dictionary. Change to `"en_gb"` for
British English, or set multiple: `vim.opt_local.spelllang = "en_us,de"`.

**`wrap = true`** enables visual (soft) line wrapping. Long paragraphs wrap at
the window edge instead of extending horizontally offscreen. Essential for prose
editing. Press `gj`/`gk` to move by *visual* lines (respecting wrap) instead of
`j`/`k` which move by file lines.

**`textwidth = 0`** disables automatic hard wrapping. With `textwidth = 0`,
Neovim never automatically inserts newlines when you type past any column. You
get visual wrapping (from `wrap = true`) but the file has the actual line lengths
you typed.

This is the modern Markdown convention: write long paragraphs as single lines,
let the renderer handle reflowing. Markdown renderers (GitHub, browsers) reflow
text based on window width regardless of line breaks within a paragraph.

**`conceallevel = 2`** is the most magical setting. With it active:
```
conceallevel = 0:   **bold text**    ← you see the asterisks
conceallevel = 2:    bold text       ← asterisks hidden; text appears bold
```

Links like `[text](url)` display as just `text`. Bold markers disappear but text
appears bold. Italic markers disappear but text appears italic.

If you need to edit the raw syntax (e.g., to fix a link URL), move your cursor
to that line — the concealed characters reappear for the line under the cursor.

**`colorcolumn = ""`** — no column ruler. Prose doesn't have meaningful line
length limits that need a visual marker.

### Rust: `after/ftplugin/rust.lua`

```lua
-- Rust: rustfmt default line length is 100
vim.opt_local.textwidth = 100
vim.opt_local.colorcolumn = "100"
```

**Why 100?** `rustfmt`, the official Rust formatter, uses a default maximum line
width of 100 characters. This is configurable via `rustfmt.toml` with
`max_width = 100`, but 100 is the documented default.

The Rust standard library itself uses 100 columns. The Rust Reference uses 100
columns. Most idiomatic Rust codebases use 100 columns.

100 makes sense for Rust specifically because Rust type signatures can be quite
long — generic bounds, trait implementations, lifetime annotations. At 80 columns,
nearly every meaningful Rust function signature would need to be wrapped in multiple
places. At 100 columns, most fit naturally.

If a Rust project has `max_width = 80` in `rustfmt.toml`, you'd want to override
this ftplugin. Add a `.nvim.lua` in the project root:

```lua
-- .nvim.lua in project root (requires vim.o.exrc = true in your config)
vim.opt_local.textwidth = 80
vim.opt_local.colorcolumn = "80"
```

### C and C++: `after/ftplugin/c.lua` and `after/ftplugin/cpp.lua`

```lua
vim.opt_local.textwidth = 80
vim.opt_local.colorcolumn = "80"
```

**Why 80?** C and C++ have the longest history of any mainstream programming
language (C from 1972, C++ from 1985). The 80-column limit is deeply embedded:

- **The Linux kernel** uses 80 columns as a hard limit. The most influential C
  codebase on earth. Kernel patch submissions are rejected for exceeding 80
  columns (with some exceptions).
- **MISRA C** and **CERT C** safety standards reference 80-column limits.
- **Many embedded systems** have consoles and debugging tools that display at 80
  columns, making 80-column code directly readable on the target system.

For modern C++17/20/23 code with long template metaprogramming expressions, 80
columns can be frustratingly restrictive. Teams often use 100 or 120. You can
override per project via `.nvim.lua`.

`clang_format` doesn't hard-enforce 80 columns — it respects whatever `ColumnLimit`
is set in `.clang-format`. The ftplugin sets the visual ruler; the formatter uses
its own config file.

### Shell Scripts: `after/ftplugin/sh.lua`

```lua
vim.opt_local.textwidth = 80
vim.opt_local.foldenable = false
```

**`textwidth = 80`** — shell scripts often target 80 columns for the same
historical reasons as C. They're frequently reviewed in CI logs, SSH sessions, and
legacy terminals where 80 columns is safely displayable.

**`foldenable = false`** — disables code folding for shell scripts. Neovim's
Treesitter integration creates folds based on syntax tree structure. For shell
scripts, folds tend to be more annoying than helpful:

- Shell functions are usually short (10-30 lines). Rarely worth collapsing.
- `if`/`for`/`while` blocks are frequently 3-10 lines — too short to benefit.
- Accidentally pressing `zc` (close fold) while editing a shell script is
  confusing if you don't realize a section just collapsed.

With `foldenable = false`, fold commands still work if you explicitly enable them,
but the buffer starts with folding off.

### SQL: `after/ftplugin/sql.lua`

```lua
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
vim.opt_local.textwidth = 120
```

SQL uses 2-space indentation (matching YAML/JSON convention) but a wider 120-column
limit because SQL queries can be naturally long, especially with CTEs and complex
joins. SQL files are also usually accessed via database clients that handle their
own display wrapping.

### Creating Your Own ftplugin

Adding per-language behavior for any language is straightforward. Create a file:

```
~/.config/nvim/after/ftplugin/<filetype>.lua
```

Find the correct filetype name with `:set filetype?` while that file type is open.

**Example: TOML files** (Cargo.toml, pyproject.toml, etc.):

```lua
-- ~/.config/nvim/after/ftplugin/toml.lua
-- TOML: 2-space indentation convention
vim.opt_local.expandtab = true
vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2
```

**Example: adding buffer-local keymaps in an ftplugin:**

```lua
-- ~/.config/nvim/after/ftplugin/python.lua (additional content)
-- Run current file with F5
vim.keymap.set("n", "<F5>", ":!python3 %<CR>", {
    buffer = true,  -- scoped to this buffer only
    silent = true,
    desc = "Run Python file"
})
```

The `buffer = true` option scopes keymaps to the current buffer. When you switch
to a non-Python buffer, these keymaps are inactive.

---

## 8. Ansible LSP — ansiblels and ansible-lint

### Why Ansible Needs a Dedicated LSP

This is an Ansible repository. YAML is the language Ansible playbooks are written
in, but they're not just YAML — they have a specific semantic layer on top:

- **Module names** like `ansible.builtin.copy`, `community.general.git` are the
  "functions" of Ansible. There are thousands of them across official and
  community collections.
- **Module parameters** — each module has its own parameter schema. `copy` has
  `src`, `dest`, `mode`, `owner`. `template` has `src`, `dest`, `backup`.
  Wrong parameter names silently do nothing; typos cause failures.
- **Conditionals** — `when:` expressions use Jinja2 templating with Ansible's
  built-in variables and registered variables from previous tasks.
- **Roles and includes** — `include_tasks`, `import_role`, `include_vars`
  reference files that need to be found and validated.

A generic YAML LSP (`yamlls`) knows YAML syntax but doesn't understand any of this.
`ansiblels` speaks Ansible fluently.

### How ansiblels Is Configured

`ansiblels` is configured in two places in the LSP config:

```lua
-- In mason-lspconfig.setup: ensure the LSP binary is installed
ensure_installed = {
    "ansiblels",
    -- ...
}

-- In lsp.lua: actually enable the LSP for Neovim
local servers = {
    "angularls", "ansiblels", "astro", "bashls", "biome", "clangd",
    -- ...
}
for _, server in ipairs(servers) do
    pcall(vim.lsp.enable, server)
end
```

The two-step setup (install via Mason, enable via lspconfig) is the same pattern
used for all LSPs in this config. Mason handles installation; lspconfig handles
configuration and activation.

`ansiblels` provides:
- **Completions** for module names, parameter names, and Jinja2 variables
- **Hover documentation** (`K`) for any module: full docs including parameter
  descriptions, examples, and return values
- **Go-to-definition** for included files, imported roles, and variable files
- **Diagnostics** for syntax errors and invalid module parameters
- **Signature help** for module parameters (shows which params are required)

### yaml.ansible Filetype Detection

`ansiblels` activates on files with the `yaml.ansible` filetype. This is distinct
from plain `yaml`. Neovim (and `ansiblels` itself) uses several heuristics to
detect Ansible files:

1. **Directory structure** — files in directories named `tasks/`, `handlers/`,
   `roles/`, `playbooks/`, `group_vars/`, `host_vars/`
2. **Content patterns** — files containing `hosts:`, `tasks:`, `become:`,
   `vars:` at the top level
3. **Explicit extension** — some setups use `.ansible.yml` extension

To check what filetype Neovim detected:
```
:set filetype?
```

For Ansible playbooks in this repo, you should see `yaml.ansible`. If you see
plain `yaml`, force it:

```
:set filetype=yaml.ansible
```

Or add a vim modeline to the top of the file:
```yaml
# vim: ft=yaml.ansible
---
- name: Setup development environment
  hosts: localhost
```

The modeline approach is persistent — every time you open the file, it sets the
filetype correctly.

### ansible-lint Integration

`ansible-lint` is installed via the Mason tool installer:

```lua
ensure_installed = {
    "ansible-lint",
    -- ...
}
```

`ansible-lint` is a purpose-built linter for Ansible playbooks. It checks:
- **Best practices** — using `ansible.builtin.` prefix, proper task naming
- **Deprecated syntax** — old module names, old loop syntax (`with_items` vs `loop`)
- **Idempotency hints** — patterns that might not be idempotent
- **Security** — hardcoded passwords, world-writable file modes
- **Style** — task naming conventions, YAML formatting in Ansible context

`ansiblels` integrates `ansible-lint` directly — it runs `ansible-lint` as a
subprocess and surfaces the results as LSP diagnostics. This means Ansible files
get a two-layer diagnostic system:
1. **ansiblels LSP diagnostics** — module parameter validation, syntax errors
2. **ansible-lint via ansiblels** — best practices, deprecated syntax, style

Both appear in the same diagnostic interface (gutter signs, virtual text,
`<leader>df` float), with source `[ansiblels]`.

### YAML Formatting for Ansible Playbooks

When you press `<leader>mp` on an Ansible playbook YAML file, conform runs the
web_formatters chain (biome-check → prettierd → prettier) because the filetype
maps to the `yaml` formatter bucket.

Important: **Prettier formats YAML structure but has no awareness of Ansible
semantics.** It fixes indentation, removes unnecessary quotes, normalizes spacing
— but it doesn't know that `- name:` is an Ansible task name or that `when:`
requires Jinja2 expression syntax. The content remains semantically yours; only
the YAML style is touched. This is correct — style and semantics are separate
concerns.

### Practical Workflow for Ansible Files

```
1. Open a playbook
   nvim playbooks/setup-neovim.yml

2. Check the detected filetype
   :set filetype?
   → Should show: yaml.ansible

3. If plain yaml, force the correct filetype
   :set filetype=yaml.ansible

4. LSP completions while editing
   In Insert mode, type: - ansible.
   → Completion menu shows all ansible.builtin.* and collection modules

5. Module documentation on hover
   Move cursor to: ansible.builtin.copy
   Press: K
   → Shows full module documentation inline

6. Diagnostic information
   Look for E/W signs in the gutter
   Press: <leader>df   → Float for current line's diagnostic
   Press: <leader>D    → All buffer diagnostics in Snacks picker

7. Format the YAML structure
   Press: <leader>mp
   → Runs prettierd or prettier on the YAML content
   → YAML style normalized; Ansible content unchanged

8. Manual lint trigger
   Press: <leader>ll
   → Triggers yamllint (for yaml files via nvim-lint)
   → ansiblels also triggers its own linting via LSP
```

### Common ansiblels Issues

**ansiblels not finding modules:**
ansiblels needs Ansible and any required collections installed in the Python
environment where it's running:

```bash
# Check what Python environment ansiblels uses
which ansible
ansible --version

# Install a missing collection
ansible-galaxy collection install community.general

# If using a virtualenv, activate it before launching Neovim
source ~/.venv/bin/activate && nvim
```

**ansible-lint not running:**
```bash
which ansible-lint
ansible-lint --version
# If missing:
pip install ansible-lint
# or: :MasonInstall ansible-lint
```

---

## 9. Troubleshooting

### `:ConformInfo` — Your First Debugging Tool

When formatting isn't working, `:ConformInfo` is the first command to run. It
opens a buffer showing the complete state of conform for the current buffer:

```
vim.filetype = typescript
Formatters for this buffer:
  biome-check: command="/home/user/.local/share/nvim/mason/bin/biome",
               available: true
  prettierd:   command="/home/user/.local/share/nvim/mason/bin/prettierd",
               available: true
  prettier:    command="/home/user/.local/share/nvim/mason/bin/prettier",
               available: true

All configured formatters:
  stylua:       command="stylua",        available: true
  shfmt:        command="shfmt",         available: true
  ruff_format:  command="ruff",          available: true
  clang_format: command="clang-format",  available: false (not executable)
```

The `available: true/false` tells you definitively whether a binary can be found.
The `command=` path shows exactly which binary will be used.

Common patterns to look for:

```
available: false (not executable)
  → Binary not found anywhere. Install it via Mason.

available: false (not configured)
  → The filetype is not in formatters_by_ft.

available: true but nothing happens
  → Check async/timeout issues. Try :lua require("conform").format({async=false})
```

### "No Formatter Found" — Diagnosis Flow

```
Step 1: Run :ConformInfo
        → Check if any formatter shows "available: true" for your filetype

Step 2: If no formatters listed for this filetype:
        → Run :lua print(vim.bo.filetype) to confirm the exact filetype name
        → If the filetype is unusual, it may not be in formatters_by_ft

Step 3: If formatters listed but all "available: false":
        → Install them: :MasonInstall biome prettierd prettier
          (or whatever formatters your language needs)

Step 4: If "available: true" but nothing happens:
        → Check :messages for any error output
        → Try increasing timeout: conform.format({async=false, timeout_ms=5000})

Step 5: If there is a timeout error:
        → The formatter ran but took too long (>1500ms)
        → Switch to prettierd (daemon is faster after warm-up)
        → Increase timeout_ms in the keymap if needed
```

### Formatter Installed But Not Found — PATH Debugging

Sometimes Mason shows a tool as "installed" but `:ConformInfo` shows it as
"not executable." The disconnect is usually PATH-related.

**Verify Mason's bin directory:**
```bash
ls ~/.local/share/nvim/mason/bin/ | grep prettier
```
You should see `prettier`, `prettierd`, etc.

**Verify PATH from inside Neovim:**
```
:!echo $PATH
```
Mason's bin directory (`~/.local/share/nvim/mason/bin`) should appear.

**Test the binary directly:**
```
:!which prettierd
```
If "not found," the PATH issue is confirmed. Mason's init.lua adds its bin to
PATH automatically — verify Mason is loading with `priority = 100` and
`lazy = false`.

**Reinstall the tool:**
```
:MasonUninstall prettierd
:MasonInstall prettierd
```
This often fixes corrupted or incomplete installations.

### Formatting Conflicts Between LSP and conform

The most common conflict: an LSP server provides formatting AND conform has an
external formatter configured. Both might fire on save.

The config handles this with `lsp_format = "fallback"` everywhere:

```lua
default_format_opts = {lsp_format = "fallback"},
format_after_save = {lsp_format = "fallback"},
```

`"fallback"` means: "only use LSP formatting if no conform formatter is available
for this filetype." Since TypeScript has `biome-check → prettierd → prettier`
configured, at least one will usually be available, so the TypeScript LSP never
formats.

**If you're experiencing double-formatting** (the buffer reformats twice on save),
disable LSP formatting for the specific server in `lsp.lua`:

```lua
vim.lsp.config("vtsls", {
    on_attach = function(client, bufnr)
        -- Disable LSP formatting — conform handles it
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end
})
```

Or the cssls config in this repo already shows the pattern with `init_options`:

```lua
vim.lsp.config("cssls", {
    init_options = {provideFormatter = false},
})
```

### Diagnosing nvim-lint Issues

There's no `:LintInfo` command (unlike conform), but you can diagnose:

**Is the linter binary available?**
```
:!which shellcheck
:!which ruff
:!which eslint_d
:!which luacheck
```

**Is the correct filetype being used?**
```
:lua print(vim.bo.filetype)
```
nvim-lint looks up `linters_by_ft[<this filetype>]`. If the filetype doesn't
match an entry, no linting happens.

**Is linting triggering at all?** Add a temporary notification:
```lua
-- In linting.lua, temporarily:
callback = function()
    vim.notify("Linting: " .. vim.bo.filetype, vim.log.levels.INFO)
    lint.try_lint()
end
```
Remove the debug line when done.

**Linting fires but no diagnostics appear:**
The linter probably found nothing wrong (correct!) OR the linter requires a config
file. Common examples:
- `eslint_d` needs an `.eslintrc` in the project
- `luacheck` benefits from a `.luacheckrc` with `globals = {"vim"}`
- `golangci-lint` uses `.golangci.yml` for rule configuration

**ESLint_d showing stale results after config change:**
```bash
eslint_d stop   # kills the daemon; restarts automatically on next lint
```

### Slow Formatting — Diagnostics

**Test formatter speed in terminal:**
```bash
# Time biome
time echo "const x = 1" | biome check --stdin-filepath test.ts

# Time prettierd (second call should be much faster — daemon is warm)
time echo "const x = 1" | prettierd test.ts  # first call: cold start
time echo "const x = 1" | prettierd test.ts  # second call: daemon warm

# Time ruff
time echo "x=1" | ruff format -
```

**Typical timing expectations:**
```
biome:     first call ~10-50ms, subsequent ~5-20ms
prettierd: first call ~500-800ms (starts daemon), subsequent ~30-100ms
prettier:  every call ~300-600ms (cold start each time)
ruff:      every call ~10-50ms
stylua:    every call ~5-20ms
shfmt:     every call ~5-20ms
black:     every call ~300-600ms
```

**Increasing the timeout:**
```lua
-- In formatting.lua, increase the timeout in <leader>mp:
conform.format({
    lsp_format = "fallback",
    async = false,
    timeout_ms = 5000  -- 5 seconds instead of 1.5
})
```

### Mason Install Reference

Quick reference for installing every tool used in this chapter:

```
-- Format tools
:MasonInstall biome prettierd prettier stylua shfmt clang-format
:MasonInstall goimports gofumpt ruff black isort google-java-format codespell

-- Lint tools
:MasonInstall shellcheck golangci-lint cpplint eslint_d luacheck
:MasonInstall markdownlint yamllint pylint ansible-lint

-- Install everything at once:
:MasonInstall biome prettierd prettier stylua shfmt clang-format goimports gofumpt ruff black isort codespell shellcheck golangci-lint cpplint eslint_d luacheck markdownlint yamllint pylint ansible-lint
```

If you ran the Ansible playbook for this repo, `mason-tool-installer` handles
most of this automatically on Neovim startup (with a 3-second delay). The
`:MasonInstall` commands are the manual fallback.

---

## 10. Quick Reference

### All Formatting and Linting Keymaps

| Keymap | Mode | Action | Plugin |
|---|---|---|---|
| `<leader>mp` | Normal | Format entire buffer | conform.nvim |
| `<leader>mp` | Visual | Format selected range only | conform.nvim |
| `<leader>ll` | Normal | Manually trigger linting | nvim-lint |
| `<leader>df` | Normal | Open diagnostic float for current line | built-in diagnostic |
| `<leader>D` | Normal | All buffer diagnostics in Snacks picker | Snacks + diagnostic |
| `<leader>lv` | Normal | Toggle LSP virtual text on/off | LSP config |
| `<leader>li` | Normal | Toggle inlay hints on/off | LSP config |
| `]s` | Normal | Jump to next misspelled word | built-in spell (Markdown) |
| `[s` | Normal | Jump to prev misspelled word | built-in spell (Markdown) |
| `z=` | Normal | Show spelling suggestions for word under cursor | built-in spell |
| `zg` | Normal | Add word to personal dictionary | built-in spell |
| `zw` | Normal | Mark word as wrong | built-in spell |

### All Relevant Commands

| Command | What It Does |
|---|---|
| `:ConformInfo` | Show formatter status, availability, and paths for current buffer |
| `:ConformDisable` | Disable format_after_save for this session |
| `:ConformEnable` | Re-enable format_after_save |
| `:Mason` | Open Mason package manager UI |
| `:MasonInstall <name>` | Install a specific tool |
| `:MasonUninstall <name>` | Remove a specific tool |
| `:MasonUpdate` | Update all installed Mason packages |
| `:Trouble diagnostics` | Open Trouble pane with all diagnostics |
| `:checkhealth conform` | Health check for conform.nvim |
| `:set filetype?` | Check current buffer's filetype |
| `:lua print(vim.bo.filetype)` | Same check via Lua |
| `:lua print(vim.fn.stdpath("data"))` | Show Neovim data dir (Mason installs here) |
| `:!which <binary>` | Check if a binary is in PATH from Neovim |
| `:messages` | Show recent notification messages |
| `:lua vim.diagnostic.open_float()` | Open diagnostic float (same as `<leader>df`) |
| `:lua vim.diagnostic.setloclist()` | Send all diagnostics to location list |

### Formatter Decision Quick Reference

```
Which formatter runs on save for my filetype?

JavaScript/TypeScript/JSX/TSX:
  Has biome in PATH?  → biome-check
  Has prettierd?      → prettierd
  Has prettier?       → prettier
  None?               → no formatting (error logged)

CSS/SCSS/Less/HTML/JSON/YAML/Markdown/GraphQL:
  Same priority chain: biome-check → prettierd → prettier
  (biome-check skips filetypes it doesn't support; chain continues)

Lua:          stylua
Shell (bash/sh/zsh):  shfmt (4-space indentation)
C/C++:        clang_format (uses .clang-format project config if present)
Go:           goimports THEN gofumpt (both run, in sequence)
Python:       ruff available? → ruff_format THEN ruff_organize_imports
              ruff missing?   → isort THEN black
Rust:         rustfmt (then LSP as fallback)
C#/GDScript:  LSP provides formatting (fallback mode)

Any filetype:           codespell also runs (spell-checks identifiers)
No other formatter:     trim_whitespace (removes trailing spaces)
```

### Per-Language ftplugin Summary Table

| Language | Indent | Tab Chars? | Line Limit | Spell | Wrap | Other |
|---|---|---|---|---|---|---|
| Python | 4 spaces | No | 88 col | Off | Off | softtabstop=4 |
| YAML | 2 spaces | No | None | Off | Off | YAML FORBIDS tabs |
| JSON | 2 spaces | No | None | Off | Off | |
| JSONC | 2 spaces | No | None | Off | Off | |
| Go | 4-wide tabs | Yes | 120 col | Off | Off | colorcolumn="" |
| Markdown | — | — | None | On (en_us) | On (soft) | conceallevel=2 |
| Rust | — | — | 100 col | Off | Off | |
| C | — | — | 80 col | Off | Off | |
| C++ | — | — | 80 col | Off | Off | |
| Shell | — | — | 80 col | Off | Off | foldenable=false |
| SQL | 2 spaces | No | 120 col | Off | Off | |

### Linting Auto-Trigger Events Summary

```
BufEnter     →  lint fires when you enter/open any buffer
BufWritePost →  lint fires after every save
InsertLeave  →  lint fires each time you leave Insert mode
<leader>ll   →  manual trigger any time in Normal mode
```

---

## 11. Exercises

Do these in order. Each takes 5-15 minutes. Don't skip them — reading and doing
are different activities, and muscle memory only comes from the doing.

---

### Exercise 1: Format a File and Watch the Diff

**Goal:** Understand what formatting actually does, verify it's working, and
practice undoing it.

**Steps:**

1. Create a test TypeScript file with intentionally messy formatting:
   ```bash
   nvim /tmp/test-conform.ts
   ```

2. In Insert mode (`i`), paste this code exactly as written (bad style included):
   ```typescript
   const greet=(name:string,greeting:string)=>{
   return greeting + " " + name
   }
   const users=["alice","bob","charlie",]
   function processUser(   user : { name: string, email: string }   ) {
   console.log(user.name)
       console.log(user.email)
   }
   export {greet,processUser}
   ```

3. Press Escape. Save with `Ctrl+S`. Watch what happens.
   If `format_after_save` is working, the file reformats automatically within
   about a second. If nothing changes, continue to step 4.

4. Try the manual trigger: press `<leader>mp` in Normal mode.

5. Run `:ConformInfo` to see which formatter was used and confirm its path.

6. Press `u` to undo the formatting. The messy version returns.

7. Press `Ctrl+r` to redo. Toggle back and forth a few times to feel the undo
   history. Formatting is just a reversible buffer change.

**What to observe:**
- Was indentation normalized?
- Were the spaces around `:` in type annotations fixed?
- Did the trailing comma in the array stay (it should — `trailing-comma all`)?
- Did the spacing around the arrow function get fixed?

**Troubleshooting:** If `:ConformInfo` shows all formatters as `available: false`,
run `:MasonInstall biome prettierd prettier` and wait for installation to complete,
then try again.

---

### Exercise 2: Range Formatting with Visual Mode

**Goal:** Learn to format a specific portion of a file without touching the rest.

**Steps:**

1. Create a TypeScript file where the top is messy and the bottom is clean:
   ```bash
   nvim /tmp/test-range.ts
   ```

2. Paste this content:
   ```typescript
   function messyFunction(x:number,y:number,z:number) {
   return x+y+z
   }

   // The function below is already formatted — do not touch it
   function cleanFunction(
     value: number,
     multiplier: number = 1.0,
   ): number {
     return value * multiplier;
   }
   ```

3. Move your cursor to line 1 with `gg`.

4. Enter Visual Line mode with `V`.

5. Select lines 1-3 (the messy function): press `2j` to extend down two lines.

6. With the selection active (you'll see highlighting), press `<leader>mp`.

7. Examine the result: the top function should be reformatted. The comment and
   clean function below should be unchanged.

**What you're learning:** The `{"n", "v"}` mode specification in the keymap
makes `<leader>mp` context-aware. The same key does different things depending
on whether you have a selection active.

**Bonus:** Try the same exercise in a Go file. Go uses `goimports + gofumpt`
which don't support range formatting — watch what happens when you select a range
and format it. The whole file formats (gofmt's behavior), but only lines that
were actually different change in the diff.

---

### Exercise 3: Observe Linting Diagnostics Live

**Goal:** Trigger real linting diagnostics, navigate them, fix them, watch them
disappear.

**Steps:**

1. Create a Python file with intentional issues:
   ```bash
   nvim /tmp/test-lint.py
   ```

2. Paste this code (it has several problems):
   ```python
   import os
   import sys
   import json  # unused — ruff will catch this

   def calculate(x, y):
       result = x + y
       unused_variable = "this is never used"  # ruff catches this
       return result

   # Shadowing the built-in 'list' function
   def list(items):
       return items

   def greet(name):
       return "Hello " + name
   ```

3. Save with `Ctrl+S`. Wait one second for lint to trigger on `BufWritePost`.

4. Look at the gutter on the left. You should see `W` or `E` signs on problem
   lines.

5. Move your cursor to the `import json` line.

6. Press `<leader>df` to open the diagnostic float. Read the full message.
   Note the source in brackets (should say `[ruff]` or `[pylint]`).

7. Press `<leader>D` to see all buffer diagnostics in the Snacks picker.
   Browse through them with `j`/`k`. Press Escape to close.

8. Press `<leader>ll` to manually re-trigger linting.

9. Fix the unused import: delete line 3 (`import json`). Save. Watch the
   `import json` diagnostic disappear.

10. Fix the unused variable: rename `unused_variable` to `_unused_variable`
    or just delete that line. Save and observe.

**What you're learning:** Diagnostics are live, update when you fix issues,
and are navigable through the same interface as LSP errors. The distinction
between linter diagnostics (`[ruff]`) and LSP diagnostics (`[pyright]`) is
visible in the float.

---

### Exercise 4: Explore ftplugin Differences Between Languages

**Goal:** Experience how editor settings change automatically per language, and
verify the isolation between buffers.

**Steps:**

1. Open a Python file (or create one):
   ```bash
   nvim /tmp/ftplugin-test.py
   ```

2. Check the current settings:
   ```
   :set expandtab? tabstop? shiftwidth? textwidth? colorcolumn?
   ```
   Expected: `expandtab`, `tabstop=4`, `shiftwidth=4`, `textwidth=88`,
   `colorcolumn=88`

3. You should see a vertical line at column 88. If your colorscheme highlights
   `colorcolumn`, it's visible.

4. Open a YAML file in a vertical split:
   ```
   :vsplit /tmp/ftplugin-test.yaml
   ```

5. In the YAML buffer, check again:
   ```
   :set expandtab? tabstop? shiftwidth? colorcolumn?
   ```
   Expected: `expandtab`, `tabstop=2`, `shiftwidth=2`, and `colorcolumn=` (empty)

6. Open a Go file in another split:
   ```
   :vsplit /tmp/ftplugin-test.go
   ```

7. Check Go settings:
   ```
   :set expandtab? tabstop? colorcolumn?
   ```
   Expected: `noexpandtab` (real tabs), `tabstop=4`, and `colorcolumn=` (empty)

8. In the Go buffer, press `i` (Insert mode), then Tab. You're inserting a real
   tab character. Press Escape.

9. Switch back to Python with `Ctrl+W h`. Tab in Python inserts spaces.

10. Open a Markdown file:
    ```
    :vsplit /tmp/ftplugin-test.md
    ```
    Check:
    ```
    :set spell? wrap? conceallevel?
    ```
    Expected: `spell`, `wrap`, `conceallevel=2`

**What you're learning:** Buffer-local settings mean each language gets correct
editor behavior automatically, and they don't interfere with each other. The
settings change as you navigate between buffers — no manual configuration needed
per file.

---

### Exercise 5: Write Your Own ftplugin

**Goal:** Add per-language editor settings for a language without an existing
ftplugin, and wire up a formatter for it.

**Steps:**

1. Check which ftplugins already exist:
   ```bash
   ls ~/.config/nvim/after/ftplugin/
   ```

2. We'll add one for TOML files (`Cargo.toml`, `pyproject.toml`, `biome.json`-
   style configs). First verify Neovim's filetype for TOML:
   ```bash
   nvim /tmp/test-check.toml
   ```
   Inside Neovim:
   ```
   :set filetype?
   ```
   It should show `toml`.

3. Exit Neovim (`:q`) and create the ftplugin:
   ```bash
   nvim ~/.config/nvim/after/ftplugin/toml.lua
   ```

4. Write these settings (following YAML/JSON convention for config files):
   ```lua
   -- TOML: 2-space indentation is the community convention
   -- (Cargo.toml, pyproject.toml, stylua.toml, etc.)
   vim.opt_local.expandtab = true
   vim.opt_local.tabstop = 2
   vim.opt_local.shiftwidth = 2
   vim.opt_local.softtabstop = 2
   vim.opt_local.textwidth = 0     -- TOML has no line length standard
   vim.opt_local.colorcolumn = ""  -- No column ruler
   ```

5. Save with `Ctrl+S` and quit with `:q`.

6. Open a TOML file to test — this repo has one:
   ```bash
   nvim ~/mfansible/dotfiles/.config/nvim/stylua.toml
   ```
   (Or any `.toml` file.)

7. Verify your settings are active:
   ```
   :set expandtab? tabstop? shiftwidth?
   ```
   Should show `expandtab`, `tabstop=2`, `shiftwidth=2`.

8. **Bonus: add a TOML formatter.** `taplo` is a TOML formatter already installed
   via Mason (it's in the `ensure_installed` list in `mason.lua`). Add TOML to
   conform's `formatters_by_ft` in `formatting.lua`:

   ```lua
   -- In the conform.setup() call, inside formatters_by_ft:
   toml = {"taplo"},
   ```

   Restart Neovim and test `<leader>mp` on a TOML file. Run `:ConformInfo` to
   confirm taplo is found and available.

**What you're learning:** The ftplugin system is simple and extensible. Any
language can get custom editor settings with a few lines of Lua. Formatters can
be added to any language by editing one table in `formatting.lua`. The two files
(ftplugin for editor settings, formatters_by_ft for formatter selection) cover
everything you need for a new language.

---

## Closing Notes

Formatting and linting work best when you stop thinking about them. The goal of
this configuration is for formatting to be invisible — code styles itself on save,
and the question of "did I format this correctly" simply never comes up. Linting
should be like a second pair of eyes: always watching, always ready to flag
something, never in the way when there's nothing to report.

A few principles that guided this config's design:

**Prefer specialized tools over general ones.** Biome for JS/TS is faster and
better than the TypeScript LSP's built-in formatter. Ruff for Python is faster
than black. Using the right tool for each language beats one tool-fits-all.

**Separate formatting from linting conceptually and mechanically.** These are
different problems. Conflating them leads to either over-formatting (a linter
that silently rewrites code is scary) or under-linting (a formatter that only
flags but never fixes is annoying). Keep them distinct.

**Respect project conventions.** `lsp_format = "fallback"`, project `.prettierrc`
discovery, project `.eslintrc` loading — the config consistently defers to
project-level settings. This means the editor config works correctly across
projects with different conventions without needing per-project editor config.

**Make it recoverable.** `undo` reverses formatting. Linting never touches your
file. `format_after_save` can be disabled per buffer. There's no step in this
pipeline that can make irreversible changes to your code.

Now go break something on purpose and watch the diagnostics complain.

---

*Next: `11-terminal-and-tasks.md` — running commands without leaving Neovim,
terminal integration, and automating repetitive tasks.*
