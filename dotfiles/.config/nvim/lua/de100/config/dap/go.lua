local M = {}

function M.setup()
    local util = require("de100.config.dap.util")
    require("dap-go").setup({
        delve = {
            path = util.executable("dlv") or "dlv",
            detached = vim.fn.has("win32") == 0,
        },
    })
    require("dap.ext.vscode").type_to_filetypes.go = { "go" }
end

return M
