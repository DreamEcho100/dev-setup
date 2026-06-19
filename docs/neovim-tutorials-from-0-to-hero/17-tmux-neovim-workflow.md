# Chapter 17 — tmux + Neovim: The Integrated Workflow

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║    tmux  ──────────────────────────────────────►  Neovim                    ║
║                                                                              ║
║    [ Two tools. One brain. Seamless navigation. ]                            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

> **Prerequisite:** You've read Chapter 16 (tmux from scratch) and are comfortable
> with the prefix key, sessions, windows, and panes. If tmux still feels foreign,
> go back and do the exercises in Chapter 16 first — this chapter builds directly
> on that foundation.

---

## What This Chapter Covers

Chapter 16 taught you tmux as a standalone tool. This chapter is about the
integration layer — the invisible seam between tmux and Neovim that, when set
up correctly, makes them feel like one unified environment rather than two
separate programs fighting over your keyboard.

By the end of this chapter you'll understand:

- Why `<C-h/j/k/l>` moves through **both** Neovim splits and tmux panes with
  the same keystrokes
- How text copied in tmux's copy mode gets into Neovim's clipboard (and vice versa)
- How to switch projects with `<C-f>` without ever leaving your editor
- The "one session per project" mental model that makes multi-project work sane
- How to set up a full project workspace in under 10 seconds with a script

---

## Part 1 — vim-tmux-navigator: Unified Split Navigation

### The Problem This Solves

Before vim-tmux-navigator, you had two separate navigation systems:

- **In Neovim:** `<C-w>h/j/k/l` to move between splits
- **In tmux:** `<prefix>h/j/k/l` to move between panes

These were completely separate. Moving from a Neovim split to a tmux pane
required a completely different gesture. Your brain had to track "am I in
Neovim or tmux right now?"

vim-tmux-navigator erases that distinction entirely.

### How It Works

The plugin is `christoomey/vim-tmux-navigator` — it's already installed in this
config. It creates a transparent handoff:

1. You press `<C-h>` (move left)
2. Neovim checks: "Is there a split to my left?"
3. If yes → move to that Neovim split (normal behavior)
4. If no → signal tmux: "move the focus left"
5. tmux moves focus to the pane to the left

The result: **`<C-h/j/k/l>` works identically everywhere.** You don't need to
think about which program you're in.

### The Navigation Diagram

This ASCII diagram shows a tmux window with two panes. The right pane has
Neovim open with a vertical split inside it:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ tmux window "editor"                                                        │
│                                                                             │
│ ┌──────────────────────┐ │ ┌───────────────┐ │ ┌───────────────┐           │
│ │                      │ │ │               │ │ │               │           │
│ │   tmux pane 1        │ │ │  Neovim split │ │ │  Neovim split │           │
│ │   (bash/tests)       │ │ │  left (code)  │ │ │  right (tests)│           │
│ │                      │ │ │               │ │ │               │           │
│ │   $ go test ./...    │ │ │   main.go     │ │ │   main_test.go│           │
│ │                      │ │ │               │ │ │               │           │
│ └──────────────────────┘ │ └───────────────┘ │ └───────────────┘           │
│        pane 1            │      pane 2 — Neovim with 2 splits              │
└─────────────────────────────────────────────────────────────────────────────┘

Navigation with <C-h/j/k/l>:

  From right Neovim split:   <C-h> → left Neovim split    (inside Neovim)
  From left Neovim split:    <C-h> → tmux pane 1          (crosses boundary!)
  From tmux pane 1:          <C-l> → Neovim (pane 2)      (crosses boundary!)
