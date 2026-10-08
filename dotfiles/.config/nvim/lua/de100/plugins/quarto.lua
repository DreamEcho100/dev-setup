-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/21-python-math-jupyter.md
-- .qmd literate notebooks: markdown math notes + executable code cells in one
-- file. Builds on molten (execution) + otter (per-cell LSP injection). The
-- `quarto` CLI binary is only needed for :QuartoPreview/render, not for basic
-- cell editing/execution.
-- https://github.com/quarto-dev/quarto-nvim
-- https://github.com/jmbuhr/otter.nvim
return {
    "quarto-dev/quarto-nvim",
    -- "markdown" included: jupytext generates markdown for .ipynb, and
    -- molten-nvim's own docs (Notebook-Setup.md) say this combo gets "the
    -- full benefits of quarto-nvim" on those buffers too, not just .qmd.
    ft = { "quarto", "markdown" },
    dependencies = { "jmbuhr/otter.nvim", "nvim-treesitter/nvim-treesitter" },
    opts = {
        lspFeatures = {
            languages = { "python" },
            -- "curly" (quarto-nvim's own default) only matches fences like
            -- ```{python}` (real .qmd files). jupytext's markdown style
            -- generates plain ```python id="..."` fences with no braces, so
            -- any non-"curly" value here makes quarto-nvim fall back to the
            -- standard nvim-treesitter markdown injections query instead,
            -- which correctly matches plain fences (confirmed by running
            -- `jupytext --to markdown` directly on a real course notebook).
            chunks = "plain",
            -- InsertLeave too: with only BufWritePost a fixed error stayed until :w
            diagnostics = { enabled = true, triggers = { "BufWritePost", "InsertLeave" } },
            completion = { enabled = true },
        },
        codeRunner = { enabled = true, default_method = "molten" },
    },
    keys = {
        -- The actual "create + run this cell" command (works on first run,
        -- unlike Molten's own :MoltenReevaluateCell which requires the cell
        -- to already exist). Dispatches to Molten via codeRunner above.
        {
            "<leader>jr",
            function() require("quarto.runner").run_cell() end,
            desc = "Jupyter: run/re-run cell",
        },
    },
}
