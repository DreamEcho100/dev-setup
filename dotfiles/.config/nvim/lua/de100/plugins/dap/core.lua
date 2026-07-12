-- Tutorial: docs/neovim-tutorials-from-0-to-hero/09-debug-test-build.md
return {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
        "leoluz/nvim-dap-go",
        "mfussenegger/nvim-dap-python",
        "jbyuki/one-small-step-for-vimkind",
    },
    keys = {
        {
            "<F5>",
            function()
                require("dap").continue()
            end,
            desc = "Debug: Start/continue",
        },
        {
            "<F9>",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "Debug: Toggle breakpoint",
        },
        {
            "<F10>",
            function()
                require("dap").step_over()
            end,
            desc = "Debug: Step over",
        },
        {
            "<F11>",
            function()
                require("dap").step_into()
            end,
            desc = "Debug: Step into",
        },
        {
            "<S-F11>",
            function()
                require("dap").step_out()
            end,
            desc = "Debug: Step out",
        },
        {
            "<S-F5>",
            function()
                require("dap").terminate()
            end,
            desc = "Debug: Terminate",
        },
        {
            "<F7>",
            function()
                require("dapui").toggle()
            end,
            desc = "Debug: Toggle UI",
        },
        {
            "<leader>dapc",
            function()
                require("dap").continue()
            end,
            desc = "Debug: Start/continue",
        },
        { "<leader>dapn", "<cmd>DapNew<cr>", desc = "Debug: New session" },
        {
            "<leader>dapx",
            function()
                require("dap").terminate()
            end,
            desc = "Debug: Terminate",
        },
        {
            "<leader>dapl",
            function()
                require("dap").run_last()
            end,
            desc = "Debug: Run last",
        },
        {
            "<leader>dapo",
            function()
                require("dap").step_over()
            end,
            desc = "Debug: Step over",
        },
        {
            "<leader>dapi",
            function()
                require("dap").step_into()
            end,
            desc = "Debug: Step into",
        },
        {
            "<leader>dapO",
            function()
                require("dap").step_out()
            end,
            desc = "Debug: Step out",
        },
        {
            "<leader>dapp",
            function()
                require("dap").pause()
            end,
            desc = "Debug: Pause",
        },
        {
            "<leader>dapt",
            function()
                require("de100.config.dap.core").debug_nearest_test()
            end,
            desc = "Debug: Nearest test",
        },
        {
            "<leader>daptb",
            function()
                require("dap").toggle_breakpoint()
            end,
            desc = "Debug: Toggle breakpoint",
        },
        {
            "<leader>dapb",
            function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end,
            desc = "Debug: Conditional breakpoint",
        },
        {
            "<leader>dapL",
            function()
                require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
            end,
            desc = "Debug: Log point",
        },
        {
            "<leader>dapr",
            function()
                require("dap").repl.open()
            end,
            desc = "Debug: Open REPL",
        },
        {
            "<leader>dape",
            function()
                require("dapui").eval()
            end,
            mode = { "n", "v" },
            desc = "Debug: Evaluate",
        },
        {
            "<leader>dapu",
            function()
                require("dapui").toggle()
            end,
            desc = "Debug: Toggle UI",
        },
        {
            "<leader>dapq",
            function()
                require("dap").list_breakpoints(true)
            end,
            desc = "Debug: List breakpoints",
        },
        {
            "<leader>dapC",
            function()
                require("dap").clear_breakpoints()
            end,
            desc = "Debug: Clear breakpoints",
        },
        { "<leader>daph", "<cmd>De100DapHealth<cr>", desc = "Debug: Health" },
        {
            "<leader>dapP",
            function()
                require("de100.config.dap.core").load_project()
            end,
            desc = "Debug: Load trusted project config",
        },
    },
    config = function()
        local util = require("de100.config.dap.util")
        require("de100.config.dap.core").setup()
        for _, module in ipairs({
            "web",
            "python",
            "go",
            "native",
            "lua",
            "optional",
        }) do
            util.setup_module(module)
        end
    end,
}
