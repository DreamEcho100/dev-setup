# Language-Specific Development Workflows

Complete guides for professional development in multiple languages and frameworks using your Neovim configuration.

## 📁 Directory Structure

```
workflows/
├── README.md (this file)
├── 01-COMPLETE-WORKFLOWS-GUIDE.md    # General workflows
├── c-cpp/                             # C/C++ workflows
├── javascript-typescript/             # JS/TS workflows
├── nodejs/                            # Node.js specific
├── react/                             # React development
├── nextjs/                            # Next.js workflows
├── solidjs/                           # Solid.js workflows
├── golang/                            # Go development
├── python/                            # Python workflows
├── csharp/                            # C# .NET workflows
└── java/                              # Java workflows
```

## 🚀 Available Guides

### ✅ Comprehensive Guides (Complete)

| Language/Framework | Status | Quick Start | Key Features |
|-------------------|--------|-------------|--------------|
| **C/C++** | ✅ Complete | `cd c-cpp/` | CMake, clangd, debugging |
| **JavaScript/TypeScript** | ✅ Complete | `cd javascript-typescript/` | tsserver, testing, frameworks |
| **Go** | ✅ Complete | `cd golang/` | gopls, delve, modules |
| **Python** | ✅ Complete | `cd python/` | pyright, pytest, data science |
| **Java** | ✅ Complete | `cd java/` | JDTLS, Maven/Gradle, Spring Boot, debugging |
| **C# (.NET)** | ✅ Complete | `cd csharp/` | OmniSharp, ASP.NET, Entity Framework |

### 🔨 Framework-Specific Guides

| Framework | Base Language | Status | Focus Areas |
|-----------|--------------|--------|-------------|
| **Node.js** | JavaScript/TypeScript | ✅ Complete | Backend, APIs, CLI tools |
| **React.js** | JavaScript/TypeScript | ✅ Complete | Components, hooks, testing, state management |
| **Next.js** | React/TypeScript | ✅ Complete | App Router, SSR/SSG, API routes, Server Components |
| **Solid.js** | JavaScript/TypeScript | ✅ Complete | Fine-grained reactivity, performance, signals |

---

## Node.js Development

### Quick Setup

```bash
# LSP (same as TypeScript)
:Mason → tsserver

# Formatters
npm install -g prettier

# Linters
npm install -g eslint

# Testing
npm install -D jest
```

### Key Workflows

**1. Express API Development**

```javascript
// server.js
const express = require('express');
const app = express();

app.get('/api/users', (req, res) => {
  // LSP autocomplete works!
  res.json({ users: [] });
});

app.listen(3000);
```

```vim
# Run with hot reload
:!npx nodemon server.js

# Or in terminal
<leader>th
npx nodemon server.js
```

**2. Debugging Node.js**

```vim
# Set breakpoint
<leader>db

# Debug configuration (DAP)
{
  type = "pwa-node",
  request = "launch",
  name = "Debug Node.js",
  program = "${file}",
  cwd = "${workspaceFolder}",
}

# Start debugging
<F5>
```

**3. Package Development**

```json
// package.json
{
  "name": "my-package",
  "main": "index.js",
  "scripts": {
    "test": "jest",
    "build": "tsc"
  }
}
```

```vim
# Run scripts
:!npm test
:!npm run build

# Or with shortcuts
<leader>rt       " npm test
<leader>rb       " npm run build
```

### Common Patterns

- **REST APIs**: Express, Fastify, Koa
- **GraphQL**: Apollo Server
- **CLI Tools**: Commander, yargs
- **Testing**: Jest, Mocha, AVA
- **Build Tools**: Webpack, Rollup, esbuild

---

## React.js Development

### Quick Setup

```bash
# Create React app
npx create-react-app my-app --template typescript
cd my-app

# Open in Neovim
nvim .
```

### LSP Features

```typescript
// Component.tsx
import React, { useState } from 'react';

interface Props {
  title: string;
}

export const MyComponent: React.FC<Props> = ({ title }) => {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      {/* JSX autocomplete works! */}
      <h1>{title}</h1>
      <button onClick={() => setCount(count + 1)}>
        Count: {count}
      </button>
    </div>
  );
};
```

