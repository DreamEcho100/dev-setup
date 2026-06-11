-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/05-search-and-replace.md
return {
    "dmtrKovalenko/fff.nvim",
    build = function()
        -- downloads a prebuilt binary or falls back to cargo build
        require("fff.download").download_or_build_binary()
    end,
    -- for nixos:
    -- build = "nix run .#release",
    opts = {
        debug = {enabled = true, show_scores = true},
        layout = {
            prompt_position = "top",
            height = 1,
            width = 1,
            -- 'middle_number' | 'middle' | 'end' | 'start'
            path_shorten_strategy = "start",
            flex = false
        }
    },
    lazy = false, -- the plugin lazy-initialises itself
    keys = {
        {
            "<leader>ff",
            function() require("fff").find_files() end,
            desc = "FFFind files"
        }, -- {
        --   "<leader><space>",
        --   function()
        --     require("fff").find_files()
        --   end,
        --   desc = "FFFind files",
        -- },
        {"<leader>fg", function() require("fff").live_grep() end, desc = "LiFFFe grep"},
        {
            "<leader>fz",
            function()
                require("fff").live_grep({grep = {modes = {"fuzzy", "plain"}}})
            end,
            desc = "Live fffuzy grep"
        }, {
            "<leader>fc",
            function()
                require("fff").live_grep({query = vim.fn.expand("<cword>")})
            end,
            desc = "Search current word"
        }
    }
}
