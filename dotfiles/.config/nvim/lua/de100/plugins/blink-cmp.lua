-- Filename: ~/github/dotfiles-latest/neovim/neobean/lua/plugins/blink-cmp.lua
-- ~/github/dotfiles-latest/neovim/neobean/lua/plugins/blink-cmp.lua
-- HACK: blink.cmp updates | Remove LuaSnip | Emoji and Dictionary Sources | Fix Jump Autosave Issue
-- https://youtu.be/JrgfpWap_Pg
-- completion plugin with support for LSPs and external sources that updates
-- on every keystroke with minimal overhead
-- https://www.lazyvim.org/extras/coding/blink
-- https://github.com/saghen/blink.cmp
-- Documentation site: https://cmp.saghen.dev/
-- NOTE: Specify the trigger character(s) used for luasnip
local trigger_text = ";"

return {
    "saghen/blink.cmp",
    enabled = true,
    -- In case there are breaking changes and you want to go back to the last
    -- working release: https://github.com/Saghen/blink.cmp/releases
    -- version = "v0.13.1",
    dependencies = {
        "saghen/blink.lib", -- required by blink.cmp v2
        -- "moyiz/blink-emoji.nvim",
        "Kaiser-Yang/blink-cmp-dictionary", "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets"
    },
    build = function()
        local ok, cmp = pcall(require, "blink.cmp")
        if ok and type(cmp.build) == "function" then cmp.build():pwait() end
    end,

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = function(_, opts)
        -- Telescope and similar prompt UIs were very slow with blink enabled,
        -- so disable blink for those filetypes.
        -- Run :lua print(vim.bo[0].filetype) inside a buffer to find its ft.
        opts.enabled = function()
            local filetype = vim.bo[0].filetype
            if filetype == "TelescopePrompt" or filetype == "minifiles" or
                filetype == "snacks_picker_input" then return false end
            return true
        end

        -- Merge custom sources with whatever was already configured (e.g. by
        -- LazyVim, which adds lazydev). Don't overwrite the existing table.
        opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
            default = {
                "lsp", "path", "snippets", "buffer"
                -- "emoji", "dictionary"  -- uncomment after :Lazy sync installs them
            },
            -- dadbod only activates for SQL files (matches when vim-dadbod-completion is loaded)
            per_filetype = {
                sql = {"lsp", "path", "snippets", "buffer", "dadbod"},
                mysql = {"lsp", "path", "snippets", "buffer", "dadbod"},
                plsql = {"lsp", "path", "snippets", "buffer", "dadbod"}
            },
            providers = {
                lsp = {
                    name = "lsp",
                    enabled = true,
                    module = "blink.cmp.sources.lsp",
                    kind = "LSP",
                    min_keyword_length = 0,
                    -- Previously used fallbacks = { "snippets", "buffer" } so
                    -- snippets/text only appeared when LSP returned nothing.
                    -- Disabled because lua snippets stopped showing up.
                    score_offset = 90,
                    opts = {
                        tailwind_color_icon = "󱓻"
                        -- set to nil to disable tailwind color icons
                    }
                },
                path = {
                    name = "Path",
                    module = "blink.cmp.sources.path",
                    score_offset = 25,
                    -- When typing a path, prefer path entries; only fall back
                    -- to snippets/buffer if there are no path matches.
                    fallbacks = {"snippets", "buffer"},
                    opts = {
                        trailing_slash = false,
                        label_trailing_slash = true,
                        get_cwd = function(context)
                            return vim.fn.expand(("#%d:p:h"):format(
                                                     context.bufnr))
                        end,
                        show_hidden_files_by_default = true
                    }
                },
                buffer = {
                    name = "Buffer",
                    enabled = true,
                    max_items = 3,
                    module = "blink.cmp.sources.buffer",
                    min_keyword_length = 2,
                    score_offset = 15
                },
                snippets = {
                    name = "snippets",
                    enabled = true,
                    max_items = 15,
                    min_keyword_length = 2,
                    module = "blink.cmp.sources.snippets",
                    score_offset = 85,
                    -- Only show snippets after typing the trigger_text char,
                    -- e.g. with trigger_text=";", typing ";bash" shows the
                    -- "bash" snippet.
                    should_show_items = function()
                        local col = vim.api.nvim_win_get_cursor(0)[2]
                        local before_cursor =
                            vim.api.nvim_get_current_line():sub(1, col)
                        return before_cursor:match(trigger_text .. "%w*$") ~=
                                   nil
                    end,
                    -- Strip the trigger_text from the final inserted text
                    -- after accepting the completion.
                    -- Based on `synic`'s suggestion to avoid reloading the
                    -- luasnip source on each transform:
                    -- https://github.com/linkarzu/dotfiles-latest/discussions/7#discussion-7849902
                    transform_items = function(_, items)
                        local line = vim.api.nvim_get_current_line()
                        local col = vim.api.nvim_win_get_cursor(0)[2]
                        local before_cursor = line:sub(1, col)
                        local start_pos, end_pos = before_cursor:find(
                                                       trigger_text .. "[^" ..
                                                           trigger_text .. "]*$")
                        if start_pos then
                            for _, item in ipairs(items) do
                                if not item.trigger_text_modified then
                                    ---@diagnostic disable-next-line: inject-field
                                    item.trigger_text_modified = true
                                    item.textEdit = {
                                        newText = item.insertText or item.label,
                                        range = {
                                            start = {
                                                line = vim.fn.line(".") - 1,
                                                character = start_pos - 1
                                            },
                                            ["end"] = {
                                                line = vim.fn.line(".") - 1,
                                                character = end_pos
                                            }
                                        }
                                    }
                                end
                            end
                        end
                        return items
                    end
                },
                -- https://github.com/moyiz/blink-emoji.nvim
                -- emoji = {
                --     module = "blink-emoji",
                --     name = "Emoji", 
                --     score_offset = 93,
                --     min_keyword_length = 2,
                --     opts = {insert = true},
                -- },
                -- https://github.com/Kaiser-Yang/blink-cmp-dictionary
                -- On macOS to bootstrap a dictionary:
                --   cp /usr/share/dict/words ~/github/dotfiles-latest/dictionaries/words.txt
                -- For word definitions install wordnet:
                --   brew install wordnet
                dictionary = {
                    module = "blink-cmp-dictionary",
                    name = "Dict",
                    score_offset = 20,
                    enabled = true,
                    max_items = 8,
                    min_keyword_length = 3,
                    opts = {
                        -- Uses fzf under the hood; make sure fzf is installed.
                        -- https://github.com/Kaiser-Yang/blink-cmp-dictionary/issues/2
                        --
                        -- Point at a directory containing .txt files (not a
                        -- single file).
                        dictionary_directories = {},
                        dictionary_files = {
                            vim.fn.expand("~/.config/nvim/spell/en.utf-8.add")
                        }
                        -- To disable definitions, uncomment:
                        -- separate_output = function(output)
                        --   local items = {}
                        --   for line in output:gmatch("[^\r\n]+") do
                        --     table.insert(items, {
                        --       label = line,
                        --       insert_text = line,
                        --       documentation = nil,
                        --     })
                        --   end
                        --   return items
                        -- end,
                    }
                },
                dadbod = {
                    name = "Dadbod",
                    module = "vim_dadbod_completion.blink",
                    min_keyword_length = 2,
                    score_offset = 85
                }
                -- copilot = {
                --   name = "copilot",
                --   enabled = true,
                --   module = "blink-cmp-copilot",
                --   kind = "Copilot",
                --   min_keyword_length = 6,
                --   score_offset = -100,
                --   async = true,
                -- },
            }
        })

        opts.cmdline = {
            enabled = true,
            keymap = {preset = "cmdline"},
            completion = {menu = {auto_show = true}}
        }

        opts.completion = {
            -- accept = {
            --   auto_brackets = {
            --     enabled = true,
            --     default_brackets = { ";", "" },
            --     override_brackets_for_filetypes = {
            --       markdown = { ";", "" },
            --     },
            --   },
            -- },
            -- keyword = { range = "full" },
            menu = {auto_show = true, border = "single"},
            documentation = {auto_show = true, window = {border = "single"}},
            ghost_text = {enabled = false, show_with_menu = false},
            accept = {auto_brackets = {enabled = true}}
        }

        opts.fuzzy = {
            implementation = "lua"
            --   use_typo_resistance = false, -- matches fzf behavior when off
            --   use_frecency = true,
            --   use_proximity = false,
        }

        opts.snippets = {preset = "luasnip"}

        -- opts.sources.providers.snippets.opts = {
        --   use_show_condition = true,
        --   show_autosnippets = true,
        -- }

        -- LazyVim's default keymap preset accepts completions with Enter,
        -- which is bad in markdown — Enter should move to the next line, not
        -- accept. Use "default" preset (C-y to accept) with custom overrides.
        -- https://cmp.saghen.dev/configuration/keymap.html#default
        opts.keymap = {
            preset = "default",
            ["<Tab>"] = {"snippet_forward", "fallback"},
            ["<S-Tab>"] = {"snippet_backward", "fallback"},

            ["<Up>"] = {"select_prev", "fallback"},
            ["<Down>"] = {"select_next", "fallback"},
            ["<C-p>"] = {"select_prev", "fallback"},
            ["<C-n>"] = {"select_next", "fallback"},

            ["<S-k>"] = {"scroll_documentation_up", "fallback"},
            ["<S-j>"] = {"scroll_documentation_down", "fallback"},

            ["<C-space>"] = {"show", "show_documentation", "hide_documentation"},
            ["<C-e>"] = {"hide", "fallback"}
        }

        return opts
    end
}
