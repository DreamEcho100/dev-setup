-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/06-files-buffers-windows-tabs.md
return {
    -- Adding a filename to the Top Right
    {
        "b0o/incline.nvim",
        enabled = true,
        dependencies = {"nvim-tree/nvim-web-devicons"},
        config = function()
            local devicons = require("nvim-web-devicons")

            require("incline").setup({
                hide = {only_win = false},
                render = function(props)
                    local bufname = vim.api.nvim_buf_get_name(props.buf)
                    -- Label style is per-target, change with :PathStyle incline
                    local filename = require("de100.utils.path-style").format(
                                         bufname, "incline")

                    local ext = vim.fn.fnamemodify(bufname, ":e")
                    local icon, icon_color =
                        devicons.get_icon(vim.fn.fnamemodify(bufname, ":t"), ext,
                                          {default = true})

                    local modified = vim.bo[props.buf].modified

                    return {
                        {" ", icon, " ", guifg = icon_color},
                        {filename, gui = modified and "bold" or "none"},
                        modified and {" [+]", guifg = "#ff9e64"} or "", " "
                    }
                end
            })
        end
    }
}
