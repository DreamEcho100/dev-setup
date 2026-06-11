return {
    "nvim-treesitter/nvim-treesitter-context",
    event = {"BufReadPost", "BufNewFile"},
    opts = {mode = "cursor", max_lines = 3},
    keys = {
        {
            "<leader>ut",
            function()
                local tsc = require("treesitter-context")
                tsc.toggle()
                local enabled = tsc.enabled and tsc.enabled()
                local notify = vim.notify
                if _G.LazyVim and _G.LazyVim.info and _G.LazyVim.warn then
                    notify = enabled and LazyVim.info or LazyVim.warn
                    notify((enabled and "Enabled" or "Disabled") ..
                               " Treesitter Context", {title = "Option"})
                else
                    notify((enabled and "Enabled" or "Disabled") ..
                               " Treesitter Context", enabled and
                               vim.log.levels.INFO or vim.log.levels.WARN)
                end
            end,
            desc = "Toggle Treesitter Context"
        }
    }
}
