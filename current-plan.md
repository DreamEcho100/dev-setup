# Neovim VS Code-To-Power-User Modernization

Status: implemented, commit split pending Git index access
Started: 2026-06-09
Backup branch: `backup/pre-neovim-modernization-20260609`
Backup archive: `_archive/nvim/20260609-pre-modernization/pre-modernization-config.tar.gz`

## Decisions

- Optimize for a hybrid path: VS Code familiarity first, then Vim/Neovim power workflows.
- Target broad polyglot development and install practical editor/toolchain dependencies by default.
- Keep Ansible cross-platform where practical.
- Keep `dev-env/runs/*` Bash scripts Ubuntu/Linux-focused and mirrored with their matching playbooks.
- Use stable Neovim by default; expose nightly as an explicit opt-in.
- Keep LaTeX, Mermaid, and Docker in the default setup.
- Keep Java and .NET documented opt-ins to avoid forcing large runtime stacks on every machine.
- Back up before replacing stale/conflicting plugins.
- Keep remote work first-class through both editor-style remote workflows and SSH/tmux-native workflows.
- Add AI hooks and docs without hardcoding provider secrets.
- Use CodeCompanion as the documented default AI chat/edit path, disabled by default.
- Keep Copilot and Avante as disabled optional hooks.
- Let Snacks own user-facing picker workflows; keep Telescope compatibility-only.
- Keep VS Code-style multicursor enabled and document Vim-native alternatives.

## Phase Log

### Phase 1: Preflight and Backup

- Restored `dotfiles/.config/nvim/lazy-lock.json` after the prior health-check run removed several plugin lock entries.
- Removed generated `nvim.log`.
- Created backup branch `backup/pre-neovim-modernization-20260609`.
- Created archive snapshot at `_archive/nvim/20260609-pre-modernization/pre-modernization-config.tar.gz`.

### Phase 2: Docs and Planning Artifacts

- Added this `current-plan.md`.
- Added top-level docs for setup, VS Code transition workflows, and Neovim power-user workflows.

### Phase 3: Bootstrap Alignment

- Replaced `dotfiles.yml` with a mirrored symlink playbook for `.config`, `.local`, and root dotfiles.
- Added `.zshenv` and `.profile` to normalize XDG paths and PATH, including VS Code Snap path recovery.
- Replaced `neovim.yml` with stable-by-default source installer and broad editor/tool dependency tasks.
- Replaced `dev-env/runs/neovim` with an Ubuntu/Linux mirror that supports `--dry`, `--stable`, `--nightly`, `--version`, and `--prefix`.

### Phase 4: Neovim Config Modernization

- Switched Blink to the `super-tab` keymap preset.
- Moved Harpoon off `<C-s>` and into `<leader>h*` mappings.
- Added built-in Lua split zoom and removed `vim-maximizer`.
- Removed stale/disabled active specs for `wilder.nvim`, `nvim-tree`, and `fff`.
- Removed stale `git-worktree.nvim` active spec.
- Consolidated `todo-comments` into one plugin spec with Snacks picker keymaps.
- Expanded Mason/LSP tooling for broad polyglot work.
- Added `which-key`, `flash.nvim`, `grug-far`, `overseer`, `neotest`, `diffview`, `multicursor`, AI hooks, Rust/Java/C#/LaTeX helpers.
- Fixed remote plugin safety and Linux terminal behavior in `conn-manager`.
- Broadened Treesitter parser installation.

### Phase 5: Verification

- `luac -p` passed for all Lua files under `dotfiles/.config/nvim/lua`.
- `ansible-playbook --syntax-check dotfiles.yml` passed with Ansible temp dirs pointed at `/tmp`.
- `ansible-playbook --syntax-check neovim.yml` passed with Ansible temp dirs pointed at `/tmp`.
- `ansible-playbook --check dotfiles.yml` passed with `ansible_remote_tmp=/tmp/ansible-remote`.
- `dev-env/runs/dotfiles --dry` passed.
- `dev-env/runs/neovim --dry` passed.
- Isolated Neovim plugin sync passed with repo config and `/tmp/dev-setup-nvim-*` XDG data/state/cache dirs.
- Headless Neovim startup passed with the isolated XDG dirs.
- Targeted `checkhealth lazy` and `checkhealth provider` passed with the isolated XDG dirs.
- Removed unsupported Treesitter parser names after sync warnings for `jsonc` and `norg`.
- Follow-up checks also passed for `git diff --check`, `git diff --cached --check`, Bash syntax, Lua syntax, Ansible syntax, dotfiles check mode, default Neovim dry-run, Java/.NET opt-in Neovim dry-run, headless startup, and targeted health.
- A follow-up network-backed `Lazy! sync` could not be rerun with escalation because the environment rejected escalated execution due the current usage limit. A local-only sync exited `0`, cleaned the removed Telescope theme plugin from the lockfile, and printed DNS fetch failures.

### Phase 6: User Decisions and Deep Tutorials

- Moved Java and .NET install paths to documented opt-in flags/vars.
- Kept LaTeX, Mermaid, and Docker in the default setup path.
- Removed user-facing Telescope keymaps and moved LSP location pickers to Snacks.
- Kept multicursor enabled and documented it as a valid workflow alongside Vim-native alternatives.
- Added a new detailed tutorial directory under `docs/tutorials`.

### Phase 7: Commit Split

- Planned logical commit split:
  - `chore: archive pre-modernization neovim config`
  - `feat: align dotfiles and neovim bootstrap installers`
  - `feat: modernize neovim vscode transition workflow`
  - `docs: add vscode-to-neovim tutorial series`
  - `chore: record verification plan and lockfile updates`
- Blocked in this environment because `.git` is read-only under the sandbox and escalation is unavailable due the current usage limit.
- Before committing, run `git reset` to clear the current staged index, then stage each group deliberately.
- Do not commit the current staged index as-is; it contains an accidentally staged generated `.stylua.toml`. The working tree deletes that file, and `git reset` will clear the staged add.

### Phase 8: Go Workspace and Lint Hotfix

- Planned fix for `bootdotdev-learn-go`, where `hellogo` imports sibling local module `mystrings`.
- Chosen pattern: add a root Go workspace for multi-module local development and make Neovim linting module-aware per buffer.
- Updated `nvim-lint` Go behavior so `golangci-lint` runs from the nearest `go.mod`, then nearest `go.work`, then the file directory.
- Applied `-buildvcs=false` only to Neovim's `golangci-lint` process to avoid VCS stamping failures without changing normal shell builds.
- Kept `hellogo/go.mod` `replace github.com/DreamEcho100/mystrings => ../mystrings` intact.
- Added `/home/viavi/Desktop/workspaces/github/DreamEcho100/bootdotdev-learn-go/go.work` with `./hellogo` and `./mystrings`.
- Verified `go env GOWORK`, `gopls check`, `go test`, `go build -o /tmp/dev-setup-hellogo .`, and direct `golangci-lint` for `hellogo`.

