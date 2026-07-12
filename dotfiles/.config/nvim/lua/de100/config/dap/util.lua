local M = {}

local function is_windows()
    return vim.fn.has("win32") == 1
end

function M.mason_root()
    return vim.fs.joinpath(vim.fn.stdpath("data"), "mason")
end

function M.mason_package(name, ...)
    return vim.fs.joinpath(M.mason_root(), "packages", name, ...)
end

function M.executable(name)
    local path = vim.fn.exepath(name)
    if path ~= "" then
        return path
    end

    local candidates = { vim.fs.joinpath(M.mason_root(), "bin", name) }
    if is_windows() then
        vim.list_extend(candidates, {
            vim.fs.joinpath(M.mason_root(), "bin", name .. ".cmd"),
            vim.fs.joinpath(M.mason_root(), "bin", name .. ".exe"),
        })
    end

    for _, candidate in ipairs(candidates) do
        if vim.fn.executable(candidate) == 1 then
            return candidate
        end
    end

    return nil
end

function M.current_directory()
    local filename = vim.api.nvim_buf_get_name(0)
    if filename ~= "" then
        return vim.fs.dirname(filename)
    end
    return vim.fn.getcwd()
end

function M.project_root(markers)
    return vim.fs.root(0, markers or {
        ".git",
        "go.work",
        "go.mod",
        "Cargo.toml",
        "package.json",
        "pyproject.toml",
        "pom.xml",
        "build.gradle",
        "project.godot",
    }) or vim.fn.getcwd()
end

function M.prompt_executable(label)
    local dap = require("dap")
    local path = vim.fn.input(label or "Path to executable: ", M.project_root() .. "/", "file")
    if path == "" then
        return dap.ABORT
    end
    return vim.fn.fnamemodify(path, ":p")
end

function M.select_file(prompt, candidates)
    local dap = require("dap")
    if #candidates == 0 then
        return M.prompt_executable(prompt)
    end
    if #candidates == 1 then
        return candidates[1]
    end

    return coroutine.create(function(dap_run_co)
        vim.ui.select(candidates, {
            prompt = prompt,
            format_item = function(path)
                return vim.fn.fnamemodify(path, ":~:.")
            end,
        }, function(choice)
            coroutine.resume(dap_run_co, choice or dap.ABORT)
        end)
    end)
end

function M.copy_configurations(configurations, filetypes)
    local dap = require("dap")
    for _, filetype in ipairs(filetypes) do
        dap.configurations[filetype] = vim.deepcopy(configurations)
    end
end

function M.setup_module(name)
    local ok, module = pcall(require, "de100.config.dap." .. name)
    if not ok then
        vim.notify_once(("DAP module %s failed to load: %s"):format(name, module), vim.log.levels.WARN)
        return
    end

    local setup_ok, err = pcall(module.setup)
    if not setup_ok then
        vim.notify_once(("DAP module %s failed to configure: %s"):format(name, err), vim.log.levels.WARN)
    end
end

return M
