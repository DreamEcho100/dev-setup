-- Exports the active colorscheme's Normal bg/fg to
-- <stdpath state>/de100/theme/colors.json (stdpath("state") is
-- $XDG_STATE_HOME/nvim, not $XDG_STATE_HOME itself) on every colorscheme
-- change, so
-- out-of-process consumers (e.g. the Math/Latex render hook at
-- dotfiles/.config/ipython/startup/10-de100-math-render.py) can match
-- rendered images to the current theme instead of hardcoding colors.
-- Sibling to the nvim.lua state file de100/utils/theme-persist.lua and
-- de100-theme-sync already write to the same directory.
-- Required from init.lua BEFORE current-theme.lua, so this autocmd is
-- already registered when the very first colorscheme applies at startup.
local function to_hex(n) return n and string.format("#%06x", n) or nil end

local function export_colors()
    local hl = vim.api.nvim_get_hl(0, {name = "Normal", link = false})
    local colors = {}
    if hl.bg then colors.bg = to_hex(hl.bg) end
    if hl.fg then colors.fg = to_hex(hl.fg) end

    local dir = vim.fn.stdpath("state") .. "/de100/theme"
    vim.fn.mkdir(dir, "p")
    local path = dir .. "/colors.json"
    local tmp = path .. ".tmp"
    local fh = assert(io.open(tmp, "w"))
    fh:write(vim.json.encode(colors))
    fh:close()
    os.rename(tmp, path)
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("de100_theme_colors", {clear = true}),
    callback = export_colors
})
