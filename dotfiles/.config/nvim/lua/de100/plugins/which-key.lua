-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/02-the-vscode-translator.md
return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        delay = 300,
        spec = {
            {"<leader>b", group = "buffers"}, {"<leader>c", group = "code"},
            {"<leader>d", group = "diagnostics/debug"},
            {"<leader>dap", group = "debug/dap"},
            {"<leader>e", group = "explorer"}, {"<leader>f", group = "file"},
            {"<leader>g", group = "git"}, {"<leader>h", group = "harpoon"},
            {"<leader>H", group = "http/rest"},
            {"<leader>j", group = "jupyter/notebook"},
            {"<leader>l", group = "lsp/lint"},
            {"<leader>lspc", group = "lsp/clangd"},
            {"<leader>m", group = "make/cmake/format"},
            -- "cmake" group removed: cmake-tools.lua's <leader>mcm* keys were
            -- commented out (call :CMake* directly), no members left.
            {"<leader>p", group = "pick/search"},
            {"<leader>r", group = "rename/refactor"},
            {"<leader>s", group = "splits/session"},
            {"<leader>t", group = "tabs/tests/tasks/theme"},
            {"<leader>u", group = "ui/toggles"},
            {"<leader>v", group = "view/help"},
            {"<leader>w", group = "workspace/session"},
            -- "trouble/lists" group: only <leader>xw/xd are live now (trouble.lua's
            -- xq/xl/xt stay commented out, call :Trouble directly); Emmet's xe shares it.
            {"<leader>x", group = "trouble/emmet"},
            {"<leader>y", group = "yank"}
            -- "keys/show" group removed: showkeys.lua's <leader>ks was the only
            -- member and was commented out (call :ShowkeysToggle directly).
        }
    }
}
