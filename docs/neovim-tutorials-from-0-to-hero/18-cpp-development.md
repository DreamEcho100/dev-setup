# Chapter 18 — C/C++ Development in Neovim

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║    C / C++  ────────────────────────────────────►  clangd + cmake           ║
║                                                                              ║
║    [ Real includes. Real types. Real debugging. ]                            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

> **Prerequisites:** You've read Chapters 07 (LSP) and 10 (debugging). You
> understand what an LSP server is and how DAP works. No prior C++ Neovim
> experience required — but you should have written C or C++ code before in
> any editor.

---

## The C/C++ Toolchain at a Glance

Before diving in, here's a map of every tool in play and how they connect:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      C/C++ Development Stack                                │
│                                                                             │
│  Your .cpp/.c files                                                         │
│       │                                                                     │
│       ├─── clangd (LSP server) ─────────────────────────────────────────┐  │
│       │     │  reads compile_commands.json to understand includes        │  │
│       │     ├── completions, diagnostics, go-to-definition              │  │
│       │     ├── inlay hints (parameter names, deduced types)            │  │
│       │     ├── clang-tidy integration (lint on save)                   │  │
│       │     └── <leader>lh  header ↔ source switch                     │  │
│       │                                                                  │  │
│       ├─── clang-format ─────────────────────────────────────────────── │  │
│       │     reads .clang-format in project root                         │  │
│       │     triggered by <leader>mp (format file)                       │  │
│       │                                                                  │  │
│       ├─── cmake-tools.nvim ──────────────────────────────────────────  │  │
│       │     reads CMakeLists.txt                                         │  │
│       │     generates build/ and compile_commands.json → feeds clangd  │  │
│       │     integrates with overseer for build tasks                    │  │
│       │                                                                  │  │
│       ├─── nvim-dap + codelldb ─────────────────────────────────────────│  │
│       │     debugger; works on debug-symbol binaries                    │  │
│       │     <F5> launch, <F9> breakpoint, <F10> step over               │  │
│       │                                                                  │  │
│       └─── neotest + neotest-ctest ──────────────────────────────────── │  │
│             runs CTest (GoogleTest / Catch2 / doctest)                  │  │
│             <leader>tn run nearest test, <leader>ts toggle summary       │  │
│                                                                          │  │
└──────────────────────────────────────────────────────────────────────────┘
```

The most critical thing in this entire diagram: `compile_commands.json`. Without
it, clangd can't understand your includes, your types, or your project structure.
Everything else depends on getting this right first.

---

## Part 1 — compile_commands.json: The Critical First Step

### Why clangd Needs This File

Unlike Python or JavaScript, C/C++ code is not self-describing. The compiler
needs to know:

- Which header include paths are active (`-I/usr/local/include`)
- Which preprocessor flags are defined (`-DDEBUG`, `-DPLATFORM_LINUX`)
- Which C++ standard is being used (`-std=c++20`)
- Which warnings are enabled or suppressed

All of this is encoded in your build system (CMake, Make, Bazel, etc.) and
normally only the compiler knows it. `compile_commands.json` is the file that
exports these flags per-source-file so that clangd can use them too.

Without it, clangd has to guess — and it gets includes wrong constantly,
flooding you with false "file not found" errors and completely wrong completions.

### What It Looks Like

```json
[
  {
    "directory": "/home/user/myproject",
    "command": "clang++ -std=c++20 -I/usr/local/include -DDEBUG -o src/main.o -c src/main.cpp",
    "file": "src/main.cpp"
  },
  {
    "directory": "/home/user/myproject",
    "command": "clang++ -std=c++20 -I/usr/local/include -o src/utils.o -c src/utils.cpp",
    "file": "src/utils.cpp"
  }
]
```

One entry per source file. clangd reads this on startup and builds a complete
understanding of your project.

### Generating It: CMake Projects (Recommended)

If your project uses CMake (a `CMakeLists.txt` file), this is automatic.

**One-time flag to add to your CMakeLists.txt or configure command:**

```cmake
# In CMakeLists.txt (add near the top, after project()):
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

Or pass it at configure time:

```bash
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

This tells CMake to write `build/compile_commands.json`. But clangd looks
for the file in the project root, not in `build/`. There are two solutions:

**Option 1: Symlink (automatic with cmake-tools.nvim)**

The cmake-tools.nvim plugin in this config has `cmake_soft_link_compile_commands = true`,
which automatically creates a symlink from `./compile_commands.json` →
`./build/compile_commands.json`. No manual steps needed.

**Option 2: Manual symlink (for command-line use)**

```bash
ln -sf build/compile_commands.json compile_commands.json
```

**Option 3: Tell clangd where to find it (via `.clangd` config file)**

Create `.clangd` in your project root:

```yaml
CompileFlags:
  CompilationDatabase: build/
```

### Generating It: Non-CMake Projects (bear)

If you're using a plain Makefile, a custom build script, or just compiling by
hand, use `bear`:

```bash
# Wrap your build command with bear:
bear -- make
bear -- make all
bear -- g++ -std=c++20 -o myapp main.cpp utils.cpp

