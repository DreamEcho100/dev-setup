-- 📖 Tutorial: docs/neovim-tutorials-from-0-to-hero/21-python-math-jupyter.md
-- Converts .ipynb <-> .py (percent format) transparently on read/write.
-- Requires the `jupytext` CLI (installed via neovim.yml pip task).
-- https://github.com/GCBallesteros/jupytext.nvim
--
-- Must load eagerly (lazy = false), not lazy-loaded via `ft = "ipynb"`.
-- Neovim's own filetype.lua deliberately maps the `.ipynb` extension to
-- filetype "json" (never "ipynb"), so an `ft`-based trigger can never fire —
-- confirmed via `vim.filetype.match({filename = "x.ipynb"})` returning
-- "json". Without this plugin loaded, its BufReadCmd *.ipynb autocmd (which
-- does the actual conversion) never gets registered, and .ipynb files show
-- raw JSON. This is the plugin's own documented fix, not a workaround.

-- jupytext's BufReadCmd (jupytext/utils.lua's get_ipynb_metadata) does
-- vim.json.decode(read file) unconditionally, so a genuinely empty .ipynb
-- (0 bytes — e.g. touched by oil.nvim, or a fresh `:e new.ipynb`) crashes
-- with "Expected value but found T_END". :JupytextNew and the seed autocmd
-- below both work by seeding valid empty-notebook JSON on disk *before*
-- jupytext ever reads the file.
--
-- The seed autocmd deliberately hooks BufReadCmd, not BufReadPre: Neovim
-- does not fire BufReadPre/BufReadPost around a *Cmd-overridden read (the
-- Cmd variant fully replaces the built-in read they normally bracket) —
-- confirmed empirically, a BufReadPre autocmd on `*.ipynb` here never
-- fires at all. Multiple BufReadCmd autocmds for the same pattern DO all
-- run, in registration order, so registering ours before calling
-- jupytext's own setup() (which registers its BufReadCmd) guarantees ours
-- runs first and seeds the file in time for jupytext's real read.
local function empty_notebook_json()
    return '{"cells": [], "metadata": {"kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"}}, "nbformat": 4, "nbformat_minor": 5}'
end

local function new_notebook(path)
    if path == nil or path == "" then
        vim.notify(
            "JupytextNew: provide a file path, e.g. :JupytextNew notes/lesson1",
            vim.log.levels.ERROR)
        return
    end
    if not path:match("%.ipynb$") then path = path .. ".ipynb" end

    local full_path = vim.fn.fnamemodify(path, ":p")
    if vim.fn.filereadable(full_path) == 1 then
        vim.notify("JupytextNew: file already exists: " .. full_path,
                    vim.log.levels.ERROR)
        return
    end

    vim.fn.mkdir(vim.fn.fnamemodify(full_path, ":h"), "p")
    vim.fn.writefile({empty_notebook_json()}, full_path)
    vim.cmd.edit(vim.fn.fnameescape(full_path))
end

return {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    opts = {style = "markdown", output_extension = "md", force_ft = "markdown"},
    config = function(_, opts)
        -- Must be registered before jupytext's own setup() (below), so this
        -- BufReadCmd runs first — see the comment above on why BufReadPre
        -- doesn't work here.
        vim.api.nvim_create_autocmd("BufReadCmd", {
            pattern = "*.ipynb",
            group = vim.api.nvim_create_augroup("de100_jupytext_seed_empty",
                                                 {clear = true}),
            callback = function(ev)
                if vim.fn.getfsize(ev.match) <= 0 then
                    vim.fn.writefile({empty_notebook_json()}, ev.match)
                end
            end
        })

        require("jupytext").setup(opts)

        vim.api.nvim_create_user_command("JupytextNew", function(cmd_opts)
            new_notebook(cmd_opts.args)
        end, {
            nargs = 1,
            complete = "file",
            desc = "Create a new Jupyter notebook (.ipynb) seeded with valid empty-notebook JSON"
        })
    end,
    keys = {
        {
            "<leader>jn",
            function()
                vim.ui.input({prompt = "New notebook path: "}, function(input)
                    if input then new_notebook(input) end
                end)
            end,
            desc = "Jupyter: new notebook"
        }
    }
}