```

The `│` boundary between pane 1 and pane 2 is completely transparent to your
navigation keys.

### The Required tmux.conf Setting

For this to work, tmux must forward the `<C-h/j/k/l>` keys to the plugin's
detection script. Our `tmux.conf` already has this:

```bash
# From dotfiles/.config/tmux/tmux.conf
bind -r h select-pane -L
bind -r j select-pane -D
bind -r k select-pane -U
bind -r l select-pane -R
```

And Neovim checks whether the current pane is running Neovim before deciding to
hand off. The detection is automatic — you don't configure it per-project.

### Keybinding Summary

| Key | What Happens |
|-----|-------------|
| `<C-h>` | Move left — Neovim split or tmux pane |
| `<C-j>` | Move down — Neovim split or tmux pane |
| `<C-k>` | Move up — Neovim split or tmux pane |
| `<C-l>` | Move right — Neovim split or tmux pane |

These four keys are now universal. Forget `<prefix>hjkl` for pane navigation —
you only use them if you're not in Neovim.

> **Note for terminal users:** `<C-l>` normally clears the terminal. In tmux
> panes outside Neovim, use `<prefix>l` (tmux's own) or just type `clear`. The
> vim-tmux-navigator plugin only hijacks `<C-l>` inside Neovim itself, so your
> terminal panes still have `<C-l>` available.

---

## Part 2 — Clipboard Bridge: Copy Across the Boundary

### The Three Clipboards Problem

When you're running Neovim inside tmux, there are actually three "clipboards" in
play:

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  1. X11/Wayland system clipboard  (xclip / wl-copy)    │
│           ↑                ↑                            │
│     Neovim "+ register    tmux copy buffer              │
│                                                         │
│  2. Neovim registers  ("  "+ "0  "a-z  etc.)           │
│                                                         │
│  3. tmux copy buffer  (what <prefix>[ captures)        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

By default, each is isolated. Text you yank in Neovim doesn't go to tmux.
Text you select in tmux copy mode doesn't go to Neovim.

### How the Bridge Is Set Up in This Config

The config uses `xclip` as the common relay — the system clipboard is the
shared bus between all three.

**In `tmux.conf`:**
```bash
bind-key -T copy-mode-vi y     send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'
```

When you press `y` in tmux copy mode, the text goes to the X11 clipboard
(`xclip -selection clipboard`), NOT just the tmux buffer.

**In Neovim**, the `unnamedplus` setting (already configured) makes `y/p` use
the `"+` register (system clipboard) by default. So yanking in Neovim also goes
to the system clipboard.

### The Copy Flow in Practice

**tmux → Neovim:**
```
1. In a tmux pane (e.g., bash, test output):
   <prefix>[          → enter copy mode
   /search or move    → position cursor
   v                  → start selection
   y                  → yank to system clipboard (via xclip)
   <Esc> or q         → exit copy mode

2. Switch to Neovim pane: <C-l> (or <C-h> etc.)

3. In Neovim insert mode:
   <C-r>+             → paste from "+ register (system clipboard)
   OR in normal mode:
   "+p                → paste from system clipboard
   OR just:
   p                  → works if unnamedplus is set (this config has it)
```

**Neovim → tmux:**
```
1. In Neovim, yank text normally:
   yy                 → yank line (goes to system clipboard via unnamedplus)
   viwy               → yank word
   "+yy               → explicitly yank to system clipboard register

2. Switch to tmux pane: <C-h> (or whichever direction)

3. In bash or any terminal:
   Ctrl+Shift+V       → terminal emulator paste
   OR (if supported):
   xclip -out -selection clipboard | <command>
```

### Mouse Copy

Mouse copy also works — just select text with the mouse in any tmux pane and
`xclip` picks it up automatically (because `mode-keys vi` is set and mouse mode
is on). But be careful: mouse drag in tmux pane triggers tmux copy mode, not
the terminal application. If you're in Neovim and try to mouse-select, tmux
intercepts it. To select inside Neovim with mouse, you need to hold `Shift`
while clicking/dragging to bypass tmux.

### xclip Not Installed?

Run the playbook — `xclip` is included. Or manually:
```bash
sudo apt install xclip    # Debian/Ubuntu
```

