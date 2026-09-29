-- Small shared helper for <leader>ef/<leader>er "reveal current file"
-- keymaps (mini.lua, plugins/snacks.lua).
local M = {}

local function strip_trailing_slash(path) return (path:gsub("/+$", "")) end

--- Cyclic scan for the first real (non-"..") entry starting just after
--- start_lnum, wrapping around to the top if nothing follows it. Handles
--- both "cursor sits on .. at line 1, real entries below" (the common
--- case) and any other sort order without assuming .. is always first.
local function next_real_entry(bufnr, start_lnum)
    local oil = require("oil")
    local total = vim.api.nvim_buf_line_count(bufnr)
    for offset = 1, total do
        local lnum = ((start_lnum - 1 + offset) % total) + 1
        local entry = oil.get_entry_on_line(bufnr, lnum)
        if entry and entry.name ~= ".." then return entry end
    end
    return nil
end

--- Resolves the real filesystem path relevant to the current buffer, so
--- reveal-in-explorer keymaps behave sensibly from an oil.nvim directory
--- listing too. oil buffers are named with a synthetic oil:// URL, which
--- upstream reveal implementations (snacks.explorer, mini.files) don't
--- expect and silently mis-resolve.
---
--- Cursor on a real entry reveals exactly that entry (unchanged from a
--- normal file buffer). oil always shows a ".." pseudo-entry too (its
--- default cursor position on open), so cursor-on-".." (or an otherwise
--- unresolvable cursor entry) instead reveals the next real entry in the
--- listing. If the directory is genuinely empty (nothing but ".."), falls
--- back to its parent — clamped at the project root (via
--- de100.utils.project-root) so this never walks above the project into
--- unrelated system directories.
function M.target_path()
    if vim.bo.filetype ~= "oil" then return vim.api.nvim_buf_get_name(0) end

    local ok, oil = pcall(require, "oil")
    if not ok then return vim.api.nvim_buf_get_name(0) end

    local dir = oil.get_current_dir(0)
    if not dir then return vim.api.nvim_buf_get_name(0) end

    local cursor_entry = oil.get_cursor_entry()
    if cursor_entry and cursor_entry.name ~= ".." then
        return dir .. cursor_entry.name
    end

    local cursor_lnum = vim.api.nvim_win_get_cursor(0)[1]
    local fallback_entry = next_real_entry(0, cursor_lnum)
    if fallback_entry then return dir .. fallback_entry.name end

    -- Genuinely empty directory: go up, but never above the project root.
    local root = require("de100.utils.project-root").find(0)
    local bare_dir = strip_trailing_slash(dir)
    if root and bare_dir == strip_trailing_slash(root) then return dir end
    return vim.fs.dirname(bare_dir) .. "/"
end

return M
