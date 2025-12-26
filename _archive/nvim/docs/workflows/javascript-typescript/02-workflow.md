# JavaScript/TypeScript Daily Workflow

## Modern Development Workflow in Neovim

Complete guide for day-to-day JavaScript and TypeScript development.

## Project Initialization

### TypeScript Project from Scratch

```bash
# Create project
mkdir my-ts-app && cd my-ts-app
npm init -y

# Install TypeScript
npm install -D typescript @types/node tsx

# Initialize TypeScript config
npx tsc --init

# Create structure
mkdir -p src/{components,utils,types}
touch src/index.ts

# Open in Neovim
nvim .
```

### JavaScript with JSDoc

```bash
mkdir my-js-app && cd my-js-app
npm init -y

# Create jsconfig for IntelliSense
cat > jsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2022",
    "checkJs": true
  }
}
EOF

nvim .
```

## Daily Development Tasks

### 1. Creating New Modules

#### Utility Module

```vim
# Open file tree
<leader>e

# Navigate to src/utils
# Press 'a' for new file
math.ts
```

```typescript
// src/utils/math.ts

/**
 * Adds two numbers
 * @param a First number
 * @param b Second number
 * @returns Sum of a and b
 */
export function add(a: number, b: number): number {
  return a + b;
}

/**
 * Multiplies two numbers
 */
export function multiply(a: number, b: number): number {
  return a * b;
}

/**
 * Calculates average of array
 */
export function average(numbers: number[]): number {
  if (numbers.length === 0) return 0;
  const sum = numbers.reduce((acc, num) => acc + num, 0);
  return sum / numbers.length;
}
```

#### Using the Module

```vim
# Create main file
<leader>sf
index.ts
```

```typescript
// src/index.ts
import { add, multiply, average } from './utils/math';

// Autocomplete works on imported functions!
const sum = add(5, 3);
const product = multiply(4, 7);
const avg = average([1, 2, 3, 4, 5]);

console.log({ sum, product, avg });
```

### 2. Working with Types

#### Create Type Definitions

```vim
<leader>e
# Navigate to src/types/
# Press 'a'
user.ts
```

```typescript
// src/types/user.ts

export interface User {
  id: number;
  name: string;
  email: string;
  role: UserRole;
  createdAt: Date;
  updatedAt: Date;
}

export type UserRole = 'admin' | 'user' | 'guest';

export interface CreateUserDTO {
  name: string;
  email: string;
  role: UserRole;
}

export interface UpdateUserDTO extends Partial<CreateUserDTO> {
  id: number;
}
```

#### Using Types

```typescript
// src/services/user-service.ts
import type { User, CreateUserDTO, UpdateUserDTO } from '../types/user';

class UserService {
  private users: User[] = [];

  create(dto: CreateUserDTO): User {
    const user: User = {
      id: this.users.length + 1,
      ...dto,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    
    // Autocomplete works on 'user'!
    user.  // Shows: id, name, email, role, etc.
    
    this.users.push(user);
    return user;
  }

  update(dto: UpdateUserDTO): User | null {
    const index = this.users.findIndex(u => u.id === dto.id);
    if (index === -1) return null;
    
    this.users[index] = {
      ...this.users[index],
      ...dto,
      updatedAt: new Date(),
    };
    
    return this.users[index];
  }

  getAll(): User[] {
    return this.users;
  }
}

export const userService = new UserService();
```

### 3. Navigating Code

#### Quick Navigation

```vim
# Find any file
<leader>sf
user-service

# Search for text
<leader>sg
UserService

# Find symbol (functions, classes, types)
<leader>ss
# Select 'lsp_document_symbols'
```

#### LSP Navigation

```typescript
// In user-service.ts

// Jump to User type definition
// Cursor on 'User'
gd  # Jumps to types/user.ts!

// Find all usages of UserService
// Cursor on 'UserService'
gR  # Shows all files using it

// Go to implementation
gi

// Show hover documentation
K
```

#### Quick Buffer Switching

```vim
# Recent files
<leader>s.

# Switch between buffers
<Tab>  # Next buffer
<S-Tab>  # Previous buffer

# Jump list
<C-o>  # Jump back
<C-i>  # Jump forward
```

### 4. Code Editing & Refactoring

#### Auto Import

```typescript
// Type a function from lodash
const result = debounce(() => {
  console.log('Called!');
}, 1000);
```

```vim
# Red underline on 'debounce'
<leader>ca
# Select "Add import from 'lodash-es'"
```

Result:
```typescript
import { debounce } from 'lodash-es';

const result = debounce(() => {
  console.log('Called!');
}, 1000);
```

#### Extract Variable

