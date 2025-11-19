# Solid.js Development Setup in Neovim

## Overview
Complete Solid.js development environment in Neovim with TypeScript support and fine-grained reactivity.

## What is Solid.js?
Solid.js is a declarative JavaScript framework for building user interfaces:
- **No Virtual DOM** - Compiles to real DOM operations
- **Fine-grained Reactivity** - Only updates what changes
- **JSX-based** - Familiar React-like syntax
- **Excellent Performance** - Faster than React/Vue
- **Small Bundle Size** - ~7KB minified + gzipped

## Project Setup

### Create New Solid.js Project
```bash
# TypeScript template (recommended)
npx degit solidjs/templates/ts my-app
cd my-app
npm install
nvim .

# Or with Vite
npm create vite@latest my-app -- --template solid-ts
cd my-app
npm install
nvim .
```

### Existing Project
```bash
cd existing-solid-project
npm install
nvim .
```

## LSP Configuration

### Automatic Setup (Already Configured!)
Your `mason.lua` already has everything:
```lua
ensure_installed = {
  "ts_ls",      -- TypeScript LSP ✅
  "eslint",     -- ESLint ✅
}
```

Solid.js uses JSX/TSX, so TypeScript LSP handles it perfectly!

### TypeScript Configuration
```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "jsx": "preserve",
    "jsxImportSource": "solid-js",
    "types": ["vite/client"],
    "noEmit": true,
    "isolatedModules": true,
    "paths": {
      "~/*": ["./src/*"]
    }
  }
}
```

Key difference from React: `"jsxImportSource": "solid-js"`

### Vite Configuration
```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import solid from 'vite-plugin-solid'

export default defineConfig({
  plugins: [solid()],
  resolve: {
    alias: {
      '~': '/src'
    }
  }
})
```

## Features Enabled

### ✅ Solid.js Primitives
Full IntelliSense for:
- `createSignal`
- `createEffect`
- `createMemo`
- `createResource`
- `createStore`
- `Show`, `For`, `Switch/Match`

**Example:**
```tsx
import { createSignal, createEffect } from 'solid-js'

function Counter() {
  const [count, setCount] = createSignal(0)
  //    ^number  ^(value: number) => void
  
  createEffect(() => {
    console.log('Count changed:', count())
  })
  
  return (
    <button onClick={() => setCount(count() + 1)}>
      Count: {count()}
    </button>
  )
}
```

### ✅ JSX with Solid Semantics
Unlike React, Solid JSX is:
- **Compiled to real DOM** - Not a virtual DOM
- **Reactive by default** - Use functions for reactive values
- **Control flow components** - `<Show>`, `<For>`, etc.

```tsx
<Show when={user()} fallback={<div>Loading...</div>}>
  {(u) => <div>Hello {u.name}</div>}
</Show>

<For each={items()}>
  {(item, index) => <li>{index()}: {item.name}</li>}
</For>

<Switch fallback={<div>Not Found</div>}>
  <Match when={state.page === 'home'}>
    <Home />
  </Match>
  <Match when={state.page === 'about'}>
    <About />
  </Match>
</Switch>
```

LSP provides completion for all control flow components!

### ✅ Props with TypeScript
```tsx
import { Component } from 'solid-js'

interface ButtonProps {
  variant?: 'primary' | 'secondary'
  onClick?: () => void
  children: JSX.Element
}

const Button: Component<ButtonProps> = (props) => {
  return (
    <button 
      class={`btn-${props.variant ?? 'primary'}`}
      onClick={props.onClick}
    >
      {props.children}
    </button>
  )
}

// Usage with full type checking!
<Button variant="primary" onClick={() => console.log('clicked')}>
  Click me
</Button>
```

**Note:** Use `class` instead of `className` in Solid!

## Key Differences from React

### 1. Signals vs State
```tsx
// React
const [count, setCount] = useState(0)
console.log(count)        // Direct value
setCount(5)

// Solid
const [count, setCount] = createSignal(0)
console.log(count())      // Call as function!
setCount(5)
```

### 2. No Re-renders
Solid components run ONCE. Only reactive expressions re-execute:

