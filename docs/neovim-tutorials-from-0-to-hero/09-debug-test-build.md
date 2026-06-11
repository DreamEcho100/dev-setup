# 09 · Debug, Test, and Build

Coming from VSCode, you are already familiar with the idea of clicking the green play button to launch a debug session, hovering over a variable to see its value, or clicking the red circle in the gutter to set a breakpoint. All of that exists in Neovim — the underlying protocols are identical. This chapter walks you through how it works at the architecture level, how to configure it for your languages, and how to use it day-to-day without reaching for the mouse.

By the end you will be able to:

- Set breakpoints (including conditional breakpoints) and step through code entirely from the keyboard
- Inspect scopes, watches, and the REPL while a debug session is live
- Run tests with neotest and read results in-editor
- Build and run tasks with overseer, including support for your existing `.vscode/tasks.json` files

---

## Table of Contents

1. [Why a Debug Adapter Protocol?](#why-a-debug-adapter-protocol)
2. [Debug Stack Architecture](#debug-stack-architecture)
3. [nvim-dap-ui Layout](#nvim-dap-ui-layout)
4. [Installing and Configuring nvim-dap](#installing-and-configuring-nvim-dap)
5. [Setting Breakpoints](#setting-breakpoints)
6. [Starting a Debug Session and Stepping Through Code](#starting-a-debug-session-and-stepping-through-code)
7. [Inspecting State — Scopes, Watches, Hover, and REPL](#inspecting-state)
8. [Per-Language Setup](#per-language-setup)
   - [Node.js and TypeScript](#nodejs-and-typescript)
   - [Python](#python)
   - [Go](#go)
   - [C, C++, and Rust with codelldb](#c-cpp-and-rust-with-codelldb)
   - [.NET and C# with netcoredbg](#net-and-c-with-netcoredbg)
9. [Project-Specific Configuration](#project-specific-configuration)
10. [neotest — Running and Reading Tests](#neotest)
11. [Overseer — Task Runner](#overseer)
12. [Common Workflows](#common-workflows)
13. [Quick Reference Table](#quick-reference-table)
14. [Exercises](#exercises)

---

## Why a Debug Adapter Protocol?

Before we touch a single keybinding, it is worth understanding why all of this works. Microsoft defined the **Debug Adapter Protocol (DAP)** — the same protocol that powers the debugger in VSCode. A debug adapter is a small process that sits between your editor and the language runtime. The editor speaks DAP over stdin/stdout (or a TCP socket) to the adapter, and the adapter speaks whatever the runtime expects — JDWP for the JVM, ptrace for C, the `debugpy` wire protocol for Python, and so on.

This means the debug adapter is completely reusable across editors. The same `js-debug-adapter` that VSCode ships is the one nvim-dap talks to. The same `debugpy` that the Python extension uses is the one you install with Mason. If you already have a `.vscode/launch.json` in a project, there is a good chance nvim-dap can read it directly.

```
Your languages runtime
         |
         |  (language-specific protocol: JDWP, GDB/MI, DAP native, etc.)
         v
   Debug Adapter Process
   (js-debug, debugpy, delve, codelldb, netcoredbg …)
         |
         |  Debug Adapter Protocol (DAP) — JSON over stdio or TCP
         v
     nvim-dap (Lua, runs inside Neovim)
         |
         |  Lua API / events / virtual text
         v
  nvim-dap-ui + nvim-dap-virtual-text
  (the panels and inline values you see on screen)
```

This is the same stack VSCode uses. Neovim simply swaps out the VSCode renderer for nvim-dap-ui. Everything else is identical.

---

## Debug Stack Architecture

Let us draw this out in more detail because understanding where each piece lives saves enormous debugging time when something does not connect.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Your Terminal / OS                               │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                         Neovim process                               │   │
│  │                                                                      │   │
│  │  ┌────────────────────┐    ┌───────────────────────────────────────┐ │   │
│  │  │   Your source file  │    │            nvim-dap (Lua)             │ │   │
│  │  │  (editor buffer)   │    │                                       │ │   │
│  │  │                    │◄───┤  - Manages DAP session state          │ │   │
│  │  │  > line 42  ◄──────┼────┤  - Sends requests (launch, next, …)  │ │   │
│  │  │    line 43         │    │  - Receives events (stopped, output)  │ │   │
│  │  │    line 44         │    │  - Notifies nvim-dap-ui               │ │   │
│  │  └────────────────────┘    └──────────────────┬────────────────────┘ │   │
│  │                                               │                      │   │
│  │  ┌────────────────────────────────────────────▼────────────────────┐ │   │
│  │  │                       nvim-dap-ui                               │ │   │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────────┐ ┌───────────────┐  │ │   │
│  │  │  │  Scopes  │ │ Watches  │ │ Breakpoints  │ │  Call Stack   │  │ │   │
│  │  │  └──────────┘ └──────────┘ └──────────────┘ └───────────────┘  │ │   │
│  │  │  ┌─────────────────────────────────────────────────────────┐    │ │   │
│  │  │  │                        REPL                             │    │ │   │
│  │  │  └─────────────────────────────────────────────────────────┘    │ │   │
│  │  └─────────────────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                    Debug Adapter Process (separate OS process)        │   │
│  │                                                                       │   │
│  │   Examples:                                                           │   │
│  │   - ~/.local/share/nvim/mason/bin/js-debug-adapter  (Node/TS)        │   │
│  │   - ~/.venv/bin/python -m debugpy  (Python)                          │   │
│  │   - dlv dap  (Go)                                                     │   │
│  │   - ~/.local/share/nvim/mason/bin/codelldb  (C/C++/Rust)             │   │
│  │   - ~/.local/share/nvim/mason/bin/netcoredbg  (C#/.NET)              │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                      Your Application Process                         │   │
│  │   (Node.js, Python interpreter, compiled binary, .NET CLR, …)        │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

The key insight: nvim-dap never talks directly to your application. It talks to the adapter, which talks to your application. When something fails to connect, the problem is almost always in the middle layer — the adapter — not in nvim-dap or your code.

### What Mason Does

Mason is a package manager for LSP servers, linters, formatters, and debug adapters. When you install `js-debug-adapter` or `codelldb` via Mason (`:Mason`), it downloads the adapter binary and puts it in `~/.local/share/nvim/mason/bin/`. Your nvim-dap configuration then references that path. This mirrors what VSCode's extension marketplace does — it downloads the same binaries, just into a different folder.

---

## nvim-dap-ui Layout

When you toggle the debug UI with `<F7>` (or `<leader>dbt` for breakpoints separately), nvim-dap-ui opens several panels arranged around your code. Here is the default layout:

```
┌──────────────────────────────┬────────────────────────────────────────────┐
│                              │                                            │
│     LEFT SIDEBAR             │           YOUR CODE (center)               │
│                              │                                            │
│  ┌────────────────────────┐  │   src/app.ts                               │
│  │ SCOPES                 │  │                                            │
│  │                        │  │    40  async function fetchUser(id: string) │
│  │ ▼ Local                │  │    41    const response = await api.get(id) │
│  │   id: "user-123"       │  │  ► 42    const data = response.data        │
│  │   response: Object     │  │    43    return transform(data)            │
│  │     .status: 200       │  │    44  }                                   │
│  │     .data: {...}       │  │                                            │
│  │ ▼ Closure              │  │                                            │
│  │   api: AxiosInstance   │  │                                            │
│  │                        │  │                                            │
│  ├────────────────────────┤  │                                            │
│  │ WATCHES                │  │                                            │
│  │                        │  │                                            │
│  │ response.data.name     │  │                                            │
│  │   "Alice"              │  │                                            │
│  │                        │  │                                            │
│  └────────────────────────┘  │                                            │
│                              │                                            │
├──────────────────────────────┴────────────────────────────────────────────┤
│                                                                           │
│   BOTTOM PANELS (tabbed)                                                  │
│                                                                           │
│  [ REPL ] [ Output ] [ Breakpoints ] [ Stacks ] [ Threads ]               │
│                                                                           │
│  > response.data                                                          │
│  { name: "Alice", email: "alice@example.com", role: "admin" }            │
│  >                                                                        │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

Each panel corresponds directly to something you know from VSCode:

| nvim-dap-ui Panel | VSCode Equivalent                      |
| ----------------- | -------------------------------------- |
| Scopes            | Variables panel in Debug sidebar       |
| Watches           | Watch panel in Debug sidebar           |
| Breakpoints       | Breakpoints panel in Debug sidebar     |
| Stacks            | Call Stack panel in Debug sidebar      |
| Threads           | Threads panel in Debug sidebar         |
| REPL              | Debug Console                          |
| Output            | Terminal/Output panel during debugging |

The big difference from VSCode is that these panels are Neovim buffers. You navigate them with normal Vim motions. You can search inside them with `/`. You can yank variable values. The REPL is an actual Neovim buffer where you type expressions and read results.

---

## Installing and Configuring nvim-dap

Your configuration lives in the plugin files already set up. The relevant plugins are:

- `nvim-dap` — the core DAP client
- `nvim-dap-ui` — the UI panels
- `nvim-dap-virtual-text` — shows variable values as inline virtual text while paused
- Language-specific adapters:
  - `nvim-dap-go` — Go support with delve integration
  - `mason-nvim-dap` — auto-installs adapters via Mason

### What mason-nvim-dap Does

In VSCode, when you install the "JavaScript Debugger" extension, it downloads the adapter automatically. mason-nvim-dap does the same thing. Your configuration specifies which adapters you want, and Mason downloads them on first launch (or when you run `:MasonUpdate`).

```lua
-- Conceptual view of what mason-nvim-dap wires up
require("mason-nvim-dap").setup({
  ensure_installed = {
    "js-debug-adapter",   -- Node.js and TypeScript
    "debugpy",            -- Python
    "delve",              -- Go (used by nvim-dap-go)
    "codelldb",           -- C, C++, Rust
    "netcoredbg",         -- C# and .NET
  },
  automatic_installation = true,
  handlers = {},  -- use default handlers for each adapter
})
```

### Verifying Installation

After launching Neovim, run `:Mason` and look under the "DAP Servers" section. Each adapter you have installed will show a green checkmark. If something is missing, put your cursor on it and press `i` to install.

You can also check what adapters nvim-dap knows about:

```vim
:lua print(vim.inspect(require('dap').adapters))
```

This prints the adapter table. If the adapter for your language is missing, the configuration was not loaded.

---

## Setting Breakpoints

In VSCode you click the red circle in the gutter. In Neovim you press `<leader>dbt` while your cursor is on the line where you want to break. A red circle (or `B` sign depending on your terminal) appears in the sign column.

### Basic Breakpoints

```
<leader>dbt    Toggle breakpoint on current line
```

This is a toggle — pressing it on a line that already has a breakpoint removes it. Pressing it on a line without one adds it. The sign column updates immediately, before any debug session has even started. You can set all your breakpoints before you launch.

In VSCode terms: it is exactly like clicking in the gutter, except you do not need the mouse and your hands never leave the keyboard.

### What the Gutter Signs Look Like

```
 src/server.ts
 ──────────────
  38  app.use(express.json())
  39  app.use(cors())
● 40  app.listen(PORT, () => {
  41    console.log(`Server on port ${PORT}`)
  42  })
```

The `●` in column 1 is the breakpoint sign. When the debugger is running and execution is paused at a line, nvim-dap also places a `→` or highlighted line to show current position.

### Conditional Breakpoints

In VSCode you right-click a breakpoint and choose "Edit Breakpoint" to add a condition. In Neovim you use a different API call. Many configurations expose this as a separate keybinding, and you can always call it directly:

```lua
-- In your keybindings or dap config:
vim.keymap.set("n", "<leader>dbc", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "DAP: Conditional breakpoint" })
```

When you press `<leader>dbc`, you get a prompt in the command line. Type any expression that evaluates to a boolean in your language:

```
Breakpoint condition: i > 10
Breakpoint condition: user.role === "admin"
Breakpoint condition: response.status != 200
```

Conditional breakpoints appear in the gutter with a different sign (often `C` or a different color). When the debugger runs and reaches that line, it only pauses if the condition evaluates to true. This is incredibly useful for loops where you only want to stop when a specific iteration fails.

### Log Points (Message Breakpoints)

Instead of pausing execution, a log point prints a message. This is the equivalent of adding a `console.log` without modifying your source file:

```lua
vim.keymap.set("n", "<leader>dbl", function()
  require("dap").set_breakpoint(nil, nil, vim.fn.input("Log message: "))
end, { desc = "DAP: Log breakpoint" })
```

Usage example:

```
Log message: Processing user {user.id} with status {response.status}
```

The curly-brace expressions are evaluated in the context of your program and the result is printed to the Debug Console (the Output/REPL panel) without stopping execution.

### Listing and Managing Breakpoints

To see all breakpoints across all files, look at the Breakpoints panel inside nvim-dap-ui. You can also use:

```vim
:lua require('dap').list_breakpoints()
```

This opens the quickfix list with all breakpoints. Navigate it with `]q` / `[q` or however you navigate quickfix.

To remove all breakpoints:

```vim
:lua require('dap').clear_breakpoints()
```

---

## Starting a Debug Session and Stepping Through Code

### The F-Key Bindings

Your configuration maps debug actions to function keys, which mirrors VSCode's default bindings intentionally:

| Key    | Action                      | VSCode Equivalent |
| ------ | --------------------------- | ----------------- |
| `<F5>` | Continue (or start session) | F5                |
| `<F1>` | Step into                   | F11               |
| `<F2>` | Step over                   | F10               |
| `<F3>` | Step out                    | Shift+F11         |
| `<F7>` | Toggle DAP UI               | —                 |

The F5 key is the most important. If no session is running, it starts one by calling `dap.continue()`, which triggers the launch sequence. If a session is paused at a breakpoint, it resumes execution until the next breakpoint.

### Launching a Debug Session (F5)

In VSCode you click the green play button at the top of the Run and Debug sidebar, which reads from `.vscode/launch.json`. In Neovim you press `<F5>`.

When you press `<F5>`:

1. nvim-dap looks at the current buffer's filetype
2. It finds the matching configuration (either from your Lua config or from `.vscode/launch.json` if you have nvim-dap-vscode-js or similar support)
3. If there is only one configuration for this filetype, it launches immediately
4. If there are multiple configurations, it shows a picker so you can choose

The picker looks like this:

```
Select configuration:
  1: Launch Node.js (debug)
  2: Attach to process (port 9229)
  3: Run current file
```

You press a number or navigate with `j`/`k` and press Enter.

### Step Over (F2)

In VSCode: F10. Steps to the next line in the same function without descending into called functions.

```
► 42    const result = computeTotal(items)   ← paused here, press F2
  43    return result                         ← execution moves here
  44  }
```

The function `computeTotal` runs completely without pausing inside it.

### Step Into (F1)

In VSCode: F11. Steps into the function call on the current line.

```
► 42    const result = computeTotal(items)   ← press F1 here
```

Execution enters `computeTotal` and pauses at its first line:

```
  12  function computeTotal(items: Item[]) {
► 13    let total = 0                         ← now paused here
  14    for (const item of items) {
```

This is exactly like VSCode's F11 step-into.

### Step Out (F3)

In VSCode: Shift+F11. Runs the rest of the current function and pauses at the call site once it returns.

```
  12  function computeTotal(items: Item[]) {
  13    let total = 0
  14    for (const item of items) {
► 15      total += item.price                 ← paused deep inside, press F3
  16    }
  17    return total
  18  }
```

After pressing F3, execution returns to the call site:

```
  42    const result = computeTotal(items)
► 43    return result                         ← now paused here with result available
```

### Continue (F5)

In VSCode: F5. Resumes execution until the next breakpoint. If there are no more breakpoints, runs to completion (or the next thrown exception if you have break-on-exception enabled).

### Restart and Stop

You will also want these occasionally:

```lua
vim.keymap.set("n", "<leader>dr", require("dap").restart, { desc = "DAP: Restart" })
vim.keymap.set("n", "<leader>dq", require("dap").terminate, { desc = "DAP: Terminate" })
```

Restarting a session is faster than stopping and pressing F5 again, especially for compiled languages where the adapter needs to rebuild.

### Run to Cursor

A very useful operation that VSCode has as "Run to Cursor" (right-click menu). In nvim-dap:

```lua
vim.keymap.set("n", "<leader>drc", require("dap").run_to_cursor, { desc = "DAP: Run to cursor" })
```

Move your cursor to a line further down in the same function and press `<leader>drc`. Execution runs until it reaches that line. This is faster than setting a temporary breakpoint and pressing continue.

---

## Inspecting State

<a name="inspecting-state"></a>

When execution is paused at a breakpoint, you have several ways to inspect what is happening. This is where Neovim's debugger shines compared to a stripped-down terminal debugger like pdb or gdb — the UI gives you the full context without typing inspect commands by hand.

### The Scopes Panel

The Scopes panel (left side of nvim-dap-ui) shows all variables in scope at the current stack frame. It is organized hierarchically:

```
▼ Local
  user: Object
    id: "user-123"
    name: "Alice"
    email: "alice@example.com"
  response: Object
    status: 200
    data: Object
      ▶ items: Array(3)
▶ Closure
▶ Global
```

You can expand objects by pressing Enter or `o` (depending on your nvim-dap-ui config). You can navigate with `j`/`k` as normal Vim motions.

In VSCode this is the Variables panel in the left Debug sidebar. The behavior is identical — expand nodes to drill into objects, see arrays with their indices.

### The Watches Panel

Watches let you track specific expressions. In VSCode you click the + button in the Watch panel and type an expression. In nvim-dap-ui you navigate to the Watches panel and press `a` or `i` to add a watch:

```
WATCHES
  response.data.items.length    →  3
  user.role === "admin"         →  false
  process.env.NODE_ENV          →  "development"
```

Watches are re-evaluated every time execution pauses. They persist across continues and step-overs within the same session.

You can add watches programmatically too:

```lua
require("dap.ui.watches").add("response.data.name")
```

### Hover Evaluation

In VSCode, hovering over a variable with the mouse shows a tooltip with its value. In Neovim you use:

```lua
vim.keymap.set("n", "<leader>dh", require("dap.ui.widgets").hover, { desc = "DAP: Hover" })
```

Or with a floating window widget:

```lua
vim.keymap.set({"n", "v"}, "<leader>dp", function()
  require("dap.ui.widgets").preview()
end, { desc = "DAP: Preview" })
```

Place your cursor on any variable name and press `<leader>dh`. A floating window appears with the variable's current value. If you are in visual mode, the selected expression is evaluated.

This is especially useful for complex expressions — select `response.data.items[0].price * quantity` in visual mode and press `<leader>dp` to see the result without opening the REPL.

### The REPL

The REPL is the most powerful inspection tool. It is equivalent to the Debug Console in VSCode. Open it by navigating to the REPL tab in the bottom panel of nvim-dap-ui, or press:

```lua
vim.keymap.set("n", "<leader>dlr", require("dap").repl.open, { desc = "DAP: Open REPL" })
```

The REPL is a real Neovim buffer in insert mode. Type any expression and press Enter:

```
> user
{ id: 'user-123', name: 'Alice', email: 'alice@example.com' }
> user.email.split('@')[1]
'example.com'
> items.reduce((sum, item) => sum + item.price, 0)
149.97
> items.filter(i => i.price > 50)
[ { id: 'p-001', name: 'Widget', price: 79.99 } ]
```

You can also run multi-line expressions in most adapters. The REPL history works like a shell — `<C-p>` and `<C-n>` navigate previous entries.

### Virtual Text

nvim-dap-virtual-text adds inline values next to variable assignments while paused:

```
  40  const user = await getUser(id)     // { id: "user-123", name: "Alice" }
  41  const items = await getCart(user)  // [Array(3)]
► 42  const total = computeTotal(items)
```

This mirrors the inline values feature that VSCode added in later versions. It gives you at-a-glance context without opening any panel.

Configure it alongside nvim-dap:

```lua
require("nvim-dap-virtual-text").setup({
  enabled = true,
  enabled_commands = true,
  highlight_changed_variables = true,  -- highlight vars that changed value
  highlight_new_as_changed = false,
  show_stop_reason = true,
  commented = false,  -- prefix virtual text with comment string
  virt_text_pos = "eol",  -- end of line
  all_frames = false,  -- only show for current frame
})
```

---

## Per-Language Setup

<a name="per-language-setup"></a>

Each language requires its own debug adapter. Your Mason setup installs them, but you also need launch configurations — the equivalent of entries in `.vscode/launch.json` — that tell nvim-dap how to start your application.

### Node.js and TypeScript

<a name="nodejs-and-typescript"></a>

The adapter is `js-debug-adapter`, maintained by Microsoft and used by the official VSCode JavaScript Debugger extension.

#### Installation

```vim
:MasonInstall js-debug-adapter
```

Or include it in `ensure_installed` in your mason-nvim-dap config.

#### Adapter Configuration

```lua
local js_debug_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"

require("dap").adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = {
      js_debug_path .. "/js-debug/src/dapDebugServer.js",
      "${port}",
    },
  },
}

-- Also register for the "node" adapter type
require("dap").adapters["node"] = require("dap").adapters["pwa-node"]
```

#### Launch Configurations

```lua
require("dap").configurations.javascript = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",       -- debug the current file
    cwd = "${workspaceFolder}",
  },
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch index.js",
    program = "${workspaceFolder}/index.js",
    cwd = "${workspaceFolder}",
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach (port 9229)",
    processId = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}

-- TypeScript inherits the same configurations
require("dap").configurations.typescript = require("dap").configurations.javascript
```

#### Debugging TypeScript Directly

For TypeScript projects using `ts-node` or `tsx`, add a source map configuration:

```lua
{
  type = "pwa-node",
  request = "launch",
  name = "Launch with ts-node",
  runtimeExecutable = "node",
  runtimeArgs = { "--loader", "ts-node/esm" },
  program = "${file}",
  cwd = "${workspaceFolder}",
  sourceMaps = true,
  skipFiles = { "<node_internals>/**", "node_modules/**" },
},
```

#### Equivalent `.vscode/launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch file",
      "program": "${file}",
      "cwd": "${workspaceFolder}"
    },
    {
      "type": "node",
      "request": "attach",
      "name": "Attach (port 9229)",
      "port": 9229,
      "cwd": "${workspaceFolder}"
    }
  ]
}
```

nvim-dap can read this file directly if you add:

```lua
require("dap.ext.vscode").load_launchjs(nil, { ["pwa-node"] = { "javascript", "typescript" } })
```

#### Workflow: Debugging an Express Server

Start your Express server in debug mode from your terminal (separate from Neovim):

```bash
node --inspect-brk index.js
# Debugger listening on ws://127.0.0.1:9229/...
```

In Neovim, set a breakpoint in a route handler with `<leader>dbt`, then press `<F5>` and choose "Attach (port 9229)". Make a request to your server (e.g., with curl or your browser), and Neovim pauses at your breakpoint.

### Python

<a name="python"></a>

Python debugging uses `debugpy`, which was originally created by Microsoft for the VSCode Python extension. It is the same adapter.

#### Installation

```vim
:MasonInstall debugpy
```

#### Adapter Configuration

```lua
require("dap").adapters.python = {
  type = "executable",
  command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
  args = { "-m", "debugpy.adapter" },
}
```

Note: Mason installs debugpy in its own virtualenv to avoid polluting your project's environment. The adapter path points to Mason's Python, but the code it debugs runs in your project's Python.

#### Launch Configurations

```lua
require("dap").configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      -- Find the project's virtualenv if it exists
      local venv = os.getenv("VIRTUAL_ENV")
      if venv then
        return venv .. "/bin/python"
      end
      -- Fall back to .venv in the project root
      local cwd = vim.fn.getcwd()
      if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
        return cwd .. "/.venv/bin/python"
      end
      -- Fall back to system python
      return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
    end,
  },
  {
    type = "python",
    request = "launch",
    name = "Flask app",
    module = "flask",
    env = {
      FLASK_APP = "app.py",
      FLASK_ENV = "development",
      FLASK_DEBUG = "0",  -- disable Flask's reloader, we use debugpy
    },
    args = { "run", "--no-debugger", "--no-reload" },
    pythonPath = function()
      local cwd = vim.fn.getcwd()
      if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
        return cwd .. "/.venv/bin/python"
      end
      return "python"
    end,
    jinja = true,  -- enable Jinja2 template debugging
  },
  {
    type = "python",
    request = "attach",
    name = "Attach to debugpy",
    host = "127.0.0.1",
    port = 5678,
  },
  {
    type = "python",
    request = "launch",
    name = "pytest",
    module = "pytest",
    args = { "${file}", "-v" },
    pythonPath = function()
      local cwd = vim.fn.getcwd()
      if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
        return cwd .. "/.venv/bin/python"
      end
      return "python"
    end,
  },
}
```

#### Equivalent `.vscode/launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch file",
      "type": "python",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal",
      "justMyCode": true
    },
    {
      "name": "Flask app",
      "type": "python",
      "request": "launch",
      "module": "flask",
      "env": {
        "FLASK_APP": "app.py",
        "FLASK_ENV": "development"
      },
      "args": ["run", "--no-debugger", "--no-reload"]
    }
  ]
}
```

#### Debugging with Attach Mode

For long-running Python services, attach mode is more practical. Add this to your Python code:

```python
import debugpy
debugpy.listen(("localhost", 5678))
print("Waiting for debugger to attach...")
debugpy.wait_for_client()  # optional: pause until debugger connects
```

Run your script normally, then press `<F5>` in Neovim and choose "Attach to debugpy". The connection is established and you can set breakpoints and step through normally.

### Go

<a name="go"></a>

Go uses `delve` as its debugger. nvim-dap-go is a dedicated plugin that wraps delve and provides neotest integration as well.

#### Installation

```vim
:MasonInstall delve
```

And include `nvim-dap-go` in your lazy.nvim plugins.

#### Setup

nvim-dap-go handles all the adapter and configuration setup automatically:

```lua
require("dap-go").setup({
  -- Additional dap configurations can be added
  dap_configurations = {
    {
      type = "go",
      name = "Attach remote",
      mode = "remote",
      request = "attach",
    },
  },
  -- delve configurations
  delve = {
    path = "dlv",
    initialize_timeout_sec = 20,
    port = "${port}",
    args = {},
    build_flags = "",
    -- On Windows, substitute the delve path:
    -- path = vim.fn.stdpath("data") .. "/mason/packages/delve/dlv.exe",
  },
})
```

This automatically registers:

- `Launch file` — runs the current Go file
- `Launch package` — runs the package in the current directory
- `Attach to process` — attaches to a running process
- `Attach remote` — attaches to a remote delve server

#### Testing with nvim-dap-go

nvim-dap-go adds a special test debugging command that nvim-dap alone cannot provide:

```lua
-- Debug the test function under the cursor
vim.keymap.set("n", "<leader>dgt", require("dap-go").debug_test, { desc = "DAP Go: Debug test" })
-- Debug the last test
vim.keymap.set("n", "<leader>dgl", require("dap-go").debug_last_test, { desc = "DAP Go: Debug last test" })
```

Position your cursor inside a `func TestFoo(t *testing.T)` function and press `<leader>dgt`. nvim-dap-go determines the package and test name, constructs the correct `dlv test` invocation, and starts a debug session scoped to that single test. This is equivalent to right-clicking a test in VSCode's Test Explorer and choosing "Debug Test".

#### Equivalent `.vscode/launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch file",
      "type": "go",
      "request": "launch",
      "mode": "auto",
      "program": "${file}"
    },
    {
      "name": "Launch package",
      "type": "go",
      "request": "launch",
      "mode": "auto",
      "program": "${workspaceFolder}"
    },
    {
      "name": "Attach to process",
      "type": "go",
      "request": "attach",
      "mode": "local",
      "processId": 0
    }
  ]
}
```

#### Common Go Debugging Scenarios

**Debugging with build tags:**

```lua
{
  type = "go",
  request = "launch",
  name = "Launch with build tags",
  program = "${workspaceFolder}",
  buildFlags = "-tags integration",
}
```

**Debugging with environment variables:**

```lua
{
  type = "go",
  request = "launch",
  name = "Launch API server",
  program = "${workspaceFolder}/cmd/api",
  env = {
    DATABASE_URL = "postgres://localhost/mydb_dev",
    PORT = "8080",
    LOG_LEVEL = "debug",
  },
}
```

**Debugging a compiled binary directly:**

```lua
{
  type = "go",
  request = "launch",
  name = "Debug binary",
  mode = "exec",
  program = "${workspaceFolder}/bin/myapp",
  args = { "--config", "config.dev.yaml" },
}
```

### C, C++, and Rust with codelldb

<a name="c-cpp-and-rust-with-codelldb"></a>

`codelldb` is an LLDB-based adapter. It debugs C, C++, and Rust. For Rust specifically it understands Rust's type representations and shows formatted values rather than raw memory.

#### Installation

```vim
:MasonInstall codelldb
```

#### Adapter Configuration

```lua
local codelldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb"
local liblldb_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/lldb/lib/liblldb"

-- Platform-specific extension
local liblldb_ext = ""
if vim.loop.os_uname().sysname == "Linux" then
  liblldb_ext = ".so"
elseif vim.loop.os_uname().sysname == "Darwin" then
  liblldb_ext = ".dylib"
end

require("dap").adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = codelldb_path,
    args = { "--port", "${port}" },
    -- On macOS with ARM, may also need:
    -- detached = false,
  },
}

-- Rust specifically can use rust-analyzer's built-in codelldb config:
require("dap").adapters.rust = require("dap").adapters.codelldb
```

#### C/C++ Launch Configurations

```lua
require("dap").configurations.c = {
  {
    type = "codelldb",
    request = "launch",
    name = "Launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
}

require("dap").configurations.cpp = require("dap").configurations.c
```

For CMake projects, point directly at the build output:

```lua
{
  type = "codelldb",
  request = "launch",
  name = "Launch (cmake debug build)",
  program = "${workspaceFolder}/build/debug/myapp",
  cwd = "${workspaceFolder}",
  args = {},
},
```

#### Rust Launch Configurations

For Rust you typically want to build first, then debug:

```lua
require("dap").configurations.rust = {
  {
    type = "codelldb",
    request = "launch",
    name = "Launch (cargo build first)",
    program = function()
      local metadata = vim.fn.system("cargo metadata --no-deps --format-version 1")
      local decoded = vim.fn.json_decode(metadata)
      local target_dir = decoded.target_directory
      local package_name = decoded.packages[1].name
      -- Build the project first
      os.execute("cargo build 2>&1")
      return target_dir .. "/debug/" .. package_name
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
  {
    type = "codelldb",
    request = "launch",
    name = "Launch binary (prompt)",
    program = function()
      return vim.fn.input(
        "Path to executable: ",
        vim.fn.getcwd() .. "/target/debug/",
        "file"
      )
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
}
```

#### Equivalent `.vscode/launch.json` for Rust

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "lldb",
      "request": "launch",
      "name": "Debug executable",
      "cargo": {
        "args": ["build", "--manifest-path", "${workspaceFolder}/Cargo.toml"],
        "filter": {
          "name": "myapp",
          "kind": "bin"
        }
      },
      "args": [],
      "cwd": "${workspaceFolder}"
    }
  ]
}
```

Note: In VSCode with the CodeLLDB extension you often use the `cargo` key which handles building and finding the binary. In nvim-dap you handle this with a Lua function — more verbose but also more flexible.

#### Viewing Rust Values

codelldb understands Rust's type system and formats values properly:

```
SCOPES
▼ Local
  vec: Vec<i32> [1, 2, 3, 4, 5]   ← not raw memory, actual Vec content
  opt: Option<String>
    Some: "hello world"             ← unwrapped Option variant
  result: Result<User, Error>
    Ok: { id: 42, name: "Alice" }  ← unwrapped Ok variant
```

### .NET and C# with netcoredbg

<a name="net-and-c-with-netcoredbg"></a>

`netcoredbg` is an open-source debugger for .NET Core and .NET 5+.

#### Installation

```vim
:MasonInstall netcoredbg
```

#### Adapter Configuration

```lua
require("dap").adapters.coreclr = {
  type = "executable",
  command = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg",
  args = { "--interpreter=vscode" },
}
```

#### Launch Configurations

```lua
require("dap").configurations.cs = {
  {
    type = "coreclr",
    name = "Launch (dotnet run)",
    request = "launch",
    program = function()
      return vim.fn.input(
        "Path to dll: ",
        vim.fn.getcwd() .. "/bin/Debug/",
        "file"
      )
    end,
  },
  {
    type = "coreclr",
    name = "Attach",
    request = "attach",
    processId = require("dap.utils").pick_process,
  },
}
```

For ASP.NET Core projects, build first and point at the DLL:

```lua
{
  type = "coreclr",
  name = "ASP.NET Core",
  request = "launch",
  program = "${workspaceFolder}/bin/Debug/net8.0/MyWebApp.dll",
  env = {
    ASPNETCORE_ENVIRONMENT = "Development",
  },
},
```

#### Equivalent `.vscode/launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": ".NET Core Launch (console)",
      "type": "coreclr",
      "request": "launch",
      "preLaunchTask": "build",
      "program": "${workspaceFolder}/bin/Debug/net8.0/${workspaceFolderBasename}.dll",
      "args": [],
      "cwd": "${workspaceFolder}",
      "stopAtEntry": false
    }
  ]
}
```

---

## Project-Specific Configuration

One of the most useful features is the ability to define per-project debug configurations without modifying your global Neovim config. This mirrors VSCode's `.vscode/launch.json` workflow.

### Option 1: .vscode/launch.json (VSCode Compatibility)

If you already have a `.vscode/launch.json`, nvim-dap can load it. Add this to your nvim-dap setup (typically in an autocmd that runs when you open a project):

```lua
-- Load .vscode/launch.json if it exists
local function load_vscode_launch()
  local launch_json = vim.fn.getcwd() .. "/.vscode/launch.json"
  if vim.fn.filereadable(launch_json) == 1 then
    -- Map vscode adapter types to nvim-dap adapter types
    require("dap.ext.vscode").load_launchjs(launch_json, {
      ["node"] = { "javascript", "typescript" },
      ["pwa-node"] = { "javascript", "typescript" },
      ["python"] = { "python" },
      ["go"] = { "go" },
      ["lldb"] = { "c", "cpp", "rust" },
      ["coreclr"] = { "cs" },
    })
    vim.notify("Loaded .vscode/launch.json", vim.log.levels.INFO)
  end
end

-- Auto-load when entering a project
vim.api.nvim_create_autocmd("VimEnter", {
  callback = load_vscode_launch,
})

-- Also allow manual reload
vim.keymap.set("n", "<leader>dl", load_vscode_launch, { desc = "DAP: Load launch.json" })
```

The `load_launchjs` function parses the JSON file and merges its configurations into `require("dap").configurations`. Variables like `${workspaceFolder}`, `${file}`, and `${port}` are resolved at launch time.

### Option 2: .nvim/dap.lua (Neovim-Native)

Create a file at `.nvim/dap.lua` in your project root. This is pure Lua and runs with full access to the nvim-dap API:

```lua
-- .nvim/dap.lua
local dap = require("dap")

-- Override the default Python configuration for this project
dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Django (dev)",
    program = "manage.py",
    args = { "runserver", "--noreload", "--nothreading" },
    pythonPath = vim.fn.getcwd() .. "/.venv/bin/python",
    django = true,
    env = {
      DJANGO_SETTINGS_MODULE = "myapp.settings.development",
      DATABASE_URL = "postgres://localhost/myapp_dev",
    },
    justMyCode = false,  -- step into library code too
  },
  {
    type = "python",
    request = "launch",
    name = "Django (test specific)",
    program = "manage.py",
    args = {
      "test",
      vim.fn.input("Test path: ", "myapp.tests."),
      "--keepdb",
    },
    pythonPath = vim.fn.getcwd() .. "/.venv/bin/python",
    django = true,
    env = {
      DJANGO_SETTINGS_MODULE = "myapp.settings.test",
    },
  },
}
```

Load this file in your nvim-dap setup:

```lua
-- In your dap config, after base setup:
local project_dap = vim.fn.getcwd() .. "/.nvim/dap.lua"
if vim.fn.filereadable(project_dap) == 1 then
  dofile(project_dap)
end
```

### Option 3: .nvimrc.lua (Per-Project Neovim Config)

Some setups use an `.nvimrc.lua` or `.exrc.lua` file at the project root for all project-specific Neovim config, not just debugging. Enable this with:

```lua
-- In your init.lua
vim.o.exrc = true   -- allow per-directory .exrc files
vim.o.secure = true -- but require them to be readable (not writable by others)
```

Then create `.exrc.lua` or `.nvimrc.lua` at your project root with any Neovim Lua:

```lua
-- .nvimrc.lua at project root
-- DAP config
require("dap").configurations.javascript = {
  { name = "Launch Express", type = "pwa-node", request = "launch",
    program = "src/server.js", cwd = vim.fn.getcwd(),
    env = { NODE_ENV = "development", PORT = "3000" } },
}
-- Also set up project-specific tasks for overseer
require("overseer").add_template_hook(function(opts, callback)
  -- ... custom tasks
end)
```

### Summary of Configuration Loading Order

When you press `<F5>`, nvim-dap looks for configurations in this order:

```
1. require("dap").configurations[filetype]   (set in your Lua config)
2. Merged with .vscode/launch.json            (if loaded with load_launchjs)
3. Merged with .nvim/dap.lua                  (if loaded in your setup)

Later entries take precedence, so project-level config overrides global config.
```

---

## neotest — Running and Reading Tests

<a name="neotest"></a>

neotest is a framework for running tests from within Neovim. It is equivalent to VSCode's Test Explorer — it discovers tests, runs them, shows results in the gutter, and lets you re-run individual tests or files without leaving your editor.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         neotest                             │
│                                                             │
│  ┌───────────────┐    ┌──────────────┐    ┌─────────────┐  │
│  │  Test runner  │    │ Result store │    │  UI panels  │  │
│  │  (spawns      │    │ (pass/fail/  │    │  (summary,  │  │
│  │   tests in    │    │  output per  │    │   gutter    │  │
│  │   subprocess) │    │  test)       │    │   signs)    │  │
│  └──────┬────────┘    └──────────────┘    └─────────────┘  │
│         │                                                   │
│  ┌──────▼─────────────────────────────────────────────┐    │
│  │                    Adapters                         │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────┐ ┌──────────┐  │    │
│  │  │ Jest/    │ │ pytest   │ │ Go   │ │  plenary │  │    │
│  │  │ Vitest   │ │          │ │ test │ │  busted  │  │    │
│  │  └──────────┘ └──────────┘ └──────┘ └──────────┘  │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

neotest uses adapters to understand different test frameworks. Each adapter knows how to discover tests, parse their output, and map results back to specific lines in your source files.

### Keybindings

Your configuration sets up these bindings:

| Keybinding   | Action                | VSCode Equivalent                |
| ------------ | --------------------- | -------------------------------- |
| `<leader>tN` | Run nearest test      | Click "Run Test" lens above test |
| `<leader>tF` | Run all tests in file | Run file in Test Explorer        |
| `<leader>tO` | Open output           | Click test result to see output  |
| `<leader>tS` | Open summary          | Open Test Explorer panel         |

### Running the Nearest Test

Place your cursor inside a test function and press `<leader>tN`. neotest identifies which test you are in and runs only that test:

```python
# cursor is inside this function
def test_user_creation():          ← <leader>tN runs only this test
    user = User.create("alice", "alice@example.com")
    assert user.id is not None
    assert user.name == "alice"
```

The result appears in the gutter:

```
  12  def test_user_creation():
✓ 13    user = User.create("alice", "alice@example.com")
✓ 14    assert user.id is not None
✓ 15    assert user.name == "alice"
```

A green checkmark for passing, a red `✗` for failing. If the test fails, the error message appears as virtual text on the failing assertion line.

### Running All Tests in a File

Press `<leader>tF` to run every test in the current file. Results appear for each test individually. This is equivalent to right-clicking a file in VSCode's Test Explorer and choosing "Run All Tests in File".

### Reading Test Output

When a test fails, press `<leader>tO` to open the output. This shows the full test output including the error message, stack trace, and assertion failure details — exactly what you would see in VSCode's test output panel when you click a failed test.

The output opens in a floating window or a split, depending on your configuration:

```
FAILED test_user_creation
────────────────────────────────────
AssertionError: assert None is not None
     + where None = <User id=None name='alice'>

def test_user_creation():
    user = User.create("alice", "alice@example.com")
>   assert user.id is not None
E   AssertionError: assert None is not None

tests/test_user.py:14: AssertionError
```

### The Summary Panel

Press `<leader>tS` to open the Summary panel, which is neotest's equivalent of the full Test Explorer sidebar:

```
NEOTEST SUMMARY
════════════════════════════════
▼ tests/
  ▼ test_user.py
    ✓ test_user_creation
    ✗ test_user_deletion
    ✓ test_user_update
  ▼ test_api.py
    ✓ test_get_users
    ✓ test_create_user
    ✗ test_delete_user
════════════════════════════════
5 passed, 2 failed
```

Navigate with `j`/`k`. Press Enter on a test to jump to its source. Press `r` to re-run a test. Press `o` to open the output for a test.

### Gutter Icons at a Glance

```
 test_user.py
 ────────────────────────────────
  ✓ def test_user_creation():
  11   user = User.create("alice", "alice@example.com")
  12   assert user.id is not None
  13
  ✗ def test_user_deletion():
  15   user = User.objects.get(id=1)
  16   user.delete()
  17   assert User.objects.filter(id=1).count() == 0
  ⟳  def test_user_update():   ← currently running
  19   ...
```

The `⟳` indicates a test that is currently running. Tests run asynchronously, so you can continue editing while tests run in the background.

### Setting Up neotest Adapters

In your plugin configuration, you install adapters for each test framework:

```lua
require("neotest").setup({
  adapters = {
    -- JavaScript/TypeScript with Jest
    require("neotest-jest")({
      jestCommand = "npx jest",
      jestConfigFile = "jest.config.ts",
      env = { CI = "true" },
      cwd = function(path)
        return vim.fn.getcwd()
      end,
    }),

    -- JavaScript/TypeScript with Vitest
    require("neotest-vitest")({
      vitestCommand = "npx vitest",
    }),

    -- Python with pytest
    require("neotest-python")({
      dap = { justMyCode = false },
      runner = "pytest",
      python = function()
        local venv = vim.fn.getcwd() .. "/.venv/bin/python"
        if vim.fn.executable(venv) == 1 then
          return venv
        end
        return "python"
      end,
    }),

    -- Go
    require("neotest-go")({
      experimental = {
        test_table = true,  -- support table-driven tests
      },
      args = { "-count=1", "-timeout=60s" },
    }),

    -- Rust with cargo-nextest
    require("neotest-rust")({
      args = { "--no-capture" },
      dap_adapter = "codelldb",
    }),
  },

  -- UI configuration
  icons = {
    running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
    passed = "✓",
    failed = "✗",
    unknown = "?",
    skipped = "⊘",
    running = "⟳",
  },

  summary = {
    enabled = true,
    animated = true,
    follow = true,       -- auto-scroll to running test
    expand_errors = true,
  },

  output = {
    enabled = true,
    open_on_run = "short",  -- "always" | "short" | false
  },
})
```

### Debug a Failing Test with nvim-dap

neotest and nvim-dap integrate directly. When you have a failing test, you can launch a debug session for just that test:

```lua
vim.keymap.set("n", "<leader>td", function()
  require("neotest").run.run({ strategy = "dap" })
end, { desc = "Neotest: Debug nearest test" })
```

Press `<leader>td` with your cursor inside a failing test. neotest runs the test with your configured DAP adapter and pauses at the first breakpoint. This combines test discovery (knowing which test to run) with debug stepping (seeing what happens at runtime). VSCode has this as "Debug Test" in the code lens above each test.

### Watch Mode

neotest supports re-running tests automatically when files change:

```lua
vim.keymap.set("n", "<leader>tw", function()
  require("neotest").watch.toggle(vim.fn.expand("%"))
end, { desc = "Neotest: Watch file" })
```

This is equivalent to `jest --watch` or `pytest-watch` but controlled from within Neovim without a separate terminal.

---

## Overseer — Task Runner

<a name="overseer"></a>

Overseer is Neovim's answer to VSCode's task system. In VSCode you define tasks in `.vscode/tasks.json` (build, lint, deploy, etc.) and run them from the Terminal > Run Task menu. Overseer does the same thing but from Neovim, and it can also read your existing `.vscode/tasks.json` files.

### Keybindings

Your configuration sets up:

| Keybinding   | Action                       | VSCode Equivalent                  |
| ------------ | ---------------------------- | ---------------------------------- |
| `<leader>tr` | Run task (picker)            | Terminal > Run Task                |
| `<leader>tt` | Toggle task list             | Terminal > Run Task (view running) |
| `<leader>ta` | Task action on selected task | Right-click task > options         |

### Anatomy of a Task

In VSCode, a task in `.vscode/tasks.json` looks like:

```json
{
  "label": "build",
  "type": "shell",
  "command": "npm run build",
  "group": { "kind": "build", "isDefault": true },
  "presentation": { "reveal": "always", "panel": "dedicated" },
  "problemMatcher": ["$tsc"]
}
```

In Overseer, the equivalent is:

```lua
{
  name = "build",
  builder = function()
    return {
      cmd = { "npm", "run", "build" },
      components = {
        { "on_output_quickfix", set_diagnostics = true },
        "on_result_notify",
        "default",
      },
    }
  end,
}
```

Or you can define tasks in `.vscode/tasks.json` and Overseer reads them automatically.

### Running a Task

Press `<leader>tr` to open the task picker. Overseer discovers:

1. Tasks defined in your Lua configuration
2. Tasks from `.vscode/tasks.json` in the current workspace
3. Built-in templates for common operations (make, cargo build, npm scripts, etc.)

```
Run Task
════════════════════════════════
> npm: build
  npm: test
  npm: start
  npm: lint
  npm: type-check
  make: all
  make: clean
  shell: (prompt)
```

Select a task and press Enter. The task runs in a terminal buffer managed by Overseer.

### The Task List

Press `<leader>tt` to toggle the task list, which shows all running and recent tasks:

```
OVERSEER
════════════════════════════════
 RUNNING
  ⟳ npm: build    [2s]

 RECENT
  ✓ npm: test     [12s ago]
  ✗ npm: lint     [1m ago]
════════════════════════════════
```

Navigate to a task and press Enter (or your configured action key) to open its output terminal. Press `<leader>ta` with a task selected to see available actions (restart, stop, dispose, open output).

### .vscode/tasks.json Support

If your project already has `.vscode/tasks.json`, Overseer reads it automatically. Here is a comprehensive example:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "TypeScript: Build",
      "type": "shell",
      "command": "npx tsc --noEmit",
      "group": { "kind": "build", "isDefault": true },
      "presentation": {
        "reveal": "always",
        "panel": "dedicated",
        "clear": true
      },
      "problemMatcher": ["$tsc"]
    },
    {
      "label": "Node: Start server",
      "type": "shell",
      "command": "node dist/server.js",
      "isBackground": true,
      "group": "test",
      "presentation": {
        "reveal": "always",
        "panel": "dedicated"
      },
      "problemMatcher": {
        "pattern": {
          "regexp": "^Error: (.*)$",
          "message": 1
        },
        "background": {
          "activeOnStart": true,
          "beginsPattern": "^Starting server",
          "endsPattern": "^Server listening on port"
        }
      }
    },
    {
      "label": "Docker: Build and run",
      "type": "shell",
      "command": "docker compose up --build",
      "group": "build",
      "dependsOn": ["TypeScript: Build"]
    }
  ]
}
```

When you press `<leader>tr`, all three tasks appear in the picker. The `dependsOn` field is respected — running "Docker: Build and run" also runs "TypeScript: Build" first.

### Defining Custom Lua Tasks

For complex tasks that go beyond what shell commands can express, define them in Lua:

```lua
-- In your overseer config or a .nvim/tasks.lua file
local overseer = require("overseer")

-- A task that builds TypeScript and then runs tests
overseer.register_template({
  name = "Build and test",
  desc = "Compile TypeScript then run Jest",
  builder = function(params)
    return {
      name = "build-and-test",
      strategy = {
        "sequence",
        {
          { "shell", cmd = "npx tsc --noEmit" },
          { "shell", cmd = "npx jest --ci" },
        },
      },
      components = {
        "default",
        { "on_result_notify", system = "unfocused" },
        {
          "on_output_quickfix",
          set_diagnostics = true,
          errorformat = "%f(%l,%c): error TS%n: %m",
        },
      },
    }
  end,
})

-- A parameterized task with user input
overseer.register_template({
  name = "Deploy to environment",
  desc = "Deploy to a specific environment",
  params = {
    env = {
      desc = "Target environment",
      type = "enum",
      choices = { "development", "staging", "production" },
      default = "development",
    },
    dry_run = {
      desc = "Dry run only",
      type = "boolean",
      default = false,
    },
  },
  builder = function(params)
    local cmd = {
      "scripts/deploy.sh",
      "--env", params.env,
    }
    if params.dry_run then
      table.insert(cmd, "--dry-run")
    end
    return {
      cmd = cmd,
      name = "Deploy (" .. params.env .. ")",
      components = {
        "default",
        { "on_result_notify", system = "always" },
      },
    }
  end,
})

-- A task that watches for file changes and re-runs
overseer.register_template({
  name = "Watch and rebuild",
  builder = function()
    return {
      cmd = { "npx", "tsc", "--watch", "--noEmit" },
      name = "tsc: watch",
      components = {
        { "restart_on_save", paths = { "src", "tsconfig.json" } },
        "default",
      },
    }
  end,
})
```

### Overseer with Keybinding to Run Last Task

A very useful addition mirrors VSCode's "Re-run Last Task" (Ctrl+Shift+P > "Tasks: Rerun Last Task"):

```lua
vim.keymap.set("n", "<leader>tl", function()
  local overseer = require("overseer")
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify("No tasks found", vim.log.levels.WARN)
  else
    overseer.run_action(tasks[1], "restart")
  end
end, { desc = "Overseer: Restart last task" })
```

### Integrating Overseer with Pre-Debug Builds

A common VSCode pattern is using `preLaunchTask` in `launch.json` to build before debugging. You can replicate this in nvim-dap:

```lua
-- In your dap config:
local function build_and_debug(dap_config)
  local overseer = require("overseer")
  local task = overseer.new_task({
    cmd = { "cargo", "build" },
    components = {
      { "on_complete_notify" },
      "default",
    },
  })
  task:subscribe("on_complete", function(_, status)
    if status == overseer.STATUS.SUCCESS then
      require("dap").run(dap_config)
    end
  end)
  task:start()
end

-- Then use build_and_debug in your launch configurations:
require("dap").configurations.rust = {
  {
    type = "codelldb",
    request = "launch",
    name = "Build and debug",
    program = function()
      -- This function runs when F5 is pressed
      -- But we want to build first...
      return vim.fn.getcwd() .. "/target/debug/myapp"
    end,
    -- Pre-launch task equivalent:
    before_launch = function(config)
      local task = require("overseer").new_task({ cmd = { "cargo", "build" } })
      task:start()
      -- Wait for completion via coroutine
      local done = false
      task:subscribe("on_complete", function() done = true end)
      vim.wait(30000, function() return done end, 100)
    end,
  },
}
```

---

## Common Workflows

<a name="common-workflows"></a>

This section walks through end-to-end debugging scenarios that combine everything above.

### Workflow 1: Debug a Flask Application

**Scenario:** A Python Flask endpoint is returning incorrect data. You need to step through the route handler to see what is happening.

**Step 1: Set up the project**

Make sure your project has a virtual environment:

```bash
cd /path/to/flask-project
python -m venv .venv
source .venv/bin/activate
pip install flask debugpy
```

**Step 2: Ensure your dap config includes the Flask configuration**

Either your global config or `.nvim/dap.lua`:

```lua
require("dap").configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Flask (dev)",
    module = "flask",
    env = {
      FLASK_APP = "app.py",
      FLASK_ENV = "development",
      FLASK_DEBUG = "0",
    },
    args = { "run", "--no-debugger", "--no-reload" },
    pythonPath = vim.fn.getcwd() .. "/.venv/bin/python",
    jinja = true,
  },
}
```

**Step 3: Open the route handler**

Navigate to `app.py` and find the route that is misbehaving:

```python
@app.route("/users/<int:user_id>")
def get_user(user_id):
    user = db.session.get(User, user_id)
    return jsonify(user.to_dict())
```

**Step 4: Set a breakpoint**

Move your cursor to the line inside the route handler and press `<leader>dbt`:

```python
@app.route("/users/<int:user_id>")
def get_user(user_id):
● user = db.session.get(User, user_id)   ← breakpoint here
  return jsonify(user.to_dict())
```

**Step 5: Start the debug session**

Press `<F5>`. A picker appears (since you have multiple Python configurations). Select "Flask (dev)". Flask starts up in a debug session.

**Step 6: Trigger the route**

In a separate terminal or browser, make a request:

```bash
curl http://localhost:5000/users/1
```

Execution hits your breakpoint. Neovim's nvim-dap-ui opens automatically (because of your `<F7>` toggle setup or an autocmd). The Scopes panel shows:

```
▼ Local
  user_id: 1
▼ Closure
  app: Flask object
  db: SQLAlchemy object
```

**Step 7: Step through**

Press `<F2>` to step over the database query:

```python
@app.route("/users/<int:user_id>")
def get_user(user_id):
  user = db.session.get(User, user_id)   ← just executed
► return jsonify(user.to_dict())         ← paused here
```

The Scopes panel now shows:

```
▼ Local
  user_id: 1
  user: None   ← The bug! User not found in database
```

You can see that `user` is `None`, which will cause `user.to_dict()` to raise an `AttributeError`. Now you know the bug is in the database query, not the route handler.

**Step 8: Use the REPL to investigate**

Press `<leader>dlr` to open the REPL:

```python
> db.session.get(User, 1)
None
> db.session.query(User).count()
0
> db.session.query(User).first()
None
```

The database is empty. The problem is not in this code at all — the database was not seeded.

**Step 9: End the session**

Press `<leader>dq` to terminate. Press `<F7>` to close the UI.

### Workflow 2: Debug a Go Binary

**Scenario:** A Go HTTP server is producing incorrect JSON responses. You want to step through the handler.

**Step 1: Open the handler**

```go
func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
    id := chi.URLParam(r, "id")
    user, err := h.store.GetUser(r.Context(), id)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    json.NewEncoder(w).Encode(user)
}
```

**Step 2: Set a breakpoint**

With cursor on the `user, err := ...` line, press `<leader>dbt`.

**Step 3: Launch**

Press `<F5>`. nvim-dap-go shows configurations:

```
1: Launch package
2: Launch file
3: Attach remote
```

Select "Launch package". nvim-dap-go runs `dlv dap` with your package, which compiles and runs the binary in debug mode.

**Step 4: Trigger the endpoint**

```bash
curl http://localhost:8080/users/abc123
```

Execution pauses at your breakpoint. The Scopes panel shows:

```
▼ Local
  w: http.ResponseWriter
  r: *http.Request
  h: *UserHandler
  id: "abc123"
```

**Step 5: Step into the store call**

Press `<F1>` to step into `h.store.GetUser`. You descend into the store implementation:

```go
func (s *PostgresStore) GetUser(ctx context.Context, id string) (*User, error) {
►   row := s.db.QueryRowContext(ctx, "SELECT id, name, email FROM users WHERE id = $1", id)
    var user User
    err := row.Scan(&user.ID, &user.Name, &user.Email)
    return &user, err
}
```

**Step 6: Inspect the query**

Press `<F2>` to step over the query. Now `row` is populated. Press `<F2>` again to step over Scan. Check the Scopes panel:

```
▼ Local
  ctx: context.Background
  id: "abc123"
  row: *sql.Row
  user: User {ID: "abc123", Name: "", Email: ""}
  err: sql.ErrNoRows   ← returned sql.ErrNoRows instead of nil
```

The handler checks `if err != nil` and returns 500 when the user is not found, but it should return 404. That is the bug.

**Step 7: Check with the REPL**

In Go's delve REPL you can evaluate expressions:

```
> id
"abc123"
> user
main.User {ID:"abc123", Name:"", Email:""}
> err
error("sql: no rows in result set")
```

### Workflow 3: Watch a Test as It Runs

**Scenario:** A Jest test is failing intermittently. You suspect it is a race condition and want to watch variables during the test run.

**Step 1: Open the test file**

```typescript
// tests/queue.test.ts
describe("Queue", () => {
  it("processes all items", async () => {
    const queue = new Queue();
    await Promise.all([
      queue.add("item1"),
      queue.add("item2"),
      queue.add("item3"),
    ]);
    await queue.drain();
    expect(queue.processed).toEqual(["item1", "item2", "item3"]);
  });
});
```

**Step 2: Set a breakpoint inside the test**

Move your cursor to `await queue.drain()` and press `<leader>dbt`.

**Step 3: Debug just this test**

Press `<leader>td` (if you set up the debug-via-neotest keybinding). neotest identifies the test and runs it with the DAP strategy. The debug session starts and pauses at your breakpoint.

**Step 4: Check state before drain**

The Scopes panel shows:

```
▼ Local
  queue: Queue
    _pending: Array(0)
    _processing: Array(3)   ← all 3 are still processing!
    processed: Array(0)
```

You can see that all three adds are still processing when drain is called. The queue does not wait for ongoing processing to complete before reporting done. That is the race.

**Step 5: Add watches for continuous monitoring**

In the Watches panel, add:

```
queue._processing.length    → 3
queue.processed.length      → 0
```

Press `<F2>` to step over the drain call. The watches update:

```
queue._processing.length    → 0   (drain completed)
queue.processed.length      → 1   (only 1 item made it!)
```

The race condition is confirmed: drain resolves before the concurrent adds finish.

---

## Quick Reference Table

<a name="quick-reference-table"></a>

### DAP Keybindings

| Keybinding    | Action                   | Notes                                       |
| ------------- | ------------------------ | ------------------------------------------- |
| `<F5>`        | Continue / Start session | Same as VSCode F5                           |
| `<F1>`        | Step into                | VSCode uses F11                             |
| `<F2>`        | Step over                | VSCode uses F10                             |
| `<F3>`        | Step out                 | VSCode uses Shift+F11                       |
| `<F7>`        | Toggle DAP UI            | No VSCode equivalent (UI is always visible) |
| `<leader>dbt` | Toggle breakpoint        | VSCode: click in gutter                     |
| `<leader>dbc` | Conditional breakpoint   | VSCode: right-click > Edit Breakpoint       |
| `<leader>dbl` | Log point                | VSCode: right-click > Add Logpoint          |
| `<leader>dh`  | Hover variable value     | VSCode: mouse hover                         |
| `<leader>dp`  | Preview selection        | VSCode: mouse hover on selection            |
| `<leader>dr`  | Restart session          | VSCode: Ctrl+Shift+F5                       |
| `<leader>dq`  | Terminate session        | VSCode: Shift+F5                            |
| `<leader>drc` | Run to cursor            | VSCode: right-click > Run to Cursor         |
| `<leader>dlr` | Open REPL                | VSCode: Debug Console                       |

### Neotest Keybindings

| Keybinding   | Action             | Notes                             |
| ------------ | ------------------ | --------------------------------- |
| `<leader>tN` | Run nearest test   | VSCode: click "Run Test" lens     |
| `<leader>tF` | Run file tests     | VSCode: Run File in Test Explorer |
| `<leader>tO` | Open output        | VSCode: click failed test output  |
| `<leader>tS` | Summary panel      | VSCode: open Test Explorer        |
| `<leader>td` | Debug nearest test | VSCode: "Debug Test" lens         |
| `<leader>tw` | Watch file         | VSCode: jest --watch extension    |

### Overseer Keybindings

| Keybinding   | Action            | Notes                            |
| ------------ | ----------------- | -------------------------------- |
| `<leader>tr` | Run task (picker) | VSCode: Terminal > Run Task      |
| `<leader>tt` | Toggle task list  | VSCode: Terminal > Run Task view |
| `<leader>ta` | Task action       | VSCode: right-click task         |
| `<leader>tl` | Restart last task | VSCode: Tasks: Rerun Last Task   |

### Adapters and Their Scope

| Adapter          | Languages                       | Installation                          |
| ---------------- | ------------------------------- | ------------------------------------- |
| js-debug-adapter | JavaScript, TypeScript, Node.js | `:MasonInstall js-debug-adapter`      |
| debugpy          | Python                          | `:MasonInstall debugpy`               |
| delve            | Go                              | `:MasonInstall delve` (+ nvim-dap-go) |
| codelldb         | C, C++, Rust                    | `:MasonInstall codelldb`              |
| netcoredbg       | C#, F#, VB.NET                  | `:MasonInstall netcoredbg`            |

### DAP State Machine

```
                    ┌──────────────────────────────┐
                    │                              │
                    ▼                              │
              ┌──────────┐       F5            ┌──────────┐
              │          │───────────────────► │          │
              │  Stopped │                     │ Running  │
              │          │◄─────────────────── │          │
              └──────────┘   breakpoint hit    └──────────┘
                   │                                │
                   │ F2/F1/F3                       │ Shift+F5
                   │                                ▼
                   │                          ┌──────────┐
                   └─────────────────────────►│ Stopped  │
                                              │ (stepped)│
                                              └──────────┘
```

---

## Advanced Topics

### Exception Breakpoints

In VSCode, you can enable "Pause on exceptions" in the breakpoints panel. nvim-dap exposes this through:

```lua
-- Pause on all uncaught exceptions
require("dap").set_exception_breakpoints({ "uncaught" })

-- Pause on all exceptions (including caught ones)
require("dap").set_exception_breakpoints({ "all" })

-- Disable
require("dap").set_exception_breakpoints({})
```

You can also set this per-session in a configuration:

```lua
{
  type = "python",
  request = "launch",
  name = "Launch with exceptions",
  program = "${file}",
  stopOnEntry = false,
  justMyCode = false,
  -- These get merged with exception breakpoints:
  exceptionBreakpointFilters = {
    { filter = "uncaughtExceptions", label = "Uncaught Exceptions", default = true },
    { filter = "userUnhandledExceptions", label = "User Unhandled Exceptions", default = true },
  },
}
```

### Remote Debugging

Remote debugging (attaching to a process on a different machine or in a Docker container) uses attach configurations:

```lua
-- Debug a Python app in Docker
{
  type = "python",
  request = "attach",
  name = "Docker: Attach to container",
  host = "localhost",
  port = 5678,
  -- Path mappings from container to local:
  pathMappings = {
    {
      localRoot = vim.fn.getcwd(),
      remoteRoot = "/app",  -- path inside container
    },
  },
},
```

Start your Docker container with debugpy listening:

```dockerfile
# In your Dockerfile or docker-compose.yml:
CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "-m", "flask", "run"]
```

And expose the port in docker-compose.yml:

```yaml
ports:
  - "5678:5678"
```

Then press `<F5>` in Neovim and choose the "Docker: Attach" configuration.

### Multi-Process Debugging

Some applications spawn child processes. Go handles this natively with delve. For Node.js you need to attach to each worker process separately.

For applications using Node.js `cluster`:

```lua
{
  type = "pwa-node",
  request = "attach",
  name = "Attach to worker (port prompt)",
  port = function()
    return tonumber(vim.fn.input("Worker port: "))
  end,
  cwd = "${workspaceFolder}",
},
```

### Using nvim-dap Programmatically

If you need to build custom debug workflows, nvim-dap's Lua API is fully accessible:

```lua
-- Start a session with a specific config
require("dap").run({
  type = "python",
  request = "launch",
  name = "custom",
  program = "/path/to/script.py",
  args = { "--verbose" },
})

-- Listen for events
require("dap").listeners.after.event_stopped["my_plugin"] = function(session, body)
  -- Called every time execution stops
  print("Stopped at: " .. vim.inspect(body.reason))
end

-- Query current state
local session = require("dap").session()
if session then
  print("Active DAP session: " .. session.config.name)
end
```

### Overseer — Advanced Task Strategies

Overseer supports several execution strategies beyond simple shell commands:

```lua
-- Run two commands in sequence (second runs only if first succeeds)
{
  strategy = {
    "sequence",
    {
      { "shell", cmd = "cargo build" },
      { "shell", cmd = "cargo test" },
    },
  },
}

-- Run commands in parallel and wait for all to complete
{
  strategy = {
    "parallel",
    {
      { "shell", cmd = "eslint src/" },
      { "shell", cmd = "tsc --noEmit" },
      { "shell", cmd = "prettier --check src/" },
    },
  },
}
```

### Overseer Components

Components are reusable behaviors attached to tasks:

```lua
-- Built-in components:
"default"                    -- standard setup (always add this)
"on_result_notify"           -- show a notification when done
{ "on_output_quickfix",      -- parse output into quickfix list
  set_diagnostics = true,
  errorformat = "%f:%l:%c: %m" }
{ "restart_on_save",         -- auto-restart when files change
  paths = { "src" } }
{ "timeout",                 -- kill task after N seconds
  timeout = 60 }
"on_complete_dispose"        -- clean up task buffers when done
```

You can create your own components:

```lua
require("overseer").register_component("my_notify", {
  desc = "Notify with a custom message",
  params = {
    msg = { desc = "Message template", type = "string", default = "Task done" },
  },
  constructor = function(params)
    return {
      on_complete = function(self, task, status)
        vim.notify(params.msg .. ": " .. status, vim.log.levels.INFO)
      end,
    }
  end,
})
```

### Debugging Neovim DAP Setup Issues

When a debug session fails to connect, work through this checklist:

**1. Check that the adapter binary exists:**

```vim
:lua print(vim.fn.executable(vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"))
```

**2. Check that nvim-dap knows about your adapter:**

```vim
:lua print(vim.inspect(require("dap").adapters))
```

**3. Check that there are configurations for your filetype:**

```vim
:lua print(vim.inspect(require("dap").configurations[vim.bo.filetype]))
```

**4. Enable nvim-dap logging to see the full DAP conversation:**

```lua
require("dap").set_log_level("DEBUG")
-- Log file is at:
vim.fn.stdpath("cache") .. "/dap.log"
```

Open the log file after a failed session attempt to see exactly which message failed and what the adapter responded.

**5. Test the adapter manually:**

For server-type adapters, you can verify the port is being listened on:

```bash
# In a shell, start the adapter manually
node ~/.local/share/nvim/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js 12345
# Should print: DAP server listening at port 12345
```

---

## neotest — Adapter-Specific Details

### neotest-jest Configuration

For monorepos with multiple Jest configurations:

```lua
require("neotest-jest")({
  jestCommand = function(path)
    -- Find the closest package.json with a jest config
    local root = require("neotest.lib").files.match_root_pattern("jest.config.*")(path)
    if root then
      return "npx jest --config " .. root .. "/jest.config.ts"
    end
    return "npx jest"
  end,
  cwd = function(path)
    -- Run from the package root, not the workspace root
    return require("neotest.lib").files.match_root_pattern("package.json")(path)
  end,
})
```

### neotest-python with Coverage

Run tests with coverage and show results:

```lua
require("neotest").run.run({
  extra_args = { "--cov=src", "--cov-report=term-missing" },
})
```

### neotest-go with Test Tables

Go's table-driven tests are supported natively. Given:

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name string
        a, b int
        want int
    }{
        {"positive", 2, 3, 5},
        {"negative", -1, 1, 0},
        {"zero", 0, 0, 0},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            if got := Add(tt.a, tt.b); got != tt.want {
                t.Errorf("Add(%d, %d) = %d, want %d", tt.a, tt.b, got, tt.want)
            }
        })
    }
}
```

The neotest summary panel shows each table entry as a separate test:

```
▼ add_test.go
  ✓ TestAdd/positive
  ✓ TestAdd/negative
  ✓ TestAdd/zero
