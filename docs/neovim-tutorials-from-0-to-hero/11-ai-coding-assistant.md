# 11 · AI Coding Assistant

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   ██████╗  ██████╗ ██████╗ ██╗██╗      ██████╗ ████████╗                   ║
║  ██╔════╝ ██╔═══██╗██╔══██╗██║██║     ██╔═══██╗╚══██╔══╝                   ║
║  ██║      ██║   ██║██████╔╝██║██║     ██║   ██║   ██║                      ║
║  ██║      ██║   ██║██╔═══╝ ██║██║     ██║   ██║   ██║                      ║
║  ╚██████╗ ╚██████╔╝██║     ██║███████╗╚██████╔╝   ██║                      ║
║   ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚══════╝ ╚═════╝    ╚═╝                      ║
║                                                                              ║
║     GitHub Copilot · CodeCompanion · Avante · Ollama · the works            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## Table of Contents

1. [Introduction — AI Is a Power Tool, Not a Requirement](#1-introduction)
2. [The Opt-In Philosophy — Why Nothing Loads by Default](#2-the-opt-in-philosophy)
3. [GitHub Copilot — Inline Ghost Text Completions](#3-github-copilot)
4. [CodeCompanion — LLM Chat and Action Palette](#4-codecompanion)
5. [Avante — Cursor-Style Interactive Diffs](#5-avante)
6. [Choosing Between Tools — Decision Guide](#6-choosing-between-tools)
7. [Making It Permanent — Shell Config and Direnv](#7-making-it-permanent)
8. [API Keys and Authentication](#8-api-keys-and-authentication)
9. [Combining Tools — Power User Setup](#9-combining-tools)
10. [Local AI with Ollama — No Cloud, No Cost](#10-local-ai-with-ollama)
11. [Exercises](#11-exercises)

---

## 1. Introduction

Let's start with the honest version of this conversation rather than the
marketing version.

AI coding assistants are genuinely useful. There is a real productivity gain
available when these tools are working well — not because they write correct
code by default, but because they dramatically reduce the cost of the tedious
parts: boilerplate, repetitive patterns, test stubs, docstrings, function
signatures you've typed seventeen hundred times. The best use of AI tooling is
not "write my code for me," it's "skip the parts I already know how to do so I
can spend my mental energy on the parts that actually require thought."

But there's a flip side that a lot of tutorials gloss over, and we're not going
to do that here.

AI tools have startup overhead. They make network requests. They cost money if
you're using a cloud API. They can trigger autocomplete in contexts where you
don't want it. They can slow down your editor. They can create a cognitive
dependency that quietly erodes your ability to think through problems from first
principles. None of these are dealbreakers, but they are real tradeoffs that
deserve honest acknowledgment.

The `de100` config takes a clear position on this: **all three AI plugins are
disabled by default**. Not "disabled with a comment you have to uncomment" — they
are genuinely, completely skipped by lazy.nvim at startup unless you explicitly
tell the environment to load them. If you're working on a project that benefits
from AI assistance, you turn them on. If you're not, or if you're on a machine
without internet access, or if you're just in a flow state and don't want the
noise, they simply don't exist.

This chapter covers all three plugins in detail:

- **copilot.lua** — GitHub Copilot integration, inline ghost text, the familiar
  grey-text-as-you-type experience you may know from VSCode
- **codecompanion.nvim** — a flexible LLM chat and action interface that works
  with Copilot, Claude, OpenAI, Ollama, and more
- **avante.nvim** — a Cursor-style panel that shows diffs and lets you accept
  or reject AI-suggested changes interactively

By the end of this chapter you'll understand not just how to enable each tool,
but when you'd want to, what each one is best at, how to keep API keys out of
your dotfiles, how to use a local Ollama model for privacy-first AI assistance,
and how to combine multiple tools without them stepping on each other.

This is a long chapter because these tools deserve a long treatment. Grab a
coffee and take it one section at a time.

---

## 2. The Opt-In Philosophy

### Why Disabled by Default Makes Sense

If you're coming from VSCode, you're used to extensions loading automatically
every time the editor starts. That's the extension model: install it, and from
that point on it's always there. VSCode manages the performance cost internally
with some lazy loading, but from a user perspective, the extension is "always
on" the moment it's installed.

Neovim with lazy.nvim works differently at a fundamental level. The entire
plugin system is built around the concept of selective loading — you can tell a
plugin to load only when a specific command is run, only when a specific filetype
is opened, only when a specific event fires, or only when a specific condition
is true at startup. That last category is where the AI plugins live.

The condition in this config is an environment variable check:

```lua
-- From dotfiles/.config/nvim/lua/de100/plugins/ai.lua
{
    "zbirenbaum/copilot.lua",
    enabled = vim.env.DE100_ENABLE_COPILOT == "1",
    -- ...
},
{
    "olimorris/codecompanion.nvim",
    enabled = vim.env.DE100_ENABLE_CODECOMPANION == "1",
    -- ...
},
{
    "yetone/avante.nvim",
    enabled = vim.env.DE100_ENABLE_AVANTE == "1",
    -- ...
}
```

The `enabled` field is evaluated once at startup. If it evaluates to `false`,
lazy.nvim doesn't just defer loading — it skips the plugin entirely. No module
registration. No command registration. No event listeners. The plugin might as
well not be installed. This is meaningfully different from "loaded lazily" — a
lazily loaded plugin still registers its commands and event handlers at startup
so it can load when triggered. A disabled plugin registers nothing.

### The Startup Cost Is Real

When Copilot is enabled in VSCode, the extension starts a language server
process in the background. That server handles the communication with GitHub's
API, manages the authentication token, debounces requests as you type, and
streams completions back. It's doing real work, and it consumes real memory —
typically 100-200 MB for the Copilot server process alone, plus network
bandwidth for every completion request.

In Neovim, the situation is similar but more visible because you're closer to
the metal. copilot.lua starts a Node.js process (the same one that powers the
VSCode extension, actually — copilot.lua is a Lua wrapper around the official
Copilot agent) when it initializes. That process needs to be running and
authenticated before you get your first suggestion. On a fast machine with a
good network connection, you won't notice this. On a slow machine, a metered
connection, or an environment where you're SSH'd into a remote server, it
matters.

CodeCompanion and Avante have different overhead profiles. They don't start
background processes until you actually invoke them, but they do load Lua
modules, register commands, set up keybindings, and potentially perform setup
checks at startup. None of this is catastrophically slow, but it all adds up.
A config that starts in 40ms might start in 80ms with all three AI tools
enabled. Whether that matters depends entirely on how often you open Neovim and
for what purpose.

### Not Everyone Has or Wants Copilot

GitHub Copilot requires an active subscription — currently around $10/month for
individuals, more for teams and business. Not every developer has one, not every
employer pays for one, and not every use case justifies the cost. Bundling a
Copilot dependency into a dotfile config by default would mean the config is
broken-looking for anyone without a subscription — they'd see authentication
errors, failed connections, and disabled inline completions every time they
opened the editor. That's a bad default.

The same applies to cloud AI backends for CodeCompanion and Avante. Claude API
access requires an Anthropic account and credit balance. OpenAI requires the
same for GPT-4. These are real costs, and someone sharing a dotfiles repo
shouldn't be implicitly requiring anyone who clones it to have signed up for
several subscription services.

### The VSCode Comparison

VSCode extensions also have the concept of "disabling" — you can right-click an
extension and disable it, either globally or just for the current workspace. But
this is a retroactive action: you install the extension, discover it's causing
problems, and then disable it. The default flow is install-and-load.

Neovim's approach here is inverted: the default is to not load, and you
explicitly opt in. This is philosophically closer to how a minimal Unix system
works — nothing runs unless you start it. For a config that's meant to be used
across multiple machines with potentially different levels of AI tooling access,
this is clearly the right approach.

```
VSCode extension model:
┌─────────────┐    install    ┌────────────────────────────┐
│  Extension  │ ───────────► │  Always loads at startup   │
│  Marketplace│              │  (unless manually disabled) │
└─────────────┘              └────────────────────────────┘

de100 config model:
┌─────────────┐   env var=0  ┌────────────────────────────┐
│  AI Plugin  │ ───────────► │  Completely skipped        │
│  (installed)│              │  (zero startup cost)       │
│             │   env var=1  └────────────────────────────┘
│             │ ───────────► ┌────────────────────────────┐
│             │              │  Loaded and active         │
└─────────────┘              └────────────────────────────┘
```

### How lazy.nvim's `enabled` Field Works

It's worth being precise about what happens mechanically when `enabled = false`.

When lazy.nvim starts, it processes your plugin specs before loading any of them.
The `enabled` field is checked during this processing phase. If `enabled`
evaluates to `false` (or to a function that returns `false`), the plugin is
removed from lazy.nvim's internal plugin table entirely. It won't appear in
`:Lazy` (the plugin manager UI). It won't respond to `:Lazy load pluginname`.
It simply doesn't exist from lazy.nvim's perspective for that Neovim session.

This is subtly different from using `lazy = true` (deferred loading) or
`cond = false` (conditional loading with different semantics). With `enabled`,
you're not just delaying — you're eliminating.

The practical implication: if you set `DE100_ENABLE_COPILOT=1` in your shell
and then start Neovim, Copilot loads. If you then open a new Neovim instance
without that variable set, Copilot doesn't load. The two sessions behave
completely differently, which is exactly what you want when you're switching
between a project that uses AI assistance and a personal project where you
prefer not to have it running.

---

## 3. GitHub Copilot

### copilot.lua vs copilot.vim

There are two official-ish GitHub Copilot integrations for Neovim:

**copilot.vim** — This is the one GitHub ships and officially supports. It's
written in Vimscript, uses Neovim's built-in completion infrastructure, and
shows suggestions as virtual text. It's stable, well-tested, and maintained by
GitHub. The downside is that it doesn't integrate with modern Neovim completion
frameworks like blink-cmp or nvim-cmp.

**copilot.lua** (by zbirenbaum) — This is a Lua rewrite of the Copilot
integration. It uses the same underlying Node.js agent process as copilot.vim
(the official GitHub Copilot agent), but exposes a Lua API that other plugins
can hook into. The big benefit is `copilot-cmp`, a companion plugin that feeds
Copilot suggestions into your completion menu alongside LSP suggestions, snippet
completions, and everything else.

The `de100` config uses copilot.lua. If you're used to Copilot in VSCode showing
up as ghost text that you Tab into, you'll find the same experience here — but
you also get the option to see Copilot suggestions in your completion popup if
you prefer that interface.

### Enabling Copilot

First, set the environment variable:

```bash
export DE100_ENABLE_COPILOT=1
```

Then restart Neovim (or open a new terminal and launch Neovim). The environment
variable is read once at startup, so a running Neovim instance won't pick up
the change — you need a fresh start.

Verify that Copilot loaded by running `:Lazy` and looking for `copilot.lua` in
the list. If the variable is set correctly, you should see it with a loaded or
installed status.

### First-Time Authentication

The first time you enable Copilot, you need to authenticate with GitHub. The
plugin uses the same OAuth device flow as the official GitHub CLI and the
VSCode extension.

Run:

```
:Copilot setup
```

You'll see output like this in the command area (the exact token will differ):

```
First, copy your one-time code: ABCD-1234
Then visit: https://github.com/login/device
Press ENTER to open GitHub in your browser
```

Copy the code, press Enter to open the GitHub device activation page (or open
it manually if your terminal isn't configured to open URLs), paste the code,
authorize the application, and return to Neovim. The plugin will detect the
completed authorization and store the token.

On subsequent starts, the stored token is loaded automatically — you won't need
to repeat this process unless the token expires or is revoked. If you're working
on a machine where you're SSH'd in remotely and can't open a browser, you can:

1. Run `:Copilot setup` locally first to get the device code
2. Open the GitHub device page in a local browser
3. Enter the code and authorize
4. The SSH session's Copilot will detect the authorization

Alternatively, if you've already authenticated on another machine, the token is
typically stored at `~/.config/github-copilot/hosts.json`. You can copy this
file to your new machine to transfer authentication without going through the
flow again, though this approach varies by platform.

### Checking Copilot Status

At any point, you can check whether Copilot is running and connected:

```
:Copilot status
```

The output will tell you:

```
Copilot: Enabled
  GitHub user: your-github-username
  Copilot: Ready
```

Or if something's wrong:

```
Copilot: Enabled
  GitHub user: (not authenticated)
  Copilot: Not authenticated
```

Or if there's a network issue:

```
Copilot: Enabled
  GitHub user: your-github-username
  Copilot: Error (network timeout)
```

These status messages are your first stop when debugging. Common issues:

- **Not authenticated** — run `:Copilot setup` or `:Copilot auth` again
- **Network timeout** — check your internet connection; Copilot requires
  outbound HTTPS to `api.github.com` and `copilot-proxy.githubusercontent.com`
- **Token expired** — GitHub Copilot tokens expire periodically; run
  `:Copilot setup` to reauthenticate

### Inline Ghost Text — The Core Experience

With Copilot running and authenticated, you'll see ghost text suggestions as
you type in insert mode. This is the same experience as VSCode: you start
typing a function, and Copilot suggests a completion in grey text to the right
of your cursor.

```
-- You type this:
function calculate_total(items)

-- Copilot suggests (shown in grey):
function calculate_total(items)
    local total = 0
    for _, item in ipairs(items) do
        total = total + item.price
    end
    return total
end
```

The controls for ghost text:

| Key        | Action                                           |
|------------|--------------------------------------------------|
| `Tab`      | Accept the entire suggestion                     |
| `Ctrl+]`   | Dismiss the current suggestion                   |
| `Alt+]`    | Next suggestion (if multiple are available)      |
| `Alt+[`    | Previous suggestion                              |
| `Ctrl+Alt+]` | Accept word by word (partial accept)           |

Note that `Tab` for accepting suggestions can conflict with other Tab uses in
insert mode — particularly if you have a completion plugin that also uses Tab.
The `de100` config handles this through blink-cmp's keymap configuration, which
prioritizes explicit completion menu navigation over Copilot tab-accept when the
menu is visible, and allows Copilot tab-accept when the menu is closed.

The `auto_trigger = true` setting in `ai.lua` means suggestions appear
automatically as you type, without needing to press any key to request them.
This is the default VSCode behavior. If you find it distracting, you can change
this to `auto_trigger = false` and use `Alt+\` to manually request a suggestion
when you want one.

### The Copilot Panel

Beyond individual inline suggestions, Copilot can show you multiple alternative
completions at once in a split panel:

```
:Copilot panel
```

This opens a panel (typically at the top of the screen) showing several
alternative completions for the code under your cursor. You can browse them and
select the one you want. This is less commonly used than inline suggestions but
useful when you want to see the range of what Copilot thinks you might be doing
— sometimes the second or third suggestion is better than the first.

```
╔═══════════════════════════════════════════════════════════════╗
║  GitHub Copilot                                 Solution 1/5  ║
╠═══════════════════════════════════════════════════════════════╣
║  function calculate_total(items)                              ║
║      local total = 0                                          ║
║      for _, item in ipairs(items) do                          ║
║          total = total + item.price                           ║
║      end                                                      ║
║      return total                                             ║
║  end                                                          ║
╠═══════════════════════════════════════════════════════════════╣
║  [gr] Accept   [Tab] Next   [Shift+Tab] Prev   [q] Close      ║
╚═══════════════════════════════════════════════════════════════╝
```

### copilot-cmp: Suggestions in the Completion Menu

If you also install `copilot-cmp` (or the blink-cmp variant `blink-cmp-copilot`),
Copilot suggestions appear as entries in your completion popup alongside LSP
completions, snippets, and buffer words.

This is a matter of personal preference. Some developers prefer the inline ghost
text approach because it doesn't interrupt your visual flow — the suggestion is
there if you want it, invisible if you don't. Others prefer having everything
in the completion menu because they're already navigating it for LSP completions
and they'd rather have one unified interface.

The `de100` blink-cmp config (see chapter 07) is set up to support this if you
enable Copilot. The Copilot source appears as `copilot` in the source list and
suggestions are marked with a distinct icon so you can distinguish them from LSP
suggestions.

```
┌─────────────────────────────────────────────────────────┐
│  calculate_total    function   [LSP]                     │
│  calculateTax       function   [LSP]                     │
│  calculate_total    ....       [Copilot] ← from Copilot  │
│    local total = 0                                       │
│    for _, item in ipairs(items) do                       │
│      total = total + item.price                          │
└─────────────────────────────────────────────────────────┘
```

### VSCode vs Neovim Copilot Experience

The core behavior is essentially identical — ghost text, Tab to accept, same
underlying AI model. The differences are:

| Aspect | VSCode | Neovim (copilot.lua) |
|--------|--------|----------------------|
| Setup | Extension install, browser auth | Plugin install, `:Copilot setup` |
| Auth persistence | Extension handles it | Stored in `~/.config/github-copilot/` |
| Ghost text | Yes | Yes |
| Panel | Yes (separate view) | Yes (`:Copilot panel`) |
| Completion menu integration | Yes (inline only) | Yes (via copilot-cmp) |
| Multiple suggestions | Yes (Alt+] / Alt+[) | Yes (same keybinds) |
| Startup cost | Extension host process | Node.js copilot agent |
| Can disable per project | Workspace settings | Env var or `:Copilot disable` |

The biggest practical difference is that in VSCode, Copilot is always running
in the background once installed. In Neovim with this config, it only runs when
`DE100_ENABLE_COPILOT=1` is set in the environment — meaning you can have it
for work projects and not have it running when you're doing personal projects
or learning exercises where you want to work things out yourself.

### Troubleshooting Copilot

**Suggestions aren't appearing:**
1. Run `:Copilot status` — is it showing Ready?
2. Are you in a filetype Copilot supports? (It works for most, but has a list)
3. Is `auto_trigger = true` in your config? If not, press `Alt+\` to request
4. Has the buffer been modified? Ghost text appears after a short debounce delay

**Auth errors after it was working:**
GitHub Copilot tokens expire. Run `:Copilot setup` to reauthenticate.

**Node.js errors at startup:**
copilot.lua requires Node.js 18+. Run `node --version` to check. If you're on
an older version, update Node.js.

**Suggestions are very slow:**
This is almost always a network issue. Copilot completions go through GitHub's
proxy servers, and latency on those requests directly determines how quickly
suggestions appear. On a fast connection you'll see suggestions within 200-500ms.
On a slow or congested connection it can be several seconds.

---

## 4. CodeCompanion

### What CodeCompanion Is

CodeCompanion is the most flexible of the three AI tools in this config. Rather
than focusing on inline autocomplete (that's Copilot's job), CodeCompanion
provides:

1. **A chat interface** — a Markdown-formatted buffer where you have a
   conversation with an AI model about your code
2. **An action palette** — a menu of pre-defined actions like "explain this
   code," "generate tests," "refactor for clarity," "fix this bug"
3. **An inline assistant** — the ability to ask for changes directly in your
   source file and have them applied
4. **Context management** — tools for including specific files, buffers, or
   code selections in your AI conversations

The key advantage over Copilot is **backend flexibility**. Copilot is locked to
GitHub's AI (which is GPT-4 under the hood, with some Microsoft/GitHub
customization). CodeCompanion can be configured to use:

- GitHub Copilot (if you have it, you can reuse the same auth)
- Anthropic Claude (Claude 3.5 Sonnet, Claude 3 Opus, etc.)
- OpenAI (GPT-4o, GPT-4, GPT-3.5-turbo)
- Google Gemini
- Ollama (local models — covered in section 10)
- Any API-compatible endpoint

This means if you have a Claude API key but not a Copilot subscription, or if
you prefer GPT-4 for certain tasks, CodeCompanion handles that without requiring
you to switch tools.

### Enabling CodeCompanion

```bash
export DE100_ENABLE_CODECOMPANION=1
```

Restart Neovim. The three commands become available:

```
:CodeCompanion          # context-aware: if text selected, send it; otherwise chat
:CodeCompanionChat      # open/focus the chat buffer
:CodeCompanionActions   # open the action palette
```

### The Chat Interface

`:CodeCompanionChat` opens a new buffer formatted as Markdown. This buffer is
your conversation with the AI. Type your question, send it (by default
`Ctrl+Enter` or a configured keymap), and the response streams in below your
message.

```
╔══════════════════════════════════════════════════════════════════╗
║  codecompanion://chat                                            ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  ## Me                                                           ║
║                                                                  ║
║  Why would a Lua table behave like both an array and a           ║
║  dictionary? I keep seeing ipairs vs pairs and I'm confused.     ║
║                                                                  ║
║  ## CodeCompanion (Claude)                                       ║
║                                                                  ║
║  Great question! In Lua, tables are the single universal data    ║
║  structure — they serve as arrays, dictionaries, objects, and    ║
║  namespaces all at once...                                       ║
║                                                                  ║
║  [streaming...]                                                  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

The chat buffer is a real Neovim buffer — you can navigate it with all your
normal motions, yank text from it, search within it, and so on. It persists
until you close it, so you can return to a conversation and continue it.

Multiple chat buffers are supported. Each `:CodeCompanionChat` call opens a new
chat session (or focuses the existing one, depending on configuration). You can
have one chat about your authentication system and another about a data
processing pipeline, and switch between them like regular buffers.

### The Action Palette

`:CodeCompanionActions` opens a floating menu of pre-built actions:

```
┌─────────────────────────────────────────────────────┐
│  CodeCompanion Actions                               │
├─────────────────────────────────────────────────────┤
│  > Explain code                                      │
│    Generate unit tests                               │
│    Fix code                                          │
│    Refactor code                                     │
│    Add documentation                                 │
│    Code review                                       │
│    Generate commit message                           │
│    Explain LSP diagnostics                           │
│    Custom prompt...                                  │
└─────────────────────────────────────────────────────┘
```

Navigate with `j`/`k`, select with `Enter`. When you select an action,
CodeCompanion takes the current context (the buffer you were in, any selected
text, possibly the current diagnostic error) and sends it to the AI with an
appropriate prompt.

For example, if you position your cursor on a function and select "Explain code,"
CodeCompanion sends the entire function to the AI with a prompt like "Explain
what this code does, step by step." The response appears in a chat buffer.

If you have text selected in visual mode when you open the action palette, the
action applies to the selected text rather than the entire buffer. This is how
you ask "explain just this block" rather than "explain the entire file."

### Visual Mode Context — The Most Useful Pattern

Here's the workflow you'll use constantly once you get used to it:

1. Navigate to the code you want to discuss
2. Select it in visual mode: `V` for line selection, `v` for character,
   `Ctrl+V` for block
3. Run `:CodeCompanionChat` (or `:CodeCompanionActions`)
4. The selected code is included as context in your message

This is the equivalent of the VSCode Copilot Chat "explain this" right-click
menu option, but more powerful because you can select exactly the code you want
to ask about and then frame the question in any way you like.

Example workflow:

```
# You're looking at a gnarly regex in some legacy code:

local pattern = "^(%d+)%.(%d+)%.(%d+)%.(%d+)$"

# Step 1: Select the line with V
# Step 2: :CodeCompanionChat
# Step 3: Type "What does this pattern match and can you break down
#          each capturing group?"
# Step 4: Ctrl+Enter to send
```

The AI response will be in the context of that exact code, which it can see
because you included it as context.

### Inline Assistant

Beyond the chat buffer, CodeCompanion can make changes directly in your source
file. The exact behavior depends on the adapter (AI backend) configured, but
the general pattern is:

1. Position cursor where you want changes, or select code to modify
2. Invoke the inline assistant (configured keymap or `:CodeCompanion` when text
   is not selected defaults to inline mode in some configurations)
3. Type your instruction: "convert this to use a functional style" or "add
   error handling for nil inputs"
4. The change appears in the buffer for you to review

This is less polished than Avante's diff-based workflow (which we'll cover in
section 5), but it works for quick, targeted changes.

### Configuring the Adapter (AI Backend)

The default adapter in most CodeCompanion installations is Copilot (if
available) or a configured cloud API. You can change this in your opts:

```lua
-- In ai.lua or a separate codecompanion config:
{
    "olimorris/codecompanion.nvim",
    enabled = vim.env.DE100_ENABLE_CODECOMPANION == "1",
    opts = {
        adapters = {
            -- Use Claude as the primary chat backend
            chat = require("codecompanion.adapters").extend("anthropic", {
                env = {
                    api_key = "ANTHROPIC_API_KEY"
                },
                schema = {
                    model = {
                        default = "claude-3-5-sonnet-20241022"
                    }
                }
            }),
            -- Use Ollama for inline operations (faster, no cost)
            inline = require("codecompanion.adapters").extend("ollama", {
                schema = {
                    model = {
                        default = "codellama:latest"
                    }
                }
            })
        }
    }
}
```

The adapter system allows mixing backends: use Claude for complex chat
conversations where quality matters, and use a local Ollama model for quick
inline edits where latency matters more than quality. This is a genuinely
powerful feature that has no equivalent in VSCode's extension model.

### Slash Commands Within Chat

Inside a chat buffer, CodeCompanion supports slash commands that add context:

| Command | What It Does |
|---------|-------------|
| `/buffer` | Include a specific buffer's contents |
| `/file` | Include a file from the filesystem |
| `/symbols` | Include LSP symbol information |
| `/terminal` | Include the last terminal output |
| `/help` | Show available commands |
| `/clear` | Start a new conversation |

Example: you're debugging a test failure. You want to include both the test
file and the implementation file in your question:

```
## Me

/file src/auth/validator.ts
/file tests/auth/validator.test.ts

These tests are failing with "TypeError: Cannot read property 'userId'
of undefined". Looking at both files, can you explain why?
```

CodeCompanion will attach both files as context before sending to the AI,
giving it the full picture it needs to give useful advice.

### Use Cases Where CodeCompanion Shines

**Understanding unfamiliar codebases:** Open a file, select 50 lines of legacy
code, and ask CodeCompanion to explain it. This beats Google searching for
obscure patterns or waiting for a colleague to be available.

**Generating tests:** Select a function, invoke "Generate unit tests," and get
a skeleton of test cases covering the happy path and edge cases. You'll still
need to review and modify them — AI-generated tests often miss business logic
edge cases — but the skeleton is usually worth having.

**Explaining error messages:** Select an LSP diagnostic or paste a stack trace
and ask "what is causing this and what are possible fixes?" This is particularly
useful for type errors in TypeScript or ownership errors in Rust where the
error message is correct but cryptic.

**Writing documentation:** Select a function or module, ask for docstring
generation. The AI is quite good at this for code it can understand.

**Code review prep:** Before submitting a PR, ask CodeCompanion to review a
diff or a file for obvious issues. It won't catch everything a human reviewer
will, but it often catches things you missed in your own review blindness.

### VSCode Comparison

CodeCompanion is closest to GitHub Copilot Chat in VSCode, but with more
flexibility:

| Feature | VSCode Copilot Chat | CodeCompanion |
|---------|---------------------|---------------|
| Chat interface | Side panel | Neovim buffer (native) |
| AI backend | GitHub Copilot (GPT-4) only | Copilot, Claude, OpenAI, Ollama, etc. |
| Action palette | Yes | Yes |
| Context inclusion | @file, @workspace | /file, /buffer, /symbols |
| Inline changes | Yes (inline chat) | Yes |
| Streaming responses | Yes | Yes |
| Multiple backends at once | No | Yes (different per operation type) |
| Works offline | No | Yes (with Ollama) |
| Per-project config | Workspace settings | Lua config, env vars |

The headline difference is backends. VSCode Copilot Chat is locked to GitHub's
infrastructure. CodeCompanion lets you use whichever LLM you have access to —
which means if you're a Claude user, or your organization uses Azure OpenAI,
or you want a completely local solution for proprietary code, CodeCompanion
handles all of those.

---

## 5. Avante

### What Avante Is

Avante takes a different approach to AI assistance than the previous two tools.
Instead of inline ghost text (Copilot) or a chat buffer (CodeCompanion), Avante
implements a **Cursor-style interactive diff workflow**.

If you've used Cursor (the AI-first code editor forked from VSCode), you know
the interaction pattern: you select code or describe what you want, the AI
generates a suggestion, and you see the diff before it's applied. You can accept
the entire change, accept individual hunks, reject everything, or modify the
suggestion before accepting.

This is meaningfully different from CodeCompanion's inline assistant. With
CodeCompanion, changes are often applied directly and you undo if you don't
want them. With Avante, the diff is shown first, and you make an explicit
accept/reject decision for each change. This is a safer workflow for larger
refactors where you want to review exactly what's changing before committing.

### Why Avante Needs a Build Step

You'll notice this in the `ai.lua` spec:

```lua
{
    "yetone/avante.nvim",
    enabled = vim.env.DE100_ENABLE_AVANTE == "1",
    event = "VeryLazy",
    build = "make",
    -- ...
}
```

The `build = "make"` tells lazy.nvim to run `make` in the plugin directory after
installation. This is unusual — most Neovim plugins are pure Lua and need no
compilation. Avante is different because parts of it are written in Rust.

Specifically, Avante includes a Rust-based component for efficient diff
computation and display. Rust gives it better performance for computing and
rendering large diffs than a pure Lua implementation could achieve. But it means
the plugin can't just be cloned from GitHub and used — it needs to be compiled
first.

When you first install Avante (or when it updates), lazy.nvim will run `make`
in the plugin directory. You'll see this either as a notification or in the
lazy.nvim log. The build takes 15-60 seconds depending on your machine's Rust
compilation speed. If you don't have Rust installed, the build will fail — in
that case, install Rust via `rustup` and then run `:Lazy build avante.nvim` to
try again.

```
Build process when first loading avante.nvim:
┌─────────────────────────────────────────────────────────┐
│  lazy.nvim detects build = "make"                        │
│         │                                                │
│         ▼                                                │
│  cd ~/.local/share/nvim/lazy/avante.nvim                 │
│  make                                                    │
│         │                                                │
│         ▼                                                │
│  cargo build --release                                   │
│  (compiles Rust components)                              │
│         │                                                │
│         ▼                                                │
│  Outputs: lua/avante/diff.so (shared library)            │
│         │                                                │
│         ▼                                                │
│  Avante now loads and functions                          │
└─────────────────────────────────────────────────────────┘
```

If the build fails silently and Avante seems to load but doesn't work correctly,
check the lazy.nvim log (`:Lazy log`) for build errors.

### Enabling Avante

```bash
export DE100_ENABLE_AVANTE=1
```

Restart Neovim. On first load (if not already installed), lazy.nvim will
download Avante, run the build, and then load it. Subsequent starts will be
faster since the compiled artifacts are cached.

The `event = "VeryLazy"` in the spec means Avante loads after Neovim is fully
started, not during startup. This prevents the build check and initialization
from affecting your startup time.

### Configuring the AI Provider

Before Avante is useful, you need to configure which AI provider it should use.
Add this to your Avante opts:

```lua
{
    "yetone/avante.nvim",
    enabled = vim.env.DE100_ENABLE_AVANTE == "1",
    event = "VeryLazy",
    build = "make",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons"
    },
    opts = {
        provider = "claude",  -- or "openai", "copilot", "gemini"
        claude = {
            endpoint = "https://api.anthropic.com",
            model = "claude-3-5-sonnet-20241022",
            temperature = 0,
            max_tokens = 4096,
        },
    }
}
```

For OpenAI:

```lua
opts = {
    provider = "openai",
    openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o",
        temperature = 0,
        max_tokens = 4096,
    }
}
```

API keys are read from environment variables (`ANTHROPIC_API_KEY`,
`OPENAI_API_KEY`) — more on that in section 8.

### :AvanteAsk — Understanding Code

With your cursor in a buffer, run:

```
:AvanteAsk
```

A floating input prompt appears at the bottom of the screen. Type your question
about the current code:

```
What does the authentication middleware do and what security assumptions does it make?
```

Avante sends the relevant code context (the file, or selected code if you had a
selection) along with your question to the AI. The response appears in a panel
on the right side of the screen.

```
┌─────────────────────────────┬──────────────────────────────────┐
│                             │  Avante                          │
│  // src/middleware/auth.ts  │                                  │
│                             │  The authentication middleware   │
│  export const authMiddle    │  validates JWT tokens using the  │
│  ware = async (req, res,    │  HS256 algorithm. Key security   │
│  next) => {                 │  assumptions:                    │
│    const token = req.hea    │                                  │
│    ders.authorization?.s    │  1. The JWT_SECRET env var is    │
│    plit(' ')[1];             │     set and kept confidential   │
│    if (!token) return re    │  2. Tokens expire (claims.exp)   │
│    s.status(401).json({..   │  3. No token revocation logic    │
│  };                         │     exists — revoked tokens are  │
│                             │     accepted until expiry        │
│                             │                                  │
└─────────────────────────────┴──────────────────────────────────┘
```

This is a read-only operation — Avante is explaining, not modifying.

### :AvanteEdit — The Diff Workflow

This is where Avante's real value lies. Position your cursor in a buffer (or
select code in visual mode), then run:

```
:AvanteEdit
```

A floating prompt appears. Describe what change you want:

```
Refactor this function to use async/await instead of Promise chains
```

Avante sends the code and your instruction to the AI, receives the suggested
edit, computes a diff, and shows you the result in a side-by-side panel:

```
┌─────────────────────────────┬──────────────────────────────────┐
│  ORIGINAL                   │  SUGGESTED                       │
│  ─────────────────────────  │  ────────────────────────────── │
│  function fetchUser(id) {   │  async function fetchUser(id) {  │
│    return db.users          │    const user = await           │
│      .findOne(id)            │      db.users.findOne(id);      │
│      .then(user => {         │    if (!user) {                 │
│        if (!user) {          │      throw new Error(           │
│          throw new Error(    │        'User not found'         │
│            'User not found'  │      );                         │
│          );                  │    }                            │
│        }                     │    return user;                 │
│        return user;          │  }                              │
│      })                      │                                 │
│      .catch(err => {         │  [lines removed]                │
│        logger.error(err);    │                                 │
│        throw err;            │                                 │
│      });                     │                                 │
│  }                           │                                 │
└─────────────────────────────┴──────────────────────────────────┘
  [A] Accept all   [R] Reject all   [Tab] Next hunk   [Shift+Tab] Prev hunk
```

The key interactions in the diff panel:

| Key | Action |
|-----|--------|
| `a` or `A` | Accept all changes |
| `r` or `R` | Reject all changes |
| `Tab` | Jump to next diff hunk |
| `Shift+Tab` | Jump to previous diff hunk |
| `a` on a hunk | Accept just this hunk |
| `r` on a hunk | Reject just this hunk |
| `q` | Close the panel without accepting |

The hunk-by-hunk accept/reject is the most powerful feature. If the AI made
three changes and two are good but one is wrong, you can accept the two good
ones and reject the problematic one. This is much better than "accept all or
undo everything."

### When Avante Shines

Avante is best for:

**Structured refactors** — when you know what you want the code to look like
conceptually and you want help with the mechanical transformation. Converting
callback-style to async/await, refactoring class-based components to functional,
extracting repeated logic into utilities — these are cases where the diff
workflow is genuinely valuable.

**Large targeted changes** — editing several related lines across a function.
The diff view makes it easy to verify the change is scoped correctly.

**Learning from transformations** — the diff view is educational. If you ask
"convert this to idiomatic Rust" and watch what changes, you learn something
about Rust idioms from the diff, not just from the final result.

**Review before commit** — some people use Avante as a final review step,
asking "are there any obvious issues with this code" before committing, and
reviewing the AI's diff suggestion to decide what to fix.

### When Avante Is Overkill

For quick, small changes, the overhead of the diff panel isn't worth it. If
you just want to add a docstring to a function, copilot.lua's ghost text or
CodeCompanion's action palette is faster. Avante's compilation requirement and
heavier UI are appropriate for its use case — complex, reviewable transformations
— but overkill for small changes.

### VSCode Cursor Comparison

Cursor is an editor (not a plugin) built on VSCode's codebase with deep AI
integration as its primary selling point. The Avante workflow is a Neovim
implementation of Cursor's core interaction pattern.

| Feature | Cursor | Avante |
|---------|--------|--------|
| Inline edit with diff | Yes | Yes |
| Accept/reject hunks | Yes | Yes |
| Provider flexibility | Limited | Claude, GPT-4, Gemini, etc. |
| Works in existing editor | N/A (is the editor) | Yes (Neovim plugin) |
| Compile required | No | Yes (Rust components) |
| Keyboard-centric workflow | Partial | Full (Neovim) |

The philosophical difference: Cursor assumes AI assistance is the default mode
of operation — the entire editor is designed around it. Avante assumes Neovim
is your editor and AI assistance is a feature you invoke when it's useful.
For developers who want full control over when and how AI is involved, Avante's
approach is actually preferable.

---

## 6. Choosing Between Tools

This is the section most people actually need. All three tools are installed in
this config, which naturally raises the question: when do I use which?

### The Mental Model

Think of the three tools as operating at different levels of granularity and
interactivity:

```
AI Tool Selection Framework:

  ┌─────────────────────────────────────────────────────────┐
  │                                                          │
  │   GRANULARITY                                            │
  │   Fine ◄─────────────────────────────────► Coarse        │
  │                                                          │
  │                                                          │
  │   Copilot     CodeCompanion        Avante               │
  │   (tokens)    (paragraphs)         (diffs)              │
  │      │              │                  │                 │
  │  autocomplete    discuss/ask       show diff             │
  │  as you type     about code        review it            │
  │                                    accept/reject         │
  │                                                          │
  └─────────────────────────────────────────────────────────┘
```

**Copilot** operates at the token/line level. It watches what you type and
suggests what comes next. It's reactive — it responds to your typing, not to
explicit requests. It's fast, unintrusive when it's right, and easy to dismiss
when it's wrong.

**CodeCompanion** operates at the conversation level. You ask it things, it
explains, suggests, and generates. The interaction is explicit — you initiate
it with a command. Best for understanding, exploration, and generating
substantial amounts of code from a high-level description.

**Avante** operates at the diff level. It shows you exactly what would change
and requires your explicit approval before anything is modified. Best for
reviewing and applying structured transformations.

### Decision Guide

**Situation: I'm writing a function I've written variants of before**
→ Use **Copilot**. Ghost text will suggest the body after you type the signature.

**Situation: I don't understand this code I'm looking at**
→ Use **CodeCompanion**. Select the code, open chat, ask your question.

**Situation: I want to refactor this function but don't want to break anything**
→ Use **Avante**. Ask for the refactor, review the diff hunk by hunk, accept
  what looks right.

**Situation: I want to generate a full test file for this module**
→ Use **CodeCompanion**. "Generate tests" action with the module file as context.
  You'll probably iterate a few times in the chat.

**Situation: I'm writing boilerplate (CRUD endpoints, form validation, etc.)**
→ Use **Copilot**. It's very good at boilerplate patterns.

**Situation: I want to convert this synchronous code to async**
→ Use **Avante**. This is exactly the structured refactor scenario where diffs
  are valuable.

**Situation: I'm stuck on a weird error and need to explain it**
→ Use **CodeCompanion**. Paste the error (or use `:CodeCompanionActions` →
  "Explain LSP diagnostics"), and have a conversation about it.

**Situation: I'm in a flow state and want minimal distraction**
→ Use **Copilot only** (or disable all three). Ghost text is the least
  disruptive because it doesn't require explicit commands or panels.

**Situation: I'm working with proprietary code and can't send it to cloud APIs**
→ Use **CodeCompanion with Ollama** backend. Fully local, no data leaves your
  machine.

### Do They Conflict?

Mostly no. The three tools serve different purposes and different interaction
modes, so they don't generally step on each other.

The one area of potential overlap: if both Copilot and CodeCompanion are enabled
and you're using CodeCompanion with a Copilot adapter, you're paying for two
things that could just be one. In that scenario, you might want Copilot for
inline completions and CodeCompanion configured with a different backend (Claude,
Ollama) for chat — using Copilot's underlying API twice is redundant.

Keyboard conflicts are possible if the three tools register keybindings that
clash. The `de100` config's defaults try to avoid this, but if you customize
keybindings for any of the three, check for collisions with `:verbose map
<key>`.

### Feature Comparison Table

| Feature | Copilot | CodeCompanion | Avante |
|---------|---------|---------------|--------|
| Inline ghost text | Yes | No | No |
| Chat interface | No | Yes | Partial |
| Action palette | No | Yes | No |
| Diff preview before applying | No | No | Yes |
| Hunk-level accept/reject | No | No | Yes |
| Multiple AI backends | No | Yes | Yes |
| Local AI (Ollama) | No | Yes | Yes |
| Works without internet | No | With Ollama | With local |
| Subscription required | Yes (Copilot) | Depends on backend | Depends |
| Compile required | No | No | Yes (Rust) |
| Startup cost | Medium (Node.js) | Low | Low (VeryLazy) |
| Best for | Autocomplete | Chat + exploration | Structured refactors |
| VSCode equivalent | Copilot inline | Copilot Chat | Cursor |

---

## 7. Making It Permanent

### Adding Environment Variables to Your Shell Config

Setting `export DE100_ENABLE_COPILOT=1` in a terminal only affects that
terminal session. When you close it and open a new one, the variable is gone.
To make it permanent, add the export to your shell's initialization file.

For zsh (`.zshrc`):

```bash
# Open your .zshrc
nvim ~/.zshrc

# Add at the bottom (or in your "environment variables" section):
export DE100_ENABLE_COPILOT=1
export DE100_ENABLE_CODECOMPANION=1
# export DE100_ENABLE_AVANTE=1  # Uncomment if you want Avante

# Save, then reload without restarting the terminal:
source ~/.zshrc
```

For bash (`.bashrc` or `.bash_profile`):

```bash
nvim ~/.bashrc

# Add exports:
export DE100_ENABLE_COPILOT=1
export DE100_ENABLE_CODECOMPANION=1

source ~/.bashrc
```

After sourcing, open a new Neovim instance and verify the tools loaded:

```
:Lazy
```

You should see copilot.lua and codecompanion.nvim in the loaded plugins list.

### The source Command and Why You Need It

When you run `export VARIABLE=value` at a terminal prompt, that assignment
lives in the current shell process's environment. Child processes inherit it.
But your shell configuration file (`.zshrc`) is only processed when a new shell
starts — it's not continuously monitored.

When you edit `.zshrc` and want the changes to take effect immediately, you run:

```bash
source ~/.zshrc
```

This re-runs `.zshrc` in the current shell process, which applies any new
exports (and any other configuration changes) to the current session. Without
sourcing, you'd need to close the terminal and open a new one.

One subtlety: `source` re-runs the entire file, including any `PATH` additions.
If your `.zshrc` adds directories to `PATH`, running `source` multiple times
can duplicate those entries. This is usually harmless but can slow down command
lookups in extreme cases. Most people's `.zshrc` files are written carefully
enough to avoid this (using conditionals like `if [[ ":$PATH:" != *":$dir:"* ]]`
before appending).

### Per-Project Enabling with direnv

The real power of the environment variable approach emerges when you combine it
with `direnv`, a shell extension that automatically loads and unloads environment
variables when you enter or leave a directory.

Install direnv if you don't have it:

```bash
# Ubuntu/Debian
sudo apt install direnv

# macOS with Homebrew
brew install direnv

# Arch Linux
sudo pacman -S direnv
```

Hook it into your shell (add to `.zshrc` or `.bashrc`):

```bash
# .zshrc
eval "$(direnv hook zsh)"

# .bashrc
eval "$(direnv hook bash)"
```

Now, in any project where you want AI tools enabled, create a `.envrc` file:

```bash
# /your/project/.envrc

# Enable AI tools for this project
export DE100_ENABLE_COPILOT=1
export DE100_ENABLE_CODECOMPANION=1

# Also set any API keys for this project
export ANTHROPIC_API_KEY="sk-ant-..."
```

Then authorize the `.envrc` file with direnv:

```bash
cd /your/project
direnv allow
```

Now, when you `cd` into that directory, direnv automatically loads those
environment variables. When you `cd` out, they're unloaded. If you open Neovim
from within the project directory, the AI tools will be enabled. If you open
Neovim from your home directory or another project, they won't be.

```
Terminal session:

  ~/personal-project $ nvim .          # No AI (no .envrc)
  ~/personal-project $ cd ../work-project
  direnv: loading ~/work-project/.envrc
  direnv: export +DE100_ENABLE_COPILOT +ANTHROPIC_API_KEY
  ~/work-project $ nvim .              # Copilot + CodeCompanion active
  ~/work-project $ cd ..
  direnv: unloading
  ~/$ nvim .                           # No AI again
```

This workflow is particularly valuable for:

- **Projects with different AI subscriptions** — work project uses Copilot,
  personal project uses Ollama locally
- **Privacy-sensitive code** — projects where you don't want code sent to any
  cloud API get no `.envrc` and therefore no AI
- **Different AI backends per project** — a TypeScript project might use Copilot
  while a Rust project uses a model that's better at Rust

### The Ansible Playbook Approach

Since this is an Ansible-managed dotfiles repo, there's a cleaner way to manage
`.zshrc` additions than manually editing the file: the playbook can handle it.

If you want the AI environment variables managed as part of your dotfile
deployment, they can be added to the shell configuration templates or task files.
The benefit: the same variable settings (or lack thereof) are applied
consistently across every machine you run the playbook on.

For variables that differ per machine (like API keys that are secret), you'd use
Ansible vault or host_vars to set them per host, rather than hardcoding in the
playbook. See the ansible configuration in this repo for how secrets are handled.

---

## 8. API Keys and Authentication

### GitHub Copilot — OAuth, No API Key Needed

Copilot is unusual among the three tools in that it uses OAuth rather than API
keys. When you run `:Copilot setup`, you authenticate with your GitHub account
directly. GitHub issues a token that's stored locally in `~/.config/github-copilot/hosts.json`.

There's no API key to manage or protect. The token is tied to your GitHub
account and Copilot subscription. If someone else gets that token file, they
can make Copilot API calls that count against your subscription's usage limits,
so the file shouldn't be publicly readable, but it's not as sensitive as an API
key that could incur unlimited charges.

The token does expire periodically. When it does, `:Copilot status` will show
"Not authenticated" and you run `:Copilot setup` again to re-authenticate.

### CodeCompanion with Anthropic Claude

To use Claude as a CodeCompanion backend, you need an Anthropic API key.

1. Go to [console.anthropic.com](https://console.anthropic.com)
2. Create an account and add billing information
3. Navigate to API Keys and create a new key
4. Copy the key (it starts with `sk-ant-`)

Set it in your environment:

```bash
export ANTHROPIC_API_KEY="sk-ant-api03-..."
```

CodeCompanion's Anthropic adapter reads this environment variable automatically.
Costs are per-token: at the time of writing, Claude 3.5 Sonnet costs
approximately $3 per million input tokens and $15 per million output tokens.
For typical chat use, this is a few cents per session — rarely more than a
dollar or two per month for normal development use.

Configure the adapter to use Claude:

```lua
opts = {
    strategies = {
        chat = {
            adapter = "anthropic"
        },
        inline = {
            adapter = "anthropic"
        }
    },
    adapters = {
        anthropic = require("codecompanion.adapters").extend("anthropic", {
            schema = {
                model = {
                    default = "claude-3-5-sonnet-20241022"
                }
            }
        })
    }
}
```

### CodeCompanion with OpenAI

Same pattern, different key and adapter:

```bash
export OPENAI_API_KEY="sk-..."
```

```lua
opts = {
    strategies = {
        chat = { adapter = "openai" }
    },
    adapters = {
        openai = require("codecompanion.adapters").extend("openai", {
            schema = {
                model = { default = "gpt-4o" }
            }
        })
    }
}
```

OpenAI pricing is similar to Anthropic's and varies by model. GPT-4o is
typically more expensive than GPT-3.5-turbo but significantly more capable for
code tasks.

### CodeCompanion with Ollama — No Key Needed

Ollama runs locally. No API key, no account, no charges. The Ollama adapter
just needs a running Ollama server (which runs on `localhost:11434` by default):

```lua
opts = {
    strategies = {
        chat = { adapter = "ollama" },
        inline = { adapter = "ollama" }
    },
    adapters = {
        ollama = require("codecompanion.adapters").extend("ollama", {
            schema = {
                model = { default = "codellama:latest" }
            }
        })
    }
}
```

Ollama is covered in detail in section 10.

### Avante API Keys

Avante reads API keys from the same environment variables:

- Claude: `ANTHROPIC_API_KEY`
- OpenAI: `OPENAI_API_KEY`
- Gemini: `GEMINI_API_KEY`

The provider configured in `opts.provider` determines which variable it looks
for. You don't need to configure the key path separately — it just reads the
standard environment variable for the configured provider.

### Storing Keys Securely — What NOT to Do

The most common mistake with API keys in dotfiles is committing them to version
control. Never do this. Even if the repository is private, keys in git history
are a security risk: the repo might become public later, collaborators might
have access, the hosting service might be compromised.

Specifically:

```bash
# WRONG: Do not do this
# .zshrc committed to your dotfiles repo:
export ANTHROPIC_API_KEY="sk-ant-api03-actualkey123..."

# WRONG: Do not do this
# ai.lua committed to your dotfiles repo:
opts = {
    adapters = {
        anthropic = require("...").extend("anthropic", {
            env = { api_key = "sk-ant-api03-actualkey123..." }
        })
    }
}
```

Safer approaches:

**Option 1: Environment variables set outside the dotfiles repo**
Keep your `.zshrc` template in the dotfiles repo without the actual key values.
On each machine, manually add the real values to `~/.zshrc.local` or similar:

```bash
# .zshrc (in dotfiles repo, safe to commit):
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# .zshrc.local (NOT in dotfiles repo, has actual keys):
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
```

**Option 2: A secrets file outside the repo**
Create a separate file that's not tracked by any git repository:

```bash
# ~/.config/ai-secrets (NOT in any git repo)
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
```

```bash
# .zshrc (in dotfiles repo, safe to commit):
[[ -f ~/.config/ai-secrets ]] && source ~/.config/ai-secrets
```

**Option 3: A password manager or secrets manager**
Tools like `1Password CLI`, `pass`, or `secret-tool` can provide keys on demand:

```bash
# .zshrc:
# Fetch key from 1Password when shell starts
export ANTHROPIC_API_KEY="$(op read 'op://Personal/Anthropic API Key/credential')"
```

This approach requires the password manager to be unlocked when your shell
starts, which can be annoying if the manager requires a password. But it's the
most secure option for keys that need to be rotated regularly.

**Option 4: direnv with .envrc outside the repo**
If using direnv, `.envrc` files can be per-project and not included in the
project's `.gitignore`. The project's `.gitignore` should explicitly exclude
`.envrc` if the project repo is not the dotfiles repo:

```bash
# In your project's .gitignore:
.envrc

# In your project's .envrc (not committed):
export ANTHROPIC_API_KEY="sk-ant-..."
```

The `direnv allow` command requires explicit re-authorization whenever `.envrc`
changes, which also helps prevent malicious `.envrc` files from executing code
if someone sneaks one into a repository you cloned.

---

## 9. Combining Tools — Power User Setup

### The Recommended Combination

After spending time with all three tools, most developers settle on a combination
rather than one tool exclusively. The most common combination that makes sense:

**Copilot (inline) + CodeCompanion (chat, Claude or Ollama backend)**

This gives you:
- Ghost text autocomplete for the flow state / repetitive code scenarios
- A flexible chat interface with the best available AI for complex questions
- No redundancy (Copilot handles inline, CodeCompanion handles chat)
- Lower cost than using three cloud AI subscriptions simultaneously

```bash
# .envrc or .zshrc for a project using this combo:
export DE100_ENABLE_COPILOT=1
export DE100_ENABLE_CODECOMPANION=1
# DE100_ENABLE_AVANTE not set -- not needed for this workflow
```

**Copilot + Avante (no CodeCompanion)**

If your primary need is inline completions and structured refactors, and you
prefer Avante's diff workflow over CodeCompanion's chat interface:

```bash
export DE100_ENABLE_COPILOT=1
export DE100_ENABLE_AVANTE=1
# DE100_ENABLE_CODECOMPANION not set
```

**All three**

All three can run simultaneously without fundamental conflicts. The main
consideration is memory and startup time:

- Copilot adds a Node.js process (~100-200 MB)
- CodeCompanion adds Lua module overhead (minimal, ~5-10 MB)
- Avante loads with `VeryLazy` (minimal startup impact, ~10-20 MB after load)

On a modern machine with 16+ GB RAM, this is irrelevant. On a constrained
machine (a cheap VPS, a low-end laptop), you might care.

### Turning Tools On/Off Per Project with direnv

The power user workflow with direnv involves maintaining different `.envrc` files
per project category:

```bash
# ~/work/client-a/.envrc
# High-value client: we pay for Copilot and Claude
export DE100_ENABLE_COPILOT=1
export DE100_ENABLE_CODECOMPANION=1
export ANTHROPIC_API_KEY="$(cat ~/.secrets/anthropic-key)"
direnv allow

# ~/work/client-b/.envrc
# Different client: uses Azure OpenAI via their API
export DE100_ENABLE_CODECOMPANION=1
export OPENAI_API_KEY="$(cat ~/.secrets/azure-openai-key)"
export OPENAI_API_BASE="https://client-b.openai.azure.com/"

# ~/personal/learning-rust/.envrc
# Learning project: Ollama only (local, no cost, no privacy concern)
export DE100_ENABLE_CODECOMPANION=1
# No ANTHROPIC_API_KEY -- Ollama adapter used

# ~/personal/katas/.envrc
# Deliberate practice: no AI assistance
# (empty .envrc, or no .envrc at all)
```

This per-directory configuration means opening Neovim in any of these directories
gives you exactly the AI tooling appropriate for that context, automatically,
without any manual switching.

### Performance Considerations

When all three tools are running:

**Memory:** Expect 200-400 MB total additional memory compared to Neovim without
AI tools. This is dominated by the Copilot Node.js process. CodeCompanion and
Avante are much lighter.

**CPU:** Minimal at idle. Copilot does fire requests as you type (debounced),
which involves network I/O but minimal CPU. CodeCompanion and Avante only do
work when explicitly invoked.

**Network:** Copilot is the only tool that makes network requests continuously
(debounced by typing, but frequent during active editing). CodeCompanion and
Avante only hit the network when you explicitly ask them to.

**Startup time:** The most noticeable impact. Each tool adds some initialization:

```
Startup time breakdown (approximate, fast machine):
- Base Neovim + de100 config:  ~35ms
- + Copilot (enabled):         ~60ms  (Node.js process startup)
- + CodeCompanion:             ~70ms  (command registration, setup)
- + Avante (VeryLazy):         +0ms startup, ~20ms on first access
```

If your startup time is a concern, prioritize: disable Copilot when you don't
have a subscription or don't need inline completion for a session. It has the
highest startup cost.

### Keybinding Strategy

With multiple AI tools, you want a consistent keybinding scheme. A suggested
mapping philosophy:

```lua
-- In your keymaps.lua or a dedicated ai-keymaps.lua:
vim.keymap.set({"n", "v"}, "<leader>aa", function()
    -- Smart router: if CodeCompanion available, use it; else nothing
    if pcall(require, "codecompanion") then
        vim.cmd("CodeCompanionActions")
    end
end, { desc = "AI: Actions palette" })

vim.keymap.set({"n", "v"}, "<leader>ac", function()
    if pcall(require, "codecompanion") then
        vim.cmd("CodeCompanionChat")
    end
end, { desc = "AI: Open chat" })

vim.keymap.set({"n", "v"}, "<leader>ae", function()
    if pcall(require, "avante") then
        vim.cmd("AvanteEdit")
    end
end, { desc = "AI: Edit with Avante" })

vim.keymap.set({"n", "v"}, "<leader>ak", function()
    if pcall(require, "avante") then
        vim.cmd("AvanteAsk")
    end
end, { desc = "AI: Ask Avante" })
```

Using `pcall` to check if the plugin is available means these keybindings are
defined but gracefully do nothing when the corresponding tool isn't enabled.
No errors, no confusion — `<leader>ac` just silently does nothing if
CodeCompanion is disabled for the current session.

---

## 10. Local AI with Ollama

### Why Local AI

Cloud AI APIs are convenient but come with three significant downsides:

1. **Privacy:** Your code is sent to a third-party server. For most personal
   projects and most open source code, this is fine. For proprietary code,
   client code under NDA, code containing business logic, or code for security
   systems — it's a real concern. Even companies that promise not to train on
   your data can't provide absolute privacy guarantees.

2. **Cost:** API calls accumulate. For light use, the cost is trivial. For a
   team of developers using AI heavily across multiple projects, it can become
   significant.

3. **Internet dependency:** Cloud APIs require internet access. If you're
   working offline (on a plane, in a location with unreliable connectivity, or
   on an air-gapped machine), cloud AI tools are unavailable.

Ollama solves all three: it runs entirely locally, there's no per-token charge,
and it works without internet. The tradeoff is model quality — local models are
generally less capable than Claude 3.5 Sonnet or GPT-4o, and running large
models requires significant RAM and optionally a GPU.

### Installing Ollama

**Linux:**

```bash
# The official install script:
curl -fsSL https://ollama.com/install.sh | sh

# Or manually from the releases page for more control:
# https://github.com/ollama/ollama/releases
```

**macOS:**

```bash
# Download the macOS app from ollama.com/download
# Or via Homebrew:
brew install ollama
```

**Verify installation:**

```bash
ollama --version
# ollama version is 0.x.x
```

**Start the Ollama service:**

```bash
ollama serve
# Listening on 127.0.0.1:11434
```

On systemd-based Linux, Ollama can run as a service:

```bash
sudo systemctl enable --now ollama
sudo systemctl status ollama
```

### Pulling Code Models

Ollama has a model library at [ollama.com/library](https://ollama.com/library).
For code assistance, these are the most commonly used options:

**CodeLlama** — Meta's code-focused model, fine-tuned from Llama 2:

```bash
ollama pull codellama        # 7B parameter model, ~4 GB, decent performance
ollama pull codellama:13b    # 13B parameter model, ~8 GB, better performance
ollama pull codellama:34b    # 34B parameter model, ~20 GB, near-GPT-3.5 quality
```

**DeepSeek Coder** — Strong code model from DeepSeek:

```bash
ollama pull deepseek-coder          # 6.7B, good for code tasks
ollama pull deepseek-coder:33b      # 33B, very capable
ollama pull deepseek-coder-v2       # Latest version, improved reasoning
```

**Llama 3.1** — Not code-specific but strong general model from Meta:

```bash
ollama pull llama3.1        # 8B, good general purpose
ollama pull llama3.1:70b    # 70B, needs significant RAM
```

**Qwen2.5 Coder** — Alibaba's code model, often ranks highly on code benchmarks:

```bash
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:32b
```

The RAM requirements scale with model size:

```
Model Size → Approximate RAM Required:
  7B  parameters → ~5-6 GB RAM
  13B parameters → ~9-10 GB RAM
  33B parameters → ~20-24 GB RAM
  70B parameters → ~45-50 GB RAM

With a GPU, models run much faster (VRAM determines max model size).
Without a GPU, inference runs on CPU — usable but slower.
```

For a machine with 16 GB RAM and no dedicated GPU, `codellama:13b` or
`deepseek-coder:6.7b` is a good starting point. You'll get reasonable quality
for code explanation and simple generation tasks with tolerable inference speed.

**Test that your model works:**

```bash
ollama run codellama "Write a function that reverses a linked list in Python"
```

If you get a coherent response, the model is working.

### Configuring CodeCompanion to Use Ollama

Add or modify the adapter configuration in your CodeCompanion opts:

```lua
{
    "olimorris/codecompanion.nvim",
    enabled = vim.env.DE100_ENABLE_CODECOMPANION == "1",
    opts = {
        strategies = {
            chat = {
                adapter = "ollama"
            },
            inline = {
                adapter = "ollama"
            },
            agent = {
                adapter = "ollama"
            }
        },
        adapters = {
            ollama = require("codecompanion.adapters").extend("ollama", {
                env = {
                    -- Default is http://localhost:11434 -- adjust if running
                    -- Ollama on a different host or port
                    url = "http://localhost:11434"
                },
                schema = {
                    model = {
                        default = "deepseek-coder:latest"
                    },
                    -- Adjust based on model's context window:
                    num_ctx = {
                        default = 16384
                    }
                }
            })
        }
    }
}
```

If you want different models for different operation types (chat vs inline), you
can define multiple ollama adapters:

```lua
adapters = {
    ollama_chat = require("codecompanion.adapters").extend("ollama", {
        schema = {
            model = { default = "codellama:13b" }  -- Bigger model for chat
        }
    }),
    ollama_inline = require("codecompanion.adapters").extend("ollama", {
        schema = {
            model = { default = "codellama:7b" }  -- Faster model for inline
        }
    })
},
strategies = {
    chat = { adapter = "ollama_chat" },
    inline = { adapter = "ollama_inline" }
}
```

### Configuring Avante to Use a Local Model

Avante also supports Ollama (as of recent versions) through the OpenAI-compatible
API that Ollama exposes:

```lua
{
    "yetone/avante.nvim",
    enabled = vim.env.DE100_ENABLE_AVANTE == "1",
    event = "VeryLazy",
    build = "make",
    opts = {
        provider = "openai",  -- Use OpenAI adapter with Ollama endpoint
        openai = {
            endpoint = "http://localhost:11434/v1",
            model = "deepseek-coder:latest",
            api_key_name = "EMPTY",  -- Ollama doesn't require a key
            timeout = 60000,  -- Longer timeout for local inference
        }
    }
}
```

Ollama exposes an OpenAI-compatible API at `/v1`, which means any tool that
supports OpenAI can be pointed at Ollama with a base URL change.

### Performance Expectations

Local inference is slower than cloud APIs. For a 7B model running on CPU:

- Short completions (< 100 tokens): 5-20 seconds
- Medium responses (200-500 tokens): 15-60 seconds
- Long code generation (500+ tokens): 1-5 minutes

With a modern GPU (RTX 3080 or better):

- Short completions: 1-3 seconds
- Medium responses: 3-10 seconds
- Long code generation: 10-30 seconds

This is why Ollama is best suited for CodeCompanion's chat use case (where you
submit a question and can wait for a response) rather than Copilot's inline
ghost text use case (where suggestions need to appear within 500ms to be
useful). Ghost text with a 15-second latency is worse than no ghost text.

For inline code generation tasks where you can wait a few seconds (explicit
requests rather than automatic suggestions), a local model is absolutely usable.

### Privacy-First Workflow

The complete local-AI workflow looks like this:

```bash
# .envrc for privacy-sensitive project:
export DE100_ENABLE_CODECOMPANION=1
# No ANTHROPIC_API_KEY, no OPENAI_API_KEY
# Ollama is configured as the adapter

# Ensure Ollama is running:
ollama serve &
```

All AI interactions stay on your machine. Your code, your questions, the AI's
responses — all local. No data leaves your network. This is the appropriate
setup for:

- Projects under NDA or with proprietary business logic
- Security tools or vulnerability research
- Client code where you've signed data handling agreements
- Personal code you're simply not comfortable sharing

The quality is lower than Claude 3.5 Sonnet, but for code explanation,
boilerplate generation, and test writing — the most common use cases — a
well-chosen local model is surprisingly capable.

---

## 11. Exercises

These exercises are designed to be done in order. Each one builds on the
previous and assumes you have access to at least one of the AI tools (or
Ollama for the fully local option). Read the setup instructions for each
exercise before starting.

---

### Exercise 1 — Enable Copilot and Experience Ghost Text

**Prerequisites:** GitHub account with Copilot subscription (individual plan or
provided by your employer). Node.js 18+ installed.

**Objective:** Enable Copilot, authenticate, and understand the full ghost text
interaction cycle.

**Setup:**

```bash
# Step 1: Set the environment variable
export DE100_ENABLE_COPILOT=1

# Step 2: Start a new Neovim session (not just :source -- the env var
# is read at startup, so you need a fresh Neovim process)
nvim
```

In Neovim, verify Copilot loaded:

```
:Lazy
```

Look for `copilot.lua` in the list. If it's present and loaded, proceed. If
it's not in the list at all, the env var wasn't set when Neovim started —
close, set the var, and reopen.

**Task 1: Authenticate**

```
:Copilot setup
```

Follow the OAuth device flow. When complete, run:

```
:Copilot status
```

Confirm it shows "Ready" and your GitHub username.

**Task 2: Experience inline suggestions**

Open a new file:

```
:enew
:setfiletype python
```

Type the following (slowly, with pauses to let Copilot respond):

```python
def bubble_sort(arr):
```

After typing the opening line, pause for 1-2 seconds. You should see grey ghost
text suggesting the function body. Observe what it suggests.

Press `Tab` to accept it. Then immediately press `Ctrl+Z` to undo, getting
back to just the function signature.

Now, change the function name to something more obscure:

```python
def schmorgenbord_sort(arr):
```

Observe whether Copilot can still suggest something sensible even with a
nonsense name (it usually can because the name is less important to it than
the context and language).

**Task 3: Use the panel**

Position your cursor at the end of the function signature line and run:

```
:Copilot panel
```

Browse the alternative suggestions with `Tab`/`Shift+Tab`. Notice that Copilot
has multiple ideas about what your function might do.

Close the panel with `q`.

**Task 4: Dismiss and compare**

Write another function signature:

```python
def process_data(raw_input, config, output_format="json"):
```

When Copilot suggests a completion, press `Ctrl+]` to dismiss it. Then press
`Alt+\` to manually request a suggestion. Is it the same? Different?

**Reflection questions:**
- When was Copilot's suggestion accurate enough to accept immediately?
- When did you need to dismiss and rethink?
- Did the ghost text ever appear in a way that broke your concentration?

---

### Exercise 2 — Explore CodeCompanion with Multiple Contexts

**Prerequisites:** CodeCompanion enabled, plus at least one backend configured:
either Copilot (if you did Exercise 1), or an API key for Claude/OpenAI, or
Ollama installed and running with a code model pulled.

**Objective:** Understand CodeCompanion's chat interface, context inclusion, and
action palette by working with real code you don't fully understand.

**Setup:**

```bash
export DE100_ENABLE_CODECOMPANION=1

# If using Claude:
export ANTHROPIC_API_KEY="your-key-here"

# If using Ollama (make sure Ollama is running with a model):
# ollama pull codellama
# ollama serve
# Then configure opts.strategies.chat.adapter = "ollama" in ai.lua
```

**Task 1: Open a chat buffer**

Start Neovim and open a file from this repository:

```bash
nvim dotfiles/.config/nvim/lua/de100/plugins/ai.lua
```

Run:

```
:CodeCompanionChat
```

A new chat buffer opens. Type the following question (modify to match what
you're curious about):

```
Looking at this Lua file, explain what the `enabled` field does in a lazy.nvim
plugin spec, and why checking an environment variable is a good pattern for
optional plugins.
```

Send with `Ctrl+Enter` (or whatever keybind CodeCompanion configures). Read the
response.

**Task 2: Include file context with /file**

In the same chat buffer, ask a follow-up question that references another file.
Use the `/file` slash command to include it:

```
/file dotfiles/.config/nvim/lua/de100/plugins/blink-cmp.lua

How does blink-cmp work alongside the copilot.lua plugin? Is there any 
connection between them?
```

Observe how CodeCompanion includes the file content as context before sending.

**Task 3: Visual mode context**

Navigate back to `ai.lua` (`:buffer ai.lua` or use your buffer navigation).
Select lines 3-11 (the copilot.lua spec) in visual mode with `V` and then
motion.

With the selection active, run:

```
:CodeCompanionActions
```

Select "Explain code" from the action palette. CodeCompanion will explain
specifically the selected lines, not the entire file.

**Task 4: Generate tests**

Open or create a simple Lua file with one function:

```
:enew
:setfiletype lua
```

Write a simple function:

```lua
local function clamp(value, min_val, max_val)
    if value < min_val then return min_val end
    if value > max_val then return max_val end
    return value
end
```

Select the function, open the action palette, and choose "Generate unit tests."
Review what CodeCompanion produces. Does it cover edge cases? Are the tests
idiomatic for the language?

**Reflection questions:**
- How does the `/file` slash command change the quality of the AI's response?
- What makes visual selection important for targeted questions?
- What did the AI get wrong or miss in the generated tests?

---

### Exercise 3 — Avante's Diff Workflow: Accept, Reject, Partial Apply

**Prerequisites:** Avante enabled, an API key configured (Claude or OpenAI
recommended for quality; Ollama is usable but slower), Rust installed (for the
build step), and the Avante plugin successfully compiled.

**Objective:** Experience Avante's core diff workflow and understand when to
accept vs reject individual hunks.

**Setup:**

```bash
# Verify Rust is installed (needed for the build step)
rustc --version  # should show rustc 1.70+ or higher
cargo --version

export DE100_ENABLE_AVANTE=1
export ANTHROPIC_API_KEY="your-key"  # or OPENAI_API_KEY
```

Start Neovim. On first load with Avante enabled, lazy.nvim will compile the
Rust components — this takes 30-90 seconds. Be patient. Check the status in
`:Lazy` if you're not sure if it completed.

**Task 1: Ask about existing code**

Open any moderately complex file in the repository. Navigate to a function or
component you find interesting. With your cursor inside it, run:

```
:AvanteAsk
```

Ask something about the code:

```
What are the potential failure modes of this function, and what would
you add to make it more robust?
```

Read the response in the Avante panel. Notice that no changes were made to your
file — `:AvanteAsk` is read-only.

**Task 2: Request an edit and review the diff**

Create a new file to practice with (so you're not modifying anything
irreversible):

```
:enew
:w /tmp/avante-practice.js
```

Write a simple but improvable function:

```javascript
function getUserData(userId) {
    var result = fetch('/api/users/' + userId)
    var data = result.json()
    return data
}
```

This function has several issues (synchronous-looking but fetching, var instead
of const/let, no error handling). Position your cursor inside the function.

Run:

```
:AvanteEdit
```

Enter:

```
Rewrite this function with proper async/await, use const/let instead of var,
add error handling, and add a JSDoc comment
```

The diff panel will show the suggested changes. Examine it carefully:

```
Expected diff to show something like:
- var result = fetch(...)         | + /**
- var data = result.json()        | +  * Fetches user data by ID
- return data                     | +  * @param {string} userId
                                  | +  */
                                  | + async function getUserData(userId) {
                                  | +   try {
                                  | +     const response = await fetch(...)
                                  | +     if (!response.ok) {
                                  | +       throw new Error(...)
                                  | +     }
                                  | +     const data = await response.json()
                                  | +     return data
                                  | +   } catch (error) {
                                  | +     console.error(...)
                                  | +     throw error
                                  | +   }
                                  | + }
```

**Task 3: Accept some hunks, reject others**

The AI probably made multiple changes. Use `Tab` to navigate between diff hunks.
For each hunk, decide if you want it:

- The JSDoc comment: accept it with `a`
- The async/await conversion: accept it
- The error handling: examine it carefully — does the error handling make sense?
  If the AI added something you'd write differently, reject this hunk with `r`
  and write your own version

This is the core skill: treating AI suggestions as a starting point, not a final
answer. Accept the parts that are right, reject the parts that aren't, and use
your judgment to fill in the rest.

**Task 4: Iterate**

After accepting/rejecting hunks, run `:AvanteEdit` again on the same file with
a follow-up instruction:

```
The error handling logs and rethrows the error, but it should also return null
instead of throwing so callers don't need try/catch. Update accordingly.
```

Review the new diff. Does Avante remember the context of the previous edit? Does
the suggested change align with what you asked for?

**Task 5: Reflection and comparison**

Open `:CodeCompanionChat` and ask about the same function you were just editing:

```
Which approach is better for an error in an API call: throwing the error
and letting the caller handle it, or returning null? What are the tradeoffs?
```

Compare the experience: Avante showed you the code change directly, CodeCompanion
lets you have a nuanced conversation about the tradeoffs. Neither tool is
objectively better — they're different interaction modes for different needs.

**Reflection questions:**
- When was the diff preview genuinely useful compared to just applying the change?
- Did you reject any hunks? What made them wrong?
- How did the second `:AvanteEdit` compare to the first in terms of quality?
- When would you prefer Avante's diff workflow over CodeCompanion's chat?

---

## Summary

You've covered a lot of ground in this chapter. Let's consolidate:

**The Philosophy:** AI tools are powerful and optional. This config disables them
by default using `vim.env.DE100_ENABLE_X == "1"` checks in lazy.nvim's `enabled`
field. No startup cost, no API calls, no subscription needed — unless you
explicitly want them.

**Copilot (`copilot.lua`):** Inline ghost text autocomplete. Best for flow state
coding where you want suggestions to appear automatically. Requires a Copilot
subscription. Auth with `:Copilot setup`. Tab to accept, Ctrl+] to dismiss.

**CodeCompanion:** Flexible LLM chat with multiple backend options. Best for
questions, explanations, test generation, and iterative discussion about code.
Supports Copilot, Claude, OpenAI, Ollama, and more. The `/file` and `/buffer`
slash commands in chat are powerful for including context.

**Avante:** Cursor-style interactive diffs. Best for structured refactors where
you want to review the change before applying it. Requires Rust for compilation
(`build = "make"`). Use `:AvanteAsk` to discuss code, `:AvanteEdit` to request
and review changes.

**Choosing:** Copilot for autocomplete, CodeCompanion for chat, Avante for diffs.
They don't conflict. Combine based on your workflow needs.

**Permanence:** Set env vars in `~/.zshrc` for always-on, or use `direnv` with
per-project `.envrc` files for per-project control.

**Keys:** Never commit API keys to dotfiles. Use `.zshrc.local`, secrets files
outside the repo, password managers, or direnv with `.gitignore`d `.envrc` files.

**Local AI:** Ollama lets you run code models locally for privacy and
zero-cost AI assistance. Slower than cloud APIs but private and offline-capable.
Configure CodeCompanion's `ollama` adapter and pull `codellama` or
`deepseek-coder`.

---

## Quick Reference

```
Enable tools:
  export DE100_ENABLE_COPILOT=1
  export DE100_ENABLE_CODECOMPANION=1
  export DE100_ENABLE_AVANTE=1

Copilot commands:
  :Copilot setup     -- First-time auth
  :Copilot status    -- Check connection
  :Copilot panel     -- Multiple suggestions panel
  :Copilot disable   -- Temporarily disable
  Tab                -- Accept inline suggestion
  Ctrl+]             -- Dismiss inline suggestion
  Alt+]              -- Next suggestion
  Alt+[              -- Previous suggestion

CodeCompanion commands:
  :CodeCompanionChat     -- Open chat buffer
  :CodeCompanionActions  -- Action palette
  :CodeCompanion         -- Context-aware (chat or inline)
  /file <path>           -- Include file in chat context
  /buffer <name>         -- Include buffer in chat context
  /symbols               -- Include LSP symbols
  Ctrl+Enter             -- Send chat message

Avante commands:
  :AvanteAsk   -- Ask about code (read-only)
  :AvanteEdit  -- Request edit, review diff
  a / A        -- Accept hunk / Accept all
  r / R        -- Reject hunk / Reject all
  Tab          -- Next diff hunk
  q            -- Close panel

Ollama:
  ollama pull codellama     -- Download a code model
  ollama pull deepseek-coder
  ollama serve              -- Start Ollama server
  ollama run <model> "..."  -- Quick test from terminal
```

---

*Next chapter: 12 · Debugging — DAP (Debug Adapter Protocol), breakpoints,
stepping through code, and the REPL-in-your-editor workflow.*
