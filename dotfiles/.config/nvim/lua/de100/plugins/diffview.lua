return {
    "sindrets/diffview.nvim",
    cmd = {"DiffviewOpen", "DiffviewFileHistory", "DiffviewClose"},
    dependencies = {"nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons"},
    keys = {
        {"<leader>gdo", "<cmd>DiffviewOpen<CR>", desc = "Open Diffview"},
        {"<leader>gdc", "<cmd>DiffviewClose<CR>", desc = "Close Diffview"},
        {"<leader>gdh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history"},
        {"<leader>gdH", "<cmd>DiffviewFileHistory<CR>", desc = "Repo history"}
    }
}