```typescript
function calculate() {
  return (100 * 1.2 + 50) * 0.9;  // Complex expression
}
```

```vim
# Visual select the expression
V
# Select: (100 * 1.2 + 50)
<leader>ca
# "Extract to constant"
```

Result:
```typescript
function calculate() {
  const subtotal = 100 * 1.2 + 50;
  return subtotal * 0.9;
}
```

#### Rename Symbol

```typescript
class UserManger {  // Typo!
  //...
}
```

```vim
# Cursor on 'UserManger'
<leader>rn
# Type: UserManager
# All references updated!
```

#### Organize Imports

```typescript
import { z } from 'zod';
import { User } from './types/user';
import { debounce } from 'lodash-es';
import type { Config } from './config';
```

```vim
<leader>ca
# "Organize imports"
```

Result (sorted and grouped):
```typescript
import type { Config } from './config';
import type { User } from './types/user';

import { debounce } from 'lodash-es';
import { z } from 'zod';
```

### 5. Error Handling & Diagnostics

#### TypeScript Errors

```typescript
interface User {
  name: string;
  age: number;
}

const user: User = {
  name: "John",
  age: "30"  // ❌ Type 'string' not assignable to 'number'
};
```

```vim
# Navigate errors
]d  # Next diagnostic
[d  # Previous diagnostic

# Show error details
<leader>d  # Floating window

# List all errors
<leader>D  # Telescope diagnostics
```

#### Quick Fixes

```typescript
function greet(name) {  // ❌ Parameter 'name' implicitly has 'any' type
  return `Hello, ${name}`;
}
```

```vim
<leader>ca
# "Infer type from usage" or "Add type annotation"
```

Result:
```typescript
function greet(name: string): string {
  return `Hello, ${name}`;
}
```

#### ESLint Fixes

```typescript
const x = 10;  // ❌ 'x' is assigned but never used

if (true) {
    console.log('test')  // ❌ Missing semicolon
}
```

```vim
<leader>ca
# "Fix all auto-fixable problems"
```

### 6. Working with Async Code

#### Async Functions

```typescript
// Define async function
async function fetchUser(id: number): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  
  // Autocomplete on response!
  response.  // Shows: json(), text(), blob(), etc.
  
  if (!response.ok) {
    throw new Error('Failed to fetch user');
  }
  
  const data = await response.json();
  return data as User;
}

// Using it
async function main() {
  try {
    const user = await fetchUser(1);
    
    // Autocomplete knows 'user' is User type!
    user.  // Shows: id, name, email, etc.
    
    console.log(user.name);
  } catch (error) {
    console.error('Error:', error);
  }
}
```

#### Promise Chains

```typescript
fetchUser(1)
  .then(user => {
    // Autocomplete on 'user'
    console.log(user.name);
    return fetchUserPosts(user.id);
  })
  .then(posts => {
    // Autocomplete on 'posts'
    posts.forEach(post => console.log(post.title));
  })
  .catch(error => console.error(error));
```

### 7. Testing Workflow

#### Create Test File

```vim
<leader>e
# Navigate to src/__tests__/
# Or src/utils/
a
math.test.ts
```

```typescript
// src/utils/math.test.ts
import { describe, it, expect } from 'vitest';
import { add, multiply, average } from './math';

describe('Math utilities', () => {
  describe('add', () => {
    it('adds two positive numbers', () => {
      expect(add(2, 3)).toBe(5);
    });
    
    it('adds negative numbers', () => {
      expect(add(-1, -1)).toBe(-2);
    });
  });
  
  describe('multiply', () => {
    it('multiplies two numbers', () => {
      expect(multiply(4, 5)).toBe(20);
    });
  });
  
  describe('average', () => {
    it('calculates average of array', () => {
      expect(average([1, 2, 3, 4, 5])).toBe(3);
    });
    
    it('returns 0 for empty array', () => {
      expect(average([])).toBe(0);
    });
  });
});
```

#### Run Tests

```vim
# Run tests in terminal
<leader>v
:terminal
npm test

# Or directly
:!npm test

# Run specific file
:!npm test -- math.test.ts

# Watch mode
:!npm test -- --watch
```

### 8. Package Management

#### Install Dependencies

```vim
# Open terminal
:terminal

# Install package
npm install axios

# Install dev dependency
npm install -D @types/axios

# With pnpm
pnpm add axios
pnpm add -D @types/axios
```

#### After Installation

Types available immediately!

```typescript
import axios from 'axios';

// Autocomplete works!
axios.  // Shows: get, post, put, delete, etc.

async function fetchData() {
  const response = await axios.get('/api/data');
  
  // Autocomplete on response!
  response.  // Shows: data, status, headers, etc.
}
```

