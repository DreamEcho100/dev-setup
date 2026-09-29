-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/10-formatting-linting.md
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"
vim.opt_local.wrap = true
vim.opt_local.textwidth = 0
vim.opt_local.conceallevel = 2
vim.opt_local.colorcolumn = ""

-- Jupyter/quarto notebooks: jupytext converts .ipynb to markdown, and
-- quarto-nvim's own ftplugin only auto-activates for filetype=quarto, never
-- markdown — this is the documented fix from molten-nvim's own
-- Notebook-Setup.md for exactly this combination.
require("quarto").activate()
