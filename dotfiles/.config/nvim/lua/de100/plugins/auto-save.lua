-- https://github.com/okuuva/auto-save.nvim
--
-- This is a fork of original plugin `https://github.com/pocco81/auto-save.nvim`
-- but the original one was updated 2 years ago, and I was experiencing issues
-- with autoformat and undo/redo
--
-- Relationship with conform.nvim:
-- auto-save.nvim owns save-on-leave behavior for buffers, windows, command-line
-- entry, focus loss, etc. Because those saves often happen from non-nested
-- autocmds like BufLeave, Neovim can skip the normal BufWritePre formatting
-- path. The AutoSaveWritePre hook below explicitly calls LazyVim.format(),
-- which routes through conform.nvim, before auto-save writes the file.
-- Autocommand group for autosave-related events
local group = vim.api.nvim_create_augroup("autosave", {})

local autosave_blocked = {
    visual = false,
    flash_jump = false,
    snacks_input = false,
    snacks_picker_input = false
}
local autosave_format_restore = {}

local function restore_autoformat(buf)
    local restore = autosave_format_restore[buf]
    if restore == nil then return end

    autosave_format_restore[buf] = nil
    if vim.api.nvim_buf_is_valid(buf) then
        vim.b[buf].autoformat = restore.autoformat
    end
end

-- auto-save.nvim writes from events like BufLeave/FocusLost. Neovim does not
-- run nested BufWritePre autocmds from those callbacks, so LazyVim's normal
-- format-on-save path would be skipped. Format explicitly before auto-save's
-- write, then temporarily disable LazyVim autoformat for that write to avoid a
-- duplicate format when BufWritePre does run outside nested autocmd contexts.
vim.api.nvim_create_autocmd("User", {
    pattern = "AutoSaveWritePre",
    group = group,
    callback = function(opts)
        local buf = opts.data and opts.data.saved_buffer
        if buf == nil or not vim.api.nvim_buf_is_valid(buf) or
            not vim.api.nvim_buf_is_loaded(buf) then return end
        if _G.LazyVim == nil or _G.LazyVim.format == nil then return end

        local ok = pcall(function() LazyVim.format({buf = buf}) end)
        if not ok then return end

        autosave_format_restore[buf] = {autoformat = vim.b[buf].autoformat}
        vim.b[buf].autoformat = false
    end
})

vim.api.nvim_create_autocmd("User", {
    pattern = "AutoSaveWritePost",
    group = group,
    callback = function(opts)
        local buf = opts.data and opts.data.saved_buffer
        if buf ~= nil then
            restore_autoformat(buf)
            print("AutoSaved")
        end
    end
})

-- I do not want to save when I'm in visual mode because I'm usually moving
-- stuff from one place to another, or deleting it
-- https://github.com/okuuva/auto-save.nvim/issues/67#issuecomment-2597631756
local visual_event_group = vim.api.nvim_create_augroup("visual_event",
                                                       {clear = true})

vim.api.nvim_create_autocmd("ModeChanged", {
    group = visual_event_group,
    pattern = {"*:[vV\x16]*"},
    callback = function()
        vim.api.nvim_exec_autocmds("User", {pattern = "VisualEnter"})
        autosave_blocked.visual = true
    end
})

vim.api.nvim_create_autocmd("ModeChanged", {
    group = visual_event_group,
    pattern = {"[vV\x16]*:*"},
    callback = function()
        autosave_blocked.visual = false
        vim.api.nvim_exec_autocmds("User", {pattern = "VisualLeave"})
    end
})

-- Override the `flash.jump` function to detect start and end.
-- This MUST be deferred because this file is evaluated by lazy.nvim during
-- plugin spec collection, before flash.nvim is on the runtimepath. Patching
-- at module top-level would crash startup with "module 'flash' not found".
local function setup_flash_hook()
    local ok, flash = pcall(require, "flash")
    if not ok then return false end

    if flash._autosave_patched then return true end
    flash._autosave_patched = true

    local original_jump = flash.jump
    flash.jump = function(opts)
        vim.api.nvim_exec_autocmds("User", {pattern = "FlashJumpStart"})
        autosave_blocked.flash_jump = true

        local results = {pcall(original_jump, opts)}

        autosave_blocked.flash_jump = false
        vim.api.nvim_exec_autocmds("User", {pattern = "FlashJumpEnd"})

        if not results[1] then error(results[2], 0) end
        table.remove(results, 1)
        return unpack(results)
    end
    return true
