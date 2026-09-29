-- Per-cell floating-output popup for Molten, mapped to <leader>jo in
-- de100/plugins/molten.lua. Molten's always-inline default (see molten.lua)
-- keeps everything pinned below each cell with no floating window, but its
-- own floating window (:MoltenShowOutput/:MoltenHideOutput, independent of
-- the inline image_location/virt_text_output settings) is still the only
-- way to see full output without that inline noise. Molten has no per-cell
-- scoping for this though — auto_open_output is a single global flag shared
-- by every cell (confirmed by reading molten-nvim's rplugin source directly:
-- one MoltenOptions instance, passed by reference everywhere) — so "only
-- pop up for cells I've explicitly turned it on for" is built here instead.
--
-- Cell identity is a range lookup via otter.nvim's code_chunks (the same
-- mechanism quarto.nvim's own <leader>jr runner uses internally, see
-- quarto-nvim/lua/quarto/runner/init.lua) since neither quarto-nvim nor
-- molten-nvim expose a public "what cell is the cursor in" query.
local M = {}

-- {[bufnr] = {[key] = true}}, key = "from_row-from_col-to_row-to_col".
M.toggled = {}

local function range_key(range)
    return string.format("%d-%d-%d-%d", range.from[1], range.from[2], range.to[1], range.to[2])
end

local function range_contains_row(range, row)
    return range.from[1] <= row and row <= range.to[1]
end

--- Finds the code cell the cursor is currently inside, if any.
---@param bufnr integer
---@return table|nil range {from = {row, col}, to = {row, col}}, 0-indexed
function M.current_cell_range(bufnr)
    local ok, keeper = pcall(require, "otter.keeper")
    if not ok or not keeper.has_raft(bufnr) then return nil end

    keeper.sync_raft(bufnr)
    local raft = keeper.rafts[bufnr]
    if not raft or not raft.code_chunks then return nil end

    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    for _, chunks in pairs(raft.code_chunks) do
        for _, chunk in ipairs(chunks) do
            if range_contains_row(chunk.range, row) then return chunk.range end
        end
    end
    return nil
end

-- The toggled range currently driving a visible popup, so on_cursor_moved
-- only issues :MoltenShowOutput/:MoltenHideOutput on an actual transition
-- rather than on every single cursor move.
local shown_key = nil

function M.toggle()
    local bufnr = vim.api.nvim_get_current_buf()
    local range = M.current_cell_range(bufnr)
    if not range then
        vim.notify("molten-popup: cursor isn't inside a code cell", vim.log.levels.WARN)
        return
    end

    M.toggled[bufnr] = M.toggled[bufnr] or {}
    local key = range_key(range)
    if M.toggled[bufnr][key] then
        M.toggled[bufnr][key] = nil
        if shown_key == key then
            pcall(vim.cmd, "MoltenHideOutput")
            shown_key = nil
        end
        vim.notify("molten-popup: output popup off for this cell", vim.log.levels.INFO)
    else
        M.toggled[bufnr][key] = true
        vim.notify("molten-popup: output popup on for this cell", vim.log.levels.INFO)
        M.on_cursor_moved()
    end
end

-- Same filetypes molten.lua's `ft` loads Molten for.
local MOLTEN_FILETYPES = { python = true, quarto = true, markdown = true }

function M.on_cursor_moved()
    local bufnr = vim.api.nvim_get_current_buf()
    if not MOLTEN_FILETYPES[vim.bo[bufnr].filetype] then return end

    local toggled = M.toggled[bufnr]
    local range = toggled and M.current_cell_range(bufnr) or nil
    local key = range and range_key(range) or nil
    local should_show = key ~= nil and toggled[key] == true

    if should_show then
        if shown_key ~= key then
            pcall(vim.cmd, "MoltenShowOutput")
            shown_key = key
        end
    elseif shown_key ~= nil then
        pcall(vim.cmd, "MoltenHideOutput")
        shown_key = nil
    end
end

function M.setup()
    local group = vim.api.nvim_create_augroup("de100_molten_popup", { clear = true })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        callback = M.on_cursor_moved,
    })
end

return M
