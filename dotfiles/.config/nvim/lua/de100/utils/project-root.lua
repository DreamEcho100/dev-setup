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

-- Session-lifetime cache, keyed by search path, expiring after
-- CACHE_TTL_MS so a project created/removed mid-session still eventually
-- gets picked up rather than caching forever.
local CACHE_TTL_MS = 5000
local _cache = {}

--- Finds the project root for the given buffer (current buffer by default),
--- walking up from its path looking for M.markers. Returns nil if none
--- found — mirrors vim.fs.root's own nullable contract, so callers decide
--- their own fallback. Cached per search path for CACHE_TTL_MS, since this
--- walks the filesystem tree and both <leader>mcd and
--- de100.utils.explorer-reveal can call it repeatedly in quick succession.
---@param bufnr? integer
---@return string|nil
function M.find(bufnr)
    local fname = vim.api.nvim_buf_get_name(bufnr or 0)
    local search_path = search_path_for(fname)

    local now = vim.uv.now()
    local cached = _cache[search_path]
    if cached and (now - cached.at) < CACHE_TTL_MS then
        return cached.root
    end

    local root = vim.fs.root(search_path, M.markers)
    _cache[search_path] = {root = root, at = now}
    return root
end

return M
