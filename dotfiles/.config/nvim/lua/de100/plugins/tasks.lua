return {
    "stevearc/overseer.nvim",
    cmd = {
        "OverseerOpen", "OverseerRun", "OverseerToggle", "OverseerQuickAction"
    },
    opts = {templates = {"builtin"}},
    keys = {
        {"<leader>tr", "<cmd>OverseerRun<CR>", desc = "Run task"},
        {"<leader>tt", "<cmd>OverseerToggle<CR>", desc = "Toggle tasks"},
        {"<leader>ta", "<cmd>OverseerQuickAction<CR>", desc = "Task action"}
    }
}
