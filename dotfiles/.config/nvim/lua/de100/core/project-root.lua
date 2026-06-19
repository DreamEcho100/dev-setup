local markers = {
    "CMakeLists.txt", -- CMake
    "go.mod", "go.work", -- Go
    "Cargo.toml", -- Rust
    "package.json", -- Node.js
    "pyproject.toml", "setup.py", -- Python
    ".git" -- Git
}

vim.keymap.set("n", "<leader>mcd", function()
    local fname = vim.api.nvim_buf_get_name(0)
    local search_path

    -- oil.nvim uses oil:///real/path — strip scheme to get walkable path
    if fname:match("^oil://") then
        search_path = fname:gsub("^oil://", "")
    elseif fname ~= "" and not fname:match("^%a+://") then
        search_path = fname
    else
        search_path = vim.uv.cwd()
    end

    local root = vim.fs.root(search_path, markers)
    if not root then
        vim.notify("No project root found", vim.log.levels.WARN)
        return
    end
    vim.cmd("cd " .. vim.fn.fnameescape(root))
    vim.notify("Project root: " .. root, vim.log.levels.INFO)
end, {desc = "cd to project root"})
