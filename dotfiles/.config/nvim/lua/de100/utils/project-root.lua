-- Shared project-root detection, used by de100/core/project-root.lua's
-- <leader>mcd and de100/utils/explorer-reveal.lua.
local M = {}

M.markers = {
    "CMakeLists.txt", -- CMake
    "go.mod", "go.work", -- Go
    "Cargo.toml", -- Rust
    "package.json", -- Node.js
    "pyproject.toml", "setup.py", -- Python
    ".git" -- Git
}

local function search_path_for(fname)
    -- oil.nvim uses oil:///real/path — strip scheme to get walkable path
    if fname:match("^oil://") then
        return fname:gsub("^oil://", "")
    elseif fname ~= "" and not fname:match("^%a+://") then
        return fname
    end
    return vim.uv.cwd()
end

--- Finds the project root for the given buffer (current buffer by default),
--- walking up from its path looking for M.markers. Returns nil if none
--- found — mirrors vim.fs.root's own nullable contract, so callers decide
--- their own fallback.
---@param bufnr? integer
---@return string|nil
function M.find(bufnr)
    local fname = vim.api.nvim_buf_get_name(bufnr or 0)
    return vim.fs.root(search_path_for(fname), M.markers)
end

return M
