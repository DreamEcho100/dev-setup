return {
    "amitds1997/remote-nvim.nvim",
    -- Remove version pinning to get the latest fix
    -- version = "*", 
    dependencies = {
        "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim",
        "nvim-telescope/telescope.nvim"
    },
    config = function()
        -- Do NOT manually require plenary or assign utils
        -- The plugin should handle its own dependencies
        require("remote-nvim").setup({
            devpod = {
                binary = "devpod",
                docker_binary = "docker",
                -- Replace utils.path_join with standard Lua or plenary.path
                -- Example: use vim.fn.stdpath and string concatenation
                ssh_config_path = vim.fn.stdpath("data") ..
                    "/remote-nvim/ssh_config",
                search_style = "current_dir_only",
                dotfiles = {path = nil, install_script = nil},
                gpg_agent_forwarding = false,
                container_list = "running_only"
            },
            ssh_config = {
                ssh_binary = "ssh",
                scp_binary = "scp",
                ssh_config_file_paths = {vim.fn.expand("~/.ssh/config")},
                ssh_prompts = {
                    {
                        match = "password:",
                        type = "secret",
                        value_type = "static",
                        value = ""
                    }, {
                        match = "continue connecting (yes/no/[fingerprint])?",
                        type = "plain",
                        value_type = "static",
                        value = ""
                    }
                }
            },
            -- Replace utils.path_join for neovim_install_script_path
            neovim_install_script_path = vim.fn.fnamemodify(debug.getinfo(1)
                                                                .source:sub(2),
                                                            ":h:h:h") ..
                "/scripts/neovim_install.sh",
            progress_view = {type = "popup"},
            offline_mode = {
                enabled = false,
                no_github = false,
                cache_dir = vim.fn.stdpath("cache") ..
                    "/remote-nvim/version_cache"
            },
            remote = {
                app_name = "nvim",
                copy_dirs = {
                    config = {
                        base = vim.fn.stdpath("config"),
                        dirs = "*",
                        compression = {enabled = false, additional_opts = {}}
                    },
                    data = {
                        base = vim.fn.stdpath("data"),
                        dirs = {"lazy"},
                        compression = {
                            enabled = true,
                            additional_opts = {"--exclude-vcs"}
                        }
                    },
                    cache = {
                        base = vim.fn.stdpath("cache"),
                        dirs = {},
                        compression = {enabled = true}
                    },
                    state = {
                        base = vim.fn.stdpath("state"),
                        dirs = {},
                        compression = {enabled = true}
                    }
                }
            },
            client_callback = function(port, _)
                require("remote-nvim.ui").float_term(
                    ("nvim --server localhost:%s --remote-ui"):format(port),
                    function(exit_code)
                        if exit_code ~= 0 then
                            vim.notify(
                                ("Local client failed with exit code %s"):format(
                                    exit_code), vim.log.levels.ERROR)
                        end
                    end)
            end,
            log = {
                filepath = vim.fn.stdpath("state") .. "/remote-nvim.log",
                level = "info",
                max_size = 2097152
            }
        })
    end
}