```

You can run `TestAdd/negative` individually by placing your cursor on the relevant subtable entry name in the test source and pressing `<leader>tN`.

---

## Integrating Everything: A Real Workflow

Here is what a typical debugging workflow looks like when everything is set up and you are comfortable with the bindings, compared to what the same workflow looks like in VSCode.

### VSCode Workflow (for reference)

1. Click the Run and Debug icon in the sidebar (Ctrl+Shift+D)
2. Click the gear icon to open launch.json
3. Add or modify a configuration
4. Click in the gutter next to the line you want to break at
5. Press F5 or click the green play button
6. When paused: hover over variables with the mouse
7. Use the Debug toolbar at the top for F10/F11/Shift+F11
8. Type expressions in the Debug Console
9. Press Shift+F5 to stop

### Neovim Workflow (with this config)

1. Edit your Lua dap config or `.nvim/dap.lua` (one-time setup per project)
2. Navigate to the line you want to break at, press `<leader>dbt`
3. Press `<F5>` to start, choose configuration if prompted
4. When paused: `<F7>` to open UI if not already open, or just look at the scopes panel and virtual text
5. Use `<F2>`/`<F1>`/`<F3>` to step
6. `<leader>dh` to hover a variable, or `<leader>dlr>` to open REPL
7. `<leader>dq` to stop

The Neovim workflow has fewer clicks and your hands stay on the keyboard. The most significant difference is that you need to configure adapters once per language (Mason handles the downloads), after which day-to-day use is very close to VSCode in terms of operations, just keyboard-driven.

---

## Exercises

<a name="exercises"></a>

These exercises reinforce the concepts from this chapter. Each one is designed to be completed in a real project.

### Exercise 1: Set Up and Verify an Adapter

**Goal:** Install a debug adapter for a language you use and verify it works end-to-end.

**Steps:**

1. Pick a language you work with (JavaScript, Python, Go, etc.)
2. Run `:Mason` and install the corresponding adapter if not already installed
3. Create a minimal project with a short script (e.g., a function that adds two numbers)
4. Write a Lua launch configuration for it (or verify the existing one with `:lua print(vim.inspect(require("dap").configurations.javascript))` or your language)
5. Set a breakpoint with `<leader>dbt`
6. Press `<F5>`, choose your configuration, and verify that execution pauses at your breakpoint
7. Open the Scopes panel and verify the local variables are visible
8. Press `<F2>` to step over and verify the current line indicator moves

**Success criteria:** You can see local variable values in the Scopes panel while paused.

### Exercise 2: Conditional Breakpoints and the REPL

**Goal:** Use a conditional breakpoint and the REPL to investigate a loop.

**Steps:**

1. Write or find a function that loops over a collection (e.g., iterates over a list of items and computes something)
2. Set a conditional breakpoint inside the loop that only triggers when a specific condition is met (e.g., `i === 5` for the 6th iteration, or `item.price > 100`)
3. Press `<F5>` to start
4. When the breakpoint triggers, open the REPL with `<leader>dlr`
5. Type expressions to inspect the loop state
6. Add a watch expression that tracks the current item

**Success criteria:** The breakpoint only pauses on the iteration matching your condition. You can evaluate arbitrary expressions in the REPL.

### Exercise 3: Debug a Failing Test

**Goal:** Use neotest and nvim-dap together to debug a failing test.

**Steps:**

1. Find or write a test that fails (ideally one where the failure reason is not immediately obvious)
2. Press `<leader>tN` with your cursor inside the test to run it and confirm it fails
3. Press `<leader>tO` to view the output and understand what is failing
4. Set a breakpoint in the function being tested (not the test itself, but the code it calls)
5. Press `<leader>td` to debug the test with DAP
6. Step through the code and find the line where the state diverges from your expectation
7. Fix the bug

**Success criteria:** You use the neotest output to understand the failure, then use nvim-dap stepping to find the exact line causing it.

### Exercise 4: Create a Custom Overseer Task

**Goal:** Define a project-specific Overseer task that runs multiple steps.

**Steps:**

1. In a project with a build step (npm build, cargo build, make, etc.), create a `.nvim/tasks.lua` file
2. Define an Overseer template that:
   - Runs the linter
   - If linting passes, runs the type checker or tests
   - Shows a notification on success or failure
3. Load the tasks file from your init.lua or using a VimEnter autocmd
4. Press `<leader>tr` and verify your custom task appears in the picker
5. Run it and verify both steps execute in sequence

**Success criteria:** Your custom task appears in the picker and runs both steps, with the second step only running when the first succeeds.

### Exercise 5: Load a .vscode/launch.json

**Goal:** Set up a project that uses `.vscode/launch.json` and debug it from Neovim.

**Steps:**

1. Find or create a project that has a `.vscode/launch.json` (many open-source projects have one)
2. Add the `load_launchjs` call to your nvim-dap configuration, mapped to a keybinding (e.g., `<leader>dl`)
3. Press `<leader>dl` to load the configuration
4. Press `<F5>` and verify that the configurations from `.vscode/launch.json` appear in the picker
5. Launch one of the configurations and verify it works

**Bonus:** Find a configuration in `.vscode/launch.json` that uses `${workspaceFolder}` or `${file}` variables and verify that nvim-dap resolves them correctly.

**Success criteria:** You can use an existing `.vscode/launch.json` without modifying your global nvim-dap configuration. The project-specific configurations appear alongside your global configurations in the picker.

---

## Summary

Here is what you now know:

- **Architecture:** DAP is a protocol. nvim-dap is a client. The adapters are the same binaries VSCode uses. Mason installs them.
- **Breakpoints:** `<leader>dbt` to toggle, `<leader>dbc` for conditional. They persist across sessions within the same Neovim instance.
- **Stepping:** `<F5>` start/continue, `<F1>` step-into, `<F2>` step-over, `<F3>` step-out. These mirror VSCode's F11/F10/Shift+F11 but in more logical positions.
- **Inspection:** Scopes panel for passive inspection, `<leader>dh` for hover, `<leader>dlr` for the REPL. The REPL is a real Neovim buffer.
- **Per-language:** Each language has an adapter (Mason) and configurations (Lua or `.vscode/launch.json`). The Go setup is the most automated (nvim-dap-go handles everything). Rust needs a build step before the adapter can find the binary.
- **neotest:** Discovers and runs tests with `<leader>tN`, `<leader>tF`, `<leader>tO`, `<leader>tS`. Integrates with DAP for `<leader>td`.
- **Overseer:** Task runner with `<leader>tr` to launch, `<leader>tt` to see running tasks. Reads `.vscode/tasks.json` automatically. Supports complex multi-step Lua tasks.

The initial setup — installing adapters, writing launch configurations — takes a few hours. After that, the day-to-day experience is faster than VSCode because you never need the mouse.

---

_Next: [10 · Git Workflow Inside Neovim](./10-git-workflow.md)_
