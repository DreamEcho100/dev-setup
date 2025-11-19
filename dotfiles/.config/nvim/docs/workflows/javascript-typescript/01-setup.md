# JavaScript/TypeScript Setup in Neovim

## Complete Modern JS/TS Development Setup

Your config is already 90% configured for JavaScript/TypeScript! This guide completes the setup.

## Prerequisites

### Node.js & npm

```bash
# Ubuntu/Debian (via NodeSource)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS
brew install node

# Verify
node --version
npm --version
```

### pnpm (Modern Package Manager)

```bash
npm install -g pnpm

# Or via Homebrew
brew install pnpm
```

### yarn (Alternative)

```bash
npm install -g yarn
```

## LSP Configuration (Already Done!)

Your `mason.lua` already includes:
```lua
ensure_installed = {
    "ts_ls",      -- TypeScript/JavaScript LSP ✅
    "eslint",     -- ESLint LSP ✅
    "html",       -- HTML support ✅
    "cssls",      -- CSS support ✅
    "tailwindcss",-- Tailwind CSS ✅
    "emmet_ls",   -- Emmet abbreviations ✅
}
```

### Verify LSP

```vim
# Create test file
nvim test.ts

# Check LSP
:LspInfo
# Should show: ts_ls (tsserver)
```

## Formatter Configuration (Already Done!)

Your `formatting.lua` includes:
```lua
formatters_by_ft = {
    javascript = { "prettierd", "prettier" },
    typescript = { "prettierd", "prettier" },
    javascriptreact = { "prettierd", "prettier" },
    typescriptreact = { "prettierd", "prettier" },
}
```

### Install Prettier

```vim
:Mason
# Install: prettierd (faster) or prettier
```

Or globally:
```bash
npm install -g prettier
```

## Linter Configuration (Already Done!)

Your `linting.lua` includes:
```lua
linters_by_ft = {
    javascript = { "eslint_d" },
    typescript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescriptreact = { "eslint_d" },
}
```

### Install ESLint

```vim
:Mason
# Install: eslint_d (faster daemon)
```

Or in project:
```bash
npm install -D eslint
npx eslint --init
```

## Project Setup

### TypeScript Project

```bash
# Initialize
mkdir my-ts-project && cd my-ts-project
npm init -y

# Install TypeScript
npm install -D typescript @types/node

# Create tsconfig.json
npx tsc --init
```

#### Recommended tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022", "DOM"],
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "allowJs": true,
    "checkJs": false,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### JavaScript Project

```bash
# Initialize
mkdir my-js-project && cd my-js-project
npm init -y

# Add JSDoc type checking (optional)
npm install -D typescript
```

#### jsconfig.json (for IntelliSense)

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "checkJs": true,
    "lib": ["ES2022", "DOM"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

## ESLint Configuration

### Install & Initialize

```bash
npm install -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin

# Or use init
npx eslint --init
```

### .eslintrc.json

```json
{
  "root": true,
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended"
  ],
  "rules": {
    "no-console": "warn",
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": ["error", {
      "argsIgnorePattern": "^_"
    }],
    "@typescript-eslint/no-explicit-any": "warn"
  }
}
```

## Prettier Configuration

### .prettierrc

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "avoid",
  "bracketSpacing": true
}
```

### .prettierignore

```
node_modules
dist
build
coverage
.next
.nuxt
*.min.js
```

## Features Verification

### 1. Autocomplete

Create `test.ts`:
```typescript
interface User {
  name: string;
  age: number;
  email: string;
}

const user: User = {
  name: "John",
  age: 30,
  email: "john@example.com"
};

// Test autocomplete
user.  // Should show: name, age, email with types!

// Array methods
const numbers = [1, 2, 3, 4, 5];
numbers.  // Should show: map, filter, reduce, etc.
```

```vim
# Open file
nvim test.ts

# Type 'user.' and wait
# Should see completions!
```

### 2. Type Checking

```typescript
interface User {
  name: string;
  age: number;
}

const user: User = {
  name: "John",
  age: "30"  // ❌ Error: Type 'string' not assignable to 'number'
};
```

Error shows immediately with red underline!

### 3. Go to Definition

```typescript
function greet(name: string) {
  return `Hello, ${name}!`;
}

