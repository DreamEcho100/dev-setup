local M = {}

function M.setup()
    local dap = require("dap")
    local util = require("de100.config.dap.util")
    local command = util.executable("codelldb") or "codelldb"

    dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = { command = command, args = { "--port", "${port}" } },
    }
    dap.adapters.lldb = dap.adapters.codelldb

    dap.listeners.on_config["de100.codelldb"] = function(config)
        if config.type ~= "codelldb" and config.type ~= "lldb" then
            return config
        end
        local final = vim.deepcopy(config)
        final._adapterSettings = vim.tbl_deep_extend("force", final._adapterSettings or {}, {
            showDisassembly = "never",
        })
        return final
    end

    local configurations = {
        {
            name = "Native: launch executable",
            type = "codelldb",
            request = "launch",
            program = function()
                return util.prompt_executable("Path to debug executable: ")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
        },
        {
            name = "Native: attach to process",
            type = "codelldb",
            request = "attach",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
        },
    }

    util.copy_configurations(configurations, { "c", "cpp", "zig", "odin" })

    local vscode = require("dap.ext.vscode")
    vscode.type_to_filetypes.codelldb = { "c", "cpp", "rust", "zig", "odin" }
    vscode.type_to_filetypes.lldb = vim.deepcopy(vscode.type_to_filetypes.codelldb)
end

return M
