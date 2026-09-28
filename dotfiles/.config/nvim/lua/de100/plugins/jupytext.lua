-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/21-python-math-jupyter.md
-- Converts .ipynb <-> .py (percent format) transparently on read/write.
-- Requires the `jupytext` CLI (installed via neovim.yml pip task).
-- https://github.com/GCBallesteros/jupytext.nvim
return {
    "GCBallesteros/jupytext.nvim",
    ft = "ipynb",
    opts = {
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown",
    },
}
