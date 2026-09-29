-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/13-customising-your-config.md
-- Meta-variant catalogue + apply/persist logic for the <leader>th colorscheme
-- picker (de100/plugins/snacks.lua), for every picker-visible name that has
-- no matching colors/<name>.{vim,lua} file (gruvbox/everforest/vscode/
-- evergarden light-dark/style splits are a runtime flag, not a separate
-- colorscheme). The catalogue itself lives in theme-meta.json, shared with
-- dotfiles/.local/scripts/de100-theme-sync's theme_values() (read there via
-- jq) so there's exactly one place to add/change a meta-variant, not two.
local M = {}

local function load_extras()
    local path = vim.fn.stdpath("config") .. "/lua/de100/utils/theme-meta.json"
    local ok, lines = pcall(vim.fn.readfile, path)
    if not ok then return {} end
    local ok2, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
    return ok2 and decoded or {}
end

M.extras = load_extras()

--- Appends synthetic meta-variant items to the plain file-backed items
--- returned by snacks' vim_colorschemes finder.
---@param real_items snacks.picker.finder.Item[]
function M.merge_items(real_items)
    local by_name = {}
    for _, item in ipairs(real_items) do by_name[item.text] = item end

    local items = vim.deepcopy(real_items)
    for name, def in pairs(M.extras) do
        local real_item = by_name[def.real]
        items[#items + 1] = {
            text = name,
            file = real_item and real_item.file or nil,
            de100_meta = def
        }
    end
    return items
end

--- Runs (setup snippet, then :colorscheme) for a picker item, whether it's
--- a plain file-backed entry or one of M.extras' synthetic meta-variants.
---@param item snacks.picker.finder.Item
function M.apply(item)
    local meta = item.de100_meta
    if meta and meta.setup then assert(load(meta.setup, "de100-theme-setup"))() end
    vim.cmd.colorscheme(meta and meta.real or item.text)
end

--- Serializes exactly what M.apply(item) just ran, as dofile()-able Lua,
--- matching current-theme.lua's expected format.
---@param item snacks.picker.finder.Item
---@return string
function M.serialize(item)
    local meta = item.de100_meta
    local lines = {}
    if meta and meta.setup then lines[#lines + 1] = meta.setup end
    lines[#lines + 1] =
        ("vim.cmd.colorscheme(%q)"):format(meta and meta.real or item.text)
    return table.concat(lines, "\n") .. "\n"
end

--- Atomically writes the resolved theme choice to
--- <stdpath state>/de100/theme/nvim.lua (same path/format de100-theme-sync's
--- `nvim` target writes — note stdpath("state") is $XDG_STATE_HOME/nvim,
--- not $XDG_STATE_HOME itself), so it is picked up by current-theme.lua on
--- the next Neovim start.
---@param item snacks.picker.finder.Item
function M.persist(item)
    local dir = vim.fn.stdpath("state") .. "/de100/theme"
    vim.fn.mkdir(dir, "p")
    local path = dir .. "/nvim.lua"
    local tmp = path .. ".tmp"
    local fh = assert(io.open(tmp, "w"))
    fh:write(M.serialize(item))
    fh:close()
    os.rename(tmp, path)
end

return M
