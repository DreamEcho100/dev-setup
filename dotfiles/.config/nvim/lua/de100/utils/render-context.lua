-- Exports the active colorscheme's Normal bg/fg, plus the terminal's real
-- cell pixel dimensions, to
-- <stdpath state>/de100/theme/render-context.json (stdpath("state") is
-- $XDG_STATE_HOME/nvim, not $XDG_STATE_HOME itself) on every colorscheme
-- change and terminal resize, so out-of-process consumers (e.g. the
-- Math/Latex render hook at
-- dotfiles/.config/ipython/startup/10-de100-math-render.py) can match
-- rendered images to the current theme and size them against the real
-- terminal font instead of hardcoding colors/DPI.
-- Sibling to the nvim.lua state file de100/utils/theme-persist.lua and
-- de100-theme-sync already write to the same directory.
-- Required from init.lua BEFORE current-theme.lua, so this autocmd is
-- already registered when the very first colorscheme applies at startup.
local function to_hex(n) return n and string.format("#%06x", n) or nil end

local function is_finite_positive(n)
    return type(n) == "number" and n > 0 and n < (1 / 0)
end

-- Same ioctl(TIOCGWINSZ) approach as image.nvim's lua/image/utils/term.lua
-- (already installed, so this struct/ioctl-number logic is known-good on
-- this setup) — but called fresh every export rather than trusting that
-- module's own cache, which only refreshes on VimResized. A terminal that
-- doesn't fire that event for a font-size-only zoom (no row/col change)
-- would otherwise leave us with stale pixel dimensions indefinitely.
local function query_cell_size()
    local ok, ffi = pcall(require, "ffi")
    if not ok then return nil end

    ffi.cdef([[
        typedef struct {
            unsigned short row;
            unsigned short col;
            unsigned short xpixel;
            unsigned short ypixel;
        } de100_winsize;
        int ioctl(int, int, ...);
    ]])

    local TIOCGWINSZ
    if vim.fn.has("linux") == 1 then
        TIOCGWINSZ = 0x5413
    elseif vim.fn.has("mac") == 1 or vim.fn.has("bsd") == 1 then
        TIOCGWINSZ = 0x40087468
    else
        return nil
    end

    local sz = ffi.new("de100_winsize")
    if ffi.C.ioctl(1, TIOCGWINSZ, sz) ~= 0 then return nil end

    local xpixel, ypixel = sz.xpixel, sz.ypixel
    -- Pixel dims are unavailable over SSH; without this fallback,
    -- cell_width/cell_height come out as 0 (or NaN once divided further).
    if xpixel == 0 or ypixel == 0 then
        xpixel = sz.col * 8
        ypixel = sz.row * 16
    end
    if sz.col == 0 or sz.row == 0 then return nil end

    return {cell_width = xpixel / sz.col, cell_height = ypixel / sz.row}
end

local function export_context()
    local hl = vim.api.nvim_get_hl(0, {name = "Normal", link = false})
    local data = {}
    if hl.bg then data.bg = to_hex(hl.bg) end
    if hl.fg then data.fg = to_hex(hl.fg) end

    local term_ok, term_size = pcall(query_cell_size)
    if term_ok and term_size and is_finite_positive(term_size.cell_width) and
        is_finite_positive(term_size.cell_height) then
        data.cell_width = term_size.cell_width
        data.cell_height = term_size.cell_height
    end

    local dir = vim.fn.stdpath("state") .. "/de100/theme"
    vim.fn.mkdir(dir, "p")
    local path = dir .. "/render-context.json"
    local tmp = path .. ".tmp"
    local fh = assert(io.open(tmp, "w"))
    fh:write(vim.json.encode(data))
    fh:close()
    os.rename(tmp, path)
end

local group = vim.api.nvim_create_augroup("de100_render_context", {clear = true})
vim.api.nvim_create_autocmd({"ColorScheme", "VimResized"},
                             {group = group, callback = export_context})
