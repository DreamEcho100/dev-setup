# Framework Debugging Examples

## 🎯 Quick Reference

| Framework            | Server-Side Debugging | Client-Side Debugging |
| -------------------- | --------------------- | --------------------- |
| **React (CRA/Vite)** | ❌ No server          | ✅ Chrome DevTools    |
| **Next.js**          | ✅ Node debugger      | ✅ Chrome DevTools    |
| **Solid.js**         | ❌ No server          | ✅ Chrome DevTools    |
| **Solid Start**      | ✅ Node debugger      | ✅ Chrome DevTools    |
| **Remix**            | ✅ Node debugger      | ✅ Chrome DevTools    |
| **Astro**            | ✅ Node debugger      | ✅ Chrome DevTools    |

---

## 📦 React (Create React App / Vite)

**Client-Side Only** - Use Browser DevTools or attach to Chrome

### Option 1: Browser DevTools (Easiest)

```bash
npm run dev
# Open Chrome DevTools (F12) → Sources tab → Set breakpoints
```

### Option 2: Attach to Chrome from Neovim

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "React: Launch Chrome",
      "url": "http://localhost:5173",
      "webRoot": "${workspaceFolder}/src"
    }
  ]
}
```

**Steps:**

1. Start dev server: `npm run dev`
2. Set breakpoints in your React components
3. Press `<F5>` → Select "React: Launch Chrome"
4. Chrome will open with debugger attached

---

## ⚡ Next.js

**Full-Stack** - Debug both server and client code

### Server-Side (API Routes, Server Components, SSR)

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Next.js: debug server",
      "type": "pwa-node",
      "request": "launch",
      "cwd": "${workspaceFolder}",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "console": "integratedTerminal",
      "skipFiles": ["<node_internals>/**"]
    }
  ]
}
```

**Steps:**

1. Set breakpoints in `app/api/`, Server Components, or `getServerSideProps`
2. Press `<F5>` → Select "Next.js: debug server"
3. Make requests that trigger your breakpoints
4. Debugger will pause in server code

### Client-Side (React Components in Browser)

```json
{
  "type": "chrome",
  "request": "launch",
  "name": "Next.js: debug client",
  "url": "http://localhost:3000",
  "webRoot": "${workspaceFolder}",
  "sourceMaps": true
}
```

### Full-Stack (Both Server & Client)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Next.js: debug server",
      "type": "pwa-node",
      "request": "launch",
      "cwd": "${workspaceFolder}",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "console": "integratedTerminal"
    },
    {
      "name": "Next.js: debug client",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}"
    }
  ],
  "compounds": [
    {
      "name": "Next.js: debug full stack",
      "configurations": ["Next.js: debug server", "Next.js: debug client"],
      "stopAll": true
    }
  ]
}
```

**Steps:**

1. Press `<F5>` → Select "Next.js: debug full stack"
2. Both server and client debuggers start
3. Set breakpoints anywhere (server or client code)
4. Breakpoints work in both contexts!

---

## 🟦 Solid.js (Vite)

**Client-Side Only** - Similar to React

Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Solid.js: Launch Chrome",
      "url": "http://localhost:5173",
      "webRoot": "${workspaceFolder}/src"
    }
  ]
}
```

---

## 🟦 Solid Start

**Full-Stack** - Debug both server and client

### Server-Side

```json
{
  "name": "Solid Start: debug server",
  "type": "pwa-node",
  "request": "launch",
  "cwd": "${workspaceFolder}",
  "runtimeExecutable": "npm",
  "runtimeArgs": ["run", "dev"],
  "console": "integratedTerminal"
}
```

### Client-Side

```json
{
  "name": "Solid Start: debug client",
  "type": "chrome",
  "request": "launch",
  "url": "http://localhost:3000",
  "webRoot": "${workspaceFolder}/src"
}
```

---

## 🎭 Remix