### 9. Building & Running

#### Development Mode

```vim
# In terminal split
<leader>v
:terminal

# Run dev server
npm run dev

# Or with tsx (TypeScript)
tsx watch src/index.ts
```

#### Build for Production

```vim
# Build
:!npm run build

# Check output
<leader>e
# Navigate to dist/

# Run built code
:!node dist/index.js
```

#### Create Run Keybindings

Add to `keymaps.lua`:

```lua
-- JavaScript/TypeScript run commands
vim.keymap.set('n', '<leader>jr', ':!tsx %<CR>', 
    { desc = '[J]S [R]un current file' })

vim.keymap.set('n', '<leader>jt', ':!npm test<CR>', 
    { desc = '[J]S [T]est' })

vim.keymap.set('n', '<leader>jb', ':!npm run build<CR>', 
    { desc = '[J]S [B]uild' })

vim.keymap.set('n', '<leader>jd', ':!npm run dev<CR>', 
    { desc = '[J]S [D]ev server' })
```

### 10. Formatting & Linting

#### Format Code

```typescript
// Messy code
const obj={a:1,b:2,c:3};const arr=[1,2,3,4,5];function test(){return "hello";}
```

```vim
<leader>f
```

Result:
```typescript
const obj = { a: 1, b: 2, c: 3 };
const arr = [1, 2, 3, 4, 5];
function test() {
  return 'hello';
}
```

#### Fix ESLint Issues

```vim
<leader>ca
# "Fix all auto-fixable problems"
```

#### Format on Save (Already Enabled!)

Just save:
```vim
:w
# or
<C-s>
```

## Real-World Scenarios

### Scenario 1: Adding New Feature

```vim
# 1. Create feature branch
<leader>lg
c  # Create branch
feature/user-authentication

# 2. Create feature file
<leader>sf
# New file
src/auth/authentication.ts

# 3. Implement feature
# (Use LSP autocomplete, type checking)

# 4. Create tests
src/auth/authentication.test.ts

# 5. Run tests
:!npm test

# 6. Format & lint
<leader>f

# 7. Commit
<leader>lg
s  # Stage
c  # Commit
```

### Scenario 2: Fixing Bug

```vim
# 1. Find where bug occurs
<leader>sg
# Search for error message or function

# 2. Jump to definition
gd

# 3. Find all usages
gR

# 4. Make fix with type safety
# LSP shows errors immediately

# 5. Run affected tests
:!npm test -- related-file.test.ts

# 6. Commit fix
<leader>lg
```

### Scenario 3: Refactoring

```vim
# 1. Find symbol to refactor
<leader>sf
old-service.ts

# 2. Rename class/function
# Cursor on symbol
<leader>rn
NewService

# 3. Extract logic to new file
# Visual select code
V
# Copy
y

# 4. Create new file
<leader>e
a
new-module.ts

# 5. Paste & adjust
p

# 6. Update imports (auto-suggest!)
# Type usage, LSP adds imports

# 7. Remove unused code
# ESLint shows warnings

# 8. Run tests
:!npm test
```

## Productivity Tips

### 1. Quick File Creation

```vim
# Same directory as current file
:e %:h/new-file.ts

# Relative to project root
:e src/utils/new-util.ts
```

### 2. Split Editing

```vim
# Open related file in split
<leader>v
<leader>sf
related-file.ts

# Now edit both side-by-side!
```

### 3. Terminal Workflow

```vim
# Vertical split with terminal
<leader>v
:terminal

# Keep dev server running
npm run dev

# Switch back to code
<C-h>

# Make changes, save
# Dev server auto-reloads!
```

### 4. Snippets Usage

```typescript
// Type abbreviation + Tab
log  # → console.log()
fn   # → function() {}
af   # → () => {}
try  # → try-catch block
```

## Keybindings Summary

| Task | Keybinding | Description |
|------|------------|-------------|
| Find file | `<leader>sf` | Fuzzy find |
| Search text | `<leader>sg` | Grep search |
| Goto definition | `gd` | Jump to def |
| Find references | `gR` | Show usages |
| Rename | `<leader>rn` | Refactor |
| Code action | `<leader>ca` | Quick fixes |
| Format | `<leader>f` | Prettier |
| Next error | `]d` | Jump to next |
| Prev error | `[d` | Jump to prev |
| Show error | `<leader>d` | Float window |
| Run file | `:!tsx %` | Execute TS |
| Run tests | `:!npm test` | Test suite |
| Terminal | `<leader>v` + `:term` | Split terminal |

---

**Master these workflows for blazing-fast JS/TS development! ⚡**
