# 12 · Sessions and Workspace

> **Series:** Neovim 0 to Hero
> **Difficulty:** Intermediate — assumes familiarity with basic Neovim, LSP, and tmux concepts
> **Time:** ~75 minutes to read + exercises
> **Goal:** Build a complete, persistent, multi-project workspace stack using tmux, auto-session, remote-nvim, dadbod-ui, kubectl.nvim, and related tools

---

Welcome to one of the most practical tutorials in the series. If tutorials 01–11 were about learning to _use_ Neovim, this one is about learning to _live_ in it. There is a real difference.

Using Neovim means knowing your keymaps, understanding LSP, being able to navigate buffers. Living in Neovim means your editor is always exactly where you left it, your database connections are a keypress away, your Kubernetes cluster is browsable without leaving your editor, and spinning up a project takes under three seconds no matter how long ago you last touched it.

VSCode gives you a lot of this as a "batteries included" package. Neovim gives you something better: composable primitives that you can combine exactly the way your workflow demands. The cost is that you have to understand those primitives. The payoff is a workspace that no single IDE could replicate.

Let's build that workspace.

---

## 1. The Concept of "Workspace" — Neovim vs VSCode

### What VSCode Calls a Workspace

If you're coming from VSCode, you have a pretty clear idea of what a "workspace" is. It's a configuration file — typically a `.code-workspace` file — that bundles together:

- One or more root folders (so you can open multiple projects in a single window)
- Per-workspace settings (overriding user settings for this project)
- Recommended extensions list
- Task definitions
- Debug launch configurations

When you reopen a VSCode workspace, the editor restores your tabs, your file explorer shows the right folders, and your settings apply automatically. It's a coherent snapshot of "this project at the time I left."

VSCode workspaces also integrate seamlessly with the Remote SSH extension — you can save a workspace that points at a remote folder and reconnect to it later. There's project-level search, project-level git status, all inside one window.

This is genuinely convenient. It's also fundamentally limited: it's a single IDE's vision of what a workspace is, baked into the product. You can't add to it, extend it, or compose it with other tools.

### What Neovim Calls a Workspace (Hint: It Doesn't)

Neovim itself has no concept of "workspace." There is no built-in project file, no `.nvim-workspace` format, no out-of-the-box session management. The editor opens files. It closes them. That's the primitive.

This is not a weakness — it's a design philosophy. Unix tools do one thing well. Neovim edits text well. Everything else is handled by other tools that are themselves very good at their respective jobs.

The workspace _stack_ for a serious Neovim user looks like this:

```
+----------------------------------------------------------+
|                        YOUR BRAIN                        |
|     (knowing which project you're working on today)      |
+----------------------------------------------------------+
         |
         v
+----------------------------------------------------------+
|                         tmux                             |
|   Window/session manager — survives terminal close       |
|   Each project = one tmux session                        |
|   Ctrl+F sessionizer = fzf-powered project switcher      |
+----------------------------------------------------------+
         |
         v
+----------------------------------------------------------+
|                        Neovim                            |
|   The actual editor — buffers, windows, tabs             |
|   LSP, git, search, everything you've learned so far     |
+----------------------------------------------------------+
         |
         v
+----------------------------------------------------------+
|                     auto-session                         |
|   Persistence layer — saves and restores Neovim state    |
|   Per-directory: each project gets its own session file  |
|   Restores: buffers, splits, cursor positions, folds     |
+----------------------------------------------------------+
```

Each layer has a clear job. tmux manages _which project you're in_ and keeps that context alive even if your terminal dies. Neovim does the actual editing. auto-session ensures Neovim always resumes from exactly where you left off within a project.

### Why This Beats VSCode for Multi-Project Work

The practical difference becomes apparent once you're working on more than two or three projects simultaneously.

In VSCode: you have multiple windows open. Each window is one "workspace." Switching between them means clicking the taskbar, using an OS window switcher, or if you're clever, the `Ctrl+R` recent workspaces menu. Close a window and all your unsaved state is gone or prompted. If your computer restarts, you hope VSCode's session restore works (it usually does, but it's not guaranteed, and complex split layouts often don't survive).

