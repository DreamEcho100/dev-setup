# Python Development Setup in Neovim

## Complete Python Environment Configuration

Your config is already configured for Python! This guide ensures everything works perfectly.

## Prerequisites

### Python Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip python3-venv

# macOS
brew install python3

# Verify
python3 --version
pip3 --version
```

## LSP Configuration (Already Done!)

Your `mason.lua` includes:
```lua
ensure_installed = {
    "pyright",  -- Python LSP ✅
    "pylsp",    -- Alternative Python LSP ✅
}
```

### Install via Mason

```vim
:Mason
# Should show pyright and pylsp installed
# If not, install them:
# Navigate and press 'i'
```

## Formatter Configuration (Already Done!)

Your `formatting.lua` includes:
```lua
formatters_by_ft = {
    python = { "isort", "black" },
}
```

### Install Formatters

```vim
:Mason
# Install:
# - black (Python formatter)
# - isort (Import sorter)
```

Or globally:
```bash
pip3 install black isort
```

## Linter Configuration (Already Done!)

Your `linting.lua` includes:
```lua
linters_by_ft = {
    python = { "pylint" },
}
```

### Install Linters

```vim
:Mason
# Install: pylint
```

Or:
```bash
pip3 install pylint ruff
```

## Virtual Environment Setup

### Create Virtual Environment

```bash
# In your project directory
python3 -m venv .venv

# Activate
source .venv/bin/activate  # Linux/macOS
# or
.venv\Scripts\activate  # Windows

# Install packages
pip install requests numpy pandas
```

### Neovim Detects Virtual Environment Automatically!

When you open a Python file in a project with `.venv/`, pyright automatically uses it.

### Manual Selection (if needed)

```vim
:!source .venv/bin/activate
:LspRestart
```

## Project Structure

### Basic Python Project

```
my-python-project/
├── .venv/                  # Virtual environment
├── src/
│   ├── __init__.py
│   ├── main.py
│   └── utils.py
├── tests/
│   ├── __init__.py
│   └── test_utils.py
├── requirements.txt
├── setup.py
└── README.md
```

### Create Project

```bash
mkdir my-python-project && cd my-python-project
python3 -m venv .venv
source .venv/bin/activate

# Create structure
mkdir -p src tests
touch src/__init__.py src/main.py
touch tests/__init__.py tests/test_utils.py
touch requirements.txt

# Open in Neovim
nvim .
```

## Verify LSP Features

### Create Test File

```python
# src/main.py
from typing import List, Dict, Optional
import requests

def fetch_user(user_id: int) -> Dict[str, any]:
    """
    Fetches user data from API
    
    Args:
        user_id: The ID of the user to fetch
        
    Returns:
        Dictionary containing user data
    """
    response = requests.get(f"https://api.example.com/users/{user_id}")
    return response.json()

class UserManager:
    def __init__(self):
        self.users: List[Dict] = []
    
    def add_user(self, name: str, age: int) -> None:
        user = {
            "name": name,
            "age": age,
        }
        self.users.append(user)
    
    def get_users(self) -> List[Dict]:
        return self.users

def main():
    manager = UserManager()
    manager.add_user("John", 30)
    
    # Test autocomplete
    manager.  # Should show: add_user, get_users, users
    
    users = manager.get_users()
    for user in users:
        print(f"{user['name']} is {user['age']} years old")

if __name__ == "__main__":
    main()
```

### Test Features

```vim
# Open file
nvim src/main.py

# 1. Check LSP
:LspInfo
# Should show: pyright (client id X)

# 2. Autocomplete
# Type: manager.
# Should show methods!

# 3. Hover documentation
# Cursor on 'fetch_user'
K
# Shows function signature and docstring

# 4. Go to definition
# Cursor on 'UserManager'
gd
# Jumps to class definition

# 5. Find references
# Cursor on 'add_user'
gR
# Shows all usages

# 6. Type checking
# Create error:
age: str = 30  # Type error!
# Red underline appears

# 7. Rename
<leader>rn
# Rename symbol

# 8. Format
<leader>f
# Formats with black + isort
```

## Type Hints & Type Checking

### Basic Types

```python
from typing import List, Dict, Tuple, Set, Optional, Union, Any

# Variables
name: str = "John"
age: int = 30
height: float = 5.9
is_active: bool = True

# Collections
numbers: List[int] = [1, 2, 3]
scores: Dict[str, float] = {"math": 95.5, "science": 87.0}
coordinates: Tuple[float, float] = (10.5, 20.3)
unique_ids: Set[int] = {1, 2, 3}

# Optional
email: Optional[str] = None  # Can be str or None

# Union
user_id: Union[int, str] = 123  # Can be int or str

# Any (avoid if possible)
data: Any = {"key": "value"}
```

### Function Annotations

```python
def greet(name: str, age: int) -> str:
    return f"Hello {name}, you are {age} years old"

def process_data(
    data: List[Dict[str, any]],
    filter_key: Optional[str] = None
) -> List[Dict]:
    """Process and filter data"""
    if filter_key:
        return [item for item in data if filter_key in item]
    return data
