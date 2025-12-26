# React Development Setup in Neovim

## Overview
Complete React development environment in Neovim with TypeScript, full IntelliSense, and modern tooling.

## Project Setup

### Create New React Project with Vite
```bash
# TypeScript + React (recommended)
npm create vite@latest my-app -- --template react-ts
cd my-app
npm install
nvim .
```

### Create with Create React App (Legacy)
```bash
npx create-react-app my-app --template typescript
cd my-app
nvim .
```

### Existing Project
```bash
cd existing-react-project
npm install
nvim .
```

## LSP Configuration

### Automatic Setup (Already Configured!)
Your `mason.lua` includes everything needed:
```lua
ensure_installed = {
  "ts_ls",       -- TypeScript/JavaScript LSP ✅
  "eslint",      -- ESLint LSP ✅
  "emmet_ls",    -- Emmet for JSX ✅
}
```

All features work out of the box! 🎉

### TypeScript Configuration
Verify/create `tsconfig.json`:
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    
    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    
    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    
    /* Path aliases */
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/hooks/*": ["./src/hooks/*"],
      "@/utils/*": ["./src/utils/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### Vite Configuration
```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
```

## Features Enabled

### ✅ React IntelliSense
- Component props completion
- Hook suggestions (`useState`, `useEffect`, etc.)
- JSX attribute completion
- Event handler types
- Children prop validation

**Example:**
```tsx
interface ButtonProps {
  variant: 'primary' | 'secondary'
  onClick: () => void
  children: React.ReactNode
}

function Button({ variant, onClick, children }: ButtonProps) {
  return (
    <button onClick={onClick} className={`btn-${variant}`}>
      {children}
    </button>
  )
}

// Usage - get prop completion!
<Button 
  variant="|"  // Completion shows: 'primary' | 'secondary'
  onClick={() => console.log('clicked')}
>
  Click me
</Button>
```

### ✅ Auto-Imports
Type component name → auto-import suggestion:
```tsx
<TodoList />  // Unresolved
```
```vim
<leader>ca  " Code action → "Add import from './components/TodoList'"
```

### ✅ JSX/TSX Support
- Tag auto-closing
- Attribute completion
- Emmet abbreviations
- Fragment support

**Emmet example:**
```
div.container>ul>li*3>{Item $}
```
Press `<C-y>,` → expands to:
```tsx
<div className="container">
  <ul>
    <li>Item 1</li>
    <li>Item 2</li>
    <li>Item 3</li>
  </ul>
</div>
```

### ✅ Hook Support
All React hooks with TypeScript types:

```tsx
// useState with type inference
const [count, setCount] = useState(0)
//    ^number              ^(value: number) => void

// useState with explicit type
const [user, setUser] = useState<User | null>(null)

// useEffect - completion for dependencies
useEffect(() => {
  // Effect
}, [|])  // Completion suggests dependencies

// Custom hooks
function useCounter(initialValue = 0) {
  const [count, setCount] = useState(initialValue)
  const increment = () => setCount(c => c + 1)
  return { count, increment }
}
```

### ✅ Component Refactoring
- Extract JSX to component
- Rename component (updates all usages)
- Move component to file
- Convert function ↔ arrow function

### ✅ Props Validation
Real-time checking:
```tsx
<Button 
  variant="invalid"  // ❌ Error: Type '"invalid"' is not assignable
  onClick="string"   // ❌ Error: Type 'string' is not assignable
  // Missing required prop 'children' ❌
/>
```

## Project Structure

### Recommended Structure
```
src/
├── main.tsx              # Entry point
├── App.tsx               # Root component
├── components/
│   ├── ui/               # Reusable UI components
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   └── Input.tsx
│   ├── layout/           # Layout components
│   │   ├── Header.tsx
│   │   ├── Footer.tsx
│   │   └── Sidebar.tsx
│   └── features/         # Feature-specific components
│       ├── TodoList.tsx
│       └── TodoItem.tsx
├── hooks/                # Custom hooks
│   ├── useAuth.ts
│   ├── useFetch.ts
│   └── useLocalStorage.ts
├── contexts/             # React contexts
│   ├── AuthContext.tsx
│   └── ThemeContext.tsx
├── utils/                # Utility functions
│   ├── api.ts
│   └── helpers.ts
├── types/                # TypeScript types
│   └── index.ts
└── styles/               # Global styles
    └── index.css
```

## Component Development

### Create Functional Component
```vim
:e src/components/TodoList.tsx
```

Type `rfc` + `<Tab>` (snippet):
```tsx
export default function TodoList() {
  return (
    <div>TodoList</div>
  )
}
```

### Component with Props
```tsx
interface TodoListProps {
  todos: Todo[]
  onToggle: (id: string) => void
  onDelete: (id: string) => void
}

export function TodoList({ todos, onToggle, onDelete }: TodoListProps) {
  return (
    <ul>
      {todos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggle={onToggle}
          onDelete={onDelete}
        />
      ))}
    </ul>
  )
}
```

LSP features:
- Prop completion when destructuring
- Type checking for prop values
- Missing required prop warnings
- Hover to see prop types

### Extract Component
1. Select JSX: `vit` (visual inside tag)
2. Cut: `d`
3. Create new file: `:e src/components/NewComponent.tsx`
4. Paste: `p`
5. Wrap in function
6. Go back and import: `<leader>ca`

## Navigation

### Find Components
```vim
<leader>sf  " Search files → type component name
<leader>sg  " Search content → find usage
<leader>sw  " Search word under cursor
```

### Jump to Definition
```tsx
import { Button } from './components/Button'
//       ^^^^^^ cursor here
```
```vim
gd  " Jump to Button definition
gf  " Go to file (works on imports!)
```

### Find Component Usages
```vim
gr  " Show all references
```

### Navigate Component Structure
```vim
:Telescope lsp_document_symbols
# Shows: components, functions, hooks, types
```

## State Management

### useState
```tsx
const [state, setState] = useState<StateType>(initialValue)

// Update
setState(newValue)
setState(prev => ({ ...prev, field: value }))
```

### useReducer
```tsx
type Action =
  | { type: 'INCREMENT' }
  | { type: 'DECREMENT' }
  | { type: 'SET', payload: number }

function reducer(state: number, action: Action): number {
  switch (action.type) {
    case 'INCREMENT': return state + 1
    case 'DECREMENT': return state - 1
    case 'SET': return action.payload
  }
}

const [count, dispatch] = useReducer(reducer, 0)
dispatch({ type: 'INCREMENT' })
```

### Context API
```tsx
// contexts/AuthContext.tsx
interface AuthContextType {
  user: User | null
  login: (email: string, password: string) => Promise<void>
  logout: () => void
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  
  const login = async (email: string, password: string) => {
    const user = await api.login(email, password)
    setUser(user)
  }
  
  const logout = () => setUser(null)
  
  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) throw new Error('useAuth must be used within AuthProvider')
  return context
}
```

LSP provides completion for context values!

## Custom Hooks

### Create Custom Hook
```tsx
// hooks/useFetch.ts
export function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)
  
  useEffect(() => {
    fetch(url)
      .then(res => res.json())
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [url])
  
  return { data, loading, error }
}

// Usage with full type safety!
const { data, loading, error } = useFetch<User[]>('/api/users')
```

### Common Custom Hooks
- `useLocalStorage` - Persist state
- `useDebounce` - Debounce value
- `useMediaQuery` - Responsive design
- `useClickOutside` - Detect outside clicks
- `useAsync` - Async operation state

## Styling

### CSS Modules
```tsx
// Button.module.css
.button {
  padding: 0.5rem 1rem;
  background: var(--primary);
}

.primary {
  background: blue;
}

// Button.tsx
import styles from './Button.module.css'

export function Button({ variant }: { variant: 'primary' | 'secondary' }) {
  return (
    <button className={`${styles.button} ${styles[variant]}`}>
      Click me
    </button>
  )
}
```

LSP provides completion for `styles.|`!

### Styled Components
```bash
npm install styled-components
npm install -D @types/styled-components
```

```tsx
import styled from 'styled-components'

const Button = styled.button<{ $primary?: boolean }>`
  background: ${props => props.$primary ? 'blue' : 'gray'};
  padding: 0.5rem 1rem;
  border-radius: 4px;
`

<Button $primary onClick={handleClick}>Click</Button>
```

### Tailwind CSS
```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

Already fully supported in your config! See Next.js workflow for details.

## Running React App

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

Access at `http://localhost:5173` (Vite) or `http://localhost:3000` (CRA)

### Hot Module Replacement
Vite/CRA automatically reload on file save!

## Building

### Production Build
```bash
npm run build
```

### Preview Production
```bash
npm run preview  # Vite
# or
serve -s build   # CRA
```

## Testing

### Install Vitest + Testing Library
```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event
```

### Test Example
```tsx
// __tests__/Button.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Button } from '../components/Button'

describe('Button', () => {
  it('calls onClick when clicked', async () => {
    const handleClick = vi.fn()
    render(<Button onClick={handleClick}>Click me</Button>)
    
    await userEvent.click(screen.getByText('Click me'))
    
    expect(handleClick).toHaveBeenCalledTimes(1)
  })
})
```

### Run Tests
```vim
:!npm test
" Or watch mode
:terminal
npm test -- --watch
```

## Popular Libraries Integration

### React Router
```bash
npm install react-router-dom
```

```tsx
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom'

function App() {
  return (
    <BrowserRouter>
      <nav>
        <Link to="/">Home</Link>
        <Link to="/about">About</Link>
      </nav>
      
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/about" element={<About />} />
        <Route path="/users/:id" element={<UserDetail />} />
      </Routes>
    </BrowserRouter>
  )
}
```

### React Query
```bash
npm install @tanstack/react-query
```

```tsx
import { useQuery, QueryClient, QueryClientProvider } from '@tanstack/react-query'

const queryClient = new QueryClient()

function Users() {
  const { data, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: () => fetch('/api/users').then(r => r.json())
  })
  
  if (isLoading) return <div>Loading...</div>
  
  return (
    <ul>
      {data.map(user => <li key={user.id}>{user.name}</li>)}
    </ul>
  )
}
```

Full TypeScript support with LSP!

### Zustand (State Management)
```bash
npm install zustand
```

```tsx
import { create } from 'zustand'

interface BearStore {
  bears: number
  increase: () => void
}

const useBearStore = create<BearStore>((set) => ({
  bears: 0,
  increase: () => set((state) => ({ bears: state.bears + 1 })),
}))

function BearCounter() {
  const bears = useBearStore((state) => state.bears)
  return <div>{bears} bears</div>
}
```

## Debugging

### React DevTools
Install browser extension, works with any React app!

### Console Logging
```tsx
useEffect(() => {
  console.log('Component mounted', { props, state })
}, [])
```

### VS Code-style Debugging (nvim-dap)
See [03-debugging.md](./03-debugging.md) for full setup.

## Linting & Formatting

### Already Configured! ✅
Your config handles:
- ESLint on save
- Prettier/Biome formatting on save
- Import organization on save

### Manual Commands
```vim
<leader>f   " Format file
<leader>l   " Run linter
[d          " Previous diagnostic
]d          " Next diagnostic
<leader>d   " Show diagnostic
```

## Performance Tips

### 1. Code Splitting
```tsx
import { lazy, Suspense } from 'react'

const HeavyComponent = lazy(() => import('./HeavyComponent'))

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyComponent />
    </Suspense>
  )
}
```

### 2. Memoization
```tsx
import { memo, useMemo, useCallback } from 'react'

const ExpensiveComponent = memo(({ data }: { data: Data[] }) => {
  const processed = useMemo(
    () => data.filter(d => d.active).sort(),
    [data]
  )
  
  const handleClick = useCallback(() => {
    console.log('clicked')
  }, [])
  
  return <div>...</div>
})
```

### 3. Virtual Lists
```bash
npm install @tanstack/react-virtual
```

For rendering large lists efficiently.

## Troubleshooting

### LSP Not Working
```vim
:LspInfo
:LspRestart
```

### Import Errors
```bash
# Clear cache
rm -rf node_modules .vite
npm install
```

### TypeScript Errors
```vim
:! npm run type-check
```

## Next Steps
- [02-workflow.md](./02-workflow.md) - Daily React workflow
- [03-debugging.md](./03-debugging.md) - Debugging guide
- [04-advanced-patterns.md](./04-advanced-patterns.md) - Advanced patterns
