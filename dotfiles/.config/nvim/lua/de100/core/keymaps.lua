-- Set leader key
vim.g.mapleader = ' ' -- Set leader key to space
vim.g.maplocalleader = ' ' -- Set local leader key to space

local keymap = vim.keymap -- for conciseness

-- For conciseness
local opts = {noremap = true, silent = true}

local function tbl_merge(table1, table2)
    return vim.tbl_extend('force', table1, table2)
end

local save_opts = tbl_merge(opts, {desc = 'Save file'})
local save_after_cmdline = false

local function save_current_buffer()
    if vim.bo.buftype ~= '' or not vim.bo.modifiable or vim.bo.readonly then
        return
    end

    pcall(vim.cmd.write)
end

local function save_from_cmdline()
    save_after_cmdline = true
    return vim.api.nvim_replace_termcodes('<C-c>', true, false, true)
end

vim.api.nvim_create_autocmd("CmdlineLeave", {
    desc = "Save buffer after leaving command-line mode",
    callback = function()
        if not save_after_cmdline then return end

        save_after_cmdline = false
        save_current_buffer()
    end
})

-- Disable the spacebar key's default behavior in Normal and Visual modes
keymap.set({'n', 'v'}, '<Space>', '<Nop>', {silent = true})

-- Save file
keymap.set('n', '<C-s>', save_current_buffer, save_opts)
keymap.set('i', '<C-s>', save_current_buffer, save_opts)
keymap.set('c', '<C-s>', save_from_cmdline,
           tbl_merge(opts, {expr = true, desc = 'Save file'}))
keymap.set('n', '<leader>sn', '<cmd>noautocmd w <CR>',
           tbl_merge(opts, {desc = 'Save file without auto-formatting'}))

keymap.set('n', '<C-q>', '<cmd> q <CR>', tbl_merge(opts, {desc = 'Quit file'}))

keymap.set('n', 'x', '"_x', tbl_merge(opts, {
    desc = 'Delete single character without copying into register'
}))

-- Vertical scroll and center
keymap.set('n', '<C-d>', '<C-d>zz',
           tbl_merge(opts, {desc = 'Scroll down and center'}))
keymap.set('n', '<C-u>', '<C-u>zz',
           tbl_merge(opts, {desc = 'Scroll up and center'}))

-- Find and center
keymap.set('n', 'n', 'nzzzv', tbl_merge(opts, {desc = 'Find next and center'}))
keymap.set('n', 'N', 'Nzzzv',
           tbl_merge(opts, {desc = 'Find previous and center'}))

-- Resize with arrows
keymap.set('n', '<Up>', ':resize -2<CR>',
           tbl_merge(opts, {desc = 'Resize window smaller (by 2)'}))
keymap.set('n', '<Down>', ':resize +2<CR>',
           tbl_merge(opts, {desc = 'Resize window larger (by 2)'}))
keymap.set('n', '<Left>', ':vertical resize -2<CR>',
           tbl_merge(opts, {desc = 'Resize window narrower (by 2)'}))
keymap.set('n', '<Right>', ':vertical resize +2<CR>',
           tbl_merge(opts, {desc = 'Resize window wider (by 2)'}))

-- Buffers (a buffer is a file opened in Neovim)
keymap.set('n', '<Tab>', ':bnext<CR>', tbl_merge(opts, {desc = 'Next buffer'}))
keymap.set('n', '<S-Tab>', ':bprevious<CR>',
           tbl_merge(opts, {desc = 'Previous buffer'}))
keymap.set('n', '<leader>bx', ':bdelete!<CR>',
           tbl_merge(opts, {desc = 'Close current buffer'}))
keymap.set('n', '<leader>bo', '<cmd> enew <CR>',
           tbl_merge(opts, {desc = 'Open new buffer'}))

-- split management
vim.keymap.set("n", "<leader>sv", "<C-w>v", {desc = "Split window vertically"})
-- split window vertically
vim.keymap
    .set("n", "<leader>sh", "<C-w>s", {desc = "Split window horizontally"})
-- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", {desc = "Make splits equal size"}) -- make split windows equal width & height
-- close current split window
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>",
               {desc = "Close current split"})

-- Navigate between splits
keymap.set('n', '<C-k>', ':wincmd k<CR>',
           tbl_merge(opts, {desc = 'Move to upper split window'}))
keymap.set('n', '<C-j>', ':wincmd j<CR>',
           tbl_merge(opts, {desc = 'Move to lower split window'}))
keymap.set('n', '<C-h>', ':wincmd h<CR>',
           tbl_merge(opts, {desc = 'Move to left split window'}))