# This creates compile_commands.json in the current directory.
```

`bear` intercepts compiler calls and records their arguments. It works with any
build system that actually invokes the compiler.

### Generating It: cmake-tools.nvim (the Neovim way)

Once you're in Neovim on a CMake project, press `<leader>mcmg` (CMake generate).
cmake-tools.nvim runs:

```bash
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
```

...and then symlinks `build/compile_commands.json` to `./compile_commands.json`.
clangd detects the new file and re-indexes automatically.

From then on, every time you save `CMakeLists.txt`, cmake-tools.nvim
re-runs configure (`cmake_regenerate_on_save = true`) and the compile commands
stay up to date.

> **Limitation:** `cmake_regenerate_on_save` only watches the **root**
> `CMakeLists.txt`. It does NOT fire for:
>
> - `CMakeLists.txt` files in subdirectories
> - Adding a new `.cpp` source file (add it to `CMakeLists.txt` AND re-run
>   `<leader>mcmg`)
> - Changes to `.h` header files (clangd handles headers directly — no cmake
>   re-run needed)

### Verify clangd Is Reading It

Open a `.cpp` file and run:

```
:LspInfo
```

You should see `clangd` in the attached servers list. If clangd is attached but
completions are wrong or there are false-positive errors, check:

```bash
# From a terminal in your project root:
ls -la compile_commands.json    # Should exist
cat compile_commands.json | head -20    # Should have entries
```

If missing, generate it (CMake configure or `bear`).

---

## Part 2 — Installing the C/C++ Stack

### What the Ansible Playbook Installs

Running `ansible-playbook neovim.yml -K` installs everything system-wide:

| Tool           | Purpose                         | Installed Via                         |
| -------------- | ------------------------------- | ------------------------------------- |
| `clangd`       | LSP server                      | apt (llvm-dev or clang-tools package) |
| `clang-format` | Auto-formatter                  | apt (clang-format)                    |
| `clang-tidy`   | Linter                          | apt (clang-tidy)                      |
| `cmake`        | Build system                    | apt                                   |
| `ninja-build`  | Fast build backend              | apt                                   |
| `bear`         | compile_commands.json generator | apt (optional)                        |
| `gdb`          | GNU debugger (fallback)         | apt                                   |

### Neovim Plugin Installation

The Neovim plugins (cmake-tools.nvim, clangd_extensions.nvim, neotest-ctest)
are managed by lazy.nvim. They install on first launch:

```
:Lazy sync
```

Or on first open of a `.cpp` file (they load lazily via `ft = { "c", "cpp" }`).

### Verify Everything Is Working

Open any `.c` or `.cpp` file and check:

```
:LspInfo        → should show "clangd" as attached
:checkhealth    → look for clangd section
```

On a file with `#include <vector>`, press `K` on `vector` — you should get the
documentation popup. If you see `[LSP] No information available`, clangd isn't
attached or can't find the include.

---

## Part 3 — clangd LSP Keymaps

All the standard LSP keymaps from Chapter 07 work in C/C++ files. Here's the
complete reference with C++-specific ones highlighted:

### Standard LSP Keys (All Languages)

| Key          | Action                   | VSCode Equivalent      |
| ------------ | ------------------------ | ---------------------- |
| `K`          | Hover documentation      | Ctrl+K on hover        |
| `gd`         | Go to definition         | F12                    |
| `gD`         | Go to declaration        | (no direct equivalent) |
| `gr`         | Find all references      | Shift+F12              |
| `gI`         | Go to implementation     | Ctrl+F12               |
| `<leader>lr` | Rename symbol            | F2                     |
| `<leader>la` | Code actions             | Ctrl+.                 |
| `<leader>lf` | Format file              | Shift+Alt+F            |
| `<leader>ld` | Open diagnostics list    | Problems panel         |
| `<leader>li` | Toggle inlay hints       | (no direct equivalent) |
| `[d` / `]d`  | Previous/next diagnostic | (no direct equivalent) |

### C/C++ Specific Keys

| Key            | Action                 | When to Use                                         |
| -------------- | ---------------------- | --------------------------------------------------- |
| `<leader>lsph` | Switch header ↔ source | Flip between `.h` and `.cpp`                        |
| `<leader>lspA` | Clangd AST view        | See the Abstract Syntax Tree for current node       |
| `<leader>lspT` | Type hierarchy         | See base/derived class relationships                |
| `<leader>lspS` | Symbol info            | Detailed type/location info for symbol under cursor |
| `<leader>lspM` | Clangd memory usage    | Debug clangd if it's eating too much RAM            |

### `<leader>lsph` — Header/Source Switch

This is the most-used C++ specific key. In any C or C++ file:

```
You're in:     main.cpp
Press:         <leader>lh
You're now in: main.h   (or main.hpp)
```

If the corresponding file doesn't exist, clangd will offer to create it. This
is faster than any file picker for the header/source dance.

**Common pattern:** You're implementing a method. It's declared in `Foo.h`.
You're editing `Foo.cpp`. Press `<leader>lh` to check the declaration, then
`<leader>lh` again to come back.

### `<leader>lspcA` — AST View

Opens a tree view of the Abstract Syntax Tree for the code near your cursor.
This is mostly useful for:

- Understanding why the compiler sees something differently than you do
- Debugging template instantiation issues
- Learning C++ semantics deeply

Example: cursor on a lambda expression → `:ClangdAST` shows you how clang
decomposes it into a `LambdaExprClass` with a `CXXMethodDecl` and capture list.

### Inlay Hints

In C++ files, inlay hints show:

- **Parameter names** at call sites: `foo(/*count=*/5, /*name=*/"bar")`
- **Deduced `auto` types**: `auto x = getWidget(); // ← Widget*`
- **Return types** in lambdas

Toggle with `<leader>li`. They're off by default (a Neovim 0.12.x rendering
bug with inline hints; they're safe to enable in 0.13+).

When enabled, they look like:

```cpp
std::sort(v.begin(), v.end(), [](auto a, auto b) {
//                                   ↑Widget  ↑Widget   ← inlay hints
    return a.name < b.name;
});
```

---

## Part 4 — cmake-tools.nvim: Building from Inside Neovim

### Overview

cmake-tools.nvim is the VS Code `cmake-tools` extension equivalent for Neovim.
It manages the entire CMake workflow without you leaving your editor.

The plugin integrates with `overseer.nvim` (already installed) to run builds
as tasks with real-time output in a terminal panel.

### The CMake Workflow

A typical CMake project workflow:

```
1. Open project in Neovim
2. <leader>mcmg    → Configure (cmake -B build ...)
3. <leader>mcmT    → Select build type (Debug / Release / RelWithDebInfo)
4. <leader>mcms    → Select build target (which binary to build)
5. <leader>mcmb    → Build selected target
6. <leader>mcmr    → Run selected target
```

### cmake-tools.nvim Keymaps

All under `<leader>m` (the "make/cmake/format" group):

