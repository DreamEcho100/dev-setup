# C/C++ Development Workflow in Neovim

Complete guide for professional C/C++ development with LSP, debugging, CMake integration, and best practices.

## Quick Links

- **Setup**: Install clangd, CMake, debugger
- **LSP**: Code completion, navigation, refactoring
- **CMake**: Build system integration
- **Debugging**: GDB/LLDB with DAP
- **Testing**: Google Test integration
- **Real Workflows**: From setup to production

## What's Inside

This directory contains everything you need to replace Visual Studio, CLion, or any IDE for C/C++ development:

✅ **Complete LSP setup** - clangd configuration
✅ **CMake integration** - Build, run, debug from Neovim  
✅ **Debugging workflows** - Step through code, inspect variables
✅ **Testing setup** - Google Test, Catch2 integration
✅ **Real-world examples** - Actual development scenarios
✅ **Problem solutions** - Common issues & fixes
✅ **Best practices** - Modern C++ patterns

## Prerequisites

```bash
# Compilers
sudo apt install build-essential  # GCC/G++
# Or
sudo apt install clang             # Clang

# Build tools
sudo apt install cmake make ninja-build

# Debugger
sudo apt install gdb               # GDB
# Or via Mason: codelldb, cpptools

# Language Server
:Mason
# Install: clangd

# Formatters
sudo apt install clang-format clang-tidy
```

## Quick Start (5 minutes)

1. **Install clangd**: `:Mason` → find `clangd` → press `i`
2. **Open C++ file**: `nvim main.cpp`
3. **Test completion**: Type `std::` and see completions!
4. **Format code**: `<leader>f`
5. **Build project**: See CMake integration guide

## Your Current Config Status

✅ **Already Configured**:
- LSP support (via Mason)
- Formatting (clang-format via conform.nvim)
- Syntax highlighting (Treesitter)
- File navigation (Telescope, Neo-tree)
- Git integration

⚠️ **Needs Setup**:
- CMake integration (optional plugin)
- Debugging (DAP configuration)
- Testing (neotest adapter)

## Key Features

### Code Intelligence (LSP)
- **Autocomplete**: Context-aware suggestions
- **Go to definition**: Jump to function/class definition
- **Find references**: See all usages
- **Rename**: Refactor symbol names project-wide
- **Diagnostics**: Real-time error checking
- **Documentation**: Hover for function docs

### Build System (CMake)
- **Configure**: Generate build files
- **Build**: Compile project
- **Run**: Execute binary
- **Debug**: Launch with debugger
- **Select target**: Choose what to build

### Debugging
- **Breakpoints**: Visual breakpoint management
- **Step through**: Line-by-line execution
- **Inspect**: View variable values
- **Call stack**: Navigate function calls
- **Conditional**: Break on conditions

## Typical Workflow

```vim
# 1. Open project
nvim .

# 2. Navigate to file
<leader>sf       " Find files
main.cpp

# 3. Edit code with LSP
# - Type and get completions
# - gd to jump to definitions
# - K for documentation

# 4. Format on save
<leader>f

# 5. Build project
<leader>cg       " Configure CMake
<leader>cb       " Build

# 6. Run
<leader>cr       " Run executable

# 7. Debug if needed
<leader>db       " Set breakpoint
<leader>cd       " Start debugging

# 8. Commit changes
<leader>lg       " LazyGit
```

## Learning Path

1. **Week 1**: Basic LSP (completion, navigation)
2. **Week 2**: Build with CMake
3. **Week 3**: Debugging workflows
4. **Week 4**: Testing integration
5. **Ongoing**: Real-world projects

## Common Use Cases

- **System programming**: OS-level development
- **Game development**: High-performance games
- **Embedded systems**: Microcontroller programming
- **High-performance computing**: Scientific computing
- **Libraries**: Creating reusable libraries
- **Legacy code**: Working with existing C/C++ codebases

## Next Steps

1. Read this README thoroughly
2. Follow setup instructions
3. Try the example workflows
4. Configure for your specific needs
5. Practice with real projects

---

**Start with LSP setup, then gradually add more tools as needed!**
