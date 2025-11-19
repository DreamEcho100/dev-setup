# Python Development Workflow in Neovim

Complete guide for professional Python development with LSP, debugging, testing, virtual environments, and data science workflows.

## Quick Links

- **Setup**: pyright/pylsp, formatters, linters
- **LSP**: Autocomplete, type checking, imports
- **Debugging**: Python debugger with DAP
- **Testing**: pytest, unittest integration
- **Virtual Envs**: Managing Python environments
- **Data Science**: Jupyter-style workflows

## What's Inside

Everything you need to replace PyCharm, VS Code Python, or Jupyter:

✅ **Multiple LSP options** - pyright (fast) vs pylsp (feature-rich)
✅ **Complete debugging** - Step through Python code
✅ **Test integration** - pytest with neotest
✅ **Formatting** - black, autopep8, ruff
✅ **Linting** - pylint, flake8, mypy, ruff
✅ **Virtual environments** - venv, conda, poetry support
✅ **REPL integration** - Interactive development
✅ **Data science** - Jupyter-style workflows
✅ **Type checking** - mypy integration
✅ **Import management** - Auto-organize imports

## Prerequisites

```bash
# Python itself
sudo apt install python3 python3-pip python3-venv

# Language servers (choose one or both)
pip install pyright              # Microsoft's (fast, TypeScript-based)
pip install python-lsp-server    # Python-based (more features)

# Formatters
pip install black isort autopep8 ruff

# Linters
pip install pylint flake8 mypy ruff

# Testing
pip install pytest pytest-cov

# Debugging
pip install debugpy

# Optional: Virtual env managers
pip install virtualenv poetry pipenv
```

## Quick Start (3 minutes)

1. **Install pyright**: `:Mason` → find `pyright` → press `i`
2. **Open Python file**: `nvim main.py`  
3. **Test completion**: Type `import ` and see module suggestions!
4. **Format code**: `<leader>f` (uses black)
5. **Run file**: `:!python %` or use REPL workflow

## Your Current Config Status

✅ **Already Configured**:
- LSP support (pyright via Mason)
- Formatting (black, isort via conform.nvim)
- Linting (pylint, mypy via nvim-lint)
- Syntax highlighting (Treesitter)
- File navigation (Telescope, Neo-tree)

⚠️ **Needs Setup**:
- Debugging (DAP configuration - see guide below)
- Testing (neotest with pytest adapter)
- REPL integration (optional toggleterm)

## LSP Comparison: pyright vs pylsp

### pyright (Recommended - Already in your config!)

**Pros**:
- ⚡ Very fast (TypeScript-based)
- 🎯 Excellent type checking
- 🔍 Great autocomplete
- 📦 Low memory usage
- 🚀 Quick startup

**Cons**:
- Fewer features than pylsp
- Less customizable

**Best for**: Most Python projects, type-heavy codebases

### python-lsp-server (pylsp)

**Pros**:
- 🛠️ More features
- 🔧 Highly customizable
- 🔌 Plugin ecosystem
- 📝 Better docstring support

**Cons**:
- Slower startup
- Higher memory usage

**Best for**: Large projects, specific plugin needs

### Both (Recommended for advanced users)

Use pyright for speed + pylsp for specific features:

```lua
-- In Mason config, install both
ensure_installed = {
    "pyright",
    "pylsp",
}
```

## Virtual Environment Management

### Your System Already Handles This!

Your config's LSP automatically detects:
- `venv/` directories
- `.venv/` directories  
- `conda` environments
- `poetry` environments

### Manual Virtual Env Setup

```bash
# Create virtual environment
python -m venv venv

# Activate (terminal)
source venv/bin/activate

# Install packages
pip install -r requirements.txt

# In Neovim, LSP auto-detects venv!
nvim main.py
```

### Poetry Projects

```bash
# Create project
poetry init
poetry add requests

# Open Neovim
nvim .

# LSP automatically uses Poetry's venv!
```

## Typical Workflow

```vim
# 1. Activate virtual environment (in terminal)
source venv/bin/activate

# 2. Open project
nvim .

# 3. Edit Python file
<leader>sf
main.py

# 4. Code with LSP assistance
import requests  # Autocomplete shows methods

def fetch_data(url: str) -> dict:
    # Type hints enable better completion
    response = requests.get(url)
    response.  # LSP shows all methods!
    return response.json()

# 5. Format on save
<leader>f        " black + isort

# 6. Check for errors
]d               " Next diagnostic
<leader>ca       " Quick fix

# 7. Run tests
<leader>tt       " pytest under cursor

# 8. Debug if needed
<leader>db       " Set breakpoint
<F5>             " Start debugging

# 9. REPL for quick experiments
<leader>tp       " Python REPL
```

## Key Features

### Code Intelligence
- **Type hints aware**: Better completion with types
- **Import management**: Auto-import, organize imports
- **Refactoring**: Rename across files
- **Go to definition**: Jump to function/class definition
- **Find references**: See all usages
- **Documentation**: Docstrings on hover

### Formatting
- **black**: Opinionated formatter (default)
- **isort**: Import sorting
- **autopep8**: PEP 8 compliance
- **ruff**: Fast all-in-one (format + lint)

### Linting
- **pylint**: Comprehensive checking
- **flake8**: Style checking
- **mypy**: Static type checking
- **ruff**: Fast, Rust-based linter

### Testing
- **pytest**: Modern testing framework
- **unittest**: Standard library
- **doctest**: Test in docstrings
- **Coverage**: Test coverage reports

## Learning Path

1. **Week 1**: Basic LSP, autocomplete, formatting
2. **Week 2**: Testing with pytest + neotest
3. **Week 3**: Debugging workflows
4. **Week 4**: Virtual envs, REPL workflows
5. **Ongoing**: Data science, type hints mastery

## Common Use Cases

### Web Development (FastAPI, Django, Flask)
- LSP for framework-specific completions
- Debug web requests
- Test API endpoints
- Hot reload with terminal

### Data Science (Pandas, NumPy, Matplotlib)
- REPL-driven development
- Send code to Python terminal
- Inspect DataFrames
- Plot in external viewer

### Machine Learning (TensorFlow, PyTorch)
- Type hints for tensor shapes
- Debug training loops
- Profile performance
- Experiment in REPL

### Automation & Scripting
- Quick file editing
- Run scripts instantly
- Debug edge cases
- Test with pytest

### CLI Tools (Click, argparse)
- Test command parsing
- Debug CLI workflows
- Format with black
- Type check with mypy

## Project Structure Best Practices

```
my-python-project/
├── pyproject.toml       # Poetry/project config
├── setup.py             # Or setuptools config
├── requirements.txt     # Dependencies
├── .python-version      # Python version
├── src/
│   └── mypackage/
│       ├── __init__.py
│       ├── main.py
│       └── utils.py
├── tests/
│   ├── __init__.py
│   ├── test_main.py
│   └── test_utils.py
├── venv/                # Virtual environment (gitignored)
└── .mypy_cache/         # Type checking cache (gitignored)
```

## Next Steps

1. Read this README
2. Set up your first Python project
3. Configure virtual environment
4. Try the debugging guide
5. Set up pytest with neotest
6. Master the REPL workflow
7. Explore data science patterns

---

**Python in Neovim is faster and more flexible than any IDE! 🐍✨**
