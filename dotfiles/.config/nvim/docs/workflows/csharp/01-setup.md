# C# Development Setup in Neovim

## Overview
Complete C# development environment in Neovim with .NET support, matching Visual Studio capabilities.

## Prerequisites

### Install .NET SDK
```bash
# Ubuntu/Debian
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 8.0

# macOS
brew install --cask dotnet-sdk

# Verify installation
dotnet --version
```

## LSP Configuration

### 1. Install OmniSharp via Mason
```vim
:Mason
```
Search and install:
- `omnisharp` - C# Language Server
- `csharpier` - C# formatter
- `netcoredbg` - .NET debugger

### 2. Automatic Setup
Your `mason.lua` should include:
```lua
ensure_installed = {
  "omnisharp",  -- Add this
  "csharpier",
}
```

### 3. Manual OmniSharp Configuration (Optional)

If you need custom settings, create `~/.config/nvim/after/ftplugin/cs.lua`:

```lua
local lspconfig = require('lspconfig')

lspconfig.omnisharp.setup({
  cmd = { "omnisharp" },
  
  -- Enable organizing imports on format
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr })
        end
      })
    end
  end,

  -- OmniSharp settings
  settings = {
    FormattingOptions = {
      EnableEditorConfigSupport = true,
      OrganizeImports = true,
    },
    RoslynExtensionsOptions = {
      EnableAnalyzersSupport = true,
      EnableImportCompletion = true,
      AnalyzeOpenDocumentsOnly = false,
    },
  },
  
  -- Auto-detect root directory
  root_dir = lspconfig.util.root_pattern(
    "*.sln",
    "*.csproj",
    ".git"
  ),
})
```

## Project Types Support

### Console Application
```bash
dotnet new console -n MyApp
cd MyApp
nvim .
```

### Web API
```bash
dotnet new webapi -n MyApi
cd MyApi
nvim .
```

### ASP.NET Core MVC
```bash
dotnet new mvc -n MyWebApp
cd MyWebApp
nvim .
```

### Class Library
```bash
dotnet new classlib -n MyLibrary
cd MyLibrary
nvim .
```

### Blazor
```bash
dotnet new blazorserver -n MyBlazorApp
cd MyBlazorApp
nvim .
```

## Solution Management

### Create Solution
```bash
dotnet new sln -n MySolution
dotnet new console -n MyApp
dotnet new xunit -n MyApp.Tests
dotnet sln add MyApp/MyApp.csproj
dotnet sln add MyApp.Tests/MyApp.Tests.csproj
```

### Open in Neovim
```bash
nvim MySolution.sln
```

OmniSharp automatically loads all projects in solution!

## NuGet Package Management

### Add Package
```bash
dotnet add package Newtonsoft.Json
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Serilog
```

### Restore Packages
```bash
dotnet restore
```

### Update Package
```bash
dotnet add package Newtonsoft.Json --version 13.0.3
```

### Remove Package
```bash
dotnet remove package Newtonsoft.Json
```

After changes:
```vim
:LspRestart
```

## Features Enabled

### ✅ IntelliSense
- Context-aware code completion
- Method signatures
- Parameter hints
- Documentation tooltips

**Keybindings:**
- `<C-Space>` - Trigger completion
- `<C-j>`/`<C-k>` - Navigate suggestions
- `<CR>` - Accept completion
- `K` - Show documentation

### ✅ Navigation
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gr` - Find all references
- `<leader>sf` - Find files
- `<leader>sg` - Search in project

### ✅ Refactoring
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
  - Extract method
  - Extract local variable
  - Generate constructor
  - Implement interface
  - Add using statement

### ✅ Code Analysis
- Real-time error checking
- Code style warnings
- Best practice suggestions
- Quick fixes

### ✅ Formatting
Already configured in `formatting.lua` - add:
```lua
formatters_by_ft = {
  cs = { "csharpier" },
}
```

Auto-formats on save!

## EditorConfig Support

Create `.editorconfig` in project root:

```ini
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.cs]
csharp_new_line_before_open_brace = all
csharp_indent_case_contents = true
csharp_indent_switch_labels = true

# Naming conventions
dotnet_naming_rule.interfaces_should_be_prefixed_with_i.severity = warning
dotnet_naming_rule.interfaces_should_be_prefixed_with_i.symbols = interface
dotnet_naming_rule.interfaces_should_be_prefixed_with_i.style = begins_with_i

dotnet_naming_symbols.interface.applicable_kinds = interface
dotnet_naming_style.begins_with_i.capitalization = pascal_case
dotnet_naming_style.begins_with_i.required_prefix = I
```

OmniSharp respects these settings automatically!

## Debugging Setup

### 1. Install netcoredbg
```vim
:Mason
# Install: netcoredbg
```

### 2. Configure nvim-dap

Add to plugins:
```lua
{
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
  },
}
```

### 3. C# Debug Configuration

Create `~/.config/nvim/lua/de100/plugins/dap/csharp.lua`:

```lua
local dap = require('dap')

