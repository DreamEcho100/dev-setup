-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/07-lsp-and-completions.md
return {
    "neovim/nvim-lspconfig",
    event = {"BufReadPre", "BufNewFile"},
    dependencies = {
        "saghen/blink.cmp",
        {"antosha417/nvim-lsp-file-operations", config = true}
    },
    config = function()
        local function snacks_picker(method, fallback)
            return function()
                local ok, snacks = pcall(require, "snacks")
                if ok and snacks.picker and snacks.picker[method] then
                    snacks.picker[method]()
                    return
                end

                fallback()
            end
        end

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {clear = true}),
            callback = function(ev)
                local opts = {buffer = ev.buf, silent = true}

                opts.desc = "Show LSP references"
                vim.keymap.set("n", "gR", snacks_picker("lsp_references",
                               vim.lsp.buf.references), opts)

                opts.desc = "Go to declaration"
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

                opts.desc = "Show LSP definitions"
                vim.keymap.set("n", "gd", snacks_picker("lsp_definitions",
                               vim.lsp.buf.definition), opts)

                opts.desc = "Show LSP implementations"
                vim.keymap.set("n", "gi", snacks_picker("lsp_implementations",
                               vim.lsp.buf.implementation), opts)

                opts.desc = "Show LSP type definitions"
                vim.keymap.set("n", "gt", snacks_picker("lsp_type_definitions",
                               vim.lsp.buf.type_definition), opts)

                opts.desc = "Code actions"
                vim.keymap.set({"n", "v"}, "<leader>ca", vim.lsp.buf.code_action, opts)

                opts.desc = "Smart rename"
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

                opts.desc = "Show buffer diagnostics"
                vim.keymap.set("n", "<leader>D", function()
                    require("snacks").picker.diagnostics_buffer()
                end, opts)

                opts.desc = "Show line diagnostics"
                vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, opts)

                opts.desc = "Hover documentation"
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

                opts.desc = "Signature help"
                vim.keymap.set({"n", "i"}, "<leader>ls", vim.lsp.buf.signature_help, opts)

                -- Header ↔ source switch for C/C++ (clangd only)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if client and client.name == "clangd" then
                    opts.desc = "Switch header/source (C/C++)"
                    vim.keymap.set("n", "<leader>lh",
                                   "<cmd>ClangdSwitchSourceHeader<CR>", opts)
                end
                -- Inlay hints are off by default due to a Neovim 0.12.2 bug where
                -- LSP servers returning end-of-line hint positions crash the extmark
                -- renderer. Toggle on/off with <leader>li when needed.
            end
        })

        local signs = {
            [vim.diagnostic.severity.ERROR] = "E ",
            [vim.diagnostic.severity.WARN] = "W ",
            [vim.diagnostic.severity.HINT] = "H ",
            [vim.diagnostic.severity.INFO] = "I "
        }

        vim.diagnostic.config({
            signs = {text = signs},
            virtual_text = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = true
            }
        })

        vim.keymap.set("n", "<leader>lv", function()
            local current = vim.diagnostic.config().virtual_text
            vim.diagnostic.config({virtual_text = not current})
        end, {desc = "Toggle LSP virtual text"})

        vim.keymap.set("n", "<leader>li", function()
            vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled({bufnr = 0}),
                {bufnr = 0}
            )
        end, {desc = "Toggle inlay hints"})

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
        vim.lsp.config("*", {capabilities = capabilities})

        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {globals = {"vim"}},
                    completion = {callSnippet = "Replace"},
                    workspace = {
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true
                        }
                    }
                }
            }
        })

        vim.lsp.config("emmet_language_server", {
            filetypes = {
                "astro", "css", "eruby", "html", "htmldjango", "javascriptreact",
                "less", "pug", "sass", "scss", "svelte", "typescriptreact", "vue"
            },
            init_options = {
                showAbbreviationSuggestions = true,
                showExpandedAbbreviation = "always",
                showSuggestionsAsSnippets = true
            }
        })

        vim.lsp.config("vtsls", {
            filetypes = {
                "javascript", "javascriptreact", "javascript.jsx", "typescript",
                "typescriptreact", "typescript.tsx"
            },
            settings = {
                typescript = {
                    preferences = {
                        includePackageJsonAutoImports = "on",
                        includeCompletionsForModuleExports = true,
                        includeCompletionsForImportStatements = true
                    },
                    inlayHints = {
                        parameterNames = {enabled = "all"},
                        parameterTypes = {enabled = true},
                        variableTypes = {enabled = true},
                        propertyDeclarationTypes = {enabled = true},
                        functionLikeReturnTypes = {enabled = true},
                        enumMemberValues = {enabled = true}
                    }
                },
                javascript = {
                    preferences = {
                        includePackageJsonAutoImports = "on",
                        includeCompletionsForModuleExports = true,
                        includeCompletionsForImportStatements = true
                    },
                    inlayHints = {
                        parameterNames = {enabled = "all"},
                        parameterTypes = {enabled = true},
                        variableTypes = {enabled = true},
                        propertyDeclarationTypes = {enabled = true},
                        functionLikeReturnTypes = {enabled = true},
                        enumMemberValues = {enabled = true}
                    }
                }
            }
        })

        vim.lsp.config("gopls", {
            settings = {
                gopls = {
                    analyses = {unusedparams = true},
                    staticcheck = true,
                    gofumpt = true,
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true
                    }
                }
            }
        })

        vim.lsp.config("clangd", {
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=never",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
            },
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
            },
        })

        vim.lsp.config("cssls", {
            filetypes = {"css", "scss", "less"},
            init_options = {provideFormatter = false},
            single_file_support = true,
            settings = {
                css = {lint = {unknownAtRules = "ignore"}, validate = true},
                scss = {lint = {unknownAtRules = "ignore"}, validate = true},
                less = {lint = {unknownAtRules = "ignore"}, validate = true}
            }
        })

        vim.lsp.config("tailwindcss", {
            filetypes = {
                "astro", "css", "html", "javascript", "javascriptreact",
                "svelte", "typescript", "typescriptreact", "vue"
            },
            init_options = {userLanguages = {astro = "html"}}
        })

        vim.lsp.config("astro", {
            filetypes = {"astro"},
            init_options = {
                typescript = {
                    tsdk = vim.fn.stdpath("data") ..
                        "/mason/packages/typescript-language-server/node_modules/typescript/lib"
                }
            }
        })

        local servers = {
            "angularls", "ansiblels", "astro", "bashls", "biome", "clangd",
            "cmake", "cssls", "cssmodules_ls",
            "docker_compose_language_service", "dockerls",
            "emmet_language_server", "eslint", "gdscript", "gopls", "graphql",
            "html", "jsonls", "lua_ls", "marksman", "ols", "omnisharp",
            "prismals", "pyright", "ruff", "sqlls", "svelte", "tailwindcss",
            "taplo", "terraformls", "texlab", "vtsls", "vue_ls", "yamlls",
            "zls"
        }

        for _, server in ipairs(servers) do
            pcall(vim.lsp.enable, server)
        end
    end
}