| Key            | Command                   | What It Does                                  |
| -------------- | ------------------------- | --------------------------------------------- |
| `<leader>mcmg` | `:CMakeGenerate`          | Configure the project (cmake -B build)        |
| `<leader>mcmb` | `:CMakeBuild`             | Build the selected target                     |
| `<leader>mcmr` | `:CMakeRun`               | Run the selected target                       |
| `<leader>mcmt` | `:CMakeTest`              | Run CTest tests                               |
| `<leader>mcmc` | `:CMakeClean`             | Clean the build directory                     |
| `<leader>mcms` | `:CMakeSelectBuildTarget` | Pick which binary to build                    |
| `<leader>mcmT` | `:CMakeSelectBuildType`   | Debug / Release / RelWithDebInfo / MinSizeRel |
| `<leader>mcmo` | `:CMakeOpen`              | Open cmake-tools panel                        |
| `<leader>mp`   | (existing)                | Format file (clang-format)                    |

### First CMake Project: Step by Step

Let's walk through setting up a brand new C++ project from scratch.

**Step 1: Create the project directory**

```bash
mkdir ~/Desktop/workspaces/hello-cpp
cd ~/Desktop/workspaces/hello-cpp
```

**Step 2: Create the CMakeLists.txt**

```cmake
cmake_minimum_required(VERSION 3.20)
project(HelloCpp VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(hello src/main.cpp)
```

**Step 3: Create the source file**

```bash
mkdir src
```

Create `src/main.cpp`:

```cpp
#include <iostream>
#include <string_view>

int main() {
    std::string_view greeting = "Hello, C++ in Neovim!";
    std::cout << greeting << '\n';
    return 0;
}
```

**Step 4: Open Neovim and configure**

```bash
nvim .
```

Press `<leader>mcmg` → cmake-tools runs the configure step → `build/` directory
is created with `compile_commands.json` → symlinked to project root →
clangd re-indexes.

**Step 5: Build and run**

```
<leader>mcms    → select "hello" target
<leader>mcmb    → build it (overseer opens a terminal panel)
<leader>mcmr    → run it (should print "Hello, C++ in Neovim!")
```

**Step 6: Switch to Debug build**

```
<leader>mcmT    → select "Debug"
<leader>mcmb    → rebuild with -g symbols (needed for debugger)
```

### CMakeLists.txt Best Practices

For projects you'll debug:

```cmake
# Always export compile commands
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Separate debug and release flags
target_compile_options(myapp PRIVATE
    $<$<CONFIG:Debug>:-g -O0 -fsanitize=address>
    $<$<CONFIG:Release>:-O2 -DNDEBUG>
)

# For clang-tidy integration:
set(CMAKE_CXX_CLANG_TIDY "clang-tidy;-checks=*")
```

---

## Part 5 — Code Style: clang-format

### How Formatting Works

`clang-format` is the formatting tool for C/C++. It reads a `.clang-format`
file in your project root (or any parent directory) for style rules.

In Neovim, `<leader>lf` or `<leader>mp` (format) runs `conform.nvim` which
calls `clang-format` on the current buffer.

### Creating a `.clang-format` File

You have several style bases to choose from. Here are the most common:

**LLVM style** (what this config defaults to if no `.clang-format` exists):

```yaml
BasedOnStyle: LLVM
IndentWidth: 4
ColumnLimit: 100
```

**Google style** (popular in open-source projects):

```yaml
BasedOnStyle: Google
IndentWidth: 2
ColumnLimit: 80
```

**Mozilla style** (good balance):

```yaml
BasedOnStyle: Mozilla
IndentWidth: 4
ColumnLimit: 80
```

**Custom (common choices):**

```yaml
BasedOnStyle: LLVM
IndentWidth: 4
ColumnLimit: 100
AccessModifierOffset: -4
AlignAfterOpenBracket: Align
AlignConsecutiveAssignments: false
AlignTrailingComments: true
AllowShortFunctionsOnASingleLine: Inline
BraceWrapping:
  AfterClass: true
  AfterFunction: true
BreakBeforeBraces: Custom
IncludeBlocks: Regroup
SortIncludes: CaseSensitive
SpaceAfterCStyleCast: false
SpaceBeforeParens: ControlStatements
```

Generate a full config for a base style:

```bash
clang-format --dump-config --style=LLVM > .clang-format
```

Then edit it to your preferences.

### Verify It Works

Open any `.cpp` file, make some messy changes, then:

```
<leader>mp    → should reformat to match .clang-format
```

Or check what clang-format would do without saving:

```bash
clang-format --dry-run --Werror src/main.cpp
```

---

## Part 6 — Linting: clang-tidy

### What clang-tidy Does

clang-tidy is a static analysis tool that catches:

- Modernization opportunities (C++11/14/17/20 idioms)
- Performance issues (unnecessary copies, redundant operations)
- Readability improvements (naming conventions, code structure)
- Bug-prone patterns (use-after-move, dangling references)
- Security issues (buffer overflows, format string vulnerabilities)

### Integration with clangd

The clangd config in `lsp.lua` includes `--clang-tidy` flag:

```lua
cmd = {
    "clangd",
    "--clang-tidy",   -- ← this enables clang-tidy integration
    ...
}
```

With this flag, clangd runs clang-tidy in the background and reports findings
as LSP diagnostics. They appear in your buffer as warnings (yellow underlines)
or errors (red underlines).

### The `.clang-tidy` Config File

Create `.clang-tidy` in your project root:

```yaml
# .clang-tidy
Checks: >
  -*,
  modernize-*,
  performance-*,
  readability-*,
  -readability-magic-numbers,
  -modernize-use-trailing-return-type
WarningsAsErrors: ""
HeaderFilterRegex: ".*"
FormatStyle: file
```

**Explanation of key options:**

`Checks` uses a comma-separated list with `-` to disable:

- `-*` — disable everything first (clean slate)
- `modernize-*` — enable all modernization checks (auto, nullptr, range-for, etc.)
- `performance-*` — unnecessary copies, move semantics, etc.
- `readability-*` — naming, braces, complexity
- `-readability-magic-numbers` — disable (too noisy)
- `-modernize-use-trailing-return-type` — disable (controversial style)

**Common individual checks to know:**

