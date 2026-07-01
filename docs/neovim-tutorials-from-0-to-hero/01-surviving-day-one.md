# 01 · Surviving Day One

> **Series:** Neovim 0 to Hero
> **Difficulty:** Absolute beginner — no prior Vim/Neovim knowledge assumed
> **Time:** ~45 minutes to read + exercises
> **Goal:** Open a file, edit it, save it, and quit — without panicking

---

Welcome. You're about to learn the most powerful text editor on the planet. Yes, that's a bold claim. Yes, it's also widely considered to be true by the kind of engineers who spend more time in their editor than anywhere else.

Here's the deal: the first hour of Neovim is the hardest. Everyone who's ever become proficient at it has also rage-quit it at least once in the first session. That's completely normal. What gets people through is understanding _why_ Neovim works the way it does — not just memorizing commands, but grokking the philosophy behind them.

By the end of this tutorial, you'll be able to open files, navigate around, make edits, save, and quit. That's the whole Day One goal. Modest on the surface — genuinely transformative in practice.

Let's go.

---

## 1. The Modal Editing Shock

The very first thing Neovim does to every VSCode refugee is deeply confuse them. You open a file, you start typing, and… nothing appears in the document. Or worse, something completely unexpected happens and you can't undo it. You hammer `Ctrl+Z` and it doesn't work. You try clicking with the mouse. You consider a career change.

What's happening?

Neovim is a **modal editor**. It has multiple _modes_, and what your keystrokes do depends entirely on which mode you're currently in.

### A Brief History of Why This Exists

Back in the 1970s, the original `vi` editor (Neovim's ancestor) was created for the ADM-3A terminal. This terminal had one particularly interesting property: **it had no dedicated arrow keys**. The arrow key symbols were printed on `h`, `j`, `k`, and `l`. You navigated with those letters.

More importantly, modems in that era were painfully slow — sometimes 300 baud, which is about 30 characters per second. You couldn't afford to waste a single keypress. The idea of holding `Ctrl` for every single editing command was expensive. Modes let you use the entire keyboard as a command palette when you're not typing text.

But here's the deep insight that makes modal editing genuinely _good_ rather than just _old_: **most of your time is spent reading and navigating code, not typing new characters**. Modal editing optimizes for the common case. Inserting text is the exception; moving, selecting, changing, and searching are the rule.

### The "You're Always in INSERT Mode" Analogy

> **💡 In VSCode you'd...** open a file and immediately start typing. Every key you press inserts a character. `Ctrl+C` copies. `Ctrl+V` pastes. `Ctrl+Z` undoes. You're always in "insert mode" — there's only one mode.
>
> **In Neovim you...** open a file and land in **Normal mode**. Nothing you type inserts characters. `h`, `j`, `k`, `l` move the cursor. `:` opens the command line. `u` undoes. Only after pressing `i`, `a`, `o`, or similar keys do you enter **Insert mode** and type text like you would in VSCode.

This is the core shift. VSCode has one mode. Neovim has several. The one you spend the most time in — **Normal mode** — is actually named after how it works: normally, you're navigating and manipulating, not inserting.

### The Golden Rule

> **If you're ever confused, lost, or stuck: press `Esc` (possibly several times). It always takes you back to Normal mode.**

Tattoo this on your brain. `Esc` is your safety net. `Esc` is home. When in doubt, press `Esc` and take stock of where you are.

### The Mode State Machine

Here's a diagram of the main modes and how you travel between them:

```
                    ┌─────────────────────────────────────────────────┐
                    │                                                 │
                    │          N O R M A L   M O D E                 │
                    │              (Home Base)                        │
                    │                                                 │
                    └──┬─────────────┬─────────────┬─────────────────┘
                       │             │             │
           ┌───────────┘   ┌─────────┘   ┌────────┘
           │               │             │
           │ i/a/o/A/I/O   │ v/V/Ctrl+V  │ :
           │ s (flash in   │             │
           │ this config)  │             │
           ▼               ▼             ▼
    ┌─────────────┐  ┌──────────────┐  ┌──────────────────┐
    │             │  │              │  │                  │
    │  INSERT     │  │  VISUAL      │  │  COMMAND-LINE    │
    │  MODE       │  │  MODE        │  │  MODE            │
    │             │  │              │  │                  │
    │ (type text  │  │ (select text │  │ (type :commands  │
    │  normally)  │  │  with hjkl)  │  │  or /searches)   │
    │             │  │              │  │                  │
    └──────┬──────┘  └──────┬───────┘  └────────┬─────────┘
           │                │                    │
           │   Esc          │   Esc              │  Esc or Enter
           └───────────────►│◄───────────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │               │
                    │  Back to      │
                    │  NORMAL MODE  │
                    │               │
                    └───────────────┘


  TERMINAL MODE (bonus):
  ┌──────────────────────────────────────────────────────────────┐
  │  Enter terminal: via :terminal or snacks terminal plugin     │
  │  Exit terminal (back to Normal): Ctrl+\ then Ctrl+N          │
  └──────────────────────────────────────────────────────────────┘
```

**There's also:**

- **Replace mode** — `R` key, overwrites characters (like `Insert` key in Windows). Not used often; just know it exists.
- **Operator-pending mode** — a transient state while Neovim waits for a motion after an operator like `d` (delete) or `c` (change). You'll learn about this in later tutorials.

---

## 2. Normal Mode — Your Home Base

This is it. The place where Neovim starts. The mode you return to with `Esc`. The default state of the editor.

**In Normal mode, every key is a command. Nothing you type inserts text into your file.**

Let that sink in. When you open Neovim and a file loads, you are in Normal mode. If you immediately start typing:

- `j` moves the cursor down — it does NOT type the letter "j"
- `d` starts a delete operation — it does NOT type the letter "d"
- `u` undoes the last change — it does NOT type the letter "u"

This is the shock. This is what makes beginners think "the editor is broken." It's not broken. You're in Normal mode.

### How Do You Know What Mode You're In?

Look at the bottom-left corner of the screen — the **status line**. In this config (using lualine.nvim), it shows:

```
 NORMAL     src/index.ts          100:1
 INSERT     src/index.ts          100:5
 VISUAL     src/index.ts          100:1 -- 100:8
```

The mode name in the bottom-left corner is your compass. Check it constantly when you're learning. After a few weeks, you won't need to anymore — you'll feel the mode in your fingers.

### Why Is This Actually Powerful?

Once it clicks, Normal mode becomes your superpower. Think about it: in VSCode, to delete a word, you have to:

1. Double-click to select the word
2. Press Delete (or Backspace)

Or hold `Ctrl` and press `Backspace`.

In Neovim Normal mode: `dw` — two keystrokes, no modifier keys, hands stay on home row. Delete (`d`) + word (`w`).

To delete an entire line: `dd`. Two keystrokes.
To delete from cursor to end of line: `D`. One keystroke.
To change (delete and start inserting) a whole word: `cw`.
To change the content inside quotes: `ci"`.

We'll get deep into this in later tutorials. For now, just know: Normal mode is where the magic happens, and your goal for Day One is simply to become comfortable returning to it.

---

## 3. Getting Into Insert Mode

Okay, so if Normal mode is where you start, how do you actually type text? There are several ways to enter Insert mode, and they differ in _where_ your cursor lands before you start typing. This is one of the first "aha" moments of Vim — each entry point is optimized for a different context.

### The Entry Points

| Key | What It Does                           | Best Used When                              |
| --- | -------------------------------------- | ------------------------------------------- |
| `i` | Insert BEFORE the cursor               | Most common — general purpose inserting     |
| `a` | Insert AFTER the cursor (append)       | Adding text after the current character     |
| `o` | Open new line BELOW and enter insert   | Adding a new line below current position    |
| `O` | Open new line ABOVE and enter insert   | Adding a new line above current position    |
| `I` | Insert at the START of the line        | Jumping to line beginning to type           |
| `A` | Insert at the END of the line (Append) | Appending to end of line — extremely common |
| `s` | _(In this config: Flash jump!)_        | See note below                              |

> **Note on `s` in this config:** In a stock Neovim, `s` deletes the current character and enters Insert mode (substitute). However, in **this configuration**, `s` is remapped to trigger **Flash.nvim** — the blazing-fast jump plugin. So `s` is a motion, not an insert entry. Don't try to use `s` to insert. Use `i` instead. We'll cover Flash in a dedicated tutorial.

### VSCode Comparisons

> **💡 In VSCode you'd...** click where you want to place the cursor and start typing. There's only one way to "insert" — click and type.
>
> **In Neovim you...** navigate your cursor to the general area you want to edit (using Normal mode movements), then choose the most efficient insert entry point. If you want to add text at the end of a line, `A` takes you directly there without having to navigate to the exact end first.

Here's the thing that blows VSCode users' minds once they get it: `o` (open line below) is _incredibly_ useful. In VSCode, to add a new line below your current line, you'd typically press `End` to go to end of line, then `Enter`. In Neovim: `o`. One key. Does it all.

Similarly, `O` (open line above) replaces `End`, `Enter`, `Up arrow` with a single keystroke.

And `A` (Append to end of line) replaces `End` then typing. Just `A` and you're there.

### After Entering Insert Mode

Once you're in Insert mode, you type text exactly like in any other editor. Backspace works. Delete works. The arrow keys work (though Neovim users prefer to exit Insert mode and navigate in Normal mode — more efficient once you're past the learning curve).

**Critical: Always press `Esc` when you're done inserting.** Don't leave Insert mode just sitting there. Go back to Normal mode when you're done with a "burst" of typing. Normal mode is home.

---

## 4. Escaping Insert Mode

There are three ways to leave Insert mode and return to Normal mode:

### The Options

| Key Combo | Notes                                                                                                                         |
| --------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `Esc`     | The classic. Works everywhere. Slightly far from home row on most keyboards.                                                  |
| `Ctrl+C`  | **Custom in this config** — mapped to `<Esc>` in Insert mode (see `keymaps.lua`). Faster to reach than `Esc` for most people. |
| `Ctrl+[`  | Vim standard alternative to `Esc`. Works in all Vim-compatible editors.                                                       |

In the config's `keymaps.lua`:

```lua
vim.keymap.set("i", "<C-c>", "<Esc>")
```

This is why `Ctrl+C` works as Escape in Insert mode here.

> **💡 In VSCode you'd...** never think about leaving "insert mode" because there isn't one. All your keys do what they say.
>
> **In Neovim you...** develop a muscle memory tick: finish a sentence or a change, press `Esc`, navigate to the next thing, press an insert key, make a change, press `Esc`. This rhythm becomes second nature within a few days.

### The "Press Escape a Lot" Advice

Here's advice you'll hear from every experienced Vim user: **press Esc more often than you think you need to.** There's no penalty for pressing Esc when you're already in Normal mode — it just clears search highlights or cancels incomplete operations. If you're unsure what mode you're in: `Esc`. If something weird is happening: `Esc`. If the cursor is blinking at you judgmentally: `Esc`.

