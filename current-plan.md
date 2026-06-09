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
- [ ] Split into logical commits after Git index access is available.

## Known Risks

- The current shell can inherit Snap VS Code XDG paths, which may point Neovim plugin data at read-only directories.
- Some optional dependencies are heavyweight or ecosystem-specific, including .NET, Java, LaTeX, Mermaid, and graphics/game development tooling.
- Some language ecosystems require project-local dependencies even after global editor tooling is installed.
- Neovim health checks may attempt plugin/parser installation and therefore write under XDG data/cache paths.
- Ansible check mode cannot fully validate symlink replacement semantics because removed paths still exist during simulation; the playbook skips symlink creation tasks in check mode after validating discovery and planned removals.
- Java and .NET language plugins remain configured even when runtime installers are opt-in; those workflows need the runtime installed before use.
- The current Git index may contain staged entries from the patching workflow. Clear the index with `git reset` before creating the final logical commits.

## Follow-Up Questions

- Should nightly Neovim remain only an opt-in installer path, or should this repo keep a separate nightly test profile?
- Should Java and .NET opt-in flags install only runtimes, or also project templates and SDK-specific helper tools?
- Should the next pass add sample projects for automated LSP/format/lint/DAP validation across every configured language?