**Full-Stack** - Server and browser debugging

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Remix: debug server",
      "type": "pwa-node",
      "request": "launch",
      "cwd": "${workspaceFolder}",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "console": "integratedTerminal"
    },
    {
      "name": "Remix: debug client",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}/app"
    }
  ]
}
```

**Debug loaders/actions:**

1. Set breakpoints in `loader` or `action` functions
2. Press `<F5>` → "Remix: debug server"
3. Navigate to the route
4. Debugger pauses in server code

---

## 🚀 Astro

**Hybrid** - Server-side rendering and client hydration

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Astro: debug server",
      "type": "pwa-node",
      "request": "launch",
      "cwd": "${workspaceFolder}",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev"],
      "console": "integratedTerminal"
    }
  ]
}
```

---

## 🔧 Common Debugging Patterns

### Pattern 1: Attach to Running Dev Server

If your dev server is already running:

```json
{
  "type": "pwa-node",
  "request": "attach",
  "name": "Attach to Node",
  "port": 9229,
  "restart": true
}
```

Start server with inspect flag:

```bash
NODE_OPTIONS='--inspect' npm run dev
```

### Pattern 2: Chrome with Remote Debugging

Start Chrome with debugging enabled:

```bash
google-chrome --remote-debugging-port=9222
```

Then attach from Neovim:

```json
{
  "type": "chrome",
  "request": "attach",
  "name": "Attach to Chrome",
  "port": 9222,
  "webRoot": "${workspaceFolder}"
}
```

### Pattern 3: Debug Build Output

Debug production builds:

```json
{
  "type": "pwa-node",
  "request": "launch",
  "name": "Start Production",
  "runtimeExecutable": "npm",
  "runtimeArgs": ["run", "start"],
  "console": "integratedTerminal"
}
```

---

## 💡 Pro Tips

### 1. Source Maps Are Critical

Ensure your build tool generates source maps:

```js
// vite.config.js
export default {
  build: {
    sourcemap: true,
  },
};

// next.config.js
module.exports = {
  productionBrowserSourceMaps: true,
};
```

### 2. Skip Node Internals

Add to all Node configurations:

```json
"skipFiles": [
  "<node_internals>/**",
  "node_modules/**"
]
```

### 3. Use Console Logs as Fallback

Sometimes browser DevTools are simpler for client-side debugging:

```javascript
console.log("🔍 Debug point", { variable });
debugger; // Pauses in browser DevTools
```

### 4. Debug Environment Variables

```json
{
  "env": {
    "NODE_ENV": "development",
    "DEBUG": "*"
  }
}
```

### 5. TypeScript Path Mappings

If using path aliases (`@/components`), configure `webRoot`:

```json
{
  "webRoot": "${workspaceFolder}",
  "pathMapping": {
    "@": "${workspaceFolder}/src"
  }
}
```

---

## 🎯 Quick Start for Your Framework

1. **Install Chrome debugger:**

   ```
   :Mason
   # Search for "chrome-debug-adapter" and install
   ```

2. **Create `.vscode/launch.json` in your project** (copy from examples above)

3. **Start debugging:**

   - For server code: Press `<F5>` → Select server config
   - For client code: Start dev server, then `<F5>` → Select Chrome config

4. **Set breakpoints** with `<leader>b`

5. **Debug controls:**
   - `<F5>` - Continue
   - `<F1>` - Step Into
   - `<F2>` - Step Over
   - `<F3>` - Step Out
   - `<F7>` - Toggle Debug UI

---

## 📚 Need Help?

- **Server not starting?** Check console for errors: `:lua vim.notify("Check terminal output")`
- **Breakpoints not hitting?** Verify source maps are enabled
- **Chrome not attaching?** Restart Chrome with `--remote-debugging-port=9222`
- **TypeScript paths broken?** Add `pathMapping` to your config

For more details, see the main `DEBUG_CONFIG_EXAMPLES.md` file.
