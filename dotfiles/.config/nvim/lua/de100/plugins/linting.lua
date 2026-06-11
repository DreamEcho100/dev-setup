-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/10-formatting-linting.md
return {
    "mfussenegger/nvim-lint",
    event = {"BufReadPre", "BufNewFile"},
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            bash = {"shellcheck"},
            go = {"golangci-lint"},
            c = {"clangtidy", "cpplint"},
            cpp = {"clangtidy", "cpplint"},
            javascript = {"biomejs", "eslint_d"},
            javascriptreact = {"biomejs", "eslint_d"},
            lua = {"luacheck"},
            markdown = {"markdownlint", "codespell"},
            python = {"ruff", "pylint"},
            sh = {"shellcheck"},
            svelte = {"biomejs", "eslint_d"},
            typescript = {"biomejs", "eslint_d"},
            typescriptreact = {"biomejs", "eslint_d"},
            yaml = {"yamllint"}
        }

        local lint_augroup = vim.api.nvim_create_augroup("nvim-lint",
                                                         {clear = true})
        vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost", "InsertLeave"},
                                    {
            group = lint_augroup,
            callback = function() lint.try_lint() end
        })

        vim.keymap.set("n", "<leader>ll", function() lint.try_lint() end,
                       {desc = "Trigger linting for current file"})
    end
}
