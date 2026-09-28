-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/21-python-math-jupyter.md
-- Runs real Jupyter kernels in-buffer; renders cell output (text/images/plots)
-- via 3rd/image.nvim using the Kitty graphics protocol (Kitty & Ghostty both
-- support it). Requires pynvim/jupyter_client/ipykernel (see neovim.yml).
-- After first install, run :UpdateRemotePlugins once and restart Neovim.
-- https://github.com/benlubas/molten-nvim
return {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    ft = { "python", "quarto", "markdown" },
    dependencies = { "3rd/image.nvim" },
    init = function()
        vim.g.molten_image_provider = "image.nvim"
        vim.g.molten_output_win_max_height = 20
        vim.g.molten_auto_open_output = true
        vim.g.molten_virt_text_output = true
        vim.g.molten_wrap_output = true
    end,
    keys = {
        { "<leader>jr", "<cmd>MoltenReevaluateCell<CR>", desc = "Jupyter: run/re-run cell" },
        { "<leader>jv", ":<C-u>MoltenEvaluateVisual<CR>gv", mode = "x", desc = "Jupyter: run selection" },
        { "]j", "<cmd>MoltenNext<CR>", desc = "Jupyter: next cell/output" },
        { "[j", "<cmd>MoltenPrev<CR>", desc = "Jupyter: prev cell/output" },
    },
}