**LSP shows**:
- ✅ Component prop types
- ✅ Hook signatures
- ✅ JSX element completions
- ✅ Import suggestions

### Testing with React Testing Library

```typescript
// Component.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { MyComponent } from './Component';

test('increments counter', () => {
  render(<MyComponent title="Test" />);
  
  const button = screen.getByText(/Count:/);
  fireEvent.click(button);
  
  expect(button).toHaveTextContent('Count: 1');
});
```

```vim
# Run test
<leader>tt       " With neotest-jest
```

### Common Workflows

**Component Creation**

```vim
# Create component file
<leader>e
a
Button.tsx

# Type component
<type 'rfc' then Tab>  # If snippets configured
# Expands to React Functional Component template
```

**Refactoring**

```vim
# Extract component
# Visual select JSX
V10j
y

# Create new file
<leader>sf
NewComponent.tsx

# Paste and wrap in component
```

**State Management**

- **useState**: For local state
- **useContext**: For shared state
- **useReducer**: For complex state
- **Zustand/Jotai**: External state (LSP support)

---

## Next.js Development

### Quick Setup

```bash
npx create-next-app@latest my-app --typescript
cd my-app
nvim .
```

### App Router (Next.js 13+)

```typescript
// app/page.tsx
export default function Home() {
  return <h1>Home Page</h1>
}

// app/about/page.tsx
export default function About() {
  return <h1>About</h1>
}
```

### API Routes

```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  const users = await fetchUsers();
  return NextResponse.json(users);
}

export async function POST(request: Request) {
  const data = await request.json();
  // LSP knows Request types!
  return NextResponse.json({ success: true });
}
```

### Server Components vs Client Components

```typescript
// Server Component (default)
async function ServerComponent() {
  const data = await fetchData();
  return <div>{data}</div>
}

// Client Component
'use client';
import { useState } from 'react';

function ClientComponent() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>
}
```

### Development Workflow

```vim
# Start dev server
<leader>th
npm run dev

# Opens on localhost:3000
# Hot reload works automatically

# Edit any file
<leader>sf
app/page.tsx
# Make changes
# Browser auto-refreshes!

# Build for production
:!npm run build

# Preview production build
:!npm start
```

### LSP Features for Next.js

- ✅ API route types
- ✅ Server component async support
- ✅ Metadata API autocomplete
- ✅ Image component optimization hints
- ✅ Link component type checking

---

## Solid.js Development

### Quick Setup

```bash
npx degit solidjs/templates/ts my-app
cd my-app
npm install
nvim .
```

### Reactive Components

```typescript
import { createSignal, createEffect } from 'solid-js';

function Counter() {
  const [count, setCount] = createSignal(0);
  
  createEffect(() => {
    console.log('Count:', count());
  });
  
  return (
    <button onClick={() => setCount(c => c + 1)}>
      Count: {count()}
    </button>
  );
}
```

### Key Differences from React

| Feature | React | Solid.js |
|---------|-------|----------|
| **Reactivity** | Virtual DOM | Fine-grained |
| **Re-renders** | Component | Only changed values |
| **Hooks** | useEffect | createEffect |
| **State** | useState | createSignal |
| **Memos** | useMemo | createMemo |

### LSP Support

```typescript
// LSP understands Solid's reactivity
const [data, setData] = createSignal<User[]>([]);
//                       ↑ Type inference works!

data().  // Shows array methods
```

### Development

```vim
# Start dev server
<leader>th
npm run dev

# Build
:!npm run build
```

---

## C# (.NET) Development

### Quick Setup

```bash
# Install .NET SDK
wget https://dot.net/v1/dotnet-install.sh
bash dotnet-install.sh

# Install LSP
:Mason
# Find: omnisharp, csharp-language-server
```

### Create Project

```bash
dotnet new console -o MyApp
cd MyApp
nvim .
```

### LSP Features

