-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/21-python-math-jupyter.md
-- Runs real Jupyter kernels in-buffer; renders cell output (text/images/plots)
-- via 3rd/image.nvim using the Kitty graphics protocol (Kitty & Ghostty both
-- support it). Requires pynvim/jupyter_client/ipykernel (see neovim.yml).
-- After first install, run :UpdateRemotePlugins once and restart Neovim.
-- https://github.com/benlubas/molten-nvim
return {
    -- Fork of benlubas/molten-nvim: upstream main plus two fixes, each also
    -- sent upstream on its own branch. (1) PR #365: inline images were drawn
    -- over the "Out[n]" header and text above them, because image.nvim's
    -- separate padding extmark gets dropped on redraw; the fork reserves the
    -- image's rows in Molten's own extmark. (2) finished cells could not show
    -- or hide their floating window (upstream 81aa71b skipped _show_selected
    -- for DONE cells). Switch back to "benlubas/molten-nvim" with
    -- `version = "^1.0.0"` once both are released.
    "DreamEcho100/molten-nvim",
    branch = "de100-integration",
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
        -- floating popup window opens on its own. molten_auto_open_output
        -- must be false or entering a cell still pops a floating window.
        --
        -- Known trade-off, accepted: molten-nvim's inline path gives every
        -- image chunk visible at once the same y coordinate
        -- (outputbuffer.py's build_output_text), so multiple simultaneously
        -- visible images can overlap; and there's no WinScrolled handling
        -- in its Python plugin, so scrolling without moving the cursor to
        -- a new cell can leave an image's Kitty-graphics-protocol
        -- placement stuck at its old screen row. Not fixable here without
        -- patching molten-nvim's own source.
        --
        -- image_location = "both" (not "virt"): ImageOutputChunk.place()
        -- (outputchunks.py) only actually places an image for a mode this
        -- option includes — under "virt", the <leader>jo popup's build call
        -- (virtual=false) hit none of its branches and returned early
        -- *before* claiming its own Kitty-image identifier, so its
        -- img_identifier stayed pointing at the inline image's; closing the
        -- popup then deleted that shared identifier — the inline copy —
        -- instead of a floating-only one. "both" gives the popup its own
        -- real image and its own separate identifier ("<path>" vs the
        -- inline copy's "virt-<path>"), so closing it only ever removes its
        -- own copy. Confirmed via source this doesn't change inline
        -- rendering for cells that never open the popup: for the inline
        -- (virtual=true) call, "both" and "virt" hit the exact same branch.
        vim.g.molten_image_location = "both"
        vim.g.molten_auto_open_output = false

        -- No config exists to auto-fade this after a delay (checked
        -- molten-nvim's source directly — the only timers in the plugin
        -- are kernel-message polling loops, nothing display-related), so
        -- the exec-time header ("Out[2]: ✓ Done 1.50s") is just noise
        -- prepended to every output, floating or inline alike — a single
        -- global option, no per-cell/per-location override. Off entirely.
        vim.g.molten_output_show_exec_time = false
    end,
    config = function()
        require("de100.utils.molten-popup").setup()
        require("de100.utils.molten-clear").setup()
        require("de100.utils.molten-save").setup()
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
        { "<leader>jc", "<cmd>MoltenClear<CR>", desc = "Jupyter: clear this cell's output" },
        { "<leader>jC", "<cmd>MoltenClearAll<CR>", desc = "Jupyter: clear all outputs in file" },
        { "<leader>jd", "<cmd>MoltenDelete<CR>", desc = "Jupyter: delete this cell's output (raw MoltenDelete)" },
        { "<leader>jx", "<cmd>MoltenInterrupt<CR>", desc = "Jupyter: interrupt the running cell" },
        {
            "<leader>jo",
            function() require("de100.utils.molten-popup").toggle() end,
            desc = "Jupyter: toggle output popup for this cell",
        },
    },
}
