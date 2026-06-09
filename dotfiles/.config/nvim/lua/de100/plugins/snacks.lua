return {
    -- HACK: docs @ https://github.com/folke/snacks.nvim/blob/main/docs
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        -- NOTE: Options
        opts = {
            notify = {enabled = false},
            notifier = {enabled = false},
            styles = {
                input = {
                    keys = {
                        n_esc = {
                            "<C-c>",
                            {"cmp_close", "cancel"},
                            mode = "n",
                            expr = true
                        },
                        i_esc = {
                            "<C-c>",
                            {"cmp_close", "stopinsert"},
                            mode = "i",
                            expr = true
                        }
                    }
                }
            },
            -- Snacks Modules
            input = {enabled = true},
            quickfile = {enabled = true, exclude = {"latex"}},
            -- HACK: read picker docs @ https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
            picker = {
                enabled = true,
                matchers = {frecency = true, cwd_bonus = false},
                exclude = {".git", "node_modules", "dist", "build"},
                formatters = {
                    file = {
                        filename_first = true,
                        filename_only = false,
                        icon_width = 2
                    }
                },
                layout = {
                    -- Built-ins include default, ivy, ivy-split, vscode, select, and sidebar.
                    -- override picker layout in keymaps function as a param below
                    preset = "split_preview",
                    cycle = false
                },
                layouts = {
                    select = {
                        preview = false,
                        layout = {
                            backdrop = false,
                            width = 0.6,
                            min_width = 80,
                            height = 0.4,
                            min_height = 10,
                            box = "vertical",
                            border = "rounded",
                            title = "{title}",
                            title_pos = "center",
                            {win = "input", height = 1, border = "bottom"},
                            {win = "list", border = "none"},
                            {
                                win = "preview",
                                title = "{preview}",
                                width = 0.6,
                                height = 0.4,
                                border = "top"
                            }
                        }
                    },
                    split_preview = {
                        reverse = true, -- set to false for search bar to be on top 
                        layout = {
                            box = "horizontal",
                            backdrop = false,
                            width = 0.8,
                            height = 0.9,
                            border = "none",
                            {
                                box = "vertical",
                                {
                                    win = "list",
                                    title = " Results ",
                                    title_pos = "center",
                                    border = "rounded"
                                },
                                {
                                    win = "input",
                                    height = 1,
                                    border = "rounded",
                                    title = "{title} {live} {flags}",
                                    title_pos = "center"
                                }
                            },
                            {
                                win = "preview",
                                title = "{preview:Preview}",
                                width = 0.50,
                                border = "rounded",
                                title_pos = "center"
                            }
                        }
                    },
                    ivy = {
                        layout = {
                            box = "vertical",
                            backdrop = false,
                            width = 0,
                            height = 0.4,
                            position = "bottom",
                            border = "top",
                            title = " {title} {live} {flags}",
                            title_pos = "left",
                            {win = "input", height = 1, border = "bottom"},
                            {
                                box = "horizontal",
                                {win = "list", border = "none"},
                                {
                                    win = "preview",
                                    title = "{preview}",
                                    width = 0.5,
                                    border = "left"
                                }
                            }
                        }
                    }
                }
            },
            image = {
                enabled = function()
                    return vim.bo.filetype == "markdown"
                end,
                doc = {
                    float = false, -- show image on cursor hover
                    inline = false, -- show image inline
                    max_width = 50,
                    max_height = 30,
                    wo = {wrap = false}
                },
                convert = {notify = true, command = "magick"},
                img_dirs = {
                    "img", "images", "assets", "static", "public", "media",
                    "attachments", "Archives/All-Vault-Images/", "~/Library",
                    "~/Downloads"
                }
            },
            dashboard = {
                enabled = true,
                sections = {
                    {section = "header"},
                    {section = "keys", gap = 1, padding = 1},
                    {section = "startup"}, {
                        section = "terminal",
                        cmd = "ascii-image-converter ~/.config/nvim/profile.jpg -C -c",
                        random = 15,
                        pane = 2,
                        indent = 15,
                        height = 20
                    }
                }
            }
        },
        -- NOTE: Keymaps
        keys = {
            {
                "<leader>lg",
                function() require("snacks").lazygit() end,
                desc = "Lazygit"
            }, {
                "<leader>gl",
                function() require("snacks").lazygit.log() end,
                desc = "Lazygit Logs"
            }, {
                "<leader>rN",
                function() require("snacks").rename.rename_file() end,
                desc = "Fast Rename Current File"
            }, {
                "<leader>dB",
                function() require("snacks").bufdelete() end,
                desc = "Delete or Close Buffer  (Confirm)"
            }, -- Snacks Picker
            {
                "<leader>pf",
                function() require("snacks").picker.files() end,
                desc = "Find files"
            }, {
                "<leader>pF",
                function() require("snacks").picker.smart() end,
                desc = "Smart picker"
            }, {
                "<leader>pb",
                function() require("snacks").picker.buffers() end,
                desc = "Pick buffers"
            }, {
                "<leader>pr",
                function() require("snacks").picker.recent() end,
                desc = "Recent files"
            }, {
                "<leader>pg",
                function() require("snacks").picker.grep() end,
                desc = "Grep project"
            }, {
                "<leader>pc",
                function() require("snacks").picker.commands() end,
                desc = "Commands"
            }, {
                "<leader>pe",
                function() require("snacks").picker.explorer() end,
                desc = "Explorer picker"
            }, {
                "<leader>pws",
                function() require("snacks").picker.grep_word() end,
                desc = "Search Visual selection or Word",
                mode = {"n", "x"}
            }, {
                "<leader>pk",
                function()
                    require("snacks").picker.keymaps({layout = "ivy"})
                end,
                desc = "Search Keymaps (Snacks Picker)"
            }, -- Git Stuff
            {
                "<leader>gbr",
                function()
                    require("snacks").picker.git_branches({layout = "select"})
                end,
                desc = "Pick and Switch Git Branches"
            }, -- Other Utils
            {
                "<leader>th",
                function()
                    require("snacks").picker.colorschemes({layout = "ivy"})
                end,
                desc = "Pick Color Schemes"
            }, {
                "<leader>vh",
                function() require("snacks").picker.help() end,
                desc = "Help Pages"
            }
        }
    }
}
