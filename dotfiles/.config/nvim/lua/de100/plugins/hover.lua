return {
  {
    "lewis6991/hover.nvim",
		enabled = false,
    event = "LspAttach", -- Load only when LSP attaches (optional, but good for perf)
    init = function()
      -- Optional: If you want to ensure the default LazyVim 'K' is disabled
      -- before hover.nvim loads, you can do it here. 
      -- However, defining the key in 'keys' below usually overrides it.
      vim.o.mousemoveevent = true -- Essential for mouse hover support
    end,
    opts = {
      providers = {
        "hover.providers.lsp",
        "hover.providers.diagnostic",
        "hover.providers.dap",
        "hover.providers.man",
        "hover.providers.dictionary",
        -- Optional providers
        "hover.providers.gh",
        "hover.providers.gh_user",
        "hover.providers.fold_preview",
        "hover.providers.highlight",
        -- 'hover.providers.jira', -- Uncomment if you have jira-cli
      },
      preview_opts = {
        border = "single",
      },
      title = true,
      mouse_providers = {
        "hover.providers.lsp",
      },
      mouse_delay = 1000,
    },
    keys = {
      {
        "K",
        function()
          require("hover").open()
        end,
        desc = "Hover (LSP/Diags/etc)",
        mode = "n",
      },
      {
        "gK",
        function()
          require("hover").enter()
        end,
        desc = "Hover (Enter)",
        mode = "n",
      },
      {
        "<C-p>",
        function()
          require("hover").switch("previous")
        end,
        desc = "Hover (Previous Source)",
        mode = "n",
      },
      {
        "<C-n>",
        function()
          require("hover").switch("next")
        end,
        desc = "Hover (Next Source)",
        mode = "n",
      },
      {
        "<MouseMove>",
        function()
          require("hover").mouse()
        end,
        desc = "Hover (Mouse)",
        mode = "n",
        -- Note: LazyVim might ignore <MouseMove> in keys. 
        -- The init function above sets vim.o.mousemoveevent = true which is the main requirement.
        -- If the keymap doesn't register, add it manually in a separate autocmd or lua block.
      },
    },
    config = function(_, opts)
      require("hover").config(opts)
      
      -- Fallback for Mouse: If <MouseMove> keymap fails in LazyVim's 'keys'
      vim.keymap.set("n", "<MouseMove>", function()
        require("hover").mouse()
      end, { desc = "hover.nvim (mouse)" })
    end,
  },
}