end

if not setup_flash_hook() then
    vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        group = group,
        callback = function(args)
            if args.data == "flash.nvim" then setup_flash_hook() end
        end
    })
end

-- Disable auto-save when entering a snacks_input buffer
vim.api.nvim_create_autocmd("FileType", {
    pattern = "snacks_input",
    group = group,
    callback = function()
        vim.api.nvim_exec_autocmds("User", {pattern = "SnacksInputEnter"})
        autosave_blocked.snacks_input = true
    end
})

-- Re-enable auto-save when leaving that buffer
vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    pattern = "*",
    callback = function(opts)
        local ft = vim.bo[opts.buf].filetype
        if ft == "snacks_input" then
            autosave_blocked.snacks_input = false
            vim.api.nvim_exec_autocmds("User", {pattern = "SnacksInputLeave"})
        end
    end
})

-- Disable auto-save when entering a snacks_picker_input buffer
vim.api.nvim_create_autocmd("FileType", {
    pattern = "snacks_picker_input",
    group = group,
    callback = function()
        vim.api.nvim_exec_autocmds("User", {pattern = "SnacksPickerInputEnter"})
        autosave_blocked.snacks_picker_input = true
    end
})

-- Re-enable auto-save when leaving that buffer
vim.api.nvim_create_autocmd("BufLeave", {
    group = group,
    pattern = "*",
    callback = function(opts)
        local ft = vim.bo[opts.buf].filetype
        if ft == "snacks_picker_input" then
            autosave_blocked.snacks_picker_input = false
            vim.api.nvim_exec_autocmds("User",
                                       {pattern = "SnacksPickerInputLeave"})
        end
    end
})

return {
    {
        "okuuva/auto-save.nvim",
        enabled = false, -- Not sure, some of the features of this plugin are nice but I sometimes don't want auto-saving and it can cause issues with undo/redo and autoformatting, so disabling for now
        cmd = "ASToggle",
        event = "VeryLazy",
        opts = {
            enabled = true,
            trigger_events = {
                immediate_save = {
                    "BufLeave", "WinLeave", "WinNewPre",
                    {"CmdlineEnter", pattern = {":", "/", "\\?"}}, "FocusLost",
                    "QuitPre", "VimSuspend"
                },
                defer_save = {
                    "InsertLeave", "TextChanged",
                    {"User", pattern = "VisualLeave"},
                    {"User", pattern = "FlashJumpEnd"},
                    {"User", pattern = "SnacksInputLeave"},
                    {"User", pattern = "SnacksPickerInputLeave"}
                },
                cancel_deferred_save = {
                    "InsertEnter", {"User", pattern = "VisualEnter"},
                    {"User", pattern = "FlashJumpStart"},
                    {"User", pattern = "SnacksInputEnter"},
                    {"User", pattern = "SnacksPickerInputEnter"}
                }
            },
            condition = function(buf)
                if autosave_blocked.visual or autosave_blocked.flash_jump or
                    autosave_blocked.snacks_input or
                    autosave_blocked.snacks_picker_input then
                    return false
                end

                -- Do not save when I'm in insert mode.
                -- Do not add a direct visual mode check here or
                -- cancel_deferred_save won't work.
                local mode = vim.fn.mode()
                if mode == "i" then return false end

                -- Do not autosave prompt, terminal, file picker, or explorer buffers.
                local buftype = vim.bo[buf].buftype
                if buftype ~= "" then return false end

                -- Skip specific filetypes (harpoon, dadbod SQL, mini.files, snacks UIs)
                local filetype = vim.bo[buf].filetype
                if filetype == "harpoon" or filetype == "mysql" or filetype ==
                    "minifiles" or filetype == "snacks_input" or filetype ==
                    "snacks_picker_input" then return false end

                -- Skip autosave if in an active snippet
                local ok_ls, luasnip = pcall(require, "luasnip")
                if ok_ls and luasnip.in_snippet() then
                    return false
                end

                return true
            end,
            write_all_buffers = false,
            -- Keep this false so non-format save autocmds still run. Formatting
            -- is handled explicitly by AutoSaveWritePre above because auto-save's
            -- writes often happen inside non-nested autocmds where BufWritePre
            -- is skipped.
            noautocmd = false,
            lockmarks = false,
            debounce_delay = 2000,
            debug = false
        }
    }
}
