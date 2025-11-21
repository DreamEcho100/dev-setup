return {
    "mfussenegger/nvim-dap",
    event = "VeryLazy",
    dependencies = {
        -- Creates a beautiful debugger UI
        'rcarriga/nvim-dap-ui', --
        --
        -- Required dependency for nvim-dap-ui
        'nvim-neotest/nvim-nio', --
        --
        -- Installs the debug adapters for you
        'mason-org/mason.nvim', -- mason.nvim package manager
        'jay-babu/mason-nvim-dap.nvim', --
        --
        -- Add your own debuggers here
        "leoluz/nvim-dap-go", -- Go debugger
        "rcarriga/nvim-dap-ui" -- Debugger UI
    },
    keys = {
        -- Basic debugging keymaps, feel free to change to your liking!
        {
            '<F5>',
            function() require('dap').continue() end,
            desc = 'Debug: Start/Continue'
        },
        {
            '<F1>',
            function() require('dap').step_into() end,
            desc = 'Debug: Step Into'
        },
        {
            '<F2>',
            function() require('dap').step_over() end,
            desc = 'Debug: Step Over'
        },
        {
            '<F3>',
            function() require('dap').step_out() end,
            desc = 'Debug: Step Out'
        }, {
            '<leader>b',
            function() require('dap').toggle_breakpoint() end,
            desc = 'Debug: Toggle Breakpoint'
        }, {
            '<leader>B',
            function()
                require('dap').set_breakpoint(vim.fn
                                                  .input 'Breakpoint condition: ')
            end,
            desc = 'Debug: Set Breakpoint'
        },
        -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
        {
            '<F7>',
            function() require('dapui').toggle() end,
            desc = 'Debug: See last session result.'
        }
    },
    config = function()
        local dap = require 'dap'
        local dapui = require 'dapui'

        require('mason-nvim-dap').setup {
            -- Makes a best effort to setup the various debuggers with
            -- reasonable debug configurations
            automatic_installation = true,

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            handlers = {},

            -- You'll need to check that you have the required things installed
            -- online, please don't ask me how to install them :)
            ensure_installed = {
                -- Update this to ensure that you have the debuggers for the langs you want
            }
        }

        -- Dap UI setup
        -- For more information, see |:help nvim-dap-ui|
        dapui.setup {
            -- Set icons to characters that are more likely to work in every terminal.
            --    Feel free to remove or use ones that you like more! :)
            --    Don't feel like these are good choices.
            icons = {expanded = '▾', collapsed = '▸', current_frame = '*'},
            controls = {
                icons = {
                    pause = '⏸',
                    play = '▶',
                    step_into = '⏎',
                    step_over = '⏭',
                    step_out = '⏮',
                    step_back = 'b',
                    run_last = '▶▶',
                    terminate = '⏹',
                    disconnect = '⏏'
                }
            }
        }

        -- Change breakpoint icons
        -- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
        -- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
        -- local breakpoint_icons = vim.g.have_nerd_font
        --     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
        --   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
        -- for type, icon in pairs(breakpoint_icons) do
        --   local tp = 'Dap' .. type
        --   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
        --   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
        -- end

        dap.listeners.after.event_initialized['dapui_config'] = dapui.open
        dap.listeners.before.event_terminated['dapui_config'] = dapui.close
        dap.listeners.before.event_exited['dapui_config'] = dapui.close

        -- Install golang specific config
        require('dap-go').setup {
            delve = {
                -- On Windows delve must be run attached or it crashes.
                -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
                detached = vim.fn.has 'win32' == 0
            }
        }

        --[[  C/C++/Rust Debugging (codelldb)
        
        SINGLE FILE:
        1. Compile with debug symbols:
           gcc -g myfile.c -o myfile
           g++ -g myfile.cpp -o myfile
           rustc -g myfile.rs
        2. Set breakpoints in your code (leader+b)
        3. Press <F5>
        4. Enter the executable path: ./myfile
        
        FULL PROJECT:
        1. For C/C++: Create a Makefile or use CMake with -DCMAKE_BUILD_TYPE=Debug
           make
        2. For Rust: cargo build
        3. Set breakpoints in your code
        4. Press <F5>
        5. Enter the executable path: ./target/debug/myproject or ./build/myproject
        
        TIP: You can modify the program function below to default to your build output path
        --]]
        -- Get the path to codelldb installed by Mason
        local codelldb_path = vim.fn.stdpath("data") .. "/mason/bin/codelldb"

        dap.adapters.codelldb = {
            type = 'server',
            port = "${port}",
            executable = {command = codelldb_path, args = {"--port", "${port}"}}
        }

        dap.configurations.cpp = {
            {
                name = "Launch file",
                type = "codelldb",
                request = "launch",
                program = function()
                    return vim.fn.input('Path to executable: ',
                                        vim.fn.getcwd() .. '/', 'file')
                end,
                cwd = '${workspaceFolder}',
                stopOnEntry = false
            }
        }

        -- Same config for C and Rust
        dap.configurations.c = dap.configurations.cpp
        dap.configurations.rust = dap.configurations.cpp

        --[[ JavaScript/TypeScript/Node.js Debugging (js-debug-adapter)
        
        SINGLE FILE:
        1. Open your JS/TS file
        2. Set breakpoints (leader+b)
        3. Press <F5> → Select "Launch file"
        4. File will run with Node.js debugger attached
        
        FULL PROJECT:
        Method 1 - Launch with debugger:
        1. Open any project file
        2. Set breakpoints
        3. Press <F5> → Select "Launch file"
        4. To debug with npm scripts, modify dap.configurations.javascript below:
           Add: { type = "pwa-node", request = "launch", name = "npm start",
                  runtimeExecutable = "npm", runtimeArgs = {"run", "start"}, ... }
        
        Method 2 - Attach to running process:
        1. Start your app with inspect flag:
           node --inspect server.js
           npm run dev -- --inspect
        2. Press <F5> → Select "Attach"
        3. Pick the Node.js process from the list
        
        TYPESCRIPT: For TS files, use ts-node or compile first, then debug the JS output
        --]]
        -- Get the path to js-debug-adapter installed by Mason
        local js_debug_path = vim.fn.stdpath("data") ..
                                  "/mason/packages/js-debug-adapter"

        dap.adapters["pwa-node"] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = {
                command = "node",
                args = {
                    js_debug_path .. "/js-debug/src/dapDebugServer.js",
                    "${port}"
                }
            }
        }

        -- Node.js configuration
        dap.configurations.javascript = {
            {
                type = "pwa-node",
                request = "launch",
                name = "Launch file",
                program = "${file}",
                cwd = "${workspaceFolder}"
            }, {
                type = "pwa-node",
                request = "attach",
                name = "Attach",
                processId = require('dap.utils').pick_process,
                cwd = "${workspaceFolder}"
            }
        }

        -- TypeScript uses same config as JavaScript
        dap.configurations.typescript = dap.configurations.javascript

        --[[ React/Next.js/Solid.js/Browser Debugging (Chrome DevTools)
        
        CLIENT-SIDE (React, Solid.js, etc.):
        ====================================
        Method 1 - Chrome Debugger (Browser code):
        1. Start your dev server: npm run dev
        2. Open Chrome with remote debugging:
           google-chrome --remote-debugging-port=9222
        3. Open your app in Chrome
        4. Set breakpoints in your React/Solid components
        5. Press <F5> → Select "Attach to Chrome"
        6. Breakpoints in browser code will now work!
        
        Method 2 - Use browser DevTools (simpler):
        1. Open Chrome DevTools (F12)
        2. Use Sources tab to set breakpoints
        (Native browser debugging is often easier for client code)
        
        SERVER-SIDE (Next.js, Solid Start):
        ====================================
        Next.js API Routes / Server Components:
        1. Set breakpoints in API routes or Server Components
        2. Press <F5> → Select "Next.js: debug server"
        3. Works just like Node.js debugging!
        
        FULL-STACK (Debug both):
        =========================
        Use compound configurations in .vscode/launch.json:
        1. Debug server with Node debugger
        2. Debug client with Chrome debugger
        3. Both run simultaneously
        
        Example .vscode/launch.json for Next.js:
        {
          "version": "0.2.0",
          "configurations": [
            {
              "name": "Next.js: debug server",
              "type": "pwa-node",
              "request": "launch",
              "runtimeExecutable": "npm",
              "runtimeArgs": ["run", "dev"],
              "port": 9229
            },
            {
              "name": "Next.js: debug client",
              "type": "chrome",
              "request": "launch",
              "url": "http://localhost:3000",
              "webRoot": "${workspaceFolder}"
            },
            {
              "name": "Next.js: debug full stack",
              "type": "node",
              "request": "launch",
              "compounds": ["Next.js: debug server", "Next.js: debug client"]
            }
          ]
        }
        --]]

        -- Chrome debugger for browser-side JavaScript (React, Solid, etc.)
        dap.adapters.chrome = {
            type = 'executable',
            command = 'node',
            args = {
                vim.fn.stdpath("data") ..
                    '/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js'
            }
        }

        -- Add browser debugging configurations
        local browser_configs = {
            {
                type = "chrome",
                request = "attach",
                name = "Attach to Chrome",
                protocol = "inspector",
                port = 9222,
                webRoot = "${workspaceFolder}",
                sourceMaps = true
            }, {
                type = "chrome",
                request = "launch",
                name = "Launch Chrome",
                url = "http://localhost:3000",
                webRoot = "${workspaceFolder}",
                sourceMaps = true
            }
        }

        -- Add to JavaScript and TypeScript configs
        vim.list_extend(dap.configurations.javascript, browser_configs)
        vim.list_extend(dap.configurations.typescript, browser_configs)

        -- -- Svelte uses same config as JavaScript with browser configs
        -- dap.configurations.svelte = vim.deepcopy(dap.configurations.javascript)

        --[[ Python Debugging (debugpy)
        
        SINGLE FILE:
        1. Open your Python file
        2. Set breakpoints (leader+b)
        3. Press <F5>
        4. Current file will be debugged automatically
        
        FULL PROJECT:
        Method 1 - Debug main entry point:
        1. Open your main.py or app.py
        2. Set breakpoints across your modules
        3. Press <F5>
        
        Method 2 - Debug with arguments:
        Modify dap.configurations.python below to add:
        { type = 'python', request = 'launch', name = "Launch with args",
          program = "${file}", args = {"arg1", "arg2"}, ... }
        
        Method 3 - Debug Flask/Django:
        Add configuration:
        { type = 'python', request = 'launch', name = "Flask",
          module = "flask", args = {"run", "--no-debugger", "--no-reload"}, ... }
        
        Virtual Environment: Update pythonPath function below to point to your venv
        --]]
        dap.adapters.python = {
            type = 'executable',
            command = vim.fn.stdpath("data") ..
                '/mason/packages/debugpy/venv/bin/python',
            args = {'-m', 'debugpy.adapter'}
        }

        dap.configurations.python = {
            {
                type = 'python',
                request = 'launch',
                name = "Launch file",
                program = "${file}",
                pythonPath = function() return '/usr/bin/python3' end
            }
        }

        --[[ Go Debugging (delve via dap-go plugin)
        
        SINGLE FILE:
        1. Create a simple Go file with package main
        2. Set breakpoints (leader+b)
        3. Press <F5>
        4. The file will be compiled and debugged
        
        FULL PROJECT:
        Method 1 - Debug main package:
        1. Open your main.go or any file in main package
        2. Set breakpoints across your packages
        3. Press <F5>
        4. Delve will build and debug your entire project
        
        Method 2 - Debug tests:
        Use dap-go specific commands:
        :lua require('dap-go').debug_test()  -- Debug nearest test
        :lua require('dap-go').debug_last_test()  -- Debug last test
        
        Method 3 - Attach to running process:
        1. Start your Go app with dlv: dlv exec ./myapp --headless --listen=:2345
        2. Use attach configuration (may need to add to dap.configurations.go)
        
        TIP: The dap-go plugin automatically detects your go.mod and sets up paths
        --]]
        -- Go debugging is already configured via dap-go plugin above

        --[[ PROJECT-SPECIFIC DEBUG CONFIGURATIONS
        
        You have 3 options for project-specific debug configs:
        
        OPTION 1: VS Code compatible .vscode/launch.json (RECOMMENDED)
        ================================================================
        Create .vscode/launch.json in your project root. nvim-dap will read it automatically!
        Works exactly like VS Code. Example:
        
        {
          "version": "0.2.0",
          "configurations": [
            {
              "type": "pwa-node",
              "request": "launch",
              "name": "Launch Express Server",
              "program": "${workspaceFolder}/server.js",
              "env": { "NODE_ENV": "development" }
            },
            {
              "type": "python",
              "request": "launch",
              "name": "Django runserver",
              "program": "${workspaceFolder}/manage.py",
              "args": ["runserver", "8000"]
            }
          ]
        }
        
        OPTION 2: Neovim-specific .nvim/dap.lua (More powerful)
        ========================================================
        Create .nvim/dap.lua in your project root. Example:
        
        return {
          configurations = {
            javascript = {
              {
                type = "pwa-node",
                request = "launch",
                name = "Launch API Server",
                program = "${workspaceFolder}/api/server.js",
                env = { PORT = "3000", NODE_ENV = "development" }
              }
            }
          }
        }
        
        OPTION 3: Inline in this file (For global defaults)
        ===================================================
        Add configurations directly above. Example already shown for each language.
        
        PRIORITY: .nvim/dap.lua > .vscode/launch.json > global configs (this file)
        
        See examples below for each language:
        --]]

        -- Load VS Code launch.json if it exists
        require('dap.ext.vscode').load_launchjs(nil, {
            ['pwa-node'] = {'javascript', 'typescript'},
            ['python'] = {'python'},
            ['codelldb'] = {'c', 'cpp', 'rust'}
        })

        -- Load project-specific .nvim/dap.lua if it exists
        local project_dap_config = vim.fn.getcwd() .. '/.nvim/dap.lua'
        if vim.fn.filereadable(project_dap_config) == 1 then
            local ok, project_config = pcall(dofile, project_dap_config)
            if ok and project_config.configurations then
                for lang, configs in pairs(project_config.configurations) do
                    if dap.configurations[lang] then
                        -- Append to existing configs
                        vim.list_extend(dap.configurations[lang], configs)
                    else
                        -- Create new language config
                        dap.configurations[lang] = configs
                    end
                end
            end
        end
    end
}