In the Neovim stack: each project is a named tmux session. You can switch between projects with a two-keystroke command. Every session is independent — project-api might have windows for editing, running the server, and watching logs; project-frontend might have windows for editing and a dev server. Detach from tmux (or close your terminal, or even your SSH connection if you're on a remote machine) and everything persists. Reattach and you're back in exactly the same state, cursor positions and all, because auto-session did its job.

There's no equivalent of "detach from VSCode and reattach three hours later on a different machine with everything exactly as you left it." That capability alone is worth learning this stack.

---

## 2. The Workspace Stack in Detail

### How the Layers Interact

Understanding _how_ these layers interact is essential to using them correctly. Let's trace through what happens when you start working on a project.

**Starting fresh:**

1. You open a terminal. tmux is running (or you start it with `tmux`).
2. You press `Ctrl+F` to invoke the sessionizer script.
3. fzf pops up with a list of your project directories (found by `fd` or `find` scanning your `~/projects` and `~/work` directories).
4. You pick "my-api-project". The sessionizer checks: does a tmux session named "my-api-project" already exist?
5. It does not. The sessionizer creates a new tmux session named "my-api-project" with the working directory set to `~/projects/my-api-project`.
6. You're now in a tmux session with a shell open in your project directory.
7. You type `nvim` and press Enter. Neovim opens.
8. auto-session detects the current directory (`~/projects/my-api-project`), looks for a saved session file, finds none (first time), and Neovim opens to a clean state.
9. You open some files, create some splits, position your cursor.
10. When you exit Neovim (`:q` or closing all windows), auto-session saves the session automatically.
11. You detach from tmux (`prefix + d`). Your terminal closes. The session is suspended but alive.

**Coming back the next day:**

1. You open a terminal. tmux is running.
2. You press `Ctrl+F` again.
3. You pick "my-api-project" again. The sessionizer finds the existing tmux session and _switches_ to it.
4. You're back in your tmux session. If Neovim was open when you detached, it's still open (tmux preserved it). If you had exited Neovim, the shell is there.
5. You type `nvim` (or if Neovim was already running, you're just back in it).
6. auto-session detects the directory, finds the saved session file, and restores: all your buffers, all your splits, your cursor was at line 47 of `server.ts` — it's still at line 47 of `server.ts`.

This is seamless, repeatable, and completely invisible once you set it up. The tooling does the right thing without you thinking about it.

### The VSCode Equivalent (And Where It Falls Short)

The closest VSCode analogy:

- tmux session = a VSCode workspace window that you can background and resume
- auto-session = VSCode's built-in "restore windows on startup"
- The sessionizer = VSCode's "Open Recent" workspace list

The critical difference: VSCode workspace windows are _OS processes_. They die if you close them or if the OS kills them. tmux sessions are _virtual terminals_ managed by a server process. They survive terminal closes, SSH disconnections, and casual `Ctrl+C`s. This is architecturally a completely different reliability guarantee.

---

## 3. auto-session Deep Dive

### What auto-session Is

auto-session (https://github.com/rmagatti/auto-session) is a Neovim plugin that provides automatic session management. The idea is simple: when you exit Neovim, it saves a session file. When you open Neovim in the same directory later, it restores that session.

The "per-directory" aspect is the key insight. This isn't one global session — it's a separate session for every working directory. Your `~/projects/api` session is completely independent of your `~/projects/frontend` session. You never have to think about "saving" or "loading" the right session. The session that loads is always the one for the directory you're in.

### What Gets Saved

When auto-session saves a session, it writes a Vim session file (using Neovim's built-in `:mksession` command under the hood). This captures:

**Buffers:** Every buffer currently loaded in the session — open files, their paths, their content (or rather, the file path so they can be re-read on restore). If you had 12 files open across different splits, all 12 are recorded.

**Window Layout:** The exact arrangement of your splits. If you had a vertical split with `server.ts` on the left and `routes.ts` on the right, with a horizontal split below showing `package.json`, that exact layout is restored. Window sizes are preserved too.

**Cursor Positions:** For each buffer, the exact line and column where your cursor was. This is subtle but extremely useful — you don't have to remember which line you were editing, you're just _there_ when you restore.

**Folds:** If you had folds open or closed in a buffer, those fold states are saved. Useful if you regularly fold away certain sections of large files.

**Tab pages:** If you were using Neovim tabs (`:tabnew`), all tabs and their respective window layouts are saved.

**Jump list and marks:** Local marks (lowercase letters like `'a`, `'b`) within files are typically preserved because they're stored in the ShaDa file (Neovim's shared data file), not specifically in the session. But the session saves the buffer states that make those marks meaningful.

### What Does NOT Get Saved

There are things auto-session cannot or does not save:

**Terminal buffers:** If you had a terminal open inside Neovim (`:term`), it will not be restored. Terminals are processes — you can't serialize and deserialize a running shell process. On restore, that split will typically be absent or replaced with an empty buffer.

**Plugin-specific state:** Some plugins maintain their own state that isn't part of the Vim session format. For example, if you had a DAP (debugging) session running, the debug state won't be restored. If you had trouble.nvim open, it will close on exit and not reopen on session restore.

**Unsaved buffer content:** If you had a scratch buffer (`:enew`) with content you never saved to disk, that content is lost. Session files record buffer _paths_, not buffer _content_. If the path doesn't exist on disk, the buffer can't be restored.

**LSP state:** The Language Server Protocol connections are not part of the session file. When you restore a session and open a buffer, the LSP starts fresh. In practice this is fine — the LSP attaches to buffers automatically as they open, so you'll have full LSP functionality within a few seconds of restoring a session.

**Remote plugin state:** Things like nvim-remote or certain external processes Neovim was communicating with are not preserved.

Understanding these limitations helps you avoid surprises. The rule of thumb: if it's a file on disk, it restores perfectly. If it's a running process or in-memory state, it doesn't.

### The Keymaps: `<leader>wr` and `<leader>ws`

Your config provides two explicit session keymaps:

**`<leader>wr` — Restore session**

This manually triggers a session restore for the current directory. Use this when:

- You started Neovim with a specific file (`nvim README.md`) and want to then restore the full session
- The automatic restore didn't trigger for some reason
- You want to go back to a previously saved state (discarding changes to the session layout you've made since)

When you press `<leader>wr`, auto-session looks up the session file for the current directory and loads it. All currently open buffers close (you'll be prompted if there are unsaved changes), and the session's buffers and layout load in their place.

**`<leader>ws` — Save session manually**

This manually saves the current session state. Use this when:

- You've set up a particularly nice window layout that you want to make sure is preserved
- You're about to do something destructive to your layout and want a checkpoint
- Auto-save on exit is disabled in your config and you need to save explicitly

When you press `<leader>ws`, auto-session calls `:mksession!` with the appropriate session file path for the current directory. The `!` flag overwrites any existing session file.

### Auto-save on Exit Behavior

The most powerful feature of auto-session is that you rarely need `<leader>ws` at all. The plugin hooks into Neovim's `VimLeavePre` event — the event that fires right before Neovim exits — and automatically saves the session. This means:

- You never think about saving sessions
- Your session is always current as of your last exit
- The workflow is: open project → work → close Neovim → (session saves automatically) → later, open Neovim in same directory → (session restores automatically) → you're back

This "just works" quality is what makes auto-session feel magical rather than like a manual chore.

### Session Files Location and Naming

Sessions are stored in `~/.local/share/nvim/sessions/`. You can inspect this directory to see all your saved sessions:

```bash
ls ~/.local/share/nvim/sessions/
```

You'll see files with names that look like mangled paths:

```
%home%viavi%projects%my-api-project.vim
%home%viavi%projects%frontend-app.vim
%home%viavi%Desktop%workspaces%github%DreamEcho100%mfansible.vim
```

The naming convention is: take the absolute path of the directory, replace every `/` with `%`, and add `.vim` as the extension. So `/home/viavi/projects/my-api-project` becomes `%home%viavi%projects%my-api-project.vim`.

This means:

1. Each directory gets exactly one session file (no conflicts)
2. You can tell at a glance which project a session file belongs to
3. You can manually delete a session file if you want to start fresh: `rm ~/.local/share/nvim/sessions/%home%viavi%projects%my-api-project.vim`

The session files themselves are readable Vim script. You can open one to see what's inside:

```vim
" Session file generated by auto-session
" nvim version: 0.10.0

let SessionLoad = 1
silent! source /home/viavi/.config/nvim/init.lua

edit /home/viavi/projects/my-api-project/src/server.ts
vsplit
edit /home/viavi/projects/my-api-project/src/routes/users.ts
" ... (many more lines)
```

This readability is a nice property — if a session file gets corrupted or does something unexpected, you can open it, understand what it's doing, and edit it.

### Troubleshooting Broken Sessions

Sometimes a session file gets corrupted, or the files it references have been moved or deleted, or the layout it encodes causes an error on load. Symptoms include:

- Neovim shows errors on startup about "E212: Can't open file for writing" or "E484: Can't open file"
- Neovim opens with a weird layout of empty or `[No Name]` buffers
- Neovim hangs or crashes on startup in a particular directory

**Fix 1: Delete the session file**

```bash
# Find and delete the session for the current directory
# (adjust the path encoding as needed)
rm ~/.local/share/nvim/sessions/%home%viavi%projects%problematic-project.vim
```

**Fix 2: Use the :Autosession command**

auto-session provides a `:Autosession` command with subcommands:

```vim
:Autosession delete          " Delete the session for current directory
:Autosession search          " Open a picker to search/manage sessions
```

`:Autosession delete` removes the session file for the current directory and lets you start fresh. Next time you exit Neovim, a new (clean) session file will be created.

**Fix 3: Start Neovim with session restore disabled**

If a session file is so broken that Neovim can't even start, you can suppress auto-session:

```bash
NVIM_AUTO_SESSION_SUPPRESS_DIRS="~" nvim
```

Or, if your config exposes it, start with the `--noplugin` flag to skip all plugins entirely, delete the broken session file, and restart normally.

---

## 4. tmux as the Outer Layer

### Why tmux + Neovim Beats VSCode for Multi-Project Work

Let's be concrete about this. Suppose you're a backend developer working on:

1. A REST API (Node.js)
2. A Python data processing service
3. A React frontend
4. An infrastructure-as-code repo (Terraform/Ansible)

In VSCode, you'd have four windows open. Switching between them requires using the OS window switcher or taskbar. Each window is an independent OS process. If your machine hibernates and wakes up, some of those windows might lose their remote connections. Your RAM usage is significant — each window runs a full Electron instance.

In the tmux + Neovim stack:

- Four named tmux sessions: `api`, `data-service`, `frontend`, `infra`
- Switching between them: `Ctrl+F` → type a few letters of the project name → Enter. Under two seconds.
- Each session has its own windows and panes configured exactly for that project's workflow
- All sessions are persistent — they survive sleep/wake cycles, SSH drops, terminal closes
- RAM usage: four Neovim instances plus tmux, which is a fraction of four Electron windows

The workflow density difference is substantial. Professional developers who live in this stack report that context-switching between projects feels like switching tabs, not switching applications.

### Projects as tmux Sessions

The fundamental pattern: **one tmux session per project**. Name the session after the project. This is not a hard rule, but it's a very effective convention.

```
tmux sessions:
  * api           (3 windows)
    frontend      (2 windows)
    infra         (4 windows)
    data-service  (2 windows)
```

Each session maintains its own window list. Windows within a session are numbered and named:

```
api session:
  [0] nvim     -- the editor, Neovim running here
  [1] server   -- `npm run dev` running here
  [2] logs     -- `tail -f logs/app.log` or similar
```

When you switch to the `api` session, you're back in whichever window you were last in. Press `prefix + 0` to jump to the nvim window, `prefix + 1` to jump to the running server, `prefix + 2` for logs.

### Ctrl+F — The Sessionizer

The sessionizer is a shell script (commonly attributed to ThePrimeagen's dotfiles, which your config adopts) that combines `fd`/`find`, `fzf`, and tmux to create a lightning-fast project switcher.

When you press `Ctrl+F` in your terminal:

1. A script runs that searches your designated project directories for Git repositories or project folders
2. `fzf` shows a fuzzy-findable list of all found directories
3. You type a few characters to narrow the list, press Enter to select
4. The script checks if a tmux session exists for that directory
5. If yes: switch to it
6. If no: create a new session with that directory as the working directory, then switch to it

Let's look at a typical sessionizer script step by step:

```bash
#!/usr/bin/env bash

# Step 1: Find candidate directories
# fd: fast file finder (like find, but faster and friendlier)
# -t d: only directories
# -d 1: max depth 1 (immediate children of each search root)
# We search multiple "project roots" and combine results
selected=$(
  { fd -t d -d 1 . ~/projects 2>/dev/null;
    fd -t d -d 1 . ~/work 2>/dev/null;
    fd -t d -d 1 . ~/Desktop/workspaces 2>/dev/null; }
  | fzf --prompt="  Project: " \
        --height=50% \
        --layout=reverse \
        --border \
        --preview="ls -la {}" \
        --preview-window=right:40%
)

# Step 2: If the user pressed Esc/Ctrl+C, fzf returns nothing — bail out
if [[ -z $selected ]]; then
  exit 0
fi

# Step 3: Derive a tmux session name from the directory path
# basename gives us just the final component: /home/user/projects/my-api -> my-api
# tr replaces dots with underscores (tmux doesn't like dots in session names)
session_name=$(basename "$selected" | tr '.' '_')

# Step 4: Check if we're already inside tmux
# $TMUX is set when running inside a tmux session
if [[ -z $TMUX ]]; then
  # Not in tmux: create or attach to the session
  tmux new-session -A -s "$session_name" -c "$selected"
else
  # Already in tmux: check if session exists
  tmux_running=$(pgrep tmux)
  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    # Session doesn't exist: create it (detached), then switch to it
    tmux new-session -ds "$session_name" -c "$selected"
  fi
  # Switch to the session
  tmux switch-client -t "$session_name"
fi
```

This is elegant in its simplicity. The script has no configuration file, no complex state. It discovers projects dynamically by searching the filesystem. The session name is derived from the directory name. The tmux operations are idempotent — creating a session that already exists is handled gracefully.

**Customizing the sessionizer:** You can add more search paths to the `fd` calls. If you also want to search `~/open-source` and `~/clients`, add those lines. You can also swap `fd` for plain `find` if fd isn't installed:

```bash
# With plain find (slower but always available):
find ~/projects -mindepth 1 -maxdepth 1 -type d 2>/dev/null
```

### Window Layout Patterns

Within a tmux session, the window layout should match your project's workflow. Here are patterns that work well:

**Standard backend service:**

```
Session: my-api
+-----------+
| [0] nvim  |   Neovim running, full screen, editing code
+-----------+
| [1] dev   |   Development server: npm run dev / python main.py
+-----------+
| [2] test  |   Test watcher: npm test --watch / pytest --watch
+-----------+
```

**Frontend project:**

```
Session: my-frontend
+------------------+
| [0] nvim         |   Neovim, editing TypeScript/React
+------------------+
| [1] vite         |   Vite dev server: npm run dev
+------------------+
| [2] typecheck    |   tsc --watch for type errors
+------------------+
```

**Full-stack project with database:**

```
Session: fullstack
+------------------+
| [0] nvim         |   Neovim - main editing
+------------------+
| [1] api          |   API server
+------------------+
| [2] db           |   Database shell (psql / mongosh)
+------------------+
| [3] workers      |   Background workers / queues
+------------------+
```

### Panes Within Windows

Windows can be split into panes. A common pattern for the editor window is a main Neovim pane plus a small terminal pane for quick commands:

```
+------------------------------------------+
|                                          |
|                                          |
|            NEOVIM (large pane)           |
|                                          |
|                                          |
+------------------------------------------+
| small terminal pane (git, npm install)   |
+------------------------------------------+
```

Create this layout:

```bash
# In the nvim window, split horizontally with a small bottom pane
tmux split-window -v -l 20%   # 20% of height for the bottom pane
tmux select-pane -t 0          # Go back to the main pane
nvim                           # Launch Neovim in the main pane
```

Navigate between panes: `prefix + arrow key` or `prefix + hjkl` (if configured).

### Detach and Reattach — Sessions Survive Terminal Closes

This is the superpower that no IDE can match. When you close your terminal emulator (or your SSH connection drops), tmux sessions keep running in the background as long as the tmux server process is alive.

```bash
# Detach from current session (everything keeps running)
prefix + d

# List all running sessions
tmux ls
# Output:
# api: 3 windows (created Mon Jun 10 09:15:32 2026) [213x53] (attached)
# frontend: 2 windows (created Mon Jun 10 08:45:01 2026) [213x53]
# infra: 4 windows (created Fri Jun  7 14:22:18 2026) [213x53]

# Reattach to a specific session
tmux attach -t api
# or the short form:
tmux a -t api

# The sessionizer handles this automatically — Ctrl+F to switch
```

A common workflow: start work sessions Monday morning, detach Friday evening. The sessions are still there Monday morning. Your Neovim sessions restored exactly where you left them Friday via auto-session. Your long-running processes (build watchers, test runners) were preserved in their tmux windows.

### tmux Cheatsheet

All tmux commands use a "prefix key" — a special key combination you press before the actual command. The default prefix is `Ctrl+B`. Many users remap it to `Ctrl+A` (screen-style) or `Ctrl+Space`.

```
PREFIX = Ctrl+B (default)

=== Sessions ===
prefix + d          Detach from current session
prefix + s          List sessions (interactive selector)
prefix + $          Rename current session
tmux new -s NAME    Create new named session
tmux ls             List all sessions
tmux a -t NAME      Attach to named session
tmux kill-ses -t N  Kill a session

=== Windows (like tabs) ===
prefix + c          Create new window
prefix + ,          Rename current window
prefix + n          Next window
prefix + p          Previous window
prefix + 0-9        Jump to window by number
prefix + w          List windows (interactive)
prefix + &          Kill current window (with confirmation)

=== Panes (splits within a window) ===
prefix + %          Split vertically (left/right panes)
prefix + "          Split horizontally (top/bottom panes)
prefix + arrow      Navigate to pane in direction
prefix + z          Toggle zoom (maximize/restore current pane)
prefix + {          Move pane left
prefix + }          Move pane right
prefix + x          Kill current pane (with confirmation)
prefix + !          Move pane to its own window

=== Copy mode (scrolling) ===
prefix + [          Enter copy mode (use vim keys to navigate)
q                   Exit copy mode
Space               Start selection (in vim copy mode)
Enter               Copy selection

=== Misc ===
prefix + :          Open tmux command prompt
prefix + ?          Show all keybindings
prefix + t          Show a clock (yes, this exists)
```

### VSCode Comparison: No Equivalent

To reiterate: there is no VSCode equivalent to tmux sessions. The closest thing is having multiple VSCode windows open and using `Ctrl+R` to switch between recent workspaces. But:

1. VSCode windows are OS processes — they consume memory even when not focused
2. Closing a VSCode window ends its process (unless you have session restore enabled, which is unreliable for complex layouts)
3. There is no "background the project but keep it running" concept
4. Switching speed: `Ctrl+R` in VSCode is fast, but it relaunches the window; the sessionizer switches instantly because the session is already running

The tmux + sessionizer approach is categorically different, not just slightly better.

---

## 5. remote-nvim — SSH Development

### The Problem It Solves

Remote development is one of the most practically important scenarios in modern software engineering. You might need to:

- Edit files on a remote server (staging, production emergency, cloud dev machine)
- Work on a codebase that only runs on Linux when you're on a Mac
- Use a powerful remote machine for heavy compilation while your laptop is underpowered
- Edit files on a Raspberry Pi, embedded device, or VM

The traditional approach: `ssh user@host` and then edit with whatever vim/nano is on the remote machine. This is terrible. The remote machine's vim has no configuration, no plugins, no LSP, no treesitter highlighting. It's a stripped-down editing experience that feels like going back to 1995.

VSCode solves this elegantly with the Remote SSH extension: your local VSCode instance connects to the remote machine over SSH, runs a VS Code Server there, and you get your full local VSCode experience (extensions, settings, everything) while editing remote files. It's one of VSCode's killer features.

remote-nvim does the same thing for Neovim. It copies your local Neovim configuration to the remote machine, starts a Neovim server there, and connects your local terminal's Neovim client to it. You get your full local configuration — LSP, plugins, keymaps, everything — while editing files that live on the remote machine.

### :RemoteStart ssh://user@host

Your config exposes the `:RemoteStart` command. The basic usage:

```vim
:RemoteStart ssh://username@hostname
:RemoteStart ssh://deploy@staging.myapp.com
:RemoteStart ssh://ubuntu@10.0.1.45
:RemoteStart ssh://ubuntu@10.0.1.45:2222   " Non-standard SSH port
```

**What happens when you run this:**

1. remote-nvim connects to the remote host via SSH (using your system SSH configuration, including `~/.ssh/config` entries, identity files, etc.)
2. It checks if Neovim is installed on the remote. If not, it downloads and installs it.
3. It copies your local Neovim configuration (`~/.config/nvim/`) to the remote machine under a temporary or persistent path.
4. It installs plugin dependencies on the remote (lazy.nvim will bootstrap on the remote just like it does locally).
5. It starts a Neovim server process on the remote.
6. Your local Neovim connects to that server and presents it in your current terminal.

From your perspective, you're just editing normally — but `:pwd` will show a path on the remote machine, and files you save are saved remotely.

### Supported Connection Types

remote-nvim supports:

- **ssh://user@host** — standard SSH connection
- **ssh://user@host:port** — SSH on non-standard port
- SSH config aliases — if your `~/.ssh/config` has a `Host` entry, you can use that alias: `ssh://my-dev-machine`

Your `~/.ssh/config` integration is particularly useful:

```ssh-config
# ~/.ssh/config
Host staging
    HostName staging.myapp.com
    User deploy
    IdentityFile ~/.ssh/staging_key
    Port 22

Host dev-machine
    HostName 192.168.1.100
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
```

With this config, you can use:

```vim
:RemoteStart ssh://staging
:RemoteStart ssh://dev-machine
```

Much cleaner than typing the full connection string.

### First-Time Setup: SSH Key Configuration

remote-nvim works best with SSH key authentication (no password prompts interrupting the setup process). Set up SSH keys if you haven't:

```bash
# Generate a key pair (if you don't have one)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy your public key to the remote machine
ssh-copy-id username@hostname

# Test that password-less auth works
ssh username@hostname "echo 'SSH key auth working'"
```

If you need password authentication, remote-nvim will prompt you, but it's less smooth. Passphrase-protected keys work fine if your SSH agent is running:

```bash
# Start SSH agent and add your key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Performance Considerations

remote-nvim's performance profile is different from local editing:

**Local operations (fast, no network latency):**

- Cursor movement
- Keymap processing
- Local plugin computations
- Anything that doesn't require reading/writing a file

**Remote operations (subject to network latency):**

- File reads and writes
- LSP operations (the LSP server runs on the remote and communicates back)
- File system searches (telescope find_files, grep)
- Any plugin that makes syscalls

On a low-latency connection (LAN, fast cloud region), remote-nvim is essentially indistinguishable from local editing. On a high-latency connection (intercontinental, VPN with overhead), you'll notice delays when saving files or during LSP responses.

A practical tip: if you're doing heavy editing on a slow connection, work in a tmux session on the remote machine with a local terminal (plain SSH), and only use remote-nvim when the connection quality is good enough.

### Comparison to VSCode Remote SSH

The conceptual similarity is high. Both approaches:

- Copy/run server-side components on the remote
- Provide your full local editor experience while editing remote files
- Use SSH as the transport

Key differences:

| Aspect                  | VSCode Remote SSH                          | remote-nvim                                    |
| ----------------------- | ------------------------------------------ | ---------------------------------------------- |
| Transport               | SSH + custom VS Code protocol              | SSH + Neovim RPC                               |
| First-run time          | Several minutes (downloads VS Code Server) | Minutes (copies nvim config, installs plugins) |
| Ongoing startup         | Seconds (server already installed)         | Seconds (server already configured)            |
| Config sync             | VS Code settings sync                      | Copies your local nvim config                  |
| Extension availability  | Most extensions work                       | All Neovim plugins work                        |
| Bandwidth               | High (Electron-based protocol)             | Low (terminal + RPC)                           |
| Connectivity resilience | Poor (window breaks on disconnect)         | Good (session can be inside tmux on remote)    |

The bandwidth and connectivity resilience differences are significant for working over unreliable connections or with limited data plans.

### Troubleshooting SSH Connections

**"Connection refused" or timeout:**

```bash
# Test basic SSH connectivity first
ssh -v username@hostname

# Check if the port is open
nc -zv hostname 22

# If on a custom port:
ssh -p 2222 username@hostname
```

**"Remote Neovim not found" during first setup:**

- Ensure the remote machine has internet access for downloading Neovim
- Or manually install Neovim on the remote: `sudo apt install neovim` (for the version in apt) or download a release from GitHub
- remote-nvim needs Neovim 0.9+ on the remote for full functionality

**Plugin installation fails on remote:**

- The remote machine needs `git` installed
- Check that `~/.local/share/nvim/` is writable on the remote
- Some plugins have external dependencies (e.g., `ripgrep` for telescope) that need to be on the remote too

**Connection drops mid-session:**

- If you're working inside a tmux session on the remote, the session survives the disconnect
- Reconnect with `:RemoteStart` and reattach to the running session
- For maximum resilience: `ssh remote-host`, `tmux attach`, then start Neovim inside that tmux session (bypassing remote-nvim entirely for unstable connections)

---

## 6. Database UI with dadbod-ui

### What dadbod Is — And Why There Are Two Plugins

There's an important distinction to understand: **vim-dadbod** and **vim-dadbod-ui** are two separate plugins that work together.

**vim-dadbod** (by tpope) is the core database interface. It's a low-level plugin that lets you execute SQL queries against databases directly from Neovim. You put a connection string in `g:db` or in a buffer variable, write SQL in a buffer, and run it. The results appear in a new buffer. It's powerful but requires knowing the right incantations.

**vim-dadbod-ui** is a tree-view UI built on top of vim-dadbod. It gives you:

- A sidebar showing your configured database connections
- A tree browser for schemas, tables, and views
- An easy way to open query buffers for each database
- A history of executed queries
- An interface for saving and organizing queries

Think of vim-dadbod as the engine and vim-dadbod-ui as the dashboard.

### Supported Databases

dadbod's adapter system supports an extensive list of databases:

```
PostgreSQL    -- postgresql://user:pass@host:5432/dbname
MySQL         -- mysql://user:pass@host:3306/dbname
MariaDB       -- mysql://user:pass@host:3306/dbname  (same adapter)
SQLite        -- sqlite:///path/to/database.sqlite
MongoDB       -- mongodb://user:pass@host:27017/dbname
Redis         -- redis://user:pass@host:6379
Microsoft SQL -- sqlserver://user:pass@host:1433?database=dbname
Oracle        -- oracle://user:pass@host:1521/service
Cassandra     -- cassandra://user:pass@host:9042/keyspace
BigQuery      -- bigquery://project/dataset
DynamoDB      -- dynamodb://region
```

If your database is on the list, dadbod can talk to it. For each adapter, the underlying tool (psql, mysql, mongo, redis-cli, etc.) needs to be installed. dadbod shells out to these tools rather than implementing database protocols itself.

### `<leader>daplbu` — Toggle DBUI Panel

Your config maps `<leader>daplbu` to toggle the dadbod-ui sidebar. Press it once: the DBUI panel opens on the left side. Press it again: it closes.

When DBUI opens for the first time, you'll see something like:

```
DADBOD UI
  + Add connection
  > Connections
  > Saved queries
```

If you've added connections before, they'll be listed under "Connections":

```
DADBOD UI
  v Connections
    v postgresql (localhost:5432/myapp)
      v public
        > Tables
          users
          orders
          products
          sessions
        > Views
          active_users
        > Routines
    > mysql (localhost:3306/analytics)
  > Saved queries
```

Navigate the tree with `j`/`k`. Press `Enter` or `o` on a table to open a query buffer pre-populated to query that table.

### Setting Up Connections

**Method 1: Through the DBUI interface**

Press `<leader>daplbu` to open DBUI, then navigate to `+ Add connection` and press Enter. DBUI will prompt you for:

- A display name for the connection
- The connection URL

The URL format follows standard database URL conventions:

```
PostgreSQL:  postgresql://user:password@localhost:5432/database_name
MySQL:       mysql://user:password@localhost:3306/database_name
SQLite:      sqlite:///home/user/projects/myapp/dev.sqlite
MongoDB:     mongodb://user:password@localhost:27017/database_name
Redis:       redis://:password@localhost:6379
```

For SQLite, note the triple slash — two for the protocol separator, one for the absolute path. For a relative path in your project: `sqlite:///./dev.db` (the `./` makes it relative to the current directory when the query is executed).

**Method 2: Global configuration**

For databases you use regularly across multiple projects, you can configure connections in your Neovim config:

```lua
-- In your plugin config for dadbod-ui
vim.g.db_ui_save_location = vim.fn.stdpath('data') .. '/db_ui'
vim.g.dbs = {
  {
    name = 'local-postgres',
    url = 'postgresql://postgres:devpassword@localhost:5432/myapp_dev'
  },
  {
    name = 'local-mysql',
    url = 'mysql://root:devpassword@localhost:3306/analytics_dev'
  }
}
```

**Method 3: Per-project connection via environment variables**

For project-specific connections (especially with credentials that vary per environment):

```lua
-- In a .nvim.lua file in your project root (loaded by exrc or a plugin like neoconf)
vim.g.db_ui_env_variable_url = 'DATABASE_URL'
-- Then in your shell: export DATABASE_URL="postgresql://..."
```

This pattern integrates nicely with `.env` files. Use something like `dotenv.nvim` to load `.env` files automatically, and your database credentials are available without hardcoding them in your Neovim config.

### The UI: Database Tree, Table Browser, Query Execution

The DBUI panel uses a tree structure that mirrors your database schema:

```
v my-postgres (localhost/myapp)
  v public (schema)
    v Tables
      v users
        id          integer  NOT NULL  PRIMARY KEY
        email       varchar  NOT NULL
        created_at  timestamp
      v orders
        id          integer
        user_id     integer  FK→users.id
        total       decimal
      views
      routines
  > information_schema (schema)
```

When you navigate to a table and press Enter, DBUI opens a new buffer (or splits) with a pre-built query:

```sql
SELECT *
FROM "public"."users"
LIMIT 200
```

This buffer is a proper SQL buffer with syntax highlighting. You can edit the query as you see fit. To execute it: `<leader>S` (or check your dadbod-ui config for the execute keymap — it's typically mapped to something convenient).

### Running Queries

There are several ways to execute SQL in the dadbod ecosystem:

**From a DBUI-opened buffer:**
The buffer already has the correct connection associated. Press `<leader>S` (or your configured execute key) to run the current query. Results appear in a split below.

**From any .sql file:**
If you have a `.sql` file in your project (migrations, stored procedures, ad-hoc queries), you can associate it with a connection:

```vim
" Associate the current buffer with a connection
:DB g:dbs.local-postgres

" Or set the buffer-local database
:let b:db = 'postgresql://localhost/myapp_dev'
```

Then `<leader>S` executes the SQL under the cursor (or the visual selection).

**Inline from any buffer:**
vim-dadbod's power move — you can run SQL directly from a non-SQL buffer using a visual selection:

1. Write some SQL in any buffer (even a markdown file or a scratch buffer)
2. Visual-select the SQL text
3. Run `:DB postgresql://localhost/myapp_dev` with the selection

This is useful for quick one-off queries when you don't want to switch to the DBUI panel.

### Viewing Results

Query results appear in a "results buffer" — a read-only buffer showing the output in a formatted table:

```
+----+---------------------------+---------------------+
| id | email                     | created_at          |
+----+---------------------------+---------------------+
|  1 | alice@example.com         | 2024-01-15 09:30:00 |
|  2 | bob@example.com           | 2024-01-15 10:15:22 |
|  3 | charlie@example.com       | 2024-01-16 08:45:11 |
+----+---------------------------+---------------------+
3 rows in 0.045s
```

You can navigate this buffer like any Neovim buffer — search with `/`, copy cells, etc. The results buffer is temporary and gets replaced when you run another query.

For large result sets, the results are paginated. You can adjust `LIMIT` in the query or scroll through the results.

### Saving Queries as Files

DBUI lets you save queries for reuse. When you have a query buffer open that you want to keep:

1. Press the "save query" keymap (typically `<leader>W` in DBUI buffers)
2. DBUI prompts for a query name
3. The query is saved to `~/.local/share/nvim/db_ui/saved_queries/` (or wherever `g:db_ui_save_location` points)

Saved queries appear in the DBUI tree under the connection they belong to:

```
v my-postgres
  > Tables
  v Saved queries
    active_users_last_30_days.sql
    revenue_by_month.sql
    user_order_summary.sql
```

Navigate to a saved query and press Enter to open it in a buffer. You can edit and re-execute it. This is a lightweight but effective query library within your editor.

A better pattern for production use: keep your SQL files in your project directory alongside your code. Create a `queries/` or `sql/` directory in your project and track those files in git. Use dadbod to execute them, but let git manage versioning.

### Connection String Formats for Common Databases

Quick reference:

```
PostgreSQL:
  postgresql://user:password@host:5432/dbname
  postgres://user:password@host:5432/dbname  (alias)
  postgresql://user:password@host/dbname     (default port)
  postgresql://:@localhost/dbname            (no auth, local)

MySQL:
  mysql://user:password@host:3306/dbname
  mysql://root:@localhost:3306/mydb          (empty password)

SQLite:
  sqlite:///absolute/path/to/file.sqlite
  sqlite:///./relative/to/cwd/file.sqlite

MongoDB:
  mongodb://user:password@host:27017/dbname
  mongodb://localhost:27017/dbname           (no auth)
  mongodb+srv://user:pass@cluster.mongodb.net/dbname  (Atlas)

Redis:
  redis://localhost:6379
  redis://:password@localhost:6379
  redis://localhost:6379/0                   (database 0)

MSSQL:
  sqlserver://user:password@host:1433?database=dbname
```

**Security note:** Be careful about putting credentials in Neovim config files that get committed to git. Use environment variables, `.env` files excluded from git, or a secrets manager for anything other than local development credentials.

### VSCode Comparison

VSCode has several database clients as extensions:

- **Database Client** (Weijan Chen) — similar tree-browser UI, multi-database support
- **SQLTools** — popular, supports many databases, has a query runner
- **Prisma** extension — for Prisma-specific database browsing

dadbod-ui competes favorably:

- Faster to navigate (Vim keymaps vs mouse/click)
- Better integration with the rest of your workflow (run SQL from any buffer, visual selections work)
- Lighter weight (no Electron overhead for each database query)
- More customizable (it's Lua code, you can extend it)

The main VSCode advantage: a more polished out-of-the-box UI with less configuration required. dadbod-ui requires knowing the connection URL format and setting things up manually; VSCode database extensions often have GUI connection wizards.

---

## 7. kubectl.nvim — Kubernetes Management

### What kubectl.nvim Provides

kubectl.nvim brings Kubernetes resource management into Neovim. If you regularly work with Kubernetes clusters — checking pod status, reading logs, debugging deployments — this plugin lets you do all of that without leaving your editor or opening a separate terminal window.

The value proposition: when you're debugging a production issue, you don't want to context-switch between your editor (where you're reading code or reviewing configs) and a terminal running `kubectl` commands. kubectl.nvim puts both in the same environment, with the same navigation model, so you can move fluidly between "reading the code" and "checking what's actually running."

### Core Capabilities

**Resource browsing:**
kubectl.nvim provides a buffer-based interface for browsing Kubernetes resources:

```vim
:KubectlGet pods          " List all pods in current namespace
:KubectlGet deployments   " List deployments
:KubectlGet services      " List services
:KubectlGet namespaces    " List namespaces
:KubectlGet nodes         " List nodes
:KubectlGet configmaps    " List configmaps
:KubectlGet secrets       " List secrets (values redacted)
:KubectlGet ingresses     " List ingresses
```

The output is presented in a Neovim buffer with syntax highlighting. You can navigate it with standard Vim motion keys.

**Interactive resource listing:**

Rather than individual commands, kubectl.nvim typically provides a picker-style interface. Press the configured keymap to open the kubectl UI, which shows a list of resource types. Select one, and you get a live-updating list of resources of that type in the current namespace.

**Viewing pod logs:**

```vim
" In a pod listing buffer, place cursor on a pod and press:
" (keymap varies by config, commonly 'l' for logs)
" Opens a new buffer with streaming pod logs
```

This is equivalent to `kubectl logs -f pod-name --namespace ns-name` but without leaving Neovim or typing the pod name.

**Describing resources:**

```vim
" On any resource, press 'd' (or your configured describe key)
" Opens a buffer with the full 'kubectl describe' output
```

Seeing the full describe output inline while reading related code is significantly more efficient than copying pod names to a separate terminal.

**Exec into pods:**

```vim
" On a pod, press 'e' (or your configured exec key)
" Opens a terminal buffer with a shell in the pod
```

This opens a Neovim terminal buffer running `kubectl exec -it pod-name -- /bin/sh`. You're in the pod, in a Neovim terminal buffer, which you can navigate with Neovim's terminal mode.

### Context Switching

Working with multiple clusters (dev, staging, production) is where context management matters most. kubectl.nvim integrates with your kubectl context configuration:

```vim
:KubectlContext           " Show current context / switch context
```

This opens a picker of your configured contexts (from `~/.kube/config`). Switch contexts without leaving Neovim, without typing `kubectl config use-context prod-cluster` in a terminal.

A common and important workflow: set your context to production cluster, review a deployment's status, switch back to dev, make a code change, deploy to dev cluster. All without leaving Neovim.

**Safety note:** Having a convenient Kubernetes context switcher is a double-edged sword. It's easy to accidentally run a destructive command against production when you thought you were on dev. Consider:

- Using a read-only kubeconfig for production contexts
- Configuring different visual themes per context (some Neovim configs colorize the status bar differently per k8s context)
- Double-checking the current context before running any destructive kubectl operations

### When to Use kubectl.nvim vs Alternatives

```
kubectl.nvim        -- when coding and need to peek at cluster state
                       when reading logs alongside code
                       when you want keyboard-driven resource navigation

Terminal kubectl    -- for scriptable, complex operations
                       when you need shell pipelines: kubectl ... | jq | grep
                       for applying manifests: kubectl apply -f ...
                       for complex selectors and queries

k9s                 -- for dedicated Kubernetes debugging sessions
                       when you need a full-screen interactive cluster view
                       real-time resource monitoring with auto-refresh
                       when kubectl.nvim feels insufficient for the task

Lens (GUI)          -- for visual cluster dashboards
                       when sharing with non-terminal users
                       for resource metrics visualization
```

The pattern that works well: use kubectl.nvim for the quick checks you do while coding (is this pod running? what are the last few log lines?), and switch to a dedicated terminal with k9s for serious cluster debugging sessions.

### Setup Requirements

kubectl.nvim requires:

1. `kubectl` command available in your PATH and configured
2. A valid `~/.kube/config` file with cluster connections
3. The user running Neovim having appropriate RBAC permissions on the cluster

Test your setup:

```bash
# These should work before kubectl.nvim will work
kubectl cluster-info
kubectl get pods --all-namespaces
kubectl config current-context
```

If you're accessing multiple clusters, ensure all relevant cluster credentials are in your kubeconfig:

```bash
# Merge multiple kubeconfig files
export KUBECONFIG=~/.kube/config:~/.kube/dev-cluster.yaml:~/.kube/prod-cluster.yaml
kubectl config get-contexts   # Should show all contexts
```

---

## 8. conn-manager — Service Connection Management

### What conn-manager Is

conn-manager is a lighter-weight tool for managing connections to services — typically things like SSH tunnels, database connections, or other service endpoints that your project depends on. While dadbod-ui handles database querying and kubectl.nvim handles Kubernetes, conn-manager provides a more general "connect to this thing" abstraction.

The use case: your project has several external dependencies (a Redis instance, an API service, an SSH tunnel to a staging database). conn-manager gives you a way to manage those connections' lifecycle — start them, stop them, check their status — without leaving Neovim.

### Buffer-Local `t` and `.` Keys

Your config sets up buffer-local keymaps for conn-manager interactions. The `t` and `.` keys are scoped to specific buffer types (likely the conn-manager interface buffer):

- **`t`**: toggle a connection (connect if disconnected, disconnect if connected)
- **`.`**: run a command or action on the selected connection

These keys are "buffer-local" — they only work in the conn-manager buffer, not in your regular code editing buffers. This avoids conflicts with other plugins or your general keymaps.

### Setting Up Connections

Connections in conn-manager are typically configured as named connection profiles. A basic configuration might look like:

```lua
-- In your conn-manager config
require('conn-manager').setup({
  connections = {
    {
      name = 'staging-db-tunnel',
      type = 'ssh-tunnel',
      local_port = 15432,
      remote_host = 'staging.myapp.com',
      remote_port = 5432,
      ssh_host = 'bastion.myapp.com',
      ssh_user = 'tunnel',
    },
    {
      name = 'local-redis',
      type = 'command',
      start = 'docker start my-redis',
      stop = 'docker stop my-redis',
      healthcheck = 'redis-cli ping',
    },
  }
})
```

With this setup, you open the conn-manager panel, navigate to a connection, press `t` to toggle it. For the SSH tunnel, this starts an `ssh -L` command in the background. For the Redis container, it runs the docker command.

### Integration with dadbod-ui

A common pattern is to use conn-manager for SSH tunnels and then connect dadbod-ui to the tunneled local port:

1. Open conn-manager panel
2. Navigate to `staging-db-tunnel`
3. Press `t` to start the SSH tunnel (now listening on localhost:15432)
4. Open dadbod-ui (`<leader>daplbu`)
5. Connect to `postgresql://user:password@localhost:15432/staging_db`

You're querying the staging database through a secure SSH tunnel, managed entirely within Neovim. No separate terminal windows, no manual tunnel commands to remember.

---

## 9. kulala.nvim — REST Client (Cross-Reference to Tutorial 07)

### Brief Overview

kulala.nvim is your HTTP REST client, covered in depth in Tutorial 07. For workspace context, here's the one-line summary: it lets you write `.http` files (RFC 7230-compliant HTTP request format) and execute them directly from Neovim, displaying the response in a split buffer.

```http
### Get all users
GET https://api.myapp.com/users
Authorization: Bearer {{TOKEN}}
Content-Type: application/json

### Create user
POST https://api.myapp.com/users
Content-Type: application/json

{
  "name": "Alice",
  "email": "alice@example.com"
}
```

### How It Fits Into the Workspace

The workspace-level insight about kulala: **keep your `.http` files in your project repository**. This is a change from the VSCode + REST Client pattern where you might have a global workspace for API testing.

When your `.http` files live in the project:

- They're version-controlled alongside the code
- New team members get the API documentation as runnable examples
- API changes (new endpoints, changed request formats) are updated in the same commit as the code change
- The requests are "living documentation" — they always work because they're maintained

A recommended project structure:

```
my-api-project/
  src/
    routes/
      users.ts
      orders.ts
  http/                    ← HTTP request files
    auth.http              ← Authentication endpoints
    users.http             ← User endpoints
    orders.http            ← Order endpoints
    _env.local.json        ← Local environment variables (gitignored)
    _env.staging.json      ← Staging environment (gitignored, or public if no secrets)
  tests/
  README.md
```

With this structure, press `<leader>daplbu` to open your DB while editing `users.ts`, have your `users.http` open in a split, execute requests to test the API, and reference them as documentation. The entire API development workflow is within Neovim.

For environment variables in kulala (switching between local, staging, production):

```json
// _env.local.json
{
  "BASE_URL": "http://localhost:3000",
  "TOKEN": "dev-token-here"
}
```

```http
# users.http
@BASE_URL = {{BASE_URL}}

### Get all users
GET {{BASE_URL}}/users
Authorization: Bearer {{TOKEN}}
```

See Tutorial 07 for the complete kulala.nvim workflow including request chaining, response assertions, and environment management.

---

## 10. Power User Day Workflow — A Full Narrative

This section walks through a complete working day using the full workspace stack. No abstraction — this is what it actually looks like when everything is configured and running.

### Morning: Starting the Day

**7:45 AM.** You sit down at your terminal. tmux is your default shell startup — your terminal emulator is configured to run `tmux new-session -A -s main` on launch, so if no sessions exist it creates one, and if a "main" session exists it reattaches.

You're immediately in your tmux session. The status bar shows `api  frontend  infra  *main`. The asterisk means you're in "main." You don't want to work in main — you want to get back to the API project.

`Ctrl+F`. fzf opens, showing:

```
  /home/viavi/projects/api-service
  /home/viavi/projects/frontend-app
  /home/viavi/projects/ml-pipeline
  /home/viavi/projects/infra-k8s
  /home/viavi/Desktop/workspaces/github/DreamEcho100/mfansible
```

You type `api` — the list narrows to `api-service`. Enter.

**Three seconds have passed.** You are now in the `api-service` tmux session. The terminal shows a shell prompt in `/home/viavi/projects/api-service`. This session had Neovim open when you left yesterday.

Neovim was already open. Yesterday's last action was editing `src/routes/users.ts` at line 127. That buffer is displayed. Your vertical split shows `src/services/user.service.ts` on the right. The diagnostic highlights from LSP are already updating as the TypeScript language server reattaches to the open buffers.

**You haven't typed a single character yet.** You are exactly where you were yesterday. The accumulated context of yesterday's work — which files matter, which line you were debugging, what the layout was — is all preserved.

This is the payoff of the full stack. The startup cost of the day is zero.

### Morning: Diving Into Code

You're working on a user authentication bug. The issue: JWT tokens aren't being invalidated properly on logout. You've been working on this.

In your Neovim session, you have:

- Left split: `src/routes/auth.ts` — the route handler
- Right split: `src/services/auth.service.ts` — the service logic
- A horizontal split at the bottom showing `src/db/sessions.ts` — the database layer

Your LSP shows a warning on line 89 of `auth.service.ts` — a potential null dereference. You navigate there with `<leader>e` (which opens the diagnostics list), see the issue, and fix it.

You want to test this against a real database. You press `<leader>daplbu`. The dadbod-ui panel slides open on the left. You expand your `local-postgres` connection, navigate to the `sessions` table, and press Enter. A query buffer opens:

```sql
SELECT *
FROM "public"."sessions"
WHERE user_id = 42
LIMIT 200
```

You modify it to check what's in the invalidated sessions:

```sql
SELECT id, user_id, token, invalidated_at, created_at
FROM "public"."sessions"
WHERE user_id = 42
AND invalidated_at IS NULL
ORDER BY created_at DESC
LIMIT 20
```

Execute it. Two sessions come back — both should have been invalidated on logout. You've confirmed the bug. Close dadbod-ui (`<leader>daplbu` again).

You have the `.http` file open in another window:

```http
### Logout user 42
POST http://localhost:3000/api/v1/auth/logout
Authorization: Bearer {{USER_42_TOKEN}}
Content-Type: application/json
```

You execute this (cursor on the request, your kulala keymap). Response: `200 OK`. Go back to dadbod-ui, re-run the query. Still two sessions, neither invalidated. The bug is confirmed and you can now fix it.

### Midday: Checking the Cluster

The API needs to be deployed to the staging cluster for QA. First you want to check that the previous deployment isn't still rolling out.

You switch to the `infra` tmux window in this session (`prefix + 2` — window 2 is your infra/deployment work area). Or better: you stay in Neovim and use kubectl.nvim.

```vim
:KubectlGet deployments
```

A buffer opens showing the staging namespace deployments:

```
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
api-service         3/3     3            3           2d
frontend-app        2/2     2            2           5d
ml-pipeline         1/1     1            1           1d
worker-service      4/4     4            4           3d
```

All good. You switch context to staging and apply the new deployment — or rather, you switch to your tmux terminal window and run the deployment command (some things are better done in a proper terminal). `prefix + 2` switches to window 2 where a shell is running. You run your deployment script. Switch back to window 0 (Neovim) with `prefix + 0`.

### Afternoon: Remote Debugging

QA found a bug on staging that doesn't reproduce locally. The staging server is `staging.myapp.com`. You need to look at the actual logs and potentially some files that differ between environments.

```vim
:RemoteStart ssh://deploy@staging.myapp.com
```

remote-nvim connects. After the initial setup (a minute or so the first time), you're editing files on the staging server with your full local Neovim config. TypeScript LSP is running on the remote, giving you diagnostics on the staging version of the code.

You open the log files:

```vim
:e /var/log/myapp/app.log
```

Navigate to the error section with `/ERROR`. Read the stack trace. The issue is a missing environment variable — `REDIS_URL` isn't set in staging but is set locally.

Switch back to local (disconnect remote-nvim), find the deployment configuration in your infra repo, add the missing variable, redeploy. Bug fixed.

### Late Afternoon: Everything Converges

You have the following windows/buffers open:

- `auth.service.ts` — the file you fixed this morning
- `sessions` query buffer in dadbod-ui context
- `auth.http` — the HTTP test requests
- `src/middleware/auth.ts` — discovered a related issue

All four are visible in your Neovim session. The LSP is green on all of them. You run your test suite from within Neovim (tutorial 11 covers this), all tests pass.

### Evening: Shutting Down

You've been working for 9 hours. Time to stop.

You don't need to do anything special. Closing Neovim (`:qa`) triggers auto-session to save the current state. The exact buffer layout — four files with their specific split arrangement, the cursor positions in each — is written to the session file.

You detach from tmux: `prefix + d`. Your terminal closes. The tmux server keeps running.

Tomorrow morning: `Ctrl+F`, type `api`, Enter. You're back at line 89 of `auth.service.ts`. The diagnostic you haven't fixed yet is still highlighted. Your dadbod-ui connections are remembered. Everything is exactly as you left it.

**Total time spent on "project management" today:** about 15 seconds (the sessionizer switch in the morning). Every minute of productive time was spent on actual work, not managing your editor state.

---

## 11. Workspace Patterns with Detailed Examples

### Pattern 1: The Mono-Repo

A mono-repo contains multiple packages in a single git repository. A typical structure:

```
my-mono-repo/
  packages/
    api/          ← Node.js API
    frontend/     ← React app
    shared/       ← Shared TypeScript types
    worker/       ← Background job processor
  infrastructure/
    terraform/
    k8s/
  scripts/
  package.json    ← Root workspace config
```

**Recommended tmux layout for a mono-repo:**

```
tmux session: mono-repo

Window 0: nvim
  Split arrangement:
    Left: current working package (e.g., packages/api/src/routes/users.ts)
    Right: related test file (packages/api/src/routes/__tests__/users.test.ts)
    Bottom: shared types reference (packages/shared/src/types/user.ts)

Window 1: api-server
  Running: cd packages/api && npm run dev

Window 2: frontend
  Running: cd packages/frontend && npm run dev

Window 3: test-watcher
  Running: npm test --watch --filter=@myapp/api

Window 4: root-commands
  Shell: for npm workspace commands, git operations, etc.
```

**auto-session consideration:** Since all packages are in one directory (`my-mono-repo/`), auto-session saves a single session for the whole mono-repo. This works well — you'll restore to whatever cross-package view you had last.

**Neovim-specific tip:** Use `:lcd` (local change directory) per window to set the working directory for a specific split to a sub-package. This makes telescope and LSP operations scoped to that package:

```vim
" In the left split showing API code:
:lcd packages/api

" Now <leader>ff (find files) only searches packages/api/**
" LSP is already scoped by the root tsconfig.json, but :lcd helps with file navigation
```

### Pattern 2: Multi-Service Pattern

You're working on a microservices system. Each service is its own repository:

```
~/projects/
  auth-service/      ← Handles user authentication
  api-gateway/       ← Routes and rate limiting
  user-service/      ← User profile management
  notification-svc/  ← Email/SMS notifications
  frontend/          ← The web application
```

**Recommended tmux layout:**

Each service gets its own tmux session. The sessionizer handles this naturally:

```
tmux sessions:
  auth-service     -- developing the current auth bug fix
  api-gateway      -- monitoring after a config change
  frontend         -- ongoing feature development
  (user-service is not active today, no session)
```

Within each session, the window layout is service-specific:

```
Session: auth-service (windows)
  [0] nvim    -- editing src/
  [1] server  -- npm run dev
  [2] tests   -- npm test --watch

Session: api-gateway (windows)
  [0] nvim    -- editing config/ and src/
  [1] server  -- running gateway
  [2] logs    -- tail -f logs/gateway.log
```

**Cross-service navigation:** When you need to check the auth-service's API interface while working in api-gateway, the flow is:

1. `Ctrl+F` → type `auth` → Enter → switch to auth-service session
2. Check what you need
3. `Ctrl+F` → type `gateway` → Enter → back to api-gateway

**Shared tooling:** dadbod-ui connections can be configured globally (in your Neovim config) so they're available in all sessions. The `users` database is accessible from both the `auth-service` session and the `user-service` session without any per-session setup.

### Pattern 3: API + DB + Tests Pattern

This is the pattern for intensive feature development where you're working on a feature that touches the API layer, database, and tests simultaneously.

```
┌─────────────────────────────────────────────────────────────┐
│ WINDOW 0: nvim (main editor)                                │
│                                                             │
│ ┌───────────────────┬───────────────────┐                  │
│ │                   │                   │                  │
│ │  users.route.ts   │  user.service.ts  │                  │
│ │   (route layer)   │  (business logic) │                  │
│ │                   │                   │                  │
│ │                   │                   │                  │
│ │                   │                   │                  │
│ └───────────────────┴───────────────────┘                  │
│ ┌─────────────────────────────────────────┐                │
│ │  users.test.ts (test file — bottom)     │                │
│ └─────────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ WINDOW 1: dadbod-ui panel + query buffer                    │
│                                                             │
│ ┌────────────┬────────────────────────────────────────┐    │
│ │ DADBOD UI  │  Query Buffer                          │    │
│ │            │                                        │    │
│ │ v postgres │  SELECT u.*, COUNT(o.id) as order_cnt  │    │
│ │   > users  │  FROM users u                          │    │
│ │   > orders │  LEFT JOIN orders o ON o.user_id = u.id│    │
│ │   > ...    │  GROUP BY u.id                         │    │
│ │            │  LIMIT 50;                             │    │
│ └────────────┴────────────────────────────────────────┘    │
│ ┌─────────────────────────────────────────────────────┐    │
│ │  Results: 47 rows in 0.023s                         │    │
│ │  +----+------------------+------------+             │    │
│ │  | id | email            | order_cnt  |             │    │
│ │  +----+------------------+------------+             │    │
│ │  |  1 | alice@...        |         5  |             │    │
│ └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ WINDOW 2: test runner + HTTP client                         │
│                                                             │
│ ┌───────────────────────────────────────────────────┐      │
│ │  vitest --watch                                   │      │
│ │                                                   │      │
│ │  ✓ GET /users returns paginated list              │      │
│ │  ✓ GET /users/:id returns user                    │      │
│ │  ✗ POST /users creates user and returns 201       │      │
│ │    AssertionError: expected 200 to equal 201      │      │
│ └───────────────────────────────────────────────────┘      │
│ ┌───────────────────────────────────────────────────┐      │
│ │  users.http (kulala buffer)                       │      │
│ │                                                   │      │
│ │  ### Create user                                  │      │
│ │  POST http://localhost:3000/api/users             │      │
│ │  Content-Type: application/json                   │      │
│ │  {"name": "Test", "email": "test@test.com"}       │      │
│ └───────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

This three-window layout puts every relevant tool one `prefix + number` away:

- Window 0: the code you're writing
- Window 1: the database showing you real data
- Window 2: the test runner and HTTP client confirming your behavior

**The tight feedback loop:**

1. Edit the route handler in window 0
2. Switch to window 2 — test runner shows failure
3. Debug by switching to window 1 — check the actual DB state
4. Fix the code in window 0
5. Window 2 test runner automatically re-runs and goes green

This loop, with all tools in the same environment with the same navigation model, is significantly more efficient than switching between IDE, database GUI, and terminal tabs.

### Pattern 4: The Remote + Local Hybrid

Sometimes you're working on something that requires both local and remote access:

```
Local machine: ~/projects/my-service/ (the codebase)
Remote staging: staging.myapp.com (where it runs)
```

**Setup:**

```
tmux session: my-service

Window 0: nvim (local)
  - Editing local code with full LSP

Window 1: local-server
  - Running local dev server

Window 2: remote (SSH into staging)
  - `ssh deploy@staging.myapp.com`
  - tmux inside (nested tmux or using different prefix)
  - Can run remote commands here

Window 3: logs
  - `ssh deploy@staging.myapp.com 'tail -f /var/log/app/app.log'`
  - Live staging logs in a local window
```

Alternatively, for serious remote editing:

```
Window 0: remote-nvim
  - :RemoteStart ssh://deploy@staging.myapp.com
  - Editing remote files with local config

Window 1: remote-shell
  - Plain SSH terminal: ssh deploy@staging.myapp.com
  - For running remote commands, restarting services
```

This hybrid lets you compare local and remote code side by side (switch between windows 0 for local Neovim and the remote-nvim instance) while having a plain shell for remote administrative tasks.

---

## 12. Exercises

### Exercise 1: Build Your Full Session Stack

**Objective:** Set up and validate the complete tmux + auto-session workflow for two of your real projects.

**Steps:**

1. Ensure the sessionizer script is installed and `Ctrl+F` is bound to it. Test it by pressing `Ctrl+F` in your terminal.

2. Pick two real projects. Press `Ctrl+F` and navigate to the first project. You should be in a new tmux session named after that directory.

3. Open Neovim in that project. Open several files across multiple splits. Arrange a layout that would be useful for this project. Leave your cursor at a specific line in a specific file.

4. Exit Neovim (`:qa`). A session should have been saved automatically. Confirm by checking:

   ```bash
   ls ~/.local/share/nvim/sessions/
   ```

   You should see a new `.vim` file corresponding to this project's path.

5. Without closing the tmux session, type `nvim` again. Did auto-session restore your layout and cursor position?

6. Now detach from the tmux session (`prefix + d`). Open a new terminal (or new tmux window in a different session). Press `Ctrl+F` and select the same project. You should be back in the existing session.

7. Repeat steps 3–6 for your second project.

**Success criteria:**

- Both projects have their own, independent session files
- Switching between them via `Ctrl+F` takes under 3 seconds
- Neovim restores your last layout perfectly on each re-entry

**Bonus:** Create a third "scratch" tmux session (`tmux new -s scratch`) and notice that it has no associated Neovim session. Exit Neovim in this session and check that a session file was created in `~/.local/share/nvim/sessions/` for whatever directory you were in.

---

### Exercise 2: Database Integration with dadbod-ui

**Objective:** Connect to a real (or local development) database and execute a meaningful query without leaving Neovim.

**Prerequisites:** A running database instance. If you don't have one, you can spin up a SQLite database for this exercise (no server required):

```bash
# Create a SQLite database for the exercise
sqlite3 ~/exercise_db.sqlite <<'SQL'
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES
  ('Alice Johnson', 'alice@example.com'),
  ('Bob Smith', 'bob@example.com'),
  ('Carol White', 'carol@example.com'),
  ('Dave Brown', 'dave@example.com'),
  ('Eve Davis', 'eve@example.com');

CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES users(id),
  amount DECIMAL(10,2) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO orders (user_id, amount) VALUES
  (1, 49.99), (1, 129.00), (2, 79.99),
  (3, 249.99), (3, 19.99), (3, 89.00),
  (4, 59.99), (5, 199.99), (5, 39.99);
SQL
```

**Steps:**

1. Open Neovim in any directory.

2. Press `<leader>daplbu` to open the DBUI panel.

3. Add a new connection. For SQLite, the URL is:

   ```
   sqlite:///home/YOUR_USERNAME/exercise_db.sqlite
   ```

   (replace `YOUR_USERNAME` with your actual username)

4. Expand the connection tree. You should see the `users` and `orders` tables.

5. Click on (navigate to) the `users` table and press Enter. A query buffer opens. Execute the default `SELECT * FROM users LIMIT 200` query. Verify that your 5 users appear.

6. Edit the query to find users who have placed more than 2 orders:

   ```sql
   SELECT u.name, u.email, COUNT(o.id) as order_count
   FROM users u
   JOIN orders o ON o.user_id = u.id
   GROUP BY u.id, u.name, u.email
   HAVING COUNT(o.id) > 2
   ORDER BY order_count DESC
   ```

   Execute it. Carol (3 orders) should appear.

7. Save this query: press the save query keymap and name it `users_with_multiple_orders`.

8. Close and reopen DBUI. Verify your saved query appears and can be opened and re-executed.

**Success criteria:**

- You connected to the database through Neovim
- You can navigate the schema tree
- You executed a non-trivial SQL query
- You saved a query for later use

---

### Exercise 3: Remote Development with remote-nvim

**Objective:** Edit a file on a remote machine using your local Neovim configuration.

**Prerequisites:** SSH access to a remote Linux/macOS machine. If you don't have a remote server, you can use a local VM or Docker container with an SSH server, or skip to the "simulation" variant.

**Full exercise (with SSH access):**

1. Ensure SSH key authentication works:

   ```bash
   ssh -o PasswordAuthentication=no user@your-remote-host "echo 'Key auth OK'"
   ```

   If this fails, set up SSH keys (see section 5 above).

2. In Neovim, run:

   ```vim
   :RemoteStart ssh://user@your-remote-host
   ```

3. Wait for the initial setup to complete (first time will take a minute).

4. Once connected, run `:pwd` — it should show a path on the remote machine.

5. Navigate to a text file on the remote machine and make a small edit. Save it.

6. In a separate terminal, SSH to the remote manually and verify your edit is there:

   ```bash
   ssh user@your-remote-host "cat /path/to/the/file/you/edited"
   ```

7. Check that LSP is working: if the remote machine has your project's language tools installed, you should see LSP diagnostics. If not, install the relevant LSP server on the remote.

**Simulation variant (no remote server):**

Use a local Docker container as the "remote":

```bash
# Start an SSH-able container
docker run -d \
  --name remote-nvim-test \
  -p 2222:22 \
  -e "AUTHORIZED_KEYS=$(cat ~/.ssh/id_rsa.pub)" \
  lscr.io/linuxserver/openssh-server:latest

# Wait 10 seconds for it to start
sleep 10

# Test SSH access
ssh -p 2222 -o StrictHostKeyChecking=no linuxserver@localhost "echo 'Connected'"

# In Neovim:
# :RemoteStart ssh://linuxserver@localhost:2222
```

**Success criteria:**

- You edited a file on a remote machine from your local Neovim instance
- Your local keymaps, themes, and at minimum syntax highlighting were present
- The file change persisted on the remote machine

---

### Exercise 4: Design Your Workspace Layout

**Objective:** Think through and implement your personal workspace layout for your most complex project.

This is a design exercise as much as a technical one. The goal is to think carefully about your workflow and build a tmux + Neovim layout that serves it.

**Step 1: Audit your current workflow**

Write down (on paper or in a scratch file) answers to:

- How many projects are you actively working on at once?
- For your most complex project: what external services does it depend on? (databases, APIs, queues, etc.)
- How often do you run tests while coding?
- Do you need remote server access regularly?
- Do you work with Kubernetes clusters?

**Step 2: Design your tmux window layout**

For your most complex project, design a tmux session layout:

```
Session: [your-project-name]

Window 0: [name]  -- [purpose]
Window 1: [name]  -- [purpose]
Window 2: [name]  -- [purpose]
(add more if needed)
```

For each window involving Neovim, design the split layout:

```
Window 0 layout:
+--[file you usually have open]--+--[file you usually have open]--+
|                                |                                |
|  (left split: X lines tall)    |  (right split: X lines tall)  |
|                                |                                |
+--------------------------------+--------------------------------+
|       (bottom split if any: purpose)                           |
+----------------------------------------------------------------+
```

**Step 3: Implement it**

1. Press `Ctrl+F` to create/switch to a session for your project.
2. Create the windows you designed: `prefix + c` for each new window, `prefix + ,` to name them.
3. Open Neovim in window 0. Create the split layout you designed. Open the files you designed.
4. In other windows, start the processes you need (dev server, test watcher, etc.).
5. Exit Neovim. Verify the session is saved.
6. Detach from tmux and reattach. Verify window 0's Neovim layout is perfectly restored.

**Step 4: Evaluate and iterate**

Use this layout for a full day of work. At the end of the day, answer:

- Was there a tool I reached for that wasn't in the layout? (Add a window for it)
- Was there a window I never used? (Remove or repurpose it)
- Did Neovim's split layout feel right, or should some files be in different positions?

Adjust your layout and make it the permanent setup for this project.

**Success criteria:**

- You have a tmux session named after your project
- The session survives a detach/reattach cycle
- Neovim within the session restores perfectly
- The layout reflects your actual workflow — it's not a generic template but something specific to how you work on this project
- You can articulate why each window exists and what it's for

---

## Appendix: Quick Reference Card

```
+------------------------------------------------------------------+
|                    WORKSPACE QUICK REFERENCE                     |
+------------------------------------------------------------------+
|  TMUX SESSION MANAGEMENT                                         |
|  Ctrl+F          Launch sessionizer (fzf project picker)         |
|  prefix + d      Detach from current session                     |
|  prefix + s      List all sessions (interactive)                 |
|  tmux ls         List sessions from terminal                     |
|  tmux a -t NAME  Reattach to named session                       |
+------------------------------------------------------------------+
|  auto-session                                                    |
|  <leader>wr      Restore session for current directory           |
|  <leader>ws      Save session manually                           |
|  :Autosession delete    Delete session for current directory     |
|  ~/.local/share/nvim/sessions/   Session files location          |
+------------------------------------------------------------------+
|  DATABASE (dadbod-ui)                                            |
|  <leader>daplbu     Toggle DBUI panel                               |
|  <leader>S       Execute SQL query (in SQL buffer)               |
|  <leader>W       Save current query                              |
|  o/Enter         Open resource / expand tree node                |
+------------------------------------------------------------------+
|  REMOTE DEVELOPMENT                                              |
|  :RemoteStart ssh://user@host     Connect to remote host         |
|  :RemoteStart ssh://user@host:N   Connect on non-standard port   |
|  :RemoteStop                      Disconnect                     |
+------------------------------------------------------------------+
|  KUBERNETES (kubectl.nvim)                                       |
|  :KubectlGet pods                 List pods                      |
|  :KubectlGet deployments          List deployments               |
|  :KubectlContext                  Switch cluster context         |
|  l (in resource buffer)           View logs                      |
|  d (in resource buffer)           Describe resource              |
+------------------------------------------------------------------+
|  CONN-MANAGER                                                    |
|  t               Toggle connection (in conn-manager buffer)      |
|  .               Run action on selected connection               |
+------------------------------------------------------------------+
|  TMUX WINDOW NAVIGATION                                          |
|  prefix + 0-9    Jump to numbered window                         |
|  prefix + n/p    Next/previous window                            |
|  prefix + c      Create new window                               |
|  prefix + ,      Rename current window                           |
|  prefix + w      List windows (interactive)                      |
+------------------------------------------------------------------+
```

---

## What's Next

You've now built the full workspace stack. You have:

- Per-project persistence via auto-session
- Instant project switching via the tmux sessionizer
- Remote development capability via remote-nvim
- Database access integrated into your editor via dadbod-ui
- Kubernetes cluster browsing via kubectl.nvim
- Service connection management via conn-manager
- HTTP API testing via kulala.nvim

The next tutorial in the series covers **Terminal Integration** — going deep on Neovim's built-in terminal, how to use it effectively alongside tmux (and when to prefer one over the other), running test suites from within Neovim, and integrating terminal output back into the editor workflow.

The tutorial after that covers **Customization and Plugin Development** — writing your own Lua plugins, creating custom keymaps that do complex things, and bending Neovim to your exact personal preferences.

You have the workspace. You have the editing skills. The question now is how deep you want to go.

---

_Part of the Neovim 0 to Hero series. Previous: [11 · Testing and Debugging](./11-testing-debugging.md). Next: [13 · Terminal Integration](./13-terminal-integration.md)._
