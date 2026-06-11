# 05 · Search and Replace

> **Series:** Neovim from 0 to Hero
> **Prerequisites:** 01 (basics), 02 (motions), 03 (editing), 04 (buffers & windows)
> **Time estimate:** ~90 minutes to read + practice

---

Search and replace in Neovim is one of those areas where — honestly — it starts a little intimidating, but once it clicks you will never want to go back to anything else. You have multiple tools at your disposal that cover every scenario: quick in-file searches, powerful regex substitution, project-wide live grep, and a full visual find-and-replace panel. This tutorial covers all of them.

By the end of this chapter you will:

- Know exactly which tool to reach for in every search scenario
- Use `/` and `?` confidently with regex, case control, and history
- Write `:substitute` commands that do non-trivial transformations
- Open `grug-far.nvim` and do a project-wide rename in under a minute
- Use Snacks grep for fast project-wide searching
- Populate the quickfix list and do batched replacements across dozens of files
- Navigate all TODO/FIXME/HACK comments in a project effortlessly

Let's start with the most important thing: knowing which tool to use.

---

## 1. The Search Landscape

Before diving into any command, here is a decision flowchart. When you need to search or replace something, run through this mentally:

```
                     ┌─────────────────────────────────────┐
                     │        WHAT DO YOU NEED TO DO?       │
                     └────────────────┬────────────────────-┘
                                      │
              ┌───────────────────────┼──────────────────────┐
              │                       │                      │
              ▼                       ▼                      ▼
     ┌────────────────┐    ┌────────────────────┐  ┌─────────────────┐
     │  FIND/NAVIGATE │    │  FIND + REPLACE    │  │  BROWSE TODOs   │
     └───────┬────────┘    └────────┬───────────┘  └───────┬─────────┘
             │                      │                      │
      ┌──────┴──────┐         ┌─────┴──────┐         ┌─────┴─────┐
      │             │         │            │         │           │
      ▼             ▼         ▼            ▼         ▼           ▼
  In THIS      Project-   In THIS     Project-   List ALL  Jump next/
   file         wide       file        wide       todos    prev todo
      │             │         │            │         │           │
      ▼             ▼         ▼            ▼         ▼           ▼
   /pattern     <leader>   :%s/old/    <leader>  <leader>pt   ]t / [t
   ?pattern       pg        new/g        ps       <leader>pT
   * or #        <leader>              <leader>
                  pws                   pS
```

Let that diagram sink in. Each branch has one or two tools that own it. You do not have to remember all of them at once — just remember this flowchart, and you will always know where to look.

Here is the same information as a quick reference table:

| Scenario | Command | Plugin |
|---|---|---|
| Quick search forward in file | `/pattern` | built-in |
| Quick search backward in file | `?pattern` | built-in |
| Search word under cursor forward | `*` | built-in |
| Search word under cursor backward | `#` | built-in |
| In-file find + replace | `:%s/old/new/g` | built-in |
| Project-wide live grep | `<leader>pg` | Snacks.nvim |
| Project-wide grep word under cursor | `<leader>pws` | Snacks.nvim |
| Project-wide visual find + replace | `<leader>ps` | grug-far.nvim |
| Project-wide replace word under cursor | `<leader>pS` | grug-far.nvim |
| Browse all TODO comments | `<leader>pt` | todo-comments + Trouble |
| Browse priority TODOs (FIXME/HACK) | `<leader>pT` | todo-comments + Trouble |
| Jump to next TODO | `]t` | todo-comments |
| Jump to previous TODO | `[t` | todo-comments |

Now let's go through each category in depth.

---

## 2. Basic Search: `/` and `?` Patterns

### 2.1 Forward and Backward Search

The `/` key puts you in search mode, going forward through the file:

```
Normal mode → type / → type your pattern → press Enter
```

The `?` key does the same thing but searches *backward* (upward in the file):

```
Normal mode → type ? → type your pattern → press Enter
```

After a search lands on the first match, you navigate between all matches:

- `n` — jump to the next match (in the direction you searched)
- `N` — jump to the previous match (opposite direction)

So if you searched with `/`, `n` goes forward and `N` goes backward. If you searched with `?`, it is the opposite. This trips people up at first — just remember that `n` always continues in the original search direction.

### 2.2 What the `nzzzv` / `Nzzzv` Mappings Do

In this Neovim configuration, `n` and `N` are remapped to `nzzzv` and `Nzzzv` respectively. Let's break that down because it's genuinely useful:

```
nzzzv
│││││
│││└┘── v = open any folds at the cursor position
││└──── z = another z-command (chained)
│└───── zz = scroll the screen so the cursor is vertically centered
└────── n = go to next match
```

The `zz` part is the important one: every time you press `n`, the screen scrolls to keep your cursor in the middle of the visible area. Without this, when you press `n` repeatedly you can end up at the very bottom or top of the screen, which makes it hard to see context around the match.

The `v` at the end opens any fold that the match landed inside, so you never get stuck looking at a collapsed fold wondering why you can't see the match.

The double `zz` (which is what `zzz` breaks down to internally) is a quirk of how the `z` prefix commands chain in Neovim — the net result is just "center the screen on the cursor."

This is one of those small quality-of-life remaps that experienced Neovim users have in their config. You probably won't notice it consciously, but remove it and you will immediately feel the difference when searching through a long file.

Here is a spatial diagram to illustrate what centering does:

```
WITHOUT nzzzv (standard n behavior):
┌──────────────────────────────────┐
│ line 1                           │
│ line 2                           │
│ line 3  ← match #1              │
│ line 4                           │
│ line 5                           │
│ ...                              │
│ line 98                          │
│ line 99 ← match #2   (cursor)   │  ← you have 1 line of context below
│ line 100                         │  ← bottom of screen
└──────────────────────────────────┘

WITH nzzzv (centered n behavior):
┌──────────────────────────────────┐
│ ...                              │
│ line 88                          │
│ line 89                          │
│ line 90  ← match #2  (cursor)   │  ← always in the middle
│ line 91                          │
│ line 92                          │
│ ...                              │
└──────────────────────────────────┘
```

You always have equal context above and below the match. This makes it much easier to understand what you're looking at.

### 2.3 Case Sensitivity

By default, Neovim's search is case-sensitive. Here are your options:

**Override per-search using inline flags:**

```
/pattern\c      ← ignore case for this search only
/pattern\C      ← force case-sensitive for this search only
```

The `\c` and `\C` can appear anywhere in the pattern (beginning, middle, end) — Neovim picks them up wherever they are.

**Settings-level control:**

```lua
-- In your options.lua or equivalent:
vim.opt.ignorecase = true    -- case-insensitive by default
vim.opt.smartcase = true     -- BUT if you type any uppercase letter,
                              -- become case-sensitive automatically
```

With `ignorecase + smartcase` (which is the recommended combination):

- `/hello` — matches `hello`, `Hello`, `HELLO`, `HeLLo`
- `/Hello` — matches `Hello` only (uppercase H triggered smartcase)
- `/HELLO` — matches `HELLO` only
- `/hello\c` — forces case-insensitive even if you have `smartcase`
- `/Hello\C` — forces case-sensitive even if `ignorecase` is set

This combination is considered best practice. You get case-insensitive search 90% of the time (since most searches are lowercase), and automatic case-sensitive search when you type an uppercase letter intentionally.

### 2.4 Star and Hash: Search Word Under Cursor

Two of the fastest ways to search are `*` and `#`:

- `*` — search forward for the exact word under the cursor
- `#` — search backward for the exact word under the cursor

"Exact word" means Neovim wraps the word in `\<` and `\>` word-boundary anchors. So if your cursor is on `foo` in `foobar`, `*` will NOT match `foobar` — it will only match standalone `foo`.

```
Text:    foo foobar foo  foo-bar  foo
Cursor: on first "foo"

*  will match:  foo (positions 1, 3, 5)
   will NOT match: foobar, foo-bar
```

The partial-match versions:

- `g*` — search forward for the string under cursor, without word boundaries (matches substrings)
- `g#` — search backward, same idea

```
Text:    foo foobar foo  foo-bar  foo
Cursor: on first "foo"

g*  will match:  foo, foobar, foo-bar (everywhere "foo" appears as a substring)
```

`*` is incredibly useful for finding all occurrences of a variable name. Put your cursor on the variable, press `*`, and now you can navigate every usage with `n` and `N`.

### 2.5 Search History

Neovim keeps a history of your searches. To access it:

1. Press `/` to open the search prompt
2. Press `↑` (Up arrow) to cycle through previous searches
3. Press `↓` (Down arrow) to go forward in history

You can also use the command-line history (`q/` to open a full history window for searches, `q?` for backward searches). In that window you can edit entries and press Enter to execute them. Type `:` in normal mode then `q:` to open command history.

The search history window (`q/`) looks like this:

```
  /myFunction
  /TODO
  /\vreturn \w+
  /ignorecase\c
  /UserService
  >                        ← cursor here, type to add a new search
```

You can navigate to any previous search with `j`/`k`, edit it like a normal Neovim buffer (fix a typo in a complex regex, for example), then press `Enter` to execute it. Press `Ctrl-C` or `q` to dismiss without running anything.

This is particularly useful when you've written a complex regex, used it, navigated away, and then realize you need it again with a slight modification. Instead of retyping the whole thing, press `q/`, navigate to it, edit, and run.

