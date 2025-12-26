# C/C++ Setup Guide

## Complete Development Environment Setup

This guide sets up everything needed for professional C/C++ development in Neovim.

## Step 1: Install Compiler & Build Tools

### GCC/G++ (GNU Compiler Collection)

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install build-essential

# Verify
gcc --version
g++ --version
```

### Clang (Alternative/Additional)

```bash
# Ubuntu/Debian
sudo apt install clang clang-tools

# macOS (via Homebrew)
brew install llvm

# Verify
clang --version
clang++ --version
```

### CMake & Build Tools

```bash
# Ubuntu/Debian
sudo apt install cmake make ninja-build

# macOS
brew install cmake ninja

# Verify
cmake --version
ninja --version
```

## Step 2: Install Language Server (clangd)

### Via Mason (Recommended)

```vim
:Mason
# Find 'clangd'
# Press 'i' to install
```

### Manual Installation (Backup)

```bash
# Ubuntu/Debian
sudo apt install clangd-14

# Create symlink
sudo ln -s /usr/bin/clangd-14 /usr/local/bin/clangd

# macOS
brew install llvm
# Add to PATH
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
```

### Verify clangd

```vim
:LspInfo
# Should show: clangd attached
```

## Step 3: Install Debugger

### GDB (GNU Debugger)

```bash
# Ubuntu/Debian
sudo apt install gdb

# macOS (via Homebrew)
brew install gdb

# Verify
gdb --version
```

### LLDB (Alternative for Clang)

```bash
# Ubuntu/Debian
sudo apt install lldb

# macOS (comes with Xcode)
xcode-select --install

# Verify
lldb --version
```

## Step 4: Install Formatters & Linters

### clang-format (Formatter)

```bash
# Ubuntu/Debian
sudo apt install clang-format

# macOS
brew install clang-format

# Verify
clang-format --version
```

Already configured in `formatting.lua`!

### clang-tidy (Linter)

```bash
# Ubuntu/Debian
sudo apt install clang-tidy

# macOS
brew install llvm  # Includes clang-tidy
```

### cpplint (Google Style Checker)

```vim
:Mason
# Install: cpplint
```

Or manually:
```bash
pip install cpplint
```

## Step 5: Configure clangd

### Create `.clangd` Configuration

In your project root:

```yaml
# .clangd
CompileFlags:
  Add:
    - -std=c++20
    - -Wall
    - -Wextra
    - -I./include
  Remove:
    - -W*  # Remove all warnings, we'll add specific ones

Diagnostics:
  UnusedIncludes: Strict
  MissingIncludes: Strict

InlayHints:
  Enabled: Yes
  ParameterNames: Yes
  DeducedTypes: Yes

Hover:
  ShowAKA: Yes
```

### For CMake Projects

clangd automatically uses `compile_commands.json`:

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.15)
project(MyProject)

# Generate compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(myapp main.cpp)
```

Build project:
```bash
mkdir build && cd build
cmake ..
# compile_commands.json is created!
```

Link to project root:
```bash
ln -s build/compile_commands.json compile_commands.json
```

## Step 6: Format Configuration

### Create `.clang-format`

In project root:

```yaml
# .clang-format
BasedOnStyle: Google

IndentWidth: 4
UseTab: Never
ColumnLimit: 100

BreakBeforeBraces: Attach
AllowShortFunctionsOnASingleLine: Inline
AllowShortIfStatementsOnASingleLine: Never
AllowShortLoopsOnASingleLine: false

PointerAlignment: Left
DerivePointerAlignment: false

IncludeBlocks: Regroup
SortIncludes: true

AccessModifierOffset: -4
NamespaceIndentation: None
```

### Test Formatting

```vim
# Open any C++ file
:e test.cpp

# Format
<leader>f
```

## Step 7: Project Structure

### Basic Project

```
my-cpp-project/
├── .clangd
├── .clang-format
├── CMakeLists.txt
├── include/
│   └── mylib.hpp
├── src/
│   ├── main.cpp
│   └── mylib.cpp
└── tests/
    └── test_mylib.cpp
```

