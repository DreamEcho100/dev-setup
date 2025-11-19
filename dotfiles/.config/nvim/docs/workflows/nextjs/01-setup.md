# Next.js Development Setup in Neovim

## Overview
Complete Next.js development environment matching VSCode's capabilities with full TypeScript, React, and Next.js features.

## Project Setup

### Create New Next.js Project
```bash
# With TypeScript (recommended)
npx create-next-app@latest my-app --typescript --tailwind --app

cd my-app
nvim .
```

### Existing Project
```bash
cd existing-nextjs-project
npm install
nvim .
```

## LSP Configuration

### Automatic Setup via Mason
Your current `mason.lua` already includes:
```lua
ensure_installed = {
  "ts_ls",        -- TypeScript/JavaScript LSP
  "tailwindcss",  -- Tailwind CSS LSP
  "eslint",       -- ESLint LSP
  "emmet_ls",     -- Emmet for JSX
}
```

All automatically configured! ✅

### TypeScript Configuration
Create/verify `tsconfig.json`:
```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/lib/*": ["./src/lib/*"],
      "@/styles/*": ["./src/styles/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

LSP automatically understands these path aliases!

## Features Enabled

### ✅ TypeScript IntelliSense
- Full Next.js API completion
- Component props validation
- Route parameter types
- Server/Client component awareness

### ✅ React/JSX Support
- Component completion
- Hook suggestions
- Props validation
- Event handler types

### ✅ Next.js Specific
- `next/router` completion
- `next/link` props
- `next/image` validation
- API route types
- Server Actions support (App Router)
- Metadata API completion

### ✅ Tailwind CSS IntelliSense
Already configured! Features:
- Class name completion
- Hover for CSS values
- Color previews in virtual text
- Variant suggestions

**Example:**
```tsx
<div className="flex items-center justify-| ">
//                                        ^ Trigger completion here
```

### ✅ Import Auto-completion
Type component name, get auto-import:
```tsx
<Button />  // Unimported
```
```vim
<leader>ca  " → "Add import from '@/components/ui/button'"
```

### ✅ Auto-import Organization
Already configured in `formatting.lua`:
```lua
-- Organizes TypeScript imports on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.tsx,*.ts",
  callback = function(ev)
    -- Runs _typescript.organizeImports command
  end
})
```

## Project Structure

### Next.js App Router (Recommended)
```
src/
├── app/
│   ├── layout.tsx          # Root layout
│   ├── page.tsx            # Home page
│   ├── globals.css
│   ├── about/
│   │   └── page.tsx        # /about route
│   ├── blog/
│   │   ├── page.tsx        # /blog route
│   │   └── [slug]/
│   │       └── page.tsx    # /blog/[slug] route
│   └── api/
│       └── users/
│           └── route.ts    # API route
├── components/
│   ├── ui/
│   │   ├── button.tsx
│   │   └── card.tsx
│   └── layout/
│       ├── header.tsx
│       └── footer.tsx
├── lib/
│   ├── utils.ts
│   └── api.ts
└── types/
    └── index.ts
```

### Pages Router (Legacy)
```
src/
├── pages/
│   ├── _app.tsx
│   ├── _document.tsx
│   ├── index.tsx
│   ├── about.tsx
│   └── api/
│       └── users.ts
├── components/
├── styles/
└── public/
```

## Navigation Workflow

### Find Components
```vim
<leader>sf  " Find files - type component name
<leader>sg  " Search by content - find usage
<leader>sw  " Search word under cursor
```

### Jump to Definition
```tsx
import { Button } from '@/components/ui/button'
//       ^^^^^^ Place cursor here
```
```vim
gd  " Jump to Button component definition
```

### Find All References
```tsx
function MyComponent() {
  // Cursor on MyComponent
}
```
```vim
gr  " Show all usages of MyComponent
```

### Navigate Imports
```vim
gf  " Go to file under cursor (works with imports!)
<C-o>  " Jump back
```

## Component Development

### Create New Component
```vim
:Neotree
# Navigate to components/
# Press 'a' to create file
MyComponent.tsx
```

Type `rfc` and trigger snippet:
```tsx
export default function MyComponent() {
  return (
    <div>MyComponent</div>
  )
}
```

### Props with TypeScript
```tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary'
  onClick?: () => void
  children: React.ReactNode
}

export function Button({ variant = 'primary', onClick, children }: ButtonProps) {
  return (
    <button onClick={onClick} className={`btn-${variant}`}>
      {children}
    </button>
  )
}
```

LSP provides:
- Prop completion when using `<Button |`
- Type checking for prop values
- Error if required props missing

### Extract Component
1. Select JSX in visual mode: `vit` (inside tag)
2. `<leader>ca` → "Extract to function"
3. Enter component name
4. Component created inline

Move to separate file manually:
```vim
# Cut component: dap (delete a paragraph)
# Create new file
:e components/NewComponent.tsx
# Paste: p
# Go back: <C-o>
# Add import
<leader>ca  " Auto-import
```

## Server vs Client Components (App Router)

### Server Component (Default)
```tsx
// app/page.tsx
export default async function Page() {
  const data = await fetch('https://api.example.com/data')
  const json = await data.json()
  
  return <div>{json.title}</div>
}
```

No `"use client"` needed!

### Client Component
```tsx
// components/Counter.tsx
'use client'

import { useState } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)
  
  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  )
}
```

LSP warns if you use client-only features without `"use client"`!

## API Routes

### App Router API Route
```tsx
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const users = await db.users.findMany()
  return NextResponse.json(users)
}

