# JavaScript/TypeScript Development Workflow

Complete guide for modern JS/TS development with LSP, debugging, testing, and framework integration.

## What's Covered

✅ **TypeScript LSP** - tsserver with full type checking
✅ **JavaScript LSP** - Modern ES6+ support
✅ **Debugging** - Node.js, Browser, Chrome DevTools
✅ **Testing** - Jest, Vitest, Mocha integration
✅ **Formatting** - Prettier, Biome, ESLint
✅ **Linting** - ESLint with modern plugins
✅ **Type Checking** - Full TypeScript support
✅ **Import Management** - Auto-imports, organize imports
✅ **Framework Support** - React, Vue, Svelte, etc.

## Prerequisites

```bash
# Node.js & npm
sudo apt install nodejs npm
# Or use nvm for version management

# Language Servers
npm install -g typescript typescript-language-server
# Via Mason: :Mason → tsserver

# Formatters
npm install -g prettier @biomejs/biome
npm install -g eslint

# Debuggers (via Mason)
:Mason
# Install: js-debug-adapter

# Testing
npm install -D jest vitest @vitest/ui
```

## Your Current Config Status

✅ **Already Configured**:
- tsserver LSP (via Mason)
- Prettier formatting (via conform.nvim)
- ESLint (via nvim-lint)  
- Treesitter (JS/TS syntax)
- Telescope, Neo-tree

⚠️ **Optional Setup**:
- Debugging (DAP for Node.js/Browser)
- Testing (neotest-jest, neotest-vitest)
- Biome (faster alternative to Prettier + ESLint)

## Quick Start

1. **Install tsserver**: `:Mason` → `tsserver` → `i`
2. **Open TS file**: `nvim app.ts`
3. **Type**: `const data: ` → see type suggestions!
4. **Format**: `<leader>f`
5. **Run**: `:!node %` or `:!tsx %`

## LSP Features

### TypeScript Server (tsserver)

**Your config already has this!**

```typescript
// Full type checking
interface User {
  name: string;
  age: number;
}

const user: User = {
  name: "John",
  age: 30,
  // LSP shows error if missing properties!
};

// Autocomplete with types
user.  // Shows: name, age (with types!)

// Go to definition
// Cursor on User, press gd → jumps to interface

// Find references
// Cursor on User, press gR → shows all usages

// Rename refactoring
// Cursor on age, <leader>rn → rename everywhere
```

### JavaScript (via tsserver)

Works for `.js` files too!

```javascript
// JSDoc for type hints
/**
 * @param {string} name
 * @param {number} age
 * @returns {Object}
 */
function createUser(name, age) {
  return { name, age };
}

// LSP understands JSDoc types!
createUser('John', 30).  // Shows name, age
```

## Formatting Options

### Option 1: Prettier (Current default)

**Already in your config!**

```lua
-- conform.nvim config
javascript = { "prettier" },
typescript = { "prettier" },
```

**Configuration**: Create `.prettierrc`:
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```

### Option 2: Biome (Faster alternative)

```lua
-- Add to conform config
javascript = { "biome" },
typescript = { "biome" },
```

**Configuration**: `biome.json`:
```json
{
  "formatter": {
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  }
}
```

**Biome advantages**:
- ⚡ 10-20x faster than Prettier
- 🔧 Built-in linting
- 📦 Single binary
- 🎯 TypeScript native

## Linting

### ESLint (Current)

**Already configured via nvim-lint!**

**Configuration**: `.eslintrc.json`:
```json
{
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "rules": {
    "no-console": "warn",
    "no-unused-vars": "error",
    "@typescript-eslint/no-explicit-any": "warn"
  }
}
```

## Typical Workflow

```vim
# 1. Open project
nvim .

# 2. Navigate to file
<leader>sf       " Find files
app.ts

# 3. Edit with full LSP
interface Todo {
  id: number;
  title: string;
  completed: boolean;
}

function createTodo(title: string): Todo {
  return {
    id: Date.now(),
    title,
    completed: false,
    // LSP validates structure!
  };
}

# 4. Auto-import
// Type a class/function from another file
// LSP suggests and auto-imports!

# 5. Format on save
<leader>f

# 6. Fix linting issues
]d               " Next diagnostic
<leader>ca       " Quick fix (e.g., "Organize imports")

# 7. Run file
:!tsx %          " TypeScript
:!node %         " JavaScript

# 8. Run tests
<leader>tt       " With neotest

# 9. Debug
<leader>db       " Set breakpoint
<F5>             " Start debugging

# 10. Commit
<leader>lg
```

## TypeScript Specific Features

### Type Checking

```typescript
// Real-time type checking
let num: number = 42;
num = "string";  // ❌ LSP shows error immediately

// Union types
type Status = "pending" | "success" | "error";
const status: Status = "pending";

// Generics with autocomplete
function identity<T>(arg: T): T {
  return arg;
}

identity(42).  // LSP knows it's number!
identity("hi").  // LSP knows it's string!
```

### Import Management

```typescript
// Auto-import
// Type: HttpClient
// LSP suggests: "Import from './http-client'"
// Press Enter → automatically adds import!

