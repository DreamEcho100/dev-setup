-- https://github.com/nvim-neo-tree/neo-tree.nvim
return { -- Neo-tree main plugin
{
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {"nvim-lua/plenary.nvim", -- For async utilities
    'MunifTanjim/nui.nvim', -- For nui window management
    'nvim-tree/nvim-web-devicons', -- For file icons
    '3rd/image.nvim' -- Optional image support in preview window
    },
    lazy = false,
    ---@module 'neo-tree'
    ---@type neotree.Config
    opts = require("de100.plugins.neotree.opt"),
    config = function()
        -- Setup neo-tree with options
        require('neo-tree').setup(require("de100.plugins.neotree.opt"))

        -- Keymaps (only define once here)
        vim.cmd [[nnoremap \ :Neotree reveal<cr>]]
        vim.keymap.set('n', '<leader>e', ':Neotree toggle position=left<CR>', {
            noremap = true,
            silent = true,
            desc = 'Toggle Neo-tree file explorer'
        })
        vim.keymap.set('n', '<leader>ngs', ':Neotree float git_status<CR>', {
            noremap = true,
            silent = true,
            desc = 'Open git status window'
        })
    end
}, -- Neo-tree lsp file operations
{
    "antosha417/nvim-lsp-file-operations",
    dependencies = {"nvim-lua/plenary.nvim", "nvim-neo-tree/neo-tree.nvim"},
    config = function()
        require("lsp-file-operations").setup()
    end
}, -- Window picker for Neo-tree
{
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
        require("window-picker").setup({
            filter_rules = {
                include_current_win = false,
                autoselect_one = true,
                bo = {
                    filetype = {"neo-tree", "neo-tree-popup", "notify"},
                    buftype = {"terminal", "quickfix"}
                }
            }
        })
    end
}}
