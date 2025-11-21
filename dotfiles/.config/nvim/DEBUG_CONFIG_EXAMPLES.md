# Project-Specific Debug Configuration Examples

Your nvim-dap setup now supports 3 ways to configure debugging per project:

## 🎯 Option 1: `.vscode/launch.json` (VS Code Compatible)

Perfect if you switch between VS Code and Neovim, or work with teammates using VS Code.

### JavaScript/TypeScript/Node.js

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "pwa-node",
      "request": "launch",
      "name": "Launch Express Server",
      "program": "${workspaceFolder}/server.js",
      "env": {
        "NODE_ENV": "development",
        "PORT": "3000"
      }
    },
    {
      "type": "pwa-node",
      "request": "launch",
      "name": "npm run dev",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "cwd": "${workspaceFolder}"
    },
    {
      "type": "pwa-node",
      "request": "launch",
      "name": "Jest Tests",
      "program": "${workspaceFolder}/node_modules/.bin/jest",
      "args": ["--runInBand"],
      "console": "integratedTerminal"
    }
  ]
}
```

### Python

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "python",
      "request": "launch",
      "name": "Django runserver",
      "program": "${workspaceFolder}/manage.py",
      "args": ["runserver", "8000"],
      "django": true
    },
    {
      "type": "python",
      "request": "launch",
      "name": "Flask app",
      "module": "flask",
      "env": {
        "FLASK_APP": "app.py",
        "FLASK_ENV": "development"
      },
      "args": ["run", "--no-debugger", "--no-reload"],
      "jinja": true
    },
    {
      "type": "python",
      "request": "launch",
      "name": "FastAPI",
      "module": "uvicorn",
      "args": ["main:app", "--reload"],
      "pythonPath": "${workspaceFolder}/venv/bin/python"
    }
  ]
}
```

### C/C++

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "codelldb",
      "request": "launch",
      "name": "Debug executable",
      "program": "${workspaceFolder}/build/myapp",
      "args": ["--verbose"],
      "cwd": "${workspaceFolder}",
      "preLaunchTask": "make"
    }
  ]
}
```

### Go

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "go",
      "request": "launch",
      "name": "Launch Package",
      "mode": "debug",
      "program": "${workspaceFolder}/cmd/server"
    }
  ]
}
```

---

## 🔧 Option 2: `.nvim/dap.lua` (Neovim-Specific, More Powerful)

More flexible than JSON. Can use Lua functions, conditionals, etc.

### Project Structure:

```
your-project/
├── .nvim/
│   └── dap.lua          ← Create this
├── src/
├── package.json
└── ...
```

### JavaScript/TypeScript Example

`.nvim/dap.lua`:

```lua
return {
  configurations = {
    javascript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch Express API",
        program = "${workspaceFolder}/src/server.js",
        env = {
          NODE_ENV = "development",
          PORT = "3000",
          DB_HOST = "localhost"
        },
        cwd = "${workspaceFolder}",
        -- Auto-restart on file changes
        restart = true,
        -- Show console output
        console = "integratedTerminal"
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch with custom config",
        program = "${workspaceFolder}/dist/index.js",
        -- Dynamic environment based on user input
        env = function()
          local env = vim.fn.input("Environment (dev/prod): ")
          return {
            NODE_ENV = env,
            CONFIG_FILE = ".env." .. env
          }
        end
      }
    },
    typescript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "ts-node current file",
        runtimeExecutable = "ts-node",
        runtimeArgs = {"--project", "tsconfig.json"},
        program = "${file}",
        cwd = "${workspaceFolder}"
      }
    }
  }
}
```

### Python Example

`.nvim/dap.lua`:

```lua
return {
  configurations = {
    python = {
      {
        type = "python",
        request = "launch",
        name = "Django runserver",
        program = "${workspaceFolder}/manage.py",
        args = {"runserver", "8000"},
        django = true,
        pythonPath = function()
          -- Auto-detect virtual environment
          local venv = vim.fn.getcwd() .. "/venv/bin/python"
          if vim.fn.filereadable(venv) == 1 then
            return venv
          end
          return "/usr/bin/python3"
        end
      },
      {
        type = "python",
        request = "launch",
        name = "Run with args",
        program = "${file}",
        args = function()
          local args_string = vim.fn.input("Arguments: ")
          return vim.split(args_string, " ")
        end
      },
      {
        type = "python",
        request = "launch",
        name = "Pytest",
        module = "pytest",
        args = {"-v", "${file}"}
      }
    }
  }
}
```

### C/C++ Example

`.nvim/dap.lua`:

```lua
return {
  configurations = {
    cpp = {
      {
        name = "Debug main executable",
        type = "codelldb",
        request = "launch",
        program = "${workspaceFolder}/build/main",
        args = {},
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        -- Run make before debugging
        preLaunchTask = "make"
      },
      {
        name = "Debug tests",
        type = "codelldb",
        request = "launch",
        program = "${workspaceFolder}/build/tests",
        args = {"--gtest_filter=*"},
        cwd = "${workspaceFolder}"
      }
    }
  }
}
```

### Go Example

`.nvim/dap.lua`:

```lua
return {
  configurations = {
    go = {
      {
        type = "go",
        name = "Debug main package",
        request = "launch",
        program = "${workspaceFolder}/cmd/server",
        env = {
          ENV = "development",
          PORT = "8080"
        }
      },
      {
        type = "go",
        name = "Debug current test",
        request = "launch",
        mode = "test",
        program = "${file}"
      }
    }
  }
}
```

---

## 📋 Option 3: Global Configs (Already in nvim-dap.lua)

Edit `~/.config/nvim/lua/de100/plugins/nvim-dap.lua` to add global default configs.

Good for configs you use in ALL projects of a language.

---

## 🔥 Usage

### With `.vscode/launch.json`:

1. Create the file in your project root
2. Open Neovim in that project
3. Press `<F5>` → Select your configuration

### With `.nvim/dap.lua`:

1. Create `.nvim/dap.lua` in your project root
2. Open Neovim in that project
3. Press `<F5>` → Your custom configs appear!

### Priority:

```
.nvim/dap.lua > .vscode/launch.json > global configs
```

---

## 💡 Tips

**Variables you can use:**

- `${workspaceFolder}` - Project root directory
- `${file}` - Current file path
- `${fileBasename}` - Current filename
- `${fileDirname}` - Current file's directory
- `${cwd}` - Current working directory

**Common patterns:**

```lua
-- Interactive program selection
program = function()
  return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
end

-- Auto-detect build type
program = function()
  local debug_path = vim.fn.getcwd() .. '/build/debug/app'
  local release_path = vim.fn.getcwd() .. '/build/release/app'
  if vim.fn.filereadable(debug_path) == 1 then
    return debug_path
  end
  return release_path
end

-- Environment from file
env = function()
  local env_file = vim.fn.getcwd() .. '/.env'
  local env = {}
  if vim.fn.filereadable(env_file) == 1 then
    for line in io.lines(env_file) do
      local key, value = line:match('([^=]+)=(.*)')
      if key then env[key] = value end
    end
  end
  return env
end
```

---

## 🎯 Real-World Example

**Next.js Project:**

`.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "pwa-node",
      "request": "launch",
      "name": "Next.js: debug server",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "port": 9229,
      "serverReadyAction": {
        "pattern": "started server on .+, url: (https?://.+)",
        "uriFormat": "%s",
        "action": "debugWithChrome"
      }
    },
    {
      "type": "pwa-node",
      "request": "launch",
      "name": "Next.js: debug build",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "start"],
      "port": 9229
    }
  ]
}
```

Now press `<F5>` and select which mode to debug in! 🚀
