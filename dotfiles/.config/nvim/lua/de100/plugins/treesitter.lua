return {
    "nvim-treesitter/nvim-treesitter",
    event = {"BufReadPre", "BufNewFile"},
    build = ":TSUpdate",
    config = function()
        -- import nvim-treesitter plugin
        local treesitter = require("nvim-treesitter.configs")

        -- configure treesitter
        treesitter.setup({ -- enable syntax highlighting
            -- Autoinstall languages that are not installed
            auto_install = true,
            highlight = {
                enable = true,
                -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
                --  If you are experiencing weird indenting issues, add the language to
                --  the list of additional_vim_regex_highlighting and disabled languages for indent.
                additional_vim_regex_highlighting = {'ruby'}
            },
            indent = {enable = true, disable = {'ruby'}},
            -- ensure these language parsers are installed
            ensure_installed = {"json", "javascript", "typescript", "tsx", "yaml", "html", "css", "prisma", "markdown",
                                "markdown_inline", "svelte", "graphql", "bash", "lua", "vim", "dockerfile", "gitignore",
                                "query", "vimdoc", "c", 'python', 'regex', 'terraform', 'sql', 'toml', 'json', 'java',
                                'groovy', 'go', 'make', 'cmake'},
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>"
                }
            }
        })

        -- use bash parser for zsh files
        vim.treesitter.language.register("bash", "zsh")
    end
}