export async function POST(request: NextRequest) {
  const body = await request.json()
  const user = await db.users.create({ data: body })
  return NextResponse.json(user, { status: 201 })
}
```

### Test API Route
```vim
<leader>v  " Split vertical
:terminal
curl http://localhost:3000/api/users
```

Or use REST client:
```vim
# In http file
GET http://localhost:3000/api/users
```

## Routing

### Dynamic Routes
```tsx
// app/blog/[slug]/page.tsx
interface PageProps {
  params: { slug: string }
  searchParams: { [key: string]: string | string[] | undefined }
}

export default function BlogPost({ params, searchParams }: PageProps) {
  return <div>Post: {params.slug}</div>
}

// Generate static params for SSG
export async function generateStaticParams() {
  const posts = await getPosts()
  return posts.map((post) => ({
    slug: post.slug,
  }))
}
```

LSP provides:
- Type-safe params
- Completion for Next.js functions
- Error checking

### Link Navigation
```tsx
import Link from 'next/link'

<Link href="/blog/my-post">Read More</Link>
```

Cmd+Click (or `gf`) on href to jump to route file!

## State Management

### React Hooks
```tsx
'use client'

import { useState, useEffect } from 'react'

export function DataFetcher() {
  const [data, setData] = useState<Data | null>(null)
  
  useEffect(() => {
    fetch('/api/data')
      .then(res => res.json())
      .then(setData)
  }, [])
  
  return <div>{data?.title}</div>
}
```

### Context
```tsx
// contexts/ThemeContext.tsx
'use client'

import { createContext, useContext } from 'react'

const ThemeContext = createContext<'light' | 'dark'>('light')

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  return (
    <ThemeContext.Provider value="dark">
      {children}
    </ThemeContext.Provider>
  )
}

export const useTheme = () => useContext(ThemeContext)
```

## Styling

### Tailwind CSS (Already Configured!)
```tsx
<div className="flex items-center space-x-4 rounded-lg border p-4 shadow-md hover:shadow-lg transition-shadow">
  <Avatar />
  <div>
    <h3 className="text-lg font-semibold">User Name</h3>
    <p className="text-sm text-gray-500">user@example.com</p>
  </div>
</div>
```

**Features:**
- ✅ Class completion
- ✅ Hover shows CSS
- ✅ Color preview
- ✅ Variant suggestions
- ✅ Unknown class warnings

### CSS Modules
```tsx
// Button.module.css
.button {
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
}

// Button.tsx
import styles from './Button.module.css'

export function Button() {
  return <button className={styles.button}>Click</button>
}
```

LSP provides completion for `styles.|`!

## Running Next.js

### Development Server
```bash
npm run dev
```

### From Neovim
```vim
<leader>v  " Vertical split
:terminal
npm run dev
```

Or detached:
```vim
:!npm run dev &
```

### Hot Reload
Next.js Fast Refresh works automatically!
Save file → browser updates instantly.

### View in Browser
```bash
# After npm run dev
firefox http://localhost:3000
```

## Building & Production

### Build
```bash
npm run build
```

### Preview Production Build
```bash
npm run build && npm run start
```

### Analyze Bundle
```bash
npm run build -- --analyze
```

## Linting & Formatting

### ESLint (Already Configured!)
Your `linting.lua` handles this automatically.

Runs on:
- File save
- Buffer enter
- Insert leave

View errors:
```vim
[d  " Previous diagnostic
]d  " Next diagnostic
<leader>d  " Show diagnostic
<leader>sd " Search all diagnostics
```

### Format on Save (Already Configured!)
Your `formatting.lua` uses:
- Biome (first choice)
- Prettier (fallback)

Formats:
- TypeScript/JavaScript
- TSX/JSX
- JSON
- CSS
- Markdown

### Manual Format
```vim
<leader>f  " Format current file
```

## Testing

### Install Vitest
```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom
```

### Component Test Example
```tsx
// __tests__/Button.test.tsx
import { render, screen } from '@testing-library/react'
import { Button } from '@/components/Button'

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })
})
```

### Run Tests
```vim
:!npm test
" Or watch mode
:!npm test -- --watch
```

## Environment Variables

### Create `.env.local`
```bash
DATABASE_URL=postgresql://...
NEXT_PUBLIC_API_URL=https://api.example.com
```

### Use in Code
```tsx
// Server component or API route
const dbUrl = process.env.DATABASE_URL

// Client component (must have NEXT_PUBLIC_ prefix)
const apiUrl = process.env.NEXT_PUBLIC_API_URL
```

LSP provides autocomplete for env vars!

## Deployment

### Vercel (Recommended)
```bash
npm install -g vercel
vercel
```

### Docker
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
CMD ["npm", "start"]
```

## Troubleshooting

### LSP Not Working
```vim
:LspInfo
:LspRestart
```

### TypeScript Errors
```bash
# Clear Next.js cache
rm -rf .next
npm run dev
```

### Import Not Resolving
```vim
:e tsconfig.json
# Verify paths are correct
:LspRestart
```

### Tailwind Not Completing
```bash
# Verify tailwind.config.ts exists
# Restart LSP
:LspRestart
```

## Performance Tips

### 1. Use `.gitignore`
```gitignore
node_modules/
.next/
out/
.env*.local
```

### 2. Exclude from Search
Your `telescope.lua` already excludes:
```lua
file_ignore_patterns = { 'node_modules', '.git', '.next' }
```

### 3. Lazy Load Images
```tsx
import Image from 'next/image'

<Image
  src="/photo.jpg"
  alt="Photo"
  width={500}
  height={300}
  loading="lazy"
/>
```

## Next Steps
- [02-workflow.md](./02-workflow.md) - Daily development workflow
- [03-advanced-patterns.md](./03-advanced-patterns.md) - Advanced Next.js patterns
- [04-performance.md](./04-performance.md) - Performance optimization
