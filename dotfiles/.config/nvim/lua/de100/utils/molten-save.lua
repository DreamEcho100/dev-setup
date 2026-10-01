-- :MoltenSaveOutput / :MoltenSaveOutputAll. Write cell outputs into the
-- notebook that belongs to this file, next to it: the file itself for an
-- .ipynb, otherwise a sibling `<name>.ipynb` (created if missing).
--
-- The notebook is synced from the buffer first (jupytext keeps the outputs it
-- already has), because Molten matches each cell to the notebook by its code.
-- The export itself is Molten's: :MoltenExportOutput! (all cells) and, in the
-- DreamEcho100 fork, :MoltenExportCellOutput! (only the cell under the cursor).
local M = {}

local function notebook_path(file)
    if file:match("%.ipynb$") then return file end
    return (file:gsub("%.[^./]*$", "")) .. ".ipynb"
end

--- Saves the buffer and brings the notebook's cells up to date; returns the
--- notebook path, or nil after notifying why not.
local function sync_notebook()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" or vim.bo.buftype ~= "" then
        vim.notify("MoltenSaveOutput: this buffer is not a file", vim.log.levels.WARN)
        return nil
    end
    local ok, err = pcall(vim.cmd, "silent write")
    if not ok then
        vim.notify("MoltenSaveOutput: could not write the file: " .. tostring(err), vim.log.levels.ERROR)
        return nil
    end

    local path = notebook_path(file)
    if path ~= file then
        if vim.fn.executable("jupytext") == 0 then
            vim.notify("MoltenSaveOutput: the jupytext CLI is needed to create " .. vim.fn.fnamemodify(path, ":t"),
                       vim.log.levels.ERROR)
            return nil
        end
        local res = vim.system({"jupytext", "--to", "ipynb", "--update", "--output", path, file}, {text = true}):wait()
        if res.code ~= 0 then
            vim.notify("MoltenSaveOutput: jupytext failed\n" .. (res.stderr or ""), vim.log.levels.ERROR)
            return nil
        end
    end
    return path
end

local function export(command)
    local path = sync_notebook()
    if not path then return end
    -- Molten matches the selected cell from its own CursorMoved autocmd
    pcall(vim.fn.MoltenOnCursorMoved)
    local ok, err = pcall(vim.cmd, command .. "! " .. vim.fn.fnameescape(path))
    if not ok then
        vim.notify("MoltenSaveOutput: " .. tostring(err), vim.log.levels.WARN)
    end
end

function M.save_cell() export("MoltenExportCellOutput") end

function M.save_all() export("MoltenExportOutput") end

function M.setup()
    vim.api.nvim_create_user_command("MoltenSaveOutput", M.save_cell, {
        desc = "Save the output of the cell under the cursor into the notebook next to this file"
    })
    vim.api.nvim_create_user_command("MoltenSaveOutputAll", M.save_all, {
        desc = "Save every cell's output into the notebook next to this file"
    })
end

return M
