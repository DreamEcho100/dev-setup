return {
    "stevearc/aerial.nvim",
    dependencies = {"nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons"},
    keys = {
        {"<leader>lo", "<cmd>AerialToggle<CR>", desc = "Toggle symbols outline"},
        {"[a", "<cmd>AerialPrev<CR>", desc = "Previous symbol"},
        {"]a", "<cmd>AerialNext<CR>", desc = "Next symbol"}
    },
    opts = {
        backends = {"lsp", "treesitter", "markdown", "asciidoc", "man"},
        layout = {
            max_width = {40, 0.2},
            min_width = 25,
            default_direction = "right",
            placement = "edge"
        },
        attach_mode = "global",
        close_automatic_events = {"switch_buffer"},
        show_guides = true,
        filter_kind = {
            "Class", "Constructor", "Enum", "Function", "Interface",
            "Module", "Method", "Struct", "Type"
        },
        icons = {},
        nav = {
            border = "rounded",
            preview = true,
            keymaps = {
                ["<CR>"] = "actions.jump",
                ["<C-v>"] = "actions.jump_vsplit",
                ["<C-s>"] = "actions.jump_split",
                q = "actions.close",
                ["<Esc>"] = "actions.close"
            }
        }
    }
}
