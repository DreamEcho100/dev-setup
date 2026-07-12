local M = {}

local function setup_dotnet()
    local dap = require("dap")
    local util = require("de100.config.dap.util")
    local command = util.executable("netcoredbg")
    if not command or not util.executable("dotnet") then
        return
    end

    dap.adapters.coreclr = {
        type = "executable",
        command = command,
        args = { "--interpreter=vscode" },
    }
    dap.configurations.cs = {
        {
            name = ".NET: launch assembly",
            type = "coreclr",
            request = "launch",
            program = function()
                local root = vim.fs.root(0, function(name)
                    return name:match("%.sln$") ~= nil or name:match("%.csproj$") ~= nil
                end) or util.project_root({ ".git" })
                local candidates = vim.fn.globpath(root, "**/bin/Debug/**/*.dll", false, true)
                candidates = vim.tbl_filter(function(path)
                    return not path:match("%.deps%.dll$")
                        and not path:match("testhost%.dll$")
                        and not path:match("/ref/")
                end, candidates)
                return util.select_file("Select .NET assembly", candidates)
            end,
            cwd = "${workspaceFolder}",
            justMyCode = true,
        },
        {
            name = ".NET: attach to process",
            type = "coreclr",
            request = "attach",
            processId = require("dap.utils").pick_process,
        },
    }
    require("dap.ext.vscode").type_to_filetypes.coreclr = { "cs", "razor" }
end

local function setup_godot()
    local dap = require("dap")
    dap.adapters.godot = { type = "server", host = "127.0.0.1", port = 6006 }
    dap.configurations.gdscript = {
        {
            name = "Godot: launch project",
            type = "godot",
            request = "launch",
            project = "${workspaceFolder}",
        },
    }
    require("dap.ext.vscode").type_to_filetypes.godot = { "gdscript" }
end

function M.setup()
    setup_dotnet()
    setup_godot()
end

return M
