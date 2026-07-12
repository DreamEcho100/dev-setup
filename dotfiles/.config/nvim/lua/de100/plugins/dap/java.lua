return {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
        local group = vim.api.nvim_create_augroup("de100_java_jdtls", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = "java",
            callback = function(args)
                require("de100.config.dap.java").start_or_attach(args.buf)
            end,
            desc = "Start or attach JDTLS for each Java project",
        })
        require("de100.config.dap.java").start_or_attach(0)
    end,
}
