# React Development Workflow in Neovim

## Complete React Development Guide

Daily workflow for building React applications with full TypeScript support.

## Project Setup

### Create React + TypeScript Project

```bash
# Using Vite (Recommended)
npm create vite@latest my-react-app -- --template react-ts
cd my-react-app
npm install

# Using Create React App
npx create-react-app my-react-app --template typescript
cd my-react-app

# Open in Neovim
nvim .
```

### Your Config Already Supports

✅ TypeScript/JavaScript LSP (ts_ls)
✅ ESLint integration
✅ Prettier formatting
✅ Emmet for JSX
✅ Tailwind CSS (if using)
✅ Auto-imports

## Component Development

### 1. Creating Components

#### Functional Component

```vim
# Create component file
<leader>e
# Navigate to src/components
a
Button.tsx
```

```typescript
// src/components/Button.tsx
import { ButtonHTMLAttributes, FC, ReactNode } from 'react';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  children: ReactNode;
  isLoading?: boolean;
}

export const Button: FC<ButtonProps> = ({
  variant = 'primary',
  size = 'md',
  children,
  isLoading = false,
  className = '',
  disabled,
  ...props
}) => {
  const baseStyles = 'rounded font-semibold transition-colors';
  
  const variantStyles = {
    primary: 'bg-blue-600 hover:bg-blue-700 text-white',
    secondary: 'bg-gray-600 hover:bg-gray-700 text-white',
    danger: 'bg-red-600 hover:bg-red-700 text-white',
  };
  
  const sizeStyles = {
    sm: 'px-3 py-1 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg',
  };
  
  return (
    <button
      className={`${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]} ${className}`}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? 'Loading...' : children}
    </button>
  );
};
```

#### Using the Component

```typescript
// src/App.tsx
import { Button } from './components/Button';

function App() {
  const handleClick = () => {
    console.log('Button clicked!');
  };
  
  return (
    <div className="p-8">
      {/* Autocomplete on Button props! */}
      <Button
        variant="primary"  // ✅ Suggests: primary | secondary | danger
        size="md"          // ✅ Suggests: sm | md | lg
        onClick={handleClick}
      >
        Click me
      </Button>
    </div>
  );
}
```

### 2. Hooks Usage

#### useState

```typescript
import { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);
  
  // Autocomplete knows 'count' is number!
  count.  // Shows number methods
  
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>
        Increment
      </button>
    </div>
  );
}
```

#### useEffect

```typescript
import { useEffect, useState } from 'react';

function UserProfile({ userId }: { userId: number }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    async function fetchUser() {
      setLoading(true);
      try {
        const response = await fetch(`/api/users/${userId}`);
        const data = await response.json();
        setUser(data);
      } catch (error) {
        console.error('Failed to fetch user:', error);
      } finally {
        setLoading(false);
      }
    }
    
    fetchUser();
  }, [userId]);  // Dependency array - LSP warns if missing!
  
  if (loading) return <div>Loading...</div>;
  if (!user) return <div>User not found</div>;
  
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

#### Custom Hooks

```vim
# Create hooks file
<leader>e
src/hooks
a
useDebounce.ts
```

```typescript
// src/hooks/useDebounce.ts
import { useEffect, useState } from 'react';

export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);
  
  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);
    
    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);
  
  return debouncedValue;
}
```

Using it:

```typescript
import { useDebounce } from './hooks/useDebounce';