dap.adapters.coreclr = {
  type = 'executable',
  command = vim.fn.stdpath("data") .. '/mason/bin/netcoredbg',
  args = {'--interpreter=vscode'}
}

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
      return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    end,
  },
}

-- Keybindings (add to keymaps.lua)
vim.keymap.set('n', '<leader>db', '<cmd>DapToggleBreakpoint<cr>', { desc = 'Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dc', '<cmd>DapContinue<cr>', { desc = 'Start/Continue' })
vim.keymap.set('n', '<leader>di', '<cmd>DapStepInto<cr>', { desc = 'Step Into' })
vim.keymap.set('n', '<leader>do', '<cmd>DapStepOut<cr>', { desc = 'Step Out' })
vim.keymap.set('n', '<leader>ds', '<cmd>DapStepOver<cr>', { desc = 'Step Over' })
```

## Testing Support

### xUnit/NUnit/MSTest
All supported automatically!

Create test project:
```bash
dotnet new xunit -n MyApp.Tests
```

Example test:
```csharp
public class CalculatorTests
{
    [Fact]
    public void Add_TwoNumbers_ReturnsSum()
    {
        var calc = new Calculator();
        var result = calc.Add(2, 3);
        Assert.Equal(5, result);
    }
}
```

### Run Tests
```bash
# All tests
dotnet test

# Specific test
dotnet test --filter "FullyQualifiedName~CalculatorTests.Add_TwoNumbers_ReturnsSum"

# With verbosity
dotnet test --logger "console;verbosity=detailed"
```

### Run from Neovim
```vim
:!dotnet test
" Or with terminal split
<leader>v
:terminal
dotnet test --logger "console;verbosity=detailed"
```

## Entity Framework Core Support

### Install EF Tools
```bash
dotnet tool install --global dotnet-ef
```

### Common Commands
```bash
# Add migration
dotnet ef migrations add InitialCreate

# Update database
dotnet ef database update

# Generate SQL script
dotnet ef migrations script
```

### Run from Neovim
```vim
:!dotnet ef migrations add AddUserTable
:!dotnet ef database update
```

## ASP.NET Core Development

### Run Application
```bash
dotnet run
# Or with watch (hot reload)
dotnet watch run
```

### From Neovim
```vim
<leader>v  " Split vertical
:terminal
dotnet watch run
```

### Access Swagger
Browser: `http://localhost:5000/swagger`

### Environment Variables
Create `Properties/launchSettings.json`:
```json
{
  "profiles": {
    "MyApi": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "applicationUrl": "https://localhost:5001;http://localhost:5000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    }
  }
}
```

## Code Snippets

Your LuaSnip configuration includes C# snippets:

- `prop` → Property
- `ctor` → Constructor
- `class` → Class template
- `interface` → Interface template
- `try` → Try-catch block
- `foreach` → Foreach loop

Type abbreviation and press `<Tab>` to expand!

## Common Tasks

### Create New Class
```vim
:Neotree
# Navigate to folder
# Press 'a' for new file
MyClass.cs
```

Type `class` and trigger completion for template.

### Implement Interface
```csharp
public class UserService : IUserService
{
    // Cursor on IUserService
}
```
```vim
<leader>ca  " Code action → "Implement interface"
```

### Generate Constructor
```csharp
public class UserService
{
    private readonly IUserRepository _repository;
    // Cursor here
}
```
```vim
<leader>ca  " → "Generate constructor"
```

### Add Using Statement
```csharp
var list = new List<string>();  // List is red underlined
```
```vim
<leader>ca  " → "Add using System.Collections.Generic"
```

## Troubleshooting

### OmniSharp Not Starting
```vim
:LspInfo
:LspRestart
```

Check logs:
```vim
:lua vim.cmd('e ' .. vim.lsp.get_log_path())
```

### Solution Not Loading
```bash
# Verify solution is valid
dotnet sln list

# Reload Neovim
```

### Slow Performance
Increase OmniSharp memory:
```lua
-- In omnisharp setup
cmd = { "omnisharp", "--hostPID", tostring(vim.fn.getpid()) },
```

### Missing SDK
```bash
# Check installed SDKs
dotnet --list-sdks

# Install required version
dotnet-install.sh --version 8.0
```

## Next Steps
- [02-workflow.md](./02-workflow.md) - Daily C# workflow
- [03-debugging.md](./03-debugging.md) - Debugging guide
- [04-aspnet-core.md](./04-aspnet-core.md) - ASP.NET Core specifics