| Check                                         | What It Catches                                      |
| --------------------------------------------- | ---------------------------------------------------- |
| `modernize-use-auto`                          | Replace explicit type with `auto` where obvious      |
| `modernize-use-nullptr`                       | Replace `NULL` with `nullptr`                        |
| `modernize-range-loop`                        | Replace index loops with range-for                   |
| `modernize-use-emplace`                       | Replace `push_back(T(...))` with `emplace_back(...)` |
| `performance-unnecessary-copy-initialization` | Avoidable copies                                     |
| `performance-move-const-arg`                  | Moving const objects (does nothing useful)           |
| `readability-const-return-type`               | Returns `const T` when T is returned by value        |
| `bugprone-use-after-move`                     | Using moved-from objects                             |
| `cppcoreguidelines-no-malloc`                 | Using malloc/free in C++                             |

### Viewing and Fixing Diagnostics

Clang-tidy warnings appear as diagnostics. Navigate them with:

| Key          | Action                                                |
| ------------ | ----------------------------------------------------- |
| `]d`         | Next diagnostic                                       |
| `[d`         | Previous diagnostic                                   |
| `<leader>ld` | Open full diagnostics list                            |
| `<leader>la` | Code actions (often includes auto-fix for clang-tidy) |

For many clang-tidy checks, `<leader>la` → "Apply fix" will automatically
apply the suggested transformation. This is faster than reading the warning
and editing manually.

### Running clang-tidy From the Command Line

```bash
# Check a single file:
clang-tidy src/main.cpp -- -std=c++20 -I./include

# Check with compile_commands.json (recommended):
clang-tidy -p build src/main.cpp

# Fix automatically:
clang-tidy -p build src/main.cpp --fix

# Check entire project:
find src -name '*.cpp' | xargs clang-tidy -p build
```

---

## Part 7 — C++ Snippets Reference

This config includes 40+ C++ snippets loaded with the `;` prefix. All work in
insert mode on `.cpp` files.

### Class Patterns

| Trigger   | Expands To                             | Use When                       |
| --------- | -------------------------------------- | ------------------------------ |
| `;class`  | Class with private members, ctor, dtor | Starting a new class           |
| `;classt` | Template class                         | Class that works on any type   |
| `;ctor`   | Constructor body                       | Adding constructors            |
| `;dtor`   | Destructor body                        | Explicit destructor            |
| `;copy`   | Copy constructor + copy assignment     | Rule of Three                  |
| `;move`   | Move constructor + move assignment     | Rule of Five (move semantics)  |
| `;rule5`  | Full Rule of Five boilerplate          | Complete resource-owning class |

**Example: `;class`**

```cpp
class MyClass {
public:
    MyClass();
    ~MyClass() = default;

private:
    // members
};
```

**Example: `;rule5`**

```cpp
class Resource {
public:
    Resource();
    ~Resource();
    Resource(const Resource& other);              // copy ctor
    Resource& operator=(const Resource& other);   // copy assign
    Resource(Resource&& other) noexcept;          // move ctor
    Resource& operator=(Resource&& other) noexcept; // move assign
};
```

### Inheritance

| Trigger     | Expands To                                |
| ----------- | ----------------------------------------- |
| `;inherit`  | Class inheriting from a base              |
| `;virtual`  | Virtual method declaration                |
| `;override` | Override method (with `override` keyword) |
| `;pure`     | Pure virtual method (`= 0`)               |

### Templates

| Trigger     | Expands To                 |
| ----------- | -------------------------- |
| `;tmpl`     | Template function          |
| `;tmplspec` | Template specialization    |
| `;concept`  | Concept definition (C++20) |

**Example: `;concept`**

```cpp
template <typename T>
concept Printable = requires(T t) {
    { std::cout << t } -> std::same_as<std::ostream&>;
};
```

### STL Containers

| Trigger | Expands To                       |
| ------- | -------------------------------- |
| `;vec`  | `std::vector<T> name;`           |
| `;map`  | `std::map<K, V> name;`           |
| `;umap` | `std::unordered_map<K, V> name;` |
| `;set`  | `std::set<T> name;`              |
| `;arr`  | `std::array<T, N> name;`         |
| `;pair` | `std::pair<T, U> name;`          |
| `;opt`  | `std::optional<T> name;`         |
| `;var`  | `std::variant<Ts...> name;`      |

### Smart Pointers

| Trigger | Expands To                           |
| ------- | ------------------------------------ |
| `;uptr` | `std::unique_ptr<T>` declaration     |
| `;sptr` | `std::shared_ptr<T>` declaration     |
| `;mkun` | `auto p = std::make_unique<T>(args)` |
| `;mksh` | `auto p = std::make_shared<T>(args)` |

**Always prefer `;mkun` / `;mksh` over `new`** — they're exception-safe and
make ownership explicit.

### Lambdas

| Trigger  | Expands To                                   |
| -------- | -------------------------------------------- |
| `;lam`   | `[](args) { body }` — no capture             |
| `;lamc`  | `[=](args) { body }` — capture by value      |
| `;lamr`  | `[&](args) { body }` — capture by reference  |
| `;lamat` | `[](args) mutable { body }` — mutable lambda |

### Range-based For

| Trigger | Expands To                               |
| ------- | ---------------------------------------- |
| `;fore` | `for (auto& elem : container) { }`       |
| `;forc` | `for (const auto& elem : container) { }` |

### Exceptions

| Trigger  | Expands To                                              |
| -------- | ------------------------------------------------------- |
| `;try`   | `try { } catch (const std::exception& e) { }`           |
| `;throw` | `throw std::runtime_error("message");`                  |
| `;excl`  | Custom exception class inheriting from `std::exception` |

### Namespace

| Trigger  | Expands To                  |
| -------- | --------------------------- |
| `;ns`    | `namespace name { }`        |
| `;nsi`   | `inline namespace name { }` |
| `;using` | `using name = type;`        |

### Modern C++

| Trigger | Expands To                                |
| ------- | ----------------------------------------- |
| `;sb`   | Structured binding: `auto [a, b] = pair;` |
| `;ifcx` | `if constexpr (condition) { }`            |
| `;noex` | `noexcept` function qualifier             |

### I/O

| Trigger | Expands To                      |
| ------- | ------------------------------- |
| `;cout` | `std::cout << value << '\n';`   |
| `;cerr` | `std::cerr << message << '\n';` |
| `;cin`  | `std::cin >> variable;`         |

### Testing (GoogleTest)

