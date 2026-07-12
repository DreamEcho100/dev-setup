return {
    { "mrcjkb/rustaceanvim", version = false, ft = { "rust" } },
    {
        "Saecki/crates.nvim",
        ft = { "toml" },
        opts = { completion = { cmp = { enabled = false } }, lsp = { enabled = true } },
    },
    {
        "seblyng/roslyn.nvim",
        ft = { "cs", "razor" },
        opts = { broad_search = true, silent = true },
        config = function(_, opts)
            vim.lsp.config("roslyn", {
                settings = {
                    ["csharp|background_analysis"] = {
                        dotnet_analyzer_diagnostics_scope = "openFiles",
                        dotnet_compiler_diagnostics_scope = "openFiles",
                    },
                    ["csharp|inlay_hints"] = {
                        csharp_enable_inlay_hints_for_implicit_object_creation = true,
                        csharp_enable_inlay_hints_for_implicit_variable_types = true,
                        csharp_enable_inlay_hints_for_lambda_parameter_types = true,
                        csharp_enable_inlay_hints_for_types = true,
                    },
                    ["csharp|code_lens"] = {
                        dotnet_enable_references_code_lens = true,
                    },
                },
            })
            require("roslyn").setup(opts)
        end,
    },
    {
        "lervag/vimtex",
        ft = { "tex", "plaintex", "bib" },
        init = function()
            vim.g.vimtex_view_method = "zathura"
            vim.g.vimtex_compiler_method = "latexmk"
            vim.g.vimtex_quickfix_mode = 0
        end,
    },
}
