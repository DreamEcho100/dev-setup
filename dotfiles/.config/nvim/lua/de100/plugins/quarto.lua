-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/21-python-math-jupyter.md
-- .qmd literate notebooks: markdown math notes + executable code cells in one
-- file. Builds on molten (execution) + otter (per-cell LSP injection). The
-- `quarto` CLI binary is only needed for :QuartoPreview/render, not for basic
-- cell editing/execution.
-- https://github.com/quarto-dev/quarto-nvim
-- https://github.com/jmbuhr/otter.nvim
return {
    "quarto-dev/quarto-nvim",
    ft = { "quarto" },
    dependencies = { "jmbuhr/otter.nvim", "nvim-treesitter/nvim-treesitter" },
    opts = {
        lspFeatures = {
            languages = { "python" },
            chunks = "curly",
            diagnostics = { enabled = true, triggers = { "BufWritePost" } },
            completion = { enabled = true },
        },
        codeRunner = { enabled = true, default_method = "molten" },
    },
}
