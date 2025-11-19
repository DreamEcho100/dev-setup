# Node.js Development Workflow in Neovim

Complete guide to professional Node.js backend development in Neovim - REST APIs, GraphQL, CLI tools, microservices, and more.

## Table of Contents

1. [Quick Start](#quick-start)
2. [LSP Setup](#lsp-setup)
3. [Project Types](#project-types)
4. [Debugging Node.js](#debugging-nodejs)
5. [Testing](#testing)
6. [Common Workflows](#common-workflows)
7. [Package Management](#package-management)
8. [Real-World Scenarios](#real-world-scenarios)
9. [Performance & Profiling](#performance--profiling)
10. [Best Practices](#best-practices)

---

## Quick Start

### Prerequisites

```bash
# Install Node.js & npm (use nvm recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
nvm use --lts

# Install TypeScript globally (optional but recommended)
npm install -g typescript ts-node

# Install LSP server (automatic via mason.nvim)
:Mason
# Search for: typescript-language-server, eslint-lsp
```

### 5-Minute Setup

```lua
-- Your config already has this via lazy.nvim
-- typescript-language-server is installed via mason
-- Just verify it's running:
:LspInfo
```

---

## LSP Setup

### TypeScript Language Server (tsserver)

**Your configuration already uses**: `typescript-language-server`

See: [JavaScript/TypeScript guide](../javascript-typescript/README.md) for full LSP details.

### Node.js-Specific LSP Features

```lua
-- In your project, ensure package.json exists:
{
  "type": "module",  -- or "commonjs"
  "engines": {
    "node": ">=18.0.0"
  }
}
```

### Common Node.js LSP Commands

| Keybinding | Command | Purpose |
|------------|---------|---------|
| `gd` | Go to definition | Jump to function/module |
| `K` | Hover | Show documentation |
| `<leader>ca` | Code action | Import modules, fix issues |
| `<leader>rn` | Rename | Rename across files |
| `gr` | References | Find all usages |
| `<leader>f` | Format | Prettier/ESLint format |

---

## Project Types

### 1. REST API (Express.js)

#### Quick Setup

```bash
# Create new project
mkdir my-api && cd my-api
npm init -y
npm install express cors helmet morgan
npm install -D nodemon typescript @types/node @types/express

# Initialize TypeScript
npx tsc --init

# Create structure
mkdir -p src/{routes,controllers,middleware,models,utils}
touch src/server.ts src/app.ts
```

#### Basic Express Server

```typescript
// src/app.ts
import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

const app: Application = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

app.get('/api/users', (req: Request, res: Response) => {
  res.json({ users: [] });
});

export default app;

// src/server.ts
import app from './app';

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
```

#### package.json Scripts

```json
{
  "scripts": {
    "dev": "nodemon --exec ts-node src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "jest",
    "lint": "eslint . --ext .ts"
  }
}
```

#### Neovim Workflow

```vim
" Open project
:e src/app.ts

" Run dev server in terminal
<leader>tt :TermExec cmd="npm run dev"<CR>

" Watch logs
:vsplit term://npm run dev

" Make changes -> auto-reload via nodemon

" Format on save (already configured)
:w

" Run tests
:!npm test

" Build for production
:!npm run build
```

---

### 2. GraphQL API (Apollo Server)

#### Setup

```bash
npm install apollo-server graphql
npm install -D @types/graphql
```

#### Basic GraphQL Server

```typescript
// src/graphql-server.ts
import { ApolloServer, gql } from 'apollo-server';

const typeDefs = gql`
  type User {
    id: ID!
    name: String!
    email: String!
  }

  type Query {
    users: [User!]!
    user(id: ID!): User
  }

  type Mutation {
    createUser(name: String!, email: String!): User!
  }
`;

const resolvers = {
  Query: {
    users: () => [
      { id: '1', name: 'John', email: 'john@example.com' }
    ],
    user: (_, { id }) => ({
      id,
      name: 'John',
      email: 'john@example.com'
    })
  },
  Mutation: {
    createUser: (_, { name, email }) => ({
      id: Date.now().toString(),
      name,
      email
    })
  }
};

const server = new ApolloServer({ typeDefs, resolvers });

server.listen(4000).then(({ url }) => {
  console.log(`GraphQL server ready at ${url}`);
});
```

#### Neovim GraphQL Workflow

```vim
" Edit schema
:e src/schema.graphql

" Syntax highlighting for .graphql files (via treesitter)
" Already configured in your setup

" Run GraphQL server
:TermExec cmd="npm run dev"

" Test queries in separate terminal
:vsplit
:term
curl -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ users { id name } }"}'

" Or use GraphQL Playground in browser
" Navigate to http://localhost:4000
```

---

### 3. CLI Tools

#### Setup

```bash
npm install commander inquirer chalk ora
npm install -D @types/node
```

#### Example CLI

```typescript
#!/usr/bin/env node
// src/cli.ts
import { Command } from 'commander';
import inquirer from 'inquirer';
import chalk from 'chalk';
import ora from 'ora';

const program = new Command();

program
  .name('my-cli')
  .description('Awesome CLI tool')
  .version('1.0.0');

program
  .command('create')
  .description('Create a new project')
  .action(async () => {
    const answers = await inquirer.prompt([
      {
        type: 'input',
        name: 'projectName',
        message: 'Project name:',
        default: 'my-project'
      },
      {
        type: 'list',
        name: 'framework',
        message: 'Choose framework:',
        choices: ['Express', 'Fastify', 'Koa']
      }
    ]);

    const spinner = ora('Creating project...').start();
    
    // Simulate work
    setTimeout(() => {
      spinner.succeed(chalk.green('Project created!'));
      console.log(chalk.blue(`Name: ${answers.projectName}`));
      console.log(chalk.blue(`Framework: ${answers.framework}`));
    }, 2000);
  });

program.parse();
```

#### Make CLI Executable

```json
// package.json
{
  "name": "my-cli",
  "bin": {
    "my-cli": "./dist/cli.js"
  },
  "scripts": {
    "build": "tsc",
    "dev": "ts-node src/cli.ts"
  }
}
```

#### Neovim CLI Development

```vim
" Edit CLI code
:e src/cli.ts

" Test CLI interactively
:term
ts-node src/cli.ts create

" Or run with npm
:!npm run dev -- create

" Build and link globally for testing
:!npm run build && npm link

" Test installed CLI
:!my-cli create
```

---

### 4. Microservices

#### Service Structure

```
my-service/
├── src/
│   ├── server.ts
│   ├── config/
│   │   └── index.ts
│   ├── services/
│   │   ├── user.service.ts
│   │   └── auth.service.ts
│   ├── routes/
│   │   └── api.routes.ts
│   ├── middleware/
│   │   └── auth.middleware.ts
│   └── utils/
│       └── logger.ts
├── tests/
├── docker/
│   └── Dockerfile
└── package.json
```

#### Example Service

```typescript
// src/services/user.service.ts
export class UserService {
  async getUser(id: string) {
    // Database query
    return { id, name: 'John' };
  }

  async createUser(data: any) {
    // Validation + DB insert
    return { id: 'new-id', ...data };
  }
}

// src/routes/api.routes.ts
import { Router } from 'express';
import { UserService } from '../services/user.service';

const router = Router();
const userService = new UserService();

router.get('/users/:id', async (req, res) => {
  const user = await userService.getUser(req.params.id);
  res.json(user);
});

export default router;
```

#### Docker Setup

```dockerfile
# docker/Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY dist/ ./dist/

EXPOSE 3000

CMD ["node", "dist/server.js"]
```

#### Neovim Microservices Workflow

```vim
" Navigate services
<leader>sf  " Find files (telescope)
" Type: user.service

" Run service locally
:TermExec cmd="npm run dev"

" Build Docker image
:!docker build -t my-service -f docker/Dockerfile .

" Run in container
:!docker run -p 3000:3000 my-service

" View logs
:TermExec cmd="docker logs -f <container-id>"

" Run multiple services (docker-compose)
:!docker-compose up
```

---

## Debugging Node.js

### Debug Adapter Protocol (DAP)

Your config uses `nvim-dap` with `vscode-js-debug`.

### Setup Debug Configuration

```lua
-- Already in your config via dap setup
-- For Node.js, configurations are auto-detected
```

### Manual Debug Config

Create `.vscode/launch.json` (DAP recognizes it):

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Server",
      "program": "${workspaceFolder}/src/server.ts",
      "preLaunchTask": "tsc: build",
      "outFiles": ["${workspaceFolder}/dist/**/*.js"]
    },
    {
      "type": "node",
      "request": "attach",
      "name": "Attach to Process",
      "port": 9229
    }
  ]
}
```

### Debugging Workflow

#### 1. Set Breakpoints

```vim
:lua require('dap').toggle_breakpoint()
" Or: <F9>
```

#### 2. Start Debugging

```vim
:lua require('dap').continue()
" Or: <F5>
```

#### 3. Debug Controls

| Key | Action |
|-----|--------|
| `<F5>` | Continue / Start |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<F9>` | Toggle breakpoint |

#### 4. Inspect Variables

```vim
" Hover over variable
:lua require('dap.ui.widgets').hover()

" Open REPL
:lua require('dap').repl.open()

" Evaluate expression
:lua require('dap.ui.widgets').centered_float(require('dap.ui.widgets').scopes)
```

### Debug Express Server Example

```typescript
// src/server.ts
import app from './app';

const PORT = 3000;

app.listen(PORT, () => {
  debugger; // Breakpoint here
  console.log(`Server on port ${PORT}`);
});
```

```vim
" In Neovim:
1. Open src/server.ts
2. Set breakpoint: <F9> on line 6
3. Start debug: <F5>
4. Choose configuration: "Debug Server"
5. Inspect variables in DAP UI
6. Step through with <F10>
```

### Debug with Nodemon

```bash
# package.json
{
  "scripts": {
    "dev": "nodemon --exec 'node --inspect' src/server.js"
  }
}
```

Then attach debugger:

```vim
:lua require('dap').continue()
" Select: "Attach to Process"
```

---

## Testing

### Jest Setup

```bash
npm install -D jest ts-jest @types/jest supertest @types/supertest
```

#### jest.config.js

```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.test.ts'],
  collectCoverageFrom: ['src/**/*.ts'],
  coverageDirectory: 'coverage'
};
```

### Example Tests

```typescript
// src/__tests__/app.test.ts
import request from 'supertest';
import app from '../app';

describe('API Tests', () => {
  describe('GET /health', () => {
    it('should return 200 OK', async () => {
      const res = await request(app).get('/health');
      expect(res.status).toBe(200);
      expect(res.body.status).toBe('ok');
    });
  });

  describe('GET /api/users', () => {
    it('should return users array', async () => {
      const res = await request(app).get('/api/users');
      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.users)).toBe(true);
    });
  });
});
```

### Neovim Testing Workflow

#### Run All Tests

```vim
:!npm test

" Or with neotest (if configured)
:lua require('neotest').run.run()
```

#### Run Current Test File

```vim
:!npm test -- %:t

" With neotest
:lua require('neotest').run.run(vim.fn.expand('%'))
```

#### Run Single Test

```vim
" Place cursor on test
:lua require('neotest').run.run()
```

#### Watch Mode

```vim
:TermExec cmd="npm test -- --watch"
```

#### Coverage

```vim
:!npm test -- --coverage
:e coverage/lcov-report/index.html
```

### Integration Tests

```typescript
// tests/integration/api.integration.test.ts
import { Server } from 'http';
import app from '../../src/app';

describe('Integration Tests', () => {
  let server: Server;

  beforeAll((done) => {
    server = app.listen(4000, done);
  });

  afterAll((done) => {
    server.close(done);
  });

  it('should handle complete user flow', async () => {
    // Create user
    const createRes = await request(app)
      .post('/api/users')
      .send({ name: 'Test User', email: 'test@example.com' });
    
    expect(createRes.status).toBe(201);
    const userId = createRes.body.id;

    // Get user
    const getRes = await request(app).get(`/api/users/${userId}`);
    expect(getRes.status).toBe(200);
    expect(getRes.body.name).toBe('Test User');
  });
});
```

---

## Common Workflows

### 1. API Endpoint Development

```vim
" Workflow:
1. Create route file
   :e src/routes/users.routes.ts
   
2. Write route with LSP autocomplete
   import { Router } from 'express';
   const router = Router();
   router.get('/users', ...);
   
3. Create controller
   :e src/controllers/users.controller.ts
   
4. Implement logic with LSP helping
   
5. Write test
   :e src/__tests__/users.test.ts
   
6. Run tests
   :!npm test
   
7. Test manually
   :TermExec cmd="npm run dev"
   :vsplit term://curl localhost:3000/api/users
```

### 2. Add New Dependency

```vim
:!npm install axios
:!npm install -D @types/axios

" LSP will auto-detect types
" Import in code: import axios from 'axios';
" Autocomplete works immediately
```

### 3. Environment Variables

```bash
# .env
PORT=3000
DATABASE_URL=postgresql://localhost/mydb
JWT_SECRET=supersecret
```

```typescript
// src/config/index.ts
import dotenv from 'dotenv';
dotenv.config();

export const config = {
  port: process.env.PORT || 3000,
  databaseUrl: process.env.DATABASE_URL!,
  jwtSecret: process.env.JWT_SECRET!
};
```

```vim
" Edit .env
:e .env

" gitignore it
:e .gitignore
.env
```

### 4. Database Integration (Prisma)

```bash
npm install @prisma/client
npm install -D prisma

npx prisma init
```

```vim
" Edit schema
:e prisma/schema.prisma

" Generate client
:!npx prisma generate

" Run migrations
:!npx prisma migrate dev

" Open Prisma Studio
:!npx prisma studio

" Use in code with full LSP support
```

---

## Package Management

### npm Commands

```vim
" Install dependencies
:!npm install

" Add package
:!npm install package-name

" Add dev dependency
:!npm install -D package-name

" Update packages
:!npm update

" Audit security
:!npm audit
:!npm audit fix

" List outdated
:!npm outdated

" Clean install
:!rm -rf node_modules package-lock.json
:!npm install
```

### Alternative: pnpm

```bash
# Install pnpm
npm install -g pnpm

# Use pnpm
pnpm install
pnpm add package-name
pnpm run dev
```

### Alternative: yarn

```bash
# Install yarn
npm install -g yarn

# Use yarn
yarn install
yarn add package-name
yarn dev
```

---

## Real-World Scenarios

### Scenario 1: REST API with Database

**Goal**: Build a complete CRUD API with PostgreSQL

```bash
# Setup
npm install express pg
npm install -D @types/pg nodemon

# Structure
mkdir -p src/{routes,controllers,services,models,middleware}
```

```typescript
// src/services/database.service.ts
import { Pool } from 'pg';

export class DatabaseService {
  private pool: Pool;

  constructor() {
    this.pool = new Pool({
      connectionString: process.env.DATABASE_URL
    });
  }

  async query(text: string, params?: any[]) {
    const client = await this.pool.connect();
    try {
      return await client.query(text, params);
    } finally {
      client.release();
    }
  }
}

// src/controllers/users.controller.ts
import { Request, Response } from 'express';
import { DatabaseService } from '../services/database.service';

export class UsersController {
  constructor(private db: DatabaseService) {}

  async getAll(req: Request, res: Response) {
    const result = await this.db.query('SELECT * FROM users');
    res.json(result.rows);
  }

  async create(req: Request, res: Response) {
    const { name, email } = req.body;
    const result = await this.db.query(
      'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
      [name, email]
    );
    res.status(201).json(result.rows[0]);
  }
}
```

**Neovim Workflow**:

```vim
1. :e src/services/database.service.ts
2. Write code with LSP autocomplete
3. :e src/controllers/users.controller.ts
4. Implement CRUD operations
5. :e src/__tests__/users.test.ts
6. Write integration tests
7. :TermExec cmd="docker run -p 5432:5432 -e POSTGRES_PASSWORD=password postgres"
8. :!npm run dev
9. Test endpoints: :!curl localhost:3000/api/users
```

### Scenario 2: Authentication API

```typescript
// src/middleware/auth.middleware.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export const authenticate = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
};

// src/controllers/auth.controller.ts
import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';

export class AuthController {
  async login(req: Request, res: Response) {
    const { email, password } = req.body;
    
    // Fetch user from DB
    const user = await db.query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (!user || !await bcrypt.compare(password, user.password)) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET!);
    res.json({ token });
  }
}

// Use in routes
app.post('/api/login', authController.login);
app.get('/api/protected', authenticate, (req, res) => {
  res.json({ message: 'Protected route', user: req.user });
});
```

### Scenario 3: Real-time with WebSockets

```bash
npm install socket.io
npm install -D @types/socket.io
```

```typescript
// src/websocket.ts
import { Server as HTTPServer } from 'http';
import { Server as SocketServer } from 'socket.io';

export function setupWebSocket(server: HTTPServer) {
  const io = new SocketServer(server, {
    cors: { origin: '*' }
  });

  io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);

    socket.on('message', (data) => {
      io.emit('message', data); // Broadcast
    });

    socket.on('disconnect', () => {
      console.log('Client disconnected:', socket.id);
    });
  });

  return io;
}

// src/server.ts
import http from 'http';
import app from './app';
import { setupWebSocket } from './websocket';

const server = http.createServer(app);
setupWebSocket(server);

server.listen(3000);
```

---

## Performance & Profiling

### 1. CPU Profiling

```bash
# Run with profiler
node --prof src/server.js

# Process profile
node --prof-process isolate-0x*.log > profile.txt
```

```vim
:e profile.txt
" Analyze bottlenecks
```

### 2. Memory Profiling

```bash
# Run with heap snapshot
node --inspect src/server.js
```

Open Chrome DevTools → Memory → Take snapshot

### 3. Performance Monitoring

```typescript
// src/middleware/performance.middleware.ts
import { Request, Response, NextFunction } from 'express';

export const performanceMonitor = (req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`${req.method} ${req.url} - ${duration}ms`);
    
    if (duration > 1000) {
      console.warn(`SLOW REQUEST: ${req.url} took ${duration}ms`);
    }
  });
  
  next();
};

// Use in app
app.use(performanceMonitor);
```

### 4. Load Testing

```bash
# Install k6
brew install k6  # macOS
# or download from k6.io

# Create load test
```

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  vus: 100,
  duration: '30s',
};

export default function () {
  const res = http.get('http://localhost:3000/api/users');
  check(res, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
```

```vim
:!k6 run load-test.js
```

---

## Best Practices

### 1. Project Structure

```
src/
├── app.ts              # Express app setup
├── server.ts           # Server entry point
├── config/             # Configuration
│   └── index.ts
├── routes/             # Route definitions
│   ├── api.routes.ts
│   └── users.routes.ts
├── controllers/        # Request handlers
│   └── users.controller.ts
├── services/           # Business logic
│   └── users.service.ts
├── models/             # Data models
│   └── user.model.ts
├── middleware/         # Custom middleware
│   └── auth.middleware.ts
├── utils/              # Utilities
│   └── logger.ts
└── types/              # TypeScript types
    └── index.ts
```

### 2. Error Handling

```typescript
// src/middleware/error.middleware.ts
import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string
  ) {
    super(message);
  }
}

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      status: 'error',
      message: err.message
    });
  }

  console.error('ERROR:', err);
  res.status(500).json({
    status: 'error',
    message: 'Internal server error'
  });
};

// Use in app
app.use(errorHandler);

// Throw errors
throw new AppError(404, 'User not found');
```

### 3. Logging

```typescript
// src/utils/logger.ts
import winston from 'winston';

export const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple(),
  }));
}