```tsx
function Counter() {
  console.log('Component runs once!')  // Logs only once
  
  const [count, setCount] = createSignal(0)
  
  createEffect(() => {
    console.log('Effect runs on count change:', count())  // Logs on every change
  })
  
  return <div>{count()}</div>  // Only this updates
}
```

### 3. No Hooks Rules
In Solid, you can use primitives anywhere:
```tsx
// ✅ Valid in Solid
if (condition) {
  const [signal, setSignal] = createSignal(0)
}

// ❌ Invalid in React (breaks hooks rules)
if (condition) {
  const [state, setState] = useState(0)  // Error!
}
```

### 4. Props are Getters
```tsx
// React - props is object
function Button(props) {
  console.log(props.count)  // Direct access
}

// Solid - props are getters (for reactivity)
function Button(props: { count: number }) {
  // Access props directly for reactive values
  return <div>{props.count}</div>
  
  // Or use splitProps/mergeProps
  const [local, others] = splitProps(props, ['count'])
  console.log(local.count)
}
```

### 5. Events
```tsx
// React
<button onClick={handleClick}>Click</button>

// Solid - same, but can also use on:click
<button onClick={handleClick}>Click</button>
<button on:click={handleClick}>Click</button>  // Alternative
```

## Project Structure

```
src/
├── index.tsx              # Entry point
├── App.tsx                # Root component
├── components/
│   ├── ui/                # Reusable UI components
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   └── Input.tsx
│   └── Counter.tsx
├── routes/                # If using Solid Router
│   ├── Home.tsx
│   ├── About.tsx
│   └── [...404].tsx
├── stores/                # Global stores
│   ├── user.ts
│   └── theme.ts
├── utils/                 # Utilities
│   └── api.ts
└── types/                 # TypeScript types
    └── index.ts
```

## Reactive Primitives

### createSignal - Simple State
```tsx
import { createSignal } from 'solid-js'

const [count, setCount] = createSignal(0)
console.log(count())     // Get value
setCount(10)             // Set value
setCount(c => c + 1)     // Update function
```

### createEffect - Side Effects
```tsx
import { createEffect, createSignal } from 'solid-js'

const [count, setCount] = createSignal(0)

createEffect(() => {
  console.log('Count is:', count())  // Automatically tracks count
})

// Effect runs when count changes!
setCount(5)  // Logs: "Count is: 5"
```

### createMemo - Derived State
```tsx
import { createMemo, createSignal } from 'solid-js'

const [count, setCount] = createSignal(0)

const doubled = createMemo(() => count() * 2)

console.log(doubled())  // 0
setCount(5)
console.log(doubled())  // 10
```

### createResource - Async Data
```tsx
import { createResource } from 'solid-js'

const [data] = createResource(fetchUsers)

return (
  <Show when={data()} fallback={<div>Loading...</div>}>
    {(users) => (
      <For each={users}>
        {(user) => <div>{user.name}</div>}
      </For>
    )}
  </Show>
)
```

### createStore - Complex State
```tsx
import { createStore } from 'solid-js/store'

const [state, setState] = createStore({
  user: { name: 'John', age: 30 },
  todos: []
})

// Immutable updates (like React)
setState('user', 'name', 'Jane')
setState('todos', (todos) => [...todos, newTodo])

// Access values directly (no function call!)
console.log(state.user.name)  // 'Jane'
```

## Component Patterns

### Basic Component
```tsx
import { Component } from 'solid-js'

const MyComponent: Component = () => {
  return <div>Hello World</div>
}

export default MyComponent
```

### Component with Props
```tsx
interface UserCardProps {
  name: string
  email: string
  onDelete?: () => void
}

const UserCard: Component<UserCardProps> = (props) => {
  return (
    <div class="card">
      <h3>{props.name}</h3>
      <p>{props.email}</p>
      <button onClick={props.onDelete}>Delete</button>
    </div>
  )
}
```

### Component with Children
```tsx
import { JSX, Component } from 'solid-js'

interface CardProps {
  title: string
  children: JSX.Element
}

const Card: Component<CardProps> = (props) => {
  return (
    <div class="card">
      <h2>{props.title}</h2>
      <div class="content">
        {props.children}
      </div>
    </div>
  )
}
```

