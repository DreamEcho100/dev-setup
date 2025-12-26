-- Set leader key
vim.g.mapleader = ' ' -- Set leader key to space
vim.g.maplocalleader = ' ' -- Set local leader key to space

local keymap = vim.keymap -- for conciseness

-- For conciseness
local opts = {noremap = true, silent = true}

function tbl_merge(table1, table2) return
    vim.tbl_extend('force', table1, table2) end

-- Disable the spacebar key's default behavior in Normal and Visual modes
keymap.set({'n', 'v'}, '<Space>', '<Nop>', {silent = true})

-- Save file
keymap.set('n', '<C-s>', '<cmd> w <CR>', tbl_merge(opts, {desc = 'Save file'}))
keymap.set('n', '<leader>sn', '<cmd>noautocmd w <CR>',
           tbl_merge(opts, {desc = 'Save file without auto-formatting'}))
-- Quit file
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

-- Window management
keymap.set('n', '<leader>v', '<C-w>v',
           tbl_merge(opts, {desc = 'Split window vertically'}))
keymap.set('n', '<leader>h', '<C-w>s',
           tbl_merge(opts, {desc = 'Split window horizontally'}))
keymap.set('n', '<leader>se', '<C-w>=',
           tbl_merge(opts, {desc = 'Make split windows equal width & height'}))
keymap.set('n', '<leader>sx', ':close<CR>',
           tbl_merge(opts, {desc = 'Close current split window'}))

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
keymap.set('n', '<leader>d', vim.diagnostic.open_float,
           {desc = 'Open floating diagnostic message'})
keymap.set('n', '<leader>q', vim.diagnostic.setloclist,
           {desc = 'Open diagnostics list'})

-- Clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", {desc = "Clear search highlights"})

-- Misc
-- desc = 'Source the init.lua file, reloading the config'

-- vim.keymap.set('n', '<leader>-', 'yy', opts)
