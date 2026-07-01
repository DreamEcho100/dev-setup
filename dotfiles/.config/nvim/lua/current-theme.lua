local theme_state = vim.fn.stdpath("state") .. "/de100/theme/nvim.lua"

if vim.fn.filereadable(theme_state) == 1 then
    dofile(theme_state)
else
    vim.cmd.colorscheme("evergarden-spring")
end
