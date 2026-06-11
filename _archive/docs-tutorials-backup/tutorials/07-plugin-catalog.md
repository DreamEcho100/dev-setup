# 07. Plugin Catalog

This catalog covers the current plugin set by responsibility.

## Plugin Manager

| Plugin | How To Use |
| --- | --- |
| `lazy.nvim` | `:Lazy` opens plugin UI, `:Lazy sync` updates/installs, `:Lazy health` checks plugin manager health. |

## UI, Discovery, Theme

| Plugin | How To Use |
| --- | --- |
| `folke/snacks.nvim` | Main picker, dashboard, input, quickfile, lazygit wrapper, image support. Use `<leader>pf`, `<leader>pg`, `<leader>pc`, `<leader>lg`, `<leader>th`. |
| `folke/which-key.nvim` | Wait after pressing `<leader>` to discover grouped mappings. Use `<leader>pk` to search keymaps through Snacks. |
| `nvim-lualine/lualine.nvim` | Statusline. Passive UI. Configure in `lualine.lua`. |
| `b0o/incline.nvim` | Floating filename/status in windows. Passive UI. |
| `nvzone/showkeys` | Displays pressed keys for learning/demo. Use its configured key to toggle if needed. |
| `catppuccin/nvim` | Colorscheme option. Switch with `<leader>th`. |
| `folke/tokyonight.nvim` | Colorscheme option. Switch with `<leader>th`. |
| `ellisonleao/gruvbox.nvim` | Colorscheme option. Switch with `<leader>th`. |
| `rebelot/kanagawa.nvim` | Colorscheme option. Switch with `<leader>th`. |
| `loctvl842/monokai-pro.nvim` | Colorscheme option. Switch with `<leader>th`. |
| `rose-pine/neovim` | Colorscheme option. Switch with `<leader>th`. |
| `craftzdog/solarized-osaka.nvim` | Colorscheme option. Switch with `<leader>th`. |
| `nvim-tree/nvim-web-devicons` | Icon dependency for UI plugins. Passive. |

## Pickers And Compatibility

| Plugin | How To Use |
| --- | --- |
| `nvim-telescope/telescope.nvim` | Compatibility-only. Use `:Telescope` only when an extension needs it. Normal picker work belongs to Snacks. |
| `nvim-telescope/telescope-fzf-native.nvim` | Native sorter dependency for Telescope. Passive. |
| `nvim-lua/plenary.nvim` | Utility dependency used by many plugins. Passive. |
| `MunifTanjim/nui.nvim` | UI dependency. Passive. |
| `nvim-neotest/nvim-nio` | Async dependency for neotest/DAP UI. Passive. |
| `kevinhwang91/promise-async` | Dependency for folding/UI plugins. Passive. |
| `nvchad/menu` | Context menu dependency used by conn-manager. Passive until conn-manager opens a menu. |
| `epheien/wintab.nvim` | Floating tab/window UI dependency used by conn-manager. Passive until conn-manager opens its UI. |

## Files And Navigation

| Plugin | How To Use |
| --- | --- |
| `stevearc/oil.nvim` | Filesystem editor. Press `-`, edit names/paths, then `:w` to apply. Floating view with `<leader>-`. |
| `echasnovski/mini.files` | Lightweight explorer. Use `<leader>ee` and `<leader>ef`. |
| `thePrimeagen/harpoon` | Mark task files. Use `<leader>ha`, `<leader>hh`, `<leader>h1` to `<leader>h4`, `<leader>hp`, `<leader>hn`. |
| `folke/flash.nvim` | Fast visible jumps. Use `s`, `S`, and operator/visual Flash mappings. |
| `mbbill/undotree` | Visual undo history. Use `<leader>u`. |
| `kevinhwang91/nvim-ufo` | Advanced folding. Use `zR` open all and `zM` close all. |
| `christoomey/vim-tmux-navigator` | Move between tmux panes and Neovim splits with Control navigation keys where tmux config supports it. |
| `mg979/vim-visual-multi` replacement: `jake-stewart/multicursor.nvim` | VS Code-style multicursor. Use `<leader>mc`, `<leader>mC`, `<Esc>`. |

