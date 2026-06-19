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
            "<leader>tn",
            function() require("neotest").run.run() end,
            desc = "Test: Run nearest",
        },
        {
            "<leader>tf",
            function() require("neotest").run.run(vim.fn.expand("%")) end,
            desc = "Test: Run file",
        },
        {
            "<leader>tl",
            function() require("neotest").run.run_last() end,
            desc = "Test: Run last",
        },
        {
            "<leader>to",
            function() require("neotest").output.open({ enter = true }) end,
            desc = "Test: Open output",
        },
        {
            "<leader>ts",
            function() require("neotest").summary.toggle() end,
            desc = "Test: Toggle summary",
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
