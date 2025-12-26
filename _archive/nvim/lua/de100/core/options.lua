local opt = vim.opt

-- 📏 Line Numbers
opt.number = true -- Show line numbers (default: false)
opt.relativenumber = true -- Show relative line numbers (default: false)
opt.numberwidth = 4 -- Width of number column (default: 4)
opt.signcolumn = 'yes' -- Always show sign column (default: 'auto')

-- 📋 Clipboard & Mouse
opt.clipboard = 'unnamedplus' -- Sync with system clipboard (default: '')
opt.mouse = 'a' -- Enable mouse support (default: '')

-- 🔤 Indentation
opt.autoindent = true -- Copy indent from current line (default: true)
opt.smartindent = true -- Smart autoindenting (default: false)
opt.shiftwidth = 2 -- Spaces for each indentation (default: 8)
opt.tabstop = 2 -- Spaces for a tab (default: 8)
opt.breakindent = true -- Wrapped lines keep indentation (default: false)
opt.softtabstop = 2 -- Spaces for tab while editing (default: 0)
opt.expandtab = false -- Convert tabs to spaces (default: false)

-- 🔍 Search
opt.ignorecase = true -- Case-insensitive search (default: false)
opt.smartcase = true -- Override ignorecase if uppercase in search (default: false)
opt.hlsearch = true -- Highlight search results (default: true)
opt.incsearch = true -- Show matches while typing (default: true)

-- 📺 Display
opt.termguicolors = true -- Enable 24-bit RGB colors (default: false)
opt.cursorline = false -- Highlight current line (default: false)
opt.scrolloff = 8 -- Lines to keep above/below cursor (default: 0)
opt.sidescrolloff = 8 -- Columns to keep beside cursor (default: 0)
opt.wrap = true -- Wrap long lines (default: true)
opt.linebreak = true -- Don't break words when wrapping (default: false)
opt.showtabline = 2 -- Always show tabline (default: 1)
opt.cmdheight = 1 -- Command line height (default: 1)
opt.pumheight = 10 -- Popup menu height (default: 0)
opt.conceallevel = 0 -- Show `` in markdown (default: 1)
opt.showmode = false -- Hide mode (shown in statusline) (default: true)

-- 🪟 Window Splits
opt.splitbelow = true -- Horizontal splits go below (default: false)
opt.splitright = true -- Vertical splits go right (default: false)

-- ⚡ Performance
opt.updatetime = 250 -- Faster completion (default: 4000)
opt.timeoutlen = 300 -- Faster key sequence timeout (default: 1000)

-- 💾 Files & Backups
opt.swapfile = false -- Don't create swapfile (default: true)
opt.backup = false -- Don't create backup file (default: false)
opt.writebackup = false -- Don't backup before overwriting (default: true)
opt.undofile = true -- Enable persistent undo (default: false)
opt.fileencoding = 'utf-8' -- File encoding (default: 'utf-8')

-- 🎯 Completion
opt.completeopt = 'menuone,noselect' -- Better completion experience (default: 'menu,preview')

-- ⌨️ Behavior
opt.whichwrap = 'bs<>[]hl' -- Allow cursor keys to wrap (default: 'b,s')
opt.backspace = 'indent,eol,start' -- Backspace behavior (default: 'indent,eol,start')

-- 📝 Editing
-- Don't show |ins-completion-menu| messages (default: does not include 'c')
opt.shortmess:append('c')
-- Treat hyphenated words as one word in searches (default: does not include '-')
opt.iskeyword:append('-')
-- Don't auto-insert comment leader on new lines (default: 'croql')
opt.formatoptions:remove({'c', 'r', 'o'})

-- 🔧 Compatibility
-- Separate Neovim plugins from Vim (default: includes this path if Vim exists)
opt.runtimepath:remove('/usr/share/vim/vimfiles')

-- 🎨 Colorscheme
opt.background = 'dark' -- Dark background (default: 'dark')
vim.cmd('colorscheme default') -- Set colorscheme (default: 'default')