// Use throughout app
logger.info('Server started');
logger.error('Database connection failed', { error: err.message });
```

### 4. Configuration Management

```typescript
// src/config/index.ts
import dotenv from 'dotenv';

dotenv.config();

const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000'),
  database: {
    url: process.env.DATABASE_URL!,
    ssl: process.env.DATABASE_SSL === 'true'
  },
  jwt: {
    secret: process.env.JWT_SECRET!,
    expiresIn: '7d'
  },
  cors: {
    origin: process.env.CORS_ORIGIN || '*'
  }
};

export default config;
```

### 5. Input Validation

```bash
npm install joi
npm install -D @types/joi
```

```typescript
// src/validators/user.validator.ts
import Joi from 'joi';

export const createUserSchema = Joi.object({
  name: Joi.string().min(2).max(50).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required()
});

// Middleware
export const validate = (schema: Joi.Schema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req.body);
    if (error) {
      return res.status(400).json({ error: error.details[0].message });
    }
    next();
  };
};

// Use in routes
app.post('/api/users', validate(createUserSchema), usersController.create);
```

---

## Quick Reference

### Essential Keybindings

| Action | Keybinding | Purpose |
|--------|------------|---------|
| Find file | `<leader>sf` | Open any file |
| Format | `<leader>f` | Format with Prettier |
| LSP rename | `<leader>rn` | Rename symbol |
| Go to def | `gd` | Jump to definition |
| References | `gr` | Find all references |
| Code action | `<leader>ca` | Fix imports/errors |
| Toggle term | `<C-\>` | Open terminal |
| Run file | `:!node %` | Execute current file |

### Common Commands

```bash
# Development
npm run dev              # Start dev server
npm run build            # Build for production
npm start                # Start production server

