-- Creating new notebooks for :JupytextNew / <leader>jn (see
-- plugins/jupytext.lua). The target directory comes from the active explorer
-- (utils/explorer-dir.lua); the user only types a name. The format follows
-- the extension: .qmd stays a Quarto file, everything else is .ipynb.
local M = {}

function M.empty_notebook_json()
    return '{"cells": [], "metadata": {"kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"}}, "nbformat": 4, "nbformat_minor": 5}'
end

local function qmd_lines(path)
    local title = vim.fn.fnamemodify(path, ":t:r")
    return {"---", "title: " .. title, "jupyter: python3", "---", ""}
end

--- name + base dir -> absolute path with a valid notebook extension.
--- Absolute and ~ names ignore base_dir; ".ipynb"/".qmd" are kept, any other
--- (or no) extension gets ".ipynb" appended.
function M.resolve(name, base_dir)
    name = vim.trim(name or "")
    if name == "" then return nil end
    if not (name:match("%.ipynb$") or name:match("%.qmd$")) then
        name = name .. ".ipynb"
    end
    local path = name
    if not (name:match("^/") or name:match("^~")) then
        path = base_dir:gsub("/+$", "") .. "/" .. name
    end
    return vim.fn.fnamemodify(path, ":p")
end

function M.create(name, base_dir)
    local full_path = M.resolve(name, base_dir)
    if not full_path then
        vim.notify("JupytextNew: provide a notebook name, e.g. lesson1 or notes/lesson1.qmd",
                   vim.log.levels.ERROR)
        return
    end
    if vim.fn.filereadable(full_path) == 1 then
        vim.notify("JupytextNew: file already exists: " .. full_path,
                   vim.log.levels.ERROR)
        return
    end

    vim.fn.mkdir(vim.fn.fnamemodify(full_path, ":h"), "p")
    local lines = full_path:match("%.qmd$") and qmd_lines(full_path) or
                      {M.empty_notebook_json()}
    vim.fn.writefile(lines, full_path)
    vim.cmd.edit(vim.fn.fnameescape(full_path))
end

--- Completion for names typed relative to base_dir: entries of the directory
--- part typed so far, directories suffixed with "/".
function M.complete(arglead, base_dir)
    local dir_part, name_part = arglead:match("^(.*/)([^/]*)$")
    if not dir_part then dir_part, name_part = "", arglead end

    local search_dir = dir_part
    if not (dir_part:match("^/") or dir_part:match("^~")) then
        search_dir = base_dir:gsub("/+$", "") .. "/" .. dir_part
    end
    search_dir = vim.fn.expand(search_dir)

    local ok, entries = pcall(vim.fn.readdir, search_dir)
    if not ok then return {} end

    local results = {}
    for _, entry in ipairs(entries) do
        if vim.startswith(entry, name_part) then
            local is_dir = vim.fn.isdirectory(search_dir .. "/" .. entry) == 1
            if is_dir or entry:match("%.ipynb$") or entry:match("%.qmd$") then
                table.insert(results, dir_part .. entry .. (is_dir and "/" or ""))
            end
        end
    end
    table.sort(results)
    return results
end

local completion_base

--- Prompt for just the name, in the explorer-inferred directory.
function M.prompt()
    local base = require("de100.utils.explorer-dir").target_dir()
    completion_base = base
    vim.ui.input({
        prompt = "New notebook in " .. vim.fn.fnamemodify(base, ":~") .. "/ : ",
        completion = "customlist,v:lua.de100_notebook_complete"
    }, function(input)
        if input and input ~= "" then M.create(input, base) end
    end)
end

function _G.de100_notebook_complete(arglead)
    return M.complete(arglead, completion_base or vim.fn.getcwd())
end

return M
