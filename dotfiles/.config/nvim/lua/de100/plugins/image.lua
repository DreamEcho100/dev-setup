-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/21-python-math-jupyter.md
-- Renders images (Molten plot output) inline via the Kitty graphics
-- protocol. Disabled under Neovide (crashes reading terminal size there —
-- same reasoning as the old dead entry this replaces, see disabled.lua).
-- Only reliable in terminals that implement the Kitty graphics protocol
-- (Kitty, Ghostty); expect no image rendering over a plain SSH session in
-- an unsupported terminal.
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
        -- All "document integrations" (auto-rendering ![](img.png)-style
        -- links in markdown/asciidoc/neorg/rst/typst) disabled on purpose.
        -- Molten's plot rendering never uses these — it calls image.nvim's
        -- image_api directly (confirmed in molten-nvim's own
        -- rplugin/python3/molten/images.py). These integrations are the
        -- ONLY thing that registers image.nvim's global BufEnter/WinNew/
        -- TabEnter autocmd (image/init.lua only loads an integration, and
        -- with it that autocmd, when `enabled = true`) — and that autocmd
        -- is what crashes with a Lua error whenever lazy.nvim's install/
        -- update floating window closes (a buffer becomes briefly invalid
        -- mid-close, and the autocmd indexes it before checking validity).
        -- Disabling the integrations we don't use removes the crash
        -- entirely with no effect on Molten's own rendering.
        integrations = {
            markdown = {enabled = false},
            asciidoc = {enabled = false},
            neorg = {enabled = false},
            rst = {enabled = false},
            typst = {enabled = false},
            html = {enabled = false},
            css = {enabled = false},
        },
        -- Clears overlapping image windows instead of leaving stale ones
        -- behind — fixes re-running a Molten cell (new output window
        -- overlapping the old one) leaving garbled/duplicate plots.
        -- Off by default. Known remaining limitation, not fully fixed by
        -- this: molten-nvim's own docs (Notebook-Setup.md, "Compromises")
        -- acknowledge images can still shift until you scroll — that part
        -- is an upstream, unresolved issue, not something configurable here.
        window_overlap_clear_enabled = true,
        -- window_overlap_clear_enabled hides ANY image whose screen
        -- position is covered by ANY window (floating included) — a
        -- completion popup, a which-key hint menu, anything — and only
        -- re-renders it on a later cursor move, not automatically when
        -- that window closes. Tried exempting blink.cmp's/which-key's
        -- filetypes via window_overlap_clear_ft_ignore; confirmed (after a
        -- full Neovim restart) it made no difference, so the real
        -- mechanism causing this isn't the filetype check. See
        -- docs/neovim-tutorials-from-0-to-hero/21-python-math-jupyter.md's
        -- "Known limitation" section — accepted as-is rather than chased
        -- further; window_overlap_clear_enabled = false removes it
        -- entirely if the garbled-plot-on-rerun trade-off is preferred.
    },
}
