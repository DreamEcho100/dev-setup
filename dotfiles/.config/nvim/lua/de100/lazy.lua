-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/00-before-you-start.md
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { import = "de100.plugins" },
    { import = "de100.plugins.lsp" },
    { import = "de100.plugins.dap" },
}, {
    checker = { enabled = true, notify = false },
    change_detection = { notify = false },
})