### Phase 9: Balanced Go Neovim IDE

- Re-scoped the Go workflow after user feedback that the custom linter path was too much for a Go and Neovim beginner.
- Chosen pattern: keep `gopls` as the primary feedback loop and keep `golangci-lint` as a secondary on-save/manual check.
- Simplified `nvim-lint` Go behavior to reuse its built-in `golangcilint` parser and version-specific output flags while only overriding the Go cwd/package target.
- Reduced Go lint triggers to `BufWritePost` and manual `<leader>ll`; non-Go linting keeps the broader open/save/InsertLeave behavior.
- Added `neotest-golang` with `gotestsum`, Go DAP test keymaps, and Overseer Go tasks for test/build/tidy/lint workflows.
- Added `docs/neovim-tutorials-from-0-to-hero/15-go-development.md` and updated existing LSP, linting, debug/test/task docs to match the final Go workflow.

### Phase 10: Blink V2 Polyglot LSP and Diagnostics UX

- Kept `blink.cmp` on V2/main with required `blink.lib`.
- Removed Blink V2 `prefetch_on_insert` because the installed V2 schema marks it as buggy/not recommended.
- Rebalanced completion toward a calmer manual-first workflow: automatic menu stays on, documentation and signature help are manual, cmdline completion avoids search/input prompts and short commands.
- Removed hidden semicolon snippet rewriting between LuaSnip and Blink; custom snippets now use explicit `;` triggers directly in snippet files.
- Quieted inline diagnostics to warnings/errors while keeping signs, underline, statusline counts, floats, Snacks, and Trouble workflows available.
- Fixed VS Code Snap XDG recovery for config/data/state/cache paths in shell dotfiles, Ansible dotfile setup, and the Ubuntu dotfiles runner.
- Started polyglot LSP cleanup: Java `jdtls` is enabled through native LSP, Rust remains `rustaceanvim`-managed, and C# uses `roslyn.nvim` instead of auto-starting Omnisharp.
- Updated tutorial docs to match Blink V2/manual-first completion, quiet diagnostics, explicit `;` snippet triggers, Rust ownership, and Roslyn C# ownership.
- Added `docs/neovim-tutorials-from-0-to-hero/19-polyglot-lsp-checklist.md` with a language-by-language LSP/completion/format/lint diagnosis matrix.
- Validation completed for edited files: targeted `stylua --check`, targeted `luac -p`, `bash -n` for the dotfiles/Neovim runners, `ansible-playbook --syntax-check` for `dotfiles.yml` and `neovim.yml` with Ansible temp dirs under `/tmp`, `dev-env/runs/dotfiles --dry`, `dev-env/runs/neovim --dry`, and `git diff --check`.
- Verified the normalized runtime XDG target paths with headless Neovim: `stdpath('data')` resolves to `/home/viavi/.local/share/nvim`, `stdpath('state')` to `/home/viavi/.local/state/nvim`, and `stdpath('cache')` to `/home/viavi/.cache/nvim`.
- Full headless health validation remains sandbox-limited in this environment because real `$HOME` state/cache writes are blocked and isolated XDG runs trigger Mason/Treesitter install/write attempts. Run the listed interactive checks from a normal terminal after applying dotfiles.

### Phase 11: Blink/LSP/Go Hotfix and Git Cleanup

- Revised Blink V2 decisions after user review: keep `prefetch_on_insert` off for this installed schema, use `prefer_rust_with_warning`, restore `<C-Space>` documentation toggling, and add `<C-@>` for terminal Ctrl-Space compatibility.
- Tightened the Blink V2 native matcher build hook to the documented `require("blink.cmp").build():pwait(60000)` form so build failures are visible instead of being swallowed.
- Hardened LSP startup so Blink capability failures do not prevent language servers from attaching.
- Made `gopls` root detection explicit: nearest `go.work`, then `go.mod`, then `.git`.
- Added `:De100Doctor` to report current buffer filetype, stdpaths, Blink native availability, active LSP clients/root dirs, nearest Go roots, and `go env GOWORK`.
- Restored lost dynamic LuaSnip semicolon behavior by making generated snippets use explicit `;` triggers instead of the removed hidden decorator/Blink transform path.
- Cleaned the working-tree view against `HEAD` by removing generated `nvim.log`, `.gitignore`, and `lazy-lock.json` changes from this hotfix scope.

### Phase 12: Terminal Workstation Stack

