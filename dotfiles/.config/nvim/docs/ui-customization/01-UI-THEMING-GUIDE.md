# UI Customization & Theming: Complete Guide

## Your Current UI Configuration

Your Neovim setup already has a **polished, professional UI**. This guide analyzes what you have and shows how to customize it further.

---

## Current UI Components Analysis

### 1. Color Scheme (OneDark)

**Location**: `lua/de100/plugins/colortheme.lua` (48 lines)

```lua
{
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
        require("onedark").setup({
            style = "dark",  -- 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer'
            transparent = false,
            term_colors = true,
            ending_tildes = false,
            cmp_itemkind_reverse = false,
            
            -- Custom highlights
            code_style = {
                comments = "italic",
                keywords = "none",
                functions = "none",
                strings = "none",
                variables = "none"
            },
            
            -- LSP semantic highlighting
            lsp_semantic_tokens = true,
            
            -- Color overrides
            colors = {},
            highlights = {},
        })
        
        require("onedark").load()
    end,
}
```

**Available Styles**:
- `dark` - Your current style, balanced dark theme
- `darker` - Higher contrast
- `cool` - Blue-tinted
- `deep` - Deep blue background
- `warm` - Orange-tinted
- `warmer` - Higher saturation warm colors

**Try Different Style**:
```lua
style = "darker",  -- In colortheme.lua
```

### 2. Statusline (Lualine)

**Location**: `lua/de100/plugins/lualine.lua` (156 lines)

**Components** (from left to right):
```
 NORMAL  main  +12 ~5 -3  user.ts  󰦪 1:15  50%
    ↓      ↓      ↓         ↓        ↓    ↓
   mode  branch  diff     filename  pos  progress
```

**Your Configuration Highlights**:
- Custom mode display with icons
- Git branch with diff stats
- File path relative to git root
- LSP status indicator
- Diagnostics (errors, warnings)
- File encoding and format
- Custom colors matching OneDark

**Mode Icons** (configured):
```lua
modes = {
    ['n']  = 'NORMAL',
    ['i']  = 'INSERT',
    ['v']  = 'VISUAL',
    ['V']  = 'V-LINE',
    [''] = 'V-BLOCK',
    -- ... etc
}
```

### 3. Tabline (Bufferline)

**Location**: `lua/de100/plugins/bufferline.lua` (56 lines)

**Layout**:
```
 user.ts  × │  config.lua  × │  README.md  × │ + New
   ↓         ↓                  ↓              ↓
 buffer    close            current         new tab
```

**Your Configuration**:
- Buffer tabs at top
- Close buttons (`×`)
- Modified indicator
- Mouse support
- Diagnostics integration
- Groups by LSP root

**Features**:
```lua
options = {
    mode = "buffers",
    numbers = "none",
    close_command = "Bdelete! %d",  -- Uses vim-bbye for safe close
    indicator = {
        style = "icon",
        icon = "▎",
    },
    buffer_close_icon = "󰅖",
    modified_icon = "●",
    diagnostics = "nvim_lsp",
}
```

### 4. Start Screen (Alpha)

**Location**: `lua/de100/plugins/alpha.lua` (37 lines)

**Shows**:
- Neovim ASCII art
- Recent files
- Quick actions (find files, etc.)
- Footer with version

### 5. Indent Guides

**Location**: `lua/de100/plugins/indent-blankline.lua` (8 lines)

Shows subtle vertical lines for indentation levels.

---

## Customization Options

### Color Scheme Variants

#### 1. Make Background Transparent

```lua
-- In colortheme.lua
require("onedark").setup({
    transparent = true,  -- See-through background
    -- ... rest of config
})
```

**Result**: Terminal background shows through Neovim.

#### 2. Customize Colors

```lua
-- In colortheme.lua
require("onedark").setup({
    colors = {
        bg0 = "#1e222a",     -- Background
        bg1 = "#282c34",     -- Darker background
        fg = "#abb2bf",      -- Foreground
        red = "#e06c75",
        orange = "#d19a66",
        yellow = "#e5c07b",
        green = "#98c379",
        cyan = "#56b6c2",
        blue = "#61afef",
        purple = "#c678dd",
    },
})
```

