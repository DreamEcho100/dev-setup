-- Per-target path display. Every surface that shows a path (tabline, incline
-- badge, lualine, telescope results) has its own style with its
-- own default; :PathStyle changes one target at a time.
--
--   :PathStyle                    pick a target, then a style (vim.ui.select)
--   :PathStyle <target>           cycle that target to its next style
--   :PathStyle <target> <style>   set it directly
local M = {}

M.styles = {"relative", "parent", "absolute", "project", "tail"}

M.defaults = {
    tabline = "relative",
    incline = "parent",
    lualine = "parent",
    search = "relative"
}

M.targets = {"tabline", "incline", "lualine", "search"}

local descriptions = {
    relative = "relative to cwd, full (~ form outside cwd)",
    parent = "filename + immediate parent dir",
    absolute = "absolute path (~ for home)",
    project = "relative to the project root",
    tail = "filename only"
}

function M.get(target)
    local overrides = vim.g.de100_path_styles or {}
    return overrides[target] or M.defaults[target] or "relative"
end

function M.set(target, style)
    local overrides = vim.deepcopy(vim.g.de100_path_styles or {})
    overrides[target] = style
    vim.g.de100_path_styles = overrides
end

--- Strips URL-ish buffer names (oil:///a/b/) down to a filesystem path;
--- returns nil for buffers that aren't files/dirs (terminals, help, ...).
local function real_path(name)
    if name == "" then return nil end
    if name:match("^oil://") then return (name:gsub("^oil://", "")) end
    if name:match("^%a[%w+.-]*://") then return nil end
    return vim.fn.fnamemodify(name, ":p")
end

local function trim_slash(path)
    if path == "/" then return path end
    return (path:gsub("/+$", ""))
end

--- Formats a buffer name / path for the given target's current style.
function M.format(name, target)
    local path = real_path(name)
    if not path then return name ~= "" and name or "[No Name]" end

    local is_dir = path:sub(-1) == "/"
    local bare = trim_slash(path)
    local style = M.get(target)
    local out

    if style == "tail" then
        out = vim.fn.fnamemodify(bare, ":t")
    elseif style == "parent" then
        out = vim.fn.fnamemodify(bare, ":h:t") .. "/" .. vim.fn.fnamemodify(bare, ":t")
    elseif style == "absolute" then
        out = vim.fn.fnamemodify(bare, ":~")
    elseif style == "project" then
        local root = vim.fs.root(bare, require("de100.utils.project-root").markers)
        if root and vim.startswith(bare, root .. "/") then
            out = bare:sub(#root + 2)
        else
            out = vim.fn.fnamemodify(bare, ":~")
        end
    else -- relative
        out = vim.fn.fnamemodify(bare, ":.")
        if out:sub(1, 1) == "/" then out = vim.fn.fnamemodify(bare, ":~") end
    end

    if out == "" or out == "." then out = vim.fn.fnamemodify(bare, ":~") end
    return out .. (is_dir and out:sub(-1) ~= "/" and "/" or "")
end

--- 'tabline' value: one label per tab, formatted with the tabline style.
function M.tabline()
    local parts = {}
    local current = vim.fn.tabpagenr()
    for i = 1, vim.fn.tabpagenr("$") do
        local buflist = vim.fn.tabpagebuflist(i)
        local buf = buflist[vim.fn.tabpagewinnr(i)]
        local label = M.format(vim.api.nvim_buf_get_name(buf), "tabline")
        if vim.bo[buf].buftype == "prompt" then label = "[Prompt]" end
        local modified = vim.bo[buf].modified and " +" or ""
        table.insert(parts, table.concat({
            i == current and "%#TabLineSel#" or "%#TabLine#", "%", i, "T ", i, " ",
            (label:gsub("%%", "%%%%")), modified, " "
        }))
    end
    return table.concat(parts) .. "%#TabLineFill#%T"
end

--- telescope `path_display` function.
function M.telescope(_, path) return M.format(path, "search") end

local function refresh(target)
    if target == "tabline" then
        vim.cmd.redrawtabline()
    elseif target == "incline" then
        local ok, incline = pcall(require, "incline")
        if ok then incline.refresh() end
    elseif target == "lualine" then
        local ok, lualine = pcall(require, "lualine")
        if ok then lualine.refresh() end
    end
    vim.cmd.redraw({bang = true})
end

local function apply(target, style)
    if not vim.tbl_contains(M.targets, target) then
        vim.notify("PathStyle: unknown target '" .. target .. "' (" ..
                       table.concat(M.targets, ", ") .. ")", vim.log.levels.ERROR)
        return
    end
    if not vim.tbl_contains(M.styles, style) then
        vim.notify("PathStyle: unknown style '" .. style .. "' (" ..
                       table.concat(M.styles, ", ") .. ")", vim.log.levels.ERROR)
        return
    end
    M.set(target, style)
    refresh(target)
    vim.notify(("PathStyle %s: %s - %s"):format(target, style, descriptions[style]))
end

local function next_style(target)
    local current = M.get(target)
    for i, style in ipairs(M.styles) do
        if style == current then return M.styles[i % #M.styles + 1] end
    end
    return M.styles[1]
end

local function pick(target)
    vim.ui.select(M.styles, {
        prompt = "Path style for " .. target .. " (current: " .. M.get(target) .. ")",
        format_item = function(style)
            return ("%s - %s%s"):format(style, descriptions[style],
                                         style == M.get(target) and "  [current]" or "")
        end
    }, function(choice) if choice then apply(target, choice) end end)
end

function M.command(args)
    local target, style = args[1], args[2]
    if not target then
        vim.ui.select(M.targets, {
            prompt = "Which path display?",
            format_item = function(t) return ("%s (now: %s)"):format(t, M.get(t)) end
        }, function(choice) if choice then pick(choice) end end)
    elseif style then
        apply(target, style)
    else
        apply(target, next_style(target))
    end
end

function M.setup()
    vim.api.nvim_create_user_command("PathStyle",
                                     function(opts) M.command(opts.fargs) end, {
        nargs = "*",
        desc = "Change how paths are displayed, per target (tabline, incline, lualine, search)",
        complete = function(arglead, cmdline)
            local nargs = #vim.split(vim.trim(cmdline), "%s+")
            if cmdline:match("%s$") then nargs = nargs + 1 end
            local list = nargs <= 2 and M.targets or M.styles
            return vim.tbl_filter(function(item)
                return vim.startswith(item, arglead)
            end, list)
        end
    })
end

return M