## Routing with Solid Router

### Installation
```bash
npm install @solidjs/router
```

### Setup
```tsx
// App.tsx
import { Router, Route, Routes, A } from '@solidjs/router'
import Home from './routes/Home'
import About from './routes/About'
import User from './routes/User'

function App() {
  return (
    <Router>
      <nav>
        <A href="/">Home</A>
        <A href="/about">About</A>
        <A href="/users/123">User</A>
      </nav>
      
      <Routes>
        <Route path="/" component={Home} />
        <Route path="/about" component={About} />
        <Route path="/users/:id" component={User} />
      </Routes>
    </Router>
  )
}
```

### Route Params
```tsx
// routes/User.tsx
import { useParams } from '@solidjs/router'

export default function User() {
  const params = useParams()
  
  return <div>User ID: {params.id}</div>
}
```

### Programmatic Navigation
```tsx
import { useNavigate } from '@solidjs/router'

function MyComponent() {
  const navigate = useNavigate()
  
  const handleClick = () => {
    navigate('/about')
  }
  
  return <button onClick={handleClick}>Go to About</button>
}
```

## Context API

```tsx
import { createContext, useContext, Component, JSX } from 'solid-js'
import { createStore } from 'solid-js/store'

type User = { name: string; email: string }

interface AuthContextType {
  user: User | null
  login: (user: User) => void
  logout: () => void
}

const AuthContext = createContext<AuthContextType>()

export const AuthProvider: Component<{ children: JSX.Element }> = (props) => {
  const [state, setState] = createStore<{ user: User | null }>({
    user: null
  })
  
  const login = (user: User) => setState('user', user)
  const logout = () => setState('user', null)
  
  const value = {
    get user() { return state.user },
    login,
    logout
  }
  
  return (
    <AuthContext.Provider value={value}>
      {props.children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used within AuthProvider')
  return context
}
```

## Running Solid App

### Development
```bash
npm run dev
```

### From Neovim
```vim
<leader>v  " Split vertical
:terminal
npm run dev
```

Access at `http://localhost:3000`

### Hot Module Replacement
Vite provides instant HMR!

## Building

### Production Build
```bash
npm run build
```

### Preview
```bash
npm run preview
```

## Styling

### CSS Modules
```tsx
import styles from './Button.module.css'

const Button: Component = () => {
  return <button class={styles.button}>Click</button>
}
```

### Tailwind CSS
```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

Works perfectly with Solid! Your config already supports Tailwind.

### Inline Styles
```tsx
<div style={{ color: 'red', 'font-size': '20px' }}>
  Text
</div>
```

## Navigation in Neovim

### Find Components
```vim
<leader>sf  " Find files
<leader>sg  " Search content
```

### Jump to Definition
```vim
gd  " Go to definition
gr  " Find references
```

### LSP Features
All standard LSP features work:
- Auto-completion
- Hover documentation
- Rename refactoring
- Code actions
- Error checking

## Troubleshooting

### LSP Issues
```vim
:LspInfo
:LspRestart
```

### Build Errors
```bash
rm -rf node_modules dist
npm install
npm run build
```

### TypeScript Errors
Ensure `jsxImportSource` is set to `solid-js` in `tsconfig.json`.

## Solid vs React Cheat Sheet

| Feature | React | Solid |
|---------|-------|-------|
| State | `useState(0)` | `createSignal(0)` |
| Access state | `count` | `count()` |
| Effects | `useEffect` | `createEffect` |
| Memoization | `useMemo` | `createMemo` |
| Context | `useContext` | `useContext` |
| Refs | `useRef` | Direct variable |
| Attribute | `className` | `class` |
| Component runs | Every render | Once |

## Performance Benefits

Solid is ~3-4x faster than React because:
1. No Virtual DOM diffing
2. Fine-grained updates
3. Compile-time optimizations
4. Smaller bundle size

## Next Steps
- [02-workflow.md](./02-workflow.md) - Daily Solid.js workflow
- [03-advanced-patterns.md](./03-advanced-patterns.md) - Advanced patterns
- Official docs: https://www.solidjs.com/docs/latest
