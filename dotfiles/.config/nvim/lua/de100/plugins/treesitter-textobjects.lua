-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/21-python-math-jupyter.md
-- Structural code-cell navigation for markdown notebooks (jupytext/quarto):
-- jump between ALL fenced code blocks, whether or not you've run them yet.
-- Complements molten's own ]j/[j (plugins/molten.lua), which only jump
-- between cells you've already evaluated — this is the documented pattern
-- from molten-nvim's own docs/Notebook-Setup.md "Treesitter Text Objects"
-- section, adapted for the newer nvim-treesitter-textobjects API (the
-- `nvim-treesitter-textobjects.move` module), since this config uses
-- main-branch nvim-treesitter, not the old `nvim-treesitter.configs`
-- module system that doc's example assumed.
-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    ft = { "markdown", "quarto" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    init = function()
        -- Disable built-in ftplugin mappings to avoid conflicts.
        vim.g.no_plugin_maps = true
    end,
    config = function()
        require("nvim-treesitter-textobjects").setup({
            move = { set_jumps = true },
        })

        local move = require("nvim-treesitter-textobjects.move")

        vim.keymap.set({ "n", "x", "o" }, "]b", function()
            move.goto_next_start("@code_cell.inner", "textobjects")
        end, { desc = "Jupyter: next code block (run or not)" })

        vim.keymap.set({ "n", "x", "o" }, "[b", function()
            move.goto_previous_start("@code_cell.inner", "textobjects")
        end, { desc = "Jupyter: prev code block (run or not)" })
    end,
}