In this config, `Esc` in Normal mode also clears multi-cursor selections and search highlights (from the multicursor plugin's keybinding), so it does double duty as a "cancel everything weird" key.

---

## 5. How to Quit (The Classic Problem)

Let's address the elephant in the room. The most famous Neovim/Vim meme is "how do I quit Vim?" with the punchline being that the answer isn't obvious. Here is the complete guide.

First: **you quit from Normal mode, using the command line.** Press `:` to enter Command-line mode, type the command, press Enter.

### The Quit Commands

| Command | What It Does                               | Use When                                             |
| ------- | ------------------------------------------ | ---------------------------------------------------- |
| `:q`    | Quit                                       | No unsaved changes, single window                    |
| `:q!`   | Quit without saving (force)                | You want to discard changes                          |
| `:w`    | Write (save) file                          | You want to save without quitting                    |
| `:wq`   | Write and quit                             | Save and exit — very common                          |
| `:wq!`  | Write and quit (force)                     | Force save even if readonly (if you have permission) |
| `:x`    | Save and quit (only writes if changed)     | Like `:wq` but smarter about timestamps              |
| `:qa`   | Quit ALL windows/buffers                   | Close everything                                     |
| `:qa!`  | Quit all, discard all changes              | Nuclear option — close everything without saving     |
| `ZZ`    | Save and quit (Normal mode shortcut)       | Equivalent to `:wq`                                  |
| `ZQ`    | Quit without saving (Normal mode shortcut) | Equivalent to `:q!`                                  |

**Custom in this config:** `Ctrl+Q` is mapped to `:q` for quick quitting:

```lua
keymap.set('n', '<C-q>', '<cmd> q <CR>', { desc = 'Quit file' })
```

### The "Don't Panic" Box

```
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║   YOU ARE STUCK — EMERGENCY PROCEDURE                    ║
║                                                          ║
║   1. Press Esc (press it 3+ times to be sure)           ║
║   2. Now you're in Normal mode                           ║
║   3. Type:  :qa!                                         ║
║   4. Press Enter                                         ║
║   5. Neovim closes. Everything is fine.                  ║
║                                                          ║
║   (You lost unsaved work, but you escaped)               ║
║                                                          ║
║   If :qa! doesn't work, try :q! or just close           ║
║   the terminal window. The file isn't changed.           ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
```

The fear of "what if I accidentally change something and can't save or quit" is what paralyzes beginners. You now have the emergency exit. There's nothing to fear.

### Practical Day-One Pattern

```
Open file → make edit → :wq → done
```

Or, using the custom keybindings in this config:

```
Open file → make edit → Ctrl+S (saves) → Ctrl+Q (quits) → done
```

---

## 6. Saving Files

Saving is something you'll do constantly. Know your options.

### Save Commands

| Method        | How                   | Notes                                                                   |
| ------------- | --------------------- | ----------------------------------------------------------------------- |
| `:w`          | Command mode          | Classic, always works                                                   |
| `:w filename` | Command mode          | Save-as (creates new file with that name)                               |
| `:wa`         | Command mode          | Write ALL open buffers                                                  |
| `Ctrl+S`      | Normal OR Insert mode | **Custom in this config** — most intuitive for VSCode refugees          |
| `<leader>sn`  | Normal mode           | Save WITHOUT running autoformat (useful when you want to save mid-edit) |

> **💡 In VSCode you'd...** `Ctrl+S` to save. Muscle memory from years of use.
>
> **In Neovim (this config) you...** can also use `Ctrl+S`! It's explicitly mapped to save in Normal mode and Insert mode:
>
> ```lua
> keymap.set('n', '<C-s>', save_current_buffer, save_opts)
> keymap.set('i', '<C-s>', save_current_buffer, save_opts)
> ```
>
> So your `Ctrl+S` muscle memory still works. Nice.

### Auto-Save: Available but Disabled

This config includes the `auto-save.nvim` plugin (in `auto-save.lua`), but it's currently **disabled** (`enabled = false` in the plugin spec). The plugin is sophisticated — it doesn't auto-save during Visual mode selections (so you don't accidentally save half-done edits), it doesn't save during Flash jumps, and it has smart debouncing. But auto-save can interfere with undo history and sometimes triggers unintended formatting. For now it's off. If you want to enable it later, it's all configured and ready — just change `enabled = false` to `enabled = true`.

### The Format-on-Save Behavior

This config uses `conform.nvim` for formatting and has `format_after_save` enabled. This means that when you save with `:w`, your file may automatically be formatted (prettier for JS/TS, stylua for Lua, goimports for Go, etc.). This is usually exactly what you want — one less thing to think about.

---

## 7. The 10 Motions You Need Today

Navigation in Normal mode is the heart of Neovim's speed advantage. Let's start simple. You need exactly 10 motions on Day One.

> **💡 In VSCode you'd...** use arrow keys, mouse clicks, or keyboard shortcuts like `Ctrl+Home`/`Ctrl+End`. Your hands leave the keyboard constantly for the mouse, or you strain for arrow keys.
>
> **In Neovim you...** navigate with keys that are on the home row. Your hands never leave the typing position. After a week it feels wrong to use arrow keys.

### The Core 10

| Key  | Movement                                | VSCode Equivalent           |
| ---- | --------------------------------------- | --------------------------- |
| `h`  | Move left one character                 | Left arrow                  |
| `j`  | Move down one line                      | Down arrow                  |
| `k`  | Move up one line                        | Up arrow                    |
| `l`  | Move right one character                | Right arrow                 |
| `w`  | Jump to start of next **w**ord          | `Ctrl+Right` (word forward) |
| `b`  | Jump **b**ack to start of previous word | `Ctrl+Left` (word back)     |
| `0`  | Jump to column 0 (start of line)        | `Home` key                  |
| `$`  | Jump to end of line                     | `End` key                   |
| `gg` | Go to first line of file                | `Ctrl+Home`                 |
| `G`  | Go to last line of file                 | `Ctrl+End`                  |

### ASCII Motion Diagram

Here's a line of code and where each motion takes you:

```
        function calculateTotal(items, taxRate) {
        ^       ^               ^     ^         ^ ^
        |       |               |     |         | |
        0       w               w     w         $ }
                b               b     b
```

- `0` → very start of line (before `function`)
- `w` → jumps forward: `function` → `calculateTotal` → `(` → `items` → `,` → `taxRate` → `)` → etc.
- `b` → jumps backward through the same word boundaries
- `$` → jumps to the `}` at the very end

### Why Not Arrow Keys?

You _can_ use arrow keys in Neovim. They work in both Insert and Normal mode. But experienced users discourage it, especially in Normal mode, for one reason: **your hands leave the home row**. The `hjkl` keys are right there under your index, middle, ring, and pinky fingers. Arrow keys require moving your right hand 10-15cm off the home position. Over a workday of editing, that's a lot of unnecessary movement.

This config actually has the `hardtime.nvim` plugin installed, which can block repeated arrow key usage to encourage you to build `hjkl` habits. It's there if you want the tough love approach.

### Supercharging with Counts

Every motion can be prefixed with a **count**. This is a multiplier:

| Command | Does                 |
| ------- | -------------------- |
| `5j`    | Move down 5 lines    |
| `3w`    | Jump forward 3 words |
| `10k`   | Move up 10 lines     |
| `2b`    | Jump back 2 words    |

This is why navigation in Neovim gets so fast — you glance at a line that's 7 lines below you and type `7j`. Done. No scrolling, no holding keys, no mouse.

### Bonus: Two More Motions Worth Learning Today

| Key      | Movement                                    |
| -------- | ------------------------------------------- |
| `Ctrl+D` | Scroll DOWN half a page (and center cursor) |
| `Ctrl+U` | Scroll UP half a page (and center cursor)   |

In this config, both of these are additionally mapped to `zz` after the scroll, which centers the cursor on screen. This prevents the disorienting jump to the edge of the screen when scrolling:

```lua
keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
```

---

## 8. Undo and Redo

Here's one of the first traps VSCode users fall into.

**`Ctrl+Z` does not undo in Neovim Normal mode.**

`Ctrl+Z` in a terminal suspends the current process and sends it to the background (like pressing Pause in a game). If you press `Ctrl+Z` in Neovim, your editor will disappear to the background and you'll find yourself back at the shell. Don't panic — type `fg` and press Enter to bring it back.

### The Undo/Redo Keys

| Key      | Action                           | VSCode Equivalent          |
| -------- | -------------------------------- | -------------------------- |
| `u`      | Undo                             | `Ctrl+Z`                   |
| `Ctrl+R` | Redo                             | `Ctrl+Y` or `Ctrl+Shift+Z` |
| `U`      | Undo all changes on current line | (no direct equivalent)     |

> **💡 In VSCode you'd...** `Ctrl+Z` to undo. Brains just know this. It's a universal shortcut since WordPerfect.
>
> **In Neovim you...** press `u` to undo. It's lower muscle memory overhead: just the `u` key, no modifier. But you have to retrain your fingers for a few days.

### Vim's Non-Linear Undo Tree

This is a preview of something deeper (we'll cover it fully in the Undotree tutorial). Neovim's undo history is actually a **tree**, not a linear list.

In VSCode: if you make change A, then change B, then undo back to A, then make change C — you permanently lose change B. Linear undo.

In Neovim: every state is preserved in the undo tree. Even if you undo back to A and make change C, you can still navigate back to state B using `Ctrl+R` to redo or via the `undotree` plugin (`<leader>uu`). This means you **never** truly lose work in Neovim as long as Neovim was open.

There's even a feature to persist the undo history to disk (`undodir` option), so you can undo changes from _previous sessions_. Wild.

For Day One, just remember: `u` undoes, `Ctrl+R` redoes. The rest is advanced territory.

---

## 9. Visual Mode Intro — Selecting Text

Visual mode is how you select text in Neovim. It's equivalent to clicking and dragging in VSCode, but keyboard-driven and therefore much more precise.

There are three types of Visual mode:

### The Three Visual Modes

| Key      | Visual Mode Type  | Description                                                          |
| -------- | ----------------- | -------------------------------------------------------------------- |
| `v`      | Character-wise    | Select character by character — like click+drag                      |
| `V`      | Line-wise         | Select entire lines — even partial selections snap to whole lines    |
| `Ctrl+V` | Block/column-wise | Select a rectangular block — like VSCode's `Alt+Click` column select |

> **💡 In VSCode you'd...** click and drag for character selection, click then `Shift+Down` for line selection, or `Alt+Click` / `Shift+Alt+Down` for column/block selection.
>
> **In Neovim you...** press `v`, `V`, or `Ctrl+V` and then navigate with Normal mode motions to extend the selection. The selection grows as you move.

### How Visual Mode Works

1. Press `v` (or `V` or `Ctrl+V`)
2. You're now in Visual mode — the cursor position marks the START of the selection
3. Use Normal mode motions (`h/j/k/l`, `w/b`, `0/$`, etc.) to extend the selection
4. When your selection covers what you want, perform an action

### Actions on Visual Selections

| Key   | Action                                         |
| ----- | ---------------------------------------------- |
| `d`   | Delete (cut) the selection                     |
| `c`   | Change: delete selection and enter Insert mode |
| `y`   | Yank (copy) the selection                      |
| `>`   | Indent the selection one level                 |
| `<`   | Unindent the selection one level               |
| `Esc` | Cancel the selection, return to Normal mode    |

### Quick Example

To copy a word:

1. Navigate cursor to the start of the word
2. Press `v` — enter character Visual mode
3. Press `e` — extend selection to end of word
4. Press `y` — yank (copy) it
5. Navigate where you want to paste
6. Press `p` — paste after cursor

Or, much faster once you know text objects (later tutorial): navigate anywhere inside a word and press `yiw` (yank inner word). No visual mode needed at all.

### Block Selection Example

Block selection (`Ctrl+V`) is incredibly powerful for editing columns of data. Imagine you have:

```
const a = 1;
const b = 2;
const c = 3;
```

And you want to change every `const` to `let`. In VSCode, you might use Find+Replace, or click each manually. In Neovim:

1. Cursor on the `c` of the first `const`
2. `Ctrl+V` — enter block Visual mode
3. `2j` — extend selection down 2 lines
4. `e` — extend selection to end of `const`
5. `c` — change: deletes selection and enters Insert mode
6. Type `let`
7. `Esc` — the change is applied to all three lines simultaneously

That's one of Neovim's party tricks. Multi-line column editing in seconds.

---

## 10. Command Mode Basics

Command mode is the `:` mode. It's where you run editor commands, open files, change settings, and perform operations like find-and-replace on the whole file.

### Entering Command Mode

- Press `:` from Normal mode
- The cursor jumps to the bottom of the screen
- You type a command and press `Enter` to execute
- Press `Esc` to cancel without running anything

### The Essential Commands Table

| Command          | What It Does                                   |
| ---------------- | ---------------------------------------------- |
| `:w`             | Write (save) current file                      |
| `:q`             | Quit (close window)                            |
| `:wq`            | Write and quit                                 |
| `:q!`            | Quit without saving                            |
| `:e filename`    | Edit (open) a file                             |
| `:e .`           | Open file explorer (Oil.nvim) in current dir   |
| `:help keyword`  | Open help for keyword                          |
| `:set option`    | Set a Neovim option (e.g. `:set number`)       |
| `:set option?`   | Query current value of an option               |
| `:ls`            | List all open buffers                          |
| `:bn`            | Buffer next                                    |
| `:bp`            | Buffer previous                                |
| `:bd`            | Buffer delete (close buffer)                   |
| `:nohl`          | Clear search highlights (or `<leader>nh`)      |
| `:%s/old/new/gc` | Find and replace throughout file, confirm each |
| `:%s/old/new/g`  | Find and replace throughout file, no confirm   |

### Searching

From Normal mode, `/` starts a forward search:

1. Press `/`
2. Type your search term
3. Press `Enter` — jumps to first match
4. Press `n` to go to next match
5. Press `N` to go to previous match
6. Press `Esc` to cancel and stay at current position

In this config, `n` and `N` are enhanced to center the screen after each jump:

```lua
keymap.set('n', 'n', 'nzzzv', { desc = 'Find next and center' })
keymap.set('n', 'N', 'Nzzzv', { desc = 'Find previous and center' })
```

Use `?` for backward search (searches in reverse direction).

> **💡 In VSCode you'd...** `Ctrl+F` to open the search bar. Same concept, different execution.
>
> **In Neovim you...** press `/` and type. It's immediate, inline, and integrated with Normal mode navigation. No dialog box.

### Tab Completion in Command Mode

When typing commands in `:` mode, you can press `Tab` to autocomplete. Try `:color<Tab>` — it'll cycle through colorscheme options. This works for file paths too: `:e src/comp<Tab>` will autocomplete to matching files.

---

## 11. Day One Cheat Sheet

Keep this open in a second tab for your first week. Print it out if you need to.

```
╔══════════════════════════════════════════════════════════════════════╗
║                    DAY ONE CHEAT SHEET                               ║
╠══════════════════════════════════════════════════════════════════════╣
║ ACTION                 │ NORMAL MODE        │ VSCODE EQUIVALENT      ║
╠════════════════════════╪════════════════════╪════════════════════════╣
║ Enter insert mode      │ i (before cursor)  │ (just start typing)    ║
║                        │ a (after cursor)   │                        ║
║                        │ o (new line below) │ End + Enter            ║
║                        │ O (new line above) │                        ║
║                        │ A (end of line)    │ End                    ║
║                        │ I (start of line)  │ Home                   ║
╠════════════════════════╪════════════════════╪════════════════════════╣
║ Exit insert mode       │ Esc                │ (N/A)                  ║
║                        │ Ctrl+C             │                        ║
╠════════════════════════╪════════════════════╪════════════════════════╣
║ Save                   │ :w or Ctrl+S       │ Ctrl+S                 ║
║ Quit                   │ :q or Ctrl+Q       │ (close tab/window)     ║
║ Save and quit          │ :wq                │ Ctrl+S then close      ║
║ Quit without saving    │ :q!                │ Close without saving   ║
║ Quit all               │ :qa!               │ Close all              ║
╠════════════════════════╪════════════════════╪════════════════════════╣
║ Move left              │ h                  │ Left arrow             ║
║ Move down              │ j                  │ Down arrow             ║
║ Move up                │ k                  │ Up arrow               ║
║ Move right             │ l                  │ Right arrow            ║
║ Next word              │ w                  │ Ctrl+Right             ║
║ Prev word              │ b                  │ Ctrl+Left              ║
║ Start of line          │ 0                  │ Home                   ║
║ End of line            │ $                  │ End                    ║
║ File start             │ gg                 │ Ctrl+Home              ║
║ File end               │ G                  │ Ctrl+End               ║
║ Scroll down            │ Ctrl+D             │ Page Down              ║
║ Scroll up              │ Ctrl+U             │ Page Up                ║
╠════════════════════════╪════════════════════╪════════════════════════╣
║ Undo                   │ u                  │ Ctrl+Z                 ║
║ Redo                   │ Ctrl+R             │ Ctrl+Y                 ║
╠════════════════════════╪════════════════════╪════════════════════════╣
║ Select (character)     │ v then move        │ Click + drag           ║
║ Select (lines)         │ V then move        │ Shift + click          ║
║ Select (block/column)  │ Ctrl+V then move   │ Alt+click              ║
╠════════════════════════╪════════════════════╪════════════════════════╣
║ Delete selection       │ d (in Visual)      │ Delete key             ║
║ Copy selection         │ y (in Visual)      │ Ctrl+C                 ║
║ Paste                  │ p                  │ Ctrl+V                 ║
╠════════════════════════╪════════════════════╪════════════════════════╣
║ Search forward         │ /pattern Enter     │ Ctrl+F                 ║
║ Next search result     │ n                  │ F3 or Enter            ║
║ Previous result        │ N                  │ Shift+F3               ║
║ Clear highlights       │ <leader>nh         │ Esc in search bar      ║
╠════════════════════════╪════════════════════╪════════════════════════╣
║ Open file              │ :e path/to/file    │ Ctrl+O                 ║
║ Open file picker       │ <leader>pf         │ Ctrl+P                 ║
╠════════════════════════╪════════════════════╪════════════════════════╣
║ EMERGENCY ESCAPE       │ Esc (x3) → :qa!   │ Close window           ║
╚════════════════════════╧════════════════════╧════════════════════════╝

NOTE: <leader> = Space bar in this config
```

---

## 12. "I'm Lost" Recovery Procedure

This is the procedure to run whenever Neovim is doing something unexpected and you don't know why. Memorize this — it will save you many times.

### Step-by-Step Recovery

```
Step 1: Press Esc
        ↓ (Are you still seeing weird behavior?)

Step 2: Press Esc again (twice more for good measure)
        ↓ (Check the bottom-left status line)

Step 3: What does it say?
        ├── "NORMAL" → You're fine, continue to Step 4
        ├── "INSERT" → Press Esc again
        ├── "VISUAL" → Press Esc again
        └── Nothing weird → Probably fine

Step 4: Is there text in the command line at the bottom?
        ├── Yes → Press Ctrl+C or Esc to cancel it
        └── No → Good

Step 5: Type :wa (write all — saves everything)
        Press Enter

Step 6: Did it error?
        ├── Yes (e.g., "read-only") → Type :qa! and press Enter (abandons unsaved)
        └── No → Your files are saved

Step 7: If everything is broken and you just want out:
        Type :qa!
        Press Enter
        Done. Clean exit. No damage.
```

### Common "What Happened" Scenarios

**"I pressed something and now there's a number in the corner and nothing works"**

- You typed a partial command or a count. Press `Esc` to cancel it.

**"There are weird characters on my screen and the cursor is at the bottom"**

- You accidentally entered Command mode (pressed `:`). Press `Esc`.

**"My whole screen turned into a terminal / shell"**

- You may have pressed `Ctrl+Z` which suspended Neovim. Type `fg` + Enter in the terminal to bring it back.

**"All my text is gone!"**

- Almost certainly not. Press `Esc`, then `u` to undo repeatedly. Or `:e!` to reload from disk (discards all changes since last save).

**"I'm in some mode I've never seen before with 'REPLACE' at the bottom"**

- You accidentally pressed `R`. Press `Esc` to return to Normal mode.

**"The screen is split into two and I don't know how to close the extra window"**

- Press `<leader>sx` (closes current split) or `:q` (closes current window, not the whole editor).

---

## 13. Exercises

Complete these in order. Don't skip ahead. Each one builds on the last.

---

### Exercise 1: The Basic Cycle (5 minutes)

**Goal:** Open a file, type something, save, quit.

1. From your terminal, navigate to any directory and create a test file:
   ```
   nvim my-first-file.txt
   ```
2. Neovim opens. You're in Normal mode. Notice the status line says `NORMAL`.
3. Press `i` to enter Insert mode. Status line should say `INSERT`.
4. Type: `Hello from Neovim!`
5. Press `Esc`. Status line should return to `NORMAL`.
6. Press `:w` and `Enter` to save.
7. Press `:q` and `Enter` to quit.
8. In the terminal, run `cat my-first-file.txt` to verify your text was saved.

**You did it.** That's the complete cycle.

---

### Exercise 2: Navigation Without Arrow Keys (10 minutes)

**Goal:** Move around a file using ONLY `h/j/k/l/w/b/0/$`.

1. Open the file again: `nvim my-first-file.txt`
2. Add more text. Press `o` to open a new line below, then type:
   ```
   The quick brown fox jumps over the lazy dog.
   Learning Neovim is like learning to touch type all over again.
   But once it clicks, nothing else feels right.
   ```
3. Press `Esc`.
4. Now: navigate to the first letter of "brown" using ONLY `h/j/k/l/w/b`. No arrow keys.
5. Navigate to the end of "Neovim" on line 2. Try `w` to jump word by word.
6. Navigate to the very end of the file with `G`.
7. Navigate to the very start with `gg`.
8. Navigate to the end of line 2 with `$`. Then to the start with `0`.
9. Save with `:w`.

**Rule:** If you touch an arrow key, restart the exercise.

---

### Exercise 3: The Insert Mode Gauntlet (10 minutes)

**Goal:** Practice all 6 ways to enter Insert mode.

In your test file, practice each of these:

1. Navigate to the middle of any word. Press `i`. You should be inserting BEFORE that character. Press `Esc`.
2. Navigate to the middle of any word. Press `a`. You should be inserting AFTER that character. Press `Esc`.
3. Navigate to any line. Press `o`. A new line should appear BELOW and you should be in Insert mode. Type a few characters. Press `Esc`.
4. Navigate to any line. Press `O`. A new line should appear ABOVE and you should be in Insert mode. Type a few characters. Press `Esc`.
5. Navigate to any line with content. Press `I`. Your cursor should jump to the start of the line and you should be in Insert mode. Press `Esc`.
6. Navigate to any line with content. Press `A`. Your cursor should jump to the end of the line and you should be in Insert mode. Press `Esc`.

Save with `Ctrl+S` (yes, it works here!).

---

### Exercise 4: Undo and Redo (5 minutes)

**Goal:** Build undo/redo muscle memory using `u` and `Ctrl+R`.

1. In your test file, add the line: `This line will be added and removed.`
2. Press `Esc`.
3. Press `u` once. The line should disappear.
4. Press `u` again. The previous line should also undo.
5. Press `Ctrl+R` twice. Both lines come back.
6. Now make 5 separate changes (each time press `Esc` between changes):
   - Add a word
   - Add another word
   - Delete a character (press `x` in Normal mode to delete the character under cursor)
   - Add a line with `o`
   - Change something
7. Undo all 5 changes one at a time with `u`.
8. Redo all 5 changes with `Ctrl+R`.

Feel the difference from `Ctrl+Z`?

---

### Exercise 5: Visual Mode Selection (10 minutes)

**Goal:** Use all three Visual modes.

1. Open your test file. It should have several lines by now.
2. **Character-wise selection:**
   - Move to the word "quick" on your fox line
   - Press `v`
   - Press `e` to extend to end of word
   - Press `d` to delete it
   - Press `u` to undo

3. **Line-wise selection:**
   - Move to any line
   - Press `V` (capital V)
   - Press `j` twice to select 3 lines
   - Press `y` to yank (copy)
   - Move to the end of the file (`G`)
   - Press `p` to paste
   - Press `u` to undo

4. **Block selection:**
   - Add these lines to your file (use `o` to add lines):
     ```
     name: Alice
     name: Bob
     name: Carol
     ```
   - Move cursor to the `A` in Alice
   - Press `Ctrl+V` (block Visual mode)
   - Press `j` twice (extend down 2 lines)
   - Press `e` (extend to end of "name")
   - Press `d` to delete the word "name" from all three lines
   - Press `u` to undo

5. Save and quit: `:wq`

---

### Bonus Challenge: The 2-Minute Timer

Challenge yourself: open a new file and, within 2 minutes, write a small paragraph of 3-4 sentences. The rules:

- Enter and exit Insert mode at least 5 times (use different entry points: `i`, `a`, `o`, `A`)
- Save at least twice (once with `:w`, once with `Ctrl+S`)
- Navigate without arrow keys
- At the end, quit with `:q`

The timer pressure will force the muscle memory to start forming. The awkwardness you feel is completely normal and it fades faster than you'd expect.

---

## What's Next

You've survived Day One. Here's what you can do now:

- Open files in Neovim and not immediately panic
- Enter and exit Insert mode deliberately
- Navigate a file with the 10 basic motions
- Save and quit with confidence
- Handle the "I'm lost" scenario

In **Tutorial 02**, you'll get the complete VSCode-to-Neovim translation guide — every shortcut you know from VSCode, mapped to its Neovim equivalent. It covers file management, LSP features, Git, debugging, testing, and more. Think of it as the reference you'll actually use.

After that, we'll go deeper into:

- **Tutorial 03:** Moving like a Ninja — advanced motions, Flash.nvim jumps, marks
- **Tutorial 04:** Editing Mastery — operators, text objects, the `.` command
- **Tutorial 05:** The Leader Key System — understanding the full `<Space>` key map

See you in Tutorial 02.

---

## 14. Understanding the Status Line

Before you go, let's talk about the status line. It's at the very bottom of the Neovim screen and it's your information dashboard. In this config, it's powered by **lualine.nvim**.

```
┌────────────────────────────────────────────────────────────────────────────┐
│ NORMAL  │  main  +2 ~5 -1  │  src/components/Button.tsx  │  lua  │ 42:17 │
│ [MODE]  │  [GIT BRANCH + HUNKS]  │  [FILE PATH]  │  [FILETYPE]  │  [POS] │
└────────────────────────────────────────────────────────────────────────────┘
```

**Reading the status line, left to right:**

| Section         | What It Shows                            | Example          |
| --------------- | ---------------------------------------- | ---------------- |
| Mode            | Current mode (NORMAL/INSERT/VISUAL/etc.) | `NORMAL`         |
| Git branch      | Current git branch name                  | `main`           |
| Git changes     | +added ~modified -deleted hunks          | `+2 ~5 -1`       |
| File path       | Relative path to current file            | `src/Button.tsx` |
| Modified flag   | `[+]` if unsaved changes                 | `[+]`            |
| LSP diagnostics | Error/warning/info/hint counts           | `E:2 W:1`        |
| Filetype        | The detected file type                   | `typescript`     |
| Position        | Line:Column                              | `42:17`          |

> **💡 In VSCode you'd...** see all of this in the bottom status bar too. Blue for normal, orange for remote. Neovim's lualine does the same thing, and the mode color changes with the current mode — a visual cue you'll start relying on.

The mode indicator changes color:

- Green → Normal mode
- Blue → Insert mode
- Yellow → Visual mode
- Red → (typically errors or important states)

This color-coding is one of the unsung heroes of Neovim. After a few days, you'll glance at the color before the text.

---

## 15. The Neovim Startup Process (What's Happening When It Opens)

Ever curious what happens between typing `nvim filename.txt` and seeing the editor? Here's a simplified walkthrough, because understanding it helps when things go wrong.

```
nvim filename.txt
      │
      ▼
  Loads init.lua
  (/home/you/.config/nvim/init.lua)
      │
      ▼
  Loads lazy.nvim (plugin manager)
  (/home/you/.local/share/nvim/lazy/lazy.nvim)
      │
      ▼
  lazy.nvim reads all plugin specs
  (de100/plugins/*.lua files)
      │
      ├── Priority 1000 plugins load immediately (colorscheme, snacks)
      ├── Non-lazy plugins load immediately
      └── Lazy plugins registered but NOT loaded yet
      │
      ▼
  Core options applied (options.lua)
  Core keymaps applied (keymaps.lua)
      │
      ▼
  File opens in a buffer
      │
      ├── BufReadPre event fires → LSP, formatting, linting plugins load
      ├── LSP servers attach to buffer
      └── Treesitter parser activates for syntax highlighting
      │
      ▼
  You see the editor. Ready.
```

**Why does this matter?**

It explains **lazy loading**. Many plugins only load when they're first needed. This is why Neovim starts fast even with 50+ plugins — most aren't loaded until you actually use them. When you press `<leader>daptb` for the first time, that's when the DAP plugin actually loads. Press `<leader>gn` for the first time and that's when Neogit loads.

You'll sometimes notice a tiny delay the _first_ time you use a feature. That's the lazy load. Subsequent uses are instant.

---

## 16. Configuring Neovim: Your First Options Edit

Let's make your first configuration change. This is important: **Neovim is configured with code, not a settings GUI**. Your config file is a Lua program.

The main options file for this config is:

```
dotfiles/.config/nvim/lua/de100/core/options.lua
```

Open it with:

```vim
:e ~/.config/nvim/lua/de100/core/options.lua
```

Or from within a Neovim session using the file picker:

```
<leader>pf   → type "options" → Enter
```

### Common Options You Might Want to Change

Here's what the options file contains and what you might want to tweak:

| Option                   | What It Does                     | Default               | Try This                  |
| ------------------------ | -------------------------------- | --------------------- | ------------------------- |
| `vim.opt.number`         | Show line numbers                | `true`                | —                         |
| `vim.opt.relativenumber` | Show relative line numbers       | `true`                | `false` if confusing      |
| `vim.opt.tabstop`        | How wide a tab is displayed      | (set to config value) | `4` for Python-style      |
| `vim.opt.shiftwidth`     | How wide `>` indents             | (set to config value) | Match tabstop             |
| `vim.opt.scrolloff`      | Lines to keep above/below cursor | `8`                   | `5` if you prefer less    |
| `vim.opt.wrap`           | Whether long lines wrap          | `false`               | `true` for prose          |
| `vim.opt.cursorline`     | Highlight the current line       | (check config)        | `true` helps track cursor |
| `vim.opt.colorcolumn`    | Show a column guide              | (check config)        | `"80"` or `"120"`         |

### Relative vs Absolute Line Numbers

This config likely has `relativenumber = true`. Here's why this matters enormously once you understand it:

```
  5  function processData(items) {
  4    const results = [];
  3    for (const item of items) {
  2      if (item.valid) {
  1        results.push(item.value);
> 0        ← cursor is here (shows absolute number, e.g. 42)
  1      }
  2    }
  3    return results;
  4  }
```

With relative numbers, every line shows its _distance_ from the cursor. This is incredibly useful because Neovim commands take counts: `5j` jumps down 5 lines. You look at line 5 above you, see `5`, and type `5k` to jump there. No mental math needed.

> **💡 In VSCode you'd...** see only absolute line numbers. You'd have to calculate "I'm on line 42, that function is at line 37, so I need to go up 5 lines." With relative numbers in Neovim, that calculation is done for you — just read the number and use it as the count.

---

## 17. The Help System: Your Best Friend

Neovim has the most comprehensive built-in help system of any editor. And it's all accessible without leaving the editor.

### How to Use Help

From Normal mode:

- `:help topic` — open help for a specific topic
- `:help :command` — help for a command (the colon prefix matters)
- `:help option` — help for a vim option
- `:help key` — help for a key binding (e.g. `:help i`)
- `<leader>vh` — fuzzy-search the entire help system via Snacks picker

### Navigating the Help Window

When you open help, you get a split window showing the documentation:

| Key      | Action in Help                                           |
| -------- | -------------------------------------------------------- |
| `Ctrl+]` | Follow the link under cursor (like clicking a hyperlink) |
| `Ctrl+O` | Go back (jump list)                                      |
| `Ctrl+T` | Go to previous help tag                                  |
| `:q`     | Close the help window                                    |

### Useful Help Topics for Beginners

```vim
:help motion.txt       " Complete motion reference
:help insert.txt       " Complete insert mode reference
:help visual.txt       " Complete visual mode reference
:help user-manual      " The full Neovim user manual
:help quickref         " Quick reference card (great for printing)
:help key-notation     " How keys are written in docs (<C-x>, etc.)
:help pattern          " Regular expression patterns
:help change.txt       " Undo, redo, and change history
```

> **💡 In VSCode you'd...** press `F1` and search the documentation, or Google it. Neovim's help is faster because it's already loaded and searchable without leaving the editor. The quality of documentation is also excellent — it's been refined for 30+ years.

---

## 18. The Which-Key Discovery System

One of the biggest advantages of this config is **which-key.nvim**. When you press the leader key (Space) and then pause, a beautiful menu appears showing you all your available next keystrokes:

```
                           ┌──────────────────────────────────────────┐
                           │                                          │
                Space ──►  │   b  buffers        p  pick/search      │
                           │   c  code           r  rename/refactor   │
                           │   d  diagnostics    s  splits/session    │
                           │   e  explorer       t  tabs/tests/tasks  │
                           │   f  file           u  ui/toggles        │
                           │   g  git            v  view/help         │
                           │   h  harpoon        w  workspace         │
                           │   H  http/rest      x  trouble/lists     │
                           │   l  lsp/lint       y  yank              │
                           │   m  make/format                         │
                           │   n  clear                               │
                           │                                          │
                           └──────────────────────────────────────────┘
```

You don't need to memorize every keybinding. You just need to remember:

1. Press `Space` and pause
2. Read the menu to find your category
3. Press the category key and pause
4. Read the submenu for the specific action

This is the Neovim equivalent of "I'll just right-click and see what options are available." The entire leader key system is self-documenting.

### Pro Tip: The Keymap Picker

Press `<leader>pk` to open the Snacks keymap picker. This shows you EVERY keybinding in the entire editor, searchable by description. Type "blame" and find the git blame toggle. Type "format" and find the formatter shortcut. It's a searchable database of everything the editor can do.

---

## 19. Marks: Bookmarks Within a File

Marks are one of those features that VSCode doesn't have a direct equivalent to, but once you know them you'll use them constantly.

A **mark** is a saved cursor position. You can set a mark and later jump back to it from anywhere in the same file (or even across files).

### Setting and Using Marks

| Command       | Action                                    |
| ------------- | ----------------------------------------- |
| `ma`          | Set mark `a` at current position          |
| `mA`          | Set global mark `A` (works across files!) |
| `` `a ``      | Jump to exact position of mark `a`        |
| `'a`          | Jump to start of line where mark `a` is   |
| `` `A ``      | Jump to global mark `A` (can cross files) |
| `:marks`      | List all marks                            |
| `:delmarks a` | Delete mark `a`                           |

### Automatic Marks You Should Know

Neovim maintains some marks automatically:

| Mark           | What It Points To                              |
| -------------- | ---------------------------------------------- |
| `` `. ``       | Last change (where you last edited)            |
| `` `" ``       | Last cursor position when you closed this file |
| `''` or ` `` ` | Position before last jump (like `Ctrl+O` once) |
| `'<` and `'>`  | Start and end of last visual selection         |

The most useful automatic mark is `` `. `` — last change. Press ` `. `` to jump to wherever you last made an edit. Incredibly useful when you jump away from your working area and need to return.

> **💡 In VSCode you'd...** have no direct equivalent to marks. The closest is bookmarks (via an extension), but they're managed through a separate UI rather than being instant keyboard-driven positions.

---

## 20. Common Beginner Mistakes and How to Avoid Them

Here's a curated list of the mistakes almost everyone makes in their first week, with explanations:

### Mistake 1: Pressing Ctrl+Z to Undo

**What happens:** Neovim gets suspended and you're back at the terminal.
**Fix:** Type `fg` and press Enter to bring Neovim back.
**Prevent:** Retrain your fingers to press `u` for undo. Patience.

### Mistake 2: Typing Text in Normal Mode

**What happens:** You type and strange things happen — cursor moves, text gets deleted, windows open.
**Fix:** Press `Esc` to return to Normal mode. Press `u` repeatedly to undo the unintended changes. Then carefully enter Insert mode with `i` before typing.
**Prevent:** Always check the status line mode indicator before typing.

### Mistake 3: Getting Stuck in a Command with a Count

**What happens:** You accidentally type a number (like `2` or `15`) and now every motion is multiplied. Or the count is sitting there waiting for a motion.
**Fix:** Press `Esc` — it cancels pending counts and incomplete commands.
**Prevent:** Be deliberate about when you type numbers in Normal mode.

### Mistake 4: Replacing Text Instead of Inserting

**What happens:** You pressed `R` instead of `i` and you're in Replace mode, overwriting characters as you type.
**Tell-tale sign:** Status line shows `REPLACE` at the bottom.
**Fix:** Press `Esc` to return to Normal mode. Undo any overwritten content with `u`.
**Prevent:** Be careful about caps lock or accidentally pressing `R`.

### Mistake 5: Forgetting That `s` is Flash Jump, Not Substitute

**What happens:** You press `s` expecting to delete a character and enter Insert mode (the default Neovim behavior), but instead Flash.nvim activates waiting for you to type a jump target.
**Fix:** Press `Esc` to cancel the Flash jump. Use `cl` instead (change character and insert) or `xi` (delete char, then insert).
**Remember:** In this config, `s` = Flash jump. It's remapped. `cl` is the substitute equivalent.

### Mistake 6: Using `:wq` When There's Nothing to Save

This is fine — `:wq` saves even if there's nothing to save (it writes the file with no changes). But some people panic when they type `:q` and get "E37: No write since last change". That message means you have unsaved changes.
**Fix:** Either `:w` then `:q`, or `:wq` to do both, or `:q!` to abandon changes.

### Mistake 7: Hitting Enter in Normal Mode

**What happens:** `Enter` in Normal mode moves the cursor down to the next line. It doesn't "confirm" anything. People coming from other contexts (terminal, dialogs) expect `Enter` to do something decisive.
**Just know:** In Normal mode, `Enter` is just another motion. `:command` + `Enter` is where Enter "confirms" things.

### Mistake 8: Not Using Counts

**What happens:** You press `j` twenty times to move twenty lines.
**Better:** Press `20j`.
**Even better:** Look at the relative line number, read off the distance (e.g., `12`), press `12j`.

Counts apply to almost everything: `3w` (forward 3 words), `4k` (up 4 lines), `2dd` (delete 2 lines), `5yy` (yank 5 lines). They're multipliers. Use them.

### Mistake 9: Closing Splits When You Meant to Close a Buffer

**What happens:** You type `:q` when you have multiple windows and close a split instead of the whole editor. Or the opposite — you close a buffer and wonder why the window layout changed.
**Remember:**

- `:q` closes the WINDOW (split), not just the buffer
- `<leader>bx` closes the BUFFER (file) from all windows showing it
- `<leader>sx` closes a SPLIT without affecting the buffer

### Mistake 10: Searching for the Sidebar

**What happens:** You spend 10 minutes trying to find the file tree sidebar and wondering why there isn't one.
**Remember:** There's no permanent sidebar in this config by design. Use:

- `<leader>ee` for mini.files (visual explorer)
- `-` for Oil (parent directory as buffer)
- `<leader>pf` for file picker (fastest for opening files)

The lack of sidebar is a feature once you accept it.

---

## 21. Copying and Pasting: Registers Demystified

Clipboard behavior in Neovim is one of the most confusing things for new users. Let's clear it up completely.

### Vim Has Multiple "Clipboards" Called Registers

> **💡 In VSCode you'd...** copy with `Ctrl+C`, paste with `Ctrl+V`. There's one clipboard (plus system clipboard). Simple.
>
> **In Neovim you...** have access to about 26 named registers (a-z), several special registers, and the system clipboard. This sounds terrifying, but in practice you mostly only care about the default register and the system clipboard register.

**The default register** (`"`) is where `y` (yank), `d` (delete), and `c` (change) put text, and where `p` (put/paste) reads from. This is the "normal" clipboard.

**The system clipboard register** (`+`) is the actual operating system clipboard — the one that `Ctrl+C` / `Ctrl+V` uses outside Neovim.

### The Key Problem

When you `dd` (delete a line), that deleted text goes into the default register. If you then try to paste something you yanked earlier, the delete has overwritten it. This is the classic "I yanked something, then deleted something, now I can't paste what I yanked" problem.

**Solutions:**

1. **The black hole register** `"_`: Delete without saving to any register.

   ```
   "_dd    " delete line and don't save it anywhere
   "_dw    " delete word and don't save it
   ```

   This config already sets `x` to use the black hole register:

   ```lua
   keymap.set('n', 'x', '"_x', { desc = 'Delete single character without copying' })
   ```

2. **Named registers**: Yank to a specific register so it's never overwritten.

   ```
   "ayy    " yank current line into register 'a'
   "ap     " paste from register 'a'
   ```

3. **Yanky.nvim** (in this config): The `yanky.lua` plugin adds a yank history. You can cycle through previous yanks when pasting. This largely solves the overwrite problem.

### System Clipboard

To copy to the system clipboard (so you can paste outside Neovim):

```
"+yy    " yank current line to system clipboard
"+y$    " yank from cursor to end of line to system clipboard
"+p     " paste from system clipboard
```

Or in Visual mode, select text and `"+y`.

### The Special Registers You Should Know

| Register | Contents                                             |
| -------- | ---------------------------------------------------- |
| `"`      | Default (unnamed) register — last yank/delete/change |
| `0`      | Last YANK only (not affected by deletes)             |
| `+`      | System clipboard                                     |
| `*`      | Selection clipboard (middle-click paste on Linux)    |
| `_`      | Black hole register (discard — nothing saved)        |
| `/`      | Last search pattern                                  |
| `:`      | Last command-line command                            |
| `%`      | Current file name                                    |
| `#`      | Alternate file name                                  |
| `.`      | Last inserted text                                   |

**Hot tip:** Register `0` holds the last YANK only. So if you:

1. Yank a word: `yw`
2. Delete some stuff: `dd`, `dd`
3. Now paste the original yank: `"0p` — it's in register 0

No more lost yanks!

---

## 22. Understanding the `.` Dot Command (Your Superpower)

This deserves its own section even on Day One because the dot command will change how you think about editing.

The `.` (period/dot) command in Normal mode **repeats the last change**. "Last change" means the last insert-mode session + escape, or the last operator command (like `dw`, `cw`, `dd`).

> **💡 In VSCode you'd...** repeat a recent action by doing it again manually, or use Find+Replace for repetitive changes. There's no "repeat last edit" command.
>
> **In Neovim you...** press `.` and the last change happens again at the current cursor position. This is deceptively simple and incredibly powerful.

### Examples

**Example 1: Deleting multiple words**

1. Cursor on "unnecessary" in `const unnecessary = getValue();`
2. `dw` — deletes "unnecessary"
3. Cursor on another word you want to delete
4. `.` — deletes that word too
5. Move to another word, `.` again — deleted

**Example 2: Adding semicolons to multiple lines**

1. Cursor at end of first line missing a semicolon
2. `A;Esc` — Append (A), type semicolon, Escape
3. `j` — next line
4. `.` — repeats `A;Esc` on this line
5. `j.j.j.` — repeat for each line

**Example 3: Changing quotes**

1. Cursor on `'single-quoted'`
2. `cs'"` — change surrounding single quotes to double quotes (mini.surround)
3. Navigate to next occurrence
4. `.` — changes that one too

The dot command plus normal mode navigation is one of the most efficient editing patterns in existence. Many Neovim users structure their edits specifically to make the dot command work: "make one exemplar change, then navigate and repeat."

---

## 23. Working With Multiple Lines (Line Operations)

You'll constantly need to work with whole lines. Here are the line-specific operations that are your everyday bread and butter.

| Command | Action                                                  |
| ------- | ------------------------------------------------------- |
| `dd`    | Delete current line (cut)                               |
| `2dd`   | Delete 2 lines                                          |
| `yy`    | Yank (copy) current line                                |
| `3yy`   | Yank 3 lines                                            |
| `p`     | Paste BELOW current line                                |
| `P`     | Paste ABOVE current line                                |
| `cc`    | Change entire line (delete + enter Insert)              |
| `C`     | Change from cursor to end of line                       |
| `D`     | Delete from cursor to end of line                       |
| `>>`    | Indent current line one level                           |
| `<<`    | Unindent current line one level                         |
| `==`    | Auto-indent current line (treesitter-based)             |
| `J`     | Join current line with the line below (removes newline) |

### Moving Lines

In Visual mode, you can move selected lines up or down:

```
V       " select line in visual mode
j       " extend to select more lines
J       " move lines DOWN (custom keybinding in this config)
K       " move lines UP
```

From `keymaps.lua`:

```lua
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up" })
```

> **💡 In VSCode you'd...** use `Alt+Down` / `Alt+Up` to move lines. No selection needed.
>
> **In Neovim you...** use Visual mode + `J`/`K`. The advantage is you can select multiple lines first, then move the whole block.

---

## 24. Find and Replace: The Full Power

We touched on `/` for search earlier. Let's go deeper into the substitution command because it's incredibly powerful.

### Basic Substitution Syntax

```vim
:s/pattern/replacement/flags    " substitute in current line only
:%s/pattern/replacement/flags   " substitute in whole file
:'<,'>s/pattern/replacement/flags  " substitute in visual selection
:1,10s/pattern/replacement/flags   " substitute in lines 1-10
```

**Common flags:**

| Flag | Meaning                                                                   |
| ---- | ------------------------------------------------------------------------- |
| `g`  | Global — all occurrences on each line (without this, only first per line) |
| `c`  | Confirm — ask before each replacement                                     |
| `i`  | Case-insensitive                                                          |
| `I`  | Case-sensitive (overrides `:set ignorecase`)                              |
| `e`  | Suppress error if no match found                                          |
| `n`  | Don't replace — just count matches                                        |

### Practical Examples

```vim
" Replace all 'foo' with 'bar' in file:
:%s/foo/bar/g

" Replace with confirmation:
:%s/foo/bar/gc

" Case-insensitive replace:
:%s/foo/bar/gi

" Replace only in lines 5-20:
:5,20s/foo/bar/g

" Replace word under cursor (common pattern):
:%s/\<<C-r><C-w>\>/<C-r><C-w>/gc

" Replace 'var' with 'const' only at start of lines:
:%s/^var /const /g

" Use capture groups (replace 'foo(bar)' with 'bar.foo()'):
:%s/foo(\(.*\))/\1.foo()/g
```

### The Search Highlight Workflow

When you search with `/`, Neovim highlights ALL matches. This is useful for reviewing where a pattern appears before running a substitution. After you're done, `<leader>nh` clears the highlights.

> **💡 In VSCode you'd...** use `Ctrl+H` for Find+Replace, with a GUI dialog and buttons. You can see previews of replacements.
>
> **In Neovim you...** type the substitution command. The `c` flag gives you confirmation per match — press `y` to replace, `n` to skip, `a` to replace all remaining, `q` to quit. It's CLI-style but faster than a GUI once you know the pattern syntax.

### grug-far for Complex Multi-File Replace

For complex project-wide search and replace, this config has **grug-far.nvim** which provides a more interactive experience. Check `grug-far.lua` for its keybindings. It's excellent for refactoring operations that span many files.

---

## 25. The Vim Grammar: Operator + Motion

This is the secret sauce. Understanding this unlocks why Neovim users are so fast at editing.

**Every editing command in Normal mode follows this grammar:**

```
[count] + operator + [count] + motion/text-object
```

**Operators** (what to do):

- `d` — delete
- `c` — change (delete + enter insert)
- `y` — yank (copy)
- `>` — indent
- `<` — unindent
- `=` — auto-indent
- `gu` — lowercase
- `gU` — uppercase
- `g~` — toggle case

**Motions** (where to apply):

- `w` — to next word start
- `e` — to end of current word
- `b` — to previous word start
- `$` — to end of line
- `0` — to start of line
- `^` — to first non-blank character
- `gg` — to file start
- `G` — to file end
- `f{char}` — to next occurrence of char
- `t{char}` — to just before next occurrence of char
- `/pattern` — to next match of pattern

### Combining Them

```
dw      " delete to next word start
d$      " delete to end of line (same as D)
d0      " delete to start of line
d3w     " delete 3 words
cw      " change word
c$      " change to end of line (same as C)
y5j     " yank 5 lines down
>3j     " indent 3 lines down
gu$     " lowercase everything to end of line
gUw     " uppercase current word
```

The "operator + motion" grammar is composable. Once you know the operators and the motions separately, you can combine ANY operator with ANY motion. There are potentially hundreds of combinations, but you don't memorize them — you understand the grammar and compose what you need.

> **💡 In VSCode you'd...** need a specific shortcut for each operation. "Delete to end of line" has one shortcut. "Delete word" has another. "Delete to next semicolon" probably doesn't have a shortcut at all.
>
> **In Neovim you...** compose: `dt;` = delete (`d`) to (`t`) next semicolon (`;`). You invented that "shortcut" on the fly from things you already knew. This is why Neovim scales — the grammar lets you express arbitrary editing operations without memorizing arbitrary shortcuts.

---

## 26. Text Objects: Selecting "Semantic" Units

Text objects are used in combination with operators. They describe "the thing my cursor is inside" or "the thing at my cursor."

**Syntax:** `[operator] + i/a + [object]`

- `i` = "inner" (excludes surrounding delimiters)
- `a` = "around" (includes surrounding delimiters)

| Object     | Description                 |
| ---------- | --------------------------- |
| `w`        | word                        |
| `W`        | WORD (whitespace-delimited) |
| `s`        | sentence                    |
| `p`        | paragraph                   |
| `"`        | double-quoted string        |
| `'`        | single-quoted string        |
| `` ` ``    | backtick-quoted string      |
| `(` or `)` | parentheses                 |
| `[` or `]` | brackets                    |
| `{` or `}` | braces                      |
| `<` or `>` | angle brackets              |
| `t`        | HTML/XML tag                |

### Examples in Action

```
ciw     " Change Inner Word — delete word and enter insert mode
ci"     " Change Inside Quotes — delete string content and insert
ca"     " Change Around Quotes — delete including the quotes and insert
di(     " Delete Inner Parens — delete content between ()
da(     " Delete Around Parens — delete () and content
yi{     " Yank Inner Braces — copy the body of a { } block
vit     " Visual select Inner Tag — select content between <tag></tag>
```

This config also includes **mini.ai** which extends text objects. With mini.ai, you get enhanced text objects for:

- Function arguments: `ia` (inside argument), `aa` (around argument)
- And more complex Treesitter-based objects

> **💡 In VSCode you'd...** double-click for word selection, `Ctrl+Shift+[` to collapse a block. For "select inside quotes" you'd typically click to position then Shift+click to extend — 3+ actions instead of 3 keystrokes.

---

## 27. A Note on This Config's Philosophy

Before you finish Day One, it's worth understanding the _intent_ behind this configuration.

This is not a minimal config. It's a **full IDE replacement** designed to handle real-world software development workflows. It includes:

- Full LSP with 30+ language servers
- Formatting and linting
- Debugging (DAP) for 6+ languages
- Testing (neotest) for 4 frameworks
- Git integration at every level (gitsigns, neogit, lazygit, diffview, fugitive)
- AI assistance (copilot, codecompanion, avante) — opt-in via env vars
- HTTP client (kulala)
- Database UI (dadbod)
- Remote editing (remote-nvim)
- Kubernetes management (kubectl.nvim)
- Session management

The plugins are carefully chosen to not conflict. The keybindings follow the which-key group structure (`<leader>g` for git, `<leader>p` for pick/search, etc.) so they're discoverable.

**The learning curve is real**, but you're not learning a minimal editor. You're learning a full development environment that happens to be inside a terminal. The investment pays off enormously once the muscle memory kicks in.

Start with Day One basics. Don't try to master everything at once. Week 1: basic editing and navigation. Week 2: LSP features. Week 3: Git workflow. Week 4: debugging, testing. By month 2 you'll be faster than you ever were in VSCode.

---

## 28. Your First Week Schedule

Here's a concrete plan for building Neovim fluency without overwhelming yourself:

### Day 1 (Today): Survive

- Open files, edit, save, quit
- `hjkl` navigation
- `i`, `a`, `o`, `A` for insert modes
- `u` and `Ctrl+R` for undo/redo
- `Esc` to escape everything

### Day 2-3: Navigate

- `w`, `b`, `e`, `0`, `$`, `gg`, `G`
- `Ctrl+D` and `Ctrl+U` for scrolling
- `/` for searching
- `<leader>pf` for opening files
- Practice for 30 minutes: do your ACTUAL WORK in Neovim, even slowly

### Day 4-5: Edit Better

- `dw`, `dd`, `yy`, `p` — delete, yank, paste
- `cw`, `cc` — change operations
- `ciw`, `ci"`, `di(` — inner/around text objects
- `.` to repeat last change
- `V` for line selection, `d`/`y` on selections

### Day 6-7: Use the Config

- `<leader>pf` for files, `<leader>pg` for grep
- `gd`/`gR`/`K` for LSP features
- `<leader>gn` for Neogit
- `<leader>ca` for code actions
- `<leader>xd` for Trouble diagnostics

### Week 2: Master the Basics

- Text objects deeply: `ci"`, `da(`, `yit`, etc.
- Marks: `ma`, `` `a ``
- Buffers: `Tab`/`Shift+Tab`, `<leader>bx`
- Splits: `<leader>sv`, `Ctrl+H/J/K/L`
- Harpoon: `<leader>ha`, `<leader>h1-4`

**Rule:** Even if it's slower at first, always try the Neovim way before falling back to the mouse or arrow keys. Discomfort is how the muscle memory forms.

---

## 29. A Closer Look at This Config's init.lua

Understanding the entry point of the config helps when things go wrong or when you want to extend it.

The main file is at `dotfiles/.config/nvim/init.lua`. It orchestrates everything:

```lua
-- 1. Load core settings (options and keymaps)
require("de100.core")

-- 2. Initialize lazy.nvim (plugin manager)
require("de100.lazy")
```

The `core` module lives in `lua/de100/core/` with two files:

- `options.lua` — Neovim settings (line numbers, tabs, scrolloff, etc.)
- `keymaps.lua` — core keybindings not tied to any plugin

The `lazy` module lives in `lua/de100/lazy.lua` and sets up lazy.nvim, telling it to find all plugin specs in `lua/de100/plugins/`.

This organization means:

- Core behavior = `core/*.lua`
- Plugin behavior = `plugins/*.lua`
- Each plugin file = one or more related plugins

You can add any new plugin by creating a file in `plugins/` or adding to an existing one. The structure is intentional — group related plugins together (e.g., all git tools in `gitstuff.lua`).

---

## 30. Neovim's Options System: The Most Important Settings Explained

Even on Day One, it helps to know what options are doing what. Here are the most impactful options from `options.lua` with plain-English explanations:

### Line Numbers

```lua
vim.opt.number = true          -- show absolute line numbers
vim.opt.relativenumber = true  -- ALSO show relative line numbers
```

With both on, you get "hybrid" line numbers: the current line shows its absolute number (useful for knowing where you are), all other lines show relative distances (useful for count-based motions).

### Tabs and Indentation

```lua
vim.opt.tabstop = 2       -- how wide a Tab character appears
vim.opt.shiftwidth = 2    -- how wide >> and << indent
vim.opt.expandtab = true  -- convert Tab keypresses to spaces
```

This config (likely) uses 2-space indentation — standard for JavaScript/TypeScript projects. Language-specific overrides live in `after/ftplugin/` (e.g., `go.lua` uses tabs for Go).

### Scrolling

```lua
vim.opt.scrolloff = 8     -- keep 8 lines above/below cursor when scrolling
vim.opt.sidescrolloff = 8 -- keep 8 columns to the left/right when horizontal scrolling
```

`scrolloff = 8` means your cursor never gets within 8 lines of the screen edge. This prevents the disorienting "cursor at the very bottom of screen" situation. Many Neovim users set this to a high value (like 999) to keep the cursor permanently centered.

### Search

```lua
vim.opt.ignorecase = true  -- case-insensitive search by default
vim.opt.smartcase = true   -- UNLESS you type uppercase letters (then case-sensitive)
vim.opt.hlsearch = true    -- highlight all search matches
vim.opt.incsearch = true   -- show matches as you type (incremental)
```

`smartcase` is the clever one: `/foobar` matches "Foobar", "FOOBAR", "fooBar". But `/Foobar` only matches "Foobar" (because you typed uppercase). Best of both worlds.

### Clipboard

```lua
vim.opt.clipboard = "unnamedplus"  -- sync default register with system clipboard
```

With this, any `y` (yank) or `d` (delete) also puts text in the system clipboard, and `p` (paste) pastes from the system clipboard. This makes Neovim behave more like VSCode where Ctrl+C/V operates on the OS clipboard.

**Trade-off:** If you don't want every delete to overwrite your clipboard, remove this option and use `"+y` / `"+p` for explicit system clipboard operations.

### Undo Persistence

```lua
vim.opt.undofile = true  -- persist undo history to disk
```

This means your undo history survives closing and reopening Neovim. Come back to a file a week later and still be able to undo changes from last session. The undo files are stored in `~/.local/state/nvim/undo/`.

### Splits

```lua
vim.opt.splitright = true  -- new vertical splits appear to the right
vim.opt.splitbelow = true  -- new horizontal splits appear below
```

These make split behavior feel more natural: `<leader>sv` creates a window to the right, `<leader>sh` creates one below.

---

## 31. The Neovim Ecosystem: What Makes This Different from Other Configs

You might have heard of LazyVim, NvChad, or AstroNvim — popular Neovim "distributions" that provide a pre-configured setup.

This config is a **custom personal config**, not a distribution. Here's what that means in practice:

| Feature                | Distribution (LazyVim/NvChad)  | This Config                              |
| ---------------------- | ------------------------------ | ---------------------------------------- |
| Pre-configured plugins | Yes — curated set              | Yes — curated set                        |
| Plugin management      | lazy.nvim                      | lazy.nvim                                |
| Default keybindings    | Distribution's own             | Personally crafted                       |
| Customization          | Override distribution defaults | Modify directly                          |
| Updates                | Upgrade the distribution       | Upgrade individual plugins               |
| Learning curve         | Lower (more magic)             | Higher (must understand your own config) |
| Flexibility            | Higher with overrides          | Maximum — it's all yours                 |

**Why this matters for you:** When something breaks or you want to change behavior, you look at YOUR config files directly. There's no "distribution layer" to understand. `dotfiles/.config/nvim/lua/de100/` contains everything — read it, understand it, change it.

This also means this config evolves with one person's needs and preferences. It's opinionated in specific ways that suit its author. You'll want to adapt things over time.

---

## 32. Neovim vs VSCode: The Honest Comparison

Let's be balanced for a moment. Not everything is better in Neovim.

### Where Neovim Genuinely Wins

**Speed and keyboard efficiency.** Once proficient, editing operations that take 5 clicks in VSCode take 1-3 keystrokes in Neovim. This compounds over a full workday.

**Customizability.** Every behavior is code. You can make Neovim do literally anything that can be expressed in Lua. No extension API limits.

**Resource usage.** Neovim uses a fraction of VSCode's memory and CPU. On older hardware or in resource-constrained environments, this matters.

**Remote / SSH editing.** Running Neovim directly on a remote server over SSH is seamless. VSCode's remote extension is impressive but requires more setup and the server side runs Electron over the network.

**Terminal integration.** Neovim lives in the terminal. Combined with tmux, you can create powerful development environments that live in the shell. No GUI required.

**Undo tree.** The non-linear undo history is genuinely superior to linear undo in any other editor.

**Macros.** Built-in macro recording is more powerful than any automation extension.

### Where VSCode Genuinely Wins

**Out-of-the-box experience.** VSCode works well for most languages with minimal configuration. No spending an afternoon setting up your config.

**GUI-first features.** Debugging breakpoints in VSCode's gutter are visual and intuitive. The Git diff viewer has syntax-highlighted side-by-side diffs that are easier to parse. Notebooks (Jupyter) are first-class.

**Extension marketplace.** The VSCode marketplace has 30,000+ extensions. Neovim has ~thousands of plugins, but VSCode's depth in some niches (e.g., specific cloud providers, niche frameworks) is hard to match.

**Onboarding.** Teaching a new developer on your team VSCode takes minutes. Teaching Neovim takes weeks.

**Integrated GitHub experience.** GitHub Pull Requests extension in VSCode is excellent. Neovim equivalents exist but aren't as polished.

**Windows support.** VSCode is a first-class Windows citizen. Neovim works on Windows but the experience is better on Unix-like systems.

### The Honest Bottom Line

Neovim isn't "better" in an objective sense. It's better **for a specific workflow**: keyboard-driven, terminal-native, highly customized editing by someone who's willing to invest weeks learning it. If you code for 6+ hours a day and are frustrated by context-switching to the mouse or navigating menus, Neovim is worth the investment. If you code occasionally or work in many GUI-friendly contexts, VSCode might genuinely serve you better.

Many developers use both: Neovim in the terminal for serious coding sessions, VSCode for specific tasks (notebooks, remote pair programming, GUI debugging).

---

## 33. Diagnosing Your Own Config: Reading Error Messages

When Neovim shows an error at startup or when using a plugin, here's how to read and fix it.

### Common Error Types

**"module 'X' not found"**

```
E5113: Error while calling lua chunk
module 'nvim-treesitter' not found
```

This means a plugin is referenced before it's installed. Run `:Lazy sync` to install missing plugins.

**"attempt to index a nil value"**

```
E5108: Error executing lua: ...nil value (field 'X')
```

A plugin or function returned `nil` when something expected a table. Usually means a plugin failed to load or a config is misconfigured.

**"No such file or directory"**
Usually means an LSP server binary isn't installed. Open `:Mason` and install it.

**LSP server keeps disconnecting**
Check `:LspLog` for the full log of LSP server communication. Often a missing dependency or config error.

### How to Read Stack Traces

When Lua code throws an error, you get a stack trace:

```
...nvim/lua/de100/plugins/lsp/lsp.lua:42: attempt to call a nil value
stack traceback:
  ...lsp/lsp.lua:42: in function 'setup'
  ...lazy/lazy.nvim/lua/lazy/core/loader.lua:375: in function 'config'
```

Read from the bottom up — the bottom is where the error originated. Line 42 of `lsp/lsp.lua` is where the actual problem is. Open that file, go to line 42, and investigate.

---

## 34. Using Neovim for Different File Types

One of Neovim's strengths is that it handles every text-based file type well. Here's a quick overview of what to expect for common file types in this config.

### Markdown Files

Markdown gets special treatment:

- `render-markdown.nvim` renders markdown formatting inline (headers look like headers, bold text looks bold)
- `markdown-preview.nvim` opens a live preview in the browser (`:MarkdownPreview`)
- `bullets.nvim` makes bullet list editing ergonomic
- `img-clip.nvim` lets you paste images from clipboard directly into markdown
- Spell checking is enabled for markdown buffers (in `after/ftplugin/markdown.lua`)

### JSON / JSONC

- LSP provides schema validation (if a JSON schema is available via `jsonls`)
- Folding works on JSON objects and arrays
- JSONC (JSON with comments) is treated as its own filetype

### YAML

- `yamlls` provides schema completion and validation
- Ansible YAML files are handled by `ansiblels`

### Shell Scripts

- `bashls` provides LSP for bash
- `shfmt` formats shell scripts
- The config enables stricter POSIX checks for `.sh` files (see `after/ftplugin/sh.lua`)

### SQL

- `sqlls` provides completion and basic LSP
- `dadbod-ui` for running queries against real databases
- `after/ftplugin/sql.lua` has SQL-specific settings

---

## 35. Quick Reference Cards for Normal Mode

Since Day One is all about survival, here are two reference cards you can keep beside your keyboard or print out.

### Reference Card A: The Motions Grid

```
                    ┌──────────────────────────────────────┐
                    │       CURSOR MOVEMENT REFERENCE       │
                    ├──────────────────────────────────────┤
                    │                                      │
                    │  CHARACTER:  h ← · → l              │
                    │              · ↑ · ↓ ·              │
                    │              · k · j ·              │
                    │                                      │
                    │  WORD:  b ←word→ w                   │
                    │         B ←WORD→ W                   │
                    │         ge ←end     e→ end           │
                    │                                      │
                    │  LINE:  0  ^  |  $  g_               │
                    │         └─ ─┘  │  └── ──┘           │
                    │       start  col1   end             │
                    │                                      │
                    │  FILE:  gg = top    G = bottom       │
                    │         {number}G = go to line       │
                    │                                      │
                    │  SCROLL: Ctrl+D = down half page     │
                    │          Ctrl+U = up half page       │
                    │          Ctrl+F = down full page     │
                    │          Ctrl+B = up full page       │
                    │                                      │
                    │  JUMP:  Ctrl+O = back in jump list   │
                    │         Ctrl+I = forward in jump list│
                    │                                      │
                    └──────────────────────────────────────┘
```

### Reference Card B: Operators Summary

```
                    ┌──────────────────────────────────────┐
                    │       OPERATOR REFERENCE              │
                    ├──────────────────────────────────────┤
                    │                                      │
                    │  d = Delete   y = Yank(copy)         │
                    │  c = Change   = = Auto-indent        │
                    │  > = Indent   < = Unindent           │
                    │  gu = lower   gU = UPPER             │
                    │                                      │
                    │  Double operator = whole line:        │
                    │  dd = delete line   yy = yank line   │
                    │  cc = change line   == = indent line │
                    │                                      │
                    │  CAPITAL = to end of line:           │
                    │  D = delete to EOL  (= d$)           │
                    │  C = change to EOL  (= c$)           │
                    │  Y = yank to EOL    (= y$)           │
                    │                                      │
                    │  COMMON COMBOS:                      │
                    │  dw  = delete word forward           │
                    │  cw  = change word                   │
                    │  ciw = change inner word             │
                    │  ci" = change inside quotes          │
                    │  di( = delete inside parens          │
                    │  yy  = yank line                     │
                    │  p   = paste after cursor            │
                    │  P   = paste before cursor           │
                    │                                      │
                    └──────────────────────────────────────┘
```

---

## 36. Frequently Asked Questions from VSCode Users

**Q: Is there autosave in Neovim?**

A: This config includes `auto-save.nvim` but it's currently **disabled** (`enabled = false` in `auto-save.lua`). You can enable it by changing that flag. When enabled, it's quite smart — it saves on focus loss, buffer leave, and other events while NOT saving during Visual mode operations or flash jumps. Until then, use `Ctrl+S` actively.

---

**Q: Can I use the mouse in Neovim?**

A: Yes. Mouse support is enabled by default. You can click to position the cursor, scroll, and click on UI elements. However, the Neovim community generally encourages moving away from the mouse for efficiency reasons. The mouse is great as a crutch while learning.

---

**Q: Why is my TypeScript/LSP not working?**

A: Check these in order:

1. `:Mason` → is `vtsls` installed? If not, install it.
2. `:LspInfo` (when in a TS file) → is the LSP attached?
3. Check for `tsconfig.json` in your project root — most TypeScript LSP servers require it.
4. If the file is in a node_modules or vendor directory, LSP may be intentionally disabled.

---

**Q: How do I change font size?**

A: Neovim itself doesn't control font size — that's your terminal's job. Change the font size in your terminal emulator (iTerm2, Alacritty, Kitty, etc.). If using a GUI wrapper like Neovide, it has its own font size option.

---

**Q: I accidentally typed something in Normal mode and now my file has weird text. How do I fix it?**

A: Press `Esc` to make sure you're in Normal mode. Then press `u` repeatedly to undo until the weird text is gone. If you've saved the file with the bad content, `:e!` reloads from disk (discarding all changes since last save). If even that's not enough, use git to restore: `:Git checkout %` or `<leader>gdi` to see what changed.

---

**Q: Can I have the Explorer sidebar always visible like VSCode?**

A: Technically yes, but it goes against the Neovim workflow philosophy. You can configure `neo-tree.nvim` (not in this config but easy to add) for a persistent sidebar. However, most Neovim users prefer the picker workflow. Try `<leader>pf` for 2 weeks before deciding you need the sidebar — you'll likely find you don't.

---

**Q: How do I split the editor and see two files at once?**

A: `<leader>sv` for vertical split, `<leader>sh` for horizontal split. Then `Ctrl+H/J/K/L` to move between the splits. Use `<leader>pf` or `:e filename` to open a different file in each split.

---

**Q: Does Neovim support Jupyter notebooks?**

A: Partially. There are plugins for Jupyter/Molten-style notebook editing in Neovim. However, for heavy notebook work, VSCode or JupyterLab is still the better choice. Neovim excels at `.py` script editing.

---

**Q: Where are my plugins installed?**

A: `~/.local/share/nvim/lazy/` — each plugin is a git repo there. lazy.nvim manages them all. You can browse this directory to inspect plugin source code.

---

**Q: My Neovim is slow on large files. What do I do?**

A: Large files can slow down treesitter syntax highlighting and LSP. Quick fixes:

- `:TSBufDisable highlight` — disable treesitter highlighting for this buffer
- `:LspStop` — stop the LSP for this session
- Add the file to conform.nvim's exclusion list if it's being formatted on save
- Check if any auto-command is firing repeatedly on the file

---

## 37. Beginner Drills: Daily Practice Routines

The fastest path to fluency is deliberate daily practice layered on top of real work. Here are structured drills you can do in the first two weeks.

### Drill Set A: Motion Fluency (5 minutes/day, Days 1-7)

Open any code file you're familiar with. Complete these without using arrow keys or mouse:

**Round 1 — Basic navigation:**

1. Jump to the first line: `gg`
2. Jump to the last line: `G`
3. Jump to line 25: `25G`
4. Jump forward 10 lines: `10j`
5. Jump to end of line: `$`
6. Jump to start of line: `0`
7. Jump forward 5 words: `5w`
8. Jump back 3 words: `3b`

**Round 2 — Find and navigate:**

1. Search for a function name: `/function`
2. Jump to next match: `n`
3. Jump to previous match: `N`
4. Search for the word under your cursor: `*`
5. Clear highlights: `<leader>nh`
6. Jump to next occurrence of the letter `e` on this line: `fe`
7. Jump to just before the next `(`: `t(`

**Round 3 — Scroll comfortably:**

1. Scroll down half page: `Ctrl+D`
2. Scroll up half page: `Ctrl+U`
3. Center current line: `zz`
4. Move current line to top: `zt`
5. Move current line to bottom: `zb`

Time yourself. The goal is to complete Round 1 in under 30 seconds by the end of week one.

---

### Drill Set B: Insert Mode Mastery (5 minutes/day, Days 3-10)

Open a scratch file. Practice all insert entry points until muscle memory forms:

```
Task: Add the text "INSERTED" at these positions:
- Before the word "hello": navigate to h, press i, type "INSERTED", Esc
- After the word "world": navigate to d, press a, type "INSERTED", Esc
- At start of line: press I, type "INSERTED", Esc
- At end of line: press A, type "INSERTED", Esc
- On new line below: press o, type "INSERTED", Esc
- On new line above: press O, type "INSERTED", Esc
```

Repeat this for 10 different lines. Try to do the entire drill without thinking — let the muscle memory take over.

---

### Drill Set C: Operator + Motion Combos (10 minutes/day, Days 5-14)

Create a test file with this content:

```javascript
function greetUser(firstName, lastName) {
  const message = "Hello, " + firstName + " " + lastName;
  const greeting = "Welcome to our platform!";
  return message;
}

const users = [
  { name: "Alice", age: 30 },
  { name: "Bob", age: 25 },
];
```

Now practice these operations (undo with `u` between each):

| Operation                                 | Command                     | Expected Result                         |
| ----------------------------------------- | --------------------------- | --------------------------------------- |
| Delete the word `firstName`               | `daw`                       | removes word + trailing space           |
| Delete text inside `"Hello, "`            | `di"`                       | leaves `""`                             |
| Change text inside `'...'`                | `ci'`                       | removes and enters insert inside quotes |
| Delete the entire function first line     | `dd`                        | removes that line                       |
| Yank 3 lines from `const users`           | `3yy`                       | 3 lines in clipboard                    |
| Change `message` wherever cursor is on it | `ciw` then type replacement | replaces the whole word                 |
| Delete from cursor to end of line         | `D`                         | removes rest of line                    |
| Indent the `const message` line one level | `>>`                        | indents right                           |
| Lowercase the word `INSERTED`             | `guw`                       | makes it lowercase                      |

---

### Drill Set D: Visual Mode Precision (10 minutes/day, Days 7-14)

Same test file. Practice visual selection:

1. Select the string content inside `"Hello, "` → `vi"` (visual inner double quotes)
2. Select the content inside `{ }` of the first user → `vi{`
3. Select the entire first `{ name: ..., age: 30 }` line → `V`
4. Select 3 lines of users → `V2j`
5. Delete them: `d` (then `u` to undo)
6. Block-select the `name:` part of all 3 lines → `Ctrl+V` then `j` then `e`
7. Change all those `name:` → `c` then type `fullName:`

---

## 38. The Big Picture: What Comes After Day One

You've absorbed a lot. Let's close with the big picture view of where you are in the learning journey and what the full Neovim skill tree looks like.

### The Skill Tree

```
                    ┌─────────────────────────────────────────┐
                    │           NEOVIM SKILL TREE              │
                    └─────────────────────────────────────────┘

TIER 1 — SURVIVAL (Week 1):                   ← YOU ARE HERE
  [x] Modes: Normal, Insert, Visual, Command
  [x] Enter/exit Insert mode (i/a/o/A/I/O)
  [x] Navigate: hjkl, w/b, 0/$, gg/G
  [x] Save: :w, Ctrl+S
  [x] Quit: :q, :wq, :q!
  [x] Undo/redo: u / Ctrl+R
  [x] Basic visual selection: v, V, Ctrl+V

TIER 2 — COMPETENCE (Weeks 2-3):
  [ ] Operator + Motion grammar: dw, ciw, y$
  [ ] Text objects: ci", da(, yit
  [ ] The dot command: .
  [ ] File picker: <leader>pf
  [ ] Buffer management: Tab, Shift+Tab, <leader>bx
  [ ] LSP basics: gd, K, gR, <leader>ca, <leader>rn
  [ ] Search and replace: /, :%s/old/new/gc
  [ ] Splits: <leader>sv, Ctrl+H/J/K/L

TIER 3 — PROFICIENCY (Weeks 4-6):
  [ ] Harpoon: <leader>ha, <leader>h1-4
  [ ] Git workflow: <leader>gs, <leader>gn, <leader>lg
  [ ] Trouble diagnostics: <leader>xw, <leader>xd
  [ ] Marks: ma, `a
  [ ] Macros: q{letter}, @{letter}
  [ ] Surround: sa/ds/ca from mini.surround
  [ ] Flash jumps: s + 2 chars + label
  [ ] Registers: "0, "+, "_, named registers

TIER 4 — MASTERY (Months 2-3):
  [ ] Debugging: F5, F1/F2/F3, <leader>daptb
  [ ] Testing: <leader>tN, <leader>tF, <leader>tS
  [ ] Custom snippets: LuaSnip
  [ ] Aerial + Treesitter navigation
  [ ] Config customization: adding plugins, keybindings
  [ ] Macros for complex transformations
  [ ] Undo tree: <leader>uu

TIER 5 — WIZARD (Month 3+):
  [ ] Writing plugins/functions
  [ ] Complex operator mappings
  [ ] Custom text objects
  [ ] Autocommands for workflow automation
  [ ] Integrating external tools via jobs
```

You're at Tier 1. Everything above Tier 1 is optional — but each tier makes you measurably faster and more capable. Tier 2 alone is where most Neovim users hit the "this is amazing" realization. Tier 3 is where you stop missing VSCode.

---

## 39. The Philosophical Case for Modal Editing

Let's end with some philosophy, because understanding the "why" makes the "what" easier to internalize.

### The Mouse Is a Pointing Device, Not an Editing Device

Mice are excellent for spatial, visual tasks: drawing, navigating GUIs, selecting items from lists. Editing text is NOT a spatial task. It's a semantic task: "go to this function," "change this variable name," "delete this block." These are conceptual operations that map naturally to commands, not to pointing and clicking.

When you double-click to select a word in VSCode, you're using a spatial metaphor (draw a rectangle around this pixel region) to represent a semantic operation (select this word). It works, but it's imprecise and slow. `ciw` (change inner word) is more direct: it _says_ what it does.

### Every Keystroke Counts

Professional developers type thousands of keystrokes per day. The efficiency of those keystrokes compounds over time. A 2x improvement in keystroke efficiency means you can do 2x the work — or do the same work in half the time. Modal editing, once internalized, provides roughly that level of improvement for text manipulation tasks.

The learning curve is real, but it's finite. The efficiency gains are permanent.

### Composability and Expressiveness

The operator + motion + text-object grammar gives you a language for describing edits. Just like programming languages let you express complex computations by composing simple operations, Vim's grammar lets you express complex edits by composing simple primitives.

`d` + `i` + `{` = "delete inner brace content." You didn't memorize that shortcut. You composed it from three things you knew. This is the difference between having 100 specific shortcuts vs. having a grammar that generates thousands of operations from ~20 building blocks.

### The Keyboard-First Principle

When your hands are on the keyboard, there's a natural efficiency to staying on the keyboard. Every time you reach for the mouse, you:

1. Move your hand 10-15cm to the right
2. Visually reacquire your position on screen
3. Perform the operation
4. Move your hand back
5. Reacquire your position on the keyboard

That's 3-5 seconds of overhead per mouse operation. For someone doing 100 such operations per day, that's 5-8 minutes of "context switching" that adds up to hours over a week.

This doesn't mean never use the mouse. It means: every time you catch yourself reaching for it, ask "is there a keyboard way to do this?" The answer, in Neovim, is almost always yes.

---

_"The key to Neovim mastery is not learning 500 commands at once. It's learning 5 commands so well that they become reflex, then adding 5 more. Repeat until you're terrifyingly fast."_

Now, next is  [02-the-vscode-translator.md](./02-the-vscode-translator.md)
