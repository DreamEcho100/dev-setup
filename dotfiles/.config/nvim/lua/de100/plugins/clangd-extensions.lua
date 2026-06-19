-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/18-cpp-development.md
-- Clangd's off-spec features: AST view, type hierarchy, symbol info, memory usage.
-- Uses the maintained dchinmay2 fork (p00f/clangd_extensions.nvim is archived).
-- https://github.com/dchinmay2/clangd_extensions.nvim
return {
    "dchinmay2/clangd_extensions.nvim",
    ft = {"c", "cpp", "objc", "objcpp"},
    dependencies = {"neovim/nvim-lspconfig"},
    opts = {
        inlay_hints = {
            -- Disabled by default: Neovim 0.12.2 has a crash in the inlay hint
            -- extmark renderer when servers return end-of-line positions.
            -- Toggle with <leader>li when you want to try them.
            inline = false,
            show_parameter_hints = true,
            parameter_hints_prefix = "<- ",
            other_hints_prefix = "=> "
        },
        ast = {
            role_icons = {
                type = "",
                declaration = "",
                expression = "",
                specifier = "",
                statement = "",
                ["template argument"] = ""
            },
            kind_icons = {
                Compound = "",
                Recovery = "",
                TranslationUnit = "",
                PackExpansion = "",
                TemplateTypeParm = "",
                TemplateTemplateParm = "",
                TemplateParamObject = ""
            },
            highlights = {detail = "Comment"}
        }
    },
    keys = {
        {
            "<leader>lspcA",
            "<cmd>ClangdAST<CR>",
            ft = {"c", "cpp"},
            desc = "Clangd AST view"
        }, {
            "<leader>lspcT",
            "<cmd>ClangdTypeHierarchy<CR>",
            ft = {"c", "cpp"},
            desc = "Type hierarchy"
        }, {
            "<leader>lspcS",
            "<cmd>ClangdSymbolInfo<CR>",
            ft = {"c", "cpp"},
            desc = "Symbol info"
        }, {
            "<leader>lspcM",
            "<cmd>ClangdMemoryUsage<CR>",
            ft = {"c", "cpp"},
            desc = "Clangd memory usage"
        }
    }
}