## Editing

| Plugin | How To Use |
| --- | --- |
| `numToStr/Comment.nvim` | Comment lines/blocks with configured comment mappings. |
| `windwp/nvim-autopairs` | Auto-pairs brackets/quotes. Passive while typing. |
| `windwp/nvim-ts-autotag` | Auto-close/rename HTML-like tags. Passive. |
| `JoosepAlviste/nvim-ts-context-commentstring` | Correct commentstring in mixed syntax files. Passive. |
| `echasnovski/mini.ai` | Extra text objects. Use operators with text objects, for example `ciq` where configured by mini.ai defaults. |
| `echasnovski/mini.surround` | Add/delete/replace surroundings. Use mini.surround default `sa`, `sd`, `sr` style mappings. |
| `echasnovski/mini.splitjoin` | Split/join structures. Use `sj` and `sk`. |
| `echasnovski/mini.trailspace` | Trim/highlight trailing spaces. Use `<leader>cw` for whitespace cleanup. |
| `echasnovski/mini.notify` | Notification backend. Passive. |
| `olrtg/nvim-emmet` | Wrap with abbreviation using `<leader>xe` in normal/visual mode. |
| `L3MON4D3/LuaSnip` | Snippet engine used by Blink. Trigger through completion. |
| `rafamadriz/friendly-snippets` | Snippet collection used by LuaSnip. Passive. |

## Completion And LSP

| Plugin | How To Use |
| --- | --- |
| `saghen/blink.cmp` | Completion engine. Uses super-tab behavior. Accept completions/snippets through Blink mappings. |
| `neovim/nvim-lspconfig` | LSP client configuration. Use `gd`, `gR`, `gi`, `gt`, `<leader>ca`, `<leader>rn`, `K`. |
| `mason-org/mason.nvim` | Tool installer UI. Use `:Mason`. |
| `mason-org/mason-lspconfig.nvim` | Bridges Mason LSP installs with Neovim LSP config. Passive. |
| `WhoIsSethDaniel/mason-tool-installer.nvim` | Ensures formatters/linters/debuggers are installed. Use `:MasonToolsInstall`. |
| `antosha417/nvim-lsp-file-operations` | Keeps LSP aware of file renames/moves. Passive. |
| `folke/lazydev.nvim` | Lua development helper for Neovim plugin/config files. Passive. |

## Formatting And Linting

| Plugin | How To Use |
| --- | --- |
| `stevearc/conform.nvim` | Formatting. Use `<leader>mp`; format-on-save depends on config/autocmd behavior. |
| `mfussenegger/nvim-lint` | External linting. Use `<leader>ll`. |

## Treesitter And Docs

| Plugin | How To Use |
| --- | --- |
| `nvim-treesitter/nvim-treesitter` | Syntax, indentation, text-object support for many languages. Use `:TSUpdate` if parsers need refresh. |
| `MeanderingProgrammer/render-markdown.nvim` | Rich Markdown rendering in buffers. Toggle with plugin commands if needed. |
| `lervag/vimtex` | LaTeX compile/view/edit workflow. Use VimTeX commands such as `:VimtexCompile`. |

## Git

| Plugin | How To Use |
| --- | --- |
| `lewis6991/gitsigns.nvim` | Hunk navigation/actions: `]h`, `[h`, `<leader>gs`, `<leader>gr`, `<leader>gp`, `<leader>gbl`. |
| `tpope/vim-fugitive` | Git in Vim. Use `<leader>gg`, then Fugitive buffer mappings and commands like `:Git status`. |
| `sindrets/diffview.nvim` | Review diffs/history. Use `<leader>gdo`, `<leader>gdc`, `<leader>gdh`, `<leader>gdH`. |
| `kdheepak/lazygit.nvim` | Disabled. LazyGit is accessed through Snacks with `<leader>lg`. |

