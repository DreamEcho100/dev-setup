return {
    "stevearc/conform.nvim",
    event = {"BufReadPre", "BufNewFile"},
    config = function()
        local conform = require("conform")

        conform.setup({
            -- Define your formatters
            formatters_by_ft = {
                javascript = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                typescript = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                javascriptreact = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                typescriptreact = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                svelte = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                css = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                html = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                json = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                yaml = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                markdown = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                graphql = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                liquid = {
                    "biome-check",
                    "prettierd",
                    "prettier",
                    stop_after_first = true
                },
                lua = {"stylua"},
                c = {"clang_format"},
                cpp = {"clang_format"},
                -- Conform will run multiple formatters sequentially
                go = {"goimports", "gofmt"},
                -- You can also customize some of the format options for the filetype
                rust = {"rustfmt", lsp_format = "fallback"},
                -- You can use a function here to determine the formatters dynamically
                python = function(bufnr)
                    if require("conform").get_formatter_info("ruff_format",
                                                             bufnr).available then
                        return {"ruff_format"}
                    else
                        return {"isort", "black"}
                    end
                end,
                -- Use the "*" filetype to run formatters on all filetypes.
                ["*"] = {"codespell"},
                -- Use the "_" filetype to run formatters on filetypes that don't
                -- have other formatters configured.
                ["_"] = {"trim_whitespace"}
            },
            -- Set this to change the default values when calling conform.format()
            -- This will also affect the default values for format_on_save/format_after_save
            default_format_opts = {lsp_format = "fallback"},
            -- If this is set, Conform will run the formatter on save.
            -- It will pass the table to conform.format().
            -- This can also be a function that returns the table.
            -- format_on_save = {
            --     lsp_fallback = true,
            --     async = false,
            --     timeout_ms = 1000,
            -- },
            -- If this is set, Conform will run the formatter asynchronously after save.
            -- It will pass the table to conform.format().
            -- This can also be a function that returns the table.
            format_after_save = {lsp_format = "fallback"},
            -- Set the log level. Use `:ConformInfo` to see the location of the log file.
            log_level = vim.log.levels.ERROR,
            -- Conform will notify you when a formatter errors
            notify_on_error = true,
            -- Conform will notify you when no formatters are available for the buffer
            notify_no_formatters = true,
            formatters = {shfmt = {append_args = {"-i", "2"}}}
        })

        -- Configure individual formatters
        conform.formatters.prettier = {
            args = {
                "--stdin-filepath", "$FILENAME", "--tab-width", "4",
                "--use-tabs", "false"
            }
        }
        conform.formatters.shfmt = {prepend_args = {"-i", "4"}}

        vim.keymap.set({"n", "v"}, "<leader>mp", function()
            conform.format(
                {lsp_fallback = true, async = false, timeout_ms = 1000})
        end, {desc = "Format whole file or range in visual mode"})
    end
}
