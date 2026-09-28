-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/05-search-and-replace.md
return {
    {
        "MagicDuck/grug-far.nvim",
        cmd = "GrugFar",
        opts = {headerMaxWidth = 80, startInInsertMode = true},
        keys = {
            -- Keymap removed: 1:1 wrapper around `:GrugFar` with no prefill,
            -- call it directly. (The prefill version below, <leader>pS, stays
            -- since it does real work, not a bare passthrough.)
            -- {
            --     "<leader>ps",
            --     "<cmd>GrugFar<CR>",
            --     desc = "Search and replace project"
            -- },
            {
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
