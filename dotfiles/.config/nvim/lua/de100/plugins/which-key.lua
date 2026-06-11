return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        delay = 300,
        spec = {
            {"<leader>b", group = "buffers"},
            {"<leader>c", group = "code"},
            {"<leader>d", group = "diagnostics/debug"},
            {"<leader>e", group = "explorer"}, {"<leader>f", group = "file"},
            {"<leader>g", group = "git"}, {"<leader>h", group = "harpoon"},
            {"<leader>H", group = "http/rest"},
            {"<leader>l", group = "lsp/lint"},
            {"<leader>m", group = "make/format"},
            {"<leader>p", group = "pick/search"},
            {"<leader>r", group = "rename/refactor"},
            {"<leader>s", group = "splits/session"},
            {"<leader>t", group = "tabs/tests/tasks"},
            {"<leader>u", group = "ui/toggles"},
            {"<leader>v", group = "view/help"},
            {"<leader>w", group = "workspace/session"},
            {"<leader>x", group = "trouble/lists"},
            {"<leader>y", group = "yank"},
            {"<leader>k", group = "keys/show"}
        }
    }
}
