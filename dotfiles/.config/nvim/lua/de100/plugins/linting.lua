-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/10-formatting-linting.md
return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        local function go_lint_context(bufnr)
            bufnr = bufnr or vim.api.nvim_get_current_buf()
            local filename = vim.api.nvim_buf_get_name(bufnr)
            if filename == "" then
                return nil
            end

            local file_dir = vim.fs.dirname(filename)
            local module_root = vim.fs.root(bufnr, "go.mod")
            local workspace_root = vim.fs.root(bufnr, "go.work")
            local cwd = module_root or workspace_root or file_dir
            local target = filename

            if module_root or workspace_root then
                local rel = vim.fs.relpath(cwd, file_dir)
                if rel and rel ~= "" and rel ~= "." then
                    target = "./" .. rel
                else
                    target = "."
                end
            end

            return { cwd = cwd, target = target }
        end

        local function goflags_without_vcs()
            local flags = {}
            for flag in vim.gsplit(vim.env.GOFLAGS or "", "%s+", { trimempty = true }) do
                if not flag:match("^%-buildvcs") then
                    table.insert(flags, flag)
                end
            end
            table.insert(flags, "-buildvcs=false")
            return table.concat(flags, " ")
        end

        local builtin_golangci = lint.linters.golangcilint
        local builtin_golangci_args = vim.deepcopy(builtin_golangci.args or {})

        lint.linters.golangcilint = vim.tbl_extend("force", builtin_golangci, {
            cmd = "/usr/bin/env",
            args = function()
                local args = vim.deepcopy(builtin_golangci_args)

                -- Keep nvim-lint's built-in version-specific JSON flags and parser,
                -- but lint the package directory from the nearest Go root.
                if #args > 0 then
                    args[#args] = function()
                        local context = go_lint_context()
                        return context and context.target or vim.api.nvim_buf_get_name(0)
                    end
                end

                table.insert(args, 1, builtin_golangci.cmd or "golangci-lint")
                table.insert(args, 1, "GOFLAGS=" .. goflags_without_vcs())
                return args
            end,
        })

        local function try_lint_go()
            local context = go_lint_context()
            if not context then
                return
            end

            lint.try_lint("golangcilint", { cwd = context.cwd })
        end

        lint.linters_by_ft = {
            bash = { "shellcheck" },
            go = { "golangcilint" },
            c = { "clangtidy", "cpplint" },
            cpp = { "clangtidy", "cpplint" },
            javascript = { "biomejs", "eslint_d" },
            javascriptreact = { "biomejs", "eslint_d" },
            lua = { "luacheck" },
            markdown = { "markdownlint", "codespell" },
            python = { "ruff", "pylint" },
            sh = { "shellcheck" },
            svelte = { "biomejs", "eslint_d" },
            typescript = { "biomejs", "eslint_d" },
            typescriptreact = { "biomejs", "eslint_d" },
            yaml = { "yamllint" },
        }

        local function try_lint()
            local ok, err = pcall(function()
                if vim.bo.filetype == "go" then
                    try_lint_go()
                    return
                end

                lint.try_lint()
            end)
            if not ok then
                vim.notify_once("nvim-lint: " .. tostring(err), vim.log.levels.WARN)
            end
        end

        local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function(args)
                if vim.bo[args.buf].filetype ~= "go" then
                    try_lint()
                end
            end,
        })
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = lint_augroup,
            pattern = "*.go",
            callback = try_lint,
        })

        vim.keymap.set("n", "<leader>ll", try_lint, { desc = "Trigger linting for current file" })
    end,
}
