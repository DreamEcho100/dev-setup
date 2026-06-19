-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/09-debug-test-build.md
return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-python",
        "nvim-neotest/neotest-plenary",
        "marilari88/neotest-vitest",
        "rouge8/neotest-rust",
        { "fredrikaverpil/neotest-golang", version = "*" },
        -- C/C++ testing via CTest; supports GoogleTest, Catch2, doctest.
        -- Requires cmake-tools.nvim to build before running tests.
        "orjangj/neotest-ctest",
    },
    keys = {
        {
            "<leader>tN",
            function()
                require("neotest").run.run()
            end,
            desc = "Run nearest test",
        },
        {
            "<leader>tF",
            function()
                require("neotest").run.run(vim.fn.expand("%"))
            end,
            desc = "Run file tests",
        },
        {
            "<leader>tO",
            function()
                require("neotest").output.open({ enter = true })
            end,
            desc = "Open test output",
        },
        {
            "<leader>tS",
            function()
                require("neotest").summary.toggle()
            end,
            desc = "Toggle test summary",
        },
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-python")({ dap = { justMyCode = false } }),
                require("neotest-plenary"),
                require("neotest-vitest"),
                require("neotest-rust"),
                require("neotest-golang")({ runner = "gotestsum" }),
                require("neotest-ctest").setup({}),
            },
        })
    end,
}
