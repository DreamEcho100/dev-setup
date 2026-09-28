-- https://github.com/NeogitOrg/neogit
-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/08-git-workflow.md
return {
    "NeogitOrg/neogit",
    lazy = true,
    dependencies = {
        "nvim-lua/plenary.nvim", -- required
        "sindrets/diffview.nvim", -- optional - Diff integration
        -- Only one of these is needed.
        -- "nvim-telescope/telescope.nvim", -- optional
        -- "ibhagwan/fzf-lua", -- optional
        -- "nvim-mini/mini.pick", -- optional
        "folke/snacks.nvim" -- optional
    },
    cmd = "Neogit",
    -- Keymap removed: 1:1 wrapper around `:Neogit`, already declared in `cmd`
    -- above — just call it directly.
    -- keys = {{"<leader>gn", "<cmd>Neogit<cr>", desc = "Show Neogit UI"}}
    -- opts = {
    --   integrations = {
    --     diffview = true,
    --   },
    -- },
}
