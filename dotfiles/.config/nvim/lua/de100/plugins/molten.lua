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
        vim.g.molten_output_win_max_height = 20
        vim.g.molten_virt_text_output = true
        vim.g.molten_wrap_output = true
        vim.g.molten_image_provider = "image.nvim"

        -- All output (text, images, plots) renders inline, pinned below
        -- each run cell — every cell you've run stays visible at once, no
        -- floating popup window ever. molten_image_location only controls
        -- whether IMAGE chunks appear in the floating window; it doesn't
        -- stop the window itself from opening, so molten_auto_open_output
        -- must also be false or entering a cell still pops an
        -- empty-of-images floating window.
        --
        -- Known trade-off, accepted: molten-nvim's inline path gives every
        -- image chunk visible at once the same y coordinate
        -- (outputbuffer.py's build_output_text), so multiple simultaneously
        -- visible images can overlap; and there's no WinScrolled handling
        -- in its Python plugin, so scrolling without moving the cursor to
        -- a new cell can leave an image's Kitty-graphics-protocol
        -- placement stuck at its old screen row. Not fixable here without
        -- patching molten-nvim's own source.
        vim.g.molten_image_location = "virt"
        vim.g.molten_auto_open_output = false
    end,
    keys = {
        -- <leader>jr (run/create a cell) lives in quarto.lua: it needs
        -- quarto.runner.run_cell(), not :MoltenReevaluateCell (which only
        -- re-runs a cell that already exists — does nothing on first run).
        { "<leader>jv", ":<C-u>MoltenEvaluateVisual<CR>gv", mode = "x", desc = "Jupyter: run selection" },
        -- ]j/[j navigate cells you've already run (Molten's own definition
        -- of a "cell"); nothing to jump to until at least one has been run.
        { "]j", "<cmd>MoltenNext<CR>", desc = "Jupyter: next cell/output" },
        { "[j", "<cmd>MoltenPrev<CR>", desc = "Jupyter: prev cell/output" },
    },
}
