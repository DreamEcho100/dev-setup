-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/11-ai-coding-assistant.md
return {
    {
        "zbirenbaum/copilot.lua",
        enabled = vim.env.DE100_ENABLE_COPILOT == "1",
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
            suggestion = {enabled = true, auto_trigger = true},
            panel = {enabled = true}
        }
    }, {
        "olimorris/codecompanion.nvim",
        enabled = vim.env.DE100_ENABLE_CODECOMPANION == "1",
        cmd = {"CodeCompanion", "CodeCompanionChat", "CodeCompanionActions"},
        dependencies = {
            "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter"
        },
        opts = {}
    }, {
        "yetone/avante.nvim",
        enabled = vim.env.DE100_ENABLE_AVANTE == "1",
        event = "VeryLazy",
        build = "make",
        dependencies = {
            "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons"
        },
        opts = {}
    }
}
