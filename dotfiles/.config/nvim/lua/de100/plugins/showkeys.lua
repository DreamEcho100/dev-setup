return {
    {
        "nvzone/showkeys",
        lazy = true,
        cmd = "ShowkeysToggle",
        keys = {
            {"<leader>ks", "<cmd>ShowkeysToggle<CR>", desc = "Toggle Showkeys"}
        },
        opts = {
            position = "top-right",
            maxkeys = 3,
            show_count = true,
            winopts = {
                focusable = false,
                relative = "editor",
                style = "minimal",
                border = "single",
                height = 1,
                row = 1,
                col = 0
            }
        }
    }
}
