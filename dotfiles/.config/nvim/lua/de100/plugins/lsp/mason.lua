return {
    {
        "mason-org/mason.nvim",
        lazy = false,
        priority = 100,
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })
        end
    },
    {
        "mason-org/mason-lspconfig.nvim",
        lazy = false,
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        config = function()
            require("mason-lspconfig").setup({
                automatic_enable = false,
                ensure_installed = {
                    "gopls", --
                    "angularls", --
                    "astro", --
                    "emmet_ls", --
                    "emmet_language_server", --
                    "marksman", --
                    "ts_ls", --
                    "html", --
                    "cssls", --
                    "tailwindcss", --
                    "svelte", --
                    "lua_ls", --
                    "graphql", --
                    "prismals", --
                    "pyright", --
                    "eslint", --
                    "clangd", --
                    "dockerls", --
                    "jsonls", --
                    "pylsp", --
                    "sqlls", --
                    "terraformls", --
                    "vtsls", --
                    "yamlls", --
                    "biome", --
                    "ruff", --
                    "cssmodules_ls" --
                }
            })
        end
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        lazy = false,
        dependencies = { "mason-org/mason.nvim" },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "prettier", --
                    "stylua", --
                    "isort", --
                    "pylint", --
                    "black", --
                    "eslint_d", --
                    "prettierd", --
                    "shellcheck", --
                    "shfmt", --
                    "biome", --
                    "checkmake", --
                    "clang-format", --
                    "cpplint", --
                    "delve", --
                    "js-debug-adapter", --
                    "debugpy", --
                    "codelldb", --
                    "local-lua-debugger-vscode", --
                    "chrome-debug-adapter" --
                }
            })
        end
    }
}
