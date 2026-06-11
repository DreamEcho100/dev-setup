-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/05-search-and-replace.md
return {
    {
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        opts = {headerMaxWidth = 80, startInInsertMode = true},
        keys = {
            {
                "<leader>ps",
                "<cmd>GrugFar<CR>",
                desc = "Search and replace project"
            }, {
                "<leader>pS",
                function()
                    require("grug-far").open({
                        prefills = {search = vim.fn.expand("<cword>")}
                    })
                end,
                desc = "Search and replace word"
            }
        }
    }
}
