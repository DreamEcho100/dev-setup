# Debug, Test, and Build

This chapter documents the debugger configuration that is actually shipped by
this repository. It targets Neovim 0.12 and the current `nvim-dap` API.

The important distinction is:

```text
LSP                         DAP
-------------------------   --------------------------
completion and hover        breakpoints and stepping
diagnostics                 scopes and variables
rename and code actions     watches and debug console

neotest                     Overseer
-------------------------   --------------------------
test discovery and output   build and task execution
can use DAP for tests        can launch tests/debuggers
```

`nvim-dap` is a Debug Adapter Protocol client. It does not contain a debugger.
Each language still needs a compatible adapter such as `debugpy`, Delve, or
CodeLLDB.

## 1. What This Config Supports

### Default adapters

These adapters are installed through Mason and configured automatically:

| Language or runtime | Adapter | Neovim integration | Notes |
| --- | --- | --- | --- |
| JavaScript/TypeScript | `js-debug-adapter` | direct `nvim-dap` config | Node and Chromium browser sessions |
| Python | `debugpy` | `nvim-dap-python` | uses project virtual environments |
| Go | Delve (`dlv`) | `nvim-dap-go` | programs and nearest tests |
| C/C++ | CodeLLDB | direct `nvim-dap` config | compile with debug symbols |
| Rust | CodeLLDB | `rustaceanvim` | Rust owns its DAP configuration |
| Lua programs | Local Lua Debugger | direct `nvim-dap` config | launches the current Lua file |
| Neovim Lua | OSV | `one-small-step-for-vimkind` | attach from a second Neovim process |
| Zig | CodeLLDB | native config | debug an executable built with symbols |
| Odin | CodeLLDB | native config | debug an executable built with symbols |

### Optional adapters

These are configured only when their runtimes or tools are available:

| Language/runtime | Adapter | Enable/install |
| --- | --- | --- |
| Java | `java-debug-adapter` and `java-test` | install Java 21+; `nvim-jdtls` starts per project |
| C#/.NET | `netcoredbg` | install .NET 10 with `--with-dotnet` or `DE100_INSTALL_DOTNET=true` |
| Godot/GDScript | Godot's built-in DAP server | install Godot with `--with-godot`; run the project with its debug server |

### Deliberate exclusions

Not every filetype has a meaningful debugger.

| Filetypes/workflows | Use instead |
| --- | --- |
| Bash/sh | `bash -x`, `set -x`, ShellCheck, tests, or an external Bash debugger when a project truly needs one |
| HTML/CSS/Markdown/LaTeX | browser preview, renderer logs, linting, and validation |
| JSON/YAML/TOML | schema diagnostics, formatter, and validation |
| SQL | Dadbod query execution and database-native explain/profiling tools |
| Docker/Compose | container logs, `docker exec`, health checks, and attach to the process inside the container |
| Terraform/Ansible | plan/check mode, validation, logs, and test tools |

The old Chrome Debug Adapter is intentionally absent. It is archived; current
JavaScript debugging uses Microsoft's `vscode-js-debug` through Mason's
`js-debug-adapter` package. A stale Bash adapter is also not installed by
default merely to make the support list look longer.

## 2. VS Code Key Translation

The function keys match VS Code where terminals can report the key reliably:

| Action | Neovim | VS Code |
| --- | --- | --- |
| Start or continue | `<F5>` | F5 |
| Stop | `<S-F5>` | Shift+F5 |
| Toggle breakpoint | `<F9>` | F9 |
| Step over | `<F10>` | F10 |
| Step into | `<F11>` | F11 |
| Step out | `<S-F11>` | Shift+F11 |
| Toggle debug UI | `<F7>` | open/close Run and Debug view |

The leader namespace works even when a terminal consumes an F-key:

| Mapping | Action |
| --- | --- |
| `<leader>dapc` | start or continue |
| `<leader>dapn` | create a new session |
| `<leader>dapx` | terminate |
| `<leader>dapl` | rerun the last configuration |
| `<leader>dapo` | step over |
| `<leader>dapi` | step into |
| `<leader>dapO` | step out |
| `<leader>dapp` | pause |
| `<leader>dapt` | debug the nearest test for the current filetype |
| `<leader>daptb` | toggle breakpoint |
| `<leader>dapb` | conditional breakpoint |
| `<leader>dapL` | log point |
| `<leader>dapr` | open DAP REPL |
| `<leader>dape` | evaluate expression or visual selection |
| `<leader>dapu` | toggle DAP UI |
| `<leader>dapq` | list breakpoints |
| `<leader>dapC` | clear breakpoints |
| `<leader>daph` | show repository-specific DAP health |
| `<leader>dapP` | review and load a trusted project `.nvim/dap.lua` |

