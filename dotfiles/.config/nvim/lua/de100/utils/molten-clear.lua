-- :MoltenClear / :MoltenClearAll. molten-nvim has no "clear output" command;
-- :MoltenDelete removes the output (and the cell registration) of the cell
-- under the cursor, and refuses to touch a cell that is still running. A
-- re-run simply recreates the cell. :MoltenRestart! also clears every output
-- but throws the kernel's state away, so it isn't used here.
local M = {}

-- :MoltenDelete only acts on the cell molten *last recorded* as selected,
-- and molten refreshes that from its own CursorMoved autocmd. A cursor moved
-- programmatically in the same tick (as :MoltenClearAll does for every cell)
-- hasn't fired that autocmd yet, so molten would still think the previous
-- cell is selected and delete nothing. Refreshing it explicitly first makes
-- the delete act on the cell under the cursor.
local function delete_under_cursor()
    pcall(vim.fn.MoltenOnCursorMoved)
    local ok, err = pcall(vim.cmd, "MoltenDelete")
    if not ok then
        vim.notify("MoltenClear: " .. tostring(err), vim.log.levels.WARN)
    end
    return ok
end

function M.clear_cell()
    local popup = require("de100.utils.molten-popup")
    local bufnr = vim.api.nvim_get_current_buf()
    local range = popup.current_cell_range(bufnr)
    if delete_under_cursor() and range then popup.forget(bufnr, range) end
end

function M.clear_all()
    local popup = require("de100.utils.molten-popup")
    local bufnr = vim.api.nvim_get_current_buf()
    local view = vim.fn.winsaveview()

    local ranges = {}
    local ok, keeper = pcall(require, "otter.keeper")
    if ok and keeper.has_raft(bufnr) then
        keeper.sync_raft(bufnr)
        for _, chunks in pairs(keeper.rafts[bufnr].code_chunks or {}) do
            for _, chunk in ipairs(chunks) do table.insert(ranges, chunk.range) end
        end
    end

    if #ranges > 0 then
        for _, range in ipairs(ranges) do
            vim.api.nvim_win_set_cursor(0, {range.from[1] + 1, 0})
            if delete_under_cursor() then popup.forget(bufnr, range) end
        end
    else
        -- No otter chunks (e.g. a plain .py): walk Molten's own cell list.
        local last
        for _ = 1, 500 do
            pcall(vim.cmd, "MoltenGoto 1")
            local pos = vim.api.nvim_win_get_cursor(0)
            if last and pos[1] == last[1] and pos[2] == last[2] then break end
            last = pos
            if not delete_under_cursor() then break end
        end
    end

    vim.fn.winrestview(view)
    vim.notify("MoltenClearAll: cleared outputs in this file (cells still running are skipped)")
end

function M.setup()
    vim.api.nvim_create_user_command("MoltenClear", M.clear_cell, {
        desc = "Clear the output of the cell under the cursor"
    })
    vim.api.nvim_create_user_command("MoltenClearAll", M.clear_all, {
        desc = "Clear the output of every cell in this file"
    })
end

return M