**Practical tip:** If you run a search and immediately want to convert it to a substitution:

```vim
" You just searched for:
/\vfunction (\w+)

" Now you want to substitute. You could type:
:%s/\vfunction (\w+)/fn \1/g

" But you can also use the empty pattern // to reuse the last search:
:%s//fn \1/g    ← empty pattern reuses the last search pattern!
```

The empty pattern `//` in a substitute command always reuses whatever you last searched for. This is a great timesaver: do your search first to verify the pattern matches what you expect, then run `:%s//replacement/g` to substitute without retyping the pattern.

### 2.6 Clearing Search Highlights

After a successful search, Neovim highlights all matches in the file (assuming `hlsearch` is enabled, which it should be). These highlights stay visible until:

- You do a new search
- You press `<leader>nh` to clear them

In this config, `<leader>nh` runs `:nohlsearch` which clears the highlights without removing the search pattern (you can still press `n` to jump to the next match, but the highlights are gone).

> 💡 **VSCode users:** In VSCode, pressing `Ctrl+F` opens the Find widget, which highlights all matches and shows a count. Pressing `Escape` closes it and clears highlights. Neovim's `/` does the same thing but inline in the command line. The key difference: in Neovim you stay in the file — there's no popup to close. Highlights stay until you explicitly clear them with `<leader>nh` (like pressing Escape in VSCode's find bar). The `*` command (search word under cursor) has no direct VSCode equivalent in terms of speed — the closest would be double-clicking a word to select it, then `Ctrl+Shift+L` to select all occurrences. But `*` in Neovim is a single keystroke that immediately lets you navigate every occurrence with `n`/`N`.

---

## 3. The `:substitute` Command In Depth

The `:substitute` command (abbreviated `:s`) is Neovim's built-in find and replace engine. It is one of the most powerful text manipulation tools you will ever learn, and it repays the time you spend learning it for the rest of your career.

### 3.1 The Basic Pattern

```
:[range]s[ubstitute]/pattern/replacement/[flags]
```

Let's break each piece down:

```
 :%s/old/new/g
 │││   │   │ └── flags (g = global, replace all on each line)
 │││   │   └──── replacement text
 │││   └──────── pattern to find (regex)
 ││└──────────── separator character (/ is conventional but can be anything)
 │└───────────── s (abbreviation of :substitute)
 └────────────── % (range meaning "whole file", more on ranges below)
```

The separator `/` can be any character that doesn't appear in your pattern. This is important when you're working with file paths:

```vim
" This would break because of the slashes in the path:
:s/src/old/src/new/g   ← WRONG, confusing

" Use a different separator instead:
:s|src/old|src/new|g   ← uses | as separator
:s#src/old#src/new#g   ← uses # as separator
:s@src/old@src/new@g   ← uses @ as separator
```

### 3.2 Understanding Ranges

Without a range, `:s` only substitutes on the current line.

```vim
:s/old/new/g        ← current line only
:%s/old/new/g       ← entire file (% = all lines)
:5s/old/new/g       ← line 5 only
:5,10s/old/new/g    ← lines 5 through 10
:.,+5s/old/new/g    ← current line (.) through 5 lines below (+5)
:'<,'>s/old/new/g   ← visual selection (set automatically when you : from visual mode)
:1,$s/old/new/g     ← line 1 to last line (same as %)
```

The visual selection range `'<,'>` is created automatically when you:
1. Select some lines in Visual mode (V for linewise, v for characterwise)
2. Press `:` — Neovim automatically fills in `'<,'>`

This is one of the most practical uses of ranges. Select the block of code you want to modify, press `:`, and Neovim restricts your substitution to just that block.

Here's how ranges map to the buffer visually:

```
Line 1  ┐
Line 2  │  :1,5s/old/new/g  ← affects these lines only
Line 3  │
Line 4  │
Line 5  ┘
Line 6
Line 7  ← cursor here: .s/old/new/g affects only this line
Line 8
Line 9  ┐
Line 10 ┘  :'<,'>s/old/new/g  ← only if you selected these lines first
```

### 3.3 All the Flags

```vim
:%s/old/new/g    ← g: global — replace ALL occurrences on each line
                    without g, only the FIRST occurrence per line is replaced

:%s/old/new/c    ← c: confirm — ask before each replacement (interactive)

:%s/old/new/i    ← i: ignore case for this substitution

:%s/old/new/I    ← I: force case-sensitive (overrides 'ignorecase' setting)

:%s/old/new/n    ← n: count only — show how many matches exist, don't replace
                    great for previewing before committing to a change

:%s/old/new/e    ← e: suppress "no match" error (useful in scripts)

:%s/old/new/gc   ← combine flags: global + confirm
:%s/old/new/gi   ← combine flags: global + ignore case
:%s/old/new/gci  ← combine flags: global + confirm + ignore case
```

The `n` flag deserves special attention. Before doing a big replace, run it first to verify the count:

```vim
:%s/myVariable/newVariableName/gn
" Output: 47 matches on 23 lines
```

If 47 sounds right, run it again without `n` to do the replacement.

### 3.4 The Confirmation Dialog (`c` flag)

When you use the `c` flag, Neovim highlights each match one by one and asks:

```
replace with newVariableName (y/n/a/q/l/^E/^Y)?
```

Your options:

| Key | Action |
|---|---|
| `y` | Yes — replace this match |
| `n` | No — skip this match |
| `a` | All — replace this and all remaining matches (no more prompts) |
| `q` | Quit — stop here, don't replace anything more |
| `l` | Last — replace this match, then quit |
| `Ctrl-E` | Scroll screen up (to see context) |
| `Ctrl-Y` | Scroll screen down (to see context) |

The `a` option is particularly useful: you start with `c` to check the first few matches and make sure the pattern is correct, then press `a` to replace everything else without reviewing each one.

### 3.5 Regex in Substitute: Groups and Backreferences

This is where `:substitute` becomes genuinely powerful. Neovim uses its own regex engine (Vim regex), which is slightly different from PCRE (the regex most programmers know from JavaScript/Python/etc).

**Basic special characters:**

```
.         any character (except newline)
*         zero or more of the preceding item
\+        one or more (note: in basic regex, + needs escaping)
\?        zero or one (optional)
^         start of line
$         end of line
[abc]     character class (a, b, or c)
[^abc]    negated character class (anything except a, b, c)
```

**Atom classes:**

```
\w        word character (letter, digit, underscore)
\W        non-word character
\s        whitespace (space, tab)
\S        non-whitespace
\d        digit (0-9)  — Note: this works in Neovim, not traditional Vim
\D        non-digit
\a        alphabetic character
\A        non-alphabetic
\l        lowercase letter
\u        uppercase letter (note: \u in replacement means something different!)
```

**Grouping and backreferences:**

```vim
" Wrap function call arguments in extra parens:
:%s/myFunc(\(.*\))/myFunc((\1))/g
"           └────┘          └┘
"           group 1       backreference \1
```

Groups are defined with `\(` and `\)` (note the backslashes — this is Vim regex's "basic" mode). Backreferences use `\1`, `\2`, etc.

**Example: swap two words:**

```vim
" Input:  firstName, lastName
" Goal:   lastName, firstName
:%s/\(\w\+\), \(\w\+\)/\2, \1/g
```

Let's read that substitution:
- `\(\w\+\)` — group 1: one or more word characters
- `, ` — literal comma and space
- `\(\w\+\)` — group 2: one or more word characters
- Replacement: `\2, \1` — group 2, comma space, group 1

**Example: rename a function and preserve its arguments:**

```vim
" Input:  oldName(arg1, arg2)
" Goal:   newName(arg1, arg2)
:%s/oldName(\(.\{-}\))/newName(\1)/g
```

The `.\{-}` is a non-greedy match (match as few characters as possible), which is important here to avoid matching across multiple function calls. In Vim regex, `\{-}` is the non-greedy quantifier.

### 3.6 Case Manipulation in Replacement

The replacement string supports special escape sequences to change the case of the substituted text:

```
\u    Capitalize (uppercase) the next character in the replacement
\U    ALL UPPERCASE from here until \E or end of replacement
\l    lowercase the next character
\L    all lowercase from here until \E or end of replacement
\E    end a \U or \L span
```

**Example: capitalize the first letter of each matched word:**

```vim
" Convert: hello world foo bar
" To:      Hello World Foo Bar
:%s/\<\(\w\)/\u\1/g
"             └┘└┘
"             \u = uppercase next char
"             \1 = the first letter (from group 1)
```

**Example: make a constant name uppercase:**

```vim
" Convert: const myValue = ...
" To:      const MY_VALUE = ...
" (This is simplified — real camelCase to SCREAMING_SNAKE requires more work)
:%s/\<\([A-Z]\)/\_\1/g   ← insert underscore before each capital
:%s/.*/\U&/g              ← make everything uppercase
"          &  = the entire match (shorthand for \0)
```

The `&` in the replacement string represents the entire matched text (same as `\0`). Combined with `\U`:

```vim
:%s/\<my_\(\w\+\)\>/\U\1/g
" Converts: my_variable → VARIABLE
```

**Example: convert kebab-case to camelCase:**

```vim
" Convert: my-variable-name → myVariableName
:%s/-\(\l\)/\u\1/g
"    └───┘   └─┘
"    hyphen followed by lowercase letter
"    replace with uppercase version of that letter
```

### 3.7 The `\v` Very Magic Mode

Vim regex has multiple "magic" levels that control which characters need to be escaped. By default (magic mode), `(`, `)`, `+`, `?` etc. need backslashes to be special. This is confusing for people who know PCRE.

The solution: `\v` at the start of a pattern puts it in "very magic" mode, where regex is much closer to PCRE:

```vim
" Normal (magic) mode — needs backslashes for grouping/quantifiers:
:%s/\(\w\+\) \(\w\+\)/\2 \1/g

" Very magic mode — much cleaner:
:%s/\v(\w+) (\w+)/\2 \1/g
```

In `\v` mode:
- `(` and `)` are grouping (no backslash needed)
- `+` is "one or more" (no backslash needed)
- `?` is "optional" (no backslash needed)
- `{3}` is "exactly 3 times" (no backslash needed)

The only characters that are literal in `\v` mode are `a-z`, `A-Z`, `0-9`, and `_`. Everything else is a regex metacharacter (which you can escape with `\` to make literal).

This is the recommended mode for complex patterns. Just start your search or substitution pattern with `\v`:

```vim
:%s/\v(function|const|let|var) (\w+)/\1 renamed_\2/g
```

> 💡 **VSCode users:** VSCode's Find & Replace supports both plain text mode and regular expressions mode (toggle with `Alt+R` on Windows/Linux or `⌥+R` on Mac). VSCode uses JavaScript-style regex (PCRE-like), so patterns like `(\w+)` work directly without backslashes for grouping. Neovim's default regex mode requires `\(\w\+\)` for the same thing — or you can use `\v` mode at the start of your pattern to get closer to what you're used to. The VSCode "Replace All" button is equivalent to `:%s/old/new/g`. The "Replace one by one" button is like `:%s/old/new/gc`. One major advantage of Neovim: the case manipulation sequences (`\u`, `\U`, `\l`, `\L`) have no equivalent in VSCode's built-in replace — you'd need an extension for that.

---

## 4. `grug-far.nvim` — Full Walkthrough

### 4.1 What Is grug-far?

`grug-far` (the name is a playful joke about the user-friendly simplicity of the interface — "grug" as in a caveman who finds complex things confusing) is a Neovim plugin that provides a visual, interactive find-and-replace panel for your entire project. Think of it as VSCode's "Find in Files" + "Replace in Files" but living inside a Neovim buffer.

The core idea: instead of running commands blindly and hoping the regex is right, you get a live preview of what will change before you commit to it. For large-scale refactoring, this is invaluable.

### 4.2 Opening grug-far

```
<leader>ps    → open grug-far panel (project search)
<leader>pS    → open grug-far with the word under cursor pre-filled
```

Note: `ps` is lowercase (open blank), `pS` is uppercase (pre-fill current word).

When you press `<leader>ps`, a new panel opens that looks something like this:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  grug-far                                                               │
├─────────────────────────────────────────────────────────────────────────┤
│  Search:   │                                                            │
├────────────┘                                                            │
│  Replace:                                                               │
├─────────────────────────────────────────────────────────────────────────┤
│  Paths:                                                                 │
├─────────────────────────────────────────────────────────────────────────┤
│  Flags:    --multiline                                                  │
├─────────────────────────────────────────────────────────────────────────┤
│  Results:                                                               │
│                                                                         │
│  (type in the Search field and press Enter to search)                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 4.3 The UI: Field by Field

**Search field:** Type the pattern you want to find. grug-far uses `ripgrep` under the hood by default, so you can use regular expressions here. The search is live — as you type, results appear in the Results section below.

**Replace field:** Type the replacement text. Leave it empty to do a search-only operation (like grep). Fill it in to preview replacements. Backreferences work here: `$1`, `$2` for groups (because ripgrep uses PCRE syntax, not Vim regex).

**Paths field:** Restrict the search to specific files or directories. Examples:
- `src/` — only search in the `src` directory
- `*.lua` — only `.lua` files
- `src/ --type lua` — only `.lua` files inside `src/`
- Leave blank to search the entire project

**Flags field:** ripgrep flags passed directly. Common ones:
- `--multiline` — allow patterns to span multiple lines
- `--type lua` — restrict to lua files (cleaner than path glob)
- `--type-not test` — exclude test files
- `-w` or `--word-regexp` — match whole words only
- `-i` or `--ignore-case` — case-insensitive search
- `-s` or `--case-sensitive` — case-sensitive (overrides config)

### 4.4 Navigating the UI

The grug-far panel is a normal Neovim buffer in insert-mode-friendly layout. Here's how to work with it:

```
Tab / Shift-Tab     → move between fields (Search → Replace → Paths → Flags)
Enter (in Search)   → execute the search
Enter (in Results)  → open the file under cursor at that line
```

**Inside the panel (while in Normal mode on a result line):**

```
Enter or gf    → go to the file/line under cursor
<CR>           → same as above
```

**To execute the replacement (replace all matches):**

Once you have results showing and a replacement filled in, look for the replace action. In grug-far, you typically:

1. Fill in Search field
2. Fill in Replace field
3. Look at the preview in Results — lines marked for replacement show the diff
4. Execute: in normal mode, press the keybinding configured for "replace all" (typically `<leader>r` or check the buffer-local mappings shown at the top of the grug-far window)

The exact keybindings shown inside grug-far depend on your configuration. Look at the top of the grug-far buffer when it opens — it shows available actions.

### 4.5 Real Example: Rename a Variable Across a Project

Suppose you have a JavaScript/TypeScript project and you want to rename `userConfig` to `appConfig` everywhere.

**Step 1:** Put your cursor on `userConfig` anywhere in your code.

**Step 2:** Press `<leader>pS` — grug-far opens with `userConfig` pre-filled in the Search field.

**Step 3:** Press `Tab` to move to the Replace field and type `appConfig`.

**Step 4:** Watch the Results section update — you'll see a list of every file and line that contains `userConfig`, with a preview of what it will look like after replacement.

**Step 5:** Verify the results look correct. Are there any false positives? For example, does `userConfig` appear in comments or strings where you don't want to change it?

**Step 6:** If you want to restrict to specific files, Tab to the Paths field and add something like `src/` to exclude test fixtures or auto-generated files.

**Step 7:** Execute the replacement. All files are updated simultaneously.

**Step 8:** After the replacement, grug-far shows a summary. You can then close the panel and your code has been updated.

### 4.6 Real Example: Change Import Paths After Reorganizing Files

You moved all utility functions from `src/utils/` to `src/lib/utilities/`. Now you need to update every import.

```
Search:  from ['"].*src/utils/(.+)['"]
Replace: from 'src/lib/utilities/$1'
Paths:   src/
Flags:   --type ts
```

The regex captures everything after `src/utils/` in the import path and uses it in the replacement. The `$1` backreference (ripgrep/PCRE style) inserts the captured group.

This is the kind of refactor that used to take 20 minutes of carefully running `sed` commands or using a shell script. With grug-far you do it interactively with a live preview.

### 4.7 The grug-far Results Buffer in Detail

When a search returns results, the grug-far panel shows something like:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  Search:  userConfig                                                    │
│  Replace: appConfig                                                     │
│  Paths:   src/                                                          │
│  Flags:   --word-regexp                                                 │
├─────────────────────────────────────────────────────────────────────────┤
│  Results:  47 matches in 12 files                                       │
│                                                                         │
│  src/components/App.tsx                                                 │
│    12:  const userConfig = { theme: 'dark' }    ← will become appConfig │
│    45:  return userConfig.theme                 ← will become appConfig │
│                                                                         │
│  src/utils/config.ts                                                    │
│     3:  export const userConfig = {}            ← will become appConfig │
│    28:  if (userConfig.debug) {                 ← will become appConfig │
│                                                                         │
│  ...10 more files...                                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

Before executing the replace, you can:
- Scroll through the results carefully
- Press `Enter` on any result to jump to that location and inspect it in context
- Come back to grug-far and adjust the pattern if needed

This is the killer feature compared to a blind `:cfdo %s///g` command — you see every change before it happens.

> 💡 **VSCode users:** grug-far is essentially VSCode's "Find in Files" (`Ctrl+Shift+F`) combined with "Replace in Files" — but living inside a Neovim buffer. The biggest difference: in VSCode, "Replace in Files" has no per-file preview by default (though you can expand each result to see context). In grug-far, the results panel shows you exactly what will change, file by file, with clear before/after context. Another difference: grug-far uses ripgrep directly, so you have full access to all ripgrep flags. VSCode's search also uses ripgrep internally but exposes fewer options. If you're used to VSCode's `Ctrl+H` for single-file replace, that maps to Neovim's `:%s/old/new/gc`. For project-wide replace, reach for `<leader>ps` (grug-far).

---

## 5. Snacks Grep — Live Project Grep

### 5.1 What Is Snacks Grep?

`snacks.nvim` is a collection of small, well-designed Neovim utilities. The grep functionality provides a fast, live-updating project-wide search with a picker interface. It's powered by ripgrep and feels like a cross between VSCode's "Find in Files" and a fuzzy finder.

The key difference from grug-far: Snacks grep is **search-only** (no replace). Use it when you want to find where something is, not when you want to change it.

### 5.2 The Two Search Keybindings

```
<leader>pg    → open live grep: search the whole project
<leader>pws   → grep the word under cursor (or visual selection)
```

`pg` opens an empty search prompt and you type your query.
`pws` instantly starts a search for whatever word your cursor is currently on — zero typing required.

### 5.3 How the Snacks Picker Works

When you press `<leader>pg`:

```
┌─────────────────────────────────────────────────────────────────────────┐
│  > _                                                   [grep]           │
├─────────────────────────────────────────────────────────────────────────┤
│  src/components/Button.tsx:12:  const handleClick = () => {            │
│  src/utils/helpers.ts:45:       function formatDate(                   │
│  src/pages/index.tsx:8:         import { Button } from                 │
│  ...                                                                    │
└─────────────────────────────────────────────────────────────────────────┘
```

The top bar is your input. As you type, results update in real time below. Results show:
- File path
- Line number
- The matching line content (with your query highlighted)

**Navigating the picker:**

```
Type            → filter results in real time
↑ / ↓           → move selection up/down
Ctrl-P / Ctrl-N → alternative up/down navigation
Enter           → open the selected file at the matching line
Ctrl-Enter      → open in a horizontal split
Ctrl-V          → open in a vertical split
Escape          → close the picker
```

### 5.4 The Power of `<leader>pws`

Put your cursor on a function name, variable, or any identifier. Press `<leader>pws`.

Snacks instantly searches for that exact word (with word boundaries, so `foo` won't match `foobar`) across your entire project. The results appear immediately.

This is the "who uses this function?" shortcut. Much faster than:
1. Copying the word
2. Opening a search panel
3. Pasting
4. Pressing search

One keystroke and you're looking at every reference.

**For visual selections:** Select multiple words in visual mode, then press `<leader>pws` to search for the exact selected string.

### 5.5 Snacks Grep vs. grug-far: Which to Use?

```
┌────────────────────────────────┬────────────────────────────────────────┐
│  USE SNACKS GREP WHEN:         │  USE GRUG-FAR WHEN:                    │
├────────────────────────────────┼────────────────────────────────────────┤
│  • You're exploring/reading    │  • You want to change something        │
│  • You want to navigate to a   │  • You need a preview before replacing │
│    specific location           │  • You're doing a project-wide rename  │
│  • You need a quick "where is  │  • You want per-file fine-grained      │
│    this used" answer           │    control over what gets replaced     │
│  • You're browsing code        │  • You need to verify before committing│
│  • Performance is critical     │                                        │
└────────────────────────────────┴────────────────────────────────────────┘
```

Think of Snacks grep as "search and navigate" and grug-far as "search and transform."

---

## 6. `fff.nvim` — Fuzzy Finding

### 6.1 What fff Brings to the Table

`fff.nvim` (the fuzzy finder functionality in your config) provides additional file and content finding capabilities that complement Snacks:

```
<leader>ff    → find files (fuzzy file name search)
<leader>fg    → live grep (similar to <leader>pg)
<leader>fz    → fuzzy grep (fuzzier, less strict matching)
<leader>fc    → search current word in project
```

### 6.2 File Finding vs. Content Searching

`<leader>ff` searches file *names* (and paths), not file *contents*. Type `Button` and you'll see `src/components/Button.tsx`, `src/stories/Button.stories.ts`, etc.

`<leader>fg` and `<leader>fz` search file *contents*. The difference between the two:

- `<leader>fg` (live grep): exact substring/regex matching — what you type must literally appear in the file
- `<leader>fz` (fuzzy grep): fuzzy matching — the characters you type can be spread out across the line, in order but not necessarily contiguous

**Example with fuzzy grep:**

Searching for `hnclk` with fuzzy grep might match `handleClick` — because `h`, `n`, `c`, `l`, `k` appear in that order in `handleClick`. This is faster when you know the rough shape of what you're looking for but can't remember exact spelling.

Here's that idea illustrated:

```
Query:   h  n  c  l  k
         │  │  │  │  │
         ↓  ↓  ↓  ↓  ↓
Result:  handleClick
         ^  ^ ^^  ^
         h  n cl  k   ← all characters present in order, non-contiguous is ok
```

### 6.3 When to Use fff vs. Snacks

```
┌─────────────────────────────────┬───────────────────────────────────────┐
│  USE fff WHEN:                   │  USE SNACKS GREP WHEN:               │
├─────────────────────────────────┼───────────────────────────────────────┤
│  • Finding file by name          │  • Searching file contents            │
│    (<leader>ff)                  │    (<leader>pg)                       │
│  • You want fuzzy/approximate    │  • You want exact/regex matching      │
│    content search (<leader>fz)   │  • You need strict word-boundary      │
│  • Quick "open this file" flow   │    search (<leader>pws)               │
│  • Large repos where you know    │                                       │
│    approximate names             │                                       │
└─────────────────────────────────┴───────────────────────────────────────┘
```

In practice, most workflows use `<leader>ff` (file finding) and `<leader>pg` or `<leader>pws` (content searching) as the core pair. The fuzzy grep (`<leader>fz`) is useful when you're in a large unfamiliar codebase and can't remember exact function names.

---

## 7. The Quickfix Workflow

### 7.1 What Is the Quickfix List?

The quickfix list is one of Neovim's oldest and most powerful features. It's a list of file locations (file + line number + optional message) that you can navigate sequentially. Think of it as a bookmark list that multiple tools can populate.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        QUICKFIX LIST                                    │
├─────────────────────────────────────────────────────────────────────────┤
│  #  File                    Line  Col   Text                            │
│  ──────────────────────────────────────────────────────────────────     │
│  1  src/components/App.tsx    12    8   const userConfig = {           │
│  2  src/components/App.tsx    45    4   return userConfig.theme        │
│  3  src/utils/config.ts        3   12   export const userConfig        │
│  4  src/utils/config.ts       28    6   if (userConfig.debug) {        │
│  5  src/pages/index.tsx        7   18   import { userConfig } from     │
│  6  tests/config.test.ts      15   10   expect(userConfig).toBe(       │
│                                                                         │
│  [6 entries]                                                            │
└─────────────────────────────────────────────────────────────────────────┘
```

The quickfix list lives independently of what buffer you're editing. You can populate it, then work through it at your own pace, jumping to each entry.

Tools that populate the quickfix list:
- `:vimgrep` (built-in grep)
- `:grep` (external grep, uses ripgrep if configured)
- Many LSP operations (go to all references, find all errors, etc.)
- Compiler output
- Test output
- Any plugin that wants to show you a list of locations

### 7.2 The Location List vs. the Quickfix List

Before populating the quickfix list, a brief aside: Neovim actually has two similar structures — the **quickfix list** and the **location list**.

```
QUICKFIX LIST                    LOCATION LIST
─────────────────────────────    ─────────────────────────────
Global to the editor session     Local to the current window
One per Neovim instance          One per window
Commands: :copen, :cn, :cp       Commands: :lopen, :ln, :lp
Populated by: :grep, :vimgrep    Populated by: :lgrep, :lvimgrep
Macro: :cfdo                     Macro: :lfdo
```

In practice, you will use the **quickfix list** (`:c` commands) for project-wide searches and the **location list** (`:l` commands) for window-specific things like LSP diagnostics. When people say "quickfix" they almost always mean the global one.

The LSP (language server) in Neovim typically uses the location list for diagnostics, which is why `:lopen` shows you errors and warnings for the current file. The `:copen` quickfix is reserved for your explicit searches.

### 7.3 Populating the Quickfix List with `:vimgrep`

```vim
:vimgrep /pattern/ fileglob
```

Examples:

```vim
" Search for TODO in all Lua files recursively:
:vimgrep /TODO/ **/*.lua

" Search for a function name in all TypeScript files:
:vimgrep /userConfig/ **/*.ts **/*.tsx

" Search in all files (any type) recursively:
:vimgrep /myPattern/ **/*

" Search in current directory only (not recursive):
:vimgrep /myPattern/ *.lua

" Case-insensitive search:
:vimgrep /myPattern/i **/*.lua
```

The `**/*` glob means "all files, recursively." The `**/*.lua` means "all `.lua` files, recursively."

**Note:** `:vimgrep` is slower than ripgrep because it uses Neovim's built-in regex engine to read every file. For large projects, use `:grep` instead (which uses the external program defined in `grepprg`, usually ripgrep) or use Snacks grep for searching and then use `:cdo` on the resulting quickfix list.

Using ripgrep as the grep program:
```vim
" In your config (already set up if using a modern config):
vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"

" Then use :grep instead of :vimgrep (much faster):
:grep userConfig src/
```

### 7.4 Navigating the Quickfix List

```vim
:copen       ← open the quickfix window (shows all entries)
:cclose      ← close the quickfix window
:cn          ← jump to next entry (or :cnext)
:cp          ← jump to previous entry (or :cprev)
:cfirst      ← jump to first entry
:clast       ← jump to last entry
:cc N        ← jump to entry number N
```

The quickfix window is a regular Neovim buffer. In it:
- Press `Enter` on an entry to jump to that location
- Press `q` to close it
- Each entry shows file, line number, and the matching text

**Deleting quickfix entries:**

You can delete entries from the quickfix list that you don't want to process. With the quickfix window open, move your cursor to an entry and press `dd` — this removes it from the list (without affecting the actual file).

This is useful when:
- The grep found occurrences in generated/vendored files you want to skip
- A few results are false positives and you only want to replace the rest
- You've already handled some entries manually and want to work through the rest

You can delete a range too: `5,10dd` removes entries 5 through 10.

**Filtering the quickfix list:**

```vim
" Keep only entries matching a pattern (removes non-matching entries):
:Cfilter /pattern/

" Keep only entries NOT matching a pattern:
:Cfilter! /pattern/
```

`:Cfilter` is available in Neovim (via the `cfilter` plugin that ships with Neovim — enable with `:packadd cfilter`). This lets you narrow down a large quickfix list after the fact.

### 7.5 Mass Replace with `:cfdo` and `:cdo`

This is the killer feature of the quickfix list for search-and-replace workflows.

**`:cfdo {command}`** — run `{command}` once per *file* in the quickfix list.

**`:cdo {command}`** — run `{command}` once per *entry* in the quickfix list.

The practical difference:

```vim
" :cfdo runs the command ONCE per file (even if multiple entries in same file)
:cfdo %s/userConfig/appConfig/g | update

" :cdo runs the command for EACH entry (once per matching line)
:cdo s/userConfig/appConfig/g | update
```

For most refactoring tasks, `:cfdo` is what you want. Here's the complete workflow:

**Full quickfix replace workflow:**

```vim
" Step 1: Find all occurrences (populate quickfix list)
:grep userConfig src/
" or:
:vimgrep /userConfig/ **/*.ts **/*.tsx

" Step 2: Open quickfix window to review the list
:copen
" Review: are these all the right places? Any false positives?
" Close when satisfied:
:cclose

" Step 3: Run substitution across all files in the quickfix list
:cfdo %s/userConfig/appConfig/g | update
"           │               │     └──────── save the file after modifying
"           │               └───────────── replacement
"           └───────────────────────────── find this
```

The `| update` part is important: it saves each file after modifying it. Without it, you'd have a bunch of unsaved changes across many buffers. `:update` is like `:write` but only saves if the buffer was actually modified.

**Example with confirmation:**

```vim
:cfdo %s/userConfig/appConfig/gc
```

This asks you to confirm each replacement, but file-by-file. After reviewing the first file and pressing `a` (all), it moves to the next file automatically.

**Running multiple commands with `:cfdo`:**

You can chain multiple commands with `|`:

```vim
:cfdo %s/oldName/newName/g | %s/oldType/newType/g | update
```

This runs both substitutions on each file before saving.

You can also use `:cfdo` to run non-substitution commands — for instance, deleting a line if it contains a pattern:

```vim
:cfdo g/deprecated_function/d | update
```

This deletes every line containing `deprecated_function` from each file in the quickfix list.

Or formatting each file after the change:

```vim
:cfdo %s/oldName/newName/g | lua vim.lsp.buf.format() | update
```

(This works if your LSP is configured and supports formatting.)

**The power of this approach:**

Imagine you have 50 TypeScript files that all import from a moved module:

```typescript
// Old:
import { helper } from '../../shared/utils'
// New:
import { helper } from '@shared/utils'
```

```vim
:grep "from '../../shared/utils'" src/
:cfdo %s/from '\.\.\/\.\.\/shared\/utils'/from '@shared\/utils'/g | update
```

Done. All 50 files updated in one command. (The backslashes before `/` escape the forward slashes in the path.)

> 💡 **VSCode users:** The quickfix list has no direct VSCode equivalent, but the closest analog is VSCode's "Problems" panel (`Ctrl+Shift+M`) combined with the "Find All References" (`Shift+F12`) results. The key difference is that Neovim's quickfix list is much more flexible — any operation can populate it, and `:cfdo` lets you run arbitrary Vim commands across all the listed files. VSCode's "Replace in Files" (`Ctrl+Shift+H`) is easier for simple cases but has no equivalent to `:cfdo`'s ability to run complex transformations (multiple substitutions, reformatting, etc.) file-by-file.

---

## 8. TODO Comments — Finding and Tracking Work

### 8.1 What `todo-comments.nvim` Does

The `todo-comments.nvim` plugin watches your buffers for special comment keywords and highlights them with distinct colors. It understands these keywords by default:

```lua
-- TODO: standard pending task marker
-- FIXME: something that needs to be fixed
-- HACK: a workaround, not the right solution
-- WARN: warning / important note
-- PERF: performance concern
-- NOTE: informational note
-- TEST: a test that needs to be written
```

Each keyword gets its own highlight color, so they stand out visually from regular comments.

Here's what a file looks like with todo-comments active:

```
  1  -- Module for processing user data
  2  local M = {}
  3
  4  -- TODO: add input validation          ← highlighted in yellow/cyan
  5  function M.processUser(user)
  6    -- HACK: using string comparison     ← highlighted in orange
  7    if tostring(user.id) == "0" then
  8      return nil
  9    end
 10
 11    -- NOTE: user.name can be nil        ← highlighted in blue
 12    local name = user.name or "Anonymous"
 13
 14    -- FIXME: this crashes if nil        ← highlighted in red
 15    local email = string.lower(user.email)
 16  end
```

**How to write them correctly:**

The keywords are case-sensitive and require a colon followed by a space (or just a colon at the end of the keyword). Common ways:

```lua
-- TODO: implement error handling
-- FIXME: this breaks when arr is empty
-- HACK: using setTimeout because the API isn't ready
-- WARN: this function mutates its input
-- NOTE: see RFC-123 for background on this decision
-- PERF: could be O(n) instead of O(n²) with a hash map
-- TEST: add a test for the nil case

// Also works in other comment styles:
// TODO: fix this
/* FIXME: broken */
# NOTE: Python comment
```

**What does NOT work:**

```lua
-- todo: lowercase keywords are NOT recognized
-- TODO no colon
-- TODO:no space after colon (also NOT recognized by default)
```

### 8.2 Navigating TODOs

```
]t    → jump to the NEXT todo comment in the file
[t    → jump to the PREVIOUS todo comment in the file
```

These work like `]d`/`[d` for diagnostics or `]h`/`[h` for git hunks — they move you directly to the next item of that type without any UI, completely fluid navigation.

If you're doing a code review or pre-release cleanup, use `]t` to walk through every TODO in every file you visit, addressing them one by one.

The navigation follows file order (line numbers), so pressing `]t` repeatedly walks you through every comment from top to bottom, cycling back to the first one when you reach the end.

### 8.3 Listing All TODOs with Trouble

The `]t`/`[t` navigation is great for sequential browsing, but sometimes you want a bird's-eye view of all the TODOs in the project at once. That's what the Trouble integration provides:

```
<leader>pt    → open Trouble with ALL todo types
<leader>pT    → open Trouble with PRIORITY todos only (FIXME and HACK)
```

**`<leader>pt` — all todos:**

Opens a Trouble window at the bottom of your screen listing every `TODO`, `FIXME`, `HACK`, `WARN`, `PERF`, `NOTE`, and `TEST` comment in the project, grouped by file.

```
┌─────────────────────────────────────────────────────────────────────────┐
│  TODOS                                                         [Trouble] │
├─────────────────────────────────────────────────────────────────────────┤
│  src/components/App.tsx                                                 │
│    12 TODO: add loading state                                           │
│    45 FIXME: memory leak in useEffect                                   │
│  src/utils/api.ts                                                       │
│     8 HACK: retry logic is fragile                                      │
│    23 NOTE: rate limit is 1000 req/hour                                 │
│    67 TODO: add proper error types                                      │
│  tests/integration.test.ts                                              │
│    34 TEST: need end-to-end test for auth flow                          │
└─────────────────────────────────────────────────────────────────────────┘
```

**`<leader>pT` — priority todos (FIXME, HACK):**

Same thing but filtered to show only `FIXME` and `HACK` entries. These are the ones that represent known problems or code debt — the things you want to clean up before shipping.

In the Trouble window:
- Navigate with `↑`/`↓` or `j`/`k`
- Press `Enter` to jump to that location in the code
- Press `q` or `<leader>xx` to close Trouble

### 8.4 The Comment Types: When to Use What

Each keyword has a specific intended meaning. Using them consistently makes the codebase more readable and makes filtering (`<leader>pT` for priority) meaningful:

| Keyword | Color | Meaning | When to Use |
|---|---|---|---|
| `TODO` | cyan/yellow | Work to do later | Feature not yet implemented, planned improvement |
| `FIXME` | red | Broken/wrong | Actual bug, incorrect behavior, crash potential |
| `HACK` | orange | Workaround | Works but not the right approach, tech debt |
| `WARN` | orange | Danger | Side effects, gotchas, "don't touch this without reading X" |
| `NOTE` | blue | Information | Non-obvious context, links to docs, decisions |
| `PERF` | purple | Performance | Slow code that could be optimized |
| `TEST` | green | Missing tests | Code that needs test coverage |

The distinction between `FIXME` and `HACK` is important:
- `FIXME` = "this is broken, it needs to be fixed"
- `HACK` = "this works, but it's not the right way to do it"

Both appear in `<leader>pT` because both represent problems that ideally shouldn't ship, but they have different urgency levels.

### 8.5 Practical TODO Workflow

**During development:**

```lua
-- Add TODOs as you go, without breaking your flow:
function processUser(user)
  -- TODO: validate user object before processing
  -- HACK: hardcoded timeout, make configurable later
  local result = doProcessing(user)
  -- FIXME: result can be nil if user.id is missing
  return result
end
```

**During code review / cleanup:**

1. Press `<leader>pT` to see all FIXMEs and HACKs
2. Start with the most critical (FIXMEs)
3. Press `Enter` on each to jump there
4. Fix it and delete the comment
5. Return to Trouble with `<leader>pT` again
6. Continue until the list is empty

**Before a release:**

```
<leader>pt    → check: are there any TODOs that should be FIXMEs?
<leader>pT    → are there any FIXMEs we can't release with?
]t            → walk through every single todo in the file you're reviewing
```

> 💡 **VSCode users:** The most direct VSCode equivalent is the "Todo Tree" extension or "TODO Highlight" extension — both scan your project for TODO/FIXME/etc comments and display them in a sidebar panel. Neovim's `todo-comments.nvim` does the same thing but with a few extras: the `]t`/`[t` navigation to jump between todos without opening a panel, and the Trouble integration that shows the list in a styled, searchable window. The highlight colors are configurable per-keyword. One thing worth noting: VSCode extensions for this typically require configuration to recognize the right keywords. `todo-comments.nvim` ships with sane defaults that cover the most common patterns.

---

## 9. Advanced Patterns

### 9.1 The `\v` (Very Magic) Mode Revisited

We mentioned `\v` earlier but it's worth going deeper because it changes the feel of writing complex regex in Neovim.

Without `\v` (default magic mode):

```vim
" Match a function definition: function foo(args)
:%s/function \(\w\+\)(\(.*\))/fn \1(\2)/g
"                                          ^^^^ backreferences work
"           └──────┘  └────┘
"           escaped parens for grouping
"           \+ for one-or-more
```

With `\v` (very magic mode):

```vim
" Same pattern, much more readable:
:%s/\vfunction (\w+)\((.+)\)/fn \1(\2)/g
"               └──┘  └──┘
"               unescaped parens for grouping
"               unescaped + for one-or-more
"   BUT: literal parens in the function call still need escaping
"   because ( is a special char in \v mode
```

In `\v` mode, the rule is:
- `(` and `)` → grouping (special)
- `\(` and `\)` → literal parentheses

In normal mode (without `\v`), the rule is:
- `(` and `)` → literal parentheses
- `\(` and `\)` → grouping (special)

The `\v` convention matches what most regex engines outside Vim use, which is why many Neovim users prefer it.

**Lookahead and lookbehind in `\v` mode:**

```vim
" Positive lookahead: match 'foo' only when followed by 'bar'
:%s/\vfoo(bar)@=/FOO/g
"           └─┘
"           @= is lookahead in Vim regex

" Negative lookahead: match 'foo' only when NOT followed by 'bar'
:%s/\vfoo(bar)@!/FOO/g

" Positive lookbehind: match 'bar' only when preceded by 'foo'
:%s/\v(foo)@<=bar/BAR/g

" Negative lookbehind: match 'bar' only when NOT preceded by 'foo'
:%s/\v(foo)@<!bar/BAR/g
```

These are advanced but occasionally essential. The syntax (`@=`, `@!`, `@<=`, `@<!`) is Vim-specific — unlike PCRE's `(?=...)`, `(?!...)`, etc.

**Practical lookahead example:** Rename a variable `config` to `settings` but only when it's used as a standalone variable, not when it's part of a longer name like `userConfig` or `configFile`.

```vim
" Match 'config' not followed by a word character (not part of a longer name)
:%s/\vconfig(\w)@!/settings/g
"                  ← this prevents matching 'configFile'

" And not preceded by a word character (not part of 'userConfig')
:%s/\v(\w)@<!config(\w)@!/settings/g
"      ← prevents matching 'userConfig'
```

### 9.2 Case-Preserving Substitution

One of the most common refactoring needs is renaming something while preserving case. For example, renaming a concept from `user` to `customer`:

- `user` → `customer`
- `User` → `Customer`
- `USER` → `CUSTOMER`
- `userProfile` → `customerProfile`
- `UserProfile` → `CustomerProfile`

A naive `:%s/user/customer/g` gets the first case right but misses `User` (with `ignorecase` it changes `User` to `customer` which is wrong).

A multi-step approach:

```vim
" Step 1: uppercase first letter (User, UserProfile)
:%s/\vUser/Customer/g

" Step 2: all-caps (USER)
:%s/\vUSER/CUSTOMER/g

" Step 3: lowercase (user, userProfile)
:%s/\vuser/customer/g
```

This works but requires three commands. A more elegant approach uses a macro or a single substitution with a function, but for most day-to-day work the three-command approach is fast enough.

For truly automated case-preserving substitution, grug-far with the right ripgrep flags or a dedicated Neovim plugin/Lua function is the way to go.

### 9.3 The `gn` Text Object — Select Current Search Match

After searching with `/`, the `gn` motion selects the next match of the current search pattern. You can use it with any operator:

```
cgn    → change the next search match (delete and enter insert mode)
dgn    → delete the next search match
ygn    → yank the next search match
```

The killer combo: search for what you want to change, then use `cgn` to change it, then press `.` to repeat for the next one.

**Example workflow:**

1. Search for `oldName` with `/oldName<Enter>`
2. Press `cgn` — selects the match and puts you in insert mode
3. Type `newName`
4. Press `Escape`
5. Press `n` to jump to the next match
6. Press `.` to repeat the change

This is different from `:%s/oldName/newName/gc` in an important way: you can *skip* individual matches simply by pressing `n` again instead of `.`. You're using the undo-able `cgn` + `.` repeat pattern, which gives you fine-grained control without a confirmation prompt per match.

Here's a visual walkthrough:

```
File:          │  Press:  │  Result:
───────────────┼──────────┼────────────────────
/oldName       │  search  │  all oldName highlighted
n              │          │  jump to first match
cgn → newName  │  change  │  first match → newName
Escape         │          │  back to normal mode
n              │  skip    │  jump to second match (without changing)
n              │  skip    │  jump to third match
.              │  repeat  │  third match → newName (dot repeats cgn+newName)
n              │          │  jump to fourth
.              │  repeat  │  fourth → newName
```

This is particularly useful when:
- Most occurrences need to change but a few don't
- You want to see each match in context before deciding
- The pattern is complex enough that you want visual confirmation

### 9.4 Multi-File Refactor: The Complete Workflow

Here's a narrative of a realistic refactoring scenario: you're renaming the `UserService` class to `AccountService` across a large TypeScript project.

**Approach A: Using grug-far (recommended for most cases)**

1. Put cursor on `UserService` anywhere in the code
2. Press `<leader>pS` — grug-far opens with `UserService` pre-filled
3. Press `Tab` to move to Replace field
4. Type `AccountService`
5. Press `Tab` to move to Paths field
6. Type `src/` to restrict to source files (not tests yet)
7. Look at the results — 47 occurrences across 12 files
8. Scroll through the results, verify no false positives
9. Execute the replacement
10. Repeat for tests: change Paths to `tests/` and replace again

Total time: about 2 minutes, with visual confirmation.

**Approach B: Using the quickfix workflow (better for complex transformations)**

This approach is superior when you need more than a simple string replacement — for example, if you also need to update imports, change file names, and modify configuration files differently.

```vim
" Step 1: Find all occurrences with ripgrep
:grep UserService src/ tests/

" Step 2: Review the quickfix list
:copen
" Look through the 47 entries — any in files you want to skip?
" Note any entries that need manual attention
:cclose

" Step 3: Handle the main rename
:cfdo %s/UserService/AccountService/g | update

" Step 4: Verify — run grep again to make sure nothing was missed
:grep UserService src/ tests/
" Quickfix list should now be empty (0 results)
```

**Approach C: Hybrid (for the most complex cases)**

```vim
" Use grug-far for the initial broad search to understand scope
" <leader>pS with cursor on UserService

" Then use quickfix for fine-grained control
:grep UserService **/*.ts
:copen                          ← review, maybe delete some entries with dd
:cfdo %s/UserService/AccountService/g | update

" Run tests to verify
:!npm test
```

The key insight: these tools are not mutually exclusive. Start with grug-far to preview scope, use quickfix for execution if you need batched custom commands.

### 9.5 Regex Tips and Common Patterns

**Match an entire line:**

```vim
:%s/^.*pattern.*$//g           ← delete entire lines containing "pattern"
:%s/^.*pattern.*\n//g          ← same, but also remove the newline
```

**Add something at beginning/end of every line:**

```vim
:%s/^/PREFIX /g                ← add "PREFIX " at start of every line
:%s/$/ SUFFIX/g                ← add " SUFFIX" at end of every line
:%s/^/    /g                   ← indent every line by 4 spaces
```

**Delete trailing whitespace:**

```vim
:%s/\s\+$//g                   ← delete trailing spaces/tabs on every line
```

**Collapse multiple blank lines into one:**

```vim
:%s/\n\{3,\}/\r\r/g            ← 3+ consecutive newlines → 2 newlines
```

**Remove comments (simple single-line):**

```vim
:%s/^\s*\/\/.*\n//g            ← remove lines that are only // comments
```

**Convert between quote styles:**

```vim
:%s/"\([^"]*\)"/'\1'/g         ← convert "double" to 'single' quotes
```

**Add a line after every line matching a pattern:**

```vim
:g/pattern/normal o newline content
```

This uses the `:global` command (`:g`), which runs a command on every line matching a pattern. `:g` is related to `:s` but more general — instead of replacing text, it runs any Ex command.

**Delete all lines matching a pattern:**

```vim
:g/pattern/d
```

**Delete all lines NOT matching a pattern (keep only matching lines):**

```vim
:v/pattern/d          ← :v is short for :g!  (global inverted)
```

**Count occurrences of a pattern:**

```vim
:%s/pattern//gn       ← n flag: count without replacing
```

**Using `:global` with substitute for two-pass operations:**

```vim
" First mark all lines with a pattern, then process only those:
:g/function/s/local /export const /
" This only runs the substitution on lines that also contain "function"
" Much more targeted than :%s
```

### 9.6 Understanding `hlsearch`, `incsearch`, and Related Options

There are a few options that shape the search experience, and understanding them helps you configure Neovim to your preference:

```lua
vim.opt.hlsearch = true       -- highlight all matches (default: off in Vi)
                               -- with true: all matches stay highlighted
                               -- press <leader>nh to clear
vim.opt.incsearch = true      -- incremental search: highlight matches AS you type
                               -- this is what makes search feel "live"
vim.opt.ignorecase = true     -- case-insensitive search by default
vim.opt.smartcase = true      -- override ignorecase when uppercase is typed
vim.opt.wrapscan = true       -- wrap around end of file when searching (default)
                               -- with false: searching stops at end of file
```

The combination of `hlsearch + incsearch` is what makes search in modern Neovim feel fast and interactive — you see matches highlighted in real time as you type the pattern, and all matches stay highlighted after you press Enter so you can quickly see the distribution.

If you ever find the persistent highlights distracting (especially after a search you did for navigation purposes), `<leader>nh` is your friend. Some configs also clear highlights automatically when you start moving (`autocmd CursorMoved * nohlsearch`), though this can be annoying because it clears even when you press `n` to navigate.

The recommended approach (used in this config): `hlsearch = true` with the manual `<leader>nh` clearance. You get highlights when you want them and can dismiss them with one keypress.

### 9.7 The `:global` Command — Beyond Substitution

The `:global` command deserves its own spotlight because it's a force multiplier for text manipulation. Its syntax:

```
:[range]g[lobal]/{pattern}/{command}
```

It runs `{command}` on every line matching `{pattern}`. The command can be *any* Ex command — delete, substitute, normal mode command, yank, etc.

**Delete matching lines:**
```vim
:g/TODO/d          ← delete every line with "TODO"
```

**Yank all matching lines to a register:**
```vim
:g/TODO/y A        ← append every TODO line to register a
" Then paste them all: "ap
```

**Run a normal mode command on matching lines:**
```vim
:g/function/normal >>    ← indent every line containing "function"
:g/^$/d                  ← delete all blank lines
```

**Chain with substitute for conditional replacement:**
```vim
:g/^export/s/function/const/
" Only replaces "function" with "const" on lines that start with "export"
```

**The inverted form `:v` (or `:g!`) runs on non-matching lines:**
```vim
:v/^import/d             ← keep only lines starting with "import"
:g!/NOTE/d               ← delete every line that does NOT contain "NOTE"
```

This becomes extremely powerful when combined with visual selection:
1. Select a block of code
2. Press `:` (auto-fills `'<,'>`)
3. Add `g/pattern/command`

For example: in a selected block, delete all comment lines:
```vim
:'<,'>g/^\s*--/d         ← delete all Lua comment lines in selection
```

---

## 10. Reference Table: All Search-Related Keybindings

| Keybinding | Mode | Action | Plugin/Source |
|---|---|---|---|
| `/pattern` | Normal | Search forward | built-in |
| `?pattern` | Normal | Search backward | built-in |
| `n` | Normal | Next match (centered) | config: `nzzzv` |
| `N` | Normal | Previous match (centered) | config: `Nzzzv` |
| `*` | Normal | Search word under cursor, forward (exact) | built-in |
| `#` | Normal | Search word under cursor, backward (exact) | built-in |
| `g*` | Normal | Search word under cursor, forward (partial) | built-in |
| `g#` | Normal | Search word under cursor, backward (partial) | built-in |
| `<leader>nh` | Normal | Clear search highlights | config |
| `gn` | Normal | Select next search match (text object) | built-in |
| `cgn` | Normal | Change next search match | built-in |
| `:%s/old/new/g` | Command | Replace all in file | built-in |
| `:%s/old/new/gc` | Command | Replace with confirmation | built-in |
| `:%s/old/new/gn` | Command | Count matches without replacing | built-in |
| `:'<,'>s/old/new/g` | Command | Replace in visual selection | built-in |
| `:vimgrep /pat/ glob` | Command | Search files → quickfix | built-in |
| `:grep pat glob` | Command | External grep → quickfix | built-in (ripgrep) |
| `:copen` | Command | Open quickfix window | built-in |
| `:cclose` | Command | Close quickfix window | built-in |
| `:cn` | Command | Next quickfix entry | built-in |
| `:cp` | Command | Previous quickfix entry | built-in |
| `:cfdo cmd` | Command | Run cmd on each file in quickfix | built-in |
| `:cdo cmd` | Command | Run cmd on each entry in quickfix | built-in |
| `:cfirst` | Command | Jump to first quickfix entry | built-in |
| `:clast` | Command | Jump to last quickfix entry | built-in |
| `<leader>pg` | Normal | Live grep project | snacks.nvim |
| `<leader>pws` | Normal | Grep word under cursor | snacks.nvim |
| `<leader>ps` | Normal | Open grug-far (project replace) | grug-far.nvim |
| `<leader>pS` | Normal | Open grug-far with word under cursor | grug-far.nvim |
| `<leader>ff` | Normal | Find files (fuzzy) | fff.nvim |
| `<leader>fg` | Normal | Live grep (fff) | fff.nvim |
| `<leader>fz` | Normal | Fuzzy grep | fff.nvim |
| `<leader>fc` | Normal | Search current word (fff) | fff.nvim |
| `<leader>pt` | Normal | Open Trouble: all TODOs | todo-comments + Trouble |
| `<leader>pT` | Normal | Open Trouble: priority TODOs | todo-comments + Trouble |
| `]t` | Normal | Jump to next TODO comment | todo-comments |
| `[t` | Normal | Jump to previous TODO comment | todo-comments |

---

## 11. Exercises

These exercises are designed to be done in order. Each one builds on what came before. To do them, you'll need a project with some code — either a real project or you can create some Lua files with dummy content.

---

### Exercise 1: Navigate Using `/` and Practice n/N Centering

**Goal:** Get comfortable with basic search and understand the centering behavior.

**Setup:** Open a Lua file that's at least 100 lines long. Your Neovim config files work great for this (`~/.config/nvim/lua/de100/plugins/` has several).

**Tasks:**

1. Open `~/.config/nvim/lua/de100/plugins/blink-cmp.lua` (or any moderately long file).

2. Press `gg` to go to the top of the file.

3. Type `/return` and press `Enter`. Observe where the cursor lands and where on the screen it is.

4. Press `n` several times. Watch how the screen recenters after each jump. The cursor should stay roughly in the middle of the screen vertically — this is `nzzzv` in action.

5. Press `N` to go backward. Same centering behavior.

6. Now search for a short, common string like `/local` and navigate through all matches. Notice how with many matches, the centering prevents you from ever being at the very edge of the screen.

7. Practice the case sensitivity:
   - Search `/return\C` — forces case-sensitive, finds only lowercase `return`
   - Search `/RETURN\C` — should find fewer/no results
   - Search `/return\c` — case-insensitive, finds `return`, `Return`, `RETURN`

8. Put your cursor on a function name (any word). Press `*`. Notice it highlights and jumps to the next occurrence. Press `n` to cycle through all of them.

9. Press `<leader>nh` to clear the highlights.

10. Open the search history: press `q/`. Use `j`/`k` to browse your previous searches. Press `Escape` to close without running anything.

**What to verify:** After this exercise, you should be able to search for anything in a file and navigate all matches without the cursor flying off to the edge of the screen.

---

### Exercise 2: Use `:%s` with Confirmation Flag to Rename a Function

**Goal:** Practice `:substitute` with the confirm flag and understand all the confirmation choices.

**Setup:** Create a test file to work in so you don't damage your config:

```vim
:e /tmp/test_substitute.lua
```

Press `i` to enter insert mode and type this content:

```lua
local function processData(input)
  local result = processData(input)
  if result then
    return processData(result)
  end
  return processData(nil)
end

-- processData is called multiple times
-- We want to rename processData to handleInput

local x = processData({})
local y = processData(x)
```

Press `Escape` then `:w` to save.

**Tasks:**

1. Run this command to count how many occurrences exist before doing anything:
   ```vim
   :%s/processData/handleInput/gn
   ```
   It should report "7 matches on 7 lines" (or similar) without changing anything.

2. Now do the replacement with confirmation:
   ```vim
   :%s/processData/handleInput/gc
   ```

3. Neovim highlights the first match and asks `replace with handleInput (y/n/a/q/l/^E/^Y)?`

4. For the first match, press `y` (yes).
5. For the second match, press `n` (no — skip it).
6. For the third match, press `y`.
7. Now press `a` (all) to replace all remaining matches at once.

8. Undo everything with `u` until you're back to all `processData`.

9. Now try the replacement again, but use the `\v` very magic mode:
   ```vim
   :%s/\vprocessData(\w*)/handleInput\1/gc
   ```
   This pattern captures any suffix after `processData` (like if it was `processDataAsync`).
   The `\1` in the replacement preserves whatever was captured.

10. Undo back to `processData` again.

11. Finally, practice case manipulation — capitalize the first letter of the replacement:
    ```vim
    :%s/\vprocess(\u\l*)/handle\1/g
    ```
    This matches `processData` (where `Data` starts with uppercase `D`) and replaces `process` with `handle`, keeping `Data` intact.

**What to verify:** You understand how `y/n/a/q/l` work during confirmation, and you've practiced basic `\v` mode patterns.

---

### Exercise 3: Use `<leader>pS` to Find and Replace a Variable Name Project-Wide

**Goal:** Use grug-far for a real project-wide rename with visual preview.

**Setup:** You need a project with multiple files. Your Neovim config directory works perfectly — it has many `.lua` files with consistent patterns.

**Tasks:**

1. Open any `.lua` file in your Neovim config:
   ```vim
   :e ~/.config/nvim/lua/de100/plugins/trouble.lua
   ```

2. Find the word `trouble` in the file. Navigate to it and put your cursor on it.

3. Press `<leader>pS` to open grug-far with `trouble` pre-filled in the Search field.

4. Look at the Results section — how many files and occurrences are found?

5. **Do NOT execute any replacement** — this is a real config file. Instead, practice navigating the grug-far UI:
   - Press `Tab` to move to the Replace field
   - Type something (but don't execute the replace)
   - Press `Tab` to move to Paths field
   - Press `Tab` to move to Flags field
   - Press `Shift-Tab` to go backward through fields

6. Now close grug-far (press `q` in normal mode, or `:q`).

7. Open a temporary directory and create multiple files for a safe practice environment:
   ```vim
   :!mkdir -p /tmp/grug_test
   :!echo "let userToken = 'abc'" > /tmp/grug_test/auth.js
   :!echo "const userToken = getUserToken()" >> /tmp/grug_test/auth.js
   :!echo "function validateUserToken(t) {}" > /tmp/grug_test/validate.js
   :!echo "export { userToken }" > /tmp/grug_test/index.js
   ```

8. Change to that directory:
   ```vim
   :cd /tmp/grug_test
   ```

9. Put your cursor on `userToken` in any file and press `<leader>pS`.

10. In the Replace field, type `authToken`.

11. In the Paths field, leave it blank (or type `/tmp/grug_test/`).

12. Look at the preview. Verify the replacements look correct.

13. Execute the replacement.

14. Open `auth.js` to verify the change happened:
    ```vim
    :e /tmp/grug_test/auth.js
    ```

**What to verify:** You can open grug-far, navigate its fields, preview changes, and execute a project-wide replacement.

---

### Exercise 4: Populate the Quickfix List and Do a `:cfdo` Replace

**Goal:** Learn the quickfix workflow for batched file operations.

**Setup:** Use the files created in Exercise 3, or create a fresh set:

```vim
:!mkdir -p /tmp/quickfix_test
:!printf 'function foo() {}\nfoo();\nconst x = foo();' > /tmp/quickfix_test/a.js
:!printf '// foo is great\nfoo.call(this);\nreturn foo;' > /tmp/quickfix_test/b.js
:!printf "import { foo } from './a';\nfoo(1,2,3);" > /tmp/quickfix_test/c.js
:cd /tmp/quickfix_test
```

**Tasks:**

1. First, configure ripgrep as the grep program for this session (skip if already in your config):
   ```vim
   :set grepprg=rg\ --vimgrep\ --smart-case
   :set grepformat=%f:%l:%c:%m
   ```

2. Search for `foo` across all JavaScript files:
   ```vim
   :grep foo *.js
   ```

3. Open the quickfix window to see all results:
   ```vim
   :copen
   ```
   You should see entries from all three files.

4. Navigate through the entries:
   - Press `Enter` on an entry to go to that location
   - Press `Ctrl-W-W` to return to the quickfix window
   - Use `:cn` and `:cp` to jump forward/back without leaving quickfix

5. Close the quickfix window:
   ```vim
   :cclose
   ```

6. Now do the actual replacement across all files in the quickfix list:
   ```vim
   :cfdo %s/\bfoo\b/bar/g | update
   ```
   The `\b` word boundaries (or use `\<foo\>` in Vim regex) ensure we match only the whole word `foo`, not substrings.

7. After the command runs, open the quickfix window again:
   ```vim
   :copen
   ```
   The entries are still there (quickfix doesn't update until you re-run the search).

8. Re-run the grep to verify the replacement worked:
   ```vim
   :grep foo *.js
   ```
   You should get zero results (or only results in comments if you have any).

9. Now verify the replacement:
   ```vim
   :grep bar *.js
   :copen
   ```
   You should see all the original `foo` locations now showing `bar`.

10. **Bonus:** Practice `:cdo` (per-entry, not per-file):
    ```vim
    :grep bar *.js
    :cdo s/bar/baz/g | update
    ```
    This does the same thing but runs the substitution on each quickfix entry's line individually.

**What to verify:** You can populate the quickfix list, navigate it, and run `:cfdo` to apply changes across all listed files.

---

### Exercise 5: Find All TODOs and Fix Them Using `]t` Navigation

**Goal:** Use the todo-comments navigation to walk through and address all outstanding TODOs in a file.

**Setup:** Create a test file with intentional TODOs:

```vim
:e /tmp/todos_practice.lua
```

Enter insert mode and add this content:

```lua
-- Module for processing user data
local M = {}

-- TODO: add input validation
function M.processUser(user)
  -- HACK: using string comparison for ID because parseInt is broken
  if tostring(user.id) == "0" then
    return nil
  end

  -- NOTE: user.name can be nil for anonymous users
  local name = user.name or "Anonymous"

  -- FIXME: this crashes if user.email is nil
  local email = string.lower(user.email)

  -- TODO: send welcome email
  -- TODO: log this action to analytics

  return {
    id = user.id,
    name = name,
    email = email,
  }
end

-- PERF: this function is O(n²) for large user lists
function M.processBatch(users)
  local results = {}
  for _, user in ipairs(users) do
    -- HACK: skip invalid users instead of erroring
    local ok, result = pcall(M.processUser, user)
    if ok then
      results[#results + 1] = result
    end
  end
  return results
end

-- TEST: write tests for processBatch with empty list, nil input, and large input

return M
```

Press `Escape` and `:w` to save.

**Tasks:**

1. Press `gg` to go to the top of the file.

2. Press `]t` to jump to the first TODO comment. Notice where it lands.

3. Read the TODO. Now "fix" it by replacing the TODO with a NOTE that explains why you're deferring it:
   ```
   -- NOTE: input validation deferred to v2 spec (see issue #42)
   ```
   (In a real scenario you'd actually add validation code. Here we're practicing the navigation.)

4. Press `]t` again to jump to the next TODO/comment. Keep going:
   - At each HACK: add a comment explaining the plan to fix it properly
   - At the FIXME: fix it by adding a nil check: `local email = string.lower(user.email or "")`
   - At the TODOs: either implement them or convert to WARN/NOTE with explanation
   - At the PERF: add a TODO in its place with a specific plan: `-- TODO: use hash map to reduce to O(n) - see perf analysis in wiki`
   - At the TEST: actually write a test stub

5. After handling each todo comment, navigate to the next with `]t`.

6. When you reach the end of the file and press `]t`, Neovim wraps around to the first one (or says "no more").

7. Press `[t` to go backward through todos.

8. Now open the Trouble TODO list to see the project overview:
   ```
   <leader>pt
   ```
   You should see a list of all remaining TODOs in the file (whatever you left in after your edits).

9. Navigate the Trouble list with `j`/`k`, press `Enter` to jump to any entry.

10. Close Trouble with `q`.

11. Open the priority-only list:
    ```
    <leader>pT
    ```
    This should show only FIXMEs and HACKs — the ones that represent actual problems, not just future improvements.

12. Make sure all FIXMEs are resolved (or converted to something lower-priority).

**What to verify:** You can use `]t`/`[t` for fluid navigation between TODO comments and use `<leader>pt`/`<leader>pT` for a project-level overview of work remaining.

---

## Summary

You have now covered the full search and replace landscape in Neovim. Here's what you have in your toolkit:

**For finding things:**
- `/` and `?` for quick in-file search with regex support
- `*` and `#` for instant "search this word" without typing
- `<leader>pg` and `<leader>pws` for project-wide grep
- `<leader>ff` for fuzzy file-name finding

**For replacing things:**
- `:%s/old/new/gc` for in-file replacement with confirmation
- `<leader>ps` and `<leader>pS` for visual project-wide replacement with preview (grug-far)
- `:cfdo %s/old/new/g | update` for batched replacement across many files

**For tracking work:**
- `]t` / `[t` for jumping between TODO comments
- `<leader>pt` / `<leader>pT` for project-level TODO overview

The pattern to remember: start with the right tool for the scope. Single file → `:substitute`. Project-wide search → Snacks grep. Project-wide replace → grug-far. Complex batched operations → quickfix + `:cfdo`.

Each of these tools does one job very well. Learning when to reach for which one is the skill this chapter was designed to build. With practice, the right tool will become obvious for each situation, and you'll find yourself doing refactors in seconds that used to take minutes.

---

*Next chapter: [06 · LSP, Diagnostics, and Code Intelligence →](./06-lsp-diagnostics.md)*