- Added `terminal.yml` and `dev-env/runs/terminal` as a separate install layer for zsh, Kitty, Ghostty, Starship, tmux, fonts, Antidote, and TPM.
- Kept the terminal stack separate from `neovim.yml` because shell/terminal state, font setup, and tmux persistence have different lifecycle and backup needs than editor tooling.
- Added backup-before-relink behavior to `dotfiles.yml` and `dev-env/runs/dotfiles` so existing `~/.zshenv`, `~/.zshrc`, `~/.profile`, `~/.config/kitty`, `~/.config/ghostty`, and related paths are archived before replacement.
- Preserved useful pieces from the existing user `~/.zshrc`: NVM, PNPM, envman, Cursor aliases, Python aliases, local script paths, Go paths, and Powerlevel10k compatibility.
- Chosen shell prompt behavior: existing machines with `~/.p10k.zsh` and the P10k theme keep the rich Powerlevel10k layout automatically; new machines fall back to Starship plus Antidote plugins.
- Restored the useful old shell plugin behavior through Antidote: Oh My Zsh `git`, `colored-man-pages`, `colorize`, `zsh-autocomplete`, autosuggestions, history substring search, and one syntax highlighter.
- Corrected the zsh completion stack after runtime testing: removed Oh My Zsh `path:lib` because it bootstraps completion before `zsh-autocomplete`, removed the optional `insert-unambiguous` zstyle that caused `_autocomplete__unambiguous` errors, kept `zsh-autocomplete` as the completion owner, and made history search bindings explicit.
- Remapped `Ctrl+r` to `zsh-autocomplete`'s `history-search-backward` widget so it opens the menu-style history search instead of native zsh incremental search.
- Added Kitty and Ghostty configs with Tokyo Night, JetBrainsMono Nerd Font, sane scrollback, copy-on-select, font zoom, and ignored local override files.
- Fixed the Starship bootstrap shape by moving config to `dotfiles/.config/starship/starship.toml`, which is activated by the existing `.config` directory symlink model.
- Added `de100-theme` to switch Kitty, Ghostty, Starship, and Neovim together without dirtying tracked config.
- Added theme profiles for `tokyo-night`, `catppuccin-mocha`, `rose-pine-moon`, `gruvbox-dark`, and Neovim-only `evergarden-spring` fallback.
- Modernized tmux around truecolor for Kitty/Ghostty, vim-style pane navigation, Wayland/X11 clipboard copy, popup sessionizer, Tokyo Night status styling, TPM, `tmux-resurrect`, and `tmux-continuum`.
- Fixed `ready-tmux` path handling and made `tmux-sessionizer` roots configurable through `TMUX_SESSIONIZER_DIRS` or `~/.config/tmux/sessionizer-dirs`.
- Added terminal/tmux tutorial docs covering VS Code equivalents, theme/font switching, zsh, Kitty, Ghostty, tmux persistence, Atuin opt-in, and XDG troubleshooting.
- Validation completed for this phase: `bash -n`, `zsh -n`, `luac -p` for the theme loader, `shfmt -d`, `stylua --check` for the touched Lua file, Ansible syntax checks for `terminal.yml` and `dotfiles.yml`, `ansible-playbook --check dotfiles.yml`, `dev-env/runs/terminal --dry`, `dev-env/runs/dotfiles --dry`, temporary-XDG `de100-theme set`, corrected-XDG `nvim --headless -u NONE` stdpath check, targeted `:Lazy build blink.cmp`, targeted `:checkhealth blink.cmp`, and `git diff --check`.
- Activated dotfiles in the live home directory and installed the user-local terminal pieces with `dev-env/runs/terminal --skip-apt`: Starship, Antidote, TPM, and JetBrainsMono Nerd Font.

### Phase 13: Zsh UX Recovery

- Reversed the default shell plugin decision after live UX testing showed the Antidote-first migration created avoidable completion and keybinding regressions for a beginner workflow.
- Chosen default: Oh My Zsh plus Powerlevel10k when available, matching the previous working shell layout and plugin behavior.
- Kept Antidote installed and documented as an explicit opt-in power-user mode through `DE100_ZSH_PLUGIN_MANAGER=antidote`.
- Kept Starship installed as an optional prompt fallback through `DE100_SHELL_PROMPT=starship`, but not as the default on machines with P10k.
- Updated the terminal installer paths so fresh machines install Oh My Zsh, Powerlevel10k, `zsh-autocomplete`, `zsh-autosuggestions`, and `fast-syntax-highlighting`; Antidote remains installed for opt-in use.
- Removed `/` from zsh `WORDCHARS` so `Ctrl+w` deletes one path segment instead of the whole path.
- Kept only one syntax highlighter by default: `fast-syntax-highlighting`; removed the `zsh-syntax-highlighting` fallback because it warns on `zsh-autocomplete` widgets.
- Loaded `fast-syntax-highlighting` before `zsh-autocomplete` in both OMZ and Antidote modes to avoid Powerlevel10k instant-prompt warnings from highlighter widget binding output.
- Updated terminal docs to explain the default OMZ/P10k path, Antidote opt-in path, Starship fallback, history search, and the `Ctrl+w` path behavior.

### Phase 14: Neovim Startup Warning Hotfix

- Fixed the Treesitter restore-time warning where `<leader>wr` could trigger background grammar downloads and stale `tree-sitter-*-tmp` git failures during session restore.
- Chosen pattern: do not install broad Treesitter parser sets automatically on every startup. Session restore should restore editing state, not perform network/build work.
- Added `:De100TreesitterInstall` to install only missing configured parsers on demand.
- Added `:De100TreesitterUpdate` to update installed Treesitter parsers explicitly.
- Kept safe per-buffer Treesitter startup: highlighting/indentation starts when the parser is available and stays quiet when it is missing.
- Pinned `kubectl.nvim` to tagged `2.*` releases and added the required `blink.download` dependency so its Rust helper can download from a release tag instead of warning on an untagged `main` checkout.
- Rebuilt Blink V2 native matcher after the lockfile refresh so the `blink.cmp` Rust fuzzy library matches the pinned plugin commit.
- Verified headless Neovim startup and `:AutoSession restore` from the Pokedex project no longer print the Treesitter git fetch error.
- Traced the remaining `Failed to fetch tree-sitter grammar` restore warning to `kulala.nvim`, not `nvim-treesitter`.
- Disabled Kulala's automatic custom parser fetch/build during normal startup and session restore.
- Added `:De100KulalaParserInstall` for explicit Kulala HTTP parser preparation when working on `.http`/`.rest` request files.
- Removed the broken live Kulala parser checkout at `~/.local/share/nvim/kulala.nvim/tree-sitter-kulala-http`.
- Verified fresh `:AutoSession restore` from the Pokedex project and fresh `filetype=http` startup no longer trigger Kulala/Treesitter parser fetch warnings.
- Fixed `man`/`less` startup by replacing the invalid `LESS="--use-color -Dd+r$Du+b"` default with portable `LESS="-R"`. Man-page colors remain owned by Oh My Zsh `colored-man-pages`.
- Replaced the defensive LSP diagnostic URI normalizer with a stricter trace-and-drop handler: malformed diagnostics are logged with sender details and dropped instead of being guessed into a file URI.
- Verified the malformed diagnostic handler path with a synthetic headless Neovim notification.

### Phase 15: 2026 Polyglot DAP Modernization

