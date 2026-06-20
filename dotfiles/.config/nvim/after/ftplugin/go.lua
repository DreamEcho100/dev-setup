-- Go: gofmt enforces tabs; allow longer lines per convention
-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/10-formatting-linting.md
vim.opt_local.expandtab = false -- expandtab means use spaces instead of tabs
vim.opt_local.tabstop = 4 -- number of spaces a tab counts for
vim.opt_local.shiftwidth = 4 -- number of spaces to use for each step of (auto)indent
vim.opt_local.textwidth = 120
vim.opt_local.colorcolumn = ""
