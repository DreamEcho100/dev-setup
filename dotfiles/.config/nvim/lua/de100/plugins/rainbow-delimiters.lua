-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/13-customising-your-config.md
-- Colors nested brackets by depth (like VSCode's "bracket pair colorization").
-- Uses treesitter, so it also works for Python inside notebook cells (the
-- markdown fences are injected languages). No keymaps.
-- https://github.com/HiPhish/rainbow-delimiters.nvim
return {
    "HiPhish/rainbow-delimiters.nvim",
    -- Small, and it attaches to buffers as they open, so no lazy-loading.
    lazy = false,
    init = function()
        -- VSCode's cycle: gold, orchid, sky blue (then it repeats)
        vim.g.rainbow_delimiters = {
            highlight = {
                "RainbowDelimiterYellow", "RainbowDelimiterViolet",
                "RainbowDelimiterBlue"
            }
        }
    end
}
