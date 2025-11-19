# Node.js Backend Development Setup

## Complete Node.js Server-Side Development

Your config already supports TypeScript/JavaScript! This guide focuses on Node.js-specific backend development.

## Prerequisites

### Node.js & Package Managers

```bash
# Node.js (via nvm - recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20

# Or via system package manager
# Ubuntu
sudo apt install nodejs npm

# macOS
brew install node

# Verify
node --version
npm --version

# Install pnpm (faster alternative)
npm install -g pnpm

# Install yarn (another alternative)
npm install -g yarn
```

## Project Setup

### Express.js API

```bash
mkdir my-node-api && cd my-node-api
npm init -y

# Install dependencies
npm install express dotenv cors helmet
npm install -D typescript @types/node @types/express tsx nodemon

# Initialize TypeScript
npx tsc --init

nvim .
```

### TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Package.json Scripts

```json
{
  "name": "my-node-api",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest",
    "lint": "eslint src/**/*.ts",
    "format": "prettier --write src/**/*.ts"
  }
}
```

## Project Structure

```
my-node-api/
├── src/
│   ├── index.ts              # Entry point
│   ├── app.ts                # Express app
│   ├── config/
│   │   └── database.ts
│   ├── routes/
│   │   ├── index.ts
│   │   └── users.routes.ts
│   ├── controllers/
│   │   └── users.controller.ts
│   ├── services/
│   │   └── users.service.ts
│   ├── models/
│   │   └── user.model.ts
│   ├── middleware/
│   │   ├── auth.middleware.ts
│   │   └── error.middleware.ts
│   └── types/
│       └── express.d.ts
├── tests/
│   └── users.test.ts
├── .env
├── .env.example
├── .gitignore
├── tsconfig.json
└── package.json
```

## Basic Express Server

### Entry Point

```typescript
// src/index.ts
import app from './app';
import { config } from './config/config';

const PORT = config.port || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📝 Environment: ${config.nodeEnv}`);
});
```

### App Configuration

```typescript
// src/app.ts
import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import routes from './routes';
import { errorHandler } from './middleware/error.middleware';

const app: Application = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api', routes);

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handling
app.use(errorHandler);

export default app;
```

### Configuration

```typescript
// src/config/config.ts
import dotenv from 'dotenv';

dotenv.config();

export const config = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000'),
  database: {
    url: process.env.DATABASE_URL || '',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    name: process.env.DB_NAME || 'mydb',
    user: process.env.DB_USER || 'user',
    password: process.env.DB_PASSWORD || 'password',
  },
  jwt: {
    secret: process.env.JWT_SECRET || 'your-secret-key',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  redis: {
    url: process.env.REDIS_URL || 'redis://localhost:6379',
  },
} as const;
```

### Routes

```typescript
// src/routes/index.ts
import { Router } from 'express';
import usersRoutes from './users.routes';

const router = Router();

router.use('/users', usersRoutes);

export default router;
```

```typescript
// src/routes/users.routes.ts
import { Router } from 'express';
import { UsersController } from '../controllers/users.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();
const controller = new UsersController();

router.get('/', controller.getAll);
router.get('/:id', controller.getById);
router.post('/', authMiddleware, controller.create);
router.put('/:id', authMiddleware, controller.update);
router.delete('/:id', authMiddleware, controller.delete);

export default router;
```

### Controllers

```typescript
// src/controllers/users.controller.ts
import { Request, Response, NextFunction } from 'express';
import { UsersService } from '../services/users.service';

export class UsersController {
  private service = new UsersService();

  getAll = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const users = await this.service.findAll();
      res.json(users);
    } catch (error) {
      next(error);
    }
  };

  getById = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const user = await this.service.findById(parseInt(id));
      
      if (!user) {
        return res.status(404).json({ error: 'User not found' });
      }
      
      res.json(user);
    } catch (error) {
      next(error);
    }
  };

  create = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const user = await this.service.create(req.body);
      res.status(201).json(user);
    } catch (error) {
      next(error);
    }
  };

  update = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      const user = await this.service.update(parseInt(id), req.body);
      res.json(user);
    } catch (error) {
      next(error);
    }
  };

  delete = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { id } = req.params;
      await this.service.delete(parseInt(id));
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  };
}
```

### Services

```typescript
// src/services/users.service.ts
import { User, CreateUserDTO, UpdateUserDTO } from '../types/user';

