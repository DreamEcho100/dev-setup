-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/13-customising-your-config.md
return {
    "nvim-lualine/lualine.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status") -- to configure lazy pending updates count

        local colors = {
            color0 = "#092236",
            color1 = "#ff5874",
            color2 = "#c3ccdc",
            color3 = "#1c1e26",
            color6 = "#a1aab8",
            color7 = "#828697",
            color8 = "#ae81ff"
        }
        local my_lualine_theme = {
            replace = {
                a = {fg = colors.color0, bg = colors.color1, gui = "bold"},
                b = {fg = colors.color2, bg = colors.color3}
            },
            inactive = {
                a = {fg = colors.color6, bg = colors.color3, gui = "bold"},
                b = {fg = colors.color6, bg = colors.color3},
                c = {fg = colors.color6, bg = colors.color3}
            },
            normal = {
                a = {fg = colors.color0, bg = colors.color7, gui = "bold"},
                b = {fg = colors.color2, bg = colors.color3},
                c = {fg = colors.color2, bg = colors.color3}
            },
            visual = {
                a = {fg = colors.color0, bg = colors.color8, gui = "bold"},
                b = {fg = colors.color2, bg = colors.color3}
            },
            insert = {
                a = {fg = colors.color0, bg = colors.color2, gui = "bold"},
                b = {fg = colors.color2, bg = colors.color3}
            }
        }

        local mode = {
            'mode',
            fmt = function(str)
                -- return ' ' 
                -- displays only the first character of the mode
                return ' ' .. str
            end
        }

        local diff = {
            'diff',
            colored = true,
            symbols = {added = ' ', modified = ' ', removed = ' '} -- changes diff symbols
            -- cond = hide_in_width,
        }

        -- Path style is per-target, change with :PathStyle lualine
        local filename = {
            function()
                local name = require("de100.utils.path-style").format(
                                 vim.api.nvim_buf_get_name(0), "lualine")
                if vim.bo.modified then name = name .. " [+]" end
                if not vim.bo.modifiable or vim.bo.readonly then
                    name = name .. " [-]"
                end
                return name
            end
        }

        local branch = {'branch', icon = {'', color = {fg = '#A6D4DE'}}, '|'}

        lualine.setup({
            icons_enabled = true,
            options = {
                theme = my_lualine_theme,
                component_separators = {left = "|", right = "|"},
                section_separators = {left = "|", right = ""}
            },
            sections = {
                lualine_a = {mode},
                lualine_b = {
                    -- displays git branch with an icon and a separator
                    branch,
                    -- displays diagnostics with an icon and a separator
                    {
                        'diagnostics',
                        sources = {'nvim_diagnostic'},
                        sections = {'error', 'warn'},
                        symbols = {error = ' ', warn = ' '}
                    }, -- displays remote host if connected remotely/
                    {
                        function()
                            -- Shows "Remote: <hostname>" if connected remotely
                            return vim.g.remote_neovim_host and
                                       ("Remote: %s"):format(
                                           vim.uv.os_gethostname()) or ""
                        end,
                        padding = {right = 1, left = 1},
                        separator = {left = "", right = ""}
                    }
                },
                lualine_c = {diff, filename},
                lualine_x = {
                    {
                        -- require("noice").api.statusline.mode.get,
                        -- cond = require("noice").api.statusline.mode.has,
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = {fg = "#ff9e64"}
                    }, {"encoding"}, {"fileformat"}, {"filetype"}
                }
            }
        })
    end
}
