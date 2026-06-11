return {
    "stevearc/conform.nvim",
    event = {"BufReadPre", "BufNewFile"},
    config = function()
        local conform = require("conform")

        local web_formatters = {
            "biome-check",
            "prettierd",
            "prettier",
            stop_after_first = true
        }

        conform.setup({
            formatters_by_ft = {
                astro = web_formatters,
                css = web_formatters,
                graphql = web_formatters,
                html = web_formatters,
                javascript = web_formatters,
                javascriptreact = web_formatters,
                json = web_formatters,
                jsonc = web_formatters,
                less = web_formatters,
                liquid = web_formatters,
                markdown = web_formatters,
                scss = web_formatters,
                svelte = web_formatters,
                typescript = web_formatters,
                typescriptreact = web_formatters,
                vue = web_formatters,
                yaml = web_formatters,

                lua = {"stylua"},
                sh = {"shfmt"},
                bash = {"shfmt"},
                zsh = {"shfmt"},
                c = {"clang_format"},
                cpp = {"clang_format"},
                cs = {lsp_format = "fallback"},
                gdscript = {lsp_format = "fallback"},
                go = {"goimports", "gofumpt"},
                java = {"google-java-format"},
                rust = {"rustfmt", lsp_format = "fallback"},
                tex = {"latexindent"},
                zig = {"zigfmt"},

                python = function(bufnr)
                    if conform.get_formatter_info("ruff_format", bufnr)
                        .available then
                        return {"ruff_format", "ruff_organize_imports"}
                    end
                    return {"isort", "black"}
                end,

                ["*"] = {"codespell"},
                ["_"] = {"trim_whitespace"}
            },
            default_format_opts = {lsp_format = "fallback"},
            format_after_save = {lsp_format = "fallback"},
            log_level = vim.log.levels.ERROR,
            notify_on_error = true,
            notify_no_formatters = false,
            formatters = {
                prettier = {
                    args = {
                        "--stdin-filepath", "$FILENAME", "--tab-width", "2",
                        "--use-tabs", "true", "--trailing-comma", "all"
                    }
                },
                prettierd = {
                    args = {
                        "--stdin-filepath", "$FILENAME", "--tab-width", "2",
                        "--use-tabs", "true", "--trailing-comma", "all"
                    }
                },
                shfmt = {prepend_args = {"-i", "4"}}
            }
        })

        vim.keymap.set({"n", "v"}, "<leader>mp", function()
            conform.format({
                lsp_format = "fallback",
                async = false,
                timeout_ms = 1500
            })
        end, {desc = "Format file or range"})
    end
}