#### 3. Custom Highlights

```lua
-- In colortheme.lua
require("onedark").setup({
    highlights = {
        TSComment = { fg = "$grey", italic = true },
        ["@comment"] = { fg = "$grey", italic = true },
        TSKeyword = { fg = "$purple", bold = true },
        Function = { fg = "$blue", bold = true },
    },
})
```

### Alternative Color Schemes

#### Catppuccin (Popular)

```lua
-- Replace onedark with catppuccin
return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",  -- latte, frappe, macchiato, mocha
            transparent_background = false,
            term_colors = true,
            integrations = {
                cmp = true,
                gitsigns = true,
                nvimtree = true,
                treesitter = true,
                telescope = true,
            },
        })
        vim.cmd.colorscheme("catppuccin")
    end,
}
```

#### Tokyonight

```lua
return {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
        require("tokyonight").setup({
            style = "storm",  -- storm, moon, night, day
            transparent = false,
            terminal_colors = true,
            styles = {
                comments = { italic = true },
                keywords = { italic = true },
            },
        })
        vim.cmd.colorscheme("tokyonight")
    end,
}
```

#### Gruvbox

```lua
return {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
        require("gruvbox").setup({
            contrast = "hard",  -- soft, medium, hard
            transparent_mode = false,
        })
        vim.cmd.colorscheme("gruvbox")
    end,
}
```

### Statusline Customization

#### Add Custom Component

```lua
-- In lualine.lua, add to sections
sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = {
        'filename',
        -- Add custom component
        {
            function()
                return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
            end,
            icon = '📁',
        }
    },
    -- ... rest
}
```

#### Show LSP Clients

```lua
-- Add to lualine_x
{
    function()
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then
            return 'No LSP'
        end
        local names = {}
        for _, client in ipairs(clients) do
            table.insert(names, client.name)
        end
        return table.concat(names, ', ')
    end,
    icon = '',
}
```

#### Show Git Blame

```lua
-- Requires gitsigns
{
    function()
        local blame = vim.b.gitsigns_blame_line
        if not blame then return '' end
        return blame
    end,
    cond = function()
        return vim.b.gitsigns_blame_line ~= nil
    end,
}
```

### Bufferline Customization

#### Tab-Style Display

```lua
-- In bufferline.lua
options = {
    mode = "tabs",  -- Instead of "buffers"
    -- Show actual tabs instead of buffers
}
```

#### Group Buffers by Directory

```lua
-- In bufferline.lua
options = {
    groups = {
        options = {
            toggle_hidden_on_enter = true,
        },
        items = {
            {
                name = "Tests",
                highlight = { underline = true, sp = "blue" },
                priority = 2,
                matcher = function(buf)
                    return buf.filename:match('.test.') or buf.filename:match('.spec.')
                end,
            },
            {
                name = "Docs",
                highlight = { underline = true, sp = "green" },
                matcher = function(buf)
                    return buf.filename:match('%.md')
                end,
            },
        },
    },
}
```

#### Show Buffer Numbers

```lua
-- In bufferline.lua
options = {
    numbers = "buffer_id",  -- or "ordinal" or "both"
}
```

**Usage**: `<leader>1` to jump to buffer 1, etc. (add keybindings)

### Icons Customization

Your config uses **nvim-web-devicons** for file type icons.

#### Change Specific Icons

```lua
-- Add to your config
require('nvim-web-devicons').setup({
    override = {
        ts = {
            icon = "",
            color = "#519aba",
            name = "Ts"
        },
        js = {
            icon = "",
            color = "#cbcb41",
            name = "Js"
        },
    },
    default = true,
})
```

### Indent Guides Enhancement

```lua
-- In indent-blankline.lua
require("ibl").setup({
    indent = {
        char = "│",      -- or "▏" or "┊"
        tab_char = "│",
    },
    scope = {
        enabled = true,
        show_start = true,
        show_end = true,
        highlight = { "Function", "Label" },
    },
    exclude = {
        filetypes = { "dashboard", "lazy", "mason" },
    },
})
```

