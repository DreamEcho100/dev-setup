-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/12-sessions-workspace.md
return {
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    init = function()
        vim.api.nvim_create_user_command("De100KulalaParserInstall", function()
            require("lazy").load({ plugins = { "kulala.nvim" } })
            local config = require("kulala.config").get()
            config.treesitter.enable = true
            require("kulala.config.parser").setup()
        end, { desc = "Install/build Kulala HTTP Treesitter parser explicitly" })
    end,
    keys = {
        {
            "<leader>Hr",
            function()
                require("kulala").run()
            end,
            desc = "Run HTTP request",
        },
        {
            "<leader>Ha",
            function()
                require("kulala").run_all()
            end,
            desc = "Run all HTTP requests",
        },
        {
            "<leader>Hp",
            function()
                require("kulala").replay()
            end,
            desc = "Replay last request",
        },
        {
            "<leader>Hi",
            function()
                require("kulala").inspect()
            end,
            desc = "Inspect request",
        },
        {
            "<leader>Hc",
            function()
                require("kulala").copy()
            end,
            desc = "Copy as cURL",
        },
        {
            "<leader>HE",
            function()
                require("kulala").set_selected_env()
            end,
            desc = "Set environment",
        },
        {
            "]r",
            function()
                require("kulala").jump_next()
            end,
            ft = "http",
            desc = "Next request",
        },
        {
            "[r",
            function()
                require("kulala").jump_prev()
            end,
            ft = "http",
            desc = "Prev request",
        },
    },
    opts = {
        default_view = "body",
        default_env = "dev",
        debug = false,
        show_icons = "on_request",
        -- Do not fetch/build Kulala's custom parser during normal startup or
        -- session restore. Run :De100KulalaParserInstall when working on .http
        -- files and you want the enhanced parser prepared explicitly.
        treesitter = { enable = false, cli_path = "tree-sitter" },
        contenttypes = {
            ["application/json"] = {
                ft = "json",
                pathresolver = nil,
                show_icons = true,
            },
            ["application/xml"] = {
                ft = "xml",
                pathresolver = nil,
                show_icons = true,
            },
            ["text/html"] = { ft = "html", pathresolver = nil, show_icons = true },
        },
    },
}
