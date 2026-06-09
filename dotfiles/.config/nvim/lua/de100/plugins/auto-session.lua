return {
    "rmagatti/auto-session",
    config = function()
        local auto_session = require("auto-session")

        vim.o.sessionoptions =
            "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

        auto_session.setup({
            auto_restore = false,
            suppressed_dirs = {
                "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/"
            }
        })

        local keymap = vim.keymap
        keymap.set("n", "<leader>wr", "<cmd>AutoSession restore<CR>",
                   {desc = "Restore session for cwd"})
        keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>",
                   {desc = "Save session for cwd"})
    end
}
