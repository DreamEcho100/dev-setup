# 06 · Files, Buffers, Windows, and Tabs

> This is chapter 6 of the Neovim 0-to-Hero series. By the end of this chapter you will
> understand how Neovim thinks about open files, how to navigate between them at speed,
> how to arrange your screen into whatever layout you need, and how to pick up exactly
> where you left off after closing Neovim.

---

## Table of Contents

1. [The Confusion Cleared — The Mental Model You Need](#1-the-confusion-cleared)
2. [Buffers — The Open Files Layer](#2-buffers--the-open-files-layer)
3. [Windows — The Viewport Layer](#3-windows--the-viewport-layer)
4. [Tabs — The Layout Layer](#4-tabs--the-layout-layer)
5. [Oil.nvim — Edit the Filesystem Like a Buffer](#5-oilnvim--edit-the-filesystem-like-a-buffer)
6. [mini.files — The Tree Navigator](#6-minifiles--the-tree-navigator)
7. [Harpoon — Project Bookmarks](#7-harpoon--project-bookmarks)
8. [Snacks Picker — The Universal Finder](#8-snacks-picker--the-universal-finder)
9. [auto-session — Per-Directory Workspace Memory](#9-auto-session--per-directory-workspace-memory)
10. [Power User Day — A Narrative Walkthrough](#10-power-user-day--a-narrative-walkthrough)
11. [Complete Reference Table](#11-complete-reference-table)
12. [Exercises](#12-exercises)

---

## 1. The Confusion Cleared

If you are coming from VSCode, the first thing Neovim will do is confuse you about files. You
open a file, then open another, then wonder where the first one went. You try to "close a tab"
and instead close the entire window. You split the screen and have no idea how to get back to a
single pane. You save a bunch of work, close Neovim, come back the next morning, and your
entire setup is gone. This chapter exists to prevent all of that frustration.

The root of the confusion is that VSCode and Neovim use the word "tab" to mean completely
different things — and Neovim adds two extra concepts that VSCode simply does not have. Once
the model clicks, everything about Neovim file management makes perfect sense. Until it clicks,
you will be constantly surprised.

In **VSCode**, the model is intentionally simple and flat:

- Open a file and a tab appears at the top of the editor.
- Close the tab and the file is gone from your view.
- Tabs and files are the same concept. One file, one tab. End of story.
- Your "workspace" is basically a flat list of open file tabs with some panels on the sides.

That simplicity is wonderful for beginners and works fine for most workflows. But it falls apart
when you want to do things like: "I want to see `app.ts` and `types.ts` side by side, while
also being able to instantly flip to `utils.ts` without losing my split layout." In VSCode you
would reach for Editor Groups and Tab Groups, and managing those things manually gets messy.

**Neovim** separates the concept of "open files" into three completely independent layers, each
doing one thing well:

**Buffers** are the actual open files. A buffer is "a file loaded into memory." It may or may
not be visible on screen at any moment. You can have 30 buffers open and see none of them, or
you can see all of them simultaneously. Closing a window does not close the buffer inside it —
the file stays in memory, ready to show up instantly whenever you want it.

**Windows** are rectangles on screen that display a buffer. You can have as many windows as you
want, arranged in any combination of horizontal and vertical splits. Multiple windows can show
the same buffer simultaneously — useful for looking at two different parts of a long file. When
you close a window, the buffer it was showing is still open; it just has no viewport.

**Tabs** are named collections of window layouts. A Neovim tab is not a file at all — it is an
entire screen arrangement. Tab 1 might have a vertical split showing `app.ts` on the left and
`types.ts` on the right. Tab 2 might be a completely fresh full-screen `app.test.ts`. The same
buffers are always available regardless of which tab you are in; tabs are just different ways of
arranging your screen.

Here is what all three layers look like together:

```
┌─────────────────────────────────────────────────────────────────┐
│  TAB 1: "main"                                                  │
│  ┌──────────────────────────┬──────────────────────────────┐    │
│  │ Window A                 │ Window B                     │    │
│  │ [buffer: app.ts]         │ [buffer: types.ts]           │    │
│  │                          │                              │    │
│  │  const App = () => {     │  export type User = {        │    │
│  │    return <div/>         │    id: string                │    │
│  │  }                       │    name: string              │    │
│  │                          │  }                           │    │
│  └──────────────────────────┴──────────────────────────────┘    │
├─────────────────────────────────────────────────────────────────┤
│  TAB 2: "tests"                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ Window A                                                 │   │
│  │ [buffer: app.test.ts]                                    │   │
│  │                                                          │   │
│  │  describe('App', () => {                                 │   │
│  │    it('renders', () => { ... })                          │   │
│  │  })                                                      │   │
│  └──────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│  BACKGROUND BUFFERS (loaded in memory, not showing in any window)│
│  utils.ts  │  constants.ts  │  README.md  │  config.json  │ ... │
└─────────────────────────────────────────────────────────────────┘
```

Notice that `utils.ts`, `constants.ts`, `README.md`, and `config.json` are open — loaded into
memory, accessible instantly — but they are not currently displayed in any window. They live in
the buffer list, silently waiting. When you want one, it appears immediately; no disk read, no
delay.

> 💡 **VSCode vs Neovim: The Mental Model Comparison**
>
> | Concept                 | VSCode                 | Neovim equivalent               |
> | ----------------------- | ---------------------- | ------------------------------- |
> | Open file               | Creates a tab          | Loads a buffer                  |
> | "Tab"                   | = a file               | = a window layout (NOT a file)  |
> | Close tab               | Unloads the file       | Deletes buffer OR closes window |
> | Split editor            | Splits a tab group     | Creates a new window            |
> | See two files at once   | Open in two tab groups | Two windows, any buffers        |
> | Pinned tab              | Keeps file in tab bar  | Harpoon mark                    |
> | Workspace state         | Saved automatically    | auto-session (`<leader>ws/wr`)  |
> | "Workspace/Perspective" | Not really a concept   | Neovim Tab (layout)             |

Once this model is in your head, everything else in this chapter will make immediate sense.
Let's go through each layer in detail, starting with the foundational one.

---

## 2. Buffers — The Open Files Layer

A **buffer** is Neovim's word for "a file loaded into memory." Every file you open becomes a
buffer. Buffers persist until you explicitly delete them — closing a window does NOT close the
buffer inside it. This is the most important sentence in this section, so read it again.

Closing a window does not close the buffer.

This means you can have 20 files loaded in memory, only showing 2 of them on screen, and flip
between any of them instantly. No file re-reads, no delays, no "loading" — they are all there.

### Listing all your buffers

Run `:ls` or `:buffers` in command mode to see every open buffer:

```
:ls

  1 %a   "app.ts"                       line 42
  2 #h   "types.ts"                     line 1
  3  a   "utils.ts"                     line 15
  4  h   "constants.ts"                 line 1
  5  h + "README.md"                    line 8
```

**Reading the flags column:**

```
  [number]  [flags]  [filename]             [last cursor line]

Flags column (multiple can appear together):
  %    Current buffer — the one you are looking at right now
  #    Alternate buffer — the last buffer you were in before this one
  a    Active — currently displayed in at least one window
  h    Hidden — loaded in memory but not displayed in any window
  +    Modified — has unsaved changes (the red dot in VSCode)
  =    Read-only — cannot be modified
  -    Not modifiable
```

The `h` flag is what trips up VSCode users. That buffer is "hidden" — you cannot see it, but it
is fully loaded, with your cursor position preserved, ready to appear the instant you navigate
to it.

### Cycling through buffers

```
<Tab>      → go to the NEXT buffer (cycles forward through the buffer list)
<S-Tab>    → go to the PREVIOUS buffer (cycles backward through the buffer list)
```

This is the fastest way to flip through files when you have a handful open. Press `<Tab>` a
few times and you cycle through everything loaded in sequence. The order follows the buffer
list order (roughly the order you opened them).

### Jumping to a specific buffer

```
:b 3           → jump to buffer number 3 (use the number from :ls)
:b app         → jump to the first buffer whose name contains "app" (partial match)
:b utils.ts    → jump to utils.ts by its exact name
```

Partial matching is powerful: `:b test` will jump to your test file if you only have one file
with "test" in its name. If there are multiple matches, Neovim will ask you to be more specific.

### The alternate buffer — your two-file fast toggle

The `#` flag in `:ls` marks the **alternate buffer**. This is the previous buffer you were in —
the last file you were editing before you switched to the current one. You can toggle between
your current and alternate buffer with a single key:

```
Ctrl+^   (or  :e #  in command mode)
```

This is one of the most underused features in Neovim, and it is incredibly useful for a very
common workflow: you are editing two related files and constantly switching between them. Open
one, then the other, and now `Ctrl+^` bounces you back and forth with zero overhead. No
picker, no search, no cycling — just instant toggle between the two.

Common use cases:

- `app.ts` ↔ `app.test.ts` (implementation and its tests)
- `component.tsx` ↔ `component.module.css` (component and its styles)
- `main.go` ↔ `main_test.go` (Go implementation and tests)
- `schema.prisma` ↔ `migrations/*.sql` (schema and generated migration)

### Managing buffers with keymaps

```
<leader>bx   → delete/close the current buffer
               The buffer is removed from memory. The window stays open,
               showing the next available buffer or an empty buffer.

<leader>bo   → open a new empty buffer
               Creates a blank scratch buffer. Useful for quick notes,
               temporary pastes, or drafting something before saving.

<leader>bD   → delete buffer WITH a confirmation prompt (Snacks bufdelete)
               Safer than <leader>bx — if the buffer has unsaved changes,
               it asks before discarding. Good to use on important files.
```

> 💡 **VSCode equivalent**
>
> `<leader>bx` is like clicking the × on a VSCode tab. But notice the difference: in Neovim,
> deleting a buffer does not change your window layout. If you have a vertical split with two
> files, and you delete the buffer in the left pane, the left pane stays open (it just shows
> a different buffer or goes blank). In VSCode, closing the last tab in a split group collapses
> the group entirely. Neovim's behavior gives you more control.

### The buffer picker

When you have many buffers open and cycling gets tedious, use the picker:

```
<leader>pb   → Snacks buffer picker — fuzzy search all currently open buffers
<leader>pr   → recent files — all files you have opened recently (including closed ones)
```

The buffer picker shows every loaded buffer in a searchable list. Start typing any part of the
filename to filter instantly. This is your tool when you have 15+ buffers and you know the name
of the file you want.

The recent files picker (`<leader>pr`) goes further — it shows files from previous sessions too,
so you can reopen a file you closed a week ago without remembering where it lives.

### incline.nvim — The Floating Buffer Label

This config includes `incline.nvim`, which adds a small floating label in the **top-right
corner of each window** showing exactly which buffer that window is currently displaying. You
do not need to press anything — it is always there when you have multiple windows open.

```
┌──────────────────────────────┬──────────────────────────────────┐
│                    app.ts ▶  │                     types.ts ▶   │
│                              │                                  │
│  const App = () => {         │  export type User = {            │
│    return <div/>             │    id: string                    │
│  }                           │  }                               │
└──────────────────────────────┴──────────────────────────────────┘
```

At a glance you know what each pane is showing. This is especially valuable when you have
3 or 4 windows open and you are navigating between them with `Ctrl+H/J/K/L` — the labels tell
you exactly where you are without having to look at the file contents or the statusline.

---

## 3. Windows — The Viewport Layer

A **window** in Neovim is a rectangular viewport that shows a buffer. You can have as many
windows open simultaneously as you want, arranged in any combination of horizontal splits
(stacked top/bottom) and vertical splits (side by side).

Windows are purely about screen real estate. When you close a window, the buffer it was showing
is still open in memory — it is just not displayed anymore. You can open that buffer in another
window later and your cursor position will be exactly where you left it.

### Creating splits

```
<leader>sv   → vertical split   (creates a new window to the RIGHT showing the same buffer)
<leader>sh   → horizontal split  (creates a new window BELOW showing the same buffer)
```

After `<leader>sv` from inside `app.ts`:

```
┌─────────────────────────────┬──────────────────────────────────┐
│ Window A                    │ Window B                         │
│ [showing: app.ts]           │ [showing: app.ts — same buffer]  │
│                             │                                  │
│  const App = () => {        │  const App = () => {             │
│    return <div/>            │    return <div/>                 │
│  }                          │  }                               │
└─────────────────────────────┴──────────────────────────────────┘
```

Both windows show the same buffer initially. Navigate to Window B with `Ctrl+L`, then open a
different file there. Now you have the classic side-by-side view.

After `<leader>sh` from inside `app.ts`:

```
┌──────────────────────────────────────────────────────────────────┐
│ Window A [showing: app.ts]                                       │
│  const App = () => { return <div/> }                             │
├──────────────────────────────────────────────────────────────────┤
│ Window B [showing: app.ts — same buffer, different scroll]       │
│  const App = () => { return <div/> }                             │
└──────────────────────────────────────────────────────────────────┘
```

Horizontal splits are useful for looking at two different parts of a very long file (top shows
the function signature, bottom shows the implementation), or for having a terminal or output
buffer below your code.

### Navigating between windows

```
Ctrl+H   → move cursor focus to the LEFT window
Ctrl+J   → move cursor focus to the window BELOW
Ctrl+K   → move cursor focus to the window ABOVE
Ctrl+L   → move cursor focus to the RIGHT window
```

Think of H/J/K/L as directional compass for your windows — the same spatial logic as vim's
movement keys (`h`=left, `j`=down, `k`=up, `l`=right). Once this muscle memory forms, jumping
between splits becomes as natural as moving your cursor within a file.

> 💡 **VSCode equivalent**
>
> `Ctrl+H/J/K/L` in Neovim corresponds to VSCode's "Focus Left/Right/Above/Below Editor Group"
> commands, which in VSCode require `Ctrl+K` then `Ctrl+H/J/K/L` — a two-keypress sequence.
> Neovim's single-chord version is noticeably faster in practice.

### Resizing windows

```
Arrow Up     → make the current window TALLER (add 2 rows to height)
Arrow Down   → make the current window SHORTER (remove 2 rows from height)
Arrow Left   → make the current window NARROWER (remove 2 columns from width)
Arrow Right  → make the current window WIDER (add 2 columns to width)
```

Hold an arrow key to keep resizing in that direction. The adjacent windows shrink or grow to
fill the remaining space. This is one of the rare cases in this config where the arrow keys
are used — their usual movement function is replaced with window resizing, since `h/j/k/l`
covers all cursor movement needs in Normal mode.

### Layout management

```
<leader>se   → equalize all windows (make every window the same size as every other)
<leader>sx   → close the CURRENT window (the buffer inside stays open, just this viewport closes)
<leader>sm   → toggle zoom: maximize current window to fill the screen,
               press again to RESTORE all splits exactly as they were
```

`<leader>sm` (maximize/restore zoom) deserves special attention because it solves a very common
problem. You have a 3-way split set up just right, but you need to focus on one file for a while
without distractions. Press `<leader>sm` — the current window expands to fill the entire screen.
The other windows do not close; they are temporarily hidden. Press `<leader>sm` again and the
entire split layout is restored, each window exactly where it was before.

> 💡 **VSCode equivalent**
>
> `<leader>sm` is similar to Ctrl+K Z (VS Code Zen Mode) or the "Maximize Editor Group" button,
> but more surgical: only the focused window fills the screen, not the entire editor. Your
> sidebar, other panels, and the other windows in your layout are waiting behind the scenes
> and come back instantly on the second press.

### Common multi-window layouts

**Two panes side by side (the most common layout):**

```
# Start in app.ts, press <leader>sv, then Ctrl+L to move right
# Open types.ts in the right pane with <leader>pf or :e

┌──────────────────────┬──────────────────────────────────────────┐
│         app.ts ▶     │                           types.ts ▶     │
│                      │                                          │
│  import { User }     │  export type User = {                    │
│    from './types'    │    id: string                            │
│                      │    name: string                          │
│  const App = () => { │    email: string                         │
│    return <div/>     │  }                                       │
│  }                   │                                          │
└──────────────────────┴──────────────────────────────────────────┘
```

**Three panes (main + two reference files):**

```
# From app.ts: <leader>sv → Ctrl+L → <leader>sh
# Open types.ts top-right, utils.ts bottom-right

┌──────────────────────┬──────────────────────────────────────────┐
│         app.ts ▶     │                           types.ts ▶     │
│                      ├──────────────────────────────────────────┤
│  const App = () => { │                           utils.ts ▶     │
│    const user =      │  export const formatName =               │
│      getUser()       │    (user: User) => ...                   │
│    return <div/>     │                                          │
│  }                   │                                          │
└──────────────────────┴──────────────────────────────────────────┘
```

**Four-pane grid (full reference layout):**

```
# <leader>sv → split right
# Ctrl+H → go left → <leader>sh → split bottom left
# Ctrl+L → go right → <leader>sh → split bottom right

┌──────────────────────┬──────────────────────────────────────────┐
│         app.ts ▶     │                           types.ts ▶     │
├──────────────────────┼──────────────────────────────────────────┤
│     app.test.ts ▶    │                           utils.ts ▶     │
│                      │                                          │
└──────────────────────┴──────────────────────────────────────────┘

Use <leader>se to equalize all four windows after setting up.
Navigate between any quadrant with Ctrl+H/J/K/L.
```

---

## 4. Tabs — The Layout Layer

Neovim **tabs** are the most misunderstood concept for people coming from any modern editor.
Let's be absolutely clear about this before anything else:

> **A Neovim tab is not a file. It is a named layout of windows.**

When you open a new tab in Neovim, you get a completely fresh blank window arrangement. You
then set up whatever splits and windows you need inside that tab. Switching tabs changes your
entire screen layout — but your buffers are always available in any tab, regardless of which
tab is active.

The mental shift: think of Neovim tabs as "workspace perspectives" or "modes of work," not as
"open files."

### Tab operations

```
<leader>to   → open a NEW empty tab (blank screen, single window)
<leader>tx   → CLOSE the current tab (all its windows close, buffers stay loaded)
<leader>tn   → go to the NEXT tab (cycle forward)
<leader>tp   → go to the PREVIOUS tab (cycle backward)
<leader>tf   → open the CURRENT BUFFER in a brand new full-screen tab
               (leaves your current layout intact, opens this file alone)
```

`<leader>tf` is the most practically useful of these. You are deep in a 3-way split, you want
to focus completely on one file for a while. Press `<leader>tf` — that exact file opens in a
clean full-screen tab. You can focus, think, write. When done, press `<leader>tx` to close
the focused tab and you return to your original split layout unchanged.

### Tabs in practice — real workflows

**The "work mode" pattern:**

```
TAB 1: "coding"
  ┌──────────────┬──────────────────┐
  │ app.ts       │ types.ts         │
  └──────────────┴──────────────────┘

TAB 2: "tests"
  ┌──────────────────────────────────┐
  │ app.test.ts (full screen)        │
  └──────────────────────────────────┘

TAB 3: "config"
  ┌──────────────────────────────────┐
  │ package.json (full screen)       │
  └──────────────────────────────────┘

Switch between them with <leader>tn / <leader>tp
```

**The "focus mode" pattern:**

```
# You're in your normal coding layout (Tab 1)
# You need to deeply understand a complex function in utils.ts
<leader>tf        → utils.ts opens in Tab 2, full screen

# Deep focus editing...
# When done:
<leader>tx        → close Tab 2, return to your split layout in Tab 1
```

### Seeing all your tabs

```
:tabs

  Tab page 1
      app.ts
      types.ts
  Tab page 2
  >   app.test.ts
  Tab page 3
      package.json
```

The `>` marks the current tab. The listed files show what buffers are displayed in windows in
each tab. The `gt` and `gT` keys (native Neovim) also navigate forward/backward through tabs.

> 💡 **VSCode equivalent**
>
> Neovim tabs are most similar to VS Code's "New Window" feature (opening a completely separate
> editor instance) or the concept of "Editor Groups" in a multi-root workspace. VSCode's file
> tabs at the top of the editor are NOT like Neovim tabs — those are more like Neovim buffers.
> If you have ever used IntelliJ's "Perspectives" (Project, Debug, Git), Neovim tabs are
> essentially that concept: different screen arrangements for different work modes.

### When to use tabs vs splits vs buffers

This decision comes up constantly. Here is a clear guide:

- **Use buffers** when you have files open that you want accessible but not visible.
  "I have these 15 files in my project; let me load them all so switching is instant."

- **Use splits (windows)** when you want to see multiple files SIMULTANEOUSLY on screen.
  "I need to look at `types.ts` while editing `app.ts` — show them side by side."

- **Use tabs** when you want different WORK MODES you switch BETWEEN (not simultaneously).
  "Tab 1 is coding, Tab 2 is tests, Tab 3 is docs — I switch between them as tasks change."

---

## 5. Oil.nvim — Edit the Filesystem Like a Buffer

Oil.nvim is a file manager built around a radical idea: what if a directory listing were just
a text buffer, and editing the buffer made changes to the actual filesystem? You already know
how to edit text in Neovim. Why learn a separate file manager interface?

With Oil, you do not. You already know how to use it.

### Opening Oil

```
-            → open the parent directory of the current file in an Oil buffer
               (the most common entry point — works from any buffer)

<leader>-    → open Oil in a floating window centered on screen
               (does not cover your splits, overlays them temporarily)
```

Press `-` from inside `~/projects/myapp/src/components/Button.tsx` and Oil opens showing:

```
  ~/projects/myapp/src/components/
  ..
  Button.tsx
  Input.tsx
  Modal.tsx
  index.ts
```

This looks like a plain text file showing directory contents. That is because in Oil's world,
it IS a text file. You can move around with `j`/`k`, open things with `Enter`, and go up with
`-`. But the real power is what you can do by editing the text.

### Navigating in Oil

```
j / k        → move cursor up/down through the directory listing
Enter or l   → open the file under cursor OR enter a directory (navigate in)
- or H       → go UP to the parent directory (same key that opened Oil from a file)
Ctrl+S       → open file under cursor in a horizontal split
Ctrl+V       → open file under cursor in a vertical split
Ctrl+T       → open file under cursor in a new tab
q or <Esc>   → close Oil and return to your previous buffer
```

### The magic — editing the filesystem

The directory listing is an editable Neovim buffer. You use all your normal editing commands
on it, then press `:w` (write) to apply those text changes as real filesystem operations.

**Renaming a file:**

```
# Cursor is on the line:   Button.tsx
# Press cw (change word) or e then cb, type the new name:
ButtonComponent.tsx

# Press Escape, then:
:w

# Result: Button.tsx is renamed to ButtonComponent.tsx on disk
```

**Creating a new file:**

```
# Press o to open a new line below current line (or O for above)
# Type the new filename:
NewComponent.tsx

# Press Escape, then:
:w

# Result: NewComponent.tsx is created as an empty file on disk
```

**Deleting a file:**

```
# Navigate cursor to Modal.tsx
# Press dd to delete the line

# Press :w

# Result: Modal.tsx is deleted from disk (Oil confirms destructive operations)
```

**Moving a file:**

```
# Navigate cursor to Modal.tsx in the components/ directory
# Press dd to cut the line

# Navigate to the destination directory
# (use - to go up, Enter to go into subdirectories)

# Press p to paste the line

# Press :w

# Result: Modal.tsx is moved to the destination directory
```

**Creating a directory:**

```
# Add a new line ending with /
helpers/

# Press :w

# Result: helpers/ directory is created
```

**Renaming a directory:**

```
# The line says:   helpers/
# Change it to:    utilities/
# Press :w

# Result: helpers/ directory is renamed to utilities/
```

> 💡 **VSCode equivalent**
>
> Oil.nvim is like having the VSCode Explorer panel reimplemented as a Neovim text buffer.
> Every operation you would do with a GUI — rename with F2, delete with the Delete key, create
> with the new file button, move with drag-and-drop — becomes a text editing operation. For
> anyone already fluent in vim motions, this is dramatically faster than any GUI file explorer.
> Rename 5 files? A few `cw` operations and one `:w`. Create a directory tree? Type it out and
> `:w`. The vim muscle memory you have already built transfers completely.

### Oil floating window

`<leader>-` opens Oil as a centered floating window. This is useful when you are in a complex
split layout and do not want to replace one of your windows with a directory listing. The float
overlays your layout, you do your filesystem work, then close it and your layout is unchanged.

---

## 6. mini.files — The Tree Navigator

`mini.files` is a complementary approach to file navigation: a multi-column panel view where
each column represents a directory level, similar to macOS Finder's column view or the ranger
terminal file manager. Where Oil is best for quick filesystem edits in the current directory,
mini.files is better for exploring the project tree and understanding directory structure.

### Opening mini.files

```
<leader>ee   → toggle mini.files explorer open/closed
<leader>ef   → open mini.files AND navigate directly to the current file's location
               (reveals where the file you are editing lives in the project tree)
```

`<leader>ef` is the one you will use more often — it is the "show me where I am" command.
You are editing a deeply nested file and you want to see what else is nearby, or you want to
create a sibling file in the same directory. `<leader>ef` opens the tree already navigated
to your exact location.

### The multi-column interface

mini.files shows parent → current → child in a series of panels:

```
┌──────────────────┬────────────────────┬─────────────────────────┐
│ ~/projects/app/  │ src/               │ components/             │
│                  │                    │                         │
│  node_modules/   │  app.ts            │  Button.tsx         ◄── │
│  public/         │  components/  ───► │  Input.tsx              │
│  src/        ──► │  types.ts          │  Modal.tsx              │
│  package.json    │  utils.ts          │  index.ts               │
│  tsconfig.json   │                    │                         │
└──────────────────┴────────────────────┴─────────────────────────┘
     parent dir          current dir          child dir
```

The highlighted entry in the middle column (`components/`) is expanded into the right column.
The left column shows the parent. As you navigate deeper, columns are added and shifted.

### Navigation in mini.files

```
j / k        → move cursor up/down within the current column
l or Enter   → expand directory (adds a new right column) OR open file in editor
h or -       → go up / collapse (removes the rightmost column)
q or <Esc>   → close mini.files
```

The spatial model is: `l` goes deeper (right), `h` goes shallower (left). Same as vim
horizontal motion.

### Filesystem editing in mini.files

Like Oil, mini.files supports editing the filesystem through the text buffer:

```
Rename:   position cursor on a file, press r, type new name, Enter to confirm
Create:   press a, type filename (end with / for directory), Enter
Delete:   press d on a file or directory (D for confirmation dialog)
Copy:     press c on source, navigate to destination, press p to paste
Move:     press m (cut) on source, navigate, press p to paste
```

All changes require a final `:w` or the mini.files save command to be written to disk, similar
to Oil.

> 💡 **VSCode equivalent**
>
> `<leader>ef` is the equivalent of VS Code's "Reveal in Explorer" button — it opens the file
> tree panel scrolled to and highlighting your current file. `<leader>ee` is the equivalent of
> pressing `Ctrl+Shift+E` to toggle the Explorer panel open and closed. The multi-column layout
> is closer to macOS Finder column view than VS Code's traditional tree, which some people find
> more intuitive for understanding directory relationships.

---

## 7. Harpoon — Project Bookmarks

Here is a truth about software development: in any given work session, you spend approximately
80% of your time in the same 4-5 files. You might have 50 files open across your project, but
your actual editing loop is tight: edit the component, check the types file, run the test,
update the config. The same files, over and over.

Harpoon exists for exactly this reality. It is a project-local bookmark system that lets you
**mark up to 4 files and jump to any of them with a single keypress**. Not a fuzzy search, not
cycling through a list, not any kind of prompt — just press `<leader>h1` and you are in file 1.
Instantly. Every time. No matter what you were looking at before.

### Setting up your Harpoon list

```
<leader>ha   → add the current file to the Harpoon list
               (first add = slot 1, second add = slot 2, and so on)

<leader>hh   → open the Harpoon quick menu
               (shows all your marked files, lets you reorder or remove them)
```

The quick menu looks like this:

```
  ╭─────────────────────────────────────────────╮
  │  Harpoon                                    │
  │  ───────────────────────────────────────    │
  │  1  src/app.ts                              │
  │  2  src/types.ts                            │
  │  3  src/utils.ts                            │
  │  4  src/app.test.ts                         │
  │  ───────────────────────────────────────    │
  │  [q]uit  [d]elete under cursor              │
  ╰─────────────────────────────────────────────╯
```

In the quick menu, you can reorder files by using `dd` to cut a line and `p` to paste it
elsewhere. This lets you reassign which file is slot 1, 2, 3, or 4.

### Jumping to bookmarked files

```
<leader>h1   → jump to Harpoon file #1 (instant, no prompt, no confirmation)
<leader>h2   → jump to Harpoon file #2
<leader>h3   → jump to Harpoon file #3
<leader>h4   → jump to Harpoon file #4
<leader>hp   → go to the PREVIOUS file in the Harpoon list (cycle backward)
<leader>hn   → go to the NEXT file in the Harpoon list (cycle forward)
```

The jumps are unconditional. Press `<leader>h1` and you are in that file, cursor at its last
known position, immediately. Your previous buffer becomes the alternate buffer (`Ctrl+^`), so
you can always go back.

`<leader>hp` and `<leader>hn` are for when you want to cycle through all your Harpoon files
without remembering which number is which — useful if you have 4 marked files and want to
review all of them in order.

### The Harpoon workflow for a real session

```
# Start of session: navigate to your core files and mark them
<leader>pf → "app.ts" → Enter → <leader>ha     (now Harpoon #1)
<leader>pf → "types.ts" → Enter → <leader>ha   (now Harpoon #2)
<leader>pf → "api.ts" → Enter → <leader>ha     (now Harpoon #3)
<leader>pf → "app.test" → Enter → <leader>ha   (now Harpoon #4)

# During the session:
<leader>h1   → immediately in app.ts
<leader>h2   → immediately in types.ts
<leader>h1   → back in app.ts
<leader>h4   → immediately in app.test.ts
<leader>h3   → immediately in api.ts

# The whole thing feels like keyboard shortcuts for your browser tabs
# but smarter — the list is project-specific and cursor positions persist
```

### What makes Harpoon different from the buffer picker

Both Harpoon and `<leader>pb` (buffer picker) let you jump to open files. The difference:

- **`<leader>pb` (buffer picker)**: fuzzy search through ALL open buffers. Great when you have
  many files and you want to find one by typing part of its name.

- **Harpoon (`<leader>h1-4`)**: zero-overhead instant jump to a specific pre-defined file. No
  searching, no typing, no menu navigation. One keypress, one destination.

Use the picker for exploration. Use Harpoon for your core loop.

> 💡 **VSCode equivalent**
>
> The closest VSCode analog is pinned tabs combined with `Ctrl+1`, `Ctrl+2` etc. to jump to
> specific tab positions — but VSCode's tab order can shift around and the keyboard shortcuts
> are not always reliable. Harpoon's list is completely stable (you control the order), always
> project-specific (different Harpoon list per project directory), and persists across sessions.
> Think of it as intentional, stable keyboard shortcuts for your most important files.

---

## 8. Snacks Picker — The Universal Finder

While Harpoon handles your core 4 files, the Snacks picker handles discovery and navigation for
everything else. It is a fuzzy finder — a searchable, filterable interface for files, buffers,
recent files, keymaps, and more. Think of it as a command palette specifically tuned for file
and navigation tasks.

### File finding commands

```
<leader>pf   → find files
               Fuzzy searches all files in the current project directory.
               Type any part of a filename or path to filter.

<leader>pF   → smart picker (frecency + git context)
               More intelligent than plain file find — combines:
               • Files you open frequently (frecency algorithm)
               • Files changed in the current git branch
               • Files recently modified
               Shows the most contextually relevant files first.

<leader>pb   → open buffers picker
               Fuzzy searches only the files currently loaded in memory.
               Faster than <leader>pf when you know you already have it open.

<leader>pr   → recent files
               Files you have opened in recent Neovim sessions.
               Useful for returning to a file you closed yesterday.

<leader>pe   → explorer picker
               Shows the project tree inside the picker panel.
               Navigate directories and preview files before opening.
```

### Keymap discovery

```
<leader>pk   → search all keybindings
               Fuzzy search through every configured keymap in Neovim.
               Type the action name ("split", "buffer", "format", "lsp") to find its key.
               Essential when you cannot remember a specific binding.
```

`<leader>pk` is your "I forgot the key" escape hatch. It searches keymap descriptions, so
typing "buffer delete" finds `<leader>bx`, typing "vertical split" finds `<leader>sv`, etc.

### Inside the picker — navigation and opening

```
Ctrl+N or Arrow Down   → select next item in the list
Ctrl+P or Arrow Up     → select previous item in the list
Enter                  → open the selected item in the current window
Ctrl+V                 → open selected item in a vertical split (side by side)
Ctrl+X                 → open selected item in a horizontal split (top/bottom)
Ctrl+T                 → open selected item in a new tab
Ctrl+D                 → scroll the preview pane down
Ctrl+U                 → scroll the preview pane up
Esc                    → close the picker without opening anything
```

### The picker interface anatomy

```
┌──────────────────────────────────────────────────────────────────┐
│  > app                                           12 / 247 files  │
│  ──────────────────────────────────────────────────────────────  │
│  src/app.ts                                                      │
│  src/app.test.ts                                                 │
│  src/app.module.ts                    ┌────────────────────────┐ │
│  src/app.controller.ts                │  Preview               │ │
│  src/app.service.ts                   │                        │ │
│                                       │  import React from ... │ │
│                                       │  const App = () => {   │ │
│                                       │    return (            │ │
│                                       │      <div>Hello</div>  │ │
│                                       │    )                   │ │
│                                       │  }                     │ │
│                                       └────────────────────────┘ │
│                                                                  │
│  [Enter] open  [Ctrl+V] vsplit  [Ctrl+X] split  [Esc] close    │
└──────────────────────────────────────────────────────────────────┘

Top line: your search query + match count
Left panel: filtered results list
Right panel: preview of highlighted file
Bottom: key hints
```

The preview panel shows the content of the highlighted file in real time as you move through
the list. You can see exactly what is in a file before deciding to open it.

> 💡 **VSCode equivalent**
>
> | Neovim key   | VSCode equivalent                      |
> | ------------ | -------------------------------------- |
> | `<leader>pf` | Ctrl+P (Quick Open)                    |
> | `<leader>pF` | Ctrl+P with frecency sorting (GitLens) |
> | `<leader>pb` | Ctrl+Tab (switch open editors)         |
> | `<leader>pr` | File > Open Recent                     |
> | `<leader>pe` | Explorer panel file tree               |
> | `<leader>pk` | Ctrl+K Ctrl+S (Keyboard Shortcuts)     |

---

## 9. auto-session — Per-Directory Workspace Memory

When you close Neovim after a productive session and reopen it the next morning, what do you
want to happen? Do you want a blank slate — start fresh, figure out where you were? Or do you
want Neovim to remember exactly what you had open, where your splits were, and where your
cursor was in each file?

auto-session gives you the power to choose, with manual save and restore operations tied to
your current working directory.

### Session operations

```
<leader>ws   → SAVE the current session for this working directory
               Snapshot: all open buffers, window layout, tab structure,
               cursor positions in every buffer, current directory.

<leader>wr   → RESTORE the session for this working directory
               Loads the snapshot: reopens all buffers, recreates your splits,
               returns cursor to where it was in each file.
```

Sessions are keyed to your **current working directory** (the directory you ran `nvim` from,
or where you last did a `:cd`). If you open Neovim in `~/projects/frontend`, the session
saved there is completely separate from the session in `~/projects/backend`. Each project
gets its own memory.

### What gets saved in a session

When you execute `<leader>ws`, the session file records:

- **All open buffers**: every file you have loaded in memory
- **Window layout**: which windows exist, their sizes, their arrangement
- **Tab structure**: how many tabs, what windows each tab has
- **Cursor positions**: where your cursor is in every buffer
- **Scroll positions**: what part of each file was visible
- **Current working directory**: the project root

### The daily workflow pattern

```
# Morning arrival:
$ cd ~/projects/myapp
$ nvim
<leader>wr     → everything comes back
                 Your splits are restored.
                 Each file opens at the cursor position you left.
                 All your background buffers are loaded.

# Work normally throughout the day...
# Add files, change layouts, edit everywhere.

# Before closing (or when you want to snapshot a good state):
<leader>ws     → save this session

# Close Neovim:
:qa

# Tomorrow morning, same sequence.
```

### Why manual save/restore instead of automatic

VSCode saves workspace state automatically with no user action required. Why does Neovim use
manual control? Several practical reasons:

1. **Intentional snapshots**: You can save a session when your layout is exactly right, then
   restore to THAT specific state even after you have wandered into many other files in between.

2. **Multiple session states**: You can have different saved sessions for different work modes
   (debugging session, review session, refactoring session).

3. **Session corruption protection**: If Neovim crashes mid-session with uncommitted changes,
   you restore to your last explicit save, not some intermediate state.

4. **Fast startup option**: Sometimes you want to open Neovim and start fresh. Without
   auto-restore, a fresh `nvim` is genuinely blank.

> 💡 **VSCode equivalent**
>
> `<leader>ws` / `<leader>wr` is the manual equivalent of VS Code's automatic workspace state
> saving. VSCode does this silently when you close (recording which files were open, their
> scroll positions, etc.) and restores when you reopen the project. Neovim with auto-session
> is the same concept, with you in control of the save/restore cycle rather than it being
> fully automatic.

---

## 10. Power User Day — A Narrative Walkthrough

Let's walk through a complete real-world day using every tool from this chapter together. This
is the kind of workflow that, once you internalize it, makes Neovim feel genuinely faster than
any GUI editor for day-to-day development.

### Morning: arriving at the project

```
$ cd ~/projects/myapp
$ nvim
```

Neovim opens. Empty. But you know what to do:

```
<leader>wr   → restore the session from yesterday
```

Your screen fills back up. The vertical split you had — `app.ts` on the left, `types.ts` on
the right — is restored. The 8 background buffers you had open are all loaded. Your cursor is
exactly where you left off in each file. You did not lose any context. You are immediately back
in the zone you built up yesterday.

### Setting up today's Harpoon bookmarks

Today you are working on a new feature. Your core files will be slightly different:

```
<leader>hh   → open the Harpoon quick menu

# Current list: app.ts, types.ts, utils.ts, app.test.ts
# Today you need: app.ts, api.ts, auth.ts, app.test.ts

# In the quick menu, change slot 2:
# Navigate to the types.ts line
# Press d to remove it
# Navigate to slot 2 position
# Save and close the menu

<leader>pf → "api.ts" → Enter
<leader>ha → marks as next available slot

<leader>pf → "auth.ts" → Enter
<leader>ha → marks as next available slot
```

Now `<leader>h1` through `<leader>h4` give you instant access to your four files for today.

### Creating a productive split layout

```
# You're in app.ts (from the restored session)
# You want api.ts alongside it for this feature work

Ctrl+L          → move to the right window (which was showing types.ts)
<leader>h3      → swap this window to show api.ts instead

# Now: app.ts (left) | api.ts (right)
# Perfect layout for writing the feature
```

### Exploring and creating new files

A new helper module is needed. You want to add it to `src/lib/`:

```
-               → open Oil in the src/ directory (parent of current file app.ts)
j               → navigate down to lib/ directory
Enter           → enter the lib/ directory

# Oil shows the contents of src/lib/:
# database.ts
# http.ts

# Add a new file:
o               → new line in the Oil buffer
auth-helpers.ts → type the filename
<Esc>
:w              → file created on disk

Enter           → open auth-helpers.ts in the editor
<leader>ha      → add it to Harpoon if you will be working in it all day
```

### Focused work with zoom

You are writing a complex async function in `api.ts` that requires real concentration. You are
currently in your 2-pane split layout, but you want just this file:

```
Ctrl+L          → make sure you are in the api.ts window
<leader>sm      → api.ts expands to fill the entire screen
```

The left pane (app.ts) is still open and loaded — it is just temporarily invisible. You focus,
think deeply, write the complex function. When you are done:

```
<leader>sm      → split layout restores perfectly
```

Both windows are back, same sizes, same scroll positions. Nothing was lost.

### Context switching with tabs

A colleague asks you to quickly review a different part of the codebase — the database layer.
You do not want to disturb your current `app.ts | api.ts` layout:

```
<leader>to      → open a new empty Tab 2

# In this fresh tab:
<leader>pf → "database" → Enter

# Review the database module, check the schema:
<leader>sv      → split, open schema.prisma alongside it
Ctrl+H/L        → navigate between them

# Review done. Close this tab:
<leader>tx      → Tab 2 closes, you return to your app.ts | api.ts layout in Tab 1
```

Nothing about your Tab 1 layout was disturbed. The review context is gone, your coding context
is intact.

### Quick filesystem organization

You realize three component files should be in a subdirectory:

```
-               → open Oil in the components/ directory

# Oil shows:
# Button.tsx
# Input.tsx
# Modal.tsx
# FormField.tsx
# Table.tsx
# index.ts

# Create a "forms" subdirectory:
o               → new line
forms/          → type with trailing slash
<Esc>

# Move the form-related files:
# Navigate to FormField.tsx
# dd (cut the line)
# Navigate to forms/ line
# (enter the directory with Enter, paste:)
p               → paste FormField.tsx into forms/

# Repeat for other form files, then:
:w              → all filesystem changes applied at once
```

### End of day — saving your session

Your layout is perfect: `app.ts | api.ts` side by side, 12 buffers loaded, cursor positions
exactly right in each file. Before you close:

```
<leader>ws      → save this session

:qa             → close Neovim
```

Tomorrow:

```
$ cd ~/projects/myapp
$ nvim
<leader>wr      → everything back, exactly here
```

---

## 11. Complete Reference Table

### Buffers

| Key             | Action                                          |
| --------------- | ----------------------------------------------- |
| `<Tab>`         | Next buffer in the buffer list                  |
| `<S-Tab>`       | Previous buffer in the buffer list              |
| `<leader>bx`    | Delete current buffer (window stays open)       |
| `<leader>bo`    | Open a new empty buffer                         |
| `<leader>bD`    | Delete buffer with confirmation prompt (Snacks) |
| `<leader>pb`    | Buffer picker — fuzzy search open buffers       |
| `<leader>pr`    | Recent files picker (including closed files)    |
| `Ctrl+^`        | Toggle between current and alternate buffer     |
| `:ls`           | List all open buffers with flags                |
| `:b <name/num>` | Jump to buffer by partial name or buffer number |

**Buffer flags (from `:ls`):**

| Flag | Meaning                                       |
| ---- | --------------------------------------------- |
| `%`  | Current buffer (the one you are in)           |
| `#`  | Alternate buffer (previous buffer)            |
| `a`  | Active — displayed in a window                |
| `h`  | Hidden — loaded but not visible in any window |
| `+`  | Modified — has unsaved changes                |
| `=`  | Read-only                                     |

### Windows

| Key           | Action                                        |
| ------------- | --------------------------------------------- |
| `<leader>sv`  | Vertical split (side by side)                 |
| `<leader>sh`  | Horizontal split (top/bottom)                 |
| `<leader>se`  | Equalize all window sizes                     |
| `<leader>sx`  | Close current window (buffer remains open)    |
| `<leader>sm`  | Toggle zoom — maximize/restore current window |
| `Ctrl+H`      | Move focus to the window on the LEFT          |
| `Ctrl+J`      | Move focus to the window BELOW                |
| `Ctrl+K`      | Move focus to the window ABOVE                |
| `Ctrl+L`      | Move focus to the window on the RIGHT         |
| `Arrow Up`    | Resize current window taller (+2 rows)        |
| `Arrow Down`  | Resize current window shorter (−2 rows)       |
| `Arrow Left`  | Resize current window narrower (−2 columns)   |
| `Arrow Right` | Resize current window wider (+2 columns)      |

### Tabs

| Key          | Action                                       |
| ------------ | -------------------------------------------- |
| `<leader>to` | Open new empty tab                           |
| `<leader>tx` | Close current tab                            |
| `<leader>tn` | Go to next tab                               |
| `<leader>tp` | Go to previous tab                           |
| `<leader>tf` | Open current buffer in a new full-screen tab |
| `:tabs`      | List all tabs and their window contents      |
| `gt`         | Go to next tab (native Neovim)               |
| `gT`         | Go to previous tab (native Neovim)           |

### Oil.nvim

| Key           | Action                                       |
| ------------- | -------------------------------------------- |
| `-`           | Open parent directory of current file in Oil |
| `<leader>-`   | Open Oil in a floating window                |
| `j` / `k`     | Move cursor up/down in the directory listing |
| `Enter` / `l` | Open file or enter directory                 |
| `-` / `H`     | Go up to parent directory                    |
| `Ctrl+V`      | Open file in a vertical split                |
| `Ctrl+S`      | Open file in a horizontal split              |
| `Ctrl+T`      | Open file in a new tab                       |
| `:w`          | Apply all pending filesystem changes         |

### mini.files

| Key           | Action                                           |
| ------------- | ------------------------------------------------ |
| `<leader>ee`  | Toggle mini.files explorer panel                 |
| `<leader>ef`  | Open mini.files, reveal location of current file |
| `j` / `k`     | Move cursor up/down in current column            |
| `l` / `Enter` | Expand directory into right column, or open file |
| `h` / `-`     | Go up / collapse rightmost column                |
| `q` / `<Esc>` | Close mini.files                                 |

### Harpoon

| Key          | Action                                        |
| ------------ | --------------------------------------------- |
| `<leader>ha` | Add current file to Harpoon list              |
| `<leader>hh` | Open Harpoon quick menu (view/reorder/remove) |
| `<leader>h1` | Jump to Harpoon file #1                       |
| `<leader>h2` | Jump to Harpoon file #2                       |
| `<leader>h3` | Jump to Harpoon file #3                       |
| `<leader>h4` | Jump to Harpoon file #4                       |
| `<leader>hp` | Jump to previous file in Harpoon list         |
| `<leader>hn` | Jump to next file in Harpoon list             |

### Snacks Picker

| Key          | Action                                     |
| ------------ | ------------------------------------------ |
| `<leader>pf` | Find files in project (fuzzy)              |
| `<leader>pF` | Smart picker (frecency + git context)      |
| `<leader>pb` | Pick from open buffers                     |
| `<leader>pr` | Recent files (including previously closed) |
| `<leader>pe` | Explorer picker (tree-style browser)       |
| `<leader>pk` | Search all keybindings                     |

**Inside the picker:**

| Key            | Action                   |
| -------------- | ------------------------ |
| `Ctrl+N` / `↓` | Next item                |
| `Ctrl+P` / `↑` | Previous item            |
| `Enter`        | Open in current window   |
| `Ctrl+V`       | Open in vertical split   |
| `Ctrl+X`       | Open in horizontal split |
| `Ctrl+T`       | Open in new tab          |
| `Esc`          | Close picker             |

### auto-session

| Key          | Action                                        |
| ------------ | --------------------------------------------- |
| `<leader>ws` | Save session for current working directory    |
| `<leader>wr` | Restore session for current working directory |

---

## 12. Exercises

Work through these in order. Each one builds on skills from the previous. You will need a
directory with at least a few files — a real project is ideal.

---

### Exercise 1 — Buffer fundamentals

**Goal:** Understand the buffer/window distinction at a hands-on level.

1. Open Neovim with `nvim` in any directory.
2. Open four files using `:e <filename>` (use real project files, or create test files first
   with `:e test1.txt`, `:e test2.txt`, etc.).
3. Run `:ls` and carefully read every column. Identify:
   - Which buffer has the `%` flag (current buffer)?
   - Which buffer has the `#` flag (alternate buffer)?
   - Which buffers are hidden (`h` flag)?
4. Use `Ctrl+^` five times and observe how the `%` and `#` flags swap with each press.
5. Use `<Tab>` to cycle forward through all four buffers, then `<S-Tab>` to cycle backward.
6. Open `<leader>pb` (buffer picker), type part of a filename, and jump to it with Enter.
7. Delete two buffers with `<leader>bx`. Run `:ls` again and verify they are gone.
8. Bonus: modify one buffer (type something, do not save), then try `<leader>bx` vs
   `<leader>bD` and notice the difference in behavior.

---

### Exercise 2 — Window layouts

**Goal:** Build fluency with splits and window navigation.

1. Open a file and press `<leader>sv` to create a vertical split.
2. Move to the right pane with `Ctrl+L`, then open a different file there with `<leader>pf`.
3. In the right pane, press `<leader>sh` to split it horizontally (you now have 3 windows).
4. Open a third different file in the bottom-right pane.
5. Navigate between all three windows using only `Ctrl+H/J/K/L` for 2 minutes.
   Goal: make navigating between windows feel automatic, not deliberate.
6. Use arrow keys to resize the left window to be about 60% of the screen width.
7. Press `<leader>se` to equalize all windows.
8. Click into the top-right window with `Ctrl+K Ctrl+L` (or just `Ctrl+L` then `Ctrl+K`).
9. Press `<leader>sm` — that window fills the screen.
10. Press `<leader>sm` again — your full 3-pane layout is restored.

---

### Exercise 3 — Harpoon muscle memory

**Goal:** Make Harpoon jumps as automatic as Ctrl+1/2/3 in a browser.

1. Navigate to a real project with at least 4 meaningful files.
2. Open each of your 4 most-used files and add them to Harpoon in priority order:
   - Most important file → `<leader>ha` (this becomes slot 1)
   - Second most important → `<leader>ha` (slot 2)
   - Etc.
3. Open `<leader>hh` and confirm the quick menu shows all 4 in the right order.
4. Run `:bufdo bd` to close all buffers (this proves Harpoon is not just buffer cycling).
5. Jump to each file using `<leader>h1`, `<leader>h2`, `<leader>h3`, `<leader>h4`.
   Each jump should be instant and land at a sensible cursor position.
6. Practice your core loop: `<leader>h1` → make a small edit → `<leader>h2` → note something
   → `<leader>h1` → apply the note. Do this 10 times until it feels natural.
7. Bonus: use `<leader>hh` to reorder your files — drag your #4 file to become #1 by
   moving its line in the quick menu.

---

### Exercise 4 — Oil.nvim filesystem editing

**Goal:** Perform real filesystem operations without leaving Neovim.

1. Create a test directory: `:!mkdir -p /tmp/oil-exercise/src`
2. Open Neovim from that directory: `:cd /tmp/oil-exercise`
3. Create `main.ts` with `:e src/main.ts`, add some content, save.
4. Press `-` to open Oil in the `src/` directory.
5. Create 4 new files by adding lines to the Oil buffer and pressing `:w`:
   - `utils.ts`
   - `types.ts`
   - `constants.ts`
   - `helpers.ts`
6. Rename `helpers.ts` to `lib.ts` by changing the text and pressing `:w`.
7. Delete `constants.ts` by deleting its line and pressing `:w`.
8. Create a subdirectory: add a new line `components/` and press `:w`.
9. Move `utils.ts` into `components/` by cutting its line (`dd`), entering the `components/`
   directory, pasting the line (`p`), and pressing `:w`.
10. Verify everything is correct: `:!find /tmp/oil-exercise -type f`

---

### Exercise 5 — Full session workflow with everything

**Goal:** Chain together all the tools in a realistic workflow.

1. Navigate to a real project: `cd ~/projects/yourproject` (or create a test one).
2. Set up a specific layout:
   - Find and open your most-used file with `<leader>pf`.
   - Create a vertical split with `<leader>sv`.
   - Open a second related file in the right pane.
   - Add both files to Harpoon with `<leader>ha`.
3. Use Oil (`-`) to create one new file in the project.
4. Open that new file and add it to Harpoon as well.
5. Open a new tab with `<leader>to` and open a fourth file there.
6. Save the session: `<leader>ws`.
7. Close Neovim completely: `:qa`.
8. Reopen Neovim in the same directory: `nvim`.
9. Restore the session: `<leader>wr`.
10. Verify: Do your splits come back? Are your Harpoon bookmarks intact (`<leader>h1-3`)?
    Are all your buffers loaded (`:ls`)?
11. Use `<leader>pk` to search for "session save" and find the keymap you just used.
    Then search for "buffer delete" to find `<leader>bx`.
    This is how you discover any key you have forgotten.

---

_Continue to [Chapter 07 — LSP and Completions](./07-lsp-and-completions.md) to learn how_
_Neovim understands your code, provides intelligent completions, and helps you navigate and_
_refactor with language-aware precision._
