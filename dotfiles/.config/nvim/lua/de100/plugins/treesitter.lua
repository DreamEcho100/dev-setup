return {
    -- NOTE: treesitter CLI installation needed
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local treesitter = require("nvim-treesitter")

            local ensure_installed = {
                "astro",
                "bash",
                "bibtex",
                "c",
                "cmake",
                "comment",
                "cpp",
                "c_sharp",
                "css",
                "dockerfile",
                "gdscript",
                "git_config",
                "git_rebase",
                "gitattributes",
                "gitcommit",
                "gitignore",
                "go",
                "gomod",
                "gosum",
                "graphql",
                "html",
                "http",
                "java",
                "javascript",
                "jsdoc",
                "json",
                "latex",
                "lua",
                "luadoc",
                "make",
                "markdown",
                "markdown_inline",
                "prisma",
                "python",
                "query",
                "regex",
                "ron",
                "rust",
                "scss",
                "sql",
                "svelte",
                "terraform",
                "toml",
                "tsx",
                "twig",
                "typescript",
                "typst",
                "vim",
                "vimdoc",
                "vue",
                "yaml",
                "zig",
            }

            local function get_missing_parsers()
                local installed = {}
                for _, lang in ipairs(treesitter.get_installed("parsers")) do
                    installed[lang] = true
                end

                local missing = {}
                for _, lang in ipairs(ensure_installed) do
                    if not installed[lang] then
                        table.insert(missing, lang)
                    end
                end

                return missing
            end

            vim.api.nvim_create_user_command("De100TreesitterInstall", function()
                local missing = get_missing_parsers()
                if #missing == 0 then
                    vim.notify("All configured Treesitter parsers are installed")
                    return
                end

                vim.notify(("Installing %d missing Treesitter parsers"):format(#missing))
                treesitter.install(missing, { summary = true })
            end, { desc = "Install missing configured Treesitter parsers" })

            vim.api.nvim_create_user_command("De100TreesitterUpdate", function()
                treesitter.update(nil, { summary = true })
            end, { desc = "Update installed Treesitter parsers" })

            -- Safe FileType autocmd for highlighting + indentation
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                callback = function(args)
                    local buf = args.buf
                    local ft = vim.bo[buf].filetype

                    local lang = vim.treesitter.language.get_lang(ft)
                    if not lang then
                        return
                    end

                    -- start treesitter safely
                    local ok = pcall(vim.treesitter.start, buf, lang)
                    if not ok then
                        return
                    end

                    -- enable indentation (skip yaml/markdown)
                    if ft ~= "yaml" and ft ~= "markdown" then
                        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                        vim.bo[buf].smartindent = false
                        vim.bo[buf].cindent = false
                    end
                end,
            })
        end,
    }, -- NOTE: js,ts,jsx,tsx Auto Close Tags
    {
        "windwp/nvim-ts-autotag",
        enabled = true,
        ft = {
            "html",
            "xml",
            "javascript",
            "typescript",
            "javascriptreact",
            "typescriptreact",
            "svelte",
        },
        config = function()
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true, -- Auto-close tags
                    enable_rename = true, -- Auto-rename pairs
                    enable_close_on_slash = false, -- Disable auto-close on trailing `</`
                },
                per_filetype = {
                    ["html"] = { enable_close = true },
                    ["typescriptreact"] = { enable_close = true },
                },
            })
        end,
    },
}