# Testing
npm test                 # Run all tests
npm test -- --watch      # Watch mode
npm test -- --coverage   # With coverage

# Linting
npm run lint             # Check code
npm run lint:fix         # Auto-fix issues

# Dependencies
npm install              # Install deps
npm ci                   # Clean install
npm outdated             # Check outdated
npm audit                # Security audit
```

---

## Troubleshooting

### LSP Not Working

```vim
:LspInfo
" If not attached:
:LspStart tsserver

" Restart LSP
:LspRestart
```

### Module Not Found

```bash
# Clear cache
rm -rf node_modules package-lock.json
npm install
```

### TypeScript Errors

```bash
# Regenerate tsconfig
npx tsc --init

# Check types
npx tsc --noEmit
```

### Debugging Not Working

```vim
" Check DAP installation
:Mason
" Install: js-debug-adapter

" Verify config exists
:e .vscode/launch.json
```

---

## Additional Resources

- **Official Docs**: https://nodejs.org/docs
- **Express Guide**: https://expressjs.com/
- **TypeScript Handbook**: https://www.typescriptlang.org/docs/
- **Jest Docs**: https://jestjs.io/
- **nvim-lspconfig**: https://github.com/neovim/nvim-lspconfig

---

**Next Steps:**

1. Create a Node.js project: `npm init -y`
2. Install TypeScript: `npm install -D typescript`
3. Open in Neovim: `nvim .`
4. Start coding with full LSP support! 🚀

See also:
- [JavaScript/TypeScript Guide](../javascript-typescript/README.md)
- [React Workflows](../react/README.md)
- [Next.js Workflows](../nextjs/README.md)