const message = greet("World");
```

```vim
# Cursor on 'greet' in line 5
gd
# Jumps to function definition!
```

### 4. Find References

```vim
# Cursor on 'greet'
gR
# Shows all usages in Telescope!
```

### 5. Rename Refactoring

```vim
# Cursor on 'greet'
<leader>rn
# Type: sayHello
# All references renamed!
```

### 6. Code Actions

```typescript
// Import missing
const express = require('express');  // ❌ Cannot find module
```

```vim
<leader>ca
# Shows: "Add missing imports"
# Adds: import express from 'express';
```

### 7. Formatting

```typescript
// Messy code
const user={name:"John",age:30,email:"john@example.com"};
```

```vim
<leader>f
```

Result:
```typescript
const user = {
  name: 'John',
  age: 30,
  email: 'john@example.com',
};
```

## Modern JavaScript Features

### ES Modules

```javascript
// math.js
export const add = (a, b) => a + b;
export const subtract = (a, b) => a - b;

// main.js
import { add, subtract } from './math.js';  // Autocomplete!
```

### Async/Await

```javascript
async function fetchUser(id) {
  const response = await fetch(`/api/users/${id}`);
  const user = await response.json();
  return user;
}

// Autocomplete on response methods!
```

### Destructuring

```javascript
const user = { name: "John", age: 30, city: "NYC" };

// Autocomplete in destructuring!
const { name, age } = user;
```

### Optional Chaining

```javascript
const user = {
  name: "John",
  address: {
    city: "NYC"
  }
};

const city = user?.address?.city;  // Autocomplete at each step!
```

## TypeScript-Specific Features

### Type Annotations

```typescript
// Function parameters
function greet(name: string, age: number): string {
  return `${name} is ${age} years old`;
}

// Variables
let count: number = 0;
let message: string = "Hello";
let isActive: boolean = true;

// Arrays
let numbers: number[] = [1, 2, 3];
let strings: Array<string> = ["a", "b", "c"];
```

### Interfaces & Types

```typescript
interface User {
  id: number;
  name: string;
  email: string;
  role: "admin" | "user";
}

type UserRole = "admin" | "user" | "guest";

// Autocomplete suggests interface properties!
const user: User = {
  id: 1,
  name: "John",
  email: "john@example.com",
  role: "admin"  // Autocomplete suggests: "admin" | "user"
};
```

### Generics

```typescript
function identity<T>(arg: T): T {
  return arg;
}

const num = identity<number>(42);  // num is number
const str = identity<string>("hello");  // str is string

// Autocomplete knows the types!
```

### Enums

```typescript
enum Direction {
  Up,
  Down,
  Left,
  Right
}

let dir: Direction = Direction.Up;  // Autocomplete!
```

## Node.js Development

### Setup

```bash
npm install -D @types/node tsx

# For running TS directly
npm install -g tsx
```

### Run TypeScript

```bash
# With tsx
tsx src/index.ts

# Compile then run
npx tsc
node dist/index.js
```

### From Neovim

```vim
# Run current TS file
:!tsx %

# Or in terminal split
<leader>v
:terminal
tsx src/index.ts
```

## Package Management

### Install Packages

```vim
# From Neovim terminal
:terminal
npm install express
npm install -D @types/express

# Or split terminal
<leader>v
:terminal
pnpm add express
```

### After Installing

Types are automatically picked up!

```typescript
import express from 'express';

const app = express();  // Autocomplete works!
```

## Debugging Setup (Optional)

### Install DAP

```lua
-- Add to plugins
{
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'mxsdev/nvim-dap-vscode-js',
  }
}
```

### Configure

```lua
require('dap-vscode-js').setup({
  debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
  adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
})

for _, language in ipairs({ "typescript", "javascript" }) do
  require('dap').configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
  }
end
```

## Common Tasks

### Create New File

```vim
<leader>e  " Open Neo-tree
# Navigate to folder
a  " Add file
utils.ts
```

### Import Module

```typescript
// Type the usage first
const result = lodash.sum([1, 2, 3]);
```

```vim
<leader>ca
# "Add import from 'lodash'"
```

Result:
```typescript
import lodash from 'lodash';

const result = lodash.sum([1, 2, 3]);
```

### Generate Code

```typescript
interface User {
  name: string;
  age: number;
}

// Type 'user.'
const user: User = {
  // Cursor here
};
```

```vim
<leader>ca
# "Fill all properties"
```

## Troubleshooting

### LSP Not Working

```vim
:LspInfo
:LspRestart
```

### Missing Types

```bash
npm install -D @types/node
npm install -D @types/react  # If using React
```

### Slow Performance

Create `.vimrc` or add to `init.lua`:
```lua
vim.g.node_host_prog = '/usr/bin/node'
```

## Next Steps

- [02-workflow.md](./02-workflow.md) - Daily JS/TS workflow
- [03-frameworks.md](./03-frameworks.md) - React, Vue, Solid.js
- [04-nodejs.md](./04-nodejs.md) - Backend development

---

**JavaScript/TypeScript development is ready! 🚀**