Use `:WhichKey <leader>dap` if you forget a mapping.

## 3. The Normal Debug Loop

1. Build the program with debug information if the language requires it.
2. Put the cursor on a line and press `<F9>`.
3. Press `<F5>` and select a configuration.
4. Use `<F10>`, `<F11>`, and `<S-F11>` to step.
5. Inspect scopes, stacks, breakpoints, and the REPL in DAP UI.
6. Put the cursor over an expression and press `<leader>dape`.
7. Press `<S-F5>` when finished.

DAP UI opens when a session initializes and closes when it terminates or exits.
Inline values come from `nvim-dap-virtual-text`; they are cleared while the
program continues so stale values are less likely to be mistaken for live
state.

## 4. Installing and Checking Adapters

Run:

```vim
:Mason
:MasonUpdate
:MasonToolsUpdate
:checkhealth dap
:De100DapHealth
```

Mason installs the configured binaries. Lazy plugin specs live in
`lua/de100/plugins/dap/`, while adapter/runtime setup is explicit Lua under
`lua/de100/config/dap/`. This avoids an extra adapter-name translation layer
and makes the command used for every adapter inspectable.

`De100DapHealth` reports:

- current filetype and working directories;
- configurations available for that filetype;
- adapter definitions selected by those configurations;
- paths for relevant runtimes and adapter executables;
- nearest `.vscode/launch.json` and `.nvim/dap.lua`;
- DAP log location.

Open the log when an adapter exits before a session starts:

```vim
:lua vim.cmd.edit(vim.fs.joinpath(vim.fn.stdpath('log'), 'dap.log'))
```

## 5. Project Configuration and Trust

### `.vscode/launch.json`

Current `nvim-dap` discovers `.vscode/launch.json` on demand. Do not call the
deprecated `require('dap.ext.vscode').load_launchjs()` function.

The repository maps common VS Code adapter types to Neovim filetypes, including
`pwa-node`, `pwa-chrome`, `debugpy`, `go`, `codelldb`, `coreclr`, and `java`.
Strict JSON is safest. Adapter-specific properties still have to be supported by
the adapter itself; VS Code extension-only commands do not automatically exist
in Neovim.

Example Node configuration:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "API: dev server",
      "type": "pwa-node",
      "request": "launch",
      "runtimeExecutable": "pnpm",
      "runtimeArgs": ["dev"],
      "cwd": "${workspaceFolder}",
      "console": "integratedTerminal",
      "skipFiles": ["<node_internals>/**"]
    }
  ]
}
```

Start Neovim from the project root, or use a project-aware working directory,
because `${workspaceFolder}` resolves from the DAP workspace context.

### `.nvim/dap.lua`

A Lua file can execute arbitrary code, so this config never auto-executes it.
Press `<leader>dapP` or run `:De100DapLoadProject`. Neovim shows the exact path
and asks for confirmation before loading it once for the current process.

The file must return a table:

```lua
return {
  adapters = {
    custom = {
      type = "server",
      host = "127.0.0.1",
      port = 4711,
    },
  },
  configurations = {
    lua = {
      {
        name = "Project service",
        type = "custom",
        request = "launch",
      },
    },
  },
}
```

Commit project Lua only when every collaborator understands that it is trusted
executable code. Prefer `launch.json` for portable declarative configuration.

## 6. JavaScript, TypeScript, and Web Frameworks

The config provides:

- `Node: launch current file`;
- `Node: attach to process`;
- `Browser: launch application`;
- `Browser: attach on port 9222`.

Node configurations are available for JavaScript, JSX, TypeScript, and TSX.
Browser configurations are also available for Astro, Svelte, and Vue. The
browser URL is prompted at launch; `http://localhost:3000` is the default.

For a framework dev server:

1. Start the server with Overseer, tmux, or another terminal.
2. Put breakpoints in source files.
3. Choose `Browser: launch application` and enter the actual development URL.
4. If breakpoints are unbound, verify source maps and `webRoot`.

To attach to an existing Chromium process, start it with a debugging port, for
example:

```bash
chromium --remote-debugging-port=9222 --user-data-dir=/tmp/chromium-dap
```

