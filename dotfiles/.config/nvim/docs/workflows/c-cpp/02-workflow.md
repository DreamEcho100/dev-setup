# C/C++ Daily Development Workflow

## Complete Day-to-Day Workflow Guide

This guide covers common workflows and scenarios in C/C++ development with Neovim.

## Starting a New Project

### Project Initialization

```bash
# Create project structure
mkdir my-cpp-project && cd my-cpp-project
mkdir -p {src,include,tests,build}

# Initialize Git
git init

# Create CMakeLists.txt
nvim CMakeLists.txt
```

```cmake
cmake_minimum_required(VERSION 3.15)
project(MyCppProject VERSION 1.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include_directories(include)

file(GLOB_RECURSE SOURCES "src/*.cpp")
add_executable(${PROJECT_NAME} ${SOURCES})
```

### Configure clangd

```bash
# Create .clangd
nvim .clangd
```

```yaml
CompileFlags:
  Add:
    - -std=c++20
    - -Wall
    - -Wextra
    - -I./include
```

### Initial Build

```bash
# Configure CMake
cmake -B build -G Ninja

# Link compile_commands.json
ln -s build/compile_commands.json .

# Open project
nvim .
```

## Common Development Tasks

### 1. Creating New Classes

#### Create Header File

```vim
# Open Neo-tree
<leader>e

# Navigate to include/
# Press 'a' to add file
Calculator.hpp
```

```cpp
// include/Calculator.hpp
#pragma once

class Calculator {
public:
    Calculator();
    ~Calculator();
    
    int add(int a, int b);
    int subtract(int a, int b);
    double multiply(double a, double b);
    double divide(double a, double b);
    
private:
    int result_;
};
```

#### Create Implementation File

```vim
# In Neo-tree, navigate to src/
# Press 'a'
Calculator.cpp
```

```cpp
// src/Calculator.cpp
#include "Calculator.hpp"
#include <stdexcept>

Calculator::Calculator() : result_(0) {}

Calculator::~Calculator() {}

int Calculator::add(int a, int b) {
    result_ = a + b;
    return result_;
}

int Calculator::subtract(int a, int b) {
    result_ = a - b;
    return result_;
}

double Calculator::multiply(double a, double b) {
    return a * b;
}

double Calculator::divide(double a, double b) {
    if (b == 0) {
        throw std::runtime_error("Division by zero");
    }
    return a / b;
}
```

#### Update CMakeLists.txt

```cmake
# Add to sources
add_library(calculator src/Calculator.cpp)
target_include_directories(calculator PUBLIC include)

# Link to main
add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME} calculator)
```

### 2. Navigating Large Codebases

#### Find Files Quickly

```vim
# Find by filename
<leader>sf
Calculator

# Find in project (grep)
<leader>sg
Calculator::add

# Find symbol (LSP)
<leader>ss
# Select 'lsp_document_symbols'
```

#### Jump Between Header/Source

```vim
# Create custom keymap (add to keymaps.lua)
vim.keymap.set('n', '<leader>a', function()
    local ext = vim.fn.expand('%:e')
    local base = vim.fn.expand('%:t:r')
    
    if ext == 'cpp' or ext == 'cc' then
        -- Jump to header
        vim.cmd('find ' .. base .. '.hpp')
    elseif ext == 'hpp' or ext == 'h' then
        -- Jump to source
        vim.cmd('find ' .. base .. '.cpp')
    end
end, { desc = 'Alternate between header/source' })

# Usage
<leader>a  " Toggle between .cpp and .hpp
```

#### Navigate Code

```vim
# Go to definition
gd

# Go to declaration
gD

# Find all references
gR

# Go to implementation
gi

# List all symbols in file
<leader>ss
# Select 'lsp_document_symbols'

# Go back
<C-o>

# Go forward
<C-i>
```

### 3. Code Editing with LSP

#### Smart Autocomplete

```cpp
#include <vector>
#include <string>

int main() {
    std::vector<std::string> names;
    
    // Type 'names.' - shows vector methods
    names.  
    // Suggestions: push_back, size, empty, etc.
    
    // Type 'std::' - shows all std namespace
    std::
    // Suggestions: string, vector, map, etc.
}
```

#### Code Actions

```cpp
// Undefined method
class MyClass {
public:
    void undefinedMethod();  // Red underline
};
```

```vim
# Cursor on 'undefinedMethod'
<leader>ca
# Code action: "Generate method definition"
```

Result in source file:
```cpp
void MyClass::undefinedMethod() {
    // TODO: Implement
}
```

#### Refactoring

```cpp
class OldClassName {
    // ...
};
```

```vim
# Cursor on 'OldClassName'
<leader>rn
# Type: NewClassName
# Enter

# All references renamed!
```

### 4. Error Handling & Diagnostics

#### View Errors

```vim
# Jump to next error
]d

# Jump to previous error
[d

# Show error in floating window
<leader>d

# List all errors in file
<leader>D

# Open Trouble (if installed)
<leader>xx
```

#### Common Errors & Fixes

```cpp
// Error: Undefined reference
#include "MyClass.hpp"  // ❌ Missing

// Fix: Add include
```

```vim
# LSP suggests fix
<leader>ca
# "Add include for MyClass"
```

```cpp
// Error: Unused variable
int x = 10;  // ❌ x is unused

// Fix: Remove or use it
std::cout << x;
```

### 5. Building & Running

#### Quick Compile Single File

```vim
# Compile current file
:!g++ -std=c++20 -o %:r %

# Run
:!./%:r

# One command
:!g++ -std=c++20 -o %:r % && ./%:r
```

#### CMake Build

