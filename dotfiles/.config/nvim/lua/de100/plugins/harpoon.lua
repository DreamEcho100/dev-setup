-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/06-files-buffers-windows-tabs.md
return {
    "thePrimeagen/harpoon",
    enabled = true,
    branch = "harpoon2",
    dependencies = {"nvim-lua/plenary.nvim"},
    config = function()
        local harpoon = require("harpoon")

        harpoon:setup({
            global_settings = {save_on_toggle = true, save_on_change = true}
        })

        -- Harpoon Nav Interface
        vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end,
                       {desc = "Harpoon add file"})
        vim.keymap.set("n", "<leader>hh", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, {desc = "Harpoon quick menu"})

        -- Harpoon marked files
        vim.keymap.set("n", "<leader>h1",
                       function() harpoon:list():select(1) end,
                       {desc = "Harpoon file 1"})
        vim.keymap.set("n", "<leader>h2",
                       function() harpoon:list():select(2) end,
                       {desc = "Harpoon file 2"})
        vim.keymap.set("n", "<leader>h3",
                       function() harpoon:list():select(3) end,
                       {desc = "Harpoon file 3"})
        vim.keymap.set("n", "<leader>h4",
                       function() harpoon:list():select(4) end,
                       {desc = "Harpoon file 4"})

        -- Toggle previous & next buffers stored within Harpoon list
        vim.keymap.set("n", "<leader>hp", function()
            harpoon:list():prev()
        end, {desc = "Harpoon previous"})
        vim.keymap.set("n", "<leader>hn", function()
            harpoon:list():next()
        end, {desc = "Harpoon next"})

    end
}
