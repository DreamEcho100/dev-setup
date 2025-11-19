-- https://github.com/nvim-lualine/lualine.nvim
return {
    "nvim-lualine/lualine.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
        local lualine = require("lualine")
        local lazy_status = require("lazy.status") -- to configure lazy pending updates count

        -- local colors = {
        --     blue = "#65D1FF",
        --     green = "#3EFFDC",
        --     violet = "#FF61EF",
        --     yellow = "#FFDA7B",
        --     red = "#FF4A4A",
        --     fg = "#c3ccdc",
        --     bg = "#112638",
        --     inactive_bg = "#2c3043"
        -- }

        -- local my_lualine_theme = {
        --     normal = {
        --         a = {bg = colors.blue, fg = colors.bg, gui = "bold"},
        --         b = {bg = colors.bg, fg = colors.fg},
        --         c = {bg = colors.bg, fg = colors.fg}
        --     },
        --     insert = {
        --         a = {bg = colors.green, fg = colors.bg, gui = "bold"},
        --         b = {bg = colors.bg, fg = colors.fg},
        --         c = {bg = colors.bg, fg = colors.fg}
        --     },
        --     visual = {
        --         a = {bg = colors.violet, fg = colors.bg, gui = "bold"},
        --         b = {bg = colors.bg, fg = colors.fg},
        --         c = {bg = colors.bg, fg = colors.fg}
        --     },
        --     command = {
        --         a = {bg = colors.yellow, fg = colors.bg, gui = "bold"},
        --         b = {bg = colors.bg, fg = colors.fg},
        --         c = {bg = colors.bg, fg = colors.fg}
        --     },
        --     replace = {
        --         a = {bg = colors.red, fg = colors.bg, gui = "bold"},
        --         b = {bg = colors.bg, fg = colors.fg},
        --         c = {bg = colors.bg, fg = colors.fg}
        --     },
        --     inactive = {
        --         a = {
        --             bg = colors.inactive_bg,
        --             fg = colors.semilightgray,
        --             gui = "bold"
        --         },
        --         b = {bg = colors.inactive_bg, fg = colors.semilightgray},
        --         c = {bg = colors.inactive_bg, fg = colors.semilightgray}
        --     }
        -- }

        local mode = {
            'mode',
            fmt = function(str)
                return ' ' .. str
                -- return ' ' .. str:sub(1, 1) -- displays only the first character of the mode
            end
        }

        local filename = {
            'filename',
            file_status = true, -- displays file status (readonly status, modified status)
            path = 0 -- 0 = just filename, 1 = relative path, 2 = absolute path
        }

        local hide_in_width = function() return vim.fn.winwidth(0) > 100 end

        local diagnostics = {
            'diagnostics',
            sources = {'nvim_diagnostic'},
            sections = {'error', 'warn'},
            symbols = {
                error = ' ',
                warn = ' ',
                info = ' ',
                hint = ' '
            },
            colored = false,
            update_in_insert = false,
            always_visible = false,
            cond = hide_in_width
        }

        local diff = {
            'diff',
            colored = false,
            symbols = {added = ' ', modified = ' ', removed = ' '}, -- changes diff symbols
            cond = hide_in_width
        }

        local function lsp_status()
            local clients = vim.lsp.get_clients()
            if next(clients) == nil then return '' end
            local client_names = {}
            for _, client in pairs(clients) do
                table.insert(client_names, client.name)
            end
            return '  ' .. table.concat(client_names, ', ')
        end

        local function treesitter_status()
            return vim.treesitter.highlighter.active[vim.api
                       .nvim_get_current_buf()] and '' or ''
        end

        -- configure lualine with modified theme
        lualine.setup({
            options = {
                -- theme = my_lualine_theme,
                icons_enabled = true,
                theme = 'onedark', -- Set theme based on environment variable
                -- Some useful glyphs:
                -- https://www.nerdfonts.com/cheat-sheet
                --        
                section_separators = {left = '', right = ''},
                component_separators = {left = '', right = ''},
                disabled_filetypes = {'alpha', 'neo-tree'},
                always_divide_middle = true
            },
            sections = {
                lualine_a = {mode},
                lualine_b = {'branch'},
                lualine_c = {filename},
                lualine_x = {
                    diagnostics, diff, {'encoding', cond = hide_in_width},
                    {'filetype', cond = hide_in_width}, lsp_status,
                    -- {"filetype"},
                    treesitter_status,
                    {
                        lazy_status.updates,
                        cond = lazy_status.has_updates,
                        color = {fg = "#ff9e64"}
                    }, {"encoding"}, {"fileformat", symbols = {unix = ""}}
                },
                lualine_y = {'location'},
                lualine_z = {'progress'}
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {{'filename', path = 1}},
                lualine_x = {{'location', padding = 0}},
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            extensions = {'fugitive'}
        })
    end
}
