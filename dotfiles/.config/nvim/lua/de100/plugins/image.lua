-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/21-python-math-jupyter.md
-- Renders images (Molten plot output, markdown images) inline via the Kitty
-- graphics protocol. Disabled under Neovide (crashes reading terminal size
-- there — same reasoning as the old dead entry this replaces, see
-- disabled.lua). Only reliable in terminals that implement the Kitty
-- graphics protocol (Kitty, Ghostty); expect no image rendering over a plain
-- SSH session in an unsupported terminal.
-- Requires libmagickwand-dev system package (see neovim.yml).
-- https://github.com/3rd/image.nvim
return {
    "3rd/image.nvim",
    cond = function()
        return not (vim.g.neovide == true)
    end,
    opts = {
        backend = "kitty",
        processor = "magick_cli",
        max_width_window_percentage = 80,
        max_height_window_percentage = 60,
        kitty_method = "normal",
    },
}
