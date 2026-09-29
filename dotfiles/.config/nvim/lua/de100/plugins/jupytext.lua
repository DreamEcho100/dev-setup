-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/21-python-math-jupyter.md
-- Converts .ipynb <-> .py (percent format) transparently on read/write.
-- Requires the `jupytext` CLI (installed via neovim.yml pip task).
-- https://github.com/GCBallesteros/jupytext.nvim
--
-- Must load eagerly (lazy = false), not lazy-loaded via `ft = "ipynb"`.
-- Neovim's own filetype.lua deliberately maps the `.ipynb` extension to
-- filetype "json" (never "ipynb"), so an `ft`-based trigger can never fire —
-- confirmed via `vim.filetype.match({filename = "x.ipynb"})` returning
-- "json". Without this plugin loaded, its BufReadCmd *.ipynb autocmd (which
-- does the actual conversion) never gets registered, and .ipynb files show
-- raw JSON. This is the plugin's own documented fix, not a workaround.
return {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown",
    },
}
