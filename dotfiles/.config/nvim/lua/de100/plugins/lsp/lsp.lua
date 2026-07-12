-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/07-lsp-and-completions.md
return {
    "neovim/nvim-lspconfig",
    event = {"BufReadPre", "BufNewFile"},
    dependencies = {
        "saghen/blink.cmp",
        {"antosha417/nvim-lsp-file-operations", config = true}
    },
    config = function()
        local uri_scheme_pattern = "^%a[%w+.-]*:"
        local malformed_diagnostics_log = vim.fs.joinpath(vim.fn.stdpath("state"),
                                                          "de100",
                                                          "lsp-malformed-diagnostics.log")

        local function is_valid_diagnostic_uri(uri)
            return type(uri) == "string" and uri ~= "" and
                       uri:match(uri_scheme_pattern) ~= nil
        end

        local function append_malformed_diagnostic_log(uri, ctx, result)
            local client = ctx and vim.lsp.get_client_by_id(ctx.client_id)
            local bufnr = ctx and ctx.bufnr
            local bufname = bufnr and vim.api.nvim_buf_is_valid(bufnr) and
                                vim.api.nvim_buf_get_name(bufnr) or ""
            local diagnostics = result and result.diagnostics or {}
            local first_diagnostic = diagnostics[1]

            vim.fn.mkdir(vim.fs.dirname(malformed_diagnostics_log), "p")

            local fd = io.open(malformed_diagnostics_log, "a")
            if not fd then return end

            fd:write(("\n[%s] malformed LSP diagnostics\n"):format(
                         os.date("!%Y-%m-%dT%H:%M:%SZ")))
            fd:write(("client: %s (%s)\n"):format(
                         client and client.name or "unknown",
                         ctx and tostring(ctx.client_id) or "nil"))
            fd:write(("method: %s\n"):format(ctx and ctx.method or "unknown"))
            fd:write(("uri: %s\n"):format(vim.inspect(uri)))
            fd:write(("buffer: %s\n"):format(bufname ~= "" and bufname or
                                                 "[No Name]"))
            fd:write(("cwd: %s\n"):format(vim.fn.getcwd()))
            fd:write(("root: %s\n"):format(client and client.config and
                                               client.config.root_dir or "nil"))
            fd:write(("diagnostic_count: %d\n"):format(#diagnostics))

            if first_diagnostic then
                fd:write(("first_source: %s\n"):format(
                             tostring(first_diagnostic.source)))
                fd:write(("first_code: %s\n"):format(
                             tostring(first_diagnostic.code)))
                fd:write(("first_message: %s\n"):format(
                             tostring(first_diagnostic.message)))
            end

            fd:close()
        end

        local publish_diagnostics_handler =
            vim.lsp.handlers["textDocument/publishDiagnostics"] or
                vim.lsp.diagnostic.on_publish_diagnostics

        vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err,
                                                                       result,
                                                                       ctx,
                                                                       config)
            if result and not is_valid_diagnostic_uri(result.uri) then
                append_malformed_diagnostic_log(result.uri, ctx, result)
                vim.notify_once(
                    "Dropped malformed LSP diagnostics; run :De100LspBadDiagnostics to inspect the sender.",
                    vim.log.levels.WARN)
                return
            end

            local ok, handler_err =
                pcall(publish_diagnostics_handler, err, result, ctx, config)
            if not ok then
                vim.notify_once("Ignored LSP diagnostics handler error: " ..
                                    tostring(handler_err), vim.log.levels.WARN)
            end
        end

        vim.api.nvim_create_user_command("De100LspBadDiagnostics", function()
            if vim.fn.filereadable(malformed_diagnostics_log) == 0 then
                vim.notify("No malformed LSP diagnostics have been logged.",
                           vim.log.levels.INFO)
                return
            end

            vim.cmd.edit(vim.fn.fnameescape(malformed_diagnostics_log))
        end, {desc = "Open malformed LSP diagnostics trace log"})

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
                                                        vim.lsp.buf.references),
                               opts)

                opts.desc = "Go to declaration"
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

                opts.desc = "Show LSP definitions"
                vim.keymap.set("n", "gd", snacks_picker("lsp_definitions",
                                                        vim.lsp.buf.definition),
                               opts)

                opts.desc = "Show LSP implementations"
                vim.keymap.set("n", "gi", snacks_picker("lsp_implementations",
                                                        vim.lsp.buf
                                                            .implementation),
                               opts)

                opts.desc = "Show LSP type definitions"
                vim.keymap.set("n", "gt", snacks_picker("lsp_type_definitions",
                                                        vim.lsp.buf
                                                            .type_definition),
                               opts)

                opts.desc = "Code actions"
                vim.keymap.set({"n", "v"}, "<leader>ca",
                               vim.lsp.buf.code_action, opts)

                opts.desc = "Smart rename"
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

                opts.desc = "Show buffer diagnostics"
                vim.keymap.set("n", "<leader>D", function()
                    require("snacks").picker.diagnostics_buffer()
                end, opts)

                opts.desc = "Show line diagnostics"
                vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float,
                               opts)

                opts.desc = "Hover documentation"
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

                opts.desc = "Signature help"
                vim.keymap.set({"n", "i"}, "<leader>ls",
                               vim.lsp.buf.signature_help, opts)

                -- Header ↔ source switch for C/C++ (clangd only)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if client and client.name == "clangd" then
                    opts.desc = "Switch header/source (C/C++)"
                    vim.keymap.set("n", "<leader>lspch",
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
            virtual_text = {
                severity = {min = vim.diagnostic.severity.WARN},
                spacing = 2,
                source = "if_many",
                prefix = "●"
            },
            virtual_lines = false,
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
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({
                bufnr = 0
            }), {bufnr = 0})
        end, {desc = "Toggle inlay hints"})

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local blink_ok, blink_cmp = pcall(require, "blink.cmp")
        if blink_ok and type(blink_cmp.get_lsp_capabilities) == "function" then
            capabilities = blink_cmp.get_lsp_capabilities(capabilities)
        else
            vim.notify_once(
                "blink.cmp capabilities unavailable; starting LSP with default Neovim capabilities.",
                vim.log.levels.WARN
            )
        end
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
                "astro", "css", "eruby", "html", "htmldjango",
                "javascriptreact", "less", "pug", "sass", "scss", "svelte",
                "typescriptreact", "vue"
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
            root_dir = function(bufnr, on_dir)
                on_dir(vim.fs.root(bufnr, "go.work") or
                           vim.fs.root(bufnr, "go.mod") or
                           vim.fs.root(bufnr, ".git"))
            end,
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

        vim.api.nvim_create_user_command("De100Doctor", function()
            local bufnr = vim.api.nvim_get_current_buf()
            local filename = vim.api.nvim_buf_get_name(bufnr)
            local file_dir = filename ~= "" and vim.fs.dirname(filename) or
                                 vim.fn.getcwd()
            local go_work_root = vim.fs.root(bufnr, "go.work")
            local go_mod_root = vim.fs.root(bufnr, "go.mod")
            local go_cwd = go_work_root or go_mod_root or file_dir

            local lines = {
                "filetype: " .. vim.bo[bufnr].filetype,
                "buffer: " .. (filename ~= "" and filename or "[No Name]"),
                "cwd: " .. vim.fn.getcwd(),
                "stdpath(data): " .. vim.fn.stdpath("data"),
                "stdpath(state): " .. vim.fn.stdpath("state"),
                "stdpath(cache): " .. vim.fn.stdpath("cache")
            }

            local doctor_blink_ok, doctor_blink = pcall(require, "blink.cmp")
            if doctor_blink_ok and type(doctor_blink.library_available) ==
                "function" then
                local native_ok, native_available =
                    pcall(doctor_blink.library_available)
                table.insert(lines, "blink native: " ..
                                 (native_ok and tostring(native_available) or
                                     "error"))
            else
                table.insert(lines, "blink native: unavailable")
            end

            local clients = vim.lsp.get_clients({bufnr = bufnr})
            if #clients == 0 then
                table.insert(lines, "lsp clients: none")
            else
                table.insert(lines, "lsp clients:")
                for _, client in ipairs(clients) do
                    table.insert(lines, ("  - %s root=%s"):format(client.name,
                                                                  client.config
                                                                      .root_dir or
                                                                      "nil"))
                end
            end

            table.insert(lines, "go.work root: " .. (go_work_root or "nil"))
            table.insert(lines, "go.mod root: " .. (go_mod_root or "nil"))

            if vim.fn.executable("go") == 1 then
                local result = vim.system({"go", "env", "GOWORK"},
                                          {cwd = go_cwd, text = true}):wait(3000)
                local gowork = result and result.code == 0 and
                                   vim.trim(result.stdout or "") or "error"
                table.insert(lines,
                             "go env GOWORK: " ..
                                 (gowork ~= "" and gowork or "off"))
            else
                table.insert(lines, "go env GOWORK: go not found")
            end

            vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO,
                       {title = "De100Doctor"})
        end, {desc = "Show current buffer Blink/LSP/Go diagnostic state"})

        vim.lsp.config("jdtls", {
            root_dir = function(bufnr, on_dir)
                on_dir(vim.fs.root(bufnr, {
                    "gradlew", "mvnw", "pom.xml", "build.gradle", ".git"
                }))
            end,
            settings = {
                java = {
                    signatureHelp = {enabled = true},
                    completion = {favoriteStaticMembers = {}},
                    contentProvider = {preferred = "fernflower"},
                    sources = {
                        organizeImports = {
                            starThreshold = 9999,
                            staticStarThreshold = 9999
                        }
                    }
                }
            }
        })

        vim.lsp.config("clangd", {
            cmd = {
                "clangd", "--background-index", "--clang-tidy",
                "--header-insertion=never", "--completion-style=detailed",
                "--function-arg-placeholders", "--fallback-style=llvm"
            },
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true
            }
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
            "html", "jdtls", "jsonls", "lua_ls", "marksman", "ols", "prismals",
            "pyright", "ruff", "sqlls", "svelte", "tailwindcss", "taplo",
            "terraformls", "texlab", "vtsls", "vue_ls", "yamlls", "zls"
        }

        local enable_failures = {}
        for _, server in ipairs(servers) do
            local ok, err = pcall(vim.lsp.enable, server)
            if not ok then
                table.insert(enable_failures, server .. ": " .. tostring(err))
            end
        end

        if #enable_failures > 0 then
            vim.notify_once("LSP enable failures:\n" ..
                                table.concat(enable_failures, "\n"),
                            vim.log.levels.WARN)
        end
    end
}
