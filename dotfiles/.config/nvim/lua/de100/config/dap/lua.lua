local M = {}

function M.setup()
    local dap = require("dap")
    local util = require("de100.config.dap.util")
    local local_lua_root = util.mason_package("local-lua-debugger-vscode", "extension")
    local adapter_script = vim.fs.joinpath(local_lua_root, "extension", "debugAdapter.js")

    dap.adapters["lua-local"] = {
        type = "executable",
        command = util.executable("node") or "node",
        args = { adapter_script },
    }
    dap.configurations.lua = {
        {
            name = "Lua: launch current file",
            type = "lua-local",
            request = "launch",
            cwd = "${workspaceFolder}",
            program = {
                lua = util.executable("lua5.1") or util.executable("lua") or "lua",
                file = "${file}",
            },
        },
        {
            name = "Neovim Lua: attach on port 8086",
            type = "nlua",
            request = "attach",
        },
    }

    dap.adapters.nlua = function(callback, config)
        callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
    end

    vim.api.nvim_create_user_command("De100DapLuaServer", function()
        require("osv").launch({ port = 8086 })
    end, { desc = "Start a Neovim Lua debug server on port 8086" })

    local vscode = require("dap.ext.vscode")
    vscode.type_to_filetypes["lua-local"] = { "lua" }
    vscode.type_to_filetypes.nlua = { "lua" }
end

return M