| Trigger    | Expands To                           |
| ---------- | ------------------------------------ |
| `;gtest`   | `TEST(SuiteName, TestName) { }`      |
| `;gtest_f` | `TEST_F(FixtureClass, TestName) { }` |
| `;assert`  | `ASSERT_EQ(expected, actual);`       |
| `;expect`  | `EXPECT_EQ(expected, actual);`       |

---

## Part 8 — Debugging with codelldb

### What codelldb Is

codelldb is the DAP (Debug Adapter Protocol) server for C/C++. It wraps LLDB
(the LLVM debugger) in the protocol that Neovim's nvim-dap understands. The
experience is similar to VS Code's debugger — breakpoints, step through, variable
inspection.

### Prerequisite: Debug Build

The debugger only works with binaries compiled with debug symbols:

```cmake
# In CMakeLists.txt:
target_compile_options(myapp PRIVATE -g -O0)
# OR set build type to Debug:
cmake -B build -DCMAKE_BUILD_TYPE=Debug
```

Build type Debug includes `-g` (debug symbols) and `-O0` (no optimization,
so stepping makes sense). **Never debug a Release build** — it's been optimized
so heavily that stepping through code has nothing to do with what you wrote.

Set the Debug build type in Neovim with `<leader>mcmT` → select "Debug".

### DAP Keymaps (From Chapter 10)

