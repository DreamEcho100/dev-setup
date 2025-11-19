-- https://github.com/stevearc/conform.nvim
return {
    "stevearc/conform.nvim",
    event = {"BufReadPre", "BufNewFile"},

    cmd = {"ConformInfo"},
    keys = {
        {
            -- Customize or remove this keymap to your liking
            "<leader>f",
            function() require("conform").format({async = true}) end,
            mode = "",
            desc = "Format buffer"
        }, -- Format current buffer
        {
            "<leader>mp",
            function()
                require("conform").format({
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 1000
                })
            end,
            mode = {"n", "v"},
            desc = "Format file or range (in visual mode)"
        }
    },
    -- This will provide type hinting with LuaLS
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
        -- Define your formatters
        formatters_by_ft = {
            javascript = {
                "biome",
                "prettierd",
                "prettier",
                stop_after_first = true
            },
            typescript = {
                "biome",
                "prettierd",
                "prettier",
                stop_after_first = true
            },
            javascriptreact = {
                "biome",
                "prettierd",
                "prettier",
                stop_after_first = true
            },
            typescriptreact = {
                "biome",
                "prettierd",
                "prettier",
                stop_after_first = true
            },
            svelte = {"biome", "prettierd", "prettier", stop_after_first = true},
            css = {"biome", "prettierd", "prettier", stop_after_first = true},
            html = {"biome", "prettierd", "prettier", stop_after_first = true},
            json = {"biome", "prettierd", "prettier", stop_after_first = true},
            yaml = {"biome", "prettierd", "prettier", stop_after_first = true},
            markdown = {
                "biome",
                "prettierd",
                "prettier",
                stop_after_first = true
            },
            graphql = {
                "biome",
                "prettierd",
                "prettier",
                stop_after_first = true
            },
            liquid = {"biome", "prettierd", "prettier", stop_after_first = true},
            lua = {"stylua"},
            python = {"isort", "black"},
            c = {"clang_format"},
            cpp = {"clang_format"}
        },
        -- Set default options
        default_format_opts = {lsp_format = "fallback"},
        -- Set up format-on-save
        format_on_save = {lsp_fallback = true, async = false, timeout_ms = 3000},
        -- Customize formatters
        formatters = {shfmt = {append_args = {"-i", "2"}}}
    },
    -- init = function()
    --     -- If you want the formatexpr, here is the place to set it
    --     vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    -- end,

    config = function()
        local conform = require("conform")

        vim.api.nvim_create_autocmd("BufWritePre", {
            desc = "Format before save",
            pattern = "*",
            group = vim.api.nvim_create_augroup("FormatConfig", {clear = true}),
            callback = function(ev)
                local conform_opts = {
                    bufnr = ev.buf,
                    lsp_format = "fallback",
                    timeout_ms = 2000
                }
                local client = vim.lsp.get_clients({
                    name = "ts_ls",
                    bufnr = ev.buf
                })[1]

                if not client then
                    require("conform").format(conform_opts)
                    return
                end

                local request_result = client:request_sync(
                                           "workspace/executeCommand", {
                        command = "_typescript.organizeImports",
                        arguments = {vim.api.nvim_buf_get_name(ev.buf)}
                    })

                if request_result and request_result.err then
                    vim.notify(request_result.err.message, vim.log.levels.ERROR)
                    return
                end

                require("conform").format(conform_opts)
            end
        })

        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*",
            callback = function(args)
                require("conform").format({bufnr = args.buf})
            end
        })
    end
}

-- biome-check
-- biome-organize-imports