Then choose `Browser: attach on port 9222`.

For Vitest/Jest test debugging, project scripts vary too much for a safe global
guess. Put the runtime arguments in `.vscode/launch.json` or use Neotest with
the DAP strategy when the adapter supports it.

## 7. Python

`nvim-dap-python` wraps `debugpy` and adds test helpers. It does not hardcode
`/usr/bin/python3`. At session time it can use project environments such as
`.venv`, `venv`, Poetry, or the Python executable selected by project tooling.

Typical setup:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -e '.[dev]'
```

Then open a Python file, press `<F9>`, and `<F5>`. Use `<leader>dapt` on a test
method to invoke `dap-python`'s nearest-test workflow.

If imports differ between a normal run and debugging, compare:

```vim
:De100DapHealth
:LspInfo
:ConformInfo
```

and check the Python executable/environment selected by the project.

## 8. Go

Go uses Delve through `nvim-dap-go`.

```bash
go test ./...
go build ./...
dlv version
```

Press `<F5>` for program debugging. Put the cursor inside a test and press
`<leader>dapt` to call `dap-go.debug_test()`.

Debugging does not repair module resolution. If local imports fail, first make
the shell commands succeed and verify `go.mod`, `go.work`, and `go env GOWORK`.
`gopls`, `go test`, and Delve should agree about the workspace before debugging
is expected to work.

## 9. C, C++, Zig, and Odin

These filetypes share CodeLLDB. The default configuration asks for the compiled
executable; it does not guess build-system output.

C/C++ example:

```bash
cc -g -O0 -o build/app src/main.c
c++ -g -O0 -o build/app src/main.cpp
```

Zig and Odin builds should also retain symbols. Select the resulting executable
when prompted by `Native: launch executable`.

Use `Native: attach to process` to pick an already-running process. The config
hides disassembly by default so stepping stays at source level when symbols are
available.

For CMake projects, use Overseer to configure/build first, then debug the
result. A project `launch.json` is appropriate when the output path is stable.

## 10. Rust

Rust debugging is owned by `rustaceanvim`, not duplicated in the generic native
configuration. `rustaceanvim` discovers CodeLLDB and creates Rust-aware run and
test actions.

Use Rust code actions/runnables for Cargo targets. Generic `launch.json`
configurations with type `codelldb` remain recognized for Rust when a project
needs a fixed executable or arguments.

## 11. Lua and Neovim Lua

### Standalone Lua

Choose `Lua: launch current file`. The Local Lua Debugger adapter runs the
current file with `lua5.1` when available, otherwise `lua`.

### Neovim configuration/plugins

Debugging Neovim itself requires two processes:

1. In the Neovim process running the code, execute `:De100DapLuaServer`.
2. In a second Neovim process, open the same Lua source.
3. Choose `Neovim Lua: attach on port 8086` with `<F5>`.

The first process hosts OSV on localhost; the second process is the DAP client.
Do not expose the port on an untrusted network.

## 12. Optional Java

Java uses `nvim-jdtls`, not the central generic LSP startup. Opening a Java file
starts or attaches JDTLS with a project-specific state directory and injects the
Mason Java debug/test bundles.

Requirements:

```bash
java -version        # Java 21 or newer
javac -version       # the full JDK, not only a JRE
```

Run `:Mason` and verify `jdtls`, `java-debug-adapter`, and `java-test`. Then open
the project from a directory containing Maven/Gradle markers or `.git`.

`<leader>dapt` calls `jdtls.test_nearest_method()`. Hot code replacement is set
to automatic when the adapter supports it.

## 13. Optional C#/.NET

Install the optional stack:

```bash
dev-env/runs/neovim --with-dotnet
```

The runner installs .NET 10 LTS and Mason installs `netcoredbg`. The launch
configuration searches Debug output directories and asks which assembly to
run. Build before debugging:

```bash
dotnet restore
dotnet build
```

If several DLLs exist, select the application assembly rather than a `.deps`,
reference, or test-host DLL. Use a project `launch.json` to remove ambiguity.

## 14. Optional Godot/GDScript

Install the opt-in runtime:

```bash
dev-env/runs/neovim --with-godot
```

Godot owns the GDScript debug adapter and listens on localhost port 6006 during
debugging. Open the project in Godot, enable/run its debug session, then choose
`Godot: launch project` in Neovim. If the connection is refused, Godot is not
listening or the project/editor settings use another port.

## 15. Tests

`<leader>dapt` dispatches by current filetype:

```text
Go       -> nvim-dap-go nearest test
Python   -> nvim-dap-python nearest method
Java     -> nvim-jdtls nearest method
Others   -> neotest with strategy = "dap"
```

A test adapter must support DAP for the generic Neotest path to work. Running a
test and debugging a test are separate operations; use the normal Neotest keys
when you only need output and speed.

## 16. Build and Task Workflows

DAP starts and controls a debug session. It should not become a replacement for
the build system.

Use Overseer for repeatable tasks such as:

- compile/build;
- run a dev server;
- run all tests;
- lint or type-check;
- generate assets;
- start dependencies.

Use a terminal or tmux when a command needs long-lived interactive control.
Once the program exists or is listening, launch/attach DAP.

## 17. Containers, Remote Processes, and Path Mapping

The adapter and debugged process must agree about source paths. In containers
or remote environments, configure adapter-specific mappings in
`.vscode/launch.json`. Typical concepts are `localRoot`/`remoteRoot` or a
`sourceFileMap`, but exact property names differ by adapter.

Prefer running Neovim and the adapter inside the same dev container/remote host.
If attaching across a network:

- tunnel the DAP port over SSH;
- bind to localhost where possible;
- never expose an unauthenticated debug port publicly;
- verify local and remote source paths.

## 18. Troubleshooting

### No configuration appears

Run:

```vim
:set filetype?
:De100DapHealth
```

The current buffer needs a configuration registered for its exact filetype.

### Adapter executable is missing

Run `:Mason`, install/update the named package, and restart Neovim. Check the
path in `:De100DapHealth`.

### Breakpoint stays hollow or is rejected

Common causes:

- no debug symbols;
- optimized/generated code;
- stale source maps;
- source path mismatch;
- line is not executable;
- wrong process or build artifact.

### Session starts and immediately exits

Read `dap.log`, then run the adapter command shown by health output in a shell.
Also verify program path, arguments, environment, and working directory.

### Terminal does not send Shift+F11

Use the leader mappings or configure Kitty/Ghostty to emit a distinct sequence.
The debugger itself is not responsible for terminal key encoding.

### `launch.json` is ignored

Check that it is at `.vscode/launch.json`, the file is valid JSON, the `type`
has a registered filetype mapping, and Neovim's workspace directory is correct.
Do not add the deprecated manual loader.

### Project Lua did not load

That is intentional. Run `:De100DapLoadProject`, inspect the displayed path,
and explicitly choose `Load once`.

## 19. Maintenance Rules

1. Pin Neovim plugins in `lazy-lock.json`.
2. Let Mason manage adapter binaries that it supports.
3. Keep Lazy specs under `lua/de100/plugins/dap/` and runtime adapter setup
   under `lua/de100/config/dap/`.
4. Do not auto-update adapters during every startup.
5. Do not execute project Lua without a trust prompt.
6. Add an adapter only when a real project and maintained adapter justify it.
7. Test launch, attach, breakpoints, stepping, and termination before claiming a
   language is supported.

Primary references:

- <https://github.com/mfussenegger/nvim-dap>
- <https://microsoft.github.io/debug-adapter-protocol/implementors/adapters/>
- <https://codeberg.org/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation>
- <https://github.com/microsoft/vscode-js-debug>
- <https://github.com/mfussenegger/nvim-dap-python>
- <https://github.com/leoluz/nvim-dap-go>
- <https://github.com/mfussenegger/nvim-jdtls>
- <https://github.com/jbyuki/one-small-step-for-vimkind>

## 20. Practice Checklist

- [ ] Run `:De100DapHealth` in one supported filetype.
- [ ] Set, list, and clear a breakpoint.
- [ ] Launch and terminate a session.
- [ ] Step over, into, and out.
- [ ] Evaluate an expression in normal and visual mode.
- [ ] Open the REPL and inspect scopes in DAP UI.
- [ ] Debug a nearest Go, Python, or Java test when that toolchain is installed.
- [ ] Add a portable `.vscode/launch.json` to one project.
- [ ] Explain why `.nvim/dap.lua` requires explicit trust.
- [ ] Find and read `dap.log` after intentionally giving DAP a bad executable.

Once these are routine, debugging in Neovim is no longer a collection of plugin
commands. It is the same DAP model used by VS Code, with explicit ownership of
the adapter, project configuration, build artifact, and source mapping.
