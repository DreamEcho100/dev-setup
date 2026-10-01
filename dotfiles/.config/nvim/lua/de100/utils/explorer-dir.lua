-- Resolves "the directory I'm working in" from whichever explorer is active
-- (oil, mini.files, snacks explorer), falling back to the current buffer's
-- directory, then the cwd. Used by :JupytextNew / <leader>jn so the user only
-- types a file name.
local M = {}

local function strip_trailing_slash(path)
    if path == "/" then return path end
    return (path:gsub("/+$", ""))
end

local function dir_of(path, is_dir)
    path = strip_trailing_slash(path)
    if is_dir == nil then is_dir = vim.fn.isdirectory(path) == 1 end
    return is_dir and path or vim.fs.dirname(path)
end

local function from_oil()
    local ok, oil = pcall(require, "oil")
    if not ok then return nil end
    local dir = oil.get_current_dir(0)
    if not dir then return nil end
    local entry = oil.get_cursor_entry()
    if entry and entry.name ~= ".." and entry.type == "directory" then
        return strip_trailing_slash(dir) .. "/" .. entry.name
    end
    return strip_trailing_slash(dir)
end

local function from_minifiles()
    local ok, mini = pcall(require, "mini.files")
    if not ok then return nil end
    local entry = mini.get_fs_entry()
    if entry and entry.path then
        return dir_of(entry.path, entry.fs_type == "directory")
    end
    local state = mini.get_explorer_state()
    if state and state.branch then
        return strip_trailing_slash(state.branch[state.depth_focus])
    end
    return nil
end

local function from_snacks_explorer()
    local ok, snacks = pcall(require, "snacks")
    if not ok then return nil end
    local pickers = snacks.picker.get({source = "explorer"})
    local picker = pickers and pickers[1]
    local item = picker and picker:current()
    if item and item.file then return dir_of(item.file, item.dir) end
    return nil
end

local resolvers = {
    oil = from_oil,
    minifiles = from_minifiles,
    snacks_picker_list = from_snacks_explorer,
    snacks_picker_input = from_snacks_explorer
}

--- Absolute directory to create new files in, no trailing slash.
function M.target_dir()
    local resolver = resolvers[vim.bo.filetype]
    local dir = resolver and resolver() or nil
    if dir and dir ~= "" then return dir end

    local name = vim.api.nvim_buf_get_name(0)
    if name ~= "" and not name:match("^%a[%w+.-]*://") then
        return vim.fs.dirname(vim.fn.fnamemodify(name, ":p"))
    end
    return vim.fn.getcwd()
end

return M