### CMakeLists.txt Example

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyProject VERSION 1.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Include directories
include_directories(include)

# Source files
set(SOURCES
    src/main.cpp
    src/mylib.cpp
)

# Executable
add_executable(${PROJECT_NAME} ${SOURCES})

# Tests (optional)
enable_testing()
add_subdirectory(tests)
```

## Step 8: Test LSP Features

### Create Test File

```cpp
// test.cpp
#include <iostream>
#include <vector>
#include <string>

class Calculator {
public:
    int add(int a, int b) {
        return a + b;
    }
    
    double multiply(double a, double b) {
        return a * b;
    }
};

int main() {
    Calculator calc;
    
    // Test autocomplete
    calc.  // Should show: add, multiply
    
    // Test hover
    // Hover over Calculator
    
    // Test go to definition
    // gd on Calculator
    
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    
    for (const auto& num : numbers) {
        std::cout << num << std::endl;
    }
    
    return 0;
}
```

### Test Features

```vim
# 1. Open file
nvim test.cpp

# 2. Check LSP
:LspInfo
# Should show: clangd (client id X)

# 3. Test autocomplete
# Type: calc.
# Should show methods!

# 4. Hover documentation
# Cursor on 'Calculator'
K
# Shows class definition

# 5. Go to definition
# Cursor on 'add'
gd
# Jumps to method definition

# 6. Find references
gR
# Shows all usages

# 7. Rename
# Cursor on 'Calculator'
<leader>rn
# Type new name

# 8. Format
<leader>f

# 9. Diagnostics
# Make an error
calc.nonexistent()
# Should show red underline
[d     # Jump to diagnostic
```

## Step 9: Build & Run

### Simple Compilation

```vim
# Compile single file
:!g++ -std=c++20 -Wall -o test test.cpp

# Run
:!./test
```

### CMake Build

```vim
# Configure
:!cmake -B build -G Ninja

# Build
:!cmake --build build

# Run
:!./build/MyProject
```

### Create Build Keybindings

Add to `keymaps.lua`:

```lua
-- C/C++ Build commands
vim.keymap.set('n', '<leader>cb', ':!cmake --build build<CR>', 
    { desc = 'CMake Build' })
vim.keymap.set('n', '<leader>cr', ':!./build/%:t:r<CR>', 
    { desc = 'Run Executable' })
vim.keymap.set('n', '<leader>cc', ':!cmake -B build -G Ninja<CR>', 
    { desc = 'CMake Configure' })
```

## Step 10: Verify Everything Works

### Checklist

- [ ] clangd starts automatically in C++ files
- [ ] Autocomplete shows suggestions
- [ ] Go to definition works (gd)
- [ ] Find references works (gR)
- [ ] Hover shows documentation (K)
- [ ] Diagnostics show errors in red
- [ ] Format works (<leader>f)
- [ ] Can compile with g++/clang++
- [ ] Can build CMake project

### Troubleshooting

#### LSP Not Starting

```vim
:LspInfo
:LspLog
:LspRestart
```

#### No Autocomplete

Check `compile_commands.json` exists:
```bash
ls compile_commands.json
```

Regenerate:
```bash
cmake -B build
ln -sf build/compile_commands.json .
```

#### Slow Performance

Limit clangd threads:
```yaml
# .clangd
Index:
  Background: Build
  
Completion:
  AllScopes: No
```

#### Wrong Standard Version

Update `.clangd`:
```yaml
CompileFlags:
  Add: [-std=c++20]
```

## Next Steps

1. ✅ Setup complete!
2. 📖 Read [02-workflow.md](./02-workflow.md) for daily workflow
3. 🐛 Read [03-debugging.md](./03-debugging.md) for debugging
4. 🧪 Read [04-testing.md](./04-testing.md) for testing setup
5. 🎯 Read [05-real-world.md](./05-real-world.md) for examples

---

**Your C/C++ development environment is ready! 🚀**