| Key             | Action                                               |
| --------------- | ---------------------------------------------------- |
| `<F5>`          | Launch/continue debugging                            |
| `<F7>`          | Toggle DAP UI                                        |
| `<F9>`          | Toggle breakpoint                                    |
| `<F10>`         | Step over (next line, don't enter functions)         |
| `<F11>`         | Step into (enter function)                           |
| `<S-F11>`       | Step out (finish current function, return to caller) |
| `<leader>dapr`  | Open DAP REPL (evaluate expressions)                 |
| `<leader>dapq`  | List breakpoints                                     |
| `<leader>dapC`  | Clear all breakpoints                                |

### Setting Up a Debug Configuration

nvim-dap needs to know how to launch your program. Create or edit
`.nvim/dap.lua` in your project root (the global runtime defaults live under
`~/.config/nvim/lua/de100/config/dap/`):

```lua
-- .nvim/dap.lua (project-local override)
return {
    configurations = {
        cpp = {
            {
                name = "Launch myapp",
                type = "codelldb",
                request = "launch",
                program = "${workspaceFolder}/build/myapp",
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
                args = {},
            },
        },
        c = {
            {
                name = "Launch myapp",
                type = "codelldb",
                request = "launch",
                program = "${workspaceFolder}/build/myapp",
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
                args = {},
            },
        },
    },
}
```

Run `:De100DapLoadProject` and inspect the path before confirming. Project Lua
is executable code and is never loaded automatically. Prefer
`.vscode/launch.json` when a declarative configuration is sufficient.

### A Debugging Session Walkthrough

1. Set the build type to Debug: `<leader>mcmT` → "Debug"
2. Build: `<leader>mcmb`
3. Open the source file you want to debug
4. Set a breakpoint: `<F9>` on the line where you want to stop
5. Start debugging: `<F5>`
   - nvim-dap shows a picker if you have multiple configurations
   - Execution starts, pauses at your breakpoint
6. Inspect variables: `<F7>` to open the DAP UI (shows locals, watches,
   call stack, breakpoints)
7. Hover over any variable to see its value
8. Navigate: `<F10>` (step over), `<F11>` (step into), `<S-F11>` (step out)
9. `<F5>` to continue to next breakpoint
10. `<F5>` again when no more breakpoints → program runs to completion

### The DAP UI Panels

When you press `<F7>`, four panels open:

- **Scopes** — local variables in the current stack frame
- **Watches** — expressions you're monitoring
- **Call stack** — the chain of function calls that led here
- **Breakpoints** — all active breakpoints (can toggle/delete from here)

### Memory Inspection (Advanced)

In the REPL (`<leader>dapr`):

```
> p variable_name        -- print a value
> p *pointer             -- dereference a pointer
> p array[5]             -- array indexing
> p sizeof(MyClass)      -- size of a type
> bt                     -- backtrace (same as call stack)
> up / down              -- navigate call stack frames
```

---

## Part 9 — Testing with neotest-ctest

### What neotest-ctest Does

neotest-ctest is the neotest adapter for CTest, which is CMake's testing
framework. It automatically discovers tests written with:

- **GoogleTest** (most common)
- **Catch2**
- **doctest**

Once discovered, you can run individual tests, whole suites, or all tests —
directly from Neovim with results shown inline.

### Setting Up a Test Project (GoogleTest Example)

**Add GoogleTest to CMakeLists.txt:**

```cmake
cmake_minimum_required(VERSION 3.20)
project(MyProject CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Main library/executable
add_library(mylib src/mylib.cpp)
target_include_directories(mylib PUBLIC include)

# Tests
enable_testing()
find_package(GTest REQUIRED)    # or use FetchContent

add_executable(mylib_tests tests/mylib_test.cpp)
target_link_libraries(mylib_tests PRIVATE mylib GTest::gtest_main)

include(GoogleTest)
gtest_discover_tests(mylib_tests)
```

**Write a test:**

```cpp
// tests/mylib_test.cpp
#include <gtest/gtest.h>
#include "mylib.h"

TEST(MylibTest, AddsTwoNumbers) {
    EXPECT_EQ(add(2, 3), 5);
}

TEST(MylibTest, HandlesNegativeNumbers) {
    EXPECT_EQ(add(-1, 1), 0);
    EXPECT_EQ(add(-5, -3), -8);
}

class MylibFixture : public ::testing::Test {
protected:
    void SetUp() override { /* ... */ }
    void TearDown() override { /* ... */ }
};

TEST_F(MylibFixture, SomeFixtureTest) {
    EXPECT_TRUE(true);  // replace with real assertions
}
```

**Build and configure CTest:**

```
<leader>mcmg    → configure (cmake generates build/ with CTest support)
<leader>mcmb    → build (compiles the test binary)
```

### neotest Keymaps

| Key          | Action                     |
| ------------ | -------------------------- |
| `<leader>tn` | Run test nearest to cursor |
| `<leader>tf` | Run tests in current file  |
| `<leader>tl` | Run last test (repeat)     |
| `<leader>to` | Open test output panel     |
| `<leader>ts` | Toggle test summary panel  |

> **Note:** `<leader>tr`, `<leader>tt`, `<leader>ta` are **Overseer** keymaps
> (run task, toggle tasks, quick action) — not neotest.

### The Test Workflow

1. Write tests using `;gtest` or `;gtest_f` snippets
2. Build: `<leader>mcmb`
3. Position cursor inside a test function
4. Run: `<leader>tn` (run nearest test)
5. A green gutter marker appears for pass, red for fail
6. `<leader>to` opens the output panel to see assertion failures
7. Fix the code, save, `<leader>tl` to re-run the last test

### Limitation: Compile Before Test

Unlike Go's `go test` which compiles automatically, CTest requires the test
binary to already be compiled. The workflow is:

1. Code change
2. `<leader>mcmb` (build)
3. `<leader>tl` (run last test)

The build step is manual — there is no watch mode that auto-compiles.

---

## Part 10 — C vs C++ Settings

### Why the ftplugins Are Different

The `after/ftplugin/` directory has separate files for `c.lua` and `cpp.lua`:

**`c.lua`** (C code):

```lua
vim.opt_local.textwidth = 80
vim.opt_local.colorcolumn = "80"
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
```

**`cpp.lua`** (C++ code):

```lua
vim.opt_local.textwidth = 100
vim.opt_local.colorcolumn = "100"
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
```

The key difference is line length: **80 columns for C, 100 for C++**.

### Why 80 for C?

The 80-column limit in C comes from the Linux kernel coding style and the POSIX
tradition. Most C code is still written with this constraint — not because of
old terminals, but because:

- C tends to be low-level systems code that benefits from narrower scope per function
- Header files get included everywhere; wide lines make diffs noisy
- It's the cultural norm in C open source (Linux kernel, glibc, etc.)

### Why 100 for C++?

Modern C++ code often has naturally wider lines:

- Long template parameter lists
- Method chains on smart pointers
- `std::ranges::` prefixed algorithms
- Concept constraints

Most modern C++ style guides (Google, LLVM itself) allow 80-120. This config
uses 100 as a reasonable compromise. Adjust it in `cpp.lua` if your project's
`.clang-format` uses a different `ColumnLimit`.

---

## Part 11 — Projects Without a Build System

Not every C/C++ project uses CMake or Make. Sometimes you're doing a quick
experiment, working with a custom shell script build, or maintaining a
header-only library. Clangd still needs to know _how_ a file is compiled to
give accurate completions and type inference — without that, it falls back to
guessing and gives you constant false-positive errors.

There are three options, from simplest to most powerful:

### Option 1 — `compile_flags.txt` (no tooling needed)

Create this file in the project root, one compiler flag per line:

```
-std=c++20
-I./include
-Wall
-Wextra
```

Clangd reads it automatically. No build step needed.

**Limitation:** the same flags apply to every file in the entire project tree.
Fine for single-directory projects, quick experiments, or learning exercises.

### Option 2 — `.clangd` Config File (per-project control)

More powerful than `compile_flags.txt` — can add, remove, or override flags,
and works per-directory:

```yaml
# .clangd at project root
CompileFlags:
  Add: [-std=c++20, -I./include, -DDEBUG]
  Remove: [-W*] # strip unwanted flags the compiler injects
  Compiler: clang++ # tell clangd which compiler's stdlib to use
```

Useful when different subdirectories use different standards (e.g. a C
directory alongside a C++ directory), or when clangd is picking up wrong
system-default flags.

### Option 3 — Bear (works with ANY build command, including shell scripts)

Bear intercepts compiler `exec()` calls via `LD_PRELOAD` and records them
into `compile_commands.json`. It doesn't care how the build is invoked:

```bash
bear -- make                            # Makefile
bear -- sh build.sh                     # your custom shell script
bear -- ./build.sh                      # executable shell script
bear -- bash -c "gcc src/*.c -o app"    # inline command
bear -- gcc -std=c++20 src/main.cpp -o main   # single file
```

Install: `sudo apt install bear`

After running Bear once, `compile_commands.json` is created. You only need to
re-run it when you **add/remove source files or change compiler flags** —
editing existing files doesn't require it.

After Bear generates the file (or after writing `compile_flags.txt`), reload
clangd to pick up the changes:

```
:LspRestart
```

### How Clangd Picks Which One to Use

Priority order (first match wins):

1. `compile_commands.json` in the project root or `build/` — cmake-tools or Bear generate this
2. `compile_flags.txt` in the file's directory, walking up to root
3. `.clangd` `CompileFlags` block
4. Fallback: clangd guesses from file content — expect missing includes and wrong types

### Quick Reference

| Scenario                          | Best approach                                      |
| --------------------------------- | -------------------------------------------------- |
| Learning, quick experiments       | `compile_flags.txt` with `-std=c++20 -I.`          |
| Header-only library               | `compile_flags.txt`                                |
| Custom `sh` / `bash` build script | `bear -- sh build.sh`                              |
| Makefile project                  | `bear -- make`                                     |
| CMake project                     | cmake-tools.nvim auto-generates via `<leader>mcmg` |
| Mixed flags per subdirectory      | `.clangd` config file                              |

---

## Part 12 — Troubleshooting

### clangd Isn't Attaching

**Symptom:** `K` does nothing. No completions beyond buffer words. `:LspInfo`
shows clangd in the server list but no "attached" line.

**Check 1:** Does `compile_commands.json` exist in the project root?

```bash
ls -la compile_commands.json
```

If no: run `<leader>mcmg` (cmake configure) or `bear -- make`.

**Check 2:** Is clangd installed?

```bash
which clangd
clangd --version
```

If no: run the Ansible playbook or `sudo apt install clangd`.

**Check 3:** Are there errors in clangd's log?

```
:LspLog
```

Scroll to the bottom. Common errors:

- `failed to find compile_commands.json` → generate it
- `clangd: command not found` → path issue, check `:echo $PATH`

### False "File Not Found" Errors on Includes

**Symptom:** `#include <vector>` is underlined red with "file not found".

**Cause:** clangd can't find the system includes, usually because:

1. `compile_commands.json` is missing (see above)
2. The wrong `--sysroot` or `-I` path is in compile_commands.json
3. clang is not installed (clangd ships headers separately from gcc)

**Fix 1:** Run `<leader>mcmg` to regenerate compile commands.

**Fix 2:** Check if `clang` itself is installed:

```bash
clang --version    # not just clangd
```

The standard library headers are shipped with clang. If only `clangd` is
installed but not `clang`, the headers may be missing.

```bash
sudo apt install clang
```

**Fix 3:** Create a fallback `.clangd` config:

```yaml
CompileFlags:
  Add:
    [-std=c++20, -I/usr/include/c++/12, -I/usr/include/x86_64-linux-gnu/c++/12]
```

### clangd Is Slow / High Memory Usage

**Symptom:** clangd takes >10 seconds to start responding. `:ClangdMemoryUsage`
shows >2GB.

**Fix 1:** Limit the number of background index workers:

```lua
-- In lsp.lua clangd cmd:
"--j=4",    -- use max 4 threads for background indexing
```

**Fix 2:** Disable background index for large projects (re-enable after first
full index):

```lua
"--background-index=false",
```

**Fix 3:** The `.cache/clangd/` directory in your project root contains the
index. If it gets corrupted:

```bash
rm -rf .cache/clangd/
```

Then restart Neovim and wait for re-index.

### Multi-subproject Repos (cmake-tools uses the wrong root)

**Symptom:** You `nvim .` from a repo that has multiple independent subprojects
(each with its own `CMakeLists.txt`), navigate into one, press `<leader>mcmb`,
and cmake-tools errors: "Cannot find CMakeLists.txt at cwd (repo-root)".

**Why it happens:** cmake-tools stores `config.cwd` once at startup
(`vim.loop.cwd()` = the directory where you opened Neovim). It does not
automatically update when you navigate to a subdirectory.

**What the config does automatically:** The `core/project-root.lua` BufEnter
autocmd changes the **global cwd** (`:cd`) to the nearest project root when
you open any file. This fixes Telescope, grep, and other tools that read
`vim.fn.getcwd()` dynamically. However, **cmake-tools caches its own path
internally** and doesn't reliably react to `:cd`. You need to tell it manually.

**The manual workflow:**

```
# Step 1: make sure cwd is correct (project-root.lua usually does this automatically)
:pwd              → check it shows your subproject, e.g. .../projects/0-starter
<leader>mcd       → if :pwd is wrong, press this to force-cd to the nearest root

# Step 2: tell cmake-tools about the new root — pick one:
<leader>mcmg          → re-run configure; cmake-tools re-reads cwd and picks up the right project
:CMakeSelectCwd .     → explicitly set cmake-tools cwd to current directory, then configure
```

Verify it worked:

```
:CMakeInfo        → should show the correct project path and build directory
```

**Project structure example:**

```
build-your-own-game/        ← you ran nvim . here
├── .git
├── projects/
│   ├── 0-starter/          ← has its own CMakeLists.txt
│   │   └── src/main.cpp    ← open this → :pwd auto-updates, then run <leader>mcmg
│   └── 1-chapter1/
│       └── src/main.cpp    ← open this → :pwd auto-updates, then run <leader>mcmg
└── (no CMakeLists.txt at root)
```

**Summary:** `:cd` + `<leader>mcmg` is the two-step reset. Everything else
(Telescope, grep, overseer) follows `:cd` automatically; only cmake-tools
needs the explicit re-configure.

### cmake-tools.nvim Doesn't Detect CMakeLists.txt

**Symptom:** `<leader>mcmg` does nothing, or cmake-tools commands aren't available.

**Check:** cmake-tools.nvim loads lazily when `ft = {"c", "cpp", "cmake"}`.
Open a `.cpp` file first, or a `CMakeLists.txt` file. The plugin may not be
loaded if you opened Neovim directly on a Lua file.

**Check:** Is `CMakeLists.txt` in the current working directory?

```
:pwd
```

If the auto-detection didn't fire, run `<leader>mcd` to manually set the root,
or change it explicitly:

```
:cd /path/to/subproject
```

### Header/Source Switch (`<leader>lh`) Not Working

**Symptom:** `<leader>lh` says "no corresponding file" or does nothing.

**Check:** The header and source files must have matching basenames:

- `Foo.h` ↔ `Foo.cpp` ✓
- `foo.h` ↔ `foo.cpp` ✓
- `FooImpl.cpp` ↔ `Foo.h` ✗ (different base names)

**Check:** The files must be in the project that clangd knows about
(i.e., appear in `compile_commands.json`). If you just created a new file,
re-run `<leader>mcmg` to regenerate compile commands.

### Snippets Not Triggering

**Symptom:** `;class` types literally instead of expanding.

**Check 1:** Are you in insert mode? Snippets expand from insert mode, not
normal mode.

**Check 2:** Trigger with `<Tab>` if autoexpand is off. The config uses `<Tab>`
as the snippet expand key.

**Check 3:** Does `cpp.lua` exist in `~/.config/nvim/snippets/`?

```bash
ls ~/.config/nvim/snippets/
# Should show: cpp.lua, c.lua, go.lua, etc.
```

---

## Part 13 — The Full Workflow Example

Let's put everything together. You're starting on a new feature for a C++
project that already has tests.

### Before You Start (One-time Setup Per Project)

```bash
# From terminal:
tmux new-session -s myproject -n editor -c ~/Desktop/workspaces/myproject
nvim .
```

In Neovim:

```
<leader>mcmg    → configure cmake, generate compile_commands.json
<leader>mcmT    → select "Debug" build type
```

### The Development Loop

```
1. Edit code                      ← Neovim, all the LSP features active
   ↓
2. Write test (;gtest snippet)    ← TDD: write test first
   ↓
3. <leader>mcmb                     ← Build (overseer shows output)
   ↓
4. <leader>tn                     ← Run nearest test
   ↓
5. Test fails (red gutter marker) ← Expected: you haven't implemented yet
   ↓
6. Implement the feature           ← LSP completions, inlay hints help
   ↓
7. <leader>mcmb                     ← Build again
   ↓
8. <leader>tl                     ← Re-run last test
   ↓
9. Test passes (green gutter)
   ↓
10. <leader>ts                    ← Toggle summary to see all tests green
   ↓
11. <leader>mp                    ← Format file (clang-format)
   ↓
12. Fix clang-tidy warnings        ← <leader>la on any yellow underlines
   ↓
13. Commit via Neogit              ← <leader>gg
```

### If a Test Fails and You're Confused

Add debug output with `;cout` snippet:

```cpp
std::cout << "value is: " << myVar << '\n';  // temporary debug
```

Or use the debugger:

```
1. Set breakpoint in test: <F9>
2. <F5> to launch (pick your test binary config)
3. Step through: <F10>, inspect variables with <F7>
4. Find the bug, remove breakpoint: <F9>
```

### Jumping Between Header and Source While Implementing

You're implementing `Foo::doSomething()` in `Foo.cpp`:

```
<leader>lh    → jumps to Foo.h (check the declaration)
<leader>lh    → jumps back to Foo.cpp
```

While in `Foo.h`, press `<leader>la` on the method signature to see
auto-implementation options (clangd can generate the stub in `.cpp`).

---

## VSCode Comparison

| VSCode Workflow                            | This Neovim Workflow                                 |
| ------------------------------------------ | ---------------------------------------------------- |
| cmake-tools extension → status bar buttons | `<leader>m*` keymaps                                 |
| "Build" button in status bar               | `<leader>mcmb`                                       |
| "Debug" F5                                 | `<F5>` (same!)                                       |
| Breakpoints in gutter (click)              | `<F9>` (toggle)                                      |
| "Go to Header/Source" (right-click)        | `<leader>lh`                                         |
| IntelliSense (msvc/clangd)                 | clangd (identical engine)                            |
| clang-format on save                       | `:w` + conform.nvim format-on-save (or `<leader>mp`) |
| Test Explorer extension                    | neotest (`<leader>tn/tl/ts`)                         |
| C/C++ extension pack                       | clangd + cmake-tools.nvim + clangd_extensions.nvim   |
| compile_commands.json (auto)               | compile_commands.json via cmake-tools.nvim           |

The main difference: VSCode does most of this with GUI clicks. Neovim does it
with keybindings. After a week of muscle memory, the Neovim version is faster.

---

## Exercises

Do these in order — each builds on the previous.

### Exercise 1: Your First CMake Project

1. Create a new directory: `mkdir ~/Desktop/workspaces/cpp-practice && cd $_`
2. Create `CMakeLists.txt` with:
   - `cmake_minimum_required(VERSION 3.20)`
   - `project(Practice CXX)`
   - `set(CMAKE_CXX_STANDARD 20)`
   - `set(CMAKE_EXPORT_COMPILE_COMMANDS ON)`
   - `add_executable(practice src/main.cpp)`
3. Create `src/main.cpp` with a simple program that prints something
4. Open Neovim: `nvim .`
5. Press `<leader>mcmg` to configure
6. Verify `compile_commands.json` exists: `:!ls compile_commands.json`
7. Press `<leader>mcmb` to build
8. Press `<leader>mcmr` to run it

**Goal:** End with a working CMake project that clangd understands.

### Exercise 2: LSP Features

In the project from Exercise 1:

1. In `main.cpp`, type `std::vec` and let completion finish (should complete to `std::vector`)
2. Add a `std::vector<int> nums = {1, 2, 3};` line
3. Enable inlay hints: `<leader>li` — you should see type info
4. On `std::vector`, press `K` — you should get hover documentation
5. Press `gd` on any standard library type — jumps to its definition in system headers
6. Press `<C-o>` to jump back

**Goal:** Prove that clangd is working with the compile database.

### Exercise 3: Classes and Snippets

1. Create `src/calculator.h` and `src/calculator.cpp`
2. In `calculator.h`, type `;class` to expand the class snippet — fill in a `Calculator` class
3. Add a method: `double add(double a, double b);` to the header
4. Switch to `calculator.cpp` — note: use `<leader>lh` to jump to it
5. Implement the method in the `.cpp` file
6. Use `;cout` in `main.cpp` to test it
7. Build and run

**Goal:** Practice the header/source workflow and snippet usage.

### Exercise 4: Debugging

1. In `main.cpp`, write a buggy loop:
   ```cpp
   std::vector<int> v = {1, 2, 3};
   for (int i = 0; i <= v.size(); i++) {  // bug: <= instead of <
       std::cout << v[i] << '\n';           // out-of-bounds at i=3
   }
   ```
2. Set build type to Debug: `<leader>mcmT` → "Debug"
3. Build: `<leader>mcmb`
4. Set a breakpoint on the `std::cout` line: `<F9>`
5. Launch debugger: `<F5>`
6. Open DAP UI: `<F7>`
7. Step through the loop with `<F10>`, watching `i` in the Scopes panel
8. See where the bug occurs
9. Fix it (`<` instead of `<=`), rebuild, re-run

**Goal:** Walk through a real debugging session from first principles.

### Exercise 5: Tests

1. Add GoogleTest to your project (or use `FetchContent` in CMakeLists.txt):

   ```cmake
   include(FetchContent)
   FetchContent_Declare(
     googletest
     URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.tar.gz
   )
   FetchContent_MakeAvailable(googletest)

   enable_testing()
   add_executable(tests tests/calculator_test.cpp)
   target_link_libraries(tests PRIVATE GTest::gtest_main calculator_lib)
   include(GoogleTest)
   gtest_discover_tests(tests)
   ```

2. Create `tests/calculator_test.cpp` using the `;gtest` snippet
3. Write 2-3 test cases for your Calculator class
4. Build: `<leader>mcmb`
5. Run nearest test: `<leader>tn` (cursor inside a test function)
6. Toggle summary to see all tests: `<leader>ts`
7. Intentionally break a test (change the expected value) — observe the red
   gutter marker and `<leader>to` output

**Goal:** Run your first test in Neovim with inline pass/fail feedback.

---

_You've now seen the full C/C++ workflow in Neovim: from compile database to
completions, from formatting to linting, from snippets to tests, from cmake
builds to the debugger. The tools are the same ones used in production — just
controlled from your keyboard instead of a GUI._

_Good luck. Remember: `<leader>lh` is your best friend._
