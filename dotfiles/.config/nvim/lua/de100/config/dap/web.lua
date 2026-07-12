local M = {}

function M.setup()
    local dap = require("dap")
    local util = require("de100.config.dap.util")
    local command = util.executable("js-debug-adapter") or "js-debug-adapter"
    local adapter = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = { command = command, args = { "${port}" } },
    }

    for _, name in ipairs({ "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal" }) do
        dap.adapters[name] = adapter
    end

    local function browser_url()
        local url = vim.fn.input("Application URL: ", "http://localhost:3000")
        return url ~= "" and url or dap.ABORT
    end

    local node_configurations = {
        {
            name = "Node: launch current file",
            type = "pwa-node",
            request = "launch",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            console = "integratedTerminal",
            skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
        },
        {
            name = "Node: attach to process",
            type = "pwa-node",
            request = "attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
        },
    }
    local browser_configurations = {
        {
            name = "Browser: launch application",
            type = "pwa-chrome",
            request = "launch",
            url = browser_url,
            webRoot = "${workspaceFolder}",
            sourceMaps = true,
            userDataDir = function()
                return vim.fs.joinpath(vim.fn.stdpath("cache"), "de100", "js-debug-browser-profile")
            end,
        },
        {
            name = "Browser: attach on port 9222",
            type = "pwa-chrome",
            request = "attach",
            port = 9222,
            webRoot = "${workspaceFolder}",
            sourceMaps = true,
        },
    }

    local script_configurations = vim.deepcopy(node_configurations)
    vim.list_extend(script_configurations, vim.deepcopy(browser_configurations))
    util.copy_configurations(script_configurations, {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
    })
    util.copy_configurations(browser_configurations, {
        "astro",
        "svelte",
        "vue",
    })

    local vscode = require("dap.ext.vscode")
    vscode.type_to_filetypes["pwa-node"] = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "astro",
        "svelte",
        "vue",
    }
    vscode.type_to_filetypes["pwa-chrome"] = vim.deepcopy(vscode.type_to_filetypes["pwa-node"])
    vscode.type_to_filetypes["pwa-msedge"] = vim.deepcopy(vscode.type_to_filetypes["pwa-node"])
end

return M