## Debug, Tests, Tasks

| Plugin | How To Use |
| --- | --- |
| `mfussenegger/nvim-dap` | Debug client. Use `F5`, `F9`, `F10`, `F11`, `F12` and DAP commands. |
| `rcarriga/nvim-dap-ui` | Debug UI panels. Opens/toggles from DAP config keys. |
| `leoluz/nvim-dap-go` | Go debugging integration. Use dap-go commands/configs. |
| `nvim-neotest/neotest` | Test runner. Use `<leader>tN`, `<leader>tF`, `<leader>tO`, `<leader>tS`. |
| `nvim-neotest/neotest-python` | Python adapter for neotest. Passive until Python tests run. |
| `nvim-neotest/neotest-plenary` | Lua/Plenary test adapter. Passive until Lua tests run. |
| `marilari88/neotest-vitest` | Vitest adapter. Passive until JS/TS tests run. |
| `rouge8/neotest-rust` | Rust adapter. Passive until Rust tests run. |
| `antoinemadec/FixCursorHold.nvim` | Dependency used by neotest. Passive. |
| `stevearc/overseer.nvim` | Task runner. Use `<leader>tr`, `<leader>tt`, `<leader>ta`. |

## Language-Specific Helpers

| Plugin | How To Use |
| --- | --- |
| `mrcjkb/rustaceanvim` | Rust LSP/test/debug workflow. Opens automatically in Rust projects. |
| `saecki/crates.nvim` | Cargo.toml crate version helpers. Use crates commands in Cargo.toml. |
| `mfussenegger/nvim-jdtls` | Java project LSP workflow. Requires JDK opt-in install. |
| `seblyng/roslyn.nvim` | C# Roslyn LSP workflow. Requires .NET opt-in install for real projects. |

## Remote

| Plugin | How To Use |
| --- | --- |
| `amitds1997/remote-nvim.nvim` | Remote Neovim over SSH/devpod/docker. Loads only when required binaries exist. Use remote-nvim commands. |
| `lpfettel/conn-manager.nvim` | Saved SSH connection manager. Use ConnManager commands; Linux opens terminal emulators when available. |

## Search, Diagnostics, TODOs

| Plugin | How To Use |
| --- | --- |
| `MagicDuck/grug-far.nvim` | Project search/replace. Use `<leader>ps` and `<leader>pS`. |
| `folke/todo-comments.nvim` | Highlight and jump TODO/FIX/HACK comments. Use `]t`, `[t`, `<leader>pt`, `<leader>pT`. |
| `folke/trouble.nvim` | Diagnostics/references/list UI. Use configured `<leader>x*` mappings. |
| `norcalli/nvim-colorizer.lua` | Inline color previews. Passive for CSS/color strings. |

## Sessions And Tabs

| Plugin | How To Use |
| --- | --- |
| `rmagatti/auto-session` | Save/restore sessions. Use `<leader>ws`, `<leader>wr`. |
| `epheien/wintab.nvim` | Window/tab UI dependency for conn-manager. Passive. |

## AI Hooks

| Plugin | How To Use |
| --- | --- |
| `olimorris/codecompanion.nvim` | Documented default AI chat/edit hook. Disabled until `DE100_ENABLE_CODECOMPANION=1`. |
| `zbirenbaum/copilot.lua` | Optional inline suggestion hook. Disabled until `DE100_ENABLE_COPILOT=1`. |
| `yetone/avante.nvim` | Optional AI edit/chat experiment. Disabled until `DE100_ENABLE_AVANTE=1`. |

## Archived Or Replaced

| Plugin | Replacement |
| --- | --- |
| `wilder.nvim` | Blink cmdline/completion plus Snacks/which-key discovery. |
| `vim-maximizer` | Built-in Lua split zoom on `<leader>sm`. |
| `nvim-tree.lua` | Oil and mini.files. |
| `fff.nvim` | Snacks picker. |
| `git-worktree.nvim` | Native Git/tmux/project workflows unless a real worktree workflow returns. |