keymap.set('n', '<C-l>', ':wincmd l<CR>',
           tbl_merge(opts, {desc = 'Move to right split window'}))

-- Tabs
keymap.set('n', '<leader>to', ':tabnew<CR>',
           tbl_merge(opts, {desc = 'Open new tab'}))
keymap.set('n', '<leader>tx', ':tabclose<CR>',
           tbl_merge(opts, {desc = 'Close current tab'}))
keymap.set('n', '<leader>tn', ':tabn<CR>',
           tbl_merge(opts, {desc = 'Go to next tab'}))
keymap.set('n', '<leader>tp', ':tabp<CR>',
           tbl_merge(opts, {desc = 'Go to previous tab'}))
keymap.set('n', '<leader>tf', ':tabnew %<CR>',
           tbl_merge(opts, {desc = 'Open current buffer in new tab'}))

-- Toggle line wrapping
keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>',
           tbl_merge(opts, {desc = 'Toggle line wrapping'}))

-- Stay in indent mode
keymap.set('v', '<', '<gv',
           tbl_merge(opts, {desc = 'Indent line and stay in indent mode'}))
keymap.set('v', '>', '>gv',
           tbl_merge(opts, {desc = 'Unindent line and stay in indent mode'}))

-- Keep last yanked when pasting
keymap.set('v', 'p', '"_dP', tbl_merge(opts, {
    desc = 'Paste over selection without overwriting register'
}))

-- Diagnostic keymaps
keymap.set('n', '[d', vim.diagnostic.goto_prev,
           {desc = 'Go to previous diagnostic message'})
keymap.set('n', ']d', vim.diagnostic.goto_next,
           {desc = 'Go to next diagnostic message'})
keymap.set('n', '<leader>dd', vim.diagnostic.open_float,
           {desc = 'Open floating diagnostic message'})
keymap.set('n', '<leader>q', vim.diagnostic.setloclist,
           {desc = 'Open diagnostics list'})

-- Clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", {desc = "Clear search highlights"})

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv",
               {desc = "moves lines down in visual selection"})
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv",
               {desc = "moves lines up in visual selection"})

-- ctrl c as escape cuz Im lazy _(XD)_ to reach up to the esc key
vim.keymap.set("i", "<C-c>", "<Esc>")
-- Stars new tmux session from in here
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Hightlight yanking
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank",
                                        {clear = true}),
    callback = function() vim.hl.on_yank() end
})

-- Copy filepath to the clipboard
vim.keymap.set("n", "<leader>fp", function()
    local filePath = vim.fn.expand("%:~") -- Gets the file path relative to the home directory
    vim.fn.setreg("+", filePath) -- Copy the file path to the clipboard register
    print("File path copied to clipboard: " .. filePath)
end, {desc = "Copy file path to clipboard"})

-- Toggle LSP diagnostics visibility
local isLspDiagnosticsVisible = true
vim.keymap.set("n", "<leader>lx", function()
    isLspDiagnosticsVisible = not isLspDiagnosticsVisible
    vim.diagnostic.config({
        virtual_text = isLspDiagnosticsVisible,
        underline = isLspDiagnosticsVisible
    })
end, {desc = "Toggle LSP diagnostics"})

-- Lightweight split zoom replacement for vim-maximizer.
vim.keymap.set("n", "<leader>sm", function()
    if vim.t.de100_zoomed_winrestcmd then
        vim.cmd(vim.t.de100_zoomed_winrestcmd)
        vim.t.de100_zoomed_winrestcmd = nil
        return
    end

    vim.t.de100_zoomed_winrestcmd = vim.fn.winrestcmd()
    vim.cmd("resize")
    vim.cmd("vertical resize")
end, {desc = "Toggle split zoom"})

-- -- Misc
-- -- desc = 'Source the init.lua file, reloading the config'
-- vim.keymap.set('n', '<leader>-', 'yy', opts)
-- vim.keymap.set("n", "J", "mzJ`z")
-- -- the how it be paste
-- vim.keymap.set("x", "<leader>p", [["_dP]])
-- -- Copies or Yank to system clipboard
-- vim.keymap.set("n", "<leader>Y", [["+Y]], opts)
-- -- leader d delete wont remember as yanked/clipboard when delete pasting
-- vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])
-- -- Replace the word cursor is on globally
-- vim.keymap.set("n", "<leader>s",
--                [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
--                {desc = "Replace word cursor is on globally"})
-- -- Executes shell command from in here making file executable
-- vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>",
--                {silent = true, desc = "makes file executable"})