```vim
# Configure (first time or after CMakeLists.txt change)
:!cmake -B build

# Build
:!cmake --build build

# Run
:!./build/MyCppProject

# Clean build
:!cmake --build build --target clean
```

#### Create Build Keybindings

Add to `keymaps.lua`:

```lua
-- C++ Build keybindings
local keymap = vim.keymap

keymap.set('n', '<leader>cc', ':!cmake -B build<CR>', 
    { desc = '[C]Make [C]onfigure' })
    
keymap.set('n', '<leader>cb', ':!cmake --build build<CR>', 
    { desc = '[C]Make [B]uild' })
    
keymap.set('n', '<leader>cr', ':!./build/%:t:r<CR>', 
    { desc = '[C]Make [R]un' })
    
keymap.set('n', '<leader>ct', ':!cd build && ctest --output-on-failure<CR>', 
    { desc = '[C]Make [T]est' })
```

Usage:
```vim
<leader>cc  " Configure
<leader>cb  " Build
<leader>cr  " Run
```

### 6. Working with Modern C++ Features

#### Smart Pointers

```cpp
#include <memory>

// Unique pointer
auto ptr = std::make_unique<Calculator>();
ptr->add(1, 2);  // Autocomplete works!

// Shared pointer
auto shared = std::make_shared<Calculator>();

// Weak pointer
std::weak_ptr<Calculator> weak = shared;
```

#### Range-based Loops

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};

for (const auto& num : numbers) {
    std::cout << num << '\n';
}
```

#### Lambda Functions

```cpp
auto add = [](int a, int b) {
    return a + b;
};

int result = add(10, 20);  // Autocomplete on 'add'
```

#### Structured Bindings

```cpp
std::map<std::string, int> ages;
ages["John"] = 30;

for (const auto& [name, age] : ages) {
    std::cout << name << ": " << age << '\n';
}
```

### 7. Managing Dependencies

#### Header-Only Libraries

```bash
# Create lib/ directory
mkdir lib

# Add library (e.g., json.hpp)
cd lib
wget https://github.com/nlohmann/json/releases/download/v3.11.2/json.hpp
```

Update CMakeLists.txt:
```cmake
include_directories(lib)
```

Use in code:
```cpp
#include <json.hpp>

nlohmann::json j;
j["name"] = "John";
```

#### Using vcpkg (Package Manager)

```bash
# Install vcpkg
git clone https://github.com/Microsoft/vcpkg.git
./vcpkg/bootstrap-vcpkg.sh

# Install library
./vcpkg/vcpkg install fmt

# Use in CMake
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake")
```

### 8. Code Formatting Workflow

#### Format on Save (Already Configured!)

```vim
# Just save
:w
# or
<C-s>

# Formats automatically with clang-format!
```

#### Format Selection

```vim
# Visual mode
V
# Select lines
<leader>f
```

#### Format Entire File

```vim
<leader>f
```

#### Custom Format Command

Add to keymaps.lua:
```lua
keymap.set('n', '<leader>F', ':!clang-format -i %<CR>', 
    { desc = 'Format with clang-format' })
```

### 9. Documentation & Comments

#### Generate Doxygen Comments

```cpp
/**
 * @brief Calculates the sum of two integers
 * @param a First integer
 * @param b Second integer
 * @return Sum of a and b
 */
int add(int a, int b);
```

#### View Documentation

```vim
# Hover over function
K
# Shows documentation!
```

### 10. Git Integration

```vim
# Open LazyGit
<leader>lg

# Stage changes
s

# Commit
c
# Type message
# Ctrl+C to commit

# Push
P

# View diff
d
```

## Typical Day Workflow

```vim
# 1. Open project
cd ~/projects/my-cpp-project
nvim .

# 2. Pull latest changes
<leader>lg
p  " Pull

# 3. Create new branch
c  " Create branch
feature/add-calculator

# 4. Find file to edit
<leader>sf
Calculator.cpp

# 5. Make changes
# - LSP gives autocomplete
# - Save to format
# - Diagnostics show errors

# 6. Build
<leader>cb

# 7. Run
<leader>cr

# 8. Fix errors if any
[d  " Jump to error
<leader>ca  " Code action to fix

# 9. Rebuild
<leader>cb

# 10. Commit
<leader>lg
s  " Stage
c  " Commit
# Type message
P  " Push
```

## Performance Tips

### Fast File Switching

```vim
# Recent files
<leader>s.

# Buffers
<leader><leader>

# File tree
<leader>e
```

### Quick Edits

```vim
# Split and edit header
<leader>v
<leader>sf
MyClass.hpp

# Return to previous buffer
<C-6>
```

### Terminal Integration

```vim
# Open terminal in split
<leader>v
:terminal

# Build in terminal
cmake --build build

# Keep terminal open
<C-\><C-n>  " Normal mode
# Navigate to code split
<C-h>
```

## Common Workflows Summary

| Task | Command | Description |
|------|---------|-------------|
| Find file | `<leader>sf` | Fuzzy find files |
| Search text | `<leader>sg` | Grep in project |
| Go to def | `gd` | Jump to definition |
| Find refs | `gR` | Show all references |
| Rename | `<leader>rn` | Refactor rename |
| Code action | `<leader>ca` | Quick fixes |
| Format | `<leader>f` | Format code |
| Build | `<leader>cb` | Compile project |
| Run | `<leader>cr` | Execute binary |
| Git | `<leader>lg` | Open LazyGit |
| Next error | `]d` | Jump to error |
| Toggle tree | `<leader>e` | File explorer |

---

**Master these workflows for maximum productivity! 🚀**
