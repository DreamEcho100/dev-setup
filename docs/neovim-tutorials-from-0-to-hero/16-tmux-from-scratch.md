# 16 — tmux From Scratch

> **Who this is for:** Complete tmux noobs. If you've never typed `tmux` in your
> life, this is the right place. If you know the basics already, skim to the
> config walkthrough section.

---

## Table of Contents

1. [What Is tmux and Why Do You Need It?](#1-what-is-tmux-and-why-do-you-need-it)
2. [The Mental Model: Sessions > Windows > Panes](#2-the-mental-model-sessions--windows--panes)
3. [Installation](#3-installation)
4. [The Prefix Key](#4-the-prefix-key)
5. [Sessions](#5-sessions)
6. [Windows](#6-windows)
7. [Panes](#7-panes)
8. [Copy Mode — The Built-in Clipboard](#8-copy-mode--the-built-in-clipboard)
9. [Config File Walkthrough](#9-config-file-walkthrough)
10. [The tmux-sessionizer Workflow](#10-the-tmux-sessionizer-workflow)
11. [TPM — Tmux Plugin Manager (Optional)](#11-tpm--tmux-plugin-manager-optional)
12. [Common Beginner Mistakes](#12-common-beginner-mistakes)
13. [Exercises](#13-exercises)

---

## 1. What Is tmux and Why Do You Need It?

You probably already have terminal tabs. Each tab runs one shell. That works
fine — until it doesn't.

Here's what happens without tmux:

- You're running a server in one tab. You switch to another tab to edit code.
  The SSH connection drops. Every single tab dies. Your running server? Gone.
  Your editor state? Gone.

- You're on a remote machine. You close your laptop. When you reopen it, the
  connection is dead and whatever was running is gone.

- You want to see your editor, your test runner, and your build output all at
  once. You could arrange three terminal windows manually, but they don't talk
  to each other and resizing is a nightmare.

tmux solves all of this.

**tmux is a terminal multiplexer.** It runs as a server in the background. When
you attach to it, you see its windows and panes. When you detach (or get
disconnected), the server keeps running. You come back and everything is exactly
where you left it.

Think of it like this: your terminal tabs are like browser tabs that close when
the browser crashes. tmux is like having actual persistent workspaces that
survive everything except a reboot.

### What tmux gives you:

| Problem | tmux solution |
|---------|---------------|
| SSH disconnects kill your work | tmux session survives on the server |
| Want editor + tests + server visible | Split one terminal into multiple panes |
| Context-switching between projects | One session per project, switch instantly |
| Need persistent state across sessions | Detach and re-attach days later |
| Remote pair programming | Both people attach to the same session |

### What about terminal tabs?

Terminal tabs (iTerm2, Alacritty, Kitty) are handled by your terminal emulator.
They die when the terminal crashes or closes. tmux sessions live in a server
process that is completely independent of your terminal. You can close every
terminal window on your machine and the tmux sessions keep running.

---

## 2. The Mental Model: Sessions > Windows > Panes

This is the most important thing to understand. tmux has three levels of
organisation:

```
tmux server (always running in background)
│
├── Session: "frontend"                  ← one per project
│   ├── Window 1: "nvim"                 ← one per context/task
│   │   ├── Pane (70%): nvim src/App.tsx ← visible terminal regions
│   │   └── Pane (30%): $ git log
│   ├── Window 2: "dev-server"
│   │   └── Pane: $ npm run dev
│   └── Window 3: "tests"
│       └── Pane: $ npm test --watch
│
└── Session: "backend"
    ├── Window 1: "nvim"
    │   ├── Pane (60%): nvim cmd/server/main.go
    │   └── Pane (40%): nvim internal/db/queries.go
    ├── Window 2: "run"
    │   └── Pane: $ go run ./cmd/server
    └── Window 3: "db"
        └── Pane: $ psql -U postgres myapp
```

### Sessions

A session is a collection of windows. Think of it as a project workspace. One
session per repository is the ideal workflow. Sessions survive detaches and
disconnections. They have names you can jump to instantly.

### Windows

A window occupies the full screen of a session (unless you've split it into
panes). Think of a window as a context within your project — editor, build,
server, git. You switch between windows with `<prefix>n/p` or `<prefix>1-9`.
The status bar at the bottom shows which windows exist and which one you're on.

### Panes

A pane is a rectangular region within a window, showing one terminal. You split
a window into panes with `<prefix>|` (vertical, side-by-side) or `<prefix>-`
(horizontal, above-and-below). You navigate between panes with `<prefix>h/j/k/l`
(or `<C-h/j/k/l>` when vim-tmux-navigator is set up — more on that in chapter 17).

### ASCII: The three levels

```
┌─────────────────────────────────────────────────────────────────┐
│ TERMINAL EMULATOR (Alacritty, Kitty, etc.)                     │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ TMUX SESSION: "myproject"                                 │  │
│  │                                                           │  │
│  │  ┌─────────────────────┬─────────────────────────────┐   │  │
│  │  │ PANE 1 (nvim)       │ PANE 2 (shell)              │   │  │
│  │  │                     │                             │   │  │
│  │  │  WINDOW 1: "editor" │  $ cargo build              │   │  │
│  │  │  (currently active) │  Compiling...               │   │  │
│  │  │                     │                             │   │  │
│  │  └─────────────────────┴─────────────────────────────┘   │  │
│  │                                                           │  │
│  │  [1:editor]  [2:server]  [3:tests]   ← window tabs      │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

The status bar at the bottom of tmux shows:
- Left side: the session name
- Middle: the window list (number + name, current one highlighted)
- Right side: date and time

---

## 3. Installation

The repo includes an Ansible playbook that builds tmux from the latest source:

```bash
# From the repo root
ansible-playbook tmux.yml -K
```

The `-K` flag prompts for your sudo password (needed for installing dependencies
and the built tmux binary). The playbook:
1. Fetches the latest tmux release from GitHub
2. Installs build dependencies (libevent-dev, ncurses-dev, build-essential)
3. Compiles and installs tmux to `/usr/local/bin/tmux`

Why build from source? The Ubuntu apt package is often 2-3 major versions behind.
Building from source gives you the latest features and bug fixes.

### Verify installation

```bash
tmux -V
# tmux 3.5a  (or whatever the latest version is)
```

If you see an older version (e.g., `tmux 3.0a`), the system version is taking
precedence. Check:
```bash
which tmux
# /usr/local/bin/tmux  ← good, this is the one built from source
# /usr/bin/tmux        ← this is the apt version, probably old
```

If it's `/usr/bin/tmux`, add `/usr/local/bin` earlier in your `PATH`:
```bash
# In ~/.zshrc or ~/.bashrc
export PATH="/usr/local/bin:$PATH"
```

### Start tmux for the first time

```bash
tmux new -s myproject
```

You're now inside a tmux session named `myproject`. Notice the green status bar
at the bottom. That's how you know you're in tmux.

---

## 4. The Prefix Key

Everything in tmux starts with a **prefix**. The default prefix is `Ctrl+b`
(written as `<C-b>` or `C-b` in tmux docs).

The workflow is:
1. Press and release `<C-b>`
2. Then press the command key

```
<C-b>  c       → create new window
<C-b>  d       → detach from session
<C-b>  %       → split pane vertically (default tmux binding)
```

It's like Vim's leader key: a two-step sequence. `<C-b>` tells tmux "I'm about
to give you a command." The next key is the command.

### The config's prefix

The current config keeps the default `<C-b>`. Some people switch to `<C-a>`
(the screen-style prefix) because it's slightly easier to reach. The tmux.conf
has that change commented out:

```bash
# In dotfiles/.config/tmux/tmux.conf — uncomment to switch:
# unbind C-b
# set-option -g prefix C-a
# bind-key C-a send-prefix
```

If you find yourself reaching for `<C-b>` awkward, you can enable this. But
stick with the default while learning — all tmux documentation uses `<C-b>`.

### "Passthrough": sending Ctrl+b to programs

What if a program inside tmux needs `<C-b>`? Some programs (like Vim's default
config) use it. To send the actual `Ctrl+b` character to the running program,
press `<C-b>` twice:

```
<C-b>  <C-b>   → sends Ctrl+b to the foreground program
```

---

## 5. Sessions

Sessions are the outermost container. One session per project is the recommended
pattern.

### Creating sessions

```bash
# Create a new session and attach to it immediately
tmux new -s myproject

# Create a session in the background (don't attach yet)
tmux new -s backend -d

# Create a session and set the starting directory
tmux new -s frontend -c ~/projects/frontend
```

### Listing sessions

```bash
# From outside tmux
tmux ls
# or
tmux list-sessions

# Example output:
# backend: 2 windows (created Thu Jun 19 09:15:00 2026) (attached)
# frontend: 3 windows (created Thu Jun 19 08:00:00 2026)
```

### Attaching to sessions

```bash
# Attach to a specific session
tmux attach -t myproject
# or the shorter form
tmux a -t myproject

# Attach to the last used session
tmux a
```

### Killing sessions

```bash
# Kill a specific session (and everything in it)
tmux kill-session -t myproject

# Kill ALL sessions (be careful!)
tmux kill-server
```

### Inside tmux: Session keybindings

| Key | What it does |
|-----|-------------|
| `<prefix>d` | Detach — leave the session running, go back to shell |
| `<prefix>$` | Rename current session |
| `<prefix>s` | Show session picker (navigate with j/k, Enter to select) |
| `<prefix>(` | Switch to previous session |
| `<prefix>)` | Switch to next session |
| `<prefix>L` | Switch to last (most recently used) session |

### The detach workflow

Detaching is tmux's superpower. When you detach:
- The session keeps running
- Every program in it keeps running
- You can close your terminal, shut your laptop lid, disconnect from SSH
- Come back later, run `tmux a`, and everything is exactly where you left it

```
$ nvim bigproject.cpp          ← start editing
  [press <prefix>d]            ← detach
$ # session still running!
$ tmux a                       ← re-attach hours later
  # nvim is still open at bigproject.cpp
```

---

## 6. Windows

Windows are the second level. Think of them as tabs within a project session.
Each window shows either one full-screen pane, or several panes split from that
full screen.

### Window keybindings

| Key | What it does |
|-----|-------------|
| `<prefix>c` | Create a new window (opens in current path — see config) |
| `<prefix>,` | Rename the current window |
| `<prefix>n` | Go to the next window |
| `<prefix>p` | Go to the previous window |
| `<prefix>0-9` | Jump to window by number |
| `<prefix>w` | Open window picker (tree view of all sessions + windows) |
| `<prefix>&` | Kill the current window (prompts for confirmation) |
| `<prefix>l` | Go to the last (previously active) window |

### Reading the status bar

The status bar at the bottom shows your windows. The active window is
highlighted differently. Here's how to read it:

```
myproject  [1:nvim] [2:build*] [3:server]    2026-06-19  09:30
    ^         ^           ^         ^
    |         |           |         |
 session    window1    active    window3
  name               window(*)
```

The `*` in `[2:build*]` means window 2 is the current one. Some configs show
a `-` for the last window and `*` for the current one.

### Renaming windows

The default window name is the name of the running program (e.g., `bash`,
`nvim`, `node`). That's useful but not very descriptive. After opening a window
for your dev server, rename it:

```
<prefix>,
→ rename-window: dev-server
→ Enter
```

Now the status bar shows `[2:dev-server]` instead of `[2:node]`.

### Window numbering

The config sets `base-index 1`, so windows start at 1 instead of 0. This makes
the keyboard shortcuts make more sense: `<prefix>1` = first window (not
`<prefix>0`). Windows are automatically renumbered when you close one (`renumber-windows on`).

### Creating windows in the current directory

The config binds `c` to open new windows in the current pane's path:
```bash
bind c new-window -c "#{pane_current_path}"
```
So if you're in `/projects/backend` and press `<prefix>c`, the new window
also starts in `/projects/backend`. Very convenient.

---

## 7. Panes

Panes are the visual splits within a window. This is where the real power of
tmux becomes visible: you can have your editor, your compiler, and your test
runner all visible at once.

### Splitting panes

The config uses `|` and `-` instead of tmux's default `%` and `"`:

| Key | What it does |
|-----|-------------|
| `<prefix>|` | **Vertical split** — new pane appears on the right |
| `<prefix>-` | **Horizontal split** — new pane appears below |

These also open in the current directory (per the config bindings).

### Navigating between panes

| Key | What it does |
|-----|-------------|
| `<prefix>h` | Move to the pane on the left |
| `<prefix>j` | Move to the pane below |
| `<prefix>k` | Move to the pane above |
| `<prefix>l` | Move to the pane on the right |

> **Note:** In Chapter 17, you'll set up `vim-tmux-navigator` which lets you use
> `<C-h/j/k/l>` to move between BOTH Neovim splits AND tmux panes without
> thinking about which you're in. That's even better.

### Zooming a pane

Sometimes you need a pane to take up the full window temporarily:

| Key | What it does |
|-----|-------------|
| `<prefix>z` | Toggle zoom — current pane fills entire window |
| `<prefix>z` | Press again to unzoom |

While zoomed, the status bar shows `[Z]` to remind you a pane is zoomed.

### Other pane operations

| Key | What it does |
|-----|-------------|
| `<prefix>x` | Kill current pane (prompts for confirmation) |
| `<prefix>q` | Show pane numbers briefly (press the number to jump) |
| `<prefix>!` | Break pane out into its own window |
| `<prefix>{` | Swap pane with the previous one |
| `<prefix>}` | Swap pane with the next one |
| `<prefix><space>` | Cycle through pane layouts (even-horizontal, even-vertical, etc.) |

### Resizing panes

| Key | What it does |
|-----|-------------|
| `<prefix><Up>` | Resize pane up by 5 cells |
| `<prefix><Down>` | Resize pane down by 5 cells |
| `<prefix><Left>` | Resize pane left by 5 cells |
| `<prefix><Right>` | Resize pane right by 5 cells |

Hold the arrow key for continuous resize. Or just use the mouse (mouse mode is
enabled in the config — drag the pane border).

### Common pane layouts

```
Two panes side by side (editor + terminal):
┌──────────────────┬───────────────┐
│ nvim             │ $ make        │
│                  │ Building...   │
│                  │               │
│                  │               │
└──────────────────┴───────────────┘
  <prefix>|  to create this layout

Three panes (editor + two terminals):
┌──────────────────┬───────────────┐
│                  │ $ go test ./..│
│ nvim             ├───────────────┤
│                  │ $ ./myapp     │
└──────────────────┴───────────────┘
  <prefix>|  →  <prefix>-  to create this layout

Full-width bottom (editor with output below):
┌──────────────────────────────────┐
│                                  │
│ nvim                             │
│                                  │
├──────────────────────────────────┤
│ $ go build ./...                 │
└──────────────────────────────────┘
  <prefix>-  to create this layout
```

---

## 8. Copy Mode — The Built-in Clipboard

Copy mode lets you scroll back through terminal output, search it, and copy text
— all without touching the mouse (though the mouse also works with `mouse on`).

### Entering and exiting copy mode

| Key | What it does |
|-----|-------------|
| `<prefix>[` | Enter copy mode |
| `q` or `Escape` | Exit copy mode |

When you're in copy mode, the status bar shows `[COPY]` and you can scroll and
navigate freely.

### Navigation in copy mode (vi keys)

The config sets `mode-keys vi`, so navigation is the same as Vim:

| Key | What it does |
|-----|-------------|
| `j` / `k` | Move down/up one line |
| `h` / `l` | Move left/right one character |
| `w` / `b` | Jump forward/back one word |
| `0` / `$` | Start/end of line |
| `gg` / `G` | Top/bottom of scroll buffer |
| `<C-u>` / `<C-d>` | Scroll half-page up/down |
| `<C-f>` / `<C-b>` | Scroll full page up/down |
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` / `N` | Next/previous search match |

### Selecting and copying text

| Key | What it does |
|-----|-------------|
| `v` | Begin character selection (like visual mode in Vim) |
| `V` | Begin line selection |
| `<C-v>` | Begin rectangle (block) selection |
| `y` | Yank (copy) selection → copies to clipboard via xclip |
| `Enter` | Alternative yank |

The config copies to the system clipboard:
```bash
# In tmux.conf:
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel \
    'xclip -in -selection clipboard'
```

After yanking, the selection is in your system clipboard — paste it anywhere
with `Ctrl+v`, or in Neovim with `"+p`.

### Pasting in tmux

```
<prefix>]   → paste from tmux's internal buffer
```

Or just use your system paste shortcut (`Ctrl+Shift+v` in most terminals, right-click, etc.) — that uses the system clipboard which xclip wrote to.

> **Wayland users:** Replace `xclip -in -selection clipboard` with
> `wl-copy` in your tmux.conf. Both `xclip` and `wl-clipboard` are in the
> Ansible playbook's package list.

### Scrolling back through history

The most common use of copy mode isn't copying — it's scrolling. When a command
produces a lot of output, you scroll up to read it:

```
<prefix>[          → enter copy mode
<C-u> or PageUp   → scroll up
q                  → exit when done
```

---

## 9. Config File Walkthrough

The config lives at `dotfiles/.config/tmux/tmux.conf`. Here it is with
explanations for every setting:

```bash
# ── Terminal & colour ──────────────────────────────────────────────────────────
set -g default-terminal "tmux-256color"
```
Tell tmux what kind of terminal it is. `tmux-256color` is the correct value for
most modern terminals. Without this, colours may be wrong.

```bash
set -ag terminal-overrides ",xterm-256color:RGB"
```
Enable 24-bit true colour (16 million colours instead of 256). The `,xterm-256color:RGB` tells tmux to pass RGB colour codes through to the terminal emulator. Without this, Neovim themes with 24-bit colours may look wrong.

```bash
# ── General behaviour ──────────────────────────────────────────────────────────
set -s escape-time 10
```
Lower the escape-key timeout from 500ms to 10ms. **This is critical for Neovim.**
Without it, pressing `<Esc>` in Neovim inside tmux feels sluggish — there's a
half-second delay before insert mode exits. With 10ms, it's instant.

```bash
set -g base-index 1
setw -g pane-base-index 1
```
Start window and pane numbering at 1 instead of 0. Makes more ergonomic sense
when jumping with `<prefix>1`, `<prefix>2`, etc. (your keyboard's `1` key is
the leftmost, matching window 1).

```bash
set -g renumber-windows on
```
When you close a window, remaining windows are renumbered to stay consecutive.
Without this, closing window 2 out of [1,2,3] would leave you with [1,3] which
is confusing.

```bash
set -g mouse on
```
Enable mouse support. You can:
- Click a pane to focus it
- Click a window in the status bar to switch to it
- Drag pane borders to resize them
- Scroll to enter copy mode and scroll the buffer

```bash
# ── Reload config ──────────────────────────────────────────────────────────────
bind r source-file "$XDG_CONFIG_HOME/tmux/tmux.conf" \; display-message "Reloaded"
```
Press `<prefix>r` to reload the config without restarting tmux. Useful when
tweaking settings — you don't have to kill all your sessions to test a change.

```bash
# ── Pane navigation ────────────────────────────────────────────────────────────
bind -r h select-pane -L
bind -r j select-pane -D
bind -r k select-pane -U
bind -r l select-pane -R
```
`<prefix>h/j/k/l` to navigate panes like Vim. The `-r` flag means the binding
is "repeatable" — you can hold `<prefix>` and tap `l l l` to move right three
times without pressing `<prefix>` each time.

```bash
# ── Pane splitting ─────────────────────────────────────────────────────────────
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
```
`<prefix>|` for vertical split, `<prefix>-` for horizontal split. The
`-c "#{pane_current_path}"` part opens the new pane in the same directory as the
current pane — much more useful than always opening in `$HOME`.

```bash
bind c new-window -c "#{pane_current_path}"
```
Same idea: new windows also open in the current directory.

```bash
# ── Copy mode ──────────────────────────────────────────────────────────────────
setw -g mode-keys vi
bind-key -T copy-mode-vi v     send-keys -X begin-selection
bind-key -T copy-mode-vi C-v   send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y     send-keys -X copy-pipe-and-cancel \
    'xclip -in -selection clipboard'
```
Vi keys in copy mode. `v` to start selection (like Vim visual mode), `y` to
yank to system clipboard via xclip.

```bash
# ── Status bar ─────────────────────────────────────────────────────────────────
set -g status on
set -g status-position bottom
set -g status-style "fg=#cdd6f4,bg=#1e1e2e"
```
The status bar is at the bottom, coloured in Catppuccin Mocha tones (dark
background, light text). The specific colours:
- `#1e1e2e` = very dark navy (Catppuccin base)
- `#cdd6f4` = soft white (Catppuccin text)
- `#89b4fa` = soft blue (session name / active elements)
- `#f38ba8` = soft red/pink (active window)
- `#a6e3a1` = soft green (clock)

```bash
set -g status-left  "#[fg=#89b4fa,bold] #S #[default]│ "
set -g status-right "#[fg=#a6e3a1] %Y-%m-%d  %H:%M #[default]"
```
Left side shows the session name (`#S`) in blue. Right side shows date and time
in green. The `#[...]` sequences are tmux colour/style attributes.

```bash
setw -g window-status-current-style "fg=#f38ba8,bold"
setw -g window-status-current-format " #I:#W "
setw -g window-status-format " #I:#W "
```
`#I` = window index, `#W` = window name. Active window shows in pink/red bold.
Other windows show in the default text colour.

```bash
# ── TPM (commented, optional) ──────────────────────────────────────────────────
# set -g @plugin 'tmux-plugins/tpm'
# ...
# run '~/.tmux/plugins/tpm/tpm'
```
TPM (Tmux Plugin Manager) is there but commented out. See section 11 for how to
enable it.

### Reloading after changes

After editing `tmux.conf`, apply changes immediately without restarting tmux:

```
<prefix>r
```

You should see "Reloaded tmux config" flash in the status bar.

---

## 10. The tmux-sessionizer Workflow

The sessionizer is a script at `dotfiles/.local/scripts/tmux-sessionizer`. It
gives you a fuzzy-search interface to jump between project directories, creating
a tmux session for each one automatically.

### How it works

1. You press `<C-f>` inside Neovim (or run `tmux-sessionizer` directly in a terminal)
2. An fzf picker appears listing directories from your workspace directories
3. You type a few letters to filter, press Enter to select
4. tmux creates a new session named after that directory (if it doesn't exist)
5. You're switched to that session instantly

```
┌─────────────────────────────────────────────────┐
│   Project:                                      │
│ > frontend                                      │
│   backend                                       │
│   mfansible                                     │
│   dotfiles                                      │
│   personal-site                                 │
│                                                 │
│   5/47                                          │
└─────────────────────────────────────────────────┘
  Type "back" → matches "backend"
```

### The script's search directories

Edit the `SEARCH_DIRS` array at the top of the script to add your project locations:

```bash
# In dotfiles/.local/scripts/tmux-sessionizer
SEARCH_DIRS=(
    "$HOME/Desktop/workspaces"
    "$HOME/projects"
    "$HOME"
)
```

It searches up to 3 levels deep, skipping `.git`, `node_modules`, `__pycache__`,
`.cache`, and `vendor` directories.

### Making it available on your PATH

The script needs to be callable as `tmux-sessionizer`. The Ansible playbook
should symlink it to `~/.local/bin/`. If it's not on PATH, add this to your
shell profile:

```bash
# ~/.zshrc or ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
```

Then symlink the script:
```bash
ln -sf ~/path/to/mfansible/dotfiles/.local/scripts/tmux-sessionizer \
       ~/.local/bin/tmux-sessionizer
```

### Using it from Neovim

The Neovim config has:
```lua
-- In dotfiles/.config/nvim/lua/de100/core/keymaps.lua
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
```

Pressing `<C-f>` in Neovim:
1. Opens a new tmux window
2. That window runs `tmux-sessionizer`
3. You pick a project
4. tmux switches you to that project's session
5. The temporary window closes automatically

Your Neovim session in the original project is untouched and waiting for you.

### Jumping back

Use the session picker to return to any open session:
```
<prefix>s   → shows all sessions, navigate with j/k, Enter to select
```

Or press `<C-f>` again from anywhere and pick the original project.

### The session name

The session name is derived from the directory name with dots and spaces
converted to underscores. So `my-project` becomes session `my-project`,
`project.v2` becomes `project_v2`.

---

## 11. TPM — Tmux Plugin Manager (Optional)

TPM is to tmux what lazy.nvim is to Neovim: a plugin manager that makes
installing community plugins easy. The tmux.conf has a TPM block commented out.

### Installing TPM

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Enabling it in the config

Open `dotfiles/.config/tmux/tmux.conf` and uncomment the TPM block at the bottom:

```bash
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

run '~/.tmux/plugins/tpm/tpm'
```

Reload the config (`<prefix>r`), then install plugins:
```
<prefix>I    → Install plugins (capital I)
```

### Recommended plugins

**tmux-sensible** (`tmux-plugins/tmux-sensible`):
A set of sensible default settings. Good baseline additions like longer
history, faster escape detection, automatic terminal environment propagation.

**tmux-resurrect** (`tmux-plugins/tmux-resurrect`):
Save and restore tmux sessions across system restarts (reboots). This is the
"sessions survive reboots" plugin.
```
<prefix>Ctrl+s    → Save session
<prefix>Ctrl+r    → Restore session
```

**tmux-continuum** (`tmux-plugins/tmux-continuum`):
Works with tmux-resurrect to automatically save your sessions every 15 minutes.
On tmux start, it can optionally auto-restore the last saved state.
```bash
# In tmux.conf, to enable auto-restore:
set -g @continuum-restore 'on'
```

### Updating plugins

```
<prefix>U    → Update all plugins
```

### Removing plugins

Remove the line from tmux.conf, then:
```
<prefix>alt+u    → Uninstall removed plugins
```

---

## 12. Common Beginner Mistakes

### "I pressed Ctrl+b and nothing happened"

You're probably not inside a tmux session. tmux commands only work inside tmux.
Check: does your terminal status bar show a tmux session name? If not, run:
```bash
tmux new -s practice
```

### "My colors look wrong inside tmux"

Check your `$TERM` variable:
```bash
echo $TERM
```
Inside tmux, it should be `tmux-256color`. Outside tmux (in your shell), it
should be whatever your terminal sets (often `xterm-256color`). If it's just
`xterm` or `screen`, add to your shell profile:
```bash
export TERM=xterm-256color
```
The tmux.conf handles the rest with the `terminal-overrides` setting.

### "I can't scroll up to see old output"

You need copy mode. Press `<prefix>[` to enter it, then scroll with `<C-u>` or
the mouse wheel. Press `q` to exit.

### "My terminal looks garbled after tmux crashed"

Run:
```bash
reset
```
This resets the terminal to a sane state. tmux crashing can leave the terminal
in a weird mode with invisible text, missing line endings, etc. `reset` fixes it.

### "`tmux -V` shows an old version even after running the playbook"

The system `tmux` from apt is taking precedence over the compiled version. Check:
```bash
which tmux
```
If it shows `/usr/bin/tmux` instead of `/usr/local/bin/tmux`, your PATH isn't
set correctly. Add `/usr/local/bin` first:
```bash
# ~/.zshrc
export PATH="/usr/local/bin:$PATH"
```

### "I accidentally killed my session"

Sessions that are `kill-session`d are gone. However, if you just detached, it's
still running:
```bash
tmux ls        # list running sessions
tmux a -t name # re-attach
```

### "`select-pane -t:.+ has no parent`"

You tried to navigate to a pane that doesn't exist (e.g., move right when
you're already in the rightmost pane). Not an error — just tmux telling you
there's no pane in that direction.

### "Mouse scroll doesn't work"

Confirm `set -g mouse on` is in your tmux.conf and that you've reloaded it
(`<prefix>r`). Note: when you're in an application that handles mouse events
itself (like Neovim), the application's mouse handling takes priority. To force
tmux scroll in that case, hold `Shift` while scrolling.

### "I closed my terminal and everything died"

Unlike detaching (`<prefix>d`), closing the terminal emulator window while
attached to tmux does NOT kill the session. The session keeps running. Just
reopen your terminal and `tmux a` to get back. The only thing that kills a
session is:
- `<prefix>d` then `tmux kill-session` from outside
- `tmux kill-server`
- System reboot (unless you have tmux-resurrect with auto-restore)

---

## 13. Exercises

Work through these in order. Each one takes 5-15 minutes.

### Exercise 1: Sessions — Create, Detach, Re-attach

1. Open a terminal (not inside tmux)
2. Create a session: `tmux new -s practice`
3. Inside the session, run: `echo "Hello from tmux session"`
4. Detach: `<prefix>d`
5. Confirm the session is running: `tmux ls`
6. Create a second session in the background: `tmux new -s other -d`
7. Re-attach to `practice`: `tmux a -t practice`
8. Switch to `other` without detaching: `<prefix>s` → select `other`
9. Switch back to `practice`: `<prefix>s` → select `practice`
10. Kill both sessions: `<prefix>d` then `tmux kill-session -t other`

### Exercise 2: Windows — The Workstation Layout

1. Create a fresh session: `tmux new -s workspace`
2. Rename window 1 to "editor": `<prefix>,` then type `editor` and Enter
3. Create window 2: `<prefix>c`
4. Rename it "build": `<prefix>,` → `build`
5. Create window 3: `<prefix>c`
6. Rename it "server": `<prefix>,` → `server`
7. Navigate: `<prefix>1` → `<prefix>2` → `<prefix>3` → `<prefix>1`
8. Use `<prefix>w` to see the window tree
9. Go to window 2 and close it: `<prefix>&` and confirm
10. Notice windows renumber to [1:editor] [2:server]

### Exercise 3: Panes — Side-by-side Working

1. In a session, press `<prefix>|` to split vertically
2. You now have two panes. Run `top` in the right pane
3. Navigate to the left pane: `<prefix>h`
4. Run `echo "I am in the left pane"` in the left pane
5. Press `<prefix>-` to split the left pane horizontally
6. You now have 3 panes. Navigate around with `<prefix>h/j/k/l`
7. Zoom into one pane: `<prefix>z`
8. Unzoom: `<prefix>z` again
9. Kill the bottom-left pane: `<prefix>x` and confirm
10. You're back to two panes

### Exercise 4: Copy Mode — Read and Grab

1. Run a command with lots of output: `find / -name "*.conf" 2>/dev/null | head -100`
2. Enter copy mode: `<prefix>[`
3. Scroll up with `<C-u>` to see earlier output
4. Search for "etc": `/etc` then Enter
5. Press `n` to jump to next match
6. Select a line: press `v` to start selection, then move with `j` to select multiple lines
7. Copy: press `y`
8. Exit copy mode: `q`
9. Open a new pane: `<prefix>|`
10. Paste: `<prefix>]` (or `Ctrl+Shift+v` in your terminal to use system clipboard)

### Exercise 5: The Sessionizer

1. Make sure `tmux-sessionizer` is on your PATH (see section 10)
2. Open a terminal and run `tmux-sessionizer` directly
3. Use arrow keys or type to filter to a project directory
4. Press Enter — a new session is created and you're switched to it
5. Open Neovim in that session: `nvim .`
6. Press `<C-f>` — the sessionizer opens in a new window
7. Pick a different project
8. Confirm you're in a new session with `<prefix>$` or checking the status bar
9. Press `<prefix>s` to see both sessions
10. Switch back to your first session

---

> **What's next?** Now that you know tmux on its own, the next chapter covers
> how tmux and Neovim work together — seamless pane navigation, shared
> clipboard, the full "project = session" workflow pattern.
>
> Continue to: [17 — tmux + Neovim Workflow](17-tmux-neovim-workflow.md)
