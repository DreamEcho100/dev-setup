# 04 · Editing Mastery

> "VSCode gives you a palette of brushes. Vim gives you a language."

---

## Table of Contents

1. [The Vim Language — The Big Idea](#1-the-vim-language--the-big-idea)
2. [Operators — The Verbs](#2-operators--the-verbs)
3. [Text Objects — The Nouns](#3-text-objects--the-nouns)
4. [mini.surround — Wrap Everything](#4-minisurround--wrap-everything)
5. [The Yank Ring — yanky.nvim](#5-the-yank-ring--yankynvim)
6. [Registers Deep Dive](#6-registers-deep-dive)
7. [Visual Mode Deep Dive](#7-visual-mode-deep-dive)
8. [Dot Repeat — The Power Tool](#8-dot-repeat--the-power-tool)
9. [Macros — Automated Editing](#9-macros--automated-editing)
10. [Multicursor — multicursor.nvim](#10-multicursor--multicursornvim)
11. [Comments — comment.nvim](#11-comments--commentnvim)
12. [mini.splitjoin — Join and Split Arguments](#12-minisplitjoin--join-and-split-arguments)
13. [Moving Lines in Visual Mode](#13-moving-lines-in-visual-mode)
14. [Indent Management](#14-indent-management)
15. [Complete Editing Reference Table](#15-complete-editing-reference-table)
16. [Putting It All Together — Real Scenarios](#16-putting-it-all-together--real-scenarios)
17. [Exercises](#17-exercises)

---

## 1. The Vim Language — The Big Idea

Before we dive into specific keys, you need to understand *why* Vim editing feels so different from every other editor. It is not just that Vim has more shortcuts. It is that Vim editing is a **composable language**.

In VSCode, editing is a fixed menu of commands:

```
  VSCode shortcut model:
  ┌─────────────────────────────────────────────────┐
  │  Ctrl+D      = select next occurrence of word   │
  │  Ctrl+X      = cut line                         │
  │  Alt+Up      = move line up                     │
  │  Ctrl+Shift+K = delete line                     │
  │  Ctrl+]      = indent                           │
  │  ... (200+ individual shortcuts to memorize)    │
  └─────────────────────────────────────────────────┘
  Every action is its own unrelated hotkey.
  To do something new, you need a new shortcut.
```

In Vim, editing is a grammar with a tiny vocabulary that generates unlimited combinations:

```
  Vim grammar:

  ┌───────────────────────────────────────────────────────┐
  │                                                       │
  │   [count]   [operator]   [motion or text-object]      │
  │                                                       │
  │      3          d              w       = delete 3 words │
  │                 c              i"      = change inside quotes │
  │                 y              ap      = yank a paragraph │
  │                 >              i{      = indent inside braces │
  │      2          gU             iw      = uppercase 2 words │
  │                 =              ap      = autoindent paragraph │
  │                                                       │
  └───────────────────────────────────────────────────────┘
```

You learn maybe 8 operators. You learn maybe 20 motions and text objects (covered in the previous tutorial and this one). Suddenly you have 8 × 20 = 160 combinations, plus counts, plus nesting. You do not memorize 160 shortcuts — you learn 8 words and 20 words and the grammar combines them automatically.

This is why experienced Vim users say they "think in Vim." When you want to change the inside of a function argument list, you do not think "what is the shortcut for this?" You think: `c` (change) + `i(` (inside parens). The action assembles itself from its parts.

The rest of this tutorial will teach you the vocabulary — operators, text objects, and the plugins that extend them. The grammar you already know: `[count] [operator] [motion/object]`.

---

## 2. Operators — The Verbs

Operators are things you *do* to text. They always require a motion or text object to define what they act on. Most operators also work in visual mode, where the selection defines the target.

### Core Operators

```
  d   = delete     (text goes to register, can be pasted)
  c   = change     (delete + enter Insert mode)
  y   = yank       (copy to register, no deletion)
  v   = visual     (start visual selection, then apply operator)
  ~   = toggle case (single character)
  g~  = toggle case (with motion)
  gu  = lowercase  (with motion)
  gU  = uppercase  (with motion)
  =   = auto-indent
  <   = dedent (shift left)
  >   = indent (shift right) — stays in visual in this config
  !   = filter through external program
```

### Doubling an Operator Acts on the Current Line

Every operator, when pressed twice, acts on the **entire current line**:

```
  dd  = delete the entire current line
  cc  = change the entire current line (clear + insert mode)
  yy  = yank (copy) the entire current line
  ==  = auto-indent the current line
  >>  = indent the current line right
  <<  = dedent the current line left
  gUU = uppercase the entire current line (also gUgU)
  guu = lowercase the entire current line (also gugu)
```

### Operator Examples

Here is a concrete example for each operator with a motion:

```
  Operation     Result
  ──────────────────────────────────────────────────────
  dw            delete from cursor to end of next word
  d3w           delete 3 words forward
  diw           delete the word under cursor (inner word)
  daw           delete word + surrounding space
  di"           delete contents of quoted string
  da"           delete quoted string including quotes
  d$            delete to end of line
  D             (shortcut for d$) delete to end of line
  dt;           delete till semicolon
  d/foo<Enter>  delete from cursor to next "foo"

  cw            change word (delete + Insert mode)
  ci(           change inside parens (clear contents, insert)
  C             (shortcut for c$) change to end of line
  ct,           change till comma

  yiw           yank (copy) word under cursor
  y$            yank to end of line
  Y             (shortcut for y$) yank to end of line
  yap           yank around paragraph

  gUiw          uppercase the word under cursor
  guiw          lowercase the word under cursor
  g~iw          toggle case of word under cursor

  >ip           indent inner paragraph
  =ip           auto-indent inner paragraph
  <iB           dedent inside braces
```

### The Difference Between d and c

`d` deletes and leaves you in Normal mode. `c` deletes and immediately enters Insert mode so you can type a replacement. They use the same syntax:

```
  diw  = delete inner word (stay in Normal mode)
  ciw  = change inner word (delete it + enter Insert mode to type replacement)
```

`c` is "delete and replace immediately." Use `c` when you know you are about to type something new. Use `d` when you are just removing text.

### The ! Filter Operator

`!{motion}` filters the selected text through an external shell command:

```
  !ip    = filter inner paragraph through a command
           Vim prompts you for the command.
           Type: sort     → sorts the lines alphabetically
           Type: uniq     → removes duplicate lines
           Type: jq .     → formats JSON
           Type: prettier --stdin-filepath x.ts → format TypeScript
```

This is a powerful escape hatch — you can run any Unix command on a selection of text without leaving the editor. Rarely needed day-to-day but extremely useful when you need it.

---

## 3. Text Objects — The Nouns

Text objects are Vim's secret weapon. They define *what* an operator acts on — not just "from here to there" (a motion), but "this semantic unit of text" regardless of where the cursor is inside it.

### Inner vs Around (i vs a)

Every text object comes in two flavors:

```
  i = "inner" — the content, NOT including the delimiters
  a = "around" — the content PLUS the delimiters (and often surrounding space)
```

Visual example on the string `"hello world"`:

```
  "hello world"
   ^^^^^^^^^^^    ← i" (inner double-quote: just the content)
  ^^^^^^^^^^^^^   ← a" (around double-quote: content + the quotes themselves)
```

And on the word `hello` in `  hello world`:

```
    hello world
    ^^^^^         ← iw (inner word: just "hello")
    ^^^^^^        ← aw (around word: "hello" + trailing space)
```

The `a` variants are useful for deletion (you do not want to leave dangling spaces/delimiters). The `i` variants are useful for replacement (you want to replace the content but keep the delimiters).

### Word and WORD Objects

```
  iw  = inner word (just the word, no surrounding whitespace)
  aw  = around word (word + one space: great for deletion)
  iW  = inner WORD (whitespace-delimited, includes punctuation)
  aW  = around WORD + surrounding space
```

```
  Example: const foo_bar.baz = value;
                 ───────
                   iW           (foo_bar.baz as one unit)
```

### Sentence and Paragraph Objects

```
  is  = inner sentence
  as  = around sentence (sentence + trailing space)
  ip  = inner paragraph (text between blank lines)
  ap  = around paragraph (paragraph + surrounding blank lines)
```

These are most useful for prose/comment blocks. `dap` deletes a whole paragraph including its surrounding blank lines — the paragraph disappears cleanly without leaving extra blank lines.

### Bracket and Delimiter Objects

```
  i(  or  ib  = inner parens
  a(  or  ab  = around parens (includes the parens themselves)
  i{  or  iB  = inner braces
  a{  or  aB  = around braces
  i[         = inner square brackets
  a[         = around square brackets
  i<         = inner angle brackets
  a<         = around angle brackets
  i"         = inner double quotes
  a"         = around double quotes
  i'         = inner single quotes
  a'         = around single quotes
  i`         = inner backticks
  a`         = around backticks
  it         = inner HTML/JSX tag
  at         = around HTML/JSX tag (includes opening and closing tags)
```

### Visualizing Bracket Objects

```
  function calculate(arg1, arg2) {
                    ^          ^
                    i( spans this region (just the args: "arg1, arg2")
                   ^            ^
                   a( spans this region (args + the parens themselves)
```

```
  const obj = {
    foo: 1,
    bar: 2,
  };
               ^─────────^
               iB spans this region (foo:1, bar:2, and the newlines)
              ^─────────────^
              aB spans this region (including the { and })
```

### Tag Objects — it and at

For HTML and JSX:

```
  <div className="foo">
    <p>Hello world</p>
  </div>
```

With cursor anywhere inside the `<div>`:

```
  it  = inner tag = "  <p>Hello world</p>\n"
  at  = around tag = the whole thing including <div> and </div>
```

`cit` = change inside tag. This is how you quickly replace the contents of a JSX component: move cursor inside it, `cit`, type new content. Done.

### mini.ai Extensions — Next/Last Objects

Your config includes `mini.ai` which extends text objects with `in` (next) and `il` (last):

```
  cin(  = change inside NEXT parens
           (cursor does NOT need to be inside the parens already)
  yin"  = yank inside NEXT double quotes
  dil"  = delete inside LAST (previous) double quotes
```

This is enormous. Without `mini.ai`, text objects only work when the cursor is already inside the delimiter. With `mini.ai`, you can target the *nearest* delimiter in either direction. Very useful when your cursor is between two quoted strings and you want to change the one to the right without moving there first.

```
  const a = "first string", b = "second string";
                                  ^
                    cursor here---┘

  Without mini.ai: you need to move left into "first string" to use i"
  With mini.ai:    dil" deletes "first string" (last/previous quotes)
                   din" deletes "second string" (next quotes)
```

---

## 4. mini.surround — Wrap Everything

mini.surround adds operations for the *surroundings* of text — the quotes, parens, braces, brackets, and HTML tags that wrap expressions.

### The mini.surround Keys (This Config)

```
  sa  = surround ADD (add surroundings around a motion/text object)
  ds  = surround DELETE (remove surroundings)
  cs  = surround CHANGE/REPLACE (swap one surrounding for another)
  sf  = surround FIND right (find surrounding to the right)
  sF  = surround FIND left (find surrounding to the left)
  sh  = surround HIGHLIGHT (visually highlight the surrounding)
  sn  = surround update N_LINES (adjust search range)
```

### Adding Surroundings — `sa`

`sa` = surround add. It takes a motion/text object, then a character to wrap with:

```
  sa{motion}{surrounding}

  saaw"    = surround around-word with double quotes
  saiw(    = surround inner-word with parens
  saip{    = surround inner-paragraph with braces
  sa3w"    = surround 3 words with double quotes
```

Step by step, `saaw"` on the word `hello`:

```
  Before:  hello
  saaw = "surround add around word"
  then press " as the surrounding character
  After:   "hello"
```

And `saiw(` on the word `result`:

```
  Before:  return result;
                  ^^^^^^  ← cursor inside 'result'
  saiw = "surround add inner word"
  then press ( as the surrounding character
  After:   return (result);
```

For block-level wrapping:

```
  saip{    = wrap inner paragraph in curly braces
  Before:
    const x = 1;
    const y = 2;
    return x + y;

  After:
    {
    const x = 1;
    const y = 2;
    return x + y;
    }
```

### Deleting Surroundings — `ds`

`ds` = surround delete. Just specify what to remove:

```
  ds"    = delete surrounding double quotes
  ds'    = delete surrounding single quotes
  ds(    = delete surrounding parens
  ds{    = delete surrounding braces
  dst    = delete surrounding HTML/JSX tag
  ds`    = delete surrounding backticks
```

Example:

```
  Before:  "hello world"
  ds"
  After:   hello world
```

```
  Before:  (arg1, arg2)
  ds(
  After:   arg1, arg2
```

### Changing/Replacing Surroundings — `cs`

`cs` = surround change. Specify what to remove and what to replace it with:

```
  cs{old}{new}

  cs"'     = change double quotes to single quotes
  cs'"     = change single quotes to double quotes
  cs({     = change parens to braces
  cs)"     = change ) to double quotes (removes parens, adds quotes)
  cst<p>   = change surrounding HTML tag to <p>
```

Example, converting quote style:

```
  Before:  const msg = "hello world";
  cs"'
  After:   const msg = 'hello world';
```

Replacing parens with braces:

```
  Before:  function foo(arg1, arg2)
  cs({
  After:   function foo{arg1, arg2}
```

### Finding Surroundings — `sf` and `sF`

Sometimes you want to navigate to a surrounding without changing it:

```
  sf"    = move cursor to the NEXT " surrounding (right side)
  sF"    = move cursor to the PREVIOUS " surrounding (left side)
```

### VSCode Equivalent

The closest VSCode has is:
- Emmet's "Wrap with Abbreviation" (`Ctrl+Shift+P` → search "Emmet: Wrap") — but only works for HTML/JSX
- The Vim extension's `ys`/`ds`/`cs` commands if you are using vim-surround

mini.surround is more consistent and works for any delimiter, not just markup.

---

## 5. The Yank Ring — yanky.nvim

In most editors, "clipboard" means a single slot: copy replaces whatever was there. If you copy three things in a row, you can only paste the last one.

yanky.nvim gives you a **yank ring** — a persistent history of everything you have yanked, so you can reach back and paste something from 5 copies ago.

### Basic Yank and Put

```
  y{motion}  = yank (copy) the motion target into the yank ring
  yy         = yank current line
  p          = put (paste) AFTER cursor
  P          = put (paste) BEFORE cursor
```

These work the same as stock Vim but all yanks are stored in the ring.

### Yank Ring — Cycling Through History

```
  [y   = cycle yank ring FORWARD (access older yanks — further back in history)
  ]y   = cycle yank ring BACKWARD (more recent yanks)
```

Workflow: you copy `alpha`, then `beta`, then `gamma`. Now you paste `gamma` with `p`. But you actually wanted `alpha`. Press `[y` twice to cycle back to `alpha`. The pasted text updates in place.

```
  Steps:
  1. yiw on "alpha"   → ring: [alpha]
  2. yiw on "beta"    → ring: [beta, alpha]
  3. yiw on "gamma"   → ring: [gamma, beta, alpha]
  4. p                → pastes "gamma"
  5. [y               → replaces paste with "beta"
  6. [y               → replaces paste with "alpha"  ✓
```

### Enhanced Put Commands

```
  gp    = put after cursor, but move cursor AFTER the pasted text
           (useful when you want to keep pasting more things)
  gP    = put before cursor, cursor moves after pasted text
  [p    = put with auto-indent adjustment (indentation adapts to current context)
  ]p    = put below with auto-indent
  >p    = put and indent right
  <p    = put and indent left
  =p    = put and apply = auto-format
  =P    = put before and apply = auto-format
```

`[p` and `]p` are particularly useful when pasting code from one context into another with different indentation levels — the text adjusts automatically.

### Yank History Picker

```
  <leader>y  = open yank history picker (Telescope/fzf UI)
```

This opens a full searchable list of everything in your yank ring. You can scroll through your clipboard history and pick any previously yanked text to insert. This is killer for workflows where you copy multiple things and need to combine them.

### VSCode Comparison

VSCode does not have a yank ring by default. There are clipboard manager extensions, but they are not integrated with the editor's paste mechanism. With yanky.nvim, cycling through paste history is built into the editing flow — no extra UI, no dialogs.

---

## 6. Registers Deep Dive

Registers are Vim's named clipboard slots. Most motions silently use them; understanding them consciously lets you be deliberate about what you copy and paste.

### Key Registers

```
  ""        = unnamed register (default destination for d, c, s, x, y)
  "a - "z   = named registers (manually set)
  "A - "Z   = named registers, APPEND mode (capital letter appends to register)
  "0        = yank register (stores the LAST YANK only — not affected by delete)
  "_        = black hole register (write here to discard, like /dev/null)
  "+        = system clipboard (syncs with OS clipboard)
  "*        = selection clipboard (X11 primary selection on Linux)
  "/        = last search pattern register
  ":        = last command-line command
  ".        = last inserted text
  "%        = current filename
  "#        = alternate filename
```

### The Critical Difference: "0 vs ""

This trips up Vim beginners constantly:

```
  Scenario:
  1. You yank (y) a function name: "myFunction"
  2. You delete (d) a different line — now "" contains that deleted line
  3. You try to paste — you get the DELETED LINE, not "myFunction"!
```

The unnamed register `""` is overwritten by BOTH yank and delete operations. This means deleting something "erases" what you just copied.

The yank register `"0` is **only written by explicit yank operations** (y). Delete operations do not touch it.

Solution: after yanking something you want to paste multiple times:

```
  "0p   = paste from the yank register (not the unnamed register)
```

Or use a named register:

```
  "ayiw   = yank inner word into register 'a'
  ...do some editing (including deletes)...
  "ap     = paste from register 'a' (untouched by the deletes)
```

### The Black Hole Register — "_

Your config maps `x` (delete character) to `"_x` — it sends the deleted character to the black hole register, so single character deletions do not pollute your clipboard.

You can use `"_` manually for any operation you want to discard:

```
  "_dd   = delete line, don't put it in any register
  "_ciw  = change word, deleted text goes nowhere
  "_dip  = delete paragraph into the void
```

Use this when you are deleting something you know you will never need to paste.

### Viewing Register Contents

```
  :registers      = list all registers and their contents
  :registers abc  = list registers a, b, c
```

Output:

```
  Type Name Content
   l   ""   hello world
   l   "0   myFunction
   l   "a   const result = calculateTotal(items);
   c   ":   registers
   c   ".   hello
   c   "%   src/utils.ts
   r   "/   function
```

### Using the System Clipboard

```
  "+y   = yank to system clipboard (accessible from other apps)
  "+p   = paste from system clipboard
  "+yy  = yank whole line to system clipboard
```

Many configs set `clipboard=unnamedplus` to make `""` sync with `"+` automatically. If yours does, you may not need the `"+` prefix. Check with `:set clipboard?`.

---

## 7. Visual Mode Deep Dive

Visual mode lets you select text, see it highlighted, then apply an operator. It is the "first select, then act" alternative to the "act then motion" paradigm.

### Three Flavors of Visual Mode

```
  v        = charwise visual (select character by character)
  V        = linewise visual (select whole lines)
  Ctrl+V   = blockwise / column visual (select a rectangular block)
```

```
  charwise (v):
  ┌──────────────────────────────┐
  │  const foo = bar + baz;     │
  │            ^───────^         │
  │            selected range    │
  └──────────────────────────────┘

  linewise (V):
  ┌──────────────────────────────┐
  │  const foo = bar + baz;     │ ← entire line selected
  │  const qux = foo * 2;       │ ← entire line selected
  └──────────────────────────────┘

  blockwise (Ctrl+V):
  ┌──────────────────────────────┐
  │  const foo = bar + baz;     │
  │         ^^^                  │ ← "foo" column selected
  │  const foo = qux + quux;    │
  │         ^^^                  │ ← "foo" column selected
  └──────────────────────────────┘
```

### Moving to the Other End — `o`

In any visual selection, `o` moves the cursor to the **other end** of the selection. This lets you adjust the selection from either side:

```
  1. Press V to start linewise selection
  2. Press j to extend down 5 lines
  3. Press o — cursor jumps to the TOP of the selection
  4. Now k to shrink from the top
  5. Press o again — back to the bottom
```

This is how you fine-tune a selection after over-shooting.

### Block Select — The Column Editing Superpower

`Ctrl+V` selects a rectangular block, which enables simultaneous editing on multiple lines:

```
  Before: (these three const declarations need 'let' instead)
  const alpha = 1;
  const beta  = 2;
  const gamma = 3;

  1. Put cursor on 'c' of first 'const'
  2. Ctrl+V  = enter block visual
  3. 2j      = extend selection down 2 lines
  4. e       = extend to end of word 'const'

  (all three 'const' words are now highlighted)

  5. c       = change the block
  6. type 'let'
  7. Esc

  After:
  let alpha = 1;
  let beta  = 2;
  let gamma = 3;
```

### Block Insert and Append — I and A in Block Mode

After making a block selection with `Ctrl+V`:

```
  I  = insert at the LEFT side of the block (on every selected line)
  A  = append at the RIGHT side of the block (on every selected line)
```

Use case: adding `//` comments to multiple lines simultaneously:

```
  Before:
  const x = 1;
  const y = 2;
  const z = 3;

  1. Ctrl+V on first line column 1
  2. 2j to extend 2 lines down
  3. I to insert at start
  4. Type "// "
  5. Esc

  After:
  // const x = 1;
  // const y = 2;
  // const z = 3;
```

### VSCode Comparison

```
  VSCode: Alt+Click in multiple places = multiple cursors
  VSCode: Alt+Shift+Click+drag = column selection

  Neovim: Ctrl+V = block/column selection
  Neovim: Ctrl+V → I/A = insert on all lines simultaneously
```

VSCode's column selection is actually similar to `Ctrl+V` in Vim, but Vim's `I`/`A` after block selection is unique in its seamless multi-line insertion.

---

## 8. Dot Repeat — The Power Tool

The `.` key is one of the most powerful commands in Vim. It repeats your **last change** — which means the entire edit you just performed, from the moment you left Normal mode to the moment you returned.

```
  .  = repeat last change
```

### What Counts as One "Change"

A change is everything from entering a mode-changing operation to returning to Normal mode:

```
  ciw + "newName" + Esc   = one change (change word to "newName")
  A + ";" + Esc            = one change (append semicolon to line end)
  dap                      = one change (delete a paragraph)
  saaw"                    = one change (add quotes around word)
  >>                       = one change (indent current line)
```

All of these can be repeated with `.`.

### The Dot Formula

Expert Vim users design their changes to be repeatable. The "dot formula":

1. Make a change that is *general enough* to work at the next occurrence
2. Navigate to the next occurrence (using a motion, not undo)
3. Press `.`

Example: You want to add a semicolon to the end of several lines:

```
  Line 1: const foo = 1     ← cursor here
  Line 2: const bar = 2
  Line 3: const baz = 3
  Line 4: const qux = 4

  A;<Esc>   = append semicolon to current line (this is the "change")
  j.        = go down one line, repeat the change
  j.        = go down, repeat
  j.        = go down, repeat

  Result:
  const foo = 1;
  const bar = 2;
  const baz = 3;
  const qux = 4;
```

### A More Sophisticated Example

Changing double-quoted strings to single-quoted:

```
  Method 1 (naive): manually change each one

  Method 2 (dot formula):
  1. cs"'   = change surrounding " to ' (using mini.surround)
             This is the repeatable change.
  2. Now use * or n to jump to the next " character
  3. .      = repeat the surround change

  Wait — cs"' targets the nearest surrounding.
  A cleaner approach:
  1. /"\w   = search for opening quote of strings
  2. n      = jump to first match
  3. cs"'   = change it
  4. n      = jump to next
  5. .      = repeat
  6. n.n.n. = cycle through remaining occurrences
```

### Dot with Operators

Dot repeats operator+motion+count as a unit:

```
  3dw    = delete 3 words
  .      = delete 3 more words (the count is remembered)
  5j.    = move 5 lines down, delete 3 more words there
```

### When Dot Breaks Down

Dot is powerful but limited — it only remembers one change, not a sequence. For sequences, you need macros (next section). Dot is best for a single, clear, repeatable editing operation.

---

## 9. Macros — Automated Editing

A macro records a sequence of keystrokes and plays them back. Think of it as a very literal "record and replay" feature: every key you press while recording is captured, and then you can replay that exact sequence at any position.

### Recording and Playing Macros

```
  q{letter}  = start recording macro into register {letter}
               (any letter a-z, or even A-Z for appending)
  q          = stop recording (press q again to end)
  @{letter}  = play back macro in register {letter}
  @@         = replay the last macro you ran
  {N}@{letter} = play macro N times
```

### A Complete Macro Walkthrough

Goal: you have 10 lines of function calls that all need to be wrapped in `console.log()`:

```
  Before:
  processPayment(order);
  validateUser(id);
  sendEmail(template, user);
  updateDatabase(record);
  ...
```

Step 1: Record the macro.

```
  Put cursor at start of "processPayment"
  qa               = start recording into register 'a'
  0                = go to start of line (anchor)
  i                = enter Insert mode
  console.log(     = type the prefix
  Esc              = back to Normal
  $                = go to end of line
  a                = append after last char
  )                = type the closing paren
  Esc              = back to Normal
  j                = move down one line (so next replay starts on next line)
  q                = stop recording
```

Step 2: Verify it worked.

```
  After qa...q, line 1 should read:
  console.log(processPayment(order));
  and your cursor should be on line 2.
```

Step 3: Replay 9 more times.

```
  9@a   = play macro 'a' 9 more times
```

Result:

```
  console.log(processPayment(order));
  console.log(validateUser(id));
  console.log(sendEmail(template, user));
  console.log(updateDatabase(record));
  ...
```

### Macro Tips

**Always anchor the macro**: start with `0` or `^` to ensure the macro starts at a consistent position regardless of where the cursor happens to be.

**End with a move**: end your macro with `j` or the next search, so replaying moves to the next target automatically. Then `{N}@a` handles all N occurrences.

**Apply to visual selection**: select lines with `V`, then `:normal @a` runs the macro on every selected line.

```
  V         = start linewise visual
  10j       = select 10 lines
  :normal @a = run macro 'a' on each selected line
```

**Recursive macros** (advanced): clear register first with `qaq` (record nothing), then record a macro that calls itself: `qaYou can 0...@aq`. The macro plays until it hits an error (like reaching the end of the file).

**Edit a macro**: macros are stored in registers. To edit macro 'a':
```
  "ap     = paste the macro contents as text
            (edit the text)
  "ayy    = yank the edited line back into register 'a'
```

### Macros vs Dot Repeat

```
  . (dot)   = repeat ONE change
  macros    = repeat a SEQUENCE of changes

  Use dot when: the task is a single repeatable operation
  Use macros when: the task is a multi-step sequence
```

---

## 10. Multicursor — multicursor.nvim

Your config includes `multicursor.nvim`, which brings VSCode-style multiple cursors to Neovim. It works naturally with all Vim editing commands.

### Adding Cursors

```
  <leader>cm  = add cursor at the NEXT occurrence of the word under cursor
                (like VSCode's Ctrl+D — adds one more cursor at next match)
  <leader>cM  = add cursors at ALL occurrences in the buffer
                (like VSCode's Ctrl+Shift+L — select all matches)
  Esc         = if multicursor is active, Esc clears all extra cursors
                if not in multicursor, Esc = clear search highlight
```

### Typical Workflow: Rename a Variable

You want to rename `oldName` to `newName` in the current file:

```
  1. Place cursor on "oldName" (any occurrence)
  2. <leader>cM           = add cursors at ALL occurrences
  3. All instances of "oldName" are now selected with multiple cursors
  4. ciw                  = change inner word (all cursors act simultaneously)
  5. type "newName"
  6. Esc                  = exit Insert mode (all cursors confirmed)
  7. Esc                  = clear the extra cursors
```

The result: all occurrences replaced in one smooth editing sequence.

### Step-by-Step with <leader>cm (Ctrl+D Equivalent)

If you want to add cursors selectively (not all at once):

```
  1. Place cursor on "oldName" — first occurrence
  2. <leader>cm           = select this one AND add cursor at NEXT occurrence
  3. <leader>cm           = add cursor at the NEXT one too
  4. (skip one you don't want to change: navigate past it)
  5. ciw → "newName" → Esc = change all selected ones
```

This is the Vim equivalent of VSCode's `Ctrl+D` for selective multi-select.

### Multicursor with Other Editing Operations

Multicursor works with any Vim editing command — not just `ciw`:

```
  Add cursors, then:
  A;        = append semicolon to end of every selected line
  O         = add blank line above each cursor position
  ds"       = delete surrounding quotes at each cursor
  gUiw      = uppercase the word at each cursor
  >>        = indent all lines with cursors
```

### VSCode Comparison

```
  VSCode: Ctrl+D           = <leader>cm  (add next occurrence)
  VSCode: Ctrl+Shift+L     = <leader>cM  (add all occurrences)
  VSCode: Alt+Click        = no direct equivalent in this config
                             (but Ctrl+V block mode often covers the use case)
  VSCode: Escape           = Esc         (clear cursors)
```

The key advantage of Neovim's multicursor over VSCode's: every Vim operator and text object works with multicursor naturally. In VSCode, multi-cursor only works with basic typing — you cannot do `ci(` at multiple cursors in VSCode. In Neovim you can.

---

## 11. Comments — comment.nvim

comment.nvim handles line and block comments, and it is aware of the current file's language so it uses the right comment syntax automatically (` // ` for TypeScript, `#` for Python, `--` for SQL, etc.).

### Line Comment Toggle

```
  gcc    = toggle comment on CURRENT LINE
  gc{motion} = toggle comment over motion range
  gcap   = toggle comment on a paragraph
  gc3j   = toggle comment on current line and 3 below
  gcG    = toggle comment from cursor to end of file
  gcgg   = toggle comment from cursor to start of file
```

`gcc` is the workhorse. One press adds a comment; pressing again removes it. The syntax is automatically correct for whatever file you are in.

### Block Comment Toggle

```
  gbc    = toggle BLOCK comment on current line
           (uses /* ... */ style instead of // style, where applicable)
  gb{motion} = toggle block comment over motion range
  gbap   = block comment around a paragraph
```

```
  TypeScript line comment (gcc):
  // const foo = bar;

  TypeScript block comment (gbc):
  /* const foo = bar; */
```

### Visual Mode Commenting

```
  Select text in visual mode, then:
  gc  = toggle line comments on the selection
  gb  = toggle block comment on the selection
```

This is the most ergonomic way to comment/uncomment a block:

```
  V         = start linewise visual
  5j        = select 5 lines
  gc        = comment all 5 lines
```

Or to uncomment:

```
  V5j       = select 5 commented lines
  gc        = remove comments from all 5
```

### VSCode Comparison

```
  VSCode: Ctrl+/           = gcc in Neovim
  VSCode: Shift+Alt+A      = gbc in Neovim
  VSCode: (visual) Ctrl+/  = (visual) gc in Neovim
```

The big difference: VSCode always uses `Ctrl+/` for toggling, and it always does line comments. `gc` in Neovim uses the motion system, so `gcap` (comment a paragraph) or `gc5j` (comment 5 lines down) are natural extensions of the same syntax you already know.

---

## 12. mini.splitjoin — Join and Split Arguments

mini.splitjoin handles a very common refactoring operation: collapsing function arguments from multi-line to single-line, or expanding them from single-line to multi-line.

### The Two Operations

```
  sj  = JOIN arguments / array / object onto ONE line
  sk  = SPLIT arguments / array / object to MULTIPLE lines
```

### Splitting — `sk`

When a function call is on one line but would be cleaner on multiple:

```
  Before: foo(arg1, arg2, arg3, arg4)
  Press sk (cursor anywhere on the line or inside the parens)
  After:
  foo(
    arg1,
    arg2,
    arg3,
    arg4,
  )
```

Also works on objects and arrays:

```
  Before: const obj = { foo: 1, bar: 2, baz: 3 }
  sk
  After:
  const obj = {
    foo: 1,
    bar: 2,
    baz: 3,
  }
```

### Joining — `sj`

The reverse: collapse multi-line onto one line:

```
  Before:
  foo(
    arg1,
    arg2,
    arg3,
  )
  Press sj (cursor anywhere in the block)
  After: foo(arg1, arg2, arg3)
```

```
  Before:
  const arr = [
    1,
    2,
    3,
  ]
  sj
  After: const arr = [1, 2, 3]
```

### Why This Matters

This operation comes up constantly in real coding. Prettier and other formatters often decide for you, but sometimes you want to temporarily collapse a call to read it, or expand it to add a new argument clearly. `sj`/`sk` do this instantly without any formatting plugin.

### VSCode Comparison

There is no built-in VSCode equivalent. The closest is triggering your formatter with specific print-width settings, or manually editing. mini.splitjoin is a targeted, instant operation that formatters cannot replace because it does not reformat the entire file.

---

## 13. Moving Lines in Visual Mode

Your config adds `J` and `K` in visual mode to move selected lines up and down.

### The Keybindings

```
  (In visual mode)
  J  = move selected lines DOWN one line
  K  = move selected lines UP one line
```

Hold `J` or `K` to keep moving. The selection stays active and moves with the lines.

### Example

```
  Before:
  Line A
  Line B     ← selected
  Line C     ← selected
  Line D

  Press J (in visual mode, with B and C selected):

  After:
  Line A
  Line D
  Line B     ← still selected
  Line C     ← still selected
```

Press `J` again and they move down another position.

### Workflow

```
  V         = start linewise visual
  2j        = extend selection down 2 lines (select 3 lines total)
  J         = move them all down one
  JJJJ      = move them 4 more lines down
  K         = move them back up one
```

The selection persists so you can keep adjusting without re-selecting.

### VSCode Comparison

```
  VSCode: Alt+Down  = J (visual) in Neovim
  VSCode: Alt+Up    = K (visual) in Neovim
```

VSCode's Alt+Down/Up moves only the current line (or selection) one step per press. The behavior is nearly identical — the main difference is that in Neovim you activate visual mode first and then use `J`/`K`, while in VSCode you just press Alt+Down anywhere.

Note: in Normal mode, `J` (capital J) is the standard Vim "join lines" command — it removes the newline between the current line and the next, merging them. This is different from the visual-mode `J` for moving. Context (which mode you are in) determines the behavior.

---

## 14. Indent Management

Indentation is a daily operation. Vim has several ways to handle it.

### Normal Mode Indent

```
  >>   = indent current line right by one shiftwidth
  <<   = dedent current line left by one shiftwidth
  {N}>>   = indent N lines starting from current
  3>>     = indent 3 lines
```

### Visual Mode Indent (This Config: Stays in Visual)

Your config remaps `>` and `<` in visual mode to re-indent and **stay in visual mode**:

```
  V         = linewise visual
  3j        = select 4 lines
  >         = indent selection right (stays in visual mode)
  >         = indent again (still in visual mode)
  <         = dedent (still in visual mode)
```

Stock Vim exits visual mode after a single `>` or `<`. Your config keeps you in visual mode so you can keep adjusting indentation by pressing `>` or `<` repeatedly. This is an ergonomic quality-of-life improvement — no need to re-select to indent again.

### Auto-Indent

```
  ==   = auto-indent current line (let Vim compute the correct indent)
  =ip  = auto-indent inner paragraph
  =iB  = auto-indent inside braces
  =ap  = auto-indent around paragraph
  gg=G = auto-indent ENTIRE FILE (gg=G = go to top, =, G = to end of file)
```

`gg=G` is the "fix all indentation" command. Be careful with it on large files or files with complex indentation logic — the auto-indent may not match your formatter perfectly, but it is a useful quick-fix.

### Indent with a Text Object

Since `=`, `>`, and `<` are operators, they combine with any text object:

```
  >iB    = indent everything inside the current braces
  <ip    = dedent inner paragraph
  =ap    = auto-indent around paragraph (includes surrounding blank lines)
  >3j    = indent current line and 3 lines below
```

### VSCode Comparison

```
  VSCode: Tab (with selection) = > in Neovim visual
  VSCode: Shift+Tab (selection) = < in Neovim visual
  VSCode: (no equivalent for =ip) auto-indent selection is approximate
```

VSCode's Tab/Shift+Tab indent works similarly but you lose the selection after Tab (you have to re-select for another Tab press). Your Neovim config keeps the selection, so you can tap `>` or `<` as many times as needed.

---

## 15. Complete Editing Reference Table

### Operators

| Key | Name | Description |
|-----|------|-------------|
| `d` | delete | Delete text, put in register |
| `c` | change | Delete text + enter Insert mode |
| `y` | yank | Copy text to register |
| `v` | visual | Enter charwise visual mode |
| `V` | visual line | Enter linewise visual mode |
| `Ctrl+V` | visual block | Enter blockwise visual mode |
| `g~` | swap case | Toggle case of text |
| `gu` | lowercase | Make text lowercase |
| `gU` | uppercase | Make text uppercase |
| `=` | auto-indent | Apply smart indentation |
| `<` | dedent | Shift text left |
| `>` | indent | Shift text right |
| `!` | filter | Pipe text through shell command |

### Text Objects (i = inner, a = around)

| Object | Description |
|--------|-------------|
| `iw` / `aw` | inner/around word |
| `iW` / `aW` | inner/around WORD |
| `is` / `as` | inner/around sentence |
| `ip` / `ap` | inner/around paragraph |
| `i"` / `a"` | inner/around double quotes |
| `i'` / `a'` | inner/around single quotes |
| `` i` `` / `` a` `` | inner/around backticks |
| `i(` / `a(` | inner/around parens (also `ib`/`ab`) |
| `i{` / `a{` | inner/around braces (also `iB`/`aB`) |
| `i[` / `a[` | inner/around brackets |
| `i<` / `a<` | inner/around angle brackets |
| `it` / `at` | inner/around HTML/JSX tag |
| `in(` | inner NEXT parens (mini.ai) |
| `il"` | inner LAST quotes (mini.ai) |

### mini.surround

| Key | Description |
|-----|-------------|
| `sa{motion}{char}` | Add surrounding |
| `ds{char}` | Delete surrounding |
| `cs{old}{new}` | Change surrounding |
| `sf{char}` | Find surrounding right |
| `sF{char}` | Find surrounding left |
| `sh{char}` | Highlight surrounding |

### yanky.nvim

| Key | Description |
|-----|-------------|
| `y` | Yank (adds to ring) |
| `p` | Put after cursor |
| `P` | Put before cursor |
| `gp` | Put after, cursor moves past |
| `gP` | Put before, cursor moves past |
| `[y` | Cycle ring forward (older yank) |
| `]y` | Cycle ring backward |
| `[p` / `]p` | Put with indent adjustment |
| `>p` / `<p` | Put and indent right/left |
| `=p` / `=P` | Put and auto-format |
| `<leader>y` | Open yank history picker |

### Macros

| Key | Description |
|-----|-------------|
| `q{a-z}` | Start recording macro |
| `q` | Stop recording |
| `@{a-z}` | Play macro |
| `@@` | Replay last macro |
| `{N}@{a}` | Play macro N times |

### multicursor.nvim

| Key | Description |
|-----|-------------|
| `<leader>cm` | Add cursor at next match |
| `<leader>cM` | Add cursors at all matches |
| `Esc` | Clear extra cursors |

### comment.nvim

| Key | Description |
|-----|-------------|
| `gcc` | Toggle line comment |
| `gbc` | Toggle block comment |
| `gc{motion}` | Toggle line comment on motion |
| `gb{motion}` | Toggle block comment on motion |
| `(visual) gc` | Toggle comment on selection |
| `(visual) gb` | Toggle block comment on selection |

### mini.splitjoin

| Key | Description |
|-----|-------------|
| `sj` | Join arguments to one line |
| `sk` | Split arguments to multiple lines |

### Visual Mode Movement (This Config)

| Key | Description |
|-----|-------------|
| `J` (visual) | Move selected lines down |
| `K` (visual) | Move selected lines up |
| `>` (visual) | Indent, stay in visual |
| `<` (visual) | Dedent, stay in visual |

### Indent

| Key | Description |
|-----|-------------|
| `>>` | Indent current line |
| `<<` | Dedent current line |
| `=` | Auto-indent (with motion) |
| `==` | Auto-indent current line |
| `gg=G` | Auto-indent entire file |

---

## 16. Putting It All Together — Real Scenarios

Here are complete, realistic editing workflows that combine the operators, text objects, and plugins in natural sequences.

### Scenario 1: Change All String Quotes from " to ' in a File

**Goal**: Convert `"double quoted"` to `'single quoted'` throughout a file.

**Approach with mini.surround + dot repeat:**

```
  /"\w<Enter>    = search for start of a double-quoted string
  n              = jump to first match
  cs"'           = change surrounding " to '
  n.             = next match, repeat change
  n.             = next match, repeat change
  (repeat n. until end of file)
```

**Approach with substitution (for a whole file at once):**

```
  :%s/"\([^"]*\)"/'\1'/g
  = global substitute: "content" → 'content'
  (the \( \) captures the content, \1 pastes it back)
```

The dot-repeat approach is better when you want selective changes (skip some). The substitute approach is better when you want all of them.

### Scenario 2: Wrap a Function Return Value in Parens

**Goal**: Change `return result;` to `return (result);`

```
  /return\s<Enter>    = find a return statement
  n                   = jump to it
  w                   = move to the return value (skip "return ")
  saaw(               = surround around-word with parens
```

Or more precisely, if `result` is a complex expression:

```
  /return\s<Enter>    = find return
  n
  ^                   = beginning of line
  ww                  = skip "return" and a space
  v$                  = visually select to end of line
  $h                  = back one to exclude the semicolon
  sa<something>(      = surround selection with parens
```

Actually the cleanest version using visual mode:

```
  0                   = start of line
  w                   = past "return"
  vg_                 = visually select from here to last non-blank char
                       (this selects "result" without the semicolon)
  sa<visual selection>(  = mini.surround wraps selection in parens
```

Which in keystroke terms is: `0wvg_sa(`

### Scenario 3: Add Semicolons to 20 Lines with a Macro

**Goal**: 20 lines missing semicolons. Add them all.

```
  Record the macro:
  qa             = record into 'a'
  A;             = append semicolon to end of line
  Esc            = back to Normal
  j              = move to next line
  q              = stop recording

  Apply to 19 more lines:
  19@a           = run macro 19 times
```

Result: all 20 lines now end in semicolons.

**Alternative for selected lines using visual + :normal:**

```
  V              = start visual
  19j            = select 20 lines
  :normal A;     = add semicolon to end of each selected line
                  (: normal runs a Normal mode command on each line)
```

The `:normal` approach does not even need a macro — it directly applies a Normal-mode command to every selected line. `A;` = append semicolon. Simple.

### Scenario 4: Rename a Variable with Multicursor

**Goal**: Rename `oldVariable` to `newVariable` everywhere in the current file.

```
  1. Place cursor on any occurrence of "oldVariable"
  2. <leader>cM       = add cursors at ALL occurrences in buffer
  3. ciw              = change inner word (all cursors simultaneously)
  4. newVariable      = type the new name
  5. Esc              = confirm the change
  6. Esc              = clear extra cursors
```

Done. All occurrences changed in one sequence.

**Why not use search-and-replace?**

```
  :%s/oldVariable/newVariable/g
```

Substitution is fine for simple cases but it is dumb — it will replace `oldVariable` inside comments, inside strings, inside other variable names like `oldVariableHelper`. Multicursor requires you to manually verify that you are selecting the right occurrences and avoids unintended replacements.

For a production rename, the LSP's rename command (`<leader>rn` or similar, depending on your LSP config) is even better — it understands scope and renames only the semantic references. But multicursor is fast and works without LSP.

### Scenario 5: Comment Out a Block While Preserving the Original

**Goal**: Keep a function but comment it out while writing a new version below it.

```
  1. Navigate to the function start
  2. V           = start linewise visual
  3. ]}          = extend selection to closing brace (jump to matching })
  4. y           = yank the selection (copy the function)
  5. p           = paste below
  6. {           = jump back to start of the copy (or use 'p position)
  7. V]}         = re-select the original
  8. gc          = comment it all out
```

Now you have the original commented out above, and the copy below to modify. When you are done with the new version:

```
  Navigate to the commented-out block
  V]}            = select it
  gc             = uncomment (gc toggles, so this removes comments)
  dd             = delete the whole block
```

Or keep both if you want a fallback.

### Scenario 6: Reformat Inline Object to Multi-line

**Goal**: `const config = { host: "localhost", port: 3000, debug: true }` → expand to multi-line.

```
  Position cursor anywhere on the line
  sk             = split (mini.splitjoin — splits to multiple lines)

  Result:
  const config = {
    host: "localhost",
    port: 3000,
    debug: true,
  }
```

Want to collapse it back?

```
  sj             = join (collapses back to one line)
```

---

## 17. Exercises

These exercises build real editing muscle memory. They are roughly ordered by difficulty. Spend at least 15 minutes on each before moving to the next.

### Exercise 1: Operator + Text Object Combinations

**Goal**: Learn the grammar by drilling combinations.

Open any code file. Practice each of these ten operations in sequence:

1. `ciw` — change a word (any word, type something new)
2. `ci"` — change inside a quoted string
3. `da(` — delete around parens (delete function call including parens)
4. `yap` — yank a paragraph
5. `gUiw` — uppercase the word under cursor
6. `guiw` — lowercase the same word
7. `>ip` — indent a paragraph
8. `=iB` — auto-indent inside braces
9. `dit` — delete inside an HTML/JSX tag
10. `ca{` — change around braces (delete block + braces + enter Insert)

For each one: find an appropriate target in the file, apply the operation, undo with `u`, find a new target, apply again.

**What you are building**: The grammar should become second nature. After this exercise, you should never be thinking "what shortcut do I use" — instead you should think "what verb, what object?"

### Exercise 2: The Dot Repeat Drill

**Goal**: Make a repeatable change and apply it many times.

1. Create a file with 20 lines, each containing a variable declaration without a type:
   ```
   const name = getValue();
   const age = getAge();
   const email = getEmail();
   ...
   ```
2. On the first line, use `$bi: string<Esc>` or a similar pattern to add `: string` before the `=`
3. Move to the next line with `j`
4. Press `.` to repeat the change
5. Continue with `j.` for each remaining line

Try to do all 20 lines using ONLY `j` and `.` after making the initial change.

**Variation**: try `A;<Esc>` to add semicolons, then `j.j.j.` down the file.

**What you are building**: The dot-repeat instinct. When you make a change and think "I need to do this to several other places," your first thought should be `.`

### Exercise 3: Macro for Structural Editing

**Goal**: Build a macro for a non-trivial task.

Task: you have a file of plain data:

```
alice
bob
carol
dave
eve
```

Your goal is to turn each name into a JavaScript object:

```
{ name: "alice" },
{ name: "bob" },
{ name: "carol" },
{ name: "dave" },
{ name: "eve" },
```

1. Record the macro on the first line:
   - `qa` to start
   - `I{ name: "<Esc>` to insert prefix
   - `A" },<Esc>` to append suffix
   - `j` to advance to next line
   - `q` to stop
2. Verify the first line looks correct
3. Apply `4@a` to handle the remaining 4 names

**What you are building**: The ability to think in macros. When you see a repetitive structural transformation, your brain should go: "record one, repeat N."

### Exercise 4: Surround Workflow

**Goal**: Fluency with mini.surround.

Open a JavaScript/TypeScript file with function calls and string literals.

1. Find a function argument that is a string: `doSomething("hello")`
2. With cursor on the string, practice:
   - `cs"'` to change to single quotes
   - `cs'`` ` to change to backtick (template literal)
   - `` cs`( `` to wrap in parens instead
   - `ds(` to remove the parens
3. Find a word (no quotes), practice:
   - `saaw"` to wrap in double quotes
   - `cs"[` to change quotes to brackets
   - `ds[` to remove brackets
4. Find a multi-line block, practice:
   - `saip{` to wrap the paragraph in braces
   - Undo, then `saip(` to wrap in parens instead

**What you are building**: Surround fluency. You should be able to add, change, and remove surrounding characters without thinking about the syntax.

### Exercise 5: Multicursor Variable Rename

**Goal**: Learn the full multicursor workflow.

1. Create or open a file with a variable used many times, something like:
   ```typescript
   function processUser(userId: string) {
     const user = getUser(userId);
     if (!user) {
       throw new Error(`User ${userId} not found`);
     }
     const data = fetchData(userId);
     return transformData(data, userId);
   }
   ```
2. Place cursor on `userId` anywhere in the function
3. Use `<leader>cM` to select ALL occurrences
4. Verify that labels/highlights appear on every `userId`
5. Type `ciw` to change all simultaneously
6. Type `userIdentifier` as the new name
7. Press `Esc` to confirm
8. Press `Esc` again to clear multicursor
9. Verify all occurrences changed correctly

**Bonus**: Try `<leader>cm` (lowercase) to add cursors one at a time. Skip the `userId` in the function signature (you might want the type signature to change separately). Practice the selective approach.

**What you are building**: Confidence with multicursor. It feels powerful but can be intimidating if you have never used it. After this exercise, reaching for `<leader>cM` should feel natural for any in-file rename.

---

> **Coming Up Next**: [05 · The LSP, Completions, and Diagnostics](./05-lsp-completions-diagnostics.md) — Intelligent code completion, go-to-definition, hover docs, diagnostics, and the full power of language server integration in this config.

---

*Part of the "Neovim 0 to Hero" series.*