- Status: verification in progress.
- Audited the pinned June 2026 `nvim-dap` API, the current Mason adapter receipts, the Microsoft DAP adapter catalog, and each maintained language integration used by this config.
- Chosen default support: JavaScript/TypeScript and web frameworks, Python, Go, C/C++, Rust, standalone Lua, and Neovim Lua.
- Chosen optional support: Java, .NET, Godot/GDScript, Zig, and Odin when their runtimes/toolchains are available.
- Chosen exclusions: archived `chrome-debug-adapter`, stale Bash DAP, and fake debugger entries for data/markup/infrastructure filetypes.
- Split ownership cleanly: Lazy specs under `lua/de100/plugins/dap/`, repo runtime modules under `lua/de100/config/dap/`, and adapter binaries under Mason.
- Added VS Code-compatible function keys plus terminal-safe leader fallbacks, DAP UI lifecycle, calm virtual text, health reporting, and explicit trust for project `.nvim/dap.lua`.
- Added maintained integrations for `vscode-js-debug`, debugpy, Delve, CodeLLDB, Local Lua Debugger, OSV, JDTLS Java debug/test bundles, netcoredbg, and Godot's built-in DAP server.
- Kept Rust DAP ownership in `rustaceanvim`; made Java project attachment repeatable per `FileType`; runtime-gated Java on a full JDK and .NET on both `dotnet` and `netcoredbg`.
- Aligned Mason, Ansible, and Bash installation paths; Java 21, .NET 10, and Godot 4.6.3 remain explicit heavyweight opt-ins.
- Replaced the stale debugger tutorial and updated architecture, setup, VS Code translation, Go, C++, and polyglot docs.
- Narrowed `lazy-lock.json` to the intentional DAP delta only: three integration pins added and `mason-nvim-dap.nvim` removed.
- Verification completed so far: Lua parsing/formatting, Ansible syntax, default/all-option runner dry runs, fresh Lazy spec loading, DAP registration assertions, trusted project config merge, Rustaceanvim CodeLLDB detection, and real JavaScript/Python/Go/C/Lua adapter handshakes.
- Remaining verification: global health/diff checks, optional-runtime limitation report, final Git review, and logical commit split.

### Phase 16: Theme Persistence, `de100-theme-sync` Rename, Jupytext Fixes, Math Rendering

