vim.keymap.set("n", "<leader>mcd", function()
    local root = require("de100.utils.project-root").find()
    if not root then
        vim.notify("No project root found", vim.log.levels.WARN)
        return
    end
    vim.cmd("cd " .. vim.fn.fnameescape(root))
    vim.notify("Project root: " .. root, vim.log.levels.INFO)
end, {desc = "cd to project root"})
