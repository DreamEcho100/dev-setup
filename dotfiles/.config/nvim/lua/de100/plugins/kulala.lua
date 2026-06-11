-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/12-sessions-workspace.md
return {
    "mistweaverco/kulala.nvim",
    ft = {"http", "rest"},
    keys = {
        {"<leader>Hr", function() require("kulala").run() end, desc = "Run HTTP request"},
        {"<leader>Ha", function() require("kulala").run_all() end, desc = "Run all HTTP requests"},
        {"<leader>Hp", function() require("kulala").replay() end, desc = "Replay last request"},
        {"<leader>Hi", function() require("kulala").inspect() end, desc = "Inspect request"},
        {"<leader>Hc", function() require("kulala").copy() end, desc = "Copy as cURL"},
        {"<leader>HE", function() require("kulala").set_selected_env() end, desc = "Set environment"},
        {"]r", function() require("kulala").jump_next() end, ft = "http", desc = "Next request"},
        {"[r", function() require("kulala").jump_prev() end, ft = "http", desc = "Prev request"}
    },
    opts = {
        default_view = "body",
        default_env = "dev",
        debug = false,
        show_icons = "on_request",
        contenttypes = {
            ["application/json"] = {ft = "json", pathresolver = nil, show_icons = true},
            ["application/xml"] = {ft = "xml", pathresolver = nil, show_icons = true},
            ["text/html"] = {ft = "html", pathresolver = nil, show_icons = true}
        }
    }
}
