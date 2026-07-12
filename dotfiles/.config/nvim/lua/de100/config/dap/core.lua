local M = {}

local loaded_project_configs = {}

local function setup_signs()
    local signs = {
        DapBreakpoint = { text = "●", texthl = "DiagnosticError" },
        DapBreakpointCondition = { text = "◆", texthl = "DiagnosticWarn" },
        DapBreakpointRejected = { text = "○", texthl = "DiagnosticError" },
        DapLogPoint = { text = "◇", texthl = "DiagnosticInfo" },
        DapStopped = { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" },
    }

    for name, opts in pairs(signs) do
        vim.fn.sign_define(name, opts)
    end
end

local function find_project_file(directory, child)
    local current = vim.fs.normalize(directory)
    while current and current ~= "" do
        local candidate = vim.fs.joinpath(current, child)
        if vim.fn.filereadable(candidate) == 1 then
            return candidate
        end

        local parent = vim.fs.dirname(current)
        if not parent or parent == current then
            break
        end
        current = parent
    end
    return nil
end

local function merge_project_config(path, project_config)
    local dap = require("dap")
    if type(project_config) ~= "table" then
        error(path .. " must return a table")
    end

    if project_config.adapters ~= nil and type(project_config.adapters) ~= "table" then
        error(path .. " field `adapters` must be a table")
    end
    if project_config.configurations ~= nil and type(project_config.configurations) ~= "table" then
        error(path .. " field `configurations` must be a table")
    end

    for name, adapter in pairs(project_config.adapters or {}) do
        dap.adapters[name] = adapter
    end

    for filetype, configurations in pairs(project_config.configurations or {}) do
        if not vim.islist(configurations) then
            error(("%s configurations.%s must be a list"):format(path, filetype))
        end
        dap.configurations[filetype] = dap.configurations[filetype] or {}
        vim.list_extend(dap.configurations[filetype], vim.deepcopy(configurations))
    end
end

local function load_trusted_project_config()
    local util = require("de100.config.dap.util")
    local path = find_project_file(util.current_directory(), vim.fs.joinpath(".nvim", "dap.lua"))
    if not path then
        vim.notify("No .nvim/dap.lua found above the current buffer", vim.log.levels.INFO)
        return
    end
    if loaded_project_configs[path] then
        vim.notify("DAP project config is already loaded: " .. path, vim.log.levels.INFO)
        return
    end

    vim.ui.select({ "Load once", "Cancel" }, {
        prompt = "Trust and execute " .. path .. "?",
    }, function(choice)
        if choice ~= "Load once" then
            return
        end

        local chunk, load_err = loadfile(path)
        if not chunk then
            vim.notify("Could not load DAP project config: " .. tostring(load_err), vim.log.levels.ERROR)
            return
        end

        local ok, project_config = pcall(chunk)
        if not ok then
            vim.notify("DAP project config failed: " .. tostring(project_config), vim.log.levels.ERROR)
            return
        end

        local merge_ok, merge_err = pcall(merge_project_config, path, project_config)
        if not merge_ok then
            vim.notify("Invalid DAP project config: " .. tostring(merge_err), vim.log.levels.ERROR)
            return
        end

        loaded_project_configs[path] = true
        vim.notify("Loaded trusted DAP project config: " .. path)
    end)
end

local function debug_nearest_test()
    local filetype = vim.bo.filetype
    if filetype == "go" then
        require("dap-go").debug_test()
        return
    end
    if filetype == "python" then
        require("dap-python").test_method()
        return
    end
    if filetype == "java" then
        require("jdtls").test_nearest_method()
        return
    end

    local ok, neotest = pcall(require, "neotest")
    if not ok then
        vim.notify("No DAP-aware nearest-test integration for " .. filetype, vim.log.levels.WARN)
        return
    end
    neotest.run.run({ strategy = "dap" })
end

local function adapter_summary(adapter)
    if type(adapter) == "function" then
        return "dynamic function"
    end
    if type(adapter) ~= "table" then
        return tostring(adapter)
    end

    local command = adapter.command or (adapter.executable and adapter.executable.command)
    return command and ((adapter.type or "unknown") .. " command=" .. command) or (adapter.type or "table")
end

local function health_lines()
    local dap = require("dap")
    local util = require("de100.config.dap.util")
    local filetype = vim.bo.filetype
    local configurations = dap.configurations[filetype] or {}
    local lines = {
        ("Neovim: %d.%d.%d"):format(vim.version().major, vim.version().minor, vim.version().patch),
        "filetype: " .. (filetype ~= "" and filetype or "[none]"),
        "cwd: " .. vim.fn.getcwd(),
        "buffer directory: " .. util.current_directory(),
        "DAP log: " .. vim.fs.joinpath(vim.fn.stdpath("log"), "dap.log"),
        "configurations: " .. tostring(#configurations),
    }

    local adapter_names = {}
    for _, config in ipairs(configurations) do
        table.insert(
            lines,
            ("  - %s [%s/%s]"):format(config.name or "unnamed", config.type or "?", config.request or "?")
        )
        if config.type then
            adapter_names[config.type] = true
        end
    end

    table.insert(lines, "adapters:")
    for name in vim.spairs(adapter_names) do
        table.insert(lines, ("  - %s: %s"):format(name, adapter_summary(dap.adapters[name])))
    end
    if next(adapter_names) == nil then
        table.insert(lines, "  - none for current filetype")
    end

    table.insert(lines, "tools:")
    for _, tool in ipairs({
        "js-debug-adapter",
        "debugpy-adapter",
        "dlv",
        "codelldb",
        "node",
        "python3",
        "go",
        "cargo",
        "java",
        "javac",
        "jdtls",
        "netcoredbg",
        "dotnet",
        "godot",
        "zig",
        "odin",
    }) do
        table.insert(lines, ("  - %-22s %s"):format(tool, util.executable(tool) or "missing"))
    end

    local launch_json = find_project_file(util.current_directory(), vim.fs.joinpath(".vscode", "launch.json"))
    local project_lua = find_project_file(util.current_directory(), vim.fs.joinpath(".nvim", "dap.lua"))
    table.insert(lines, "launch.json: " .. (launch_json or "not found"))
    table.insert(lines, ".nvim/dap.lua: " .. (project_lua or "not found"))
    if project_lua then
        table.insert(lines, "project Lua loaded: " .. tostring(loaded_project_configs[project_lua] == true))
    end

    return lines
end

local function setup_commands()
    vim.api.nvim_create_user_command("De100DapHealth", function()
        local lines = health_lines()
        vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "DAP health" })
    end, { desc = "Show debugger configuration and adapter health" })

    vim.api.nvim_create_user_command("De100DapLoadProject", load_trusted_project_config, {
        desc = "Confirm and load the nearest .nvim/dap.lua",
    })

    vim.api.nvim_create_user_command("De100DapDebugNearestTest", debug_nearest_test, {
        desc = "Debug nearest test using the current filetype",
    })
end

function M.setup()
    local dap = require("dap")
    local dapui = require("dapui")

    setup_signs()
    setup_commands()

    dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
        controls = {
            icons = {
                pause = "⏸",
                play = "▶",
                step_into = "⏎",
                step_over = "⏭",
                step_out = "⏮",
                step_back = "b",
                run_last = "▶▶",
                terminate = "⏹",
                disconnect = "⏏",
            },
        },
    })

    require("nvim-dap-virtual-text").setup({
        highlight_changed_variables = true,
        highlight_new_as_changed = true,
        show_stop_reason = true,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = true,
    })

    dap.listeners.after.event_initialized["de100.plugins.dapui"] = dapui.open
    dap.listeners.before.event_terminated["de100.plugins.dapui"] = dapui.close
    dap.listeners.before.event_exited["de100.plugins.dapui"] = dapui.close
end

function M.debug_nearest_test()
    debug_nearest_test()
end

function M.load_project()
    load_trusted_project_config()
end

return M
