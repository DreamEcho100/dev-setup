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
- Isolated Neovim plugin sync passed with repo config and `/tmp/mfansible-nvim-*` XDG data/state/cache dirs.
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
- Verified `go env GOWORK`, `gopls check`, `go test`, `go build -o /tmp/mfansible-hellogo .`, and direct `golangci-lint` for `hellogo`.

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
