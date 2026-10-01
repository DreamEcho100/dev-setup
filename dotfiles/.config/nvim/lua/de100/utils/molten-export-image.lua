-- :MoltenCellExportImage / :MoltenAllCellsExportImage. Draw the output of the
-- cell under the cursor, or of every finished cell in this file, onto one PNG
-- saved next to the file as <file name>-<cell|all-cells>-<timestamp>.png, in the
-- active colorscheme's colours. The drawing is the DreamEcho100 molten-nvim
-- fork's :MoltenExportImage; this only picks the name, colours and font.
local M = {}

local function hex(n) return n and string.format("#%06x", n) or nil end

--- The font family the terminal is configured with: kitty's `font_family` (kitty.conf,
--- then local.conf, last one wins) or ghostty's `font-family`, per the terminal in use.
local function terminal_font_family()
    local function last_value(files, key)
        local value
        for _, file in ipairs(files) do
            if vim.fn.filereadable(file) == 1 then
                for _, line in ipairs(vim.fn.readfile(file)) do
                    local v = line:match("^%s*" .. key .. "%s*[=%s]%s*(.-)%s*$")
                    if v and v ~= "" then value = v end
                end
            end
        end
        return value and (value:gsub('^family="?', ""):gsub('^"', ""):gsub('"$', ""))
    end

    local config = vim.fn.expand("~/.config")
    local kitty = {config .. "/kitty/kitty.conf", config .. "/kitty/local.conf"}
    local ghostty = {config .. "/ghostty/config.ghostty", config .. "/ghostty/local.ghostty"}
    local in_ghostty = vim.env.GHOSTTY_RESOURCES_DIR ~= nil or vim.env.TERM_PROGRAM == "ghostty"
    local first, second = kitty, ghostty
    local key_first, key_second = "font_family", "font%-family"
    if in_ghostty then
        first, second, key_first, key_second = ghostty, kitty, key_second, key_first
    end
    return last_value(first, key_first) or last_value(second, key_second)
end

--- The Regular-style file of an installed font family (fc-match answers with an
--- unrelated font here, so the list is searched instead).
local function family_file(family)
    if not family or family == "auto" or vim.fn.executable("fc-list") == 0 then return nil end
    local wanted = family:lower()
    local fallback
    for _, line in ipairs(vim.fn.systemlist({"fc-list", "-f", "%{family}\t%{style}\t%{file}\n"})) do
        local families, style, file = line:match("^(.-)\t(.-)\t(.+)$")
        if families then
            for name in families:gmatch("[^,]+") do
                if name:lower() == wanted then
                    local lower = style:lower()
                    if lower == "regular" then return file end
                    -- weights like "Medium,Regular" list Regular too, so only use them if nothing is plain
                    if not lower:match("italic") then fallback = fallback or file end
                end
            end
        end
    end
    return fallback
end

--- A monospace font file for the image: the terminal's own font if it can be found,
--- else a font the dev scripts install (JetBrainsMono Nerd Font, DejaVu, Liberation),
--- else "-" and the fork uses its default.
local function font_file()
    local file = family_file(terminal_font_family())
    if file and vim.fn.filereadable(file) == 1 then return file end
    local dirs = {vim.fn.expand("~/.local/share/fonts"), "/usr/share/fonts", "/usr/local/share/fonts"}
    for _, name in ipairs({"JetBrainsMonoNerdFontMono-Regular.ttf", "DejaVuSansMono.ttf", "LiberationMono-Regular.ttf"}) do
        for _, dir in ipairs(dirs) do
            local found = vim.fn.findfile(name, dir .. "/**")
            if found ~= "" then return vim.fn.fnamemodify(found, ":p") end
        end
    end
    return "-"
end

local function export(mode, label)
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" or vim.bo.buftype ~= "" then
        vim.notify("Molten export image: this buffer is not a file", vim.log.levels.WARN)
        return
    end
    if vim.fn.exists(":MoltenExportImage") ~= 2 then
        vim.notify("Molten export image: this Molten has no :MoltenExportImage yet. Run :Lazy update molten-nvim, " ..
                       "then :UpdateRemotePlugins, then restart Neovim.", vim.log.levels.WARN)
        return
    end
    local normal = vim.api.nvim_get_hl(0, {name = "Normal", link = false})
    local path = ("%s/%s-%s-%s.png"):format(vim.fn.fnamemodify(file, ":h"), vim.fn.fnamemodify(file, ":t:r"),
                                            label, os.date("%Y%m%d-%H%M%S"))
    local args = vim.tbl_map(vim.fn.fnameescape,
                             {mode, path, hex(normal.bg) or "#1f1f1f", hex(normal.fg) or "#d4d4d4", font_file()})
    local ok, err = pcall(vim.cmd, "MoltenExportImage " .. table.concat(args, " "))
    if not ok then vim.notify("Molten export image: " .. tostring(err), vim.log.levels.WARN) end
end

function M.cell() export("cell", "cell") end

function M.all_cells() export("all", "all-cells") end

function M.setup()
    vim.api.nvim_create_user_command("MoltenCellExportImage", M.cell, {
        desc = "Save the output of the cell under the cursor as a PNG next to this file"
    })
    vim.api.nvim_create_user_command("MoltenAllCellsExportImage", M.all_cells, {
        desc = "Save the output of every cell in this file as one PNG next to it"
    })
end

return M
