local M = {}

function M.setup()
    local util = require("de100.config.dap.util")
    local adapter = util.executable("debugpy-adapter")
    if not adapter then
        adapter = util.mason_package("debugpy", "venv", "bin", "python")
    end

    require("dap-python").setup(adapter)
    require("dap.ext.vscode").type_to_filetypes.debugpy = { "python" }
end

return M