export class UsersService {
  private users: User[] = [];

  async findAll(): Promise<User[]> {
    return this.users;
  }

  async findById(id: number): Promise<User | undefined> {
    return this.users.find(u => u.id === id);
  }

  async create(dto: CreateUserDTO): Promise<User> {
    const user: User = {
      id: this.users.length + 1,
      ...dto,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    
    this.users.push(user);
    return user;
  }

  async update(id: number, dto: UpdateUserDTO): Promise<User> {
    const index = this.users.findIndex(u => u.id === id);
    
    if (index === -1) {
      throw new Error('User not found');
    }
    
    this.users[index] = {
      ...this.users[index],
      ...dto,
      updatedAt: new Date(),
    };
    
    return this.users[index];
  }

  async delete(id: number): Promise<void> {
    const index = this.users.findIndex(u => u.id === id);
    
    if (index === -1) {
      throw new Error('User not found');
    }
    
    this.users.splice(index, 1);
  }
}
```

### Middleware

```typescript
// src/middleware/error.middleware.ts
import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message);
    Object.setPrototypeOf(this, AppError.prototype);
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
      message: err.message,
    });
  }

  console.error('Error:', err);
  
  res.status(500).json({
    status: 'error',
    message: 'Internal server error',
  });
};
```

```typescript
// src/middleware/auth.middleware.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../config/config';

export interface AuthRequest extends Request {
  user?: {
    id: number;
    email: string;
  };
}

export const authMiddleware = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  const token = req.headers.authorization?.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  try {
    const decoded = jwt.verify(token, config.jwt.secret) as any;
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
};
```

## Database Integration

### PostgreSQL with Prisma

```bash
npm install prisma @prisma/client
npx prisma init
```

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String
  password  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  posts     Post[]
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String
  published Boolean  @default(false)
  authorId  Int
  author    User     @relation(fields: [authorId], references: [id])
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

```bash
# Generate client
npx prisma generate

# Run migrations
npx prisma migrate dev --name init
```

### Using Prisma

```typescript
// src/config/database.ts
import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient({
  log: ['query', 'error', 'warn'],
});
```

```typescript
// src/services/users.service.ts
import { prisma } from '../config/database';

export class UsersService {
  async findAll() {
    return prisma.user.findMany({
      select: {
        id: true,
        email: true,
        name: true,
        createdAt: true,
      },
    });
  }

  async findById(id: number) {
    return prisma.user.findUnique({
      where: { id },
      include: { posts: true },
    });
  }

  async create(data: CreateUserDTO) {
    return prisma.user.create({
      data,
    });
  }
}
```

## Testing

```bash
npm install -D vitest @vitest/ui supertest @types/supertest
```

```typescript
// tests/users.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import app from '../src/app';

describe('Users API', () => {
  it('GET /api/users - should return users', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect(200);

    expect(response.body).toBeInstanceOf(Array);
  });

  it('POST /api/users - should create user', async () => {
    const newUser = {
      name: 'John Doe',
      email: 'john@example.com',
    };

    const response = await request(app)
      .post('/api/users')
      .send(newUser)
      .expect(201);

    expect(response.body).toHaveProperty('id');
    expect(response.body.name).toBe(newUser.name);
  });
});
```

## Running in Neovim

```vim
# Start dev server
<leader>v
:terminal
npm run dev

# Or
:!npm run dev

# Run tests
:!npm test

# Build
:!npm run build

# Start production
:!npm start
```

## Environment Variables

```bash
# .env
NODE_ENV=development
PORT=3000

DATABASE_URL=postgresql://user:password@localhost:5432/mydb

JWT_SECRET=your-super-secret-key
JWT_EXPIRES_IN=7d

REDIS_URL=redis://localhost:6379
```

## Keybindings

```lua
-- Add to keymaps.lua
vim.keymap.set('n', '<leader>nd', ':!npm run dev<CR>', { desc = '[N]ode [D]ev' })
vim.keymap.set('n', '<leader>nb', ':!npm run build<CR>', { desc = '[N]ode [B]uild' })
vim.keymap.set('n', '<leader>nt', ':!npm test<CR>', { desc = '[N]ode [T]est' })
```

---

**Node.js backend development ready! 🚀**