```csharp
// Program.cs
using System;

namespace MyApp
{
    class Program
    {
        static void Main(string[] args)
        {
            var user = new User {
                Name = "John",
                Age = 30
            };
            
            // LSP autocomplete
            Console.  // Shows all Console methods!
            user.     // Shows Name, Age properties
        }
    }
    
    record User(string Name, int Age);
}
```

### Common Workflows

**ASP.NET Web API**

```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    [HttpGet]
    public ActionResult<IEnumerable<User>> GetUsers()
    {
        return Ok(users);
    }
}
```

**Entity Framework**

```csharp
public class ApplicationDbContext : DbContext
{
    public DbSet<User> Users { get; set; }
}
```

### Running & Testing

```vim
# Run project
:!dotnet run

# Run tests
:!dotnet test

# Build
:!dotnet build
```

---

## Java Development

### Quick Setup

```bash
# Install Java
sudo apt install default-jdk

# Install LSP
:Mason
# Find: jdtls (Eclipse JDT Language Server)
```

### Maven Project

```bash
mvn archetype:generate -DgroupId=com.example -DartifactId=my-app
cd my-app
nvim .
```

### LSP Features

```java
// Main.java
package com.example;

import java.util.List;
import java.util.ArrayList;

public class Main {
    public static void main(String[] args) {
        List<String> names = new ArrayList<>();
        
        // LSP autocomplete
        names.  // Shows all List methods!
        
        // Go to definition
        // gd on ArrayList → jumps to source
    }
}
```

### Spring Boot

```java
@RestController
@RequestMapping("/api")
public class UserController {
    
    @GetMapping("/users")
    public List<User> getUsers() {
        // LSP understands Spring annotations!
        return userService.findAll();
    }
    
    @PostMapping("/users")
    public User createUser(@RequestBody User user) {
        return userService.save(user);
    }
}
```

### Build & Run

```vim
# Maven
:!mvn clean install
:!mvn spring-boot:run

# Gradle
:!./gradlew build
:!./gradlew bootRun

# Run tests
:!mvn test
:!./gradlew test
```

---

## Common Patterns Across Languages

### 1. LSP Workflow (Universal)

```vim
gd               " Go to definition
gR               " Find references
K                " Documentation
<leader>ca       " Code actions
<leader>rn       " Rename
]d / [d          " Next/prev diagnostic
```

### 2. Testing Workflow (Universal)

```vim
<leader>tt       " Run nearest test
<leader>tf       " Run file tests
<leader>ta       " Run all tests
<leader>td       " Debug test
```

### 3. Debugging Workflow (Universal)

```vim
<leader>db       " Toggle breakpoint
<F5>             " Start/continue
<F10>            " Step over
<F11>            " Step into
<F12>            " Step out
```

### 4. Git Workflow (Universal)

```vim
<leader>lg       " LazyGit
<leader>hs       " Stage hunk
<leader>hu       " Undo hunk
<leader>hp       " Preview hunk
]h / [h          " Next/prev hunk
```

---

## Quick Reference Matrix

| Feature | C/C++ | JS/TS | Go | Python | C# | Java |
|---------|-------|-------|----|---------|----|------|
| **LSP** | clangd | tsserver | gopls | pyright | omnisharp | jdtls |
| **Debugger** | gdb/lldb | node-debug | delve | debugpy | netcoredbg | jdwp |
| **Formatter** | clang-format | prettier | gofmt | black | csharpier | google-java-format |
| **Linter** | clang-tidy | eslint | golangci-lint | pylint | - | checkstyle |
| **Build Tool** | cmake/make | npm/yarn | go build | pip/poetry | dotnet | maven/gradle |
| **Test Framework** | gtest/catch2 | jest/vitest | go test | pytest | xunit/nunit | junit |

---

## Next Steps

1. **Choose your language** from the list above
2. **Follow Quick Setup** for that language
3. **Try the example workflows**
4. **Configure tools** as needed
5. **Practice with real projects**

## Additional Resources

- **General Workflows**: See `01-COMPLETE-WORKFLOWS-GUIDE.md`
- **LSP Guide**: See `../lsp-intellisense/`
- **Debugging Guide**: See `../debugging/`
- **Testing Guide**: See `../testing/`

---

**Every language has first-class support in Neovim! 🚀**