```

### Class Annotations

```python
from typing import ClassVar, Optional

class User:
    # Class variable
    users_count: ClassVar[int] = 0
    
    def __init__(self, name: str, age: int):
        self.name: str = name
        self.age: int = age
        User.users_count += 1
    
    def get_info(self) -> str:
        return f"{self.name} ({self.age})"
    
    @classmethod
    def from_dict(cls, data: Dict[str, any]) -> 'User':
        return cls(data['name'], data['age'])
```

## Configuration Files

### pyproject.toml

```toml
[tool.black]
line-length = 100
target-version = ['py311']
include = '\.pyi?$'

[tool.isort]
profile = "black"
line_length = 100
multi_line_output = 3

[tool.pylint.messages_control]
disable = ["C0111", "C0103"]

[tool.pylint.format]
max-line-length = 100
```

### .pylintrc

```ini
[MASTER]
ignore=CVS,.git,__pycache__,.venv

[MESSAGES CONTROL]
disable=
    missing-docstring,
    invalid-name,
    too-few-public-methods

[FORMAT]
max-line-length=100
indent-string='    '

[BASIC]
good-names=i,j,k,x,y,z,_
```

### requirements.txt

```txt
requests>=2.31.0
numpy>=1.24.0
pandas>=2.0.0
pytest>=7.4.0
black>=23.0.0
isort>=5.12.0
pylint>=3.0.0
```

Install:
```bash
pip install -r requirements.txt
```

## Development Tools

### IPython (Enhanced REPL)

```bash
pip install ipython

# Run
ipython
```

```vim
# From Neovim
:!ipython
```

### Jupyter Notebooks

```bash
pip install jupyter

# Run
jupyter notebook
```

For Neovim integration, use `jupytext`:
```bash
pip install jupytext
```

### Poetry (Dependency Management)

```bash
# Install
curl -sSL https://install.python-poetry.org | python3 -

# Create project
poetry new my-project
cd my-project

# Add dependencies
poetry add requests numpy

# Install
poetry install

# Run
poetry run python src/main.py
```

## Testing Setup

### pytest

```bash
pip install pytest pytest-cov
```

Create test:
```python
# tests/test_utils.py
import pytest
from src.utils import add, divide

def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0

def test_divide():
    assert divide(10, 2) == 5
    
    with pytest.raises(ValueError):
        divide(10, 0)

@pytest.mark.parametrize("a,b,expected", [
    (1, 2, 3),
    (5, 5, 10),
    (-1, 1, 0),
])
def test_add_parametrized(a, b, expected):
    assert add(a, b) == expected
```

Run tests:
```vim
:!pytest
:!pytest tests/test_utils.py
:!pytest -v  # Verbose
:!pytest --cov=src  # With coverage
```

## Debugging Setup (Optional)

### debugpy

```bash
pip install debugpy
```

### DAP Configuration

Add to Neovim plugins:
```lua
{
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'mfussenegger/nvim-dap-python',
  },
}
```

Configure:
```lua
-- In dap config
require('dap-python').setup('~/.venv/bin/python')
```

Usage:
```vim
<leader>db  # Toggle breakpoint
<F5>        # Start debugging
<F10>       # Step over
```

## Common Packages

### Data Science

```bash
pip install numpy pandas matplotlib seaborn scikit-learn
```

### Web Development

```bash
pip install flask django fastapi uvicorn
```

### API & HTTP

```bash
pip install requests httpx aiohttp
```

### Database

```bash
pip install sqlalchemy psycopg2-binary pymongo
```

### Async

```bash
pip install asyncio aiofiles
```

## Keybindings for Python

Add to `keymaps.lua`:

```lua
-- Python specific
vim.keymap.set('n', '<leader>pr', ':!python3 %<CR>', 
    { desc = '[P]ython [R]un current file' })

vim.keymap.set('n', '<leader>pt', ':!pytest<CR>', 
    { desc = '[P]ython [T]est' })

vim.keymap.set('n', '<leader>pi', ':!pip install -r requirements.txt<CR>', 
    { desc = '[P]ython [I]nstall requirements' })
```

## Troubleshooting

### LSP Not Working

```vim
:LspInfo
:LspRestart

# Check Python version
:!python3 --version

# Check pyright
:!pyright --version
```

### Import Not Found

```bash
# Activate virtual environment
source .venv/bin/activate

# Install package
pip install package-name

# Restart LSP
:LspRestart
```

### Wrong Python Version

```vim
# Check which Python LSP is using
:lua print(vim.lsp.get_active_clients()[1].config.cmd[1])

# Specify Python path in workspace
# Create .vim/coc-settings.json (if needed)
{
  "python.pythonPath": ".venv/bin/python"
}
```

## Next Steps

- [02-workflow.md](./02-workflow.md) - Daily Python workflow
- [03-data-science.md](./03-data-science.md) - NumPy, Pandas, ML
- [04-web-development.md](./04-web-development.md) - Flask, FastAPI

---

**Python development environment ready! 🐍**
