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
        dependencies = {"mason-org/mason.nvim", "neovim/nvim-lspconfig"},
        config = function()
            require("mason-lspconfig").setup({
                automatic_enable = false,
                ensure_installed = {
                    "angularls",
                    "astro",
                    "bashls",
                    "biome",
                    "clangd",
                    "cmake",
                    "cssls",
                    "cssmodules_ls",
                    "docker_compose_language_service",
                    "dockerls",
                    "emmet_language_server",
                    "eslint",
                    "gdscript",
                    "gopls",
                    "graphql",
                    "html",
                    "jdtls",
                    "jsonls",
                    "lua_ls",
                    "marksman",
                    "ols",
                    "omnisharp",
                    "prismals",
                    "pyright",
                    "ruff",
                    "rust_analyzer",
                    "sqlls",
                    "svelte",
                    "tailwindcss",
                    "taplo",
                    "terraformls",
                    "texlab",
                    "vtsls",
                    "vue_ls",
                    "yamlls",
                    "zls"
                }
            })
        end
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        lazy = false,
        dependencies = {"mason-org/mason.nvim"},
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "black",
                    "biome",
                    "checkmake",
                    "clang-format",
                    "clangd",
                    "codelldb",
                    "codespell",
                    "cpplint",
                    "debugpy",
                    "delve",
                    "eslint_d",
                    "goimports",
                    "google-java-format",
                    "isort",
                    "java-debug-adapter",
                    "java-test",
                    "js-debug-adapter",
                    "local-lua-debugger-vscode",
                    "luacheck",
                    "markdownlint",
                    "netcoredbg",
                    "prettier",
                    "prettierd",
                    "pylint",
                    "ruff",
                    "shellcheck",
                    "shfmt",
                    "stylua",
                    "taplo",
                    "yamllint",
                    "yamlfmt"
                },
                auto_update = false,
                run_on_start = true,
                start_delay = 3000
            })
        end
    }
}
