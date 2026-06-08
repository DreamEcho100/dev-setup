return {
    "mfussenegger/nvim-lint",
    event = {"BufReadPre", "BufNewFile"},
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            python = {"black", "pylint"},
            javascript = {"biomejs", "eslint_d"},
            typescript = {"biomejs", "eslint_d"},
            javascriptreact = {"biomejs", "eslint_d"},
            typescriptreact = {"biomejs", "eslint_d"},
            svelte = {"biomejs", "eslint_d"},
            lua = {"luacheck"},
            sh = {"shellcheck"},
            c = {"clangtidy"},
            cpp = {"clangtidy"}
        }

        local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", {clear = true})
        vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost", "InsertLeave"},
                                    {
            group = lint_augroup,
            callback = function() lint.try_lint() end
        })

        vim.keymap.set("n", "<leader>l", function() lint.try_lint() end,
                       {desc = "Trigger linting for current file"})
    end
}
