local M = {}

local function add_matching_files(target, pattern, excluded)
    for _, path in ipairs(vim.fn.glob(pattern, false, true)) do
        local filename = vim.fs.basename(path)
        if not vim.tbl_contains(excluded or {}, filename) then
            table.insert(target, path)
        end
    end
end

local function debug_bundles()
    local util = require("de100.config.dap.util")
    local bundles = {}
    add_matching_files(
        bundles,
        util.mason_package("java-debug-adapter", "extension", "server", "com.microsoft.java.debug.plugin-*.jar")
    )
    add_matching_files(bundles, util.mason_package("java-test", "extension", "server", "*.jar"), {
        "com.microsoft.java.test.runner-jar-with-dependencies.jar",
        "jacocoagent.jar",
    })
    return bundles
end

local function capabilities()
    local result = vim.lsp.protocol.make_client_capabilities()
    local ok, blink = pcall(require, "blink.cmp")
    if ok and type(blink.get_lsp_capabilities) == "function" then
        result = blink.get_lsp_capabilities(result)
    end
    return result
end

local function start_or_attach()
    local util = require("de100.config.dap.util")
    local jdtls_command = util.executable("jdtls")
    if not jdtls_command then
        vim.notify_once("Java support requires the Mason jdtls package", vim.log.levels.WARN)
        return
    end
    if not util.executable("java") or not util.executable("javac") then
        vim.notify_once("Java support requires a JDK 21 or newer (java + javac)", vim.log.levels.WARN)
        return
    end

    local root = vim.fs.root(0, {
        "gradlew",
        "mvnw",
        "pom.xml",
        "build.gradle",
        "build.gradle.kts",
        "settings.gradle",
        "settings.gradle.kts",
        ".git",
    }) or util.current_directory()
    local project_name = vim.fs.basename(root):gsub("[^%w_.-]", "_")
    local workspace =
        vim.fs.joinpath(vim.fn.stdpath("state"), "jdtls", project_name .. "-" .. vim.fn.sha256(root):sub(1, 12))

    local config = {
        cmd = { jdtls_command, "-data", workspace },
        root_dir = root,
        capabilities = capabilities(),
        settings = {
            java = {
                signatureHelp = { enabled = true },
                completion = { favoriteStaticMembers = {} },
                contentProvider = { preferred = "fernflower" },
                sources = {
                    organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
                },
            },
        },
        init_options = { bundles = debug_bundles() },
    }

    require("jdtls").start_or_attach(config, { dap = { hotcodereplace = "auto" } })
    require("dap.ext.vscode").type_to_filetypes.java = { "java" }
end

function M.start_or_attach(bufnr)
    bufnr = bufnr or 0
    if bufnr == 0 then
        start_or_attach()
        return
    end

    vim.api.nvim_buf_call(bufnr, start_or_attach)
end

return M
