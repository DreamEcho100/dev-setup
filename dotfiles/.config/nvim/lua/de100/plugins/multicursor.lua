-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/04-editing-mastery.md
return {
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
        local mc = require("multicursor-nvim")
        mc.setup()

        vim.keymap.set({"n", "v"}, "<leader>cm", mc.matchAddCursor,
                       {desc = "Add cursor at match"})
        vim.keymap.set({"n", "v"}, "<leader>cM", mc.matchAllAddCursors,
                       {desc = "Add cursors at all matches"})
        vim.keymap.set("n", "<esc>", function()
            if not mc.cursorsEnabled() then
                mc.enableCursors()
            elseif mc.hasCursors() then
                mc.clearCursors()
            else
                vim.cmd("nohlsearch")
            end
        end, {desc = "Clear search/cursors"})
    end
}
