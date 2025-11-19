-- https://github.com/lewis6991/gitsigns.nvim?tab=readme-ov-file
-- Adds git related signs to the gutter, as well as utilities for managing changes
return {
    'lewis6991/gitsigns.nvim',
    opts = {
        signs = {
            add = {text = '+'},
            change = {text = '~'}, -- ┃
            delete = {text = '_'},
            topdelete = {text = '‾'},
            changedelete = {text = '~'},
            untracked = {text = '┆'}
        },
        signs_staged = {
            add = {text = '+'},
            change = {text = '~'}, -- ┃
            delete = {text = '_'},
            topdelete = {text = '‾'},
            changedelete = {text = '~'},
            untracked = {text = '┆'}
        },
        signs_staged_enable = true,
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {follow_files = true},
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
            -- Options passed to nvim_open_win
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1
        },
        on_attach = function(bufnr)
            local gs = package.loaded.gitsigns

            local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, {buffer = bufnr, desc = desc})
            end

            -- Navigation
            map("n", "]h", gs.next_hunk, "Next Hunk")
            map("n", "[h", gs.prev_hunk, "Prev Hunk")

            -- Actions
            map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
            map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
            map("v", "<leader>hs", function()
                gs.stage_hunk({vim.fn.line("."), vim.fn.line("v")})
            end, "Stage hunk")
            map("v", "<leader>hr", function()
                gs.reset_hunk({vim.fn.line("."), vim.fn.line("v")})
            end, "Reset hunk")

            map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
            map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

            map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

            map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

            map("n", "<leader>hb", function()
                gs.blame_line({full = true})
            end, "Blame line")
            map("n", "<leader>hB", gs.toggle_current_line_blame,
                "Toggle line blame")

            map("n", "<leader>hd", gs.diffthis, "Diff this")
            map("n", "<leader>hD", function() gs.diffthis("~") end,
                "Diff this ~")

            -- Text object
            map({"o", "x"}, "ih", ":<C-U>Gitsigns select_hunk<CR>",
                "Gitsigns select hunk")
        end
    }
}