- `<leader>th` (Snacks colorscheme picker) previously only applied a colorscheme for the running session. It now persists the pick directly to `~/.local/state/nvim/de100/theme/nvim.lua` on confirm, via a new `dotfiles/.config/nvim/lua/de100/theme-persist.lua` module wired into a custom `finder`/`preview`/`confirm` on the picker.
- The same module adds 9 synthetic "meta-variant" entries (`gruvbox-dark`, `vscode-dark`/`-light`, `everforest-{dark,light}-{hard,medium,soft}`) to the picker's list — themes that only exist as a base colorscheme name plus an extra runtime flag, previously invisible to the picker's plain file-glob discovery.
- Renamed `dotfiles/.local/scripts/de100-theme` to `de100-theme-sync` and made its `set` subcommand require an explicit `--all` or `--targets=kitty,ghostty,starship,nvim` (no more implicit "touch everything" default). Mirrored the same package additions in `dev-env/runs/neovim` where relevant.
- Fixed `jupytext.nvim` crashing (`vim.json.decode` on an empty file) when opening a brand-new/empty `.ipynb`. Added a `:JupytextNew {path}` command and a defensive `BufReadPre` autocmd that seeds valid empty-notebook JSON before jupytext reads it.
- Added `matplotlib`/`sympy` to the Python provisioning (`neovim.yml` + `dev-env/runs/neovim`) and the `dvipng` apt package, enabling real rasterized-LaTeX rendering (not just matplotlib's mathtext subset) for Jupyter/Molten code-cell output — previously `IPython.display.Math`/bare sympy expressions only showed as plain-text reprs since Molten can't rasterize `text/latex` itself. Added `;mathimg`/`;sympymath` LuaSnip snippets.
- Updated the affected tutorial docs (`00-before-you-start.md`, `02-the-vscode-translator.md`, `13-customising-your-config.md`, `20-shell-terminal-tmux.md`, `21-python-math-jupyter.md`, `setup.md`) to match.

### Phase 17: Explorer-Reveal-From-Oil Fix, Theme-Meta Unification, and Math-Render v2

- Fixed `<leader>ef`/`<leader>er` ("reveal current file in explorer") misbehaving from inside an oil.nvim buffer: oil buffer names are a synthetic `oil://` URL, not a plain path. New shared `dotfiles/.config/nvim/lua/de100/utils/explorer-reveal.lua` resolves the real target (cursor entry, falling back to the next real entry when cursor sits on oil's `..` pseudo-entry, falling back further to the parent directory — clamped at the project root via a new `dotfiles/.config/nvim/lua/de100/utils/project-root.lua`, extracted from `de100/core/project-root.lua`'s `<leader>mcd` so both share one root-detection implementation).
- Unified the `M.extras`/`de100-theme-sync` `theme_values()` meta-variant duplication (flagged by the user — this exact duplication is why two real gaps, see next bullet, went unnoticed) into one shared `dotfiles/.config/nvim/lua/de100/utils/theme-meta.json`, read by Lua via `vim.json.decode` and by bash via `jq` (already installed). Moved `theme-persist.lua`/`explorer-reveal.lua`/`project-root.lua`/`theme-meta.json` into a new `de100/utils/` directory per user request.
- Added two real, pre-existing theme-catalogue gaps found via audit: `gruvbox-light` (real upstream Kitty theme file was already sitting unused in `_ignore/dotfiles-latest/`) and `evergarden-lunar` (palette sourced from the plugin's own `lua/evergarden/palettes/lunar.lua`).
- **Found and fixed a significant pre-existing bug** (predates this session): `de100-theme-sync`'s `THEME_STATE_DIR` computed `$XDG_STATE_HOME/de100/theme`, but Neovim's own `stdpath("state")` is `$XDG_STATE_HOME/nvim` — meaning `de100-theme-sync set <theme> --targets=nvim`/`--all` had *never* actually been able to write to the file `current-theme.lua` reads via that same `stdpath` call. Split into `THEME_STATE_DIR` (this script's own bookkeeping — `current`/`starship.toml`, unaffected) and a new `NVIM_THEME_STATE_DIR` (`$XDG_STATE_HOME/nvim/de100/theme`, used only for the `nvim.lua` write). Verified with a real bash-writes-then-Neovim-reads round trip, not just the bash side in isolation.
- Math-render v2 (`dotfiles/.config/ipython/startup/10-de100-math-render.py`, the `Math()`/`Latex()` auto-render hook from Phase 16): fixed a global-state bug (`matplotlib.use("Agg")` inside the formatter was mutating the kernel's backend for the whole session — switched to `matplotlib.backends.backend_agg.FigureCanvasAgg` directly, no `pyplot`/`matplotlib.use()` involved). Added explicit `dpi=150` for consistent image sizing. Added theme-color awareness: new `dotfiles/.config/nvim/lua/de100/utils/theme-colors.lua` exports the active colorscheme's `Normal` bg/fg to `~/.local/state/nvim/de100/theme/colors.json` on every `ColorScheme` autocmd (required before `current-theme.lua` in `init.lua` so the very first startup theme is captured too); the Python hook reads it and colors the rendered image to match, falling back to the previous transparent/black look when absent. Investigated and declined `molten-nvim`'s native `text/latex` (`pnglatex`) rendering path as an alternative — its LaTeX template is fixed with no color-package support, so theme-matching would require patching `molten-nvim`'s own source. Traced (not guessed) a real overlap bug — two image outputs in the *same* cell collide because `molten-nvim`'s `outputbuffer.py` gives every image chunk in one `Output` the identical vertical position in `virt`-text mode — to `molten-nvim` itself; documented as a known upstream limitation (single `Math()`/plot per cell is unaffected) rather than patched here.

### Phase 18: Math-Render v3/v4 (Sizing, Theme Colors) and Molten Display Simplification

- Renamed `theme-colors.lua` → `dotfiles/.config/nvim/lua/de100/utils/render-context.lua`, extended to also export the terminal's real cell pixel dimensions (`render-context.json`'s `cell_width`/`cell_height`) via a direct `ioctl(TIOCGWINSZ)` read done fresh on every `ColorScheme`/`VimResized` export — deliberately not relying on `image.nvim`'s own cached reader (`require("image.utils.term").get_size()`), since that only refreshes on `VimResized` and a terminal font-zoom that doesn't change the row/col grid might not reliably fire that event on every terminal.
- `10-de100-math-render.py`: renders now scale against the real terminal cell height instead of a fixed DPI (previously 3-4x too tall), and use a fixed high-quality supersample DPI downscaled with Pillow's Lanczos filter rather than rendering natively at a tiny DPI, which looked blurry (no font-hinting engine the way a terminal's own renderer has). Added a session-lifetime TTL cache (2s) to avoid re-reading the state file on every render call; `de100/utils/project-root.lua` got the same TTL-cache treatment (3-5s) for its filesystem tree walk.
- Iterated on `molten.lua`'s image/output display setting through several rounds of live user testing (a three-way `all`/`current`/`both` toggle command was built, then explicitly removed again as over-engineering per user feedback) and landed on a single fixed, simple behavior: `molten_image_location = "virt"` + `molten_auto_open_output = false` — all output (text/images/plots) pinned inline below every run cell, no floating popup window ever. Confirmed via source that `molten_image_location` alone doesn't suppress the floating window container (only image chunks within it); `molten_auto_open_output` is the separate flag that does, checked independently by `on_cursor_moved()`. The known overlap/scroll-jumbling trade-off of inline-only display (documented in the previous phase) is accepted as-is, not patched.

### Phase 19: Math-Render v5 (Overlap Fix, Ghost-Mimetype Bug, Popup Toggle)

- Fixed the documented multi-`Math()`-per-cell overlap limitation from Phase 18/17 for real: `10-de100-math-render.py` now buffers every `Math()`/`Latex()` call during a cell's execution and combines them into one vertically-stacked, bordered image at `post_run_cell`, instead of accepting the overlap as an upstream limitation. Verified via real-kernel round-trip across single/multi/mixed-with-`print()` scenarios (exact pixel-math match each time).
- Root-caused (via direct reads of the installed IPython 9.17.1 source, not guesswork) a real bug this introduced: the first version suppressed output by registering `None`-returning callbacks on the `text/plain`/`text/latex`/`image/png` formatters, but `PlainTextFormatter` never returns `None` — an empty pretty-print write comes back as `""`, which is `is not None` and so still lands in `format_dict`, defeating `display()`'s emptiness check and sending a near-empty `publish_display_data` that Molten flagged as `<No usable MIMEtype!...>` once per buffered call. Fixed by switching to the `_ipython_display_` formatter protocol (`ip.display_formatter.ipython_display_formatter.for_type(...)`), which short-circuits `DisplayFormatter.format()` before any per-mimetype formatter runs — zero messages published for buffered calls, confirmed for both `display()` calls and bare trailing expressions via kernel round-trip. Also let the `_pending_math_ids`/`id()`-dedup hack be removed, since this fires exactly once per object regardless of mimetype.
- Turned the combined image's border down from 2px to 1px.
- Turned off `g:molten_output_show_exec_time` globally: confirmed via source read there's no auto-fade-after-delay mechanism anywhere in `molten-nvim` (only timers are kernel-message polling loops), and the "Out[x]: Done Ns" header is unconditionally prepended to every output regardless of display mode — the only lever is this single global on/off.
- Added `<leader>jo`: a per-cell floating-output-popup toggle, since Molten's own `auto_open_output` has no per-cell scoping (confirmed: one `MoltenOptions` instance shared by reference everywhere). New `dotfiles/.config/nvim/lua/de100/utils/molten-popup.lua` tracks toggled cells (identified via `otter.nvim`'s code-chunk ranges — the same mechanism `<leader>jr`/`quarto.runner.run_cell()` already uses internally) and drives Molten's existing `:MoltenShowOutput`/`:MoltenHideOutput` commands off a `CursorMoved` autocmd: entering a toggled cell shows the popup, leaving it hides the popup, repeating every re-entry until toggled off again. Verified headlessly against a real multi-cell `.qmd` buffer (cell-range detection correct for both cells, `nil` for prose/fence lines) and the full show/hide state-transition sequence (mocked `vim.cmd` to assert exact call order across toggle-on → move to untoggled cell → move back → toggle-off).

### Phase 20: Math-Render v6 (`<leader>jo` Image Bug, Overlap-Clear ft-Ignore Fix)

- Root-caused (via direct reads of `molten-nvim`'s `outputchunks.py`/`outputbuffer.py`) why `<leader>jo`'s floating popup showed no image at all, and why closing it then permanently killed the cell's inline image: `ImageOutputChunk.place()` only actually places an image for a mode `image_location` includes, and under this config's `"virt"`-only setting, the popup's build call returned early *before* claiming its own Kitty-image identifier — leaving it pointing at the inline image's, so `clear_float_win()` on close deleted the shared/inline one instead of a popup-only copy. Fixed by switching `molten.lua`'s `image_location` from `"virt"` to `"both"`, which gives the popup a real image with its own separate identifier. Verified: `luac -p` and a headless load confirming the new default.
- Separately investigated a report that *any* floating window (completion popups, which-key hint menus, not just `<leader>jo`'s own popup) hides every visible cell's image at once, only restoring on a later manual cursor move: traced to `image.nvim`'s own `window_overlap_clear_enabled = true` (`dotfiles/.config/nvim/lua/de100/plugins/image.lua`, set before this whole math-render feature existed, to stop re-running a Molten cell from leaving garbled/duplicate plots). Tried extending its `window_overlap_clear_ft_ignore` exemption list with `blink.cmp`'s and `which-key.nvim`'s actual filetypes (`blink-cmp-menu`/`blink-cmp-documentation`/`blink-cmp-signature`, `wk`, confirmed correct via reading their source and verified applied at runtime via `debug.getupvalue` introspection into image.nvim's live `state.options`) — but the user confirmed after a full restart that the disappearing-image behavior persists regardless, so the filetype check isn't the actual mechanism at play. Reverted that change (redundant — it wasn't the fix) and documented this as an accepted, unresolved limitation instead, with a pointer to disabling `window_overlap_clear_enabled` entirely as a manual opt-out if the trade-off (losing garbled-plot-on-rerun protection) is preferred.

### Phase 21: Live Markdown Rendering Made Opt-In

- `render-markdown.nvim` was always-on for every `markdown`/`norg`/`rmd`/`org` buffer; per user report it can render in a visually jumbled way often enough to be disruptive. Set `opts.enabled = false` (its own internal initial-state config, separate from the lazy.nvim spec's own `enabled = true` which still controls whether the plugin loads at all) and added `<leader>ur` to toggle it on/off for the session, mirroring `treesitter-context.lua`'s existing `<leader>ut` toggle pattern exactly (`require("render-markdown").toggle()` + `.get()` + `vim.notify`). Verified headlessly: defaults to `false`, flips correctly on repeated toggles. Updated every doc that described it as always-active (`00-before-you-start.md`, `01-surviving-day-one.md`, `02-the-vscode-translator.md`, `21-python-math-jupyter.md`) to note it's off by default and how to enable it.

### Phase 22: Smart New-Notebook, Per-Target Path Styles, Clear-Output Commands

- `<leader>jn` / `:JupytextNew` now take just a name: new `utils/explorer-dir.lua` infers the target directory from the active explorer (oil cursor entry, mini.files, snacks explorer, else the buffer's dir/cwd); new `utils/notebook-new.lua` picks the format from the extension (`.qmd` -> Quarto with front matter, `.ipynb` kept, anything else -> `.ipynb` appended), honors absolute/`~` names, and provides name completion relative to the inferred dir (via a `customlist,v:lua` completion, avoiding a window-local `:lcd`). Verified headlessly against oil on a temp tree (dir/file/`..` cursor cases) and each name rule.
- "Paths too short" root cause: `showtabline = 2` with Neovim's default tabline, which abbreviates every parent dir (`p/_.ipynb`). New `utils/path-style.lua` provides a custom tabline plus per-target styles (`tabline`, `incline`, `lualine`, telescope `search`; oil gets no separate winbar, its directory is already in the tab label) with their own defaults (relative / parent / parent / relative) and styles `relative|parent|absolute|project|tail`; `:PathStyle [target] [style]` changes one target only (no keymap, by request). Snacks pickers and fff untouched.
- `:MoltenClear` / `:MoltenClearAll` (`utils/molten-clear.lua`, no keymaps): molten-nvim has no clear command, so these drive `:MoltenDelete` per cell (cells enumerated via otter code chunks, same lookup as `<leader>jr`/`molten-popup`; `:MoltenRestart!` rejected since it kills kernel state). Verified call order with mocked `vim.cmd` on a multi-cell `.qmd`.
- Toasts can't be selected: no code change needed — `:Noice history|last|errors` already open a real, entered split (noice `commands.history` defaults); documented in tutorial 14. (Not verifiable headless, noice needs a UI.)
- Bug fix: `:MoltenClearAll`/`:MoltenClear` deleted nothing for cells the cursor wasn't already in, because `:MoltenDelete` acts on molten's *last recorded* selected cell, which molten refreshes only from its own CursorMoved autocmd (not fired when the cursor is moved programmatically in the same tick). Now calls `MoltenOnCursorMoved` before each delete. Verified with a live headless Molten kernel on a 2-cell `.qmd`: 2 output extmarks -> 0 with the fix, 2 -> 2 without it (control). Added `<leader>jx` -> `:MoltenInterrupt`.
- sympy output overlapping (`display(x**y); display(x/y)` drawn on top of each other): verified with a real kernel that each sympy `display()` emits its own image (`image/png` from `init_printing()`, or `text/latex` rendered by Molten) and Molten stacks one cell's images at the same row (molten-nvim, not fixable here). `10-de100-math-render.py` now registers sympy `Basic`/`MatrixBase` by name on the `_ipython_display_` formatter, feeds `sympy.latex(obj)` into the existing buffered, themed, stacked image, and prints the plain repr when mathtext can't draw an item (also now true for failed `Math()`, which used to vanish silently). Verified: two exprs -> one image, same with `init_printing()`, bare expression -> one image, matrix -> text fallback, `print()` + `Math()` + sympy mixed -> text then one stacked image.
- Real-LaTeX math rendering (no mathtext limits, by request): `10-de100-math-render.py` now renders `Math()`/`Latex()`/sympy items with one `pdflatex` run per cell (`standalone` with `multi=mathitem`, amsmath/amssymb/xcolor, theme fg colour, transparent bg) + `pdftocairo -png -transp -r 300`, scaled by one common factor so fractions/matrices stay proportionally larger, cached by content under `~/.cache/de100/math/`. Fallback chain per item: LaTeX -> matplotlib mathtext -> plain text plus the first LaTeX error line; a bad item never drops the rest. New system dep `poppler-utils` added to `neovim.yml` and `dev-env/runs/neovim` (`dvipng` isn't needed). Verified in a real kernel: pmatrix, aligned, `\operatorname`, sympy Matrix/Integral, `Latex()` with mixed text, 5 items -> one stacked image in 0.35 s cold / 0.04 s cached, theme-coloured pixels present, bad `\frac{` prints source + error while the good item still renders, and with LaTeX removed from PATH simple items still render via mathtext (matrix falls to text).
- Inline image overlap (text printed before an image, or the `Out[n]` header, covered by the image; the `<leader>jo` popup was fine): root cause is in molten-nvim, which anchors every inline image at the output's first virtual row (`y = shape[1]`) while the popup advances `lineno` per chunk. image.nvim already supports a per-image `render_offset_top` (and reserves that many extra padding rows), Molten just never passed it. A tmux probe with the real plugins and image.nvim debug logging showed the actual cause: image.nvim creates its separate padding extmark, then clears the image and the padding extmark disappears (Molten rebuilds its own extmark and re-creates the Image on every redraw), leaving Molten's extmark as just header + text, so a 2-row image is drawn over them. Final patch (`outputbuffer.py`/`outputchunks.py`/`images.py`, ~35 lines): for inline output `ImageOutputChunk.place()` reserves the image's rows inside Molten's own extmark and places the image with `render_offset_top=lines_above`, `with_virtual_padding=False`, `inline=True`; `virt_text_max_lines` is skipped when an inline image is present. Verified in the probe (image row lands after header + text; baseline offset 0 vs 4 now). Draft PR benlubas/molten-nvim#365 (the `"several images share one anchor row"` remark was removed as unverified). Carried as the fork `DreamEcho100/molten-nvim` branch `fix/inline-image-offset` (lazy spec in `plugins/molten.lua` points at it); upstream PR to be opened after it's confirmed in a real terminal (placement can't be checked headless). Also made rendered math slightly bolder (`_WEIGHT_BOOST` in the hook).
- Molten fork upkeep (after issue benlubas/molten-nvim#324: the author no longer fixes bugs, still reviews PRs; pyrola trialled in an isolated copy and rejected, it has no per-cell inline output and mishandles fenced markdown cells): `utils/molten-upstream-check.lua` counts Neovim starts and on every N-th (default 10) asks the GitHub compare API how many upstream `main` commits the fork branch lacks, then toasts the newest titles (repeat-suppressed, silent offline, `:MoltenUpstreamCheck` on demand); `dotfiles/.local/scripts/de100-molten-fork-sync` (`--check`/`--yes`) rebases the branch in a cache clone and force-pushes only that branch after a prompt, aborting cleanly on conflict. Tested headlessly (up to date, stale base, every-N counter, repeat suppression) and the script against local simulated upstreams (clean rebase with and without push, conflict, up to date) plus `--check` on the real fork. Also verified on the fixed Molten in tmux that a cell with text and two images lays out header, text, image, text, image in order.
- Reverted the sympy routing in the math hook: with the Molten inline-image fix, several images in one cell no longer overlap, and routing made sympy output look different from what sympy normally shows (user asked for it to render normally). sympy output now uses sympy's own PNG (themed output via `Math(sympy.latex(expr))`). Also found while testing: upstream 81aa71b broke the floating output window for finished cells (`update_interface` skips `_show_selected` for DONE cells); fixed on the fork branch (commit 980ff6d, separate branch `fix/float-after-done` for a future upstream PR). Note a mistake: a test copy of that fix was left in the installed plugin dir for a while, and `:Lazy sync` (instead of `:Lazy install`) updated ~45 plugins, see lazy-lock.json.
- Branches: the fork now has `fix/inline-image-offset` (image fix only, upstream PR #365), `fix/float-after-done` (popup fix, draft upstream PR #366) and `de100-integration` (upstream main + both; what `plugins/molten.lua`, the upstream check and `de100-molten-fork-sync` track). `lazy-lock.json` committed as installed (it still carries the ~45 plugin updates from the `:Lazy sync`).
- Uneven spacing between small images (sympy's PNGs are 21/15/11/16px tall vs 20px terminal rows; Molten reserves whole rows): `10-de100-math-render.py` now wraps `display_pub.publish` and the displayhook to snap any `image/png` up to 6 rows tall to a whole number of rows, centred, with text scaled by `_SNAP_TEXT_SCALE` (0.86, calibrated against sympy's 'x'), skipping our own combined image. Verified in a real kernel: sympy via display and bare expression -> exactly 20px (1 row) each, a 400x300 image untouched, a 20x15 icon snapped. Not verified: how it looks in the real terminal.
- Tuning: Math()/Latex() text size 1.1 -> 1.0 of the row height (`_LATEX_SIZE_RATIO`); snapped sympy/numpy images get a little more weight (`_SNAP_WEIGHT_BOOST` 0.3, done at 4x resolution preserving their own colours; ~+30% ink on a synthetic check, sizes stay whole 20px rows).
- Font size nudged up a little for all rendered images: `_LATEX_SIZE_RATIO` 1.0 -> 1.05 and `_SNAP_TEXT_SCALE` 0.86 -> 0.9 (~5% each).
- Follow-up: keymaps added after all — `<leader>jc` (`:MoltenClear`), `<leader>jC` (`:MoltenClearAll`), `<leader>jd` (`:MoltenDelete`), `<leader>un` (`:Noice history`); `:PathStyle` stays command-only.
- Docs: tutorial 21 also documents the per-project venv + kernel setup (after a cell failed with `No module named 'sympy'` because the kernel used system Python, and a `pip freeze >` wiped a course repo's requirements.txt); tutorials 21 (new-notebook inference, clear commands), 06 (`:PathStyle`), 14 (Noice history as the way to copy toasts), 02 (incline pointer).

## Implementation Checklist

- [x] Restore accidental artifacts.
- [x] Create backup branch.
- [x] Create archive snapshot.
- [x] Add `current-plan.md`.
- [x] Add docs/tutorial structure.
- [x] Align `dotfiles.yml` with `dev-env/runs/dotfiles`.
- [x] Align `neovim.yml` with `dev-env/runs/neovim`.
- [x] Add minimal shell environment dotfiles.
- [x] Consolidate picker/explorer plugins.
- [x] Replace stale/conflicting plugins.
- [x] Add VS Code bridge plugins.
- [x] Expand language/tooling setup.
- [x] Fix remote/tmux setup.
- [x] Run syntax, dry-run, and health checks.
- [x] Apply user decisions from follow-up review.
- [x] Add detailed multi-step tutorial docs.
- [x] Harden Neovim Go lint cwd and `golangci-lint` args for local multi-module repos.
- [x] Add `bootdotdev-learn-go/go.work` after external workspace write approval.
- [x] Verify Go workspace, `gopls`, build, and lint behavior for `bootdotdev-learn-go`.
- [x] Rebalance Go linting toward `gopls` first and `golangci-lint` second.
- [x] Add Go test/debug/task workflow integrations.
- [x] Add beginner-focused Go development docs.
- [x] Start Blink V2 completion/diagnostics UX cleanup.
- [x] Normalize XDG paths across shell, Ansible, and Bash dotfile setup.
- [x] Deduplicate C# LSP ownership around Roslyn.
- [x] Update tutorial docs for Blink V2, diagnostics, and polyglot language checks.
- [x] Run targeted Blink/LSP/polyglot validation after XDG cleanup.
- [x] Revise Blink/LSP/Go hotfix decisions after user review.
- [x] Restore dynamic `;` snippet trigger behavior without the old Blink transform glue.
- [x] Add a current-buffer Blink/LSP/Go doctor command.
- [x] Clean generated log, `.gitignore`, and lockfile changes from the working tree relative to `HEAD`.
- [x] Add a separate terminal workstation playbook and Ubuntu/Linux runner.
- [x] Add zsh, Kitty, Ghostty, Starship, Atuin, and tmux dotfiles.
- [x] Add backup-safe dotfile activation for Ansible and Bash paths.
- [x] Add repo-managed multi-theme switching for terminals, Starship, and Neovim.
- [x] Modernize tmux persistence, clipboard, popup/sessionizer, and ready hooks.
- [x] Add terminal/tmux tutorial docs.
- [x] Validate terminal playbook and runner with syntax/dry-run checks.
- [x] Activate dotfiles from a normal unsandboxed shell so the live VS Code Snap XDG leak is fixed.
- [x] Install user-local terminal pieces that do not require sudo.
- [x] Restore Oh My Zsh plus Powerlevel10k as the default zsh UX.
- [x] Keep Antidote as an explicit opt-in zsh mode.
- [x] Update terminal installers to reproduce the default Oh My Zsh plugin stack.
- [x] Fix zsh `Ctrl+w` path-segment behavior.
- [x] Stop Treesitter from installing parsers during startup/session restore.
- [x] Add explicit Treesitter install/update commands.
- [x] Pin `kubectl.nvim` to tagged releases for its Rust helper download path.
- [x] Clean stale `tree-sitter-*-tmp` directories from `~/.local/share/nvim`.
- [x] Stop Kulala from fetching/building its custom parser during startup/session restore.
- [x] Add explicit Kulala parser install command.
- [x] Fix invalid `LESS` color options for `man`.
- [x] Trace and drop malformed Neovim LSP diagnostics without guessing file URIs.
- [ ] Modernize the DAP core, UI, keymaps, health checks, and trusted project loader.
- [ ] Add maintained default debugger integrations for web, Python, Go, native code, Rust, and Lua.
- [ ] Add guarded Java, .NET, Godot, Zig, and Odin debugger integrations.
- [ ] Align Mason, Ansible, and Bash debugger dependencies.
- [ ] Rewrite debugger tutorials and run end-to-end DAP verification.
- [ ] Run the full terminal installer from a normal terminal for apt-managed packages.
- [ ] Run full interactive Neovim health checks from a normal unsandboxed terminal.
- [ ] Split into logical commits after Git index access is available.

## Known Risks

- The current shell can inherit Snap VS Code XDG paths, which may point Neovim plugin data at read-only directories.
- Some optional dependencies are heavyweight or ecosystem-specific, including .NET, Java, LaTeX, Mermaid, and graphics/game development tooling.
- Some language ecosystems require project-local dependencies even after global editor tooling is installed.
- Neovim health checks may attempt plugin/parser installation and therefore write under XDG data/cache paths.
- Ansible check mode cannot fully validate symlink replacement semantics because removed paths still exist during simulation; the playbook skips symlink creation tasks in check mode after validating discovery and planned removals.
- Java and .NET language plugins remain configured even when runtime installers are opt-in; those workflows need the runtime installed before use.
- Blink V2/main is intentionally current but can break more often than tagged stable releases; keep `lazy-lock.json` pinned and verify after plugin updates.
- C# now expects Roslyn language server availability for full C# LSP behavior; Omnisharp is no longer auto-enabled to avoid duplicate clients.
- The current Git index may contain staged entries from the patching workflow. Clear the index with `git reset` before creating the final logical commits.
- This sandbox cannot clear the staged index because `.git/index.lock` cannot be created; use `git diff HEAD` for the true final content in this environment.
- Go projects opened above their nearest `go.mod` need a `go.work` when sibling local modules should resolve together.
- `neotest-golang` requires the Go tree-sitter parser and works best with `gotestsum`; Mason now installs `gotestsum`.
- `de100-theme` writes local Kitty/Ghostty override files under the live config directory. They are intentionally ignored by Git.
- Ghostty installed through Snap may not be runnable inside this sandbox, so config validation may need a normal desktop terminal.
- tmux runtime config loading could not be validated here because sandboxed tmux socket creation fails with `Operation not permitted`; validate from a normal terminal after activation.
- Existing local shell files are backed up during dotfile activation, but activation still changes what a new shell sources. Review `~/.zshrc.local`, `~/.zshenv.local`, and `~/.profile.local` for machine-specific overrides after the first run.
- The full terminal package install needs an interactive sudo prompt; this session installed the user-local pieces with `--skip-apt` and left apt-managed packages for a normal terminal run.
- The default zsh path now expects Oh My Zsh and the custom plugins to be installed by `terminal.yml` or `dev-env/runs/terminal`; if they are missing, the shell falls back to a minimal Starship prompt instead of printing startup warnings.
- Antidote remains available, but because it is lower-level than Oh My Zsh, plugin load-order debugging is expected when using `DE100_ZSH_PLUGIN_MANAGER=antidote`.
- Broad Treesitter parser installation is now explicit. Run `:De100TreesitterInstall` after plugin setup, or install individual parsers with `:TSInstall <language>` when a language has no Treesitter highlighting.
- Stale `tree-sitter-*-tmp` directories under live Neovim data can preserve failed git clone state until they are deleted from a normal shell.
- Kulala's enhanced HTTP parser is now explicit. Run `:De100KulalaParserInstall` from a normal terminal session when you want its custom parser installed for `.http`/`.rest` request files.
- Existing terminal shells keep their old environment until restarted. Run `exec zsh` or open a new terminal to pick up the fixed `LESS=-R` default.
- The LSP diagnostic URI guard prevents the Neovim crash by dropping malformed diagnostics. Use `:De100LspBadDiagnostics` to identify the sender and then fix the specific server/plugin instead of keeping broad protocol repair logic.

## Follow-Up Questions

- Should nightly Neovim remain only an opt-in installer path, or should this repo keep a separate nightly test profile?
- Should Java and .NET opt-in flags install only runtimes, or also project templates and SDK-specific helper tools?
- Should the next pass add sample projects for automated LSP/format/lint/DAP validation across every configured language?
- Should the next terminal pass add more theme packs, such as Kanagawa, Solarized Osaka, Monokai Pro, and Evergarden terminal palettes?