On macOS (if you're using this config there), the command in `tmux.conf` should
be `pbcopy` instead of `xclip`. The config as shipped is Linux-first.

---

## Part 3 — `<C-f>`: The Sessionizer From Inside Neovim

### The Concept

You're deep in editing a file. You need to switch to a different project. The
old workflow:

1. Save (Ctrl+S)
2. Exit Neovim (:q)
3. Detach from tmux session (<prefix>d)
4. Run tmux-sessionizer
5. Pick a project
6. Reopen Neovim

That's five steps and you lose your Neovim context.

The `<C-f>` binding in this config reduces that to **one keystroke**:

1. Press `<C-f>` in Neovim
2. fzf picker appears
3. Select a project
4. You're in that project's tmux session with Neovim preserved

### How It Works

In Neovim's keymaps, `<C-f>` is bound to:
```lua
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
```

This tells tmux to open a new temporary window, run `tmux-sessionizer` in it,
and then — because the sessionizer switches the client to a different session —
the temp window disappears and you're transported to the new project's session.

Your original session (with Neovim open) is still alive. The `auto-session`
plugin saved its state. When you come back, `:SessionRestore` or the auto-restore
on startup brings your buffers back.

### The tmux-sessionizer Script

The script lives at `dotfiles/.local/scripts/tmux-sessionizer`. It's symlinked
to `~/.local/bin/tmux-sessionizer` by Ansible. Source:

```bash
#!/usr/bin/env bash
# Fuzzy-pick a project dir and create/switch to its tmux session.
# Used by <C-f> in Neovim — see dotfiles/.config/nvim/lua/de100/keymaps.lua

SEARCH_DIRS=(
    "$HOME/Desktop/workspaces"
    "$HOME/projects"
    "$HOME"
)

selected=$(
    find "${SEARCH_DIRS[@]}" \
        -maxdepth 3 -mindepth 1 \
        -type d \
        \( -name ".git" -o -name "node_modules" -o -name "__pycache__" \
           -o -name ".cache" -o -name "vendor" \) -prune \
        -o -type d -print 2>/dev/null \
    | fzf \
        --prompt="  Project: " \
        --height=40% \
        --border=rounded \
        --preview="ls -la {}" \
        --preview-window=right:40%
)

[ -z "$selected" ] && exit 0

session_name=$(basename "$selected" | tr '. ' '__')

if ! tmux has-session -t="$session_name" 2>/dev/null; then
    tmux new-session -ds "$session_name" -c "$selected"
fi

if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session_name"
else
    tmux attach-session -t "$session_name"
fi
```

**Walk-through:**
1. `find` searches your project dirs up to 3 levels deep, skipping git/node/cache dirs
2. `fzf` shows the picker with a file preview on the right
3. The session name is derived from the directory basename (`my.project` → `my_project`)
4. If the session doesn't exist yet, it creates it detached in that directory
5. `switch-client` (inside tmux) or `attach-session` (outside) jumps to it

**Customizing search directories:** Edit `SEARCH_DIRS` in the script to add
your own project roots. Then reload: `source ~/.local/bin/tmux-sessionizer`
or just run it fresh.

### Prerequisite: `fzf` Must Be Installed

```bash
which fzf || sudo apt install fzf
```

The Ansible playbook installs fzf — run it if missing.

---

## Part 4 — The "Project = Session" Mental Model

### Why One Session Per Project

The single biggest shift in your tmux workflow isn't the keybindings — it's
adopting the rule: **one tmux session = one project**.

Without this rule, you end up with a dozen unnamed windows all running different
things and no way to quickly find any of them.

With this rule:

```
tmux ls
mfansible     (2 windows)   [attached]
my-api        (3 windows)
my-frontend   (3 windows)
dotfiles      (1 window)
```

Each session has windows that make sense in the context of that project.
Switching projects is `<C-f>` or `<prefix>$` to pick from the list.

### The Standard Window Layout Per Project

Here's the template used for most projects in this workflow:

```
Session: mfansible
│
├── Window 1: "editor"    ← Neovim (main workspace)
│   └── Full-width Neovim, or Neovim + a small terminal split for quick commands
│
├── Window 2: "run"       ← Long-running process (server, watcher, dev server)
│   └── The thing that runs continuously, whose output you glance at
│
└── Window 3: "git"       ← Git operations and misc shell work
    └── git log, git diff, lazygit if you use it outside Neovim
```

For a Go project:
```
├── Window 1: "editor"   — nvim .
├── Window 2: "test"     — go test -v ./... --watch (with gotestsum)
└── Window 3: "server"   — go run ./cmd/server/main.go
```

For a C/C++ project:
```
├── Window 1: "editor"   — nvim .
├── Window 2: "build"    — cmake --build build/ (or overseer tasks)
└── Window 3: "run"      — ./build/myapp (or gdb ./build/myapp)
```

For a web frontend:
```
├── Window 1: "editor"   — nvim .
├── Window 2: "dev"      — npm run dev
└── Window 3: "test"     — npm test --watch
```

You navigate between windows with `<prefix>1`, `<prefix>2`, `<prefix>3`.
Within window 1, you navigate Neovim splits with `<C-h/j/k/l>`.

### Setting Up a Project Session Manually

```bash
# Create the session and first window
tmux new-session -s myproject -n editor -c ~/Desktop/workspaces/myproject

# Open Neovim
nvim .

# Create a second window (from inside tmux: <prefix>c or)
tmux new-window -n run

# Start the dev server
npm run dev

# Go back to editor window
<prefix>1
```

### Setting Up Automatically with a Script

Create a project-specific setup script (discussed more in the automation section
below). This is especially useful for projects you open daily.

---

## Part 5 — auto-session + tmux: Resuming Exactly Where You Left Off

### What auto-session Does

The `auto-session` plugin (already in this config) automatically saves and
restores Neovim's state on a per-directory basis. When you open Neovim in a
directory, it restores:

- Open buffers
- Window/split layout
- Cursor positions
- (Optionally) search history

**Key behaviour:** The session is keyed to the working directory, not to a
session name. So if your tmux session always `cd`s to the project root before
opening Neovim, auto-session picks up the right session.

### The Combined Workflow

```
1. <C-f> → pick "mfansible" project
   → tmux creates/switches to "mfansible" session
   → Neovim isn't open yet (first launch of the day)

2. Press <prefix>1 to go to the editor window
   → cd ~/Desktop/workspaces/github/DreamEcho100/mfansible
   → nvim .
   → auto-session kicks in: restores your last Neovim state in this directory
   → You're back to the exact files you had open yesterday

3. Do work. Neovim auto-saves the session on exit (:q).

4. <C-f> → pick "my-api" project
   → tmux switches session (mfansible is still alive, just backgrounded)
   → You're in my-api, open Neovim, auto-session restores that project's state

5. At the end of the day: <prefix>d to detach
   → Everything is preserved exactly as is
   → Tomorrow: tmux attach → all sessions still there (unless you rebooted)
```

### auto-session Keymaps in This Config

| Key | Action |
|-----|--------|
| `<leader>qs` | Save current session manually |
| `<leader>qr` | Restore session for current directory |
| `<leader>qd` | Delete session for current directory |
| `<leader>qf` | Find/switch sessions (Telescope picker) |

Use `<leader>qf` as an alternative to `<C-f>` if you want to pick from
previously saved Neovim sessions rather than arbitrary directories.

### tmux-resurrect / tmux-continuum (Optional)

For the full "never lose your tmux layout" experience, add these TPM plugins
(they're commented out in `tmux.conf`):

```bash
# Uncomment in tmux.conf:
set -g @plugin 'tmux-plugins/tmux-resurrect'   # save/restore pane layout
set -g @plugin 'tmux-plugins/tmux-continuum'   # auto-save every 15 min

run '~/.tmux/plugins/tpm/tpm'
```

With tmux-resurrect:
- `<prefix>Ctrl+s` — save the entire tmux state (sessions, windows, panes, commands)
- `<prefix>Ctrl+r` — restore after a reboot

With tmux-continuum, saving is automatic. After a reboot, run `tmux new-session`
(or the sessionizer) and the plugin prompts you to restore.

**Setup:**
```bash
# Install TPM first (one-time)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Then in a running tmux session:
<prefix>I     # Install plugins (capital I)
```

---

## Part 6 — The `ready-tmux` Pattern: Project Startup Automation

### The Problem

Every time you start work on a project, you do the same dance: open tmux, create
a session, open Neovim, start the dev server, set up the test runner... It's
fine once. After the 50th time it's just tedium.

The `ready-tmux` pattern is a per-project startup script that does all of this
for you.

### A Simple Example

Create this at `~/Desktop/workspaces/mfansible/.ready-tmux.sh`:

```bash
#!/usr/bin/env bash
# .ready-tmux.sh — project workspace setup script

SESSION="mfansible"
WORKDIR="$HOME/Desktop/workspaces/github/DreamEcho100/mfansible"

# If session already exists, just attach
if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux switch-client -t "$SESSION" 2>/dev/null || tmux attach-session -t "$SESSION"
    exit 0
fi

# Create the session with the editor window
tmux new-session -ds "$SESSION" -n editor -c "$WORKDIR"

# Window 2: git / misc
tmux new-window -t "$SESSION:2" -n git -c "$WORKDIR"
tmux send-keys -t "$SESSION:2" "git log --oneline -20" Enter

# Window 3: ansible test run
tmux new-window -t "$SESSION:3" -n ansible -c "$WORKDIR"

# Go back to window 1, open Neovim
tmux send-keys -t "$SESSION:1" "nvim ." Enter

# Attach
tmux switch-client -t "$SESSION" 2>/dev/null || tmux attach-session -t "$SESSION"
```

Make it executable:
```bash
chmod +x ~/Desktop/workspaces/mfansible/.ready-tmux.sh
```

Run it:
```bash
~/.ready-tmux.sh
# or
~/.local/bin/mfansible    # if you alias it
```

### A Go Project Template

```bash
#!/usr/bin/env bash
SESSION="my-go-service"
WORKDIR="$HOME/Desktop/workspaces/my-go-service"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux switch-client -t "$SESSION" 2>/dev/null || tmux attach-session -t "$SESSION"
    exit 0
fi

tmux new-session -ds "$SESSION" -n editor -c "$WORKDIR"

# Window 2: test watcher (gotestsum --watch)
tmux new-window -t "$SESSION:2" -n tests -c "$WORKDIR"
tmux send-keys -t "$SESSION:2" "gotestsum --watch ./..." Enter

# Window 3: running service
tmux new-window -t "$SESSION:3" -n server -c "$WORKDIR"
tmux send-keys -t "$SESSION:3" "go run ./cmd/server/main.go" Enter

# Window 4: database / misc
tmux new-window -t "$SESSION:4" -n misc -c "$WORKDIR"

# Go to editor, open Neovim
tmux send-keys -t "$SESSION:1" "nvim ." Enter
tmux switch-client -t "$SESSION" 2>/dev/null || tmux attach-session -t "$SESSION"
```

### A C/C++ Project Template

```bash
#!/usr/bin/env bash
SESSION="my-cpp-project"
WORKDIR="$HOME/Desktop/workspaces/my-cpp-project"

if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux switch-client -t "$SESSION" 2>/dev/null || tmux attach-session -t "$SESSION"
    exit 0
fi

tmux new-session -ds "$SESSION" -n editor -c "$WORKDIR"

# Window 2: cmake build output watcher
tmux new-window -t "$SESSION:2" -n build -c "$WORKDIR"
tmux send-keys -t "$SESSION:2" "cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build" Enter

# Window 3: run the binary
tmux new-window -t "$SESSION:3" -n run -c "$WORKDIR"
# don't auto-run yet — wait for build to succeed

# Go to editor, open Neovim
tmux send-keys -t "$SESSION:1" "nvim ." Enter
tmux switch-client -t "$SESSION" 2>/dev/null || tmux attach-session -t "$SESSION"
```

---

## Part 7 — Neovim Terminal vs tmux Pane

### Two Ways to Run Commands

You have two choices for running shell commands alongside Neovim:

| Option | How | Best For |
|--------|-----|----------|
| **Neovim terminal** | `:ToggleTerm` or `<leader>tt` | Quick one-off commands, short output |
| **tmux pane** | `<prefix>-` or `<prefix>\|` | Long-running processes, servers, build output |

### Neovim Terminal (`:ToggleTerm`)

Opened with `<leader>tt` or `:ToggleTerm`. It's a real bash terminal embedded
in a Neovim buffer. Use it for:

- Running a single command and seeing the output
- `git add` / `git commit` (though Neogit is better for this)
- Quick `ls` or file manipulation
- Things that take < 5 seconds

Exit terminal insert mode: `<C-\><C-n>` (back to normal mode), then navigate
or close normally.

**When NOT to use it:** Long-running servers, build watchers, test runners. These
block Neovim's event loop in some configurations and also disappear when you
quit Neovim. Put those in tmux panes instead.

### tmux Pane (Preferred for Long-Running Processes)

Use a tmux pane for anything that runs in the background:

```
<prefix>-          → split horizontally (new pane below)
<prefix>|          → split vertically (new pane to the right)
```

Then start your long-running process:
```bash
npm run dev
# or
go test ./... -count=1 -v
# or
cmake --build build/ --parallel
```

The process keeps running even if you switch to Neovim or another window. You
can glance at it with `<C-j>` (move to the pane below) without losing your
Neovim context.

### The Hybrid Layout (Most Common)

For daily work, the most common layout combines both:

```
┌────────────────────────────────────────────────────────────┐
│ Window 1: "editor"                                         │
│                                                            │
│ ┌───────────────────────────────────────┐ ┌─────────────┐ │
│ │                                       │ │             │ │
│ │           Neovim (full code)          │ │  tmux pane  │ │
│ │                                       │ │  (terminal) │ │
│ │                                       │ │             │ │
│ │           70% of width                │ │  30% width  │ │
│ │                                       │ │  quick cmds │ │
│ └───────────────────────────────────────┘ └─────────────┘ │
└────────────────────────────────────────────────────────────┘
```

Create this with `<prefix>|` from the editor window. Neovim stays on the left
at full height, you run quick commands in the right pane, navigate between them
with `<C-h>` / `<C-l>`.

---

## Part 8 — Colour and `$TERM`: Fixing Common Display Issues

### The Most Common Visual Bug

You open Neovim inside tmux and the theme looks wrong — either the colours are
flat and washed out, or background colours "bleed" at the edges of text, or
italic fonts look wrong.

The root cause is almost always `$TERM` not being set correctly.

### Correct `$TERM` Setup

Our `tmux.conf` sets this correctly:
```bash
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
```

The first line tells tmux to set `$TERM=tmux-256color` inside tmux.
The second line adds the `RGB` capability flag, which tells applications
(including Neovim) that true 24-bit colour is available.

To verify it's working:
```bash
# Inside a tmux pane:
echo $TERM
# Should print: tmux-256color

# Check that 24-bit colour is supported:
printf "\x1b[38;2;255;100;0mTRUECOLOR\x1b[0m\n"
# Should print "TRUECOLOR" in orange if 24-bit works.
# If it prints garbage codes, your terminal doesn't support it.
```

### Terminal Emulator Requirements

True 24-bit colour requires a modern terminal emulator. Supported:
- Alacritty ✓
- Kitty ✓
- WezTerm ✓
- GNOME Terminal (recent versions) ✓
- VS Code integrated terminal ✓
- Windows Terminal ✓

Not supported (or limited):
- Old `xterm` ✗
- `rxvt` ✗

If you're on a supported terminal but still seeing issues:
1. Reload tmux config: `<prefix>r`
2. Restart Neovim
3. Run `:checkhealth` in Neovim and look for colour-related warnings

### Italics Not Working?

Some terminal/tmux combinations don't pass italics through. Fix:
```bash
# Add to tmux.conf (the override line becomes):
set -ag terminal-overrides ",xterm-256color:RGB:sitm=\E[3m:ritm=\E[23m"
```

Then `<prefix>r` to reload.

### Neovim's Built-in Check

Run `:checkhealth nvim` in Neovim. Look for the `terminal` section. It will
tell you exactly what's wrong with colour support.

---

## Part 9 — Escape Time: Why This Setting Matters

### The Symptom

You press `Escape` in Neovim insert mode. There's a noticeable delay (usually
200-300ms) before Neovim goes back to normal mode.

This is caused by tmux's escape-time default being too high. tmux buffers
escape sequences (like `Esc+[` for arrow keys) and waits to see if more
characters follow before deciding what to do.

### The Fix

Our `tmux.conf` already has:
```bash
set -s escape-time 10
```

This sets the wait to 10ms — long enough to catch real escape sequences (like
`Esc+[A` for the up arrow) but short enough that a lone `Escape` feels instant.

**Before this setting:** 300ms delay on every mode switch in Neovim.
**After this setting:** Imperceptible delay.

If you're forking this config or setting up tmux elsewhere, this is the most
impactful Neovim-specific tmux setting.

---

## Part 10 — Quick Reference

### All vim-tmux-navigator Keys

| Key | Action |
|-----|--------|
| `<C-h>` | Navigate left (Neovim split or tmux pane) |
| `<C-j>` | Navigate down |
| `<C-k>` | Navigate up |
| `<C-l>` | Navigate right |

### Sessionizer

| Context | Key / Command | Action |
|---------|--------------|--------|
| Inside Neovim | `<C-f>` | Open project picker (fzf) |
| Bare terminal | `tmux-sessionizer` | Open project picker |
| tmux | `<prefix>$` | Rename current session |
| tmux | `<prefix>s` | List/switch sessions |
| tmux | `<prefix>d` | Detach (session stays alive) |
| tmux | `<prefix>(` / `)` | Switch to previous/next session |

### Clipboard

| Source | Action | Result |
|--------|--------|--------|
| Neovim | `yy` | Line goes to system clipboard (unnamedplus) |
| Neovim | `"+y<motion>` | Explicit system clipboard yank |
| tmux copy mode | `v` then `y` | Selection goes to xclip (system clipboard) |
| Any pane | Middle-click | Paste from PRIMARY selection |
| Any pane | Ctrl+Shift+V | Paste from CLIPBOARD selection |
| Neovim | `p` or `"+p` | Paste from system clipboard |

### Terminal / Pane Choice

| Use This | When |
|----------|------|
| `:ToggleTerm` (`<leader>tt`) | Short commands, one-off output, git ops |
| tmux pane (`<prefix>-` or `\|`) | Long-running servers, watchers, build output |
| Separate tmux window (`<prefix>c`) | Completely separate workflows within same project |
| Separate tmux session (`<C-f>`) | Switching to a different project entirely |

---

## Exercises

Do these before moving on. They'll make everything in this chapter concrete.

### Exercise 1: Seamless Navigation

1. Open a new tmux session: `tmux new-session -s navtest`
2. Split the window vertically: `<prefix>|`
3. In the right pane, open Neovim: `nvim /tmp/test.txt`
4. In Neovim, split horizontally: `<leader>sh`
5. Now navigate between all three panes using only `<C-h/j/k/l>`
6. Verify you can go from the Neovim right split → Neovim left split → tmux
   left pane — all with the same keys
7. Clean up: `:q` to exit Neovim, `exit` to close panes, `<prefix>d` to detach

**Goal:** Prove to yourself that there's no boundary.

### Exercise 2: Cross-Boundary Copy

1. In a tmux session, open a bash pane with: `echo "Hello from tmux" && cat /etc/hostname`
2. Enter copy mode: `<prefix>[`
3. Navigate to the `Hello from tmux` line
4. Press `v` to start selection, select the line with `$`, press `y` to copy
5. Exit copy mode, split a new pane: `<prefix>|`
6. Open Neovim in the new pane: `nvim /tmp/paste-test.txt`
7. In insert mode, press `<C-r>+` (insert from `+` register = system clipboard)
8. Verify the text appeared

**Goal:** Understand the clipboard bridge in practice.

### Exercise 3: Sessionizer Workflow

1. Make sure `fzf` is installed: `which fzf`
2. Run `tmux-sessionizer` directly from a terminal
3. Pick a project directory (e.g., the mfansible repo)
4. Verify you land in a new tmux session named after the directory
5. Now switch back to your original session: `<prefix>s` → pick it
6. From inside Neovim (open any file), press `<C-f>`
7. Pick the same project directory again
8. Verify: you're instantly transported to that session

**Goal:** The sessionizer becomes your project switcher.

### Exercise 4: The Full Project Setup

Set up a proper workspace for the mfansible repo:

1. Run `tmux-sessionizer` and pick the mfansible directory
2. Rename window 1: `<prefix>,` → type `editor`
3. Open Neovim: `nvim .`
4. Create window 2: `<prefix>c` → name it `git` → run `git log --oneline -10`
5. Create window 3: `<prefix>c` → name it `misc` → leave it at bash
6. Navigate between windows with `<prefix>1`, `<prefix>2`, `<prefix>3`
7. From window 1 (Neovim), press `<C-f>` and pick a different project
8. Notice: the mfansible session is preserved in the background
9. Switch back: `<prefix>s` → pick mfansible → your Neovim is still there

**Goal:** Experience the "project = session" pattern.

### Exercise 5: Write a ready-tmux Script

Write a `.ready-tmux.sh` for any project you work on regularly:

1. Choose a project directory (your choice)
2. Create `.ready-tmux.sh` in its root
3. The script should:
   - Create a session named after the project (or attach if it exists)
   - Set up at least 2 windows: one with Neovim, one with a relevant command
   - Use `tmux send-keys` to pre-populate commands
4. Make it executable: `chmod +x .ready-tmux.sh`
5. Run it: `./.ready-tmux.sh`
6. Verify the session and windows are set up correctly

**Goal:** One command to go from "closed laptop" to "full dev environment".

---

## VSCode Comparison

| VSCode Workflow | This Workflow |
|----------------|---------------|
| Multiple VS Code windows for multiple projects | Multiple tmux sessions, one per project |
| Cmd+` to toggle terminal | `<C-j>` to move to pane below (or `<leader>tt` for toggleterm) |
| VS Code terminal (always disappears on restart) | tmux pane (survives detach, survives restart with resurrect) |
| VS Code workspace saved on disk | auto-session saves Neovim state per directory |
| Cmd+Shift+P → "Switch Project" | `<C-f>` → fzf → instant session switch |
| Terminal split inside VS Code | tmux pane (has its own scroll, its own copy mode, runs forever) |

---

_Next: Chapter 18 — C/C++ Development with clangd, CMake, codelldb, and neotest-ctest_
