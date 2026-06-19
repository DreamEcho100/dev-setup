-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/10-formatting-linting.md
-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/18-cpp-development.md
vim.opt_local.expandtab = true   -- spaces, not tabs (C++ community norm)
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.textwidth = 100    -- modern C++ allows longer lines than C
vim.opt_local.colorcolumn = "100"
