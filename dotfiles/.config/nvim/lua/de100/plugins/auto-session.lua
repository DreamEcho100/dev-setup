-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/06-files-buffers-windows-tabs.md
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
        -- Removed: restore is typically automatic or a rare manual action,
        -- 1:1 wrapper around `:AutoSession restore` — call it directly.
        -- keymap.set("n", "<leader>wr", "<cmd>AutoSession restore<CR>",
        --            {desc = "Restore session for cwd"})
        keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>",
                   {desc = "Save session for cwd"})
    end
}