---

## Window Decorations

### Window Separators

```lua
-- In options.lua or init.lua
vim.opt.fillchars = {
    vert = '│',
    horiz = '─',
    horizup = '┴',
    horizdown = '┬',
    vertleft = '┤',
    vertright = '├',
    verthoriz = '┼',
}
```

### Cursor Line

Already enabled in your `options.lua`:
```lua
vim.opt.cursorline = true  -- Highlight current line
```

**Customize**:
```lua
-- Make it more/less prominent
vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#2c323c' })  -- Darker
vim.api.nvim_set_hl(0, 'CursorLine', { bg = '#3e4451' })  -- Lighter
```

### Line Numbers

Your current config:
```lua
vim.opt.relativenumber = true  -- Relative line numbers
vim.opt.number = true          -- Show current line number
```

Result:
```
  3  │
  2  │
  1  │
 45  │  ← Current line (absolute number)
  1  │
  2  │
  3  │
```

**Alternative** (absolute only):
```lua
vim.opt.relativenumber = false
vim.opt.number = true
```

### Sign Column

Your config has signs for:
- LSP diagnostics (errors, warnings)
- Git changes (gitsigns)
- Debug breakpoints (if dap added)

**Always show**:
```lua
vim.opt.signcolumn = "yes"  -- Always reserve space
```

**Auto-adjust**:
```lua
vim.opt.signcolumn = "auto"  -- Show when needed
```

---

## Floating Window Styling

### Borders

Your config uses borders in several places:

**Telescope**:
```lua
-- In telescope.lua
defaults = {
    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
}
```

**LSP**:
```lua
-- In lsp config
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = "rounded"  -- or "single", "double", "shadow"
    }
)
```

**Custom Borders**:
```lua
local border = {
    {"🭽", "FloatBorder"},
    {"▔", "FloatBorder"},
    {"🭾", "FloatBorder"},
    {"▕", "FloatBorder"},
    {"🭿", "FloatBorder"},
    {"▁", "FloatBorder"},
    {"🭼", "FloatBorder"},
    {"▏", "FloatBorder"},
}
```

---

## Completion Menu Styling

Your nvim-cmp config already has LSPKind integration.

### Customize Completion Window

```lua
-- In nvim-cmp.lua
window = {
    completion = {
        border = "rounded",
        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
        col_offset = -3,
        side_padding = 0,
    },
    documentation = {
        border = "rounded",
        max_height = 15,
        max_width = 60,
    },
}
```

### Custom Item Formatting

```lua
-- In nvim-cmp.lua
formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
        local kind = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 50
        })(entry, vim_item)
        
        local strings = vim.split(kind.kind, "%s", { trimempty = true })
        kind.kind = " " .. (strings[1] or "") .. " "
        kind.menu = "    (" .. (strings[2] or "") .. ")"
        
        return kind
    end,
}
```

---

## Notification Styling

Add **nvim-notify** for better notifications:

```lua
return {
    "rcarriga/nvim-notify",
    config = function()
        local notify = require("notify")
        notify.setup({
            stages = "fade_in_slide_out",
            timeout = 3000,
            background_colour = "#000000",
            icons = {
                ERROR = "",
                WARN = "",
                INFO = "",
                DEBUG = "",
                TRACE = "✎",
            },
        })
        vim.notify = notify
    end,
}
```

---

## Dashboard Customization

Your Alpha dashboard can be customized:

```lua
-- In alpha.lua
local dashboard = require("alpha.themes.dashboard")

-- Custom header
dashboard.section.header.val = {
    [[                                                    ]],
    [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
    [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
    [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
    [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
    [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
    [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
    [[                                                    ]],
}

-- Custom buttons
dashboard.section.buttons.val = {
    dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
    dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
    dashboard.button("g", "  Find text", ":Telescope live_grep<CR>"),
    dashboard.button("c", "  Config", ":e $MYVIMRC<CR>"),
    dashboard.button("q", "  Quit", ":qa<CR>"),
}
```

---

## UI Components Plugins

### Additional UI Enhancements

#### Noice (Better UI for cmdline, messages, popupmenu)

