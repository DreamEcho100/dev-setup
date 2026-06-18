-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/09-debug-test-build.md
return {
    "stevearc/overseer.nvim",
    cmd = {
        "OverseerOpen",
        "OverseerRun",
        "OverseerToggle",
        "OverseerQuickAction",
    },
    opts = { templates = { "builtin" } },
    keys = {
        { "<leader>tr", "<cmd>OverseerRun<CR>", desc = "Run task" },
        { "<leader>tt", "<cmd>OverseerToggle<CR>", desc = "Toggle tasks" },
        { "<leader>ta", "<cmd>OverseerQuickAction<CR>", desc = "Task action" },
    },
    config = function(_, opts)
        local overseer = require("overseer")

        local function go_module_root()
            local bufnr = vim.api.nvim_get_current_buf()
            return vim.fs.root(bufnr, "go.mod") or vim.fs.root(bufnr, "go.work") or vim.fn.getcwd()
        end

        local function go_package_target()
            local filename = vim.api.nvim_buf_get_name(0)
            if filename == "" then
                return "./..."
            end

            local root = go_module_root()
            local file_dir = vim.fs.dirname(filename)
            local rel = vim.fs.relpath(root, file_dir)
            if rel and rel ~= "" and rel ~= "." then
                return "./" .. rel
            end

            return "."
        end

        local function register_go_task(name, args)
            overseer.register_template({
                name = name,
                builder = function()
                    return {
                        cmd = "go",
                        args = type(args) == "function" and args() or args,
                        cwd = go_module_root(),
                    }
                end,
                condition = { filetype = { "go", "gomod", "gowork" } },
            })
        end

        overseer.setup(opts)

        register_go_task("Go: test all packages", { "test", "./..." })
        register_go_task("Go: test current package", function()
            return { "test", go_package_target() }
        end)
        register_go_task("Go: build current module", { "build", "./..." })
        register_go_task("Go: mod tidy", { "mod", "tidy" })
        overseer.register_template({
            name = "Go: golangci-lint current module",
            builder = function()
                return {
                    cmd = "golangci-lint",
                    args = { "run", "./..." },
                    cwd = go_module_root(),
                }
            end,
            condition = { filetype = { "go", "gomod", "gowork" } },
        })
    end,
}
