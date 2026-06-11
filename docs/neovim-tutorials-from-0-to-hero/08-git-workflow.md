# 08 · Git Workflow

> This is chapter 8 of the Neovim 0-to-Hero series. You have the editor configured, LSP
> working, and file navigation mastered. Now it is time to integrate git so deeply into your
> editor that you rarely need a terminal or external GUI for version control. This chapter
> covers five specialized git tools — Gitsigns, Diffview, Neogit, LazyGit, and Fugitive —
> and explains when and why to reach for each one.

---

## Table of Contents

1. [Git in Neovim vs VSCode — The Philosophy](#1-git-in-neovim-vs-vscode--the-philosophy)
2. [Gitsigns — Your Inline Git Companion](#2-gitsigns--your-inline-git-companion)
3. [Diffview — Side-by-Side Diffs and File History](#3-diffview--side-by-side-diffs-and-file-history)
4. [Neogit — The Full Git Status UI](#4-neogit--the-full-git-status-ui)
5. [LazyGit — Full TUI Inside Neovim](#5-lazygit--full-tui-inside-neovim)
6. [Fugitive — The Classic Git Integration](#6-fugitive--the-classic-git-integration)
7. [Branch Management](#7-branch-management)
8. [Complete Git Workflows Step by Step](#8-complete-git-workflows-step-by-step)
9. [Complete Reference Table](#9-complete-reference-table)
10. [Exercises](#10-exercises)

---

## 1. Git in Neovim vs VSCode — The Philosophy

In VSCode, git is handled by a single Source Control panel. You open it with Ctrl+Shift+G,
see all your changed files, stage them by clicking the + icons, write a commit message in a
text box, and press the checkmark to commit. Push happens with a button in the status bar.
It is a unified, visual, mouse-friendly workflow — everything in one place.

Neovim takes the opposite approach: multiple specialized tools, each excellent at one specific
aspect of git. This sounds more complex, but in practice it is faster because each tool is
optimized for its task. You do not open a heavy panel to check if the current line was changed;
you just glance at the gutter. You do not open a file tree to stage individual lines; the
staging keys are right there in Normal mode.

Here is the full toolkit and when to reach for each tool:

```
What do I want to do?
│
├── See what changed in the current file?
│     → Gitsigns (just look at the gutter, or <leader>gdi)
│
├── Jump between changed hunks in the file?
│     → Gitsigns (]h / [h)
│
├── Stage or unstage specific lines (not whole files)?
│     → Gitsigns (<leader>gs on hunk or visual selection)
│
├── Quick preview of what a hunk changed?
│     → Gitsigns (<leader>gp — floating diff popup)
│
├── Who wrote this line and when?
│     → Gitsigns (<leader>gbl for this line, <leader>gB to toggle all)
│
├── Commit, push, pull in a visual workflow?
│     → Neogit (<leader>gn — like VSCode Source Control)
│
├── Visual diff of the whole working tree vs HEAD?
│     → Diffview (<leader>gdo)
│
├── See the history of a specific file?
│     → Diffview (<leader>gdh — all commits that touched this file)
│
├── Resolve merge conflicts?
│     → Diffview (<leader>gdo — shows 3-pane conflict view)
│
├── Interactive rebase, squash, cherry-pick, bisect?
│     → LazyGit (<leader>lg — full TUI for complex operations)
│
├── Quick :Git command (log, stash, reflog...)?
│     → Fugitive (<leader>gf or just :Git <command>)
│
└── Switch branches quickly?
      → Snacks branch picker (<leader>gbr)
```

The key insight is that these tools are **complementary, not competing**. On a typical day you
might use Gitsigns constantly (it is always running in the background), Neogit once to commit,
Diffview when reviewing a pull request, and LazyGit once a week for rebasing. They do not
overlap; they cover different parts of the git workflow.

> 💡 **VSCode equivalent overview**
>
> | Neovim tool     | VSCode equivalent                                    |
> |-----------------|------------------------------------------------------|
> | Gitsigns        | SCM gutter decorations (built-in)                    |
> | Diffview        | Source Control diff view + Timeline panel            |
> | Neogit          | Source Control panel (Ctrl+Shift+G)                  |
> | LazyGit         | GitLens Graph + interactive rebase (paid features)   |
> | Fugitive        | Terminal git commands, no direct equivalent          |
> | Snacks `gbr`    | Branch picker in Source Control panel                |

---

## 2. Gitsigns — Your Inline Git Companion

Gitsigns runs silently in the background whenever you are in a file tracked by git. It
continuously compares the current buffer to the HEAD version and shows the differences
directly in your editing experience. No panel to open, no command to run — it is always there.

### The gutter signs

The narrow margin on the left side of your editor (the sign column, where line numbers appear)
shows colored indicators for changed lines:

```
  1  │     │  import React from 'react'
  2  │ ▎   │  import { useState } from 'react'          ← green bar: added line
  3  │     │
  4  │ ▎   │  const App = () => {                       ← yellow bar: changed line
  5  │     │    const [count, setCount] = useState(0)
  6  │     │
  7  │ ▌   │    return (                                 ← red fill: line(s) deleted above
  8  │     │      <div>{count}</div>
  9  │     │    )
 10  │     │  }
```

```
▎  (thin green bar)    → this line was ADDED (not in HEAD)
▎  (thin yellow bar)   → this line was CHANGED (different from HEAD)
▌  (thick red bar)     → lines were DELETED above this line
```

These indicators are always visible as you edit. You never have to run `git diff` to know
which lines you have changed — the gutter tells you immediately.

### Navigating between hunks

A **hunk** is a contiguous group of changed lines. Multiple separate changes in a file are
separate hunks:

```
Line 5-7:   added block (hunk 1)
Line 20-21: changed lines (hunk 2)
Line 35:    deleted line (hunk 3)
```

```
]h   → jump to the NEXT hunk in the current buffer
[h   → jump to the PREVIOUS hunk in the current buffer
```

Use `]h` and `[h` to hop between all the hunks in a file — reviewing each change in sequence
without scrolling. This is particularly useful when you have edited a file extensively and want
to review every modification before staging.

### Staging individual hunks and lines

This is where Gitsigns becomes significantly more powerful than VSCode's Source Control panel.
You can stage **individual hunks** (groups of changed lines), or even **specific lines within
a hunk** — much finer-grained control than staging entire files.

```
<leader>gs   → stage the hunk the cursor is currently IN (Normal mode)
               The hunk goes from "unstaged changed" to "staged" in git.

V, select lines, <leader>gs
             → stage ONLY the selected lines within a hunk (Visual mode)
               This is partial hunk staging — extremely useful when a hunk
               contains two separate changes and you only want to commit one.

<leader>gu   → UNSTAGE the hunk the cursor is in (undo a previous stage)
               Only works if you staged the hunk with Gitsigns earlier in
               the session.

<leader>gS   → stage ALL changes in the ENTIRE BUFFER at once
               Equivalent to: git add <current-file>

<leader>gR   → RESET the ENTIRE BUFFER to HEAD (discard ALL local changes)
               Destructive: all unsaved edits in this file are lost.
               There is no undo for a reset.
```

> 💡 **VSCode equivalent**
>
> The VSCode Source Control panel lets you stage individual files, and if you open the diff
> view you can stage individual lines by clicking. Gitsigns does the same with keyboard
> shortcuts. The Visual mode staging (`V` + `<leader>gs`) is more powerful than VSCode — you
> can stage an arbitrary selection of lines, not just the hunks VS Code detects.

### Reviewing hunks before staging

```
<leader>gp   → open a floating diff popup for the hunk under the cursor
               Shows the BEFORE and AFTER side by side without leaving the file.
               Press q or <Esc> to close.
```

The preview popup looks like:

```
  ╭─────────────────────────────────────────────────────────╮
  │  @@ -4,7 +4,8 @@                                        │
  │  - const App = () => {                                  │
  │  + const App: React.FC = () => {                        │
  │    const [count, setCount] = useState(0)                │
  │                                                         │
  │    return (                                             │
  ╰─────────────────────────────────────────────────────────╯
```

Green lines are additions, red lines are deletions. This is the quickest way to review a
change — position your cursor on any yellow/green gutter mark and press `<leader>gp`.

### Diffing the whole file

```
<leader>gdi  → diff current buffer vs HEAD (opens a side-by-side diff view)
<leader>gD   → diff current buffer vs its PARENT COMMIT
               (useful after amending or rebasing — shows what changed vs N-1)
```

`<leader>gdi` gives you a full split-window diff of the entire file against HEAD — not just
the hunk under the cursor. This is like `git diff HEAD -- current-file` visualized as a
side-by-side comparison.

### Blame

```
<leader>gbl  → detailed blame popup for the CURRENT LINE
               Shows: author name, email, commit hash, date, and commit message
               for the exact commit that last modified this line.

<leader>gB   → TOGGLE inline blame for every line in the file
               When active, each line shows a dim annotation at the end:
               "user@host • 3 days ago • feat: add user validation"
               Toggle it off when the annotations clutter your reading.
```

The line blame popup (`<leader>gbl`) is invaluable for answering "who wrote this and why":

```
╭──────────────────────────────────────────────────────────────────╮
│  a1b2c3d4  (Alice Johnson  2024-03-15 14:32:11 -0700  line 42)   │
│                                                                  │
│  feat: add strict null checking to user validation               │
│                                                                  │
│  The getUser function was returning null for inactive users      │
│  which caused downstream type errors. Added explicit null        │
│  check and a custom UserNotFoundError.                           │
╰──────────────────────────────────────────────────────────────────╯
```

### The hunk text object — ih

Gitsigns registers `ih` (inside hunk) as a text object you can use with operators:

```
vih    → visually SELECT the current hunk (then you can stage with <leader>gs)
dih    → DELETE the current hunk (discard just this change)
yih    → YANK the current hunk (copy the changed lines to clipboard)
```

This integrates hunk navigation with Neovim's operator system. `dih` is a particularly useful
shortcut for "I changed these lines but actually I don't want this change anymore."

---

## 3. Diffview — Side-by-Side Diffs and File History

Diffview provides two powerful views: a whole-repository diff of the current working tree, and
a per-file commit history. It is the tool for deep review — understanding what changed across
many files, or understanding how a file evolved over time.

### Opening Diffview

```
<leader>gdo  → open Diffview (working tree vs HEAD — shows ALL changed files)
<leader>gdc  → close Diffview (return to your previous layout)
<leader>gdh  → file history for the CURRENT file (all commits that touched it)
<leader>gdH  → full repository history (ALL commits, all files)
```

### The Diffview interface

When you open `<leader>gdo`, Diffview replaces your window layout with its own:

```
┌────────────────────┬──────────────────────────────────────────────┐
│  Changed Files     │                                              │
│  ────────────────  │                                              │
│  M  src/app.ts     │  ─────── src/app.ts ───────                 │
│  M  src/types.ts   │                                              │
│  A  src/utils.ts   │  - const App = () => {                      │
│  D  src/old.ts     │  + const App: React.FC = () => {            │
│                    │    const [count, setCount] =                 │
│                    │      useState(0)                             │
│  ────────────────  │                                              │
│  [q]uit  [?]help   │                                             │
└────────────────────┴──────────────────────────────────────────────┘
  M = modified   A = added   D = deleted   R = renamed
```

**Navigating Diffview:**

```
j / k (in file list)   → move through the list of changed files
Enter (on a file)      → open that file's diff in the right panel
]c / [c                → jump to next/prev change hunk within the current diff
q                      → close Diffview (same as <leader>gdc)
```

### File history — understanding how a file evolved

```
<leader>gdh  → open commit history for the current file
```

The file history view shows every commit that modified the current file, with a full diff
for each commit:

```
┌────────────────────────────────────┬──────────────────────────────┐
│  Commit History: src/app.ts        │                              │
│  ────────────────────────────────  │  diff for selected commit    │
│  a1b2c3d  feat: add strict types   │                              │
│  e4f5g6h  fix: null check in App   │  - const App = () => {      │
│  i7j8k9l  refactor: extract utils  │  + const App: FC = () => {  │
│  m0n1o2p  chore: initial commit    │                              │
│                                    │                              │
└────────────────────────────────────┴──────────────────────────────┘
```

This answers "how did this file change over time?" — you can navigate through the commit list
and see exactly what each commit did to this specific file.

> 💡 **VSCode equivalent**
>
> `<leader>gdh` is equivalent to VS Code's "Timeline" view (in the Explorer panel, at the
> bottom) — a per-file history with diffs for each entry. `<leader>gdo` is equivalent to
> the Source Control diff view, but shows all files in a navigable panel rather than individual
> file comparisons.

### Merge conflict resolution

When you run `git merge` or `git rebase` and encounter conflicts, Diffview provides the most
powerful conflict resolution interface available in Neovim.

Open Diffview during a merge conflict (`<leader>gdo`) and it automatically shows a **3-pane
view** for each conflicted file:

```
┌──────────────────┬──────────────────────┬──────────────────────┐
│  OURS            │  BASE (common        │  THEIRS              │
│  (current branch)│  ancestor)           │  (incoming branch)   │
│                  │                      │                      │
│  function auth() │  function auth() {   │  function auth() {   │
│  {               │    return            │    return            │
│    return        │      validateUser()  │      verifyUser()    │
│      checkUser() │  }                   │  }                   │
│  }               │                      │                      │
└──────────────────┴──────────────────────┴──────────────────────┘
                   ▲ The center panel is where you edit the resolution
```

**Conflict resolution workflow:**

```
# In the center (BASE) panel, you see the raw conflict markers:
# <<<<<<< HEAD
# your changes
# =======
# their changes
# >>>>>>> feature-branch

# Option 1: Accept ours (left panel)
# In center panel, position cursor on conflict → dp (diff put from left panel)

# Option 2: Accept theirs (right panel)
# In right panel, position cursor → dp (diff put to center panel)

# Option 3: Manual merge
# Edit the center panel directly to write the correct merged result

# When all conflicts are resolved:
# Save the center file with :w
# Stage it with <leader>gs
# Continue the merge/rebase
```

The 3-pane view makes it much clearer which version you want to keep — you see both sides
simultaneously rather than reading through conflict markers in a single file.

---

## 4. Neogit — The Full Git Status UI

Neogit is a full-featured git status interface modeled after the Magit experience from Emacs.
It gives you a structured, keyboard-driven overview of your entire repository state.

### Opening Neogit

```
<leader>gn   → open the Neogit status buffer
```

### The Neogit interface

```
╔════════════════════════════════════════════════════════════════════╗
║  Head:     main  ↑1 ↓0  (1 commit ahead of origin/main)          ║
║  Push:     origin/main                                            ║
║                                                                    ║
║  Untracked files (2)                                               ║
║  ──────────────────────────────────────────────────────────────    ║
║  ?? src/helpers.ts                                                 ║
║  ?? tests/helpers.test.ts                                          ║
║                                                                    ║
║  Unstaged changes (3)                                              ║
║  ──────────────────────────────────────────────────────────────    ║
║  modified   src/app.ts                                             ║
║  modified   src/types.ts                                           ║
║  modified   src/utils.ts                                           ║
║                                                                    ║
║  Staged changes (1)                                                ║
║  ──────────────────────────────────────────────────────────────    ║
║  modified   src/constants.ts                                       ║
║                                                                    ║
║  Recent commits                                                    ║
║  ──────────────────────────────────────────────────────────────    ║
║  a1b2c3d  feat: add user validation                                ║
║  e4f5g6h  fix: correct type for getUserById return                 ║
╚════════════════════════════════════════════════════════════════════╝
```

### Key operations in Neogit

**Staging and unstaging:**

```
s              → stage the file/hunk under the cursor
                 On a file line: stages the entire file
                 On an expanded hunk line: stages just that hunk

u              → unstage the file/hunk under the cursor

S              → stage ALL unstaged changes (all modified tracked files)
U              → unstage ALL staged changes

Tab            → expand a file to show its hunks
                 Press Tab on "modified src/app.ts" to see the individual
                 changed sections within that file, then s/u on each hunk.
```

**Viewing diffs:**

```
d or <CR>      → open the diff for the file/hunk under the cursor
```

**Committing:**

```
c              → open the commit popup (shows options for the commit type)
cc             → create a regular commit (opens a commit message buffer)
ca             → amend the last commit (add current staged changes to it)
cf             → create a fixup commit (for interactive rebase squashing)
cw             → reword the last commit message
```

When you press `cc`, a buffer opens for your commit message:

```
# Enter your commit message above this line.
# Changes to be committed:
#
#   modified:   src/app.ts
#   new file:   src/helpers.ts
#
# Untracked files:
#   tests/helpers.test.ts
```

Write your commit message at the top. For a conventional commit format:

```
feat: add strict type validation to user API

The getUser function previously returned User | null which
required null checks at every call site. This change makes
the function throw UserNotFoundError instead, simplifying
all call sites and making the error visible in the type.

Closes #142
```

When done writing the message, press `:w` (or the configured submit key) to create the commit.
The commit buffer closes, Neogit refreshes, and you see the new commit in the Recent commits
section.

**Branch operations:**

```
b              → open the branch popup
b c            → create a new branch (prompts for name)
b b            → checkout an existing branch (fuzzy search)
b d            → delete a branch
b m            → merge a branch into current
b r            → rebase onto a branch
```

**Remote operations:**

```
p              → open the push/pull popup
p p            → push current branch to remote
p u            → push and set upstream (for new branches)
p f            → force push (with confirmation)
F              → open the fetch/pull popup
F p            → pull (fetch + merge)
F r            → pull with rebase
F u            → fetch all remotes
```

**Stash operations:**

```
z              → open the stash popup
z z            → stash all changes (prompts for message)
z p            → pop the top stash (apply and remove)
z a            → apply a stash (apply without removing)
z d            → drop a stash
```

**Closing Neogit:**

```
q              → close the Neogit buffer and return to your previous layout
```

> 💡 **VSCode equivalent**
>
> Neogit is the closest Neovim equivalent to VS Code's Source Control panel (Ctrl+Shift+G).
> The structure is similar: unstaged files at the top, staged below, commit message and button
> at the top. The main differences: Neogit is keyboard-only, supports hunk-level staging via
> Tab expansion, and has branch/push/pull operations integrated in the same interface.

---

## 5. LazyGit — Full TUI Inside Neovim

LazyGit is a standalone terminal UI (TUI) application for git. This config integrates it
directly into Neovim as a floating window. It is the most fully-featured git interface in the
toolbox and the right tool for complex operations.

### Opening LazyGit

```
<leader>lg   → open LazyGit in a floating window (full interface)
<leader>gl   → open LazyGit at the log/commits view
```

LazyGit opens as a large floating window overlaying your editor:

```
┌─────────────────────────────────────────────────────────────────────┐
│  Status    Files       Branches    Commits         Stash            │
│  ─────── ────────── ──────────── ─────────────── ────────────────   │
│                                                                      │
│  Files (3 changed)   Commits                    Diff                │
│  ─────────────────   ─────────────────────────  ──────────────────  │
│  M  src/app.ts       a1b2c3d feat: strict types  - const App = () { │
│  M  src/types.ts     e4f5g6h fix: null in App    + const App: FC =  │
│  A  src/helpers.ts   i7j8k9l refactor: utils     ...                │
│                                                                      │
│  [space]=stage  [c]=commit  [P]=push  [p]=pull  [?]=help           │
└─────────────────────────────────────────────────────────────────────┘
```

### LazyGit panel navigation

LazyGit has 5 main panels, switched with number keys or tab:

```
1   → Status panel (overview, current branch status)
2   → Files panel (changed files with staging)
3   → Branches panel (local and remote branches)
4   → Commits panel (full commit history)
5   → Stash panel (saved stashes)
```

Within each panel, `j`/`k` navigates. `?` opens the help for the current panel.

### When LazyGit is the right tool

**Interactive rebase** — squash, reorder, edit, or drop commits:

```
# In the Commits panel:
4               → open Commits panel
j/k             → navigate to the commit you want to start rebasing from
e               → start interactive rebase from this commit (opens rebase editor)
# In the rebase editor:
# s = squash, r = reword, d = drop, e = edit, p = pick (keep)
# Move commits with J/K
# Enter to start the rebase
```

**Cherry-picking commits:**

```
# In the Commits panel or another branch's commits:
c               → mark a commit for cherry-pick
4 j/k c         → navigate and mark multiple commits
Ctrl+R          → execute the cherry-pick to current branch
```

**Bisect operations:**

```
# In the Commits panel:
b               → start bisect (marks current state as bad)
g               → mark a commit as good (bisect converges to the bug)
R               → reset bisect
```

**Stash management:**

```
5               → open the stash panel
n               → create a new stash (prompts for message)
j/k             → navigate stashes
<space>         → apply a stash
g               → pop a stash (apply and remove)
d               → delete a stash
```

**Amend commit with current changes:**

```
4               → Commits panel
A               → amend the HEAD commit with currently staged changes
                  (equivalent to git commit --amend --no-edit)
```

**Force push (after rebase/amend):**

```
P               → open the push popup
f               → force push with lease (safer than --force)
```

Press `q` or `<Esc>` to close LazyGit and return to Neovim.

> 💡 **VSCode equivalent**
>
> There is no direct VS Code equivalent that covers everything LazyGit does. GitLens Pro's
> "Git Graph" and "Interactive Rebase Editor" cover some of it. The closest analogy is
> SourceTree or GitKraken — full standalone git GUI clients — except LazyGit runs inside
> your editor as a floating window with zero context-switching.

---

## 6. Fugitive — The Classic Git Integration

Fugitive (vim-fugitive) is the classic Vim/Neovim git integration, used by generations of
Vim users before Neogit existed. Its superpower is the `:Git` command — you can run any
arbitrary git command and see its output in a Neovim buffer.

### Opening Fugitive

```
<leader>gf   → open the Fugitive status buffer in a fullscreen tab
```

The Fugitive status buffer shows your git status in a navigable format:

```
  HEAD detached at a1b2c3d

  Changes to be committed (staged)
    modified   src/constants.ts

  Changes not staged for commit
    modified   src/app.ts
    modified   src/types.ts
    modified   src/utils.ts

  Untracked files
    src/helpers.ts
    tests/helpers.test.ts
```

### Key operations in Fugitive status buffer

```
s              → stage file under cursor
u              → unstage file under cursor
-              → toggle stage/unstage (smarter: stages if unstaged, unstages if staged)
cc             → create commit (opens commit message buffer, same as Neogit)
ca             → amend last commit
dd or dv       → open a vimdiff for the file under cursor (shows changes inline)
O              → open the file in the current window
q              → close the Fugitive buffer
```

### Using :Git commands

The real power of Fugitive is the `:Git` command family. You can run any git command and get
the output in a Neovim buffer that you can search, yank from, and navigate:

```
:Git log --oneline          → compact one-line log in a scrollable buffer
:Git log --graph --all      → full branch graph visualization
:Git blame                  → open git blame in a vertical split
:Git diff HEAD~3            → diff against 3 commits ago
:Git diff main..feature     → diff between two branches
:Git stash                  → stash current changes
:Git stash pop              → pop the top stash
:Git rebase main            → rebase current branch onto main
:Git cherry-pick a1b2c3d    → cherry-pick a specific commit
:Git reflog                 → show the reflog (great for recovering lost commits)
:Git bisect start           → start bisect
```

`:Git blame` is particularly useful — it opens a vertical split showing the blame for every
line with the commit hash, author, and date. Clicking (or pressing Enter in the blame buffer)
on a commit hash opens that commit.

### Fugitive push/pull bindings

This config adds additional keymaps for use within the Fugitive context:

```
<leader>gP    → push (git push)
<leader>gpr   → pull with rebase (git pull --rebase)
<leader>gup   → push and set upstream (git push -u origin HEAD)
               (use for new branches that do not have a remote yet)
```

### When to choose Fugitive vs Neogit

Both Fugitive and Neogit show a git status view and let you stage/commit. Choose based on
your workflow:

**Use Fugitive when:**
- You know the exact git command you want to run (`:Git <whatever>`)
- You want to run `git log`, `git blame`, or `git reflog` in a navigable buffer
- You need vimdiff for a specific file (`dv` in Fugitive status)
- You are comfortable with the classic Vim workflow

**Use Neogit when:**
- You want a structured visual workflow with clear sections
- You want to see all your hunks expanded and stage them individually
- You prefer the Magit-style interface for commits and branches

Many users use both: Neogit for the day-to-day commit workflow, and `:Git` commands via
Fugitive for anything unusual.

---

## 7. Branch Management

### Quick branch switching

```
<leader>gbr  → open the Snacks branch picker
               Fuzzy search all local AND remote branches.
               Enter to checkout the selected branch.
```

The branch picker shows:

```
╭─────────────────────────────────────────────────────────────╮
│  > feat                              4 branches             │
│  ────────────────────────────────────────────────────────   │
│  main                                                       │
│  feat/add-user-validation                                   │
│  feat/refactor-api-layer                                    │
│  feat/update-dependencies                                   │
│  remotes/origin/feat/hotfix-login                           │
╰─────────────────────────────────────────────────────────────╯
  [Enter]=checkout  [Ctrl+V]=new branch  [?]=help
```

### Creating a new branch

Multiple ways to create a branch depending on which tool you are in:

```
# Via Neogit:
<leader>gn → b → c → type branch name → Enter

# Via LazyGit:
<leader>lg → 3 (branches panel) → n → type branch name → Enter

# Via command line:
:Git checkout -b feature/new-feature

# Via Fugitive:
:Git switch -c feature/new-feature
```

### Branch cleanup

```
# Delete a merged local branch — via LazyGit:
<leader>lg → 3 → navigate to branch → d → confirm

# Delete via command:
:Git branch -d branch-name      → safe delete (fails if not merged)
:Git branch -D branch-name      → force delete

# Delete a remote branch:
:Git push origin --delete branch-name
```

### Viewing branch relationships

```
:Git log --graph --oneline --all    → full branch graph in a buffer
<leader>gl                          → LazyGit log view (visual branch graph)
```

---

## 8. Complete Git Workflows Step by Step

### Workflow 1 — Making a Feature Commit

The most common daily workflow: you have edited some files and want to make a clean commit.

```
STEP 1: Review what changed
Navigate to each changed file (you will see gutter indicators).
Use ]h / [h to hop between hunks in each file.
Use <leader>gp to preview each hunk before staging.

STEP 2: Stage your changes

Option A — Stage by hunk (recommended for clean commits):
  Navigate to the first hunk you want to include.
  Press <leader>gs to stage it.
  Use ]h to move to the next hunk.
  Repeat for each hunk you want in this commit.

Option B — Stage entire files:
  Open <leader>gn (Neogit).
  Press s on each file you want to stage.

Option C — Stage everything:
  Press <leader>gS (Gitsigns: stage entire buffer) for each file.
  Or in Neogit: press S to stage all unstaged changes at once.

STEP 3: Write the commit message
<leader>gn → cc (create commit)
Write a clear, present-tense commit message:
  feat: add validation for user email field
  
  Validates email format on both client and server side.
  Returns 400 with descriptive error if invalid.
:w to commit.

STEP 4: Push
Option A — Via Neogit: p → p (push)
Option B — Via Fugitive: <leader>gP
Option C — Command: :Git push
```

### Workflow 2 — Reviewing Changes Before Committing

Before a commit, do a thorough review of everything you are about to commit:

```
STEP 1: Open the full diff overview
<leader>gdo   → Diffview opens showing ALL changed files

STEP 2: Navigate through each file
j/k (in file list)   → move to each changed file
Enter                → see its full diff in the right panel
]c / [c              → jump between individual hunks

STEP 3: For each file, ask yourself:
- Is this change intentional?
- Are there any debug prints (console.log, fmt.Println) I forgot to remove?
- Does the code make sense without additional context?

STEP 4: Return to your editor
<leader>gdc   → close Diffview

STEP 5: Clean up anything you found, then commit per Workflow 1
```

### Workflow 3 — Resolving Merge Conflicts

You ran `git merge feature-branch` or `git pull` and there are conflicts:

```
STEP 1: Open Diffview to see the conflict view
<leader>gdo
Conflicted files appear with a special indicator (C or !)

STEP 2: Open a conflicted file
Navigate to it in the file list → Enter
The 3-pane view opens automatically: OURS | BASE | THEIRS

STEP 3: Resolve each conflict
For each conflict section in the CENTER (base) panel:

  Option A: Keep our version
  Navigate to the conflict in the LEFT panel → dp (diff put to center)

  Option B: Keep their version
  Navigate to the conflict in the RIGHT panel → dp

  Option C: Manual merge
  Edit the CENTER panel directly — remove the conflict markers
  (<<<<<<, =======, >>>>>>>) and write the correct merged result

STEP 4: Save and stage
:w to save the resolved file
<leader>gs to stage the resolved file (or <leader>gS for the whole file)

STEP 5: Continue the merge/rebase
:Git merge --continue    (if merging)
:Git rebase --continue   (if rebasing)

STEP 6: Commit the merge
<leader>gn → cc → write merge commit message if needed
```

### Workflow 4 — Fixing the Last Commit (Amend)

You made a commit but forgot to include a file, or you want to fix a typo in the message:

```
Case A: Add forgotten changes to the last commit

Stage the forgotten changes:
  <leader>gs (on the hunks/files you forgot)

Amend the commit:
  Option 1 — Via Neogit:  <leader>gn → c → a (amend)
  Option 2 — Via Fugitive: <leader>gf → ca
  Option 3 — Command: :Git commit --amend --no-edit
             (--no-edit keeps the existing message)

The staged changes are folded into the last commit. No new commit is created.

IMPORTANT: If you have already pushed this commit, you will need to force push:
  <leader>gup     (push with upstream set)
  Or: :Git push --force-with-lease   (safer than --force)
  Coordinate with your team — force pushing rewrites shared history.

Case B: Just fix the commit message (no code changes)

  Option 1 — Via Neogit:  <leader>gn → c → w (reword)
  Option 2 — Via Fugitive: <leader>gf → cw
  Option 3 — Command: :Git commit --amend
             (opens editor with current message for editing)
```

### Workflow 5 — Stashing and Restoring Work

You are in the middle of something but need to quickly switch branches or pull changes:

```
STEP 1: Stash your current work

Via LazyGit (most powerful for managing multiple stashes):
  <leader>lg → 5 (stash panel) → n → type stash message → Enter
  "wip: user validation mid-implementation"

Via command:
  :Git stash push -m "wip: user validation mid-implementation"

STEP 2: Do your other work
  <leader>gbr → checkout another branch → do work → commit

STEP 3: Return to your branch
  <leader>gbr → checkout original branch

STEP 4: Restore your stash

Via LazyGit:
  <leader>lg → 5 → navigate to your stash → g (pop — apply and remove)

Via Neogit:
  <leader>gn → z → p (pop stash)

Via command:
  :Git stash pop       → apply and remove the top stash
  :Git stash apply 0   → apply stash 0 without removing it (if you want to keep it)

STEP 5: Verify your work is restored
  Gitsigns gutter should show your in-progress changes again.
  Continue from where you left off.
```

---

## 9. Complete Reference Table

### Gitsigns (buffer-local — active in git-tracked files)

| Key            | Action                                                    |
|----------------|-----------------------------------------------------------|
| `]h`           | Jump to next hunk                                         |
| `[h`           | Jump to previous hunk                                     |
| `<leader>gs`   | Stage hunk under cursor (Normal) or selected lines (Visual)|
| `<leader>gr`   | Reset hunk to HEAD (discard this hunk only)               |
| `<leader>gS`   | Stage ENTIRE buffer (all changes in this file)            |
| `<leader>gR`   | Reset ENTIRE buffer to HEAD (discard ALL changes)         |
| `<leader>gu`   | Unstage the hunk under cursor                             |
| `<leader>gp`   | Preview hunk in floating diff popup                       |
| `<leader>gbl`  | Blame line — detailed popup (author, date, commit, msg)   |
| `<leader>gB`   | Toggle inline blame for all lines in file                 |
| `<leader>gdi`  | Diff current buffer vs HEAD                               |
| `<leader>gD`   | Diff current buffer vs parent commit                      |
| `ih`           | Text object: inside hunk (use with d, y, v, c operators)  |

### Diffview

| Key            | Action                                                    |
|----------------|-----------------------------------------------------------|
| `<leader>gdo`  | Open Diffview (working tree vs HEAD)                      |
| `<leader>gdc`  | Close Diffview                                            |
| `<leader>gdh`  | File history for current file                             |
| `<leader>gdH`  | Full repository history                                   |
| `j` / `k`      | Navigate file list (inside Diffview)                      |
| `]c` / `[c`    | Next / previous change hunk in diff                       |
| `q`            | Close Diffview                                            |

### Neogit

| Key            | Action                                                    |
|----------------|-----------------------------------------------------------|
| `<leader>gn`   | Open Neogit status                                        |
| `s`            | Stage file/hunk                                           |
| `u`            | Unstage file/hunk                                         |
| `S`            | Stage ALL unstaged changes                                |
| `U`            | Unstage ALL staged changes                                |
| `Tab`          | Expand file to show hunks                                 |
| `cc`           | Create commit (open commit message buffer)                |
| `ca`           | Amend last commit                                         |
| `cw`           | Reword last commit message                                |
| `b c`          | Create new branch                                         |
| `b b`          | Checkout branch                                           |
| `p p`          | Push to remote                                            |
| `F r`          | Pull with rebase                                          |
| `z z`          | Stash changes                                             |
| `z p`          | Pop stash                                                 |
| `q`            | Close Neogit                                              |

### LazyGit

| Key            | Action                                                    |
|----------------|-----------------------------------------------------------|
| `<leader>lg`   | Open LazyGit                                              |
| `<leader>gl`   | Open LazyGit at log/commits view                          |
| `1-5`          | Switch between panels (Status, Files, Branches, Commits, Stash)|
| `<space>`      | Stage/unstage file                                        |
| `c`            | Commit staged changes                                     |
| `A`            | Amend HEAD commit                                         |
| `P`            | Open push menu                                            |
| `p`            | Open pull menu                                            |
| `e`            | Start interactive rebase from selected commit             |
| `n`            | New stash (in stash panel) / New branch (in branch panel) |
| `g`            | Pop stash                                                 |
| `?`            | Show help for current panel                               |
| `q`            | Close LazyGit                                             |

### Fugitive

| Key / Command      | Action                                                |
|--------------------|--------------------------------------------------------|
| `<leader>gf`       | Open Fugitive status in fullscreen tab                |
| `<leader>gP`       | Push                                                  |
| `<leader>gpr`      | Pull with rebase                                      |
| `<leader>gup`      | Push with set-upstream (for new branches)             |
| `s` (in status)    | Stage file                                            |
| `u` (in status)    | Unstage file                                          |
| `cc` (in status)   | Create commit                                         |
| `ca` (in status)   | Amend commit                                          |
| `dv` (in status)   | Open vimdiff for file                                 |
| `:Git log`         | Git log in navigable buffer                           |
| `:Git blame`       | Git blame in a split                                  |
| `:Git diff HEAD~N` | Diff vs N commits ago                                 |
| `:Git stash`       | Stash changes                                         |
| `:Git stash pop`   | Pop the stash                                         |
| `:Git reflog`      | Show reflog                                           |

### Branch Management

| Key / Command          | Action                                            |
|------------------------|---------------------------------------------------|
| `<leader>gbr`          | Snacks branch picker (fuzzy search + checkout)    |
| `:Git checkout -b name`| Create and checkout new branch                    |
| `:Git branch -d name`  | Delete merged branch                              |
| `:Git branch -D name`  | Force delete branch                               |

---

## 10. Exercises

These exercises use a real git repository. If you do not have one handy, initialize one:
`:!git init /tmp/git-practice && cd /tmp/git-practice` and create a few files.

---

### Exercise 1 — Gitsigns navigation and staging

**Goal:** Stage individual hunks and lines using Gitsigns instead of staging whole files.

1. In a git repository, edit a file and make **three separate, non-adjacent changes**:
   - Change something near line 5
   - Change something near line 25
   - Add something near line 45
2. Save the file. Look at the sign column — you should see three distinct colored sections.
3. Use `]h` to navigate through each hunk. Count them (should be 3).
4. On each hunk, press `<leader>gp` to see the before/after in the floating popup.
   Close each popup with `q`.
5. Navigate to the FIRST hunk. Press `<leader>gs` to stage it.
6. Verify the staging worked: `:Git diff --staged` should show only the first change.
7. Navigate to the SECOND hunk. Use Visual mode to select only PART of it (V then j/k),
   then press `<leader>gs`. Check `:Git diff --staged` again — only the selected lines
   should be staged, not the whole hunk.
8. Press `<leader>gS` to stage everything remaining in this file.
9. Run `:Git diff --staged` one more time to see the full staged diff.
10. Unstage the second hunk using `<leader>gu` (navigate to it first with `]h`).

---

### Exercise 2 — Diffview file history

**Goal:** Use Diffview to understand how a file evolved.

1. Open any file in a git repository that has multiple commits in its history.
   If it is a new repository, make at least 3 commits that modify the same file.
2. Press `<leader>gdh` to open the file's commit history.
3. Navigate through the commit list with `j/k`. For each commit, observe the diff shown in
   the right panel — what exactly changed in that commit?
4. Navigate to the oldest visible commit for this file. What was the state of the file then?
5. Press `q` to close the history view.
6. Now press `<leader>gdo` to open the full working tree diff. If you have uncommitted
   changes, you will see them here. Navigate to your changed file with `j/k` and press Enter.
7. Jump between diff hunks with `]c` and `[c`.
8. Press `<leader>gdc` to close Diffview.

---

### Exercise 3 — Neogit commit workflow

**Goal:** Make a clean commit using Neogit with hunk-level staging.

1. Make two logically separate changes to two different files in a real project:
   - Change A: edit `file1.ts` (a feature change)
   - Change B: edit `file2.ts` (a different feature or fix)
2. Open Neogit: `<leader>gn`
3. In the "Unstaged changes" section, press `Tab` on `file1.ts` to expand and see its hunks.
4. Stage only the hunks related to one logical change by pressing `s` on specific hunks.
5. Do the same for `file2.ts` — expand with Tab, stage the relevant hunks.
6. Verify the "Staged changes" section shows exactly what you want in the commit.
7. Press `cc` to open the commit message buffer.
8. Write a commit message following the conventional commit format:
   ```
   type: short description

   Longer explanation if needed. What changed and why.
   ```
9. Press `:w` to commit. Verify the new commit appears in the "Recent commits" section.
10. Press `p p` to push (if you have a remote). Or just close with `q`.

---

### Exercise 4 — Resolving a merge conflict

**Goal:** Practice the 3-pane Diffview conflict resolution workflow.

1. Create a situation with a merge conflict:
   ```bash
   :!cd /tmp && git init conflict-test
   :cd /tmp/conflict-test
   :e main.ts
   ```
   Write: `const greeting = "hello"` and save, then commit:
   `:!git add main.ts && git commit -m "initial"`

2. Create two branches that both modify the same line:
   ```
   :!git checkout -b feature-a
   ```
   Change `"hello"` to `"hello world"`, save, commit.
   ```
   :!git checkout main
   :!git checkout -b feature-b
   ```
   Change `"hello"` to `"hi there"`, save, commit.

3. Merge feature-a into feature-b:
   ```
   :!git merge feature-a
   ```
   This should create a conflict.

4. Open `<leader>gdo` — Diffview should show the conflicted file.
5. Open the conflicted file. Observe the 3-pane layout.
6. Read both sides. Decide on the correct resolution (either one, or a combination).
7. Edit the center panel to contain the resolved content (remove conflict markers).
8. Save with `:w`.
9. Stage the resolved file with `<leader>gS`.
10. Close Diffview with `<leader>gdc`.
11. Open Neogit: `<leader>gn`. You should see the resolved file staged.
12. Create the merge commit: `cc` → write "Merge feature-a" → `:w`.

---

### Exercise 5 — LazyGit interactive rebase

**Goal:** Use LazyGit to squash multiple commits into one.

1. In a repository, create 3 consecutive commits with trivial content:
   ```
   :e scratch.ts → add "const a = 1" → :w → :!git add scratch.ts
   :!git commit -m "wip: first step"

   → change to "const a = 1; const b = 2" → :w → :!git add scratch.ts
   :!git commit -m "wip: second step"

   → change to "const a = 1; const b = 2; const c = 3" → :w → :!git add scratch.ts
   :!git commit -m "wip: final step"
   ```
2. Open LazyGit: `<leader>lg`
3. Navigate to the Commits panel: `4`
4. Use `j` to navigate to the OLDEST of your 3 wip commits (the bottom one).
5. Press `e` to start an interactive rebase from that point.
6. In the rebase editor, mark the second and third commits as `s` (squash) — they will be
   squashed into the first commit above them.
7. Confirm the rebase.
8. You will be prompted to edit the combined commit message — write something meaningful:
   `feat: add constants a, b, and c`
9. Confirm the message.
10. Verify the 3 wip commits are now one commit: press `4` in LazyGit and confirm you see
    only one commit for this change.
11. Press `q` to close LazyGit.

---

*Continue to [Chapter 09 — Debug, Test, and Build](./09-debug-test-build.md) to learn how to*
*run tests, set breakpoints, and execute build tasks without leaving Neovim.*
