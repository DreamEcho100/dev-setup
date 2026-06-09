return {
    {"mrcjkb/rustaceanvim", version = false, ft = {"rust"}}, {
        "Saecki/crates.nvim",
        ft = {"toml"},
        opts = {completion = {cmp = {enabled = false}}, lsp = {enabled = true}}
    }, {"mfussenegger/nvim-jdtls", ft = {"java"}},
    {"seblyng/roslyn.nvim", ft = {"cs"}, opts = {}}, {
        "lervag/vimtex",
        ft = {"tex", "plaintex", "bib"},
        init = function()
            vim.g.vimtex_view_method = "zathura"
            vim.g.vimtex_compiler_method = "latexmk"
            vim.g.vimtex_quickfix_mode = 0
        end
    }
}