// Organize imports
<leader>ca       " Code actions
// Select "Organize Imports"
// Removes unused, sorts alphabetically
```

### Quick Fixes

```typescript
// Missing property
const user: User = {
  name: "John"
  // ❌ Missing 'age'
};

// Cursor on error
<leader>ca
// "Add missing properties"
// → Automatically adds age: number
```

### Refactoring

```typescript
// Extract to const
const result = calculateTotal(items) + getTax();

// Visual select expression
// <leader>ca → "Extract to constant"

// Inline variable
const MULTIPLIER = 2;
const doubled = value * MULTIPLIER;

// <leader>ca on MULTIPLIER → "Inline variable"
// → const doubled = value * 2;
```

## Debugging Setup

### Node.js Debugging

```lua
-- Add to DAP config
dap.adapters["pwa-node"] = {
  type = "server",
  host = "localhost",
  port = "${port}",
  executable = {
    command = "node",
    args = {
      vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
      "${port}",
    },
  }
}

dap.configurations.javascript = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    cwd = "${workspaceFolder}",
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach",
    processId = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
  },
}

dap.configurations.typescript = dap.configurations.javascript
```

### Debug Workflow

```vim
# 1. Set breakpoint
<leader>db       " Toggle breakpoint on current line

# 2. Start debugging
<F5>             " Launch file

# 3. Step through
<F10>            " Step over
<F11>            " Step into function
<F12>            " Step out

# 4. Inspect variables
K                " Hover over variable
# Or use DAP UI

# 5. Continue
<F5>             " Continue to next breakpoint

# 6. Stop
<leader>dt       " Terminate debug session
```

## Testing Integration

### Jest Setup

```bash
npm install -D jest @types/jest ts-jest
```

```lua
-- Add to neotest config
require("neotest").setup({
  adapters = {
    require("neotest-jest")({
      jestCommand = "npm test --",
      jestConfigFile = "jest.config.js",
      env = { CI = true },
      cwd = function()
        return vim.fn.getcwd()
      end,
    }),
  },
})
```

### Vitest Setup (Modern, faster)

```bash
npm install -D vitest @vitest/ui
```

```lua
require("neotest").setup({
  adapters = {
    require("neotest-vitest"),
  },
})
```

### Test Workflow

```typescript
// user.test.ts
import { describe, it, expect } from 'vitest';
import { createUser } from './user';

describe('createUser', () => {
  it('creates user with correct properties', () => {
    const user = createUser('John', 30);
    expect(user.name).toBe('John');
    expect(user.age).toBe(30);
  });
});
```

```vim
# Run test under cursor
<leader>tt

# Run all tests in file
<leader>tf

# Run all tests
<leader>ta

# Debug test
<leader>td       " Debug nearest test

# Show test summary
<leader>ts
```

## Framework-Specific Tips

### React/JSX

```typescript
// TSX support built-in with treesitter!
import React from 'react';

interface Props {
  name: string;
  age: number;
}

export const User: React.FC<Props> = ({ name, age }) => {
  return (
    <div>
      {/* LSP autocomplete works in JSX! */}
      <h1>{name}</h1>
      <p>{age}</p>
    </div>
  );
};

// Component completion
<User name="John" age={30} />
//     ↑ LSP shows required props!
```

### Vue

```bash
# Install Volar (Vue Language Server)
:Mason
# Find: vue-language-server (volar)
```

### Svelte

```bash
:Mason
# Find: svelte-language-server
```

## Project Structure

```
my-ts-project/
├── tsconfig.json
├── package.json
├── .prettierrc
├── .eslintrc.json
├── src/
│   ├── index.ts
│   ├── types.ts
│   └── utils.ts
├── tests/
│   └── index.test.ts
├── dist/          # Compiled output
└── node_modules/
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

## Common Problems & Solutions

### Problem: tsserver too slow

**Solution**: Exclude node_modules

```json
// tsconfig.json
{
  "exclude": ["node_modules", "**/*.spec.ts"]
}
```

### Problem: Missing imports

**Solution**: Use code actions

```vim
]d               " Go to import error
<leader>ca       " "Add import from..."
```

### Problem: Type errors from dependencies

**Solution**: Install @types

```bash
npm install -D @types/node @types/react
```

## Performance Tips

1. **Exclude large dirs**: Update `tsconfig.json`
2. **Use project references**: For monorepos
3. **Enable incremental**: `"incremental": true` in tsconfig
4. **Limit file watching**: Exclude node_modules in editor

## Keybindings Summary

```vim
# LSP
gd               " Go to definition
gD               " Go to declaration  
gR               " Find references
K                " Hover documentation
<leader>ca       " Code actions (imports, fixes)
<leader>rn       " Rename symbol

# Diagnostics
]d / [d          " Next/prev error
<leader>ca       " Quick fixes

# Formatting
<leader>f        " Format file

# Testing
<leader>tt       " Run test under cursor
<leader>tf       " Run file tests
<leader>td       " Debug test

# Debugging
<leader>db       " Toggle breakpoint
<F5>             " Start/continue
<F10>            " Step over
<F11>            " Step into
```

---

**Modern JavaScript/TypeScript development is blazing fast in Neovim! 🚀**
