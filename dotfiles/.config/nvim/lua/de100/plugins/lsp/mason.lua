-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/07-lsp-and-completions.md
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
                        package_uninstalled = "✗",
                    },
                },
            })
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        lazy = false,
        dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
        config = function()
            local servers = {
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
                "gopls",
                "graphql",
                "html",
                "jsonls",
                "lua_ls",
                "marksman",
                "ansiblels",
                "ols",
                "prismals",
                "pyright",
                "ruff",
                "sqlls",
                "svelte",
                "tailwindcss",
                "taplo",
                "terraformls",
                "texlab",
                "vtsls",
                "vue_ls",
                "yamlls",
                "zls",
            }
            if vim.fn.executable("java") == 1 and vim.fn.executable("javac") == 1 then
                table.insert(servers, "jdtls")
            end

            require("mason-lspconfig").setup({
                automatic_enable = false,
                ensure_installed = servers,
            })
        end,
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        lazy = false,
        dependencies = { "mason-org/mason.nvim" },
        config = function()
            local tools = {
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
                "ansible-lint",
                "gofumpt",
                "goimports",
                "golangci-lint",
                "gotestsum",
                "isort",
                "js-debug-adapter",
                "local-lua-debugger-vscode",
                "luacheck",
                "markdownlint",
                "prettier",
                "prettierd",
                "pylint",
                "ruff",
                "shellcheck",
                "shfmt",
                "stylua",
                "taplo",
                "yamllint",
                "yamlfmt",
            }
            if vim.fn.executable("java") == 1 and vim.fn.executable("javac") == 1 then
                vim.list_extend(tools, { "google-java-format", "java-debug-adapter", "java-test" })
            end
            if vim.fn.executable("dotnet") == 1 then
                table.insert(tools, "netcoredbg")
            end

            require("mason-tool-installer").setup({
                ensure_installed = tools,
                auto_update = false,
                run_on_start = true,
                start_delay = 3000,
            })
        end,
    },
}