function SearchInput() {
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  
  // Autocomplete on useDebounce!
  useDebounce(  // Shows signature!
  
  useEffect(() => {
    if (debouncedSearch) {
      // Perform search
      console.log('Searching for:', debouncedSearch);
    }
  }, [debouncedSearch]);
  
  return (
    <input
      type="text"
      value={search}
      onChange={(e) => setSearch(e.target.value)}
      placeholder="Search..."
    />
  );
}
```

### 3. Context & State Management

#### Create Context

```typescript
// src/contexts/AuthContext.tsx
import { createContext, ReactNode, useContext, useState } from 'react';

interface User {
  id: number;
  name: string;
  email: string;
}

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  
  const login = async (email: string, password: string) => {
    // API call
    const response = await fetch('/api/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
    const userData = await response.json();
    setUser(userData);
  };
  
  const logout = () => {
    setUser(null);
  };
  
  const value = {
    user,
    login,
    logout,
    isAuthenticated: !!user,
  };
  
  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
```

#### Using Context

```typescript
// src/App.tsx
import { AuthProvider } from './contexts/AuthContext';

function App() {
  return (
    <AuthProvider>
      <Dashboard />
    </AuthProvider>
  );
}

// src/components/Dashboard.tsx
import { useAuth } from '../contexts/AuthContext';

function Dashboard() {
  const { user, logout, isAuthenticated } = useAuth();
  
  // Autocomplete on useAuth return!
  useAuth().  // Shows: user, login, logout, isAuthenticated
  
  if (!isAuthenticated) {
    return <Login />;
  }
  
  return (
    <div>
      <h1>Welcome, {user?.name}</h1>
      <button onClick={logout}>Logout</button>
    </div>
  );
}
```

### 4. Working with Forms

#### Controlled Components

```typescript
import { FormEvent, useState } from 'react';

interface FormData {
  name: string;
  email: string;
  message: string;
}

function ContactForm() {
  const [formData, setFormData] = useState<FormData>({
    name: '',
    email: '',
    message: '',
  });
  
  const [errors, setErrors] = useState<Partial<FormData>>({});
  
  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value,
    }));
  };
  
  const validate = (): boolean => {
    const newErrors: Partial<FormData> = {};
    
    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    }
    
    if (!formData.email.includes('@')) {
      newErrors.email = 'Invalid email';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };
  
  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    
    if (validate()) {
      console.log('Form submitted:', formData);
    }
  };
  
  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <input
          type="text"
          name="name"
          value={formData.name}
          onChange={handleChange}
          placeholder="Name"
        />
        {errors.name && <span className="text-red-500">{errors.name}</span>}
      </div>
      
      <div>
        <input
          type="email"
          name="email"
          value={formData.email}
          onChange={handleChange}
          placeholder="Email"
        />
        {errors.email && <span className="text-red-500">{errors.email}</span>}
      </div>
      
      <div>
        <textarea
          name="message"
          value={formData.message}
          onChange={handleChange}
          placeholder="Message"
        />
      </div>
      
      <button type="submit">Submit</button>
    </form>
  );
}
```

### 5. API Integration

#### Create API Service

```vim
<leader>e
src/services
a
api.ts
```

```typescript
// src/services/api.ts
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:3000',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
```

#### API Hooks

```typescript
// src/hooks/useApi.ts
import { useEffect, useState } from 'react';
import api from '../services/api';

export function useApi<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  
  useEffect(() => {
    async function fetchData() {
      try {
        setLoading(true);
        const response = await api.get<T>(url);
        setData(response.data);
      } catch (err) {
        setError(err as Error);
      } finally {
        setLoading(false);
      }
    }
    
    fetchData();
  }, [url]);
  
  return { data, loading, error };
}
```

Using it:

```typescript
function UsersList() {
  const { data: users, loading, error } = useApi<User[]>('/api/users');
  
  // Autocomplete knows 'users' is User[]!
  
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  
  return (
    <ul>
      {users?.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

### 6. Routing (React Router)

```bash
npm install react-router-dom
```

```typescript
// src/App.tsx
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom';
import Home from './pages/Home';
import About from './pages/About';
import UserProfile from './pages/UserProfile';

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
        <Route path="/user/:id" element={<UserProfile />} />
      </Routes>
    </BrowserRouter>
  );
}
```

## Development Workflow

### 1. Start Dev Server

```vim
# Open terminal
<leader>v
:terminal

# Start dev server
npm run dev

# Server runs on http://localhost:5173
```

### 2. Edit Components

```vim
# Switch back to code
<C-h>

# Make changes
# Save - auto formats!
<C-s>

# Hot reload happens automatically!
```

### 3. Component Navigation

```vim
# Find component
<leader>sf
Button

# Jump to import
gd

# Find all usages
gR

# Back to file
<C-o>
```

### 4. Debugging

#### Console Logs

```typescript
function handleClick() {
  console.log('Clicked!');
  debugger;  // Browser will pause here
}
```

#### React DevTools

Install browser extension, use alongside Neovim!

### 5. Testing

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom
```

```typescript
// src/components/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './Button';

describe('Button', () => {
  it('renders children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });
  
  it('calls onClick when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click</Button>);
    
    fireEvent.click(screen.getByText('Click'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
  
  it('shows loading state', () => {
    render(<Button isLoading>Click</Button>);
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });
});
```

Run tests:
```vim
:!npm test
```

## Real-World Patterns

### 1. Error Boundaries

```typescript
// src/components/ErrorBoundary.tsx
import { Component, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }
  
  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }
  
  componentDidCatch(error: Error, errorInfo: any) {
    console.error('Error caught:', error, errorInfo);
  }
  
  render() {
    if (this.state.hasError) {
      return this.props.fallback || <div>Something went wrong</div>;
    }
    
    return this.props.children;
  }
}
```

### 2. Code Splitting

```typescript
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Profile = lazy(() => import('./pages/Profile'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/profile" element={<Profile />} />
      </Routes>
    </Suspense>
  );
}
```

## Keybindings for React

```lua
-- Add to keymaps.lua
-- React specific commands
vim.keymap.set('n', '<leader>rc', ':!npm run dev<CR>', 
    { desc = '[R]eact dev server [C]' })
vim.keymap.set('n', '<leader>rb', ':!npm run build<CR>', 
    { desc = '[R]eact [B]uild' })
vim.keymap.set('n', '<leader>rt', ':!npm test<CR>', 
    { desc = '[R]eact [T]est' })
```

---

**Build amazing React apps with Neovim! ⚛️**
