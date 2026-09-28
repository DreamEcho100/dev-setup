-- dotfiles/.config/nvim/lua/de100/plugins/markdown-preview.lua
--
-- Link to github repo
-- https://github.com/iamcco/markdown-preview.nvim
return {
    "iamcco/markdown-preview.nvim",
    -- Keymap removed: it's a 1:1 wrapper around `:MarkdownPreviewToggle` (call
    -- that directly), and it collided with formatting.lua's global <leader>mp
    -- format keymap since this one had no working ft guard in lazy's `keys`.
    -- keys = {
    --     {
    --         "<leader>mp",
    --         ft = "markdown",
    --         "<cmd>MarkdownPreviewToggle<cr>",
    --         desc = "Markdown Preview"
    --     }
    -- },
    init = function()
        -- The default filename is 「${name}」and I just hate those symbols
        vim.g.mkdp_page_title = "${name}"
    end
}
