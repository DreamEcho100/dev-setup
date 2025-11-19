return {
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            -- list of servers for mason to install
            ensure_installed = { --
                "ts_ls", --  TypeScript/JavaScript LSP
                "html", -- HTML LSP
                "cssls", -- CSS LSP
                "tailwindcss", -- Tailwind CSS LSP
                "svelte", -- Svelte LSP
                "lua_ls", -- Lua LSP
                "graphql", -- GraphQL LSP
                "emmet_ls", -- Emmet LSP
                "prismals", -- Prisma LSP
                "pyright", -- Python LSP
                "eslint", -- ESLint LSP
                "clangd", -- C/C++ LSP
                -- "cpplint", -- C/C++ linter
                "dockerls", -- 
                "jsonls", --
                "pylsp", --
                "sqlls", --
                "terraformls", --
                "vtsls", --
                "yamlls", --
                "biome", -- biome formatter
                -- "prettier", -- prettier formatter
                "ruff", -- 
                "cssmodules_ls" --
                -- "css_variables", --
                -- "csharp_ls" --
                -- "java_language_server", --
                -- "nil" --
                -- "nginx_language_server", --
                -- "postgres_lsp", --
            }
        },
        dependencies = {
            {
                "williamboman/mason.nvim",
                opts = {
                    ui = {
                        icons = {
                            package_installed = "✓",
                            package_pending = "➜",
                            package_uninstalled = "✗"
                        }
                    }
                }
            }, 'neovim/nvim-lspconfig'
        }
    }, {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
            ensure_installed = { --
                "isort", -- python formatter
                "black", -- python formatter
                "pylint", -- python linter
                "eslint_d", -- eslint linter
                "checkmake", -- 
                "clang-format", --
                "cpplint", --
                "prettierd", --
                "shfmt", --
                "stylua" -- lua formatter
            }
        },
        dependencies = {"williamboman/mason.nvim"}
    }
}