```lua
return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
    config = function()
        require("noice").setup({
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
            },
        })
    end,
}
```

#### Dressing (Better vim.ui interfaces)

```lua
return {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function()
        require("dressing").setup({
            input = {
                enabled = true,
                default_prompt = "Input:",
                prompt_align = "left",
                insert_only = true,
                border = "rounded",
            },
            select = {
                enabled = true,
                backend = { "telescope", "fzf_lua", "fzf", "builtin", "nui" },
                telescope = require("telescope.themes").get_dropdown(),
            },
        })
    end,
}
```

---

## Comparison: Your UI vs VSCode

| Component | Your Setup | VSCode |
|-----------|-----------|--------|
| **Color Scheme** | OneDark (customizable) | Many themes |
| **Statusline** | Lualine (detailed) | Basic info bar |
| **Tabs** | Bufferline (feature-rich) | Basic tabs |
| **Icons** | nvim-web-devicons | VSCode icons |
| **Start Screen** | Alpha (customizable) | Welcome page |
| **Performance** | <5ms render | 50-100ms |
| **Customization** | Full Lua control | Limited |
| **Memory** | ~10-15MB | ~50MB UI alone |

---

## Complete Customization Example

Here's a cohesive dark theme setup:

```lua
-- colortheme.lua
return {
    "navarasu/onedark.nvim",
    config = function()
        require("onedark").setup({
            style = "darker",
            transparent = false,
            code_style = {
                comments = "italic",
                keywords = "bold",
                functions = "none",
            },
            colors = {
                bg0 = "#1a1d23",  -- Darker background
            },
            highlights = {
                CursorLine = { bg = "#252931" },
                FloatBorder = { fg = "#61afef", bg = "#1a1d23" },
            },
        })
        require("onedark").load()
    end,
}
```

---

## Troubleshooting

### Colors Look Wrong

1. **Check terminal true color support**:
   ```lua
   vim.opt.termguicolors = true  -- Already in your options.lua
   ```

2. **Check terminal emulator**: Use modern terminal (Alacritty, Kitty, iTerm2)

### Icons Not Showing

1. **Install Nerd Font**: Your terminal needs a Nerd Font
   - Download from nerdfonts.com
   - Recommended: FiraCode Nerd Font, JetBrainsMono Nerd Font

2. **Configure terminal** to use the Nerd Font

### Statusline Not Updating

```vim
:set laststatus=3  " Global statusline
" Or
:set laststatus=2  " Per-window statusline
```

---

## Pro Tips

1. **Match Theme**: Ensure terminal background matches Neovim background
2. **Nerd Fonts**: Essential for icons - install proper Nerd Font
3. **True Color**: Always enable `termguicolors`
4. **Transparent Mode**: Looks great with terminal blur effects
5. **Consistent Borders**: Use same border style throughout
6. **Custom Highlights**: Override specific colors that don't look right
7. **Statusline Minimal**: Don't add too many components (slow)
8. **Icons Meaning**: Learn what icons mean for faster scanning
9. **Color Scheme Trial**: Try theme for 1 week before changing
10. **Document Custom**: Comment your customizations

---

## Resources

- **Your Current UI Files**:
  - `lua/de100/plugins/colortheme.lua`
  - `lua/de100/plugins/lualine.lua`
  - `lua/de100/plugins/bufferline.lua`
  - `lua/de100/plugins/alpha.lua`
  - `lua/de100/plugins/indent-blankline.lua`

- **Plugin Documentation**:
  - OneDark: https://github.com/navarasu/onedark.nvim
  - Lualine: https://github.com/nvim-lualine/lualine.nvim
  - Bufferline: https://github.com/akinsho/bufferline.nvim
  - Alpha: https://github.com/goolord/alpha-nvim
  - Nvim-web-devicons: https://github.com/nvim-tree/nvim-web-devicons

- **Color Scheme Collections**:
  - https://vimcolorschemes.com/
  - https://github.com/rockerBOO/awesome-neovim#colorscheme

---

**Your UI is already professional-grade! These customizations are for fine-tuning to your preference. 🎨✨**
