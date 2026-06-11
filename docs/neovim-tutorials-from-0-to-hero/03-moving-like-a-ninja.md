# 03 · Moving Like a Ninja

> "In VSCode you move your hand to the mouse. In Neovim you teleport."

---

## Table of Contents

1. [The Philosophy](#1-the-philosophy)
2. [Character Motion — h j k l](#2-character-motion--h-j-k-l)
3. [Word Motion — w b e W B E ge gE](#3-word-motion--w-b-e-w-b-e-ge-ge)
4. [Line Motion — 0 ^ $ g_ f t ; ,](#4-line-motion--0--g_-f-t--)
5. [Flash.nvim — The Teleporter](#5-flashnvim--the-teleporter)
6. [Paragraph and Block Motion](#6-paragraph-and-block-motion)
7. [Jump List — The History Trail](#7-jump-list--the-history-trail)
8. [Marks — Personal Bookmarks](#8-marks--personal-bookmarks)
9. [Scroll Commands](#9-scroll-commands)
10. [Search as Motion](#10-search-as-motion)
11. [The % Jump](#11-the--jump)
12. [Complete Motion Reference Table](#12-complete-motion-reference-table)
13. [Motion Combos — Putting It Together](#13-motion-combos--putting-it-together)
14. [Exercises](#14-exercises)

---

## 1. The Philosophy

Let me paint you a picture.

You are in VSCode. You spot a bug on line 47. Your current cursor is on line 12. Without thinking, your right hand leaves the keyboard, wraps around the mouse, scrolls down, squints at the screen, clicks somewhere near line 47, misses by two lines, clicks again. Four seconds have passed. You've broken your mental flow — that fragile state where your brain holds a whole system in memory — to perform a physical task a golden retriever could be trained to do.

Now you are in Neovim. You type `/buggyFunctionName`, hit Enter, and you are there. Or you type `s`, then two characters you see near the bug, and a label pops up. You type the label and you are there. Zero mouse. Zero hand movement. Zero flow interruption.

This is not just about speed, though speed matters. A study of expert Vim users shows they spend roughly 80% less time on cursor positioning than mouse users. But the real win is cognitive: when movement is effortless, your brain stops thinking about *how* to get somewhere and focuses entirely on *what* to do when you get there. The motion becomes transparent, like walking — you do not think about which muscle to fire next when you walk to the kitchen.

The compound motion mindset is this: Vim motions are not a list of shortcuts to memorize. They are a *language*. Verbs (operators like delete, change, yank) combine with nouns (motions and text objects). Once you internalize a few primitives — maybe 15 motions and 6 operators — you have access to hundreds of combinations. You will discover new ones by accident, and each discovery feels like finding a secret passage.

This tutorial covers motions specifically. By the end, you will have a complete repertoire. By the end of *practicing* what is here, you will move through code faster than you thought was possible. The key is: do not try to learn everything at once. Pick two new motions per day. Use them. Let them become muscle memory before you add more.

Let's go.

---

## 2. Character Motion — h j k l

These are the four fundamental direction keys. They map to the arrow keys but live right under your right hand's home row position.

```
          k
          ↑
    h ←   ·   → l
          ↓
          j
```

In more concrete terms on your keyboard:

```
  Normal mode:

  h = left  (← one character)
  j = down  (↓ one line)
  k = up    (↑ one line)
  l = right (→ one character)
```

### Why Not Arrow Keys?

Arrow keys absolutely work in Neovim. Your config doesn't disable them. But here is the thing: reaching for arrow keys means moving your hand off the home row, which means every motion costs you a half-second repositioning. Over the course of a coding session, that adds up. More importantly, you can not combine arrow keys with counts or operators the way you can with hjkl.

### Count Prefix: Do Math With Motions

Any motion can be prefixed with a number:

```
5j   = move down 5 lines
10l  = move right 10 characters
3k   = move up 3 lines
```

This is where your config's **relative line numbers** become a superpower. Instead of showing absolute line numbers, relative line numbers show how far each line is from your cursor:

```
  5  const foo = 1;         ← 5 lines above cursor
  4  const bar = 2;         ← 4 lines above cursor
  3  const baz = 3;         ← 3 lines above cursor
  2  function hello() {     ← 2 lines above cursor
  1  }                      ← 1 line above cursor
72   │ return greeting;     ← cursor is HERE (absolute line 72)
  1  }                      ← 1 line below cursor
  2                         ← 2 lines below cursor
  3  function world() {     ← 3 lines below cursor
```

See that `function hello()` at relative line 2? You just type `2k` and you are there. No counting, no mental arithmetic — the number is literally printed on the screen next to the line you want. This is *the* reason relative line numbers exist, and it is one of those features that seems minor until you use it for an hour and then can never go back.

### When NOT to Use h j k l

Character-by-character movement is for small adjustments: fixing a typo two characters left, moving down one line to fix indentation. For anything more than a few characters or lines, there is a better tool. Using `jjjjjjjjjjj` to move 11 lines is like driving to the airport in reverse. It works, but why?

The rest of this tutorial covers all those better tools.

---

## 3. Word Motion — w b e W B E ge gE

Words are the natural unit of code. Variable names, keywords, function names — they are all words. Vim has two flavors of "word": lowercase `word` (stops at punctuation boundaries) and uppercase `WORD` (stops only at whitespace).

### Visualizing the Difference

Consider this line of code:

```
foo.bar(baz_qux)
```

Here is where `w` stops (each `^` marks a stop position, i.e., the start of the next small-word):

```
foo.bar(baz_qux)
^  ^   ^^  ^
```

And here is where `W` stops (only whitespace boundaries):

```
foo.bar(baz_qux)
^
```

`W` considers `foo.bar(baz_qux)` as one single WORD because there is no whitespace in it. That might seem weird at first, but it is incredibly useful when you want to skip over an entire expression as a unit.

Let's use a more realistic example with a full expression:

```
const result = myObject.getValue(arg1, arg2);
```

Stepping through with `w` (one press = one arrow):

```
const result = myObject.getValue(arg1, arg2);
^^^^^_^^^^^^_^_^^^^^^^^_^^^^^^^^_^^^^__^^^^_^
```

Each `_` represents a stop. Notice it stops at `.`, `(`, `,`, `)`, `;`.

Stepping through with `W` (one press = one arrow):

```
const result = myObject.getValue(arg1, arg2);
^^^^^_^^^^^^_^_^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
```

Only the spaces make `W` stop. Three presses gets you from `const` to `myObject.getValue(arg1,` as a unit.

### All Word Motions

```
  w  = move to START of NEXT word          (stops at punctuation)
  W  = move to START of NEXT WORD          (stops at whitespace only)
  b  = move to START of PREVIOUS word      (backward)
  B  = move to START of PREVIOUS WORD      (backward, whitespace only)
  e  = move to END of current/next word    (stops at punctuation)
  E  = move to END of current/next WORD    (stops at whitespace only)
  ge = move to END of PREVIOUS word
  gE = move to END of PREVIOUS WORD
```

Visual summary on the word `getValue`:

```
  getValue
  ^          ← b or w lands here (start)
          ^  ← e lands here (end)
```

### When to Use W vs w

Rule of thumb: **`w` for navigating within an expression, `W` for jumping over whole terms.**

- Editing `object.property` where you want to change just `property`: use `w` to reach it (it stops right at the `p` of `property`).
- Jumping from one argument to another in `foo(arg1, arg2, arg3)`: use `W` to skip `arg1,` as a unit, land on `arg2`.
- In a CSS rule like `margin: 0 auto !important;`, use `W` to hop between values quickly.

Counts work here too: `3w` = jump forward 3 small-word starts. `2W` = jump 2 WORD starts.

---

## 4. Line Motion — 0 ^ $ g_ f t ; ,

Sometimes you need to move within the current line. For that, Vim has an excellent set of line-specific motions.

### The Endpoints

Consider this line (with leading spaces):

```
    const foo = bar.baz(qux);
^                              ← 0  (column 1, absolute)
    ^                          ← ^  (first non-blank character)
                             ^ ← $  (end of line, after last char)
                            ^  ← g_ (last non-blank character)
```

```
  0   = jump to column 1 (absolute beginning of line)
  ^   = jump to first non-blank character (ignores indentation)
  $   = jump to end of line
  g_  = jump to last non-blank character (ignores trailing spaces)
```

In practice, `^` is almost always what you want instead of `0`, because code is indented and you rarely want to land on whitespace. But `0` is useful in macros and scripting where you need a reliable absolute anchor.

`g_` is the mirror of `^` — it skips trailing spaces and lands on the last actual character. Handy when dealing with files that have inconsistent trailing whitespace.

### Find on Line — f and t

These are among the most used line motions, and they have no real equivalent in VSCode without a plugin:

```
  f{char} = find {char} FORWARD on current line, land ON it
  F{char} = find {char} BACKWARD on current line, land ON it
  t{char} = till {char} forward, land BEFORE it
  T{char} = till {char} backward, land AFTER it
  ;       = repeat last f/F/t/T in the SAME direction
  ,       = repeat last f/F/t/T in the OPPOSITE direction
```

Let's visualize on this line, with the cursor starting at `c`:

```
    const foo = bar.baz(qux);
    ^
```

Press `f=`:

```
    const foo = bar.baz(qux);
              ^
```

Press `;` (repeat forward):

```
    const foo = bar.baz(qux);
                       ^
```

Wait, there is no second `=`, so `;` would not move further (or move past the closing paren). Let me use a better example — finding `a`:

```
    const foo = bar.baz(qux);
    ^
```

`fa` lands on the `a` in `bar`:

```
    const foo = bar.baz(qux);
                  ^
```

`;` repeats forward, finding the next `a` in `baz`:

```
    const foo = bar.baz(qux);
                      ^
```

`,` reverses direction, going back to `bar`'s `a`:

```
    const foo = bar.baz(qux);
                  ^
```

Now `t(` — till open-paren, landing BEFORE it:

```
    const foo = bar.baz(qux);
                      ^
                       ^  ← this is where f( would land
                      ^   ← this is where t( lands (one before)
```

The difference between `f` and `t` becomes crucial with operators. `ct(` means "change till the open-paren" — it changes everything from the cursor up to (but not including) the `(`. This is the idiomatic way to change a function call's name: `ct(` then type the new name, and the arguments in the parens are untouched.

### VSCode Comparison

VSCode has no equivalent line-navigation shortcut. The closest is `Ctrl+F` (find in file) but that searches the whole buffer and requires you to press Enter. In Neovim, `f` + one character is instantaneous. No confirmation, no dialog box. You see the character, you press `f` + that character, cursor is there.

---

## 5. Flash.nvim — The Teleporter

If `f` is a motorcycle, Flash.nvim is a teleporter. This is the most powerful navigation tool in your config and the one that will most dramatically change how you move through code.

### What Flash Does (Normal Mode: `s`)

1. You press `s`
2. You type 1 or 2 characters that appear somewhere visible on your screen
3. Flash scans every visible position for those characters and shows a **label** (a single letter, usually highlighted in orange or red) next to each match
4. You type the label
5. Your cursor is now there

No Enter. No confirmation. Just: see something, press `s`, type what you see, type the label, done.

```
  Before pressing s:

  function calculateTotal(items) {          ← line 1
    const sum = items.reduce((acc, item) => {  ← line 2
      return acc + item.price;               ← line 3
    }, 0);                                   ← line 4
    return sum * taxRate;                    ← line 5
  }                                          ← line 6
  [cursor is here on line 6]

  You press s, then type "pr":

  function calculateTotal(items) {
    const sum = items.reduce((acc, item) => {
      return acc + item.[a]rice;   ← label 'a' appears here
    }, 0);
    return sum * taxRate;          ← no match for "pr" here
  }
  [cursor stays here]

  You press 'a':
  [cursor jumps to 'p' of 'price' on line 3]
```

In practice, labels are placed on the first character of each match, and Flash is smart enough to often give you just one label when only one match exists. You type `s`, two characters, and if it's unique, you jump immediately — no label required.

### `s` vs `f` — When to Use Each

```
  f = find on CURRENT LINE only
  s = jump ANYWHERE VISIBLE (any line)
```

Use `f` when you know the target is on the same line as your cursor. Use `s` for any inter-line navigation. In practice, `s` ends up replacing most of your `j`/`k` travel for any visible destination.

### Treesitter Jump — `S`

`S` is the uppercase sibling of `s`. Instead of jumping to character positions, it jumps to **code structure boundaries** — function starts, block starts, argument lists, and other AST nodes that Treesitter recognizes.

Press `S` and you will see labels appear at the beginning of each structural element visible on screen. This is less about jumping to a specific character and more about jumping to a logical code unit.

```
  function greet(name) {     ← S would label here (function start)
    const msg = "Hello, " +  ← S would label here (statement start)
      name + "!";
    return msg;              ← S would label here (return statement)
  }                          ← S would label here (block end)
```

Use `S` when you want to jump to "the start of that if block" or "the beginning of that function" — structural jumps rather than character jumps.

### Remote Flash — `r` (Operator Mode)

This one is a bit mind-bending but incredibly powerful. `r` activates Flash in **operator mode**, meaning you are about to perform an operation (delete, change, yank) at a distant location **without moving your cursor there first**.

Example: you want to yank the word `taxRate` on line 5, and your cursor is on line 1. Normally you would: jump to line 5, yank the word, jump back. With remote flash:

```
  yr    = "yank using remote flash"
         (type 'y', then 'r' to activate remote flash)
         Flash now asks you to pick a destination
         Type the label for 'taxRate'
         The word is yanked. Your cursor never moved.
```

Think of it as: `r` turns any operator into a "reach out and grab" operation. The cursor stays where it is, but the operation happens wherever you aim Flash.

### Treesitter Search in Operator/Visual — `R`

`R` combines treesitter-aware selection with operator/visual mode. You can visually select entire AST nodes — like an entire function argument, a whole block, a complete expression — by targeting structural boundaries rather than character positions.

### VSCode Comparison

The closest VSCode has is an extension like "AceJump" or "EasyMotion" (for the Vim extension), but these are add-ons. In your Neovim config, this is built in and tuned. VSCode's `Ctrl+F` is powerful for finding text but it pops up a dialog, takes you out of the flow, and requires Enter. Flash is instantaneous and lives entirely in the editor viewport.

### Practice Flash Right Now

1. Open any file with 30+ lines of code
2. Scroll so you can see maybe 40 lines
3. Pick something visible — a variable name, a keyword
4. Press `s`
5. Type the first two characters of that target
6. Press the label that appears
7. Notice you are there

Do this 10 times. It will feel slow at first. After those 10 repetitions your brain starts to see the screen as a teleportation grid. Within a week, reaching for `j` multiple times will feel wrong.

---

## 6. Paragraph and Block Motion

When you need to move in bigger chunks — between functions, between logical blocks, between paragraphs of comments — these motions handle it.

### Paragraph Motions — { and }

In Vim, a "paragraph" is any block of text separated by blank lines. In code, this usually means between logical sections:

```
  function foo() {         ┐
    const x = 1;           │ paragraph 1
    return x;              │
  }                        ┘
                            ← blank line
  function bar() {         ┐
    const y = 2;           │ paragraph 2
    return y;              │
  }                        ┘
                            ← blank line
  // A comment block       ┐
  // that spans            │ paragraph 3
  // three lines           ┘
```

```
  {  = jump to PREVIOUS blank line (move up to paragraph boundary)
  }  = jump to NEXT blank line (move down to paragraph boundary)
```

From inside `function bar()`, pressing `{` lands you on the blank line above `function bar()`. Pressing `{` again lands on the blank line above `function foo()`. Fast navigation between code sections.

### Sentence Motions — ( and )

```
  (  = jump to PREVIOUS sentence
  )  = jump to NEXT sentence
```

More useful in prose/comments than in code, but worth knowing. In code, "sentence" often corresponds to logical statement groups.

### Section Motions — [[ and ]]

```
  [[  = jump to PREVIOUS function/section start
  ]]  = jump to NEXT function/section start
  []  = jump to PREVIOUS function/section end
  ][  = jump to NEXT function/section end
```

These depend on the filetype and may behave differently with Treesitter, but `[[` and `]]` are reliable ways to hop between top-level definitions in most languages.

### Matching Bracket Jump — [{ ]} and Related

```
  [{  = jump to the OPENING brace of the current block
  ]}  = jump to the CLOSING brace of the current block
  [(  = jump to the OPENING paren of the current expression
  ])  = jump to the CLOSING paren of the current expression
```

If you are inside a deeply nested function and want to find where the outer block starts:

```
  function outer() {
    if (condition) {
      for (let i = 0; i < n; i++) {
        █  ← cursor here, deeply nested
           press [{ → jumps to { of for loop
           press [{ → jumps to { of if block
           press [{ → jumps to { of function outer
      }
    }
  }
```

These are fantastic for navigating complex, deeply nested code without counting braces manually.

---

## 7. Jump List — The History Trail

Every time you make a "large" jump (using `/`, `G`, `gg`, `Ctrl+D`, `Ctrl+U`, `%`, or Flash), Neovim remembers where you were. This creates a jump list — a history of positions, like a browser's back/forward history for your cursor.

```
  Ctrl+O = jump BACK in the jump list (like browser Back button)
  Ctrl+I = jump FORWARD in the jump list (like browser Forward button)
```

### Visual Metaphor: The Breadcrumb Trail

```
  Position 1: line 12, analyzing a type definition
       ↓ you jumped to its implementation (big jump)
  Position 2: line 47, reading the implementation
       ↓ you jumped to where it's called (searched and jumped)
  Position 3: line 89, reading the call site
       ↓ you jumped to a helper function it uses
  Position 4: line 134, reading the helper
  [cursor is here now]

  Press Ctrl+O → back to line 89
  Press Ctrl+O → back to line 47
  Press Ctrl+O → back to line 12
  Press Ctrl+I → forward to line 47 again
```

This is critical for "go to definition → read → come back" workflows, which happen constantly when exploring codebases.

### Viewing the Jump List

```
  :jumps  = show the complete jump list with line numbers and file names
```

Output looks like:

```
  jump line  col file/text
     4    1    0  ~/project/utils.ts
     3   12    4  const result = ...
     2   47    0  function calculate(
     1   89   12  return helper(
  >  0  134    8  const temp = ...   ← current position
```

### Two Apostrophes — `''`

```
  ''  = jump to the position BEFORE your last big jump
  `.  = jump to the location of your last CHANGE (extremely useful)
```

``.` (backtick + period) deserves special mention. After any edit, ``.` takes you back to exactly where you made that edit. You can jump around exploring code, and ``.` instantly returns you to where you were working. It is like having a "return to workplace" button.

### VSCode Equivalent

```
  VSCode: Alt+Left  = Ctrl+O in Neovim  (jump back)
  VSCode: Alt+Right = Ctrl+I in Neovim  (jump forward)
```

VSCode also has jump history, but it includes every cursor movement — even small ones — making it noisier. Neovim's jump list only records significant jumps, so `Ctrl+O` takes you to truly different locations, not just "one line up from where you were."

---

## 8. Marks — Personal Bookmarks

Marks are persistent cursor positions you set manually. Think of them as named bookmarks that do not require a special menu or sidebar.

### Setting and Jumping to Marks

```
  m{a-z}  = set a LOCAL mark named with a letter
              (local = only for the current file)
  m{A-Z}  = set a GLOBAL mark named with a capital letter
              (global = works across ANY file, persists between sessions)
```

To jump to a mark:

```
  `{letter}  = jump to EXACT position of mark (row + column)
  '{letter}  = jump to LINE of mark (column resets to first non-blank)
```

The difference between backtick and apostrophe:

```
  m a   ← set mark 'a' at line 47, column 12
  ...navigate around...
  `a    ← jumps to line 47, column 12 (exact position)
  'a    ← jumps to line 47, column 0 (first non-blank)
```

Use backtick when you need to return to a specific character. Use apostrophe when the line is what matters.

### Global Marks (Capital Letters)

Capital letter marks work across files:

```
  mA  ← set global mark 'A' in file utils.ts, line 50
  ...open a different file...
  `A  ← jumps back to utils.ts, line 50, column N
```

This is like a cross-file teleporter. Set `mM` on your main entry point, `mT` on your test file, `mU` on a utility you keep revisiting, and you can hop between them with two keystrokes.

### Viewing All Marks

```
  :marks       = list all marks (local and global)
  :marks aAbB  = list specific marks
```

Output:

```
  mark line  col file/text
   '    12    0  last jump
   "    47    0  last edit
   [     1    0  start of last change
   ]     8    0  end of last change
   ^    15    4  last insert position
   a    23    8  const result = calculateTotal
   A    50    0  ~/project/utils.ts
```

The special marks `'` `"` `[` `]` `^` are set automatically by Neovim — you do not need to set them manually.

### VSCode Comparison

VSCode has a Bookmarks extension that does something similar, but it requires installing a plugin, uses a sidebar panel, and does not have the local/global distinction. In Neovim, marks are first-class citizens built into the editor with no extensions needed.

---

## 9. Scroll Commands

Sometimes you want to move the viewport without necessarily jumping the cursor to a distant location. Scroll commands handle this.

### Half-Page Scrolling

```
  Ctrl+D  = scroll DOWN half a page (this config: cursor centered after)
  Ctrl+U  = scroll UP half a page (this config: cursor centered after)
```

Your config remaps these to `Ctrl+D zz` and `Ctrl+U zz`, meaning after each half-page scroll, your cursor is automatically centered on screen. This prevents the disorientation of ending up with your cursor near the top or bottom of the viewport after scrolling.

Standard Vim behavior would leave the cursor wherever it lands after scrolling. With the `zz` addition, you always know where to look: the middle of your screen.

### Line-by-Line Scrolling

```
  Ctrl+E  = scroll viewport DOWN one line (cursor does NOT move)
  Ctrl+Y  = scroll viewport UP one line (cursor does NOT move)
```

These scroll the view without moving the cursor. Use them when you want to peek at code just below/above the visible area while keeping your cursor on the current line. Useful for consulting code below your current position without losing your place.

### Cursor-to-Screen Position

```
  zz  = center the current line vertically on screen
  zt  = move current line to the TOP of the screen
  zb  = move current line to the BOTTOM of the screen
```

Visualize `zz`, `zt`, `zb`:

```
  SCREEN BEFORE zt:         SCREEN AFTER zt:
  ┌─────────────────┐       ┌─────────────────┐
  │ line 40         │       │ █ line 47 (cur) │  ← now at top
  │ line 41         │       │ line 48         │
  │ ...             │       │ line 49         │
  │ █ line 47 (cur) │  →    │ line 50         │
  │ ...             │       │ ...             │
  │ line 55         │       │                 │
  └─────────────────┘       └─────────────────┘

  AFTER zb:                 AFTER zz:
  ┌─────────────────┐       ┌─────────────────┐
  │ line 39         │       │ line 44         │
  │ line 40         │       │ line 45         │
  │ ...             │       │ line 46         │
  │ line 46         │       │ █ line 47 (cur) │  ← centered
  │ █ line 47 (cur) │       │ line 48         │
  └─────────────────┘       │ line 49         │
      ↑ at bottom           └─────────────────┘
```

`zz` is the most used of these three. After jumping to a match with `/` or a mark, pressing `zz` centers the code you are reading, so you can see context both above and below.

Your config already does this automatically for `Ctrl+D` and `Ctrl+U`, and `n`/`N` in search also center — but `zz` is still useful after other jumps.

### VSCode Comparison

```
  VSCode: Ctrl+Up   = Ctrl+Y in Neovim (scroll up one line)
  VSCode: Ctrl+Down = Ctrl+E in Neovim (scroll down one line)
```

VSCode does not have a direct equivalent of `zz`, `zt`, `zb`. The closest is "Reveal Active Editor" which shows the current line, but it is not as granular.

---

## 10. Search as Motion

Searching in Vim is not just for finding text — it is a primary navigation tool.

### Forward and Backward Search

```
  /pattern  = search FORWARD for pattern, press Enter to confirm
  ?pattern  = search BACKWARD for pattern, press Enter to confirm
  n         = jump to NEXT match (this config: cursor centered)
  N         = jump to PREVIOUS match (this config: cursor centered)
```

After you type `/function` and press Enter, every instance of "function" in the file is highlighted and `n` cycles through them. Your config maps `n` to `nzzzv` and `N` to `Nzzzv`, which centers the screen and keeps the cursor stable after each jump.

```
  nzzzv breakdown:
    n      = jump to next match
    zz     = center the screen on cursor
    zv     = open any folds that hide the match
```

So in your config, `n` = "go to next match, center it, ensure it's visible through folds." Much better than stock Vim's `n` which can strand you near the screen edge.

### Word Under Cursor Search

```
  *  = search FORWARD for the exact word under cursor
  #  = search BACKWARD for the exact word under cursor
```

Place your cursor on any variable name, press `*`, and every occurrence in the file is highlighted. Press `n` to cycle through them. This is instant "find all references" without leaving normal mode. For quick rename verification or just counting how many times a variable appears, `*` + `n` is unbeatable.

`*` searches for the **exact** word — `*` on `foo` will NOT match `foobar`. The search is wrapped in word boundaries automatically.

### Go to Local Definition

```
  gd  = go to the local definition of the word under cursor
  gD  = go to the global definition
```

`gd` is like a lightweight LSP "go to definition" that works without any LSP. It searches backwards in the current file for the first occurrence of the word (which is usually where it is defined). Not as smart as LSP-powered `gd`, but fast and always available.

### Search Case Sensitivity

By default, searches respect case:

```
  /Foo  = matches "Foo" but NOT "foo" or "FOO"
  /\cfoo = case-INSENSITIVE match (the \c makes it case-insensitive)
  /\Cfoo = force case-SENSITIVE match
```

Most configs (including yours, likely) set `ignorecase` + `smartcase`:
- If your pattern is all lowercase, the search is case-insensitive
- If your pattern contains any uppercase, it becomes case-sensitive

So `/foo` matches `foo`, `Foo`, `FOO`, but `/Foo` matches only `Foo`.

### Clear Search Highlighting

After a search, all matches stay highlighted. To clear:

```
  :noh   = clear search highlighting (short for :nohlsearch)
  Esc    = in your config, Esc in normal mode clears highlights
            (many configs map this)
```

### VSCode Comparison

```
  VSCode: Ctrl+F           = /  in Neovim
  VSCode: F3 / Shift+F3    = n / N in Neovim
  VSCode: Ctrl+F, then typing = / in Neovim (but requires Enter in VSCode)
```

The key difference: in VSCode, `Ctrl+F` opens a search dialog that obscures code and requires you to leave "editing mode." In Neovim, `/` is part of normal mode navigation — no dialog, no mode switch, no Enter to confirm after picking a match.

---

## 11. The % Jump

One of Vim's most useful single-key commands:

```
  %  = jump to the MATCHING bracket, paren, or brace
```

Place your cursor on any of these characters:

```
  ( ) { } [ ]
```

Press `%` and you jump to its partner.

```
  function doThing() {
  ^                  ^
  Place cursor here  Press % → cursor jumps here
  (or vice versa)
```

Even with deeply nested code:

```
  if (foo && (bar || (baz > 0))) {
  ^                             ^
  cursor on outer (             % jumps to matching )
```

For HTML and JSX, `%` can match tags if you have the right plugin (matchit or similar), jumping between `<div>` and `</div>`.

### Practical Uses

1. **Verify bracket matching**: press `%` on an opening brace, see if it lands where you expect. Mismatched brackets become obvious.
2. **Select a whole block**: `V%` = visually select from current line to matching brace (useful for copying/deleting a whole function body).
3. **Navigate function start to end**: place cursor on `{` of a function, `%` jumps to `}`. Press `%` again to go back.
4. **In operator combinations**: `d%` = delete from cursor to matching bracket (deletes the whole block content including delimiters).

---

## 12. Complete Motion Reference Table

Here is every motion covered in this tutorial, organized for quick reference:

### Character Motions

| Motion | Description |
|--------|-------------|
| `h` | Left one character |
| `j` | Down one line |
| `k` | Up one line |
| `l` | Right one character |
| `{N}h/j/k/l` | Move N times in that direction |

### Word Motions

| Motion | Description |
|--------|-------------|
| `w` | Next word start (stops at punctuation) |
| `W` | Next WORD start (stops at whitespace) |
| `b` | Previous word start |
| `B` | Previous WORD start |
| `e` | Word end (forward) |
| `E` | WORD end (forward) |
| `ge` | Word end (backward) |
| `gE` | WORD end (backward) |

### Line Motions

| Motion | Description |
|--------|-------------|
| `0` | Column 1 (absolute) |
| `^` | First non-blank character |
| `$` | End of line |
| `g_` | Last non-blank character |
| `f{c}` | Find character `c` forward on line |
| `F{c}` | Find character `c` backward on line |
| `t{c}` | Till character `c` forward (stops before) |
| `T{c}` | Till character `c` backward (stops after) |
| `;` | Repeat last f/F/t/T forward |
| `,` | Repeat last f/F/t/T backward |

### File Motions

| Motion | Description |
|--------|-------------|
| `gg` | Go to first line of file |
| `G` | Go to last line of file |
| `{N}G` | Go to line N |
| `{N}%` | Go to N percent through file |
| `H` | Jump to top of screen |
| `M` | Jump to middle of screen |
| `L` | Jump to bottom of screen |

### Paragraph/Block Motions

| Motion | Description |
|--------|-------------|
| `{` | Previous blank line (paragraph up) |
| `}` | Next blank line (paragraph down) |
| `(` | Previous sentence |
| `)` | Next sentence |
| `[[` | Previous function/section start |
| `]]` | Next function/section start |
| `[{` | Opening brace of current block |
| `]}` | Closing brace of current block |
| `[(` | Opening paren of current expression |
| `])` | Closing paren of current expression |
| `%` | Jump to matching bracket/paren/brace |

### Flash.nvim (This Config)

| Key | Description |
|-----|-------------|
| `s` | Flash jump: type chars, pick label, teleport |
| `S` | Flash treesitter: jump to AST node |
| `r` | Remote flash (operator mode): operate at distance |
| `R` | Treesitter search (operator/visual mode) |

### Jump List

| Key | Description |
|-----|-------------|
| `Ctrl+O` | Jump back in history |
| `Ctrl+I` | Jump forward in history |
| `''` | Jump to position before last big jump |
| `` `. `` | Jump to last edit location |
| `:jumps` | Show jump list |

### Marks

| Key | Description |
|-----|-------------|
| `m{a-z}` | Set local mark |
| `m{A-Z}` | Set global mark (cross-file, persistent) |
| `` `{letter} `` | Jump to exact position of mark |
| `'{letter}` | Jump to line of mark |
| `:marks` | List all marks |

### Scroll

| Key | Description |
|-----|-------------|
| `Ctrl+D` | Scroll down half page (+ center, this config) |
| `Ctrl+U` | Scroll up half page (+ center, this config) |
| `Ctrl+E` | Scroll down one line (cursor stays) |
| `Ctrl+Y` | Scroll up one line (cursor stays) |
| `zz` | Center current line on screen |
| `zt` | Current line to top of screen |
| `zb` | Current line to bottom of screen |

### Search

| Key | Description |
|-----|-------------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next match (+ center, this config) |
| `N` | Previous match (+ center, this config) |
| `*` | Search word under cursor forward |
| `#` | Search word under cursor backward |
| `gd` | Go to local definition |
| `gD` | Go to global definition |

---

## 13. Motion Combos — Putting It Together

Motions become exponentially useful when you chain them and combine them with operators (covered in the next tutorial). Here are some natural motion sequences you will use constantly.

### Combo 1: Navigate to a Specific Function

```
  gg          = go to top of file
  /function   = search forward for "function"
  n           = next match (centered on screen)
  n           = next match
  n           = now you are at the third "function" in the file
```

Or with Flash:

```
  s           = activate flash
  fu          = type first two chars of "function"
  [label]     = type the label next to the function you want
```

Flash wins for visible destinations; `/` wins for finding the Nth occurrence of something.

### Combo 2: Navigate to a TODO Comment

```
  gg          = start of file
  /TODO       = find first TODO
  n           = next TODO
  n           = next TODO
```

Or to jump to all TODOs:

```
  /TODO<Enter>  = start search
  n n n n       = hop through every TODO in the file
```

### Combo 3: Move Down, Then Navigate Within a Line

```
  3j          = move down 3 lines (using relative line numbers)
  f(          = find the opening paren on this line
  %           = jump to matching closing paren
```

### Combo 4: Jump Between Related Functions

```
  mA          = mark current location as global mark 'A'
  /handleSubmit<Enter>  = find the handler
  n           = jump to it
  mB          = mark this location as 'B'
  `A          = jump back to original location
  `B          = jump to handleSubmit
```

Once you have marks set, `A` and `B` become a "fast travel" between two distant points.

### Combo 5: Explore a Codebase

```
  gd          = go to definition of word under cursor
  Ctrl+O      = come back to where you were
  *           = highlight all occurrences of current word
  n n n       = visit each occurrence
  Ctrl+O      = return to original position
```

This three-step pattern — `gd` to see definition, `Ctrl+O` to come back, `*` to find all usages — is how you explore unfamiliar code without losing your place.

### Combo 6: Paragraph-Level Navigation

```
  }           = jump to end of current paragraph/function
  }           = next paragraph
  }           = next paragraph
  {           = go back one paragraph
```

For quick scanning of a file's structure without reading line-by-line.

### Combo 7: Screen-Relative Jumps

```
  H           = jump to top of screen
  M           = jump to middle of screen
  L           = jump to bottom of screen
  Ctrl+D      = scroll down, now new content visible
  H           = jump to top of new content
```

`H`, `M`, `L` make you think about the screen as a viewport you can target, not just a window of your file. Combined with `Ctrl+D`/`Ctrl+U`, you can scan large files by "page" while landing precisely.

### Combo 8: Search + f Combination

Sometimes the character you want is past a unique sequence on the same line:

```
  /console.log    = jump to a console.log line
  f(              = find the opening paren
  a               = enter insert mode after cursor (append)
  ```

Now you are positioned to type inside the console.log call. This `/` + `f` combination is very natural once you get used to it.

---

## 14. Exercises

These exercises are designed to build muscle memory. Do not rush. Do each one five times minimum before moving on.

### Exercise 1: Relative Line Numbers Dance

**Goal**: Get comfortable with count-prefix `j`/`k` and relative line numbers.

1. Open any file with 100+ lines
2. Move to line 50 with `50G`
3. Look at the relative line numbers on screen
4. Jump to the line that shows `7` on the left: type `7k` (if above) or `7j` (if below)
5. Then jump 4 down, 3 up, 6 down, 2 up — using ONLY relative line numbers
6. Never use the arrow keys during this exercise

**What you are building**: The habit of reading relative numbers and immediately translating them to `Nj`/`Nk`.

### Exercise 2: The f/t/;/, Drill

**Goal**: Navigate a line without leaving it.

Open a line of code that looks something like this (copy it into a scratch buffer if needed):

```
const result = someObject.getSomething(arg1, arg2).transform();
```

1. Place cursor at the start (`0`)
2. Use `f.` to jump to the first `.`
3. Press `;` to jump to the next `.`
4. Press `;` again to jump to the third `.`
5. Press `,` to go back to the second `.`
6. Now use `f(` to find the opening paren
7. Use `t,` to go "till" the first comma
8. Press `;` to repeat till the next comma
9. Use `F.` (capital F) to go backward to a `.`

**What you are building**: Fluency with line-level navigation. This replaces a lot of `h`/`l` pressing.

### Exercise 3: Flash.nvim Sprint

**Goal**: Start using `s` instead of counting lines.

1. Open a file with 50+ lines visible on screen
2. Pick 10 targets on screen at random (variable names, keywords, symbols)
3. For each target: press `s`, type the first 2 chars of the target, type the label
4. Do NOT use `j`/`k` to reach any of these targets

**What you are building**: The Flash reflex. Your eyes see something, your fingers type `s` + two chars before your brain has finished thinking about it.

Do this exercise every time you open Neovim for the next three days. It takes about 90 seconds and pays off enormously.

### Exercise 4: The Jump List Exploration

**Goal**: Learn to use `Ctrl+O`/`Ctrl+I` for navigation.

1. Open a medium-sized file (100-300 lines)
2. Use `/` to search for a function name, navigate to it with `n`
3. Use `gd` to jump to its definition
4. Use `*` to find all occurrences, press `n` to visit a couple
5. Now press `Ctrl+O` repeatedly — watch where you end up
6. Press `Ctrl+I` to go forward again
7. Run `:jumps` to see your history

**What you are building**: Confidence in non-linear navigation. You should feel safe going "down the rabbit hole" because you know `Ctrl+O` will always bring you back.

### Exercise 5: Marks Across a Codebase

**Goal**: Set up fast travel between two files.

1. Open a project with at least 2 related files (e.g., a component and its test file)
2. In the component file, on a function you want to remember: press `mA`
3. Open the test file (`:e testfile.ts` or use your file picker)
4. On the corresponding test function: press `mB`
5. Navigate around the test file for a minute
6. Press `` `A `` — you should teleport back to the component file at the exact marked position
7. Make some edits, then press `` `B `` — back to the test
8. Practice this `` `A `` / `` `B `` loop 10 times until it feels natural

**What you are building**: The marks habit. Once you start using capital marks for "current working context", your cross-file navigation becomes dramatically faster. Many Vim users maintain a personal convention: `mA` = main file, `mT` = tests, `mC` = config, `mS` = server entry — and they set these marks at the start of each session.

---

> **Next Up**: [04 · Editing Mastery](./04-editing-mastery.md) — Learn the Vim editing language: operators, text objects, surround, yank ring, multicursor, macros, and everything you need to actually *change* code at the speed of thought.

---

*Part of the "Neovim 0 to Hero" series.*
